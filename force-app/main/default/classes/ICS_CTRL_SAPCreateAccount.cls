/***************************************************************************************
@Name of the Class :ICS_CTRL_SAPCreateAccount
@Description : Class used to create account for sap
@Author : Mahesh
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Mahesh
* Last Modified Date Oct 22 2024
* Last Modified Description: Initital Version
****************************************************************************************
* @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account
***************************************************************************************/
public without sharing class ICS_CTRL_SAPCreateAccount implements Queueable, Database.AllowsCallouts {
    public String accountId;
    Public boolean isJoint;
    Public static string currencyCode;
    Public List<string>productCodesList;
    Public static boolean updateInitial =false;
    Public static string accName;
    Public List<FinServ__FinancialAccount__c> upsertList;
    public ICS_CTRL_SAPCreateAccount(String accId,boolean isJointInfo,List<string>productCodes) {
        this.accountId = accId;
        isJoint = isJointInfo;
        updateInitial = false; 
        upsertList =  new List<FinServ__FinancialAccount__c>();
        productCodesList = productCodes;
    }

    public void execute(QueueableContext context) {
        List<CMN_WebserviceCallQueue__c> serviceList =  new List<CMN_WebserviceCallQueue__c>();
        for(string pCode: productCodesList ) {
            try{
               CMN_WebserviceCallQueue__c webServiceObj=(CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateAccount',pCode,accountID,isJoint);
                serviceList.add(webServiceObj);
                FinServ__FinancialAccount__c finAcc  = processAndUpdateAccount(webServiceObj.CMN_Response__c,accountId,pCode);
                if(finAcc != null){
                     upsertList.add(finAcc);
                }
               
            }Catch(exception ex){
                ICS_API_SAPCreateAccount SAPCreateAccount = new ICS_API_SAPCreateAccount(accountId,currencyCode);
                String request = SAPCreateAccount.jsonRequest;
                CMN_WebserviceCallQueue__c obj = ICS_SRV_WebserviceQueue.createWebserviceQueue('ICS_API_SAPCreateAccount',false,request,ex.getMessage(),accountId);
                serviceList.add(obj);
            }
        }
        if(serviceList.size()>0){
            insert serviceList;
        }
        if(upsertList.size()>0){
            upsert upsertList;
        }
    }
    public static FinServ__FinancialAccount__c processAndUpdateAccount(String jsonResponse, Id accountId,string pCode) {
        // Parse the JSON response
       Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResponse);
        List<Object> accountList = (List<Object>)responseMap.get('Account');
        Map<String, Object> account = (Map<String, Object>)accountList[0];        
        // Extract status code
        Map<String, Object> additionalData = (Map<String, Object>)account.get('AdditionalData');
        Map<String, Object> categoryInfo = (Map<String, Object>)additionalData.get('CategoryInformation');
        List<Object> categories = (List<Object>)categoryInfo.get('Category');
        
        String statusCode;
        // Find the provider status category and extract status code
        for(Object cat : categories) {
            Map<String, Object> category = (Map<String, Object>)cat;
            if(category.get('CategoryItem') == 'providerStatus') {
                List<Object> details = (List<Object>)category.get('CategoryDetails');
                for(Object detail : details) {
                    Map<String, Object> detailMap = (Map<String, Object>)detail;
                    if(detailMap.get('CategoryType') == 'statusCode') {
                        statusCode = (String)detailMap.get('CategoryIdentifierValue');
                        break;
                    }
                }
            }
        }
        
        // Only proceed if status code is 'S'
        if(statusCode == 'S') {
            // Extract account number
            Map<String, Object> accountNumber = (Map<String, Object>)account.get('AccountNumber');
            Map<String, Object> accountIdentification = (Map<String, Object>)accountNumber.get('AccountIdentification');
            Map<String, Object> item = (Map<String, Object>)accountIdentification.get('Item');
            Map<String, Object> accountIdent = (Map<String, Object>)item.get('AccountIdentification');
            Map<String, Object> identifierValue = (Map<String, Object>)accountIdent.get('IdentifierValue');
            String accountNumberValue = (String)identifierValue.get('Value');
            
            try {
               
                // Create and Update Financial Account record
                List<FinServ__FinancialAccount__c> finAccRecordList =[select id,FinServ__PrimaryOwner__c,FinServ__PrimaryOwner__r.ExternalCIFCountry__c,ExternalCIFId__c,FinServ__PrimaryOwner__r.ExternalSystemId__c,FinServ__PrimaryOwner__r.Name from FinServ__FinancialAccount__c where
                                                               FinServ__PrimaryOwner__c =:accountId];
                
                FinServ__FinancialAccount__c finAccRecord =  new FinServ__FinancialAccount__c();
                finAccRecord = finAccRecordList[0];
                finAccRecord.FinServ__FinancialAccountNumber__c = accountNumberValue;
                finAccRecord.FinServ__Status__c = 'Active';
                finAccRecord.FinServ__PrimaryOwner__c = accountId;
                finAccRecord.FinServ__OpenDate__c = date.today();
                finAccRecord.CurrencyIsoCode = pCode;
                finAccRecord.ExternalSystemId__c = finAccRecord.FinServ__PrimaryOwner__r.ExternalSystemId__c;
                finAccRecord.ExternalCIFCountry__c = finAccRecord.FinServ__PrimaryOwner__r.ExternalCIFCountry__c;
                if(finAccRecord.FinServ__PrimaryOwner__r.Name.length()>80){
                        finAccRecord.Name= finAccRecordList[0].FinServ__PrimaryOwner__r.Name.substring(0,80);
                    }else{
                        finAccRecord.Name = finAccRecordList[0].FinServ__PrimaryOwner__r.Name;
                    }
                finAccRecord.ExternalIdentifier__c =finAccRecord.FinServ__PrimaryOwner__r.ExternalCIFCountry__c + finAccRecord.FinServ__PrimaryOwner__r.ExternalSystemId__c + accountNumberValue;
                if(finAccRecordList.size()>0 && updateInitial== false){
                    finAccRecord.Id = finAccRecordList[0].id;
                    
                    updateInitial =true;
                    accName = finAccRecord.Name;
                }else{
                    finAccRecord.ExternalCIFId__c=finAccRecord.ExternalCIFId__c+'_'+pCode;
                    finAccRecord.id=null;
                }
                  
               return finAccRecord;
            } catch(Exception e) {
                 return  null;
            }
        }else{
             return  null;
        }
    }
	
      /**
     * @description Custom exception class for SAP errors
     */
    public class CustomException extends Exception {}
}