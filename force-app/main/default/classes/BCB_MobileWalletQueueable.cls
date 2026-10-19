/**
* @description  Class for dealing with BCB_MobileWalletQueueable and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* @date june 2023
* Story Number:SFP-26348
*/
public class BCB_MobileWalletQueueable implements Queueable ,Database.AllowsCallouts {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_MobileWalletQueueable');

    /** 
* @description lstOfApplications
*/
    public List<Application__c> lstOfApplications;
    /** 
* @description lstOfApplicationParticipants

*/
    public List<Application_Participant__c> lstOfApplicationParticipants;
    /** 
* @description  This method is used for the list the Application
* @param applicationList
* @param applicationParticipantList

*/
    public BCB_MobileWalletQueueable(List<Application__c> applicationList, List<Application_Participant__c> applicationParticipantList) {
        this.lstOfApplications = applicationList;
        this.lstOfApplicationParticipants  = applicationParticipantList;
    }
    /** 
* @description  This method is used for excute the Queueable 
* @param context
*/
    public void execute(QueueableContext context){
        try {
            String mobileWalletResponse = CMN_MobileWallet.invocableMethod(lstOfApplications,lstOfApplicationParticipants);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(mobileWalletResponse);
            
            if(responseMap != null && responseMap.get('status') == 'Pending') {
                BCB_FlowController.createVerificationRecordForParticipant(lstOfApplicationParticipants[0], 'Mobile Wallet', 'Success');
                if(!Test.isRunningTest()){
                    System.enqueueJob(new BCB_MobileWalletStatusQueueable(lstOfApplications,lstOfApplicationParticipants,JSON.serialize(responseMap)));
                }
            } else {
                BCB_FlowController.createVerificationRecordForParticipant(lstOfApplicationParticipants[0], 'Mobile Wallet', 'Failed');
            } 
        }catch (Exception ex) {
            LOGGER.error('BCB_MobileWalletQueueable.execute', ex);
            throw new BCB_CustomException(ex.getMessage());
        } 
    }
}