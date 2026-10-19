/**
* @description Class for performing account maintenance tasks
*
* @author Karabo Machubeni
*
* @date August 2023
*/
public without sharing class CMN_SRV_AccountOwnerUpdate {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_SRV_AccountOwnerUpdate.class.getName());
    
    /**
    * @description processes the accounts that quailify for an account owner update
    * @author Karabo Machubeni | 21-08-2023
    * @param scope
    * @return List<Account>>
    *    2023-08-21  Karabo Machubeni   Core logic from the execute method of the CMN_BATCH_AccountMaintenance
    **/
    
    public static Result processAccounts(List<Account> scope){
        Map<String, List<Account>> rmAeCode2Accounts = populateRmAeCode2AccountsMap(scope);
        List<Account> accountsToUpdate = getAccountsToUpdate(rmAeCode2Accounts);
        return updateAccounts(accountsToUpdate);
    }
    
    /**
    * @description Creates a Map by RM Code containing a list of all accounts for that code
    * @author Łukasz Kojzar | 12-10-2022 
    * @param accountsToUpdate
    *    2023-08-21  Karabo Machubeni   Core logic from the execute method of the CMN_BATCH_AccountMaintenance
    **/
    
    public static Result updateAccounts(List<Account> accountsToUpdate){
        Result result = new Result();
        
        try {
            // Update any accounts with changed scores and let the trigger know not to re-calculate
            if (!accountsToUpdate.isEmpty()) {
                
                Database.SaveResult[] results = Database.update(accountsToUpdate, false);
                
                for (integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    
                    if (!sr.isSuccess()) {
                        handleError(sr, accountsToUpdate[i]);
                        result.errors++;
                    }
                    else {
                        result.ownersUpdated++;
                    }
                }
            }
            
            if (result.errors==0) {
                LOGGER.debug('execute: Update succesful');
            }
            else {
                LOGGER.error('execute: Errors updating accounts: '+result.errors+' Account record(s) not updated');
            }
        }
        catch (Exception ex) {
            LOGGER.fatal('execute: Unhandled exception', ex);
            throw ex;
        }
        return result;
    }
    
    /**
    * @description Handle and error on a save result
    * @author Derek Hughes | 14-06-2023 
    * @param sr 
    * @param Account
    * 2023-08-21  Karabo Machubeni   Core logic from the execute method of the CMN_BATCH_AccountMaintenance
    **/
    @TestVisible
    private static void handleError(Database.SaveResult sr, Account account) {
        String errorMessage = 'Unknown error';
        if (!sr.getErrors().isEmpty()) {
            errorMessage = sr.getErrors()[0].getMessage();
        }
        LOGGER.warn('execute: Error updating account: '+account.Name+': '+errorMessage);
    }
    
    /**
    * @description Creates a Map by RM Code containing a list of all accounts for that code
    * @author Łukasz Kojzar | 12-10-2022 
    * @param allAccs 
    * @return Map<String, List<Account>>
    *    2023-08-21  Karabo Machubeni   Core logic from the execute method of the CMN_BATCH_AccountMaintenance
    **/
    private static Map<String, List<Account>> populateRmAeCode2AccountsMap(List<Account> allAccs) {
        
        Map<String, List<Account>> rmAeCode2Accounts = new Map<String, List<Account>>();
        
        for(Account acc : allAccs) {
            if(!acc.Owner.IsActive || acc.Owner.RM_AE_Code__c != acc.RelationshipMgrCode__c) {
                if (rmAeCode2Accounts.containsKey(acc.RelationshipMgrCode__c)) {
                    rmAeCode2Accounts.get(acc.RelationshipMgrCode__c).add(acc);
                } else {
                    rmAeCode2Accounts.put(acc.RelationshipMgrCode__c, new List<Account>{acc});
                }
            }
        }

        return rmAeCode2Accounts;
    }
    
    /**
    * @description Determines which accounts to update, based on the owner not mathing the RM code
    * @author Łukasz Kojzar | 12-10-2022 
    * @param rmAeCode2Accounts
    * @return Map<String, List<Account>>
    *    2023-08-21  Karabo Machubeni   Logic extracted from CMN_BATCH_AccountMaintenance
    **/
    private static List<Account> getAccountsToUpdate(Map<String, List<Account>> rmAeCode2Accounts) {
        
        List<Account> accsToUpdate = new List<Account>();
        Map<String, Id> rmAeCode2UserId = populateRmAeCode2UserId(rmAeCode2Accounts);
        
        for (String rmAeCode : rmAeCode2Accounts.keySet()) {
            Id newOwnerId = rmAeCode2UserId.get(rmAeCode);
            if (newOwnerId != null) {
                for (Account acc : rmAeCode2Accounts.get(rmAeCode)) {
                    acc.OwnerId = newOwnerId;
                    accsToUpdate.add(acc);
                }
            }
        }
        
        return accsToUpdate;
    }
    
    /**
    * @description Determines which accounts to update, based on the owner not mathing the RM code
    * @author Łukasz Kojzar | 12-10-2022 
    * @param rmAeCode2Accounts
    * @return Map<String, List<Account>>
    *    2023-08-21  Karabo Machubeni   Logic extracted from CMN_BATCH_AccountMaintenance
    **/
    private static Map<String, Id> populateRmAeCode2UserId(Map<String, List<Account>> rmAeCode2Accounts) {
        
        Map<String, Id> rmAeCode2UserId = new Map<String, Id>();
        
        if (rmAeCode2Accounts.keySet().isEmpty()) {
            return rmAeCode2UserId;
        }
        
        List<User> users = [SELECT Id, RM_AE_Code__c FROM User WHERE RM_AE_Code__c IN :rmAeCode2Accounts.keySet() AND IsActive = true];
        for(User u : users) {
            rmAeCode2UserId.put(u.RM_AE_Code__c, u.Id);
        }
        return rmAeCode2UserId;
    }
    
    // Inner class to represent the results from the process
    public class Result {

        public Integer errors = 0;
        public Integer ownersUpdated = 0;
        public String errorMessages  = '';
      
    }
}