/***************************************************************************************
@ Author            : Lokesh
@ Date              : June 2023 
@ Name of the Class : BCB_CTRL_CreateApplications
@description        : Dealing with a retail customer list, when we are making the callout after dml getting error to resolve this wrote an queueable class.
@ Last Modified By  : Ravi Myaka  
@ Last Modified On  : 23-04-2024
@ Modification description : SFP-37845
***************************************************************************************/
public class BCB_GetCustomerList implements Queueable ,Database.AllowsCallouts {
      /** 
    * @description This method used applicationParticipant
    */
    public Application_Participant__c applicationParticipant;
      /** 
    * @description This method used applicationsRecord
    */
    public Application__c applicationsRecord;
        /** 
    * @description This method used for invoking  callout
    * @param applicationParticipantRecord
    * @param applicationRecord
    */
    public BCB_GetCustomerList(Application_Participant__c applicationParticipantRecord,Application__c applicationRecord) {
        this.applicationParticipant = applicationParticipantRecord;
        this.applicationsRecord = applicationRecord;
    }  
      /** 
    * @description This method used for  processing callout
    * @param context
    */ 
    public void execute(QueueableContext context){
        List<Application_Participant__c> appliactionParticipants = new List<Application_Participant__c>();
        appliactionParticipants.add(applicationParticipant);

        Map<String, String> preAppInputMap = new Map<String, String>{'firstName'=>appliactionParticipants[0].CNGCU_First_Name__c,'lastName'=>appliactionParticipants[0].CNGCU_Last_Name__c,'dateOfBirth'=>appliactionParticipants[0].AOB_DateofBirth__c.format().replace('/', '-')};
            
        string fetchRetailCustomerResponse = CMN_CustomerList.invocableMethod(preAppInputMap);
        System.debug('fetchRetailCustomerResponse '+fetchRetailCustomerResponse);
            if(fetchRetailCustomerResponse != null || fetchRetailCustomerResponse != ''){
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(fetchRetailCustomerResponse);
                if(responseObject.containsKey('status') == true && responseObject.containsKey('uuId')){
                    string uuIdNumber = String.valueOf(responseObject.get('uuId'));
                    appliactionParticipants[0].AOB_CIFID__c = appliactionParticipants[0].AOB_CIFID__c == null ? uuIdNumber : appliactionParticipants[0].AOB_CIFID__c;   
                    applicationsRecord.AOB_UG_BCB_Stage__c = 'CIF';    
                    BCB_FlowController.createVerificationRecordForParticipant(appliactionParticipants[0], 'CIF', 'Success');
                }else if(responseObject.containsKey('ErrorDescription') == true){
                    BCB_FlowController.createVerificationRecordForParticipant(appliactionParticipants[0], 'Customer Check', 'Failed');
                    BCB_FlowController.assignLeadToQueue(applicationsRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification'); 
                }else if(responseObject.containsKey('status') == true && responseObject.containsKey('uuId') == false){
                    appliactionParticipants[0].AOB_CIFID__c = '';   
                    applicationsRecord.AOB_UG_BCB_Stage__c = 'CIF';
                }else {
                    BCB_FlowController.createVerificationRecordForParticipant(appliactionParticipants[0], 'Customer Check', 'Failed');
                    BCB_FlowController.assignLeadToQueue(applicationsRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification'); 
                }
            }
            if(!appliactionParticipants.isEmpty()){
                update appliactionParticipants;
                update applicationsRecord;
            }
    }
}