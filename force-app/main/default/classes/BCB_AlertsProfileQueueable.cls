/***************************************************************************************
@ Author            :Lokesh
@ Date              :May 2023
@ Name of the Class :BCB_AlertsProfileQueueable
@description       :Class for dealing with BCB_AlertsProfileQueueable api and sending the result to the main container and storing the values in the wrapper
@ Story Number      :SFP-26345
@ Last Modified By  : Lokesh
@ Last Modified On  :July 2023
***************************************************************************************/
public class BCB_AlertsProfileQueueable implements Queueable ,Database.AllowsCallouts {
    /** 
  * @description This method used lstOfApplications
  */
  public List<Application__c> lstOfApplications;
    /** 
  * @description This method used lstOfApplicationParticipants
  */
  public List<Application_Participant__c> lstOfApplicationParticipants;
  /** 
  * @description This method used for invoking  callout
  * @param applicationList
  * @param participantList
  */
  public BCB_AlertsProfileQueueable(List<Application__c> applicationList,List<Application_Participant__c> participantList) {
      this.lstOfApplications = applicationList;
      this.lstOfApplicationParticipants= participantList;
  }
  /** 
  * @description This method used for  processing callout
  * @param context
  */
  public void execute(QueueableContext context){
      string customerAlertProfileResponse  = CMN_CustomerAlertsProfile.invocableMethod(lstOfApplications,lstOfApplicationParticipants);
      Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(customerAlertProfileResponse);

      if(responseMap != null && responseMap.containsKey('ErrorDescription') == true){
          BCB_FlowController.createVerificationRecord(lstOfApplications[0], 'Customer Alert Profile', 'Failed');
          BCB_FlowController.assignLeadToQueue(lstOfApplications[0].AOB_Lead__c, 'UG_BCB_Incomplete_Account_Opened_Queue'); 
      } 
      else{
          BCB_FlowController.createVerificationRecord(lstOfApplications[0], 'Customer Alert Profile', 'Success');
          
          if(!Test.isRunningTest()){
              system.enqueueJob(new BCB_AlertSubscriptionQueueable(lstOfApplications,lstOfApplicationParticipants));
          }
      }        
  }
}