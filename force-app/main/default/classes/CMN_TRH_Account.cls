/**
* @description Class for performing account maintenance tasks
*
* @author Karabo Machubeni
*
* @date August 2023

*
* 2024-03-08    Derek Hughes    MOved the existing logic to own method and called from andFinally
*                               Added logic to find leads and link them to accounts when accounts are created with external identifier
* 2023-10-12    Derek Hughes    Convert inline SELECT to use Selector class
* 2024-03-15    Gul Aamir       Added logic tolink accounts to a new/existing inividual
* 2024-06-18    Derek Hughes    Complete individul creation/linking logic for Flexipay in Uganda
*                               Remove duplicate updates to account owner process (someone else unknown also refactored this)
* 2025-08-15    Jaco de Lange   Add a null checker on the indiLst list in the loadIndividualsByIdentityNumber method                              
*/

public with sharing class CMN_TRH_Account extends CMN_TRH_BaseObject {

    @TestVisible private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_TRH_Account.class.getName());
    
    public static final String ZA_RELATIONSHIP_MANAGEMENT = 'ZA';  
    
    @TestVisible private Set<String> clientExternalIds = new Set<String>();
    Relationship_Management_Settings__mdt relationshipManagement = Relationship_Management_Settings__mdt.getInstance('ZA');

    private final Set<Id> accIds = new Set<Id>();

    public static boolean doUpdate = true;
    @TestVisible private Map<String,Account> identityNumbers = new Map<String,Account>();
    @TestVisible private Map<String, List<Account>> accountsByIdentityNumber = new Map<String, List<Account>>();
    @TestVisible private Map<String,Individual> individualsByIdentityNumber = new Map<String,Individual>();
    @TestVisible private Set<String> individualsNotInserted = new Set<String>();
    private final List<Individual> individualsToInsert = new List<Individual>();
    @TestVisible private List<Account> accToUpdate = new List<Account>();

    /**
     * @description This method is called prior to execution of a AFTER Trigger. Use this to cache
     * any data required into maps prior execution of the Trigger.
     * @author Derek Hughes | 09-03-2024 
     **/
    public override void bulkAfter() {
        try{

            LOGGER.info('CMN_TRH_Account bulkAfter()');

            super.bulkAfter();
        
            for (Account account : (List<Account>)Trigger.new) {
            if (String.IsNotBlank(account.ExternalIdentifier__c)) {
                clientExternalIds.add(account.ExternalIdentifier__c);
            }
            accIds.add(account.Id);
            }

            loadAccountsByIdentityNumber();
            if(!accountsByIdentityNumber.keySet().isEmpty()){
                loadIndividualsByIdentityNumber();
                validateIndividualsForAllIdNumber();
            }

            wealthAndInvestmentAccs(accIds);

        }catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : bulkAfter failure', ex);
        }     
    }

    /**
     * @description This method is called once all records have been processed by the Trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     * @author Derek Hughes | 09-03-2024 
     */
    public override void andFinally() {

        try{
            LOGGER.info('CMN_TRH_Account andFinally()');

                if (Trigger.isAfter && Trigger.isInsert) {
                    linkLeads();
                }

                // If there are any accounts that need owner updates then process them now 
                if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && !accToUpdate.isEmpty()) {
                    CMN_SRV_AccountOwnerUpdate.processAccounts(accToUpdate);
                }

                if(!individualsNotInserted.isEmpty()){
                    prepareIndividualsToInsert();
                }
                if(!accountsByIdentityNumber.keySet().isEmpty()){
                    prepareAccountToUpdate();
                }
        }catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : andFinally failure', ex);
        }     

    }

    /**
    * @description Update all the leads that matched the new accounts and were not already linked
    * @author Derek Hughes | 08-03-2024 
    **/
    @TestVisible
    private void linkLeads() {
         try{
            List<Lead> leadsToLink = new List<Lead>();

            // Get all the leads for those External Identifiers that are not linked to clients
            final SEL_Lead leadSelector = new SEL_Lead(false, false, false);
            leadsToLink = leadSelector.selectByIdWithNoRelatedAccount(clientExternalIds);

            LOGGER.info('CMN_TRH_Account linkLeads: leadsToLink.size='+leadsToLink.size());

            // set the Related Account on the leads
            if (leadsToLink != null && !leadsToLink.isEmpty()) {
                
                for (Lead lead : leadsToLink) {
                    lead.FinServ__RelatedAccount__r = new Account(
                    );
                }
                if(Schema.SobjectType.Lead.isupdateable()){
                    
                // Do not fail if any of these updates fail, just log an error
                Database.SaveResult[] results = Database.update(leadsToLink, false);

                Integer errors = 0;
                String errorMessage = '';

                for (integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
                    
                    if (!sr.isSuccess()) {
                        errors++;
                        if (!sr.getErrors().isEmpty()) {
                            errorMessage += sr.getErrors()[0].getMessage() + '\n';
                        }
                    }
                }

                if (errors > 0) {
                    LOGGER.error(errors+' error(s) occurred when linking leads to accounts:\n\n'+errorMessage);
                }

            }
        }
        } catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : linkLeads failure', ex);
        }   
    }

    /**
    * @description : Get all the Wealth and Investment accounts business unit only
    **/
    @TestVisible
    private void wealthAndInvestmentAccs (Set<Id> accIds){

        try{

            LOGGER.info('CMN_TRH_Account wealthAndInvestmentAccs()');

            List<Account> accLst = new SEL_Account().selectByIds(accIds);
            for(Account acc: accLst){
                // This current code should be executable for Wealth and Investment business unit only
                if(acc.VIPIndicator__c==true && acc.ExternalCIFCountry__c== relationshipManagement.DeveloperName && acc.RelationshipMgrCode__c !=null){
                    accToUpdate.add(acc);
                }
            }
        }catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : wealthAndInvestmentAccs failure', ex);
        }  
    }

    /**
    * @description : Get all the accounts with CMN_IdentityNumber__pc
    **/
    @TestVisible
    private void loadAccountsByIdentityNumber(){
        try {
            LOGGER.info('CMN_TRH_Account loadAccountsByIdentityNumber()');

            List<Account> accountsNew = (List<Account>)Trigger.new;
            Map<Id,Account> accountsOld = (Map<Id,Account>)Trigger.oldMap;
            for(Account acc: accountsNew){
                if( (String.IsNotBlank(acc.CMN_IdentityNumber__pc) && acc.PersonIndividualId == null) || (accountsOld != null && acc.CMN_IdentityNumber__pc != accountsOld.get(acc.Id).CMN_IdentityNumber__pc)) {
                    identityNumbers.put(acc.CMN_IdentityNumber__pc,acc);
                }
            }

            Set<String> idNos = identityNumbers.keyset();
            List<Account> accLst = new SEL_Account().selectByPersonIdentityNumber(idNos);
            if(accLst!=null && !accLst.isEmpty()){
                for(Account acc: accLst){
                    if(!accountsByIdentityNumber.containsKey(acc.CMN_IdentityNumber__pc)){
                        accountsByIdentityNumber.put(acc.CMN_IdentityNumber__pc, new List<Account>());
                    }
                    accountsByIdentityNumber.get(acc.CMN_IdentityNumber__pc).add(acc);
                }
            }
        } catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : loadAccountsByIdentityNumber failure', ex);
        }      
    }


    /**
    * @description : Get all the individuals for id no keyset
    **/
    @TestVisible
    private void loadIndividualsByIdentityNumber(){
         try{
            LOGGER.info('CMN_TRH_Account loadIndividualsByIdentityNumber()');

            Set<String> idNos = identityNumbers.keyset();
            List<Individual> indiLst = new SEL_Individual().selectByNationalIdentityNumbers(idNos);
            if (indiLst!=null && !indiLst.isEmpty()){
                for(Individual indi: indiLst){
                    individualsByIdentityNumber.put(indi.National_Identity_Number__c,indi);
                }
            }  
         }catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : loadIndividualsByIdentityNumber failure', ex);
        }  
    }
    /**
    * @description : Get and validates id no for all the individuals
    if the current accounts contains Id but the individual objects query doesnot contain the same ids, 
    add the same among the ones to create under individual records
    **/
    @TestVisible
    private void validateIndividualsForAllIdNumber(){
        try{
            LOGGER.info('CMN_TRH_Account validateIndividualsForAllIdNumber()');

            for(String idNum: identityNumbers.keyset()){
                if(accountsByIdentityNumber.get(idNum).size() > 0 && !individualsByIdentityNumber.containsKey(idNum)){
                        individualsNotInserted.add(idNum);
                }  
            }
        }  catch (Exception ex) {
            LOGGER.fatal('CMN_TRH_Account : validateIndividualsForAllIdNumber failure', ex);
        }    
    }

    /**
    * @description : Inserts new individual records
    **/
    @TestVisible
    private void prepareIndividualsToInsert(){
        for(String idNum: individualsNotInserted){
            individualsToInsert.add(
                new Individual(
                    FirstName = identityNumbers.get(idNum).FirstName, 
                    LastName = identityNumbers.get(idNum).LastName , 
                    National_Identity_Number__c = idNum,
                    External_Country_Code__c=identityNumbers.get(idNum).ExternalCIFCountry__c
                    ));
        }
        try{
            if(Schema.SobjectType.Individual.iscreateable()){
                Database.SaveResult[] results = Database.insert(individualsToInsert, false);

                for(Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        for(Database.Error err : result.getErrors()) {
                            LOGGER.error('Unable to insert individual : Error : ' + err.getMessage());
                        }
                    }
                }
            }
        } catch (DmlException e){
            LOGGER.fatal('Unable to perform the insert for the individuals : ' + e.getMessage());
        }

        for(Individual indi: individualsToInsert){
            individualsByIdentityNumber.put(indi.National_Identity_Number__c,indi);
        }
    }

    /**
    * @description : Updates existing accounts
    **/
    @TestVisible
    private void prepareAccountToUpdate(){
        for(String idNum: accountsByIdentityNumber.keySet()){
            String individualId;
            if(individualsByIdentityNumber.containsKey(idNum)){
                individualId = individualsByIdentityNumber.get(idNum).Id;
            }
            for(Account acc: accountsByIdentityNumber.get(idNum)){
                Account acnt = new Account();
                acnt.Id=acc.Id;

                if(String.isNotBlank(individualId)){
                    acnt.PersonIndividualId = individualId;
                }
                if(String.isBlank(individualId) && acc.PersonIndividualId != null){
                    acnt.PersonIndividualId = null;
                }

                accToUpdate.add(acnt);
            }
        }

        if (!accToUpdate.isEmpty() && doUpdate) {
            doUpdate = false;
            try{

                if(Schema.SobjectType.Account.isupdateable()){
                    Database.SaveResult[] results = Database.update(accToUpdate, false);

                    for(Database.SaveResult result : results) {
                        if (!result.isSuccess()){
                            for(Database.Error err : result.getErrors()) {
                                LOGGER.error('Unable to update the account record : Error : ' + err.getMessage());
                            }
                        }
                    }
                }else{
                   LOGGER.error('user '+UserInfo.getName()+' does not have sufficient permissions to update Accounts');
                }
            }
            catch (DmlException e){
                LOGGER.fatal('Unable to perform the update for the accounts : ' + e.getMessage());
            }
        }
    }

}