/*
 * @description SFP-32986 Class used  to call  webservicecall SAPCreateCYT
 * @author Rukesh
 * @date 21/10/2024
 ***
 * @last modified on  : 21/10/2024
 * @last modified by  : Rukesh
 * @last modified description: updated to align with the latest version of ICS_CTRL_SAPCreateCYT
 * ***************************************************************************************
* @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account
***************************************************************************************
 */
public without sharing class ICS_CTRL_SAPCreateCYT implements Queueable, Database.AllowsCallouts {
   public String accountId;
   public Boolean isJoint;
   public string customerType;
    // Custom exceptions for better error context
    public class SAPCreateCYTException extends Exception {}
    public class QueryException extends Exception {}
    public class CalloutException extends Exception {}
    
    public ICS_CTRL_SAPCreateCYT(String accId, Boolean isJointInfo,string customerTypeInfo) {
        this.accountId = accId;
        this.isJoint = isJointInfo;
        this.customerType=customerTypeInfo;
    }
    
    public void execute(QueueableContext context) {
        try {
            validateInputs();
            List<AccountContactRelation> accountInfoList = queryAccountContactRelation();
            
            if (!accountInfoList.isEmpty() && isJoint) {
                accountId = accountInfoList[0].AccountId;
            }
            makeServiceCallout();
            enqueueNextJob();
        } catch (QueryException e) {
            handleError('Database Query Error', e);
        } catch (CalloutException e) {
            handleError('SAP Service Callout Error', e);
        } catch (Exception e) {
            handleError('Unexpected Error', e);
        }
    }
    
    private void validateInputs() {
        if (String.isBlank(accountId)) {
            throw new SAPCreateCYTException('Account ID cannot be null or empty');
        }
    }
    
    private List<AccountContactRelation> queryAccountContactRelation() {
        try {
            List<AccountContactRelation> accrList = [SELECT Id,AccountId FROM AccountContactRelation WHERE contact.AccountId=: accountId];
            
            return accrList;
        } catch (Exception e) {
            throw new QueryException('Failed to query Financial Accounts: ' + e.getMessage() , e);
        }
    }
    
    private void makeServiceCallout() {
        try {
               CMN_WebserviceCallQueue__c webServiceObj=(CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService('ICS_API_SAPCreateCYT', '', this.accountId, isJoint);
            insert webServiceObj;
        } catch (Exception e) {
            throw new CalloutException('SAP Service callout failed: ' + e.getMessage() , e);
        }
    }
   
    public void enqueueNextJob() {
        if ((customerType == 'Single' && isJoint == false) || (customerType == 'Joint' && isJoint == true)) {            
            SEL_Opportunity oppSelector = new SEL_Opportunity();
            List<Opportunity> oppList = oppSelector.selectByAccountId(accountId);
            SEL_ApplicationFormProduct productSelector = new SEL_ApplicationFormProduct();
            sel_Applicationform appFormSelector = new sel_Applicationform();
            List<Applicationform> appData = appFormSelector.selectByOpportunityId(oppList[0].Id);
            
            if (!appData.isEmpty()) {
                List<ApplicationFormProduct> productList = productSelector.selectByApplicationFormIds(new Set<Id>{appData[0].id});
                // Collect product codes instead of enqueueing multiple jobs
                List<String> productCodes = new List<String>();
                
                for (ApplicationFormProduct formProd : productList) {
                    if (formProd.Product.Productcode != 'Visa' && formProd.Product.Name.contains('Account Currency')) {
                        String productCode = '';
                        if (formProd.Product.Productcode == 'AU Dollar') {
                            productCode = 'AUD';
                        } else if (formProd.Product.Productcode == 'Euro') {
                            productCode = 'EUR';
                        } else if (formProd.Product.Productcode == 'Sterling') {
                            productCode = 'GBP';
                        } else if (formProd.Product.Productcode == 'US Dollar') {
                            productCode = 'USD';
                        }
                        
                        if (String.isNotBlank(productCode)) {
                            productCodes.add(productCode);
                        }
                    }
                    
                }
                // Enqueue just one job that handles all product codes
                if (!productCodes.isEmpty()) {
                    System.enqueueJob(new ICS_CTRL_SAPCreateAccount(accountId, isJoint, productCodes));
                }
            }
        }
    }
    private void handleError(String errorType, Exception e) {
        ICS_API_SAPCreateCYT createRelationCYT = new ICS_API_SAPCreateCYT(accountId,isJoint);
        String request = createRelationCYT.jsonRequest;
        
        CMN_WebserviceCallQueue__c queueRecord = ICS_SRV_WebserviceQueue.createWebserviceQueue(
            'ICS_API_SAPCreateCYT',
            false,
            request,
            errorType + ': ' + e.getMessage(),
            accountId
        );
        insert queueRecord;
    }
}