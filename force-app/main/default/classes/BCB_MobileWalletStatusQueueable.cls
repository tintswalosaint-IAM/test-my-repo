/**
* @description  Class for dealing with BCB_MobileWalletStatusQueueable and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* @date june 2023
* Story Number:SFP-26348
*/
public  class BCB_MobileWalletStatusQueueable implements Queueable ,Database.AllowsCallouts{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_MobileWalletStatusQueueable');

    public List<Application__c> lstOfApplications;
    public string mobileWalletResponse;
    List<Application_Participant__c> lstOfParticipants;
    /** 
* @description This method used for excute Queuable
* @param applicationList
* @param mobileWalletRespone
*/
    public BCB_MobileWalletStatusQueueable(List<Application__c> applicationList,List<Application_Participant__c> lstOfApplicationParticipants,String mobileWalletRespone) {
        this.lstOfApplications = applicationList;
        this.mobileWalletResponse = mobileWalletRespone;
        this.lstOfParticipants = lstOfApplicationParticipants;
    }
    /** 
* @description This method used for excute Queuable
* @param context
*/
    public void execute(QueueableContext context){
        try {
            String returnString = CMN_MobileWalletStatus.invocableMethod(lstOfApplications, mobileWalletResponse);
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
            if(parsedStringMap != null &&((string)parsedStringMap.get('status')  != 'FAILED' || (string)parsedStringMap.get('status')  != 'Pending') ) {
                lstOfApplications[0].AOB_UG_BCB_Stage__c = 'Congratulations';
                update lstOfApplications;
                BCB_FlowController.createVerificationRecordForParticipant(lstOfParticipants[0], 'Mobile Wallet Status Check', 'Success');
            }else{
                BCB_FlowController.createVerificationRecordForParticipant(lstOfParticipants[0], 'Mobile Wallet Status Check', 'Failed');
                BCB_FlowController.assignLeadToQueue(lstOfApplications[0].AOB_Lead__c, 'UG_BCB_Unfunded_Accounts_Queue');  
            }
        } catch (Exception ex) {
            LOGGER.error('BCB_MobileWalletStatusQueueable.execute', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
    
}