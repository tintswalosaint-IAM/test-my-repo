/***************************************************************************************
@ Author            :Lokesh
@ Date              :May 2023
@ Name of the Class :BCB_AlertSubscriptionQueueable
@description       :Class for dealing with BCB_AlertSubscriptionQueueable api and sending the result to the main container and storing the values in the wrapper
@ Story Number      :SFP-26345
@ Last Modified By  : Lokesh
@ Last Modified On  :July 2023
***************************************************************************************/
public  class BCB_AlertSubscriptionQueueable implements Queueable ,Database.AllowsCallouts {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_AlertSubscriptionQueueable');

     /** 
    * @description This method used for invoking  callout
    */
    public List<Application__c> lstOfApplications;
       /** 
    * @description This method used for invoking  callout
    */
    public List<Application_Participant__c> lstOfApplicationParticipants;
     /** 
    * @description This method used for invoking  callout
    * @param applicationList
    * @param participantList
    */
    public BCB_AlertSubscriptionQueueable(List<Application__c> applicationList,List<Application_Participant__c> participantList) {
        this.lstOfApplications = applicationList;
        this.lstOfApplicationParticipants = participantList;
    }
     /** 
    * @description This method used for  processing callout
    * @param context
    */
    public void execute(QueueableContext context){
        try {
            string alertSubscriptionResponse =CMN_CustomerAlertSubscription.invocableMethod(lstOfApplications);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(alertSubscriptionResponse);
            if(responseMap != null && responseMap.containsKey('ErrorDescription') == true){
                BCB_FlowController.createVerificationRecord(lstOfApplications[0], 'Customer Alert Subscription', 'Failed');
                BCB_FlowController.assignLeadToQueue(lstOfApplications[0].AOB_Lead__c, 'UG_BCB_Incomplete_Account_Opened_Queue');
            }else{
                lstOfApplications[0].AOB_UG_BCB_Stage__c = 'Customer Alert Subscription';
                update lstOfApplications;
                BCB_FlowController.createVerificationRecord(lstOfApplications[0], 'Customer Alert Subscription', 'Success');
            }
        }catch (Exception ex) {
            LOGGER.error('BCB_AlertSubscriptionQueueable.execute', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
}