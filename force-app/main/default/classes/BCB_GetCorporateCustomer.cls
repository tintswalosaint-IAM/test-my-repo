/**
* @description Dealing with a customer customer list, when we are making the callout after dml getting error to resolve this wrote an queueable class.
* @author Lokesh 
* @date June 2023
* Story Number :SFP-27033
*/


public class BCB_GetCorporateCustomer implements Queueable ,Database.AllowsCallouts{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_GetCorporateCustomer');

    /**
* @description applicationParticipant
*/
    public Application_Participant__c applicationParticipant;
    /**
* @description applicationsRecord
*/
    public Application__c applicationsRecord;
    
    /**
* @description BCB_GetCorporateCustomer
* @param applicationParticipantRecord
* @param applicationRecord

*/
    public BCB_GetCorporateCustomer(Application_Participant__c applicationParticipantRecord,Application__c applicationRecord) {
        this.applicationParticipant = applicationParticipantRecord;
        this.applicationsRecord = applicationRecord;
    }
    /** 
* @description This method used to excute Queueable context 
* @param context
*/
    public void execute(QueueableContext context){
        string corporateCustomerlist;
        try {
            List<Application__c> appliactionRecords = new List<Application__c>();
            appliactionRecords.add(applicationsRecord);
            
            corporateCustomerlist = CMN_GetCorporateCustomerList.invocableMethod(appliactionRecords,applicationParticipant);
            System.debug('corporateCustomerlist '+corporateCustomerlist);
            if(corporateCustomerlist != null && corporateCustomerlist != ''){
                Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(corporateCustomerlist);
                
                if(parsedStringMap != null && parsedStringMap.containsKey('status') == true && parsedStringMap.containsKey('uuId')) {
                    appliactionRecords[0].AOB_Customer_Id__c = (String) parsedStringMap.get('uuId');
                    appliactionRecords[0].AOB_UG_BCB_Stage__c = 'CIF';
                  
                    BCB_FlowController.createVerificationRecord(applicationsRecord, 'CIF', 'Success');
                    BCB_FlowController.assignLeadToQueue(applicationsRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');
                }else if(parsedStringMap.containsKey('ErrorDescription') == true){
                    BCB_FlowController.createVerificationRecord(applicationsRecord, 'Customer Check', 'Failed');
                    BCB_FlowController.assignLeadToQueue(applicationsRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification'); 
                }else if(parsedStringMap.containsKey('status') == true && parsedStringMap.containsKey('uuId') == false){
                    appliactionRecords[0].AOB_Customer_Id__c =  '';   
                    appliactionRecords[0].AOB_UG_BCB_Stage__c = 'CIF';
                    BCB_FlowController.createVerificationRecord(applicationsRecord, 'CIF', 'Success');
                    BCB_FlowController.assignLeadToQueue(applicationsRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification');
                }else{
                    BCB_FlowController.createVerificationRecord(applicationsRecord, 'Customer Check', 'Failed');
                    BCB_FlowController.assignLeadToQueue(applicationsRecord.AOB_Lead__c, 'UG_BCB_Incomplete_Customer_Verification'); 
                }
                
                if(!appliactionRecords.isEmpty()){
                    update appliactionRecords;
                }
                
            }
            
        }catch (Exception ex) {
            LOGGER.error('BCB_GetCorporateCustomer.execute', ex);
            throw new BCB_CustomException(ex.getMessage());
        }
    }
}