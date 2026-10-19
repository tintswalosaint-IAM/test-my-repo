/**
* @Name of the Class : ICS_CTRL_GBG
* @description Contoller used for SBO UK GBG Feature  - SFP-37310
* @author IKYATHA NAIDU
* @date 11/01/2024
* @last modified on  : 01/07/2024
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-37310 changes done in token generation method for ICS_CTRL_GBG for SBO-UK
*
* @last modified on: 10-06-2025
 * @last modified by: Ridhima Saxena
 * @Modification Description: Updated callPOAVerification method
 * Story: SFP-50149 
*
*/
public with sharing class ICS_CTRL_GBG {
    
/**
 * This line declares a private static final logger instance named LOGGER using the sbgplatform.rflib_Logger class.
 * It initializes the logger by invoking the createLogger method of sbgplatform.rflib_LoggerUtil.getFactory() with the identifier 'ICS_CTRL_GBG'.
 * LOGGER is utilized throughout the codebase to handle and log messages specific to the 'ICS_CTRL_GBG' component or functionality.
 */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GBG');

    /**
    * @description gets a base 64 encoded  QR code will be returned on to UI
    * @param accId - accountID
    * @return string
    */
    @AuraEnabled
    Public static string callGBGToken(string accId) {
         string responsebody='';
        try{
            ICS_API_GenerateTokenGBG customerServiceCall = new ICS_API_GenerateTokenGBG();
            customerServiceCall.accountId = accId;
        	customerServiceCall.getQRInfo = true;
             if (Schema.sObjectType.CMN_WebserviceCallQueue__c.isAccessible() ){
             CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateTokenGBG.SERVICE_NAME,accId);
            customerServiceCall.process(obj);
                 if(Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable()){
            		insert obj; 
                 }
             }
            ics_customlabel__mdt labelData = getLandingPageJSON(ICS_Constants.ics_gbg);
            if(labelData.Description__c == null){
                return null;
            }
            else
            {
                Map<string,string> labelInfo =(Map<string,string>)json.deserialize(labelData.Description__c,map<string,string>.class);
                responsebody=customerServiceCall.serviceResponseInfo();
                map<string,object> qrResponse = new Map<string,object>();
                qrResponse =  (map<string,object> )json.deserializeuntyped(responsebody);
                if(labelInfo.containskey(ICS_Constants.ics_serverSentUrl)){
                    qrResponse.put('serverSentUrl',(object)labelInfo.get(ICS_Constants.ics_serverSentUrl));
                }
                 responsebody = json.serialize(qrResponse);
            }

        }catch(exception exc){
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getmessage());
        }
        return responsebody;
    }
     /**
    * @description fetch Constant Label Information based on DeveloperName
    * @param developerName - which receives conversion JSON Map  from account Screen
    * @return ics_customlabel__mdt
    */
    @testvisible @AuraEnabled(cacheable=true)
    public static ics_customlabel__mdt  getLandingPageJSON(String developerName) {
        if (Schema.sObjectType.ics_customlabel__mdt.isAccessible() ){
            ics_customlabel__mdt icsMetadata;
            try{
                icsMetadata = [SELECT DeveloperName,Description__c FROM ics_customlabel__mdt
                                                Where DeveloperName=:developerName];
            }catch(exception exc){
                LOGGER.error(exc.getmessage());
                throw new AuraHandledException(exc.getmessage());
            }
             return icsMetadata;
        }
        return null;
    }
     /**
    * @description fetches logged in user AccountID
    *
    * @return string
    */
    @AuraEnabled
    public static String getAccountId(){
        String userId = UserInfo.getUserId();
        String responseString='';
        try{
            if (Schema.sObjectType.User.isAccessible() ){
                List<User> users = [Select Id, Contact.AccountId from User where Id = :userId];
                if(users.size() == 0){
                    return responseString;
                }
                else {
                    if( users[0].Contact.AccountId != null){
                    responseString =  users[0].Contact.AccountId;
                    }
                 }
             }
         }catch(exception exc){
            LOGGER.error(exc.getmessage(),'Error Occured in fetching accountID');
            throw new AuraHandledException(exc.getmessage());
        }
        return responseString;
    }
    /**
    * @description fetches token Info
    *
    * @return string
    */
    @AuraEnabled
    Public static string returnGBGToken(){ 
        string accountId='';
            accountId =  getAccountId();
            ICS_API_GenerateTokenGBG customerServiceCall = new ICS_API_GenerateTokenGBG();
        	customerServiceCall.accountId = accountId;
        	customerServiceCall.getQRInfo = false;
        try{
            if (Schema.sObjectType.CMN_WebserviceCallQueue__c.isAccessible() ){
                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GenerateTokenGBG.SERVICE_NAME,accountId);
                customerServiceCall.process(obj);
                if(!test.isrunningtest() && Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable() ) {
                    insert obj;
                }
            }
        }catch(exception exc) {
            LOGGER.error(exc.getmessage(),'Error occured in calling of GBG Token API: method(returnGBGToken)');
            throw new AuraHandledException(exc.getmessage());
        }
         string responsebody= customerServiceCall.serviceResponseInfo();
        return responsebody;
    }
    /**
    * @description calls GBG addres Verification
    *
    * @return string
    */
    @AuraEnabled
    Public static string callPOAVerification(string parentId){

         SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData =selectorPartyProfile.selectByAccountAndRecordType(parentId,ICs_Constants.SBO_RECNAME);
        String returnResponse='';
        try{
             String status = '200';
             SEL_WebserviceCallQueue selectorQueue = new SEL_WebserviceCallQueue();
            List<CMN_WebserviceCallQueue__c> existingCalls = selectorQueue.selectbyServiceUserandStatus(status,
                ICS_API_GBGPOAVerification.SERVICE_NAME, 
                UserInfo.getUserId()
            );
        if (existingCalls.isEmpty()) {
            ICS_API_GBGPOAVerification customerServiceCall = new ICS_API_GBGPOAVerification(profileData.id);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GBGPOAVerification.SERVICE_NAME,profileData.id);
            customerServiceCall.process(obj);
             insert obj;
        }
         }catch(exception exc){
             LOGGER.error(exc.getmessage(),'Error occured in calling of GBG Token API: method(callPOAVerification)');
              throw new AuraHandledException(exc.getmessage());
         }
        return returnResponse;
    }

}