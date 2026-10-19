/**
 * @description SFP-32986 Class used to INvoke apex action  .
 * @author Ramya Gurram
 * @date 13/10/2024
 *****************************************************
 * @last modified on  : 13/10/2024
 * @last modified by  : Ramya Gurram
 * @last modified description: updated to latest version
  **************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 19-06-2025
 * @Modification description : SFP-49674
 ***************************************************************************************
 */
public with sharing class ICS_CTRL_InvokeUpdateTIN {
    private ICS_CTRL_InvokeUpdateTIN(){
    }
    
 @future(callout=true)
    public static void processOpportunityFuture(Id accId) {

        // Query for related Application Forms separately
        SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
        List<ApplicationForm> appForms = selectorApplicationForm.selectByAccountId(accId);

        // Collect Account IDs from Application Forms
        Set<Id> accountIds = new Set<Id>();
        for (ApplicationForm appForm : appForms) {
          
            if (appForm.Account.ExternalCIFId__c != null) {
                accountIds.add(appForm.AccountId); 
            }
        }
        // Process each account
       List<CMN_WebserviceCallQueue__c> queueList = new List<CMN_WebserviceCallQueue__c>();
        for(Id accountId : accountIds) {
            ICS_API_UpdateTIN customerServiceCall = new ICS_API_UpdateTIN();
            customerServiceCall.accountId = accountId;
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_UpdateTIN.SERVICE_NAME, accountId);
            customerServiceCall.process(obj);
           
            queueList.add(obj);
        }
        if(!queueList.isEmpty()){
            Insert queueList;
        }
    }
}