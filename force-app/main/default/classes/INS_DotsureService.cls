/**
* @description : Service class handling Dotsure Lead Sync API
* @author Raja Arsalan
* @group Insurance
* @last modified on 2026-09-11
* 
* Modifications Log
* Date         Author          Modification
* 2026-09-11   Raja Arsalan    Token parameter added - token reused across batch
*                              Exception rethrown for batch error tracking
**/
public without sharing class INS_DotsureService {
    
    
    public static String mockScenario;
    public static String testLeadId;
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_DotsureService');
    
    /**
* @description Syncs a single Lead to Dotsure
* @param leadRecord Lead record to sync
* @param accessToken OAuth access token (cached at batch level)
**/
 public static void syncLeadToDotsure(
    Lead leadRecord, 
    String accessToken, 
    INS_Insurance_Lead_Settings__mdt settings
) {
    try {
        String jsonPayload = INS_DTO_DotsureLead.buildJsonPayload(leadRecord, settings);
        LOGGER.debug('Dotsure payload: ' + jsonPayload);
        
        INS_Leads_API apiCall = new INS_Leads_API(jsonPayload, accessToken, 'POST');
        //apiCall.setChannelId(String.valueOf(settings.INS_TargetSystemCode__c));
        apiCall.setChannelId('109');

        CMN_WebserviceCallQueue__c queue = 
            CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_Leads_API.SERVICE_NAME);
        apiCall.process(queue);
        
        INS_SRV_DotsureLeadResponse.ResponseResult result =
            INS_SRV_DotsureLeadResponse.parse(
                apiCall.getResponseStatusCode(),
                apiCall.getResponseBody()
            );
        

        if (result.status == INS_SRV_DotsureLeadResponse.ResponseStatus.SUCCESS) {
            
            // SUCCESS — Reference number store karo
            leadRecord.Referred_System_Reference_Number__c = result.leadReferenceNumber;
            leadRecord.Dialer_Failure_Reason__c = null;  // Clear old error
            leadRecord.Lead_Closing_Comment__c = null;   // Clear old comment
            
            LOGGER.info('Dotsure sync SUCCESS for Lead: ' + leadRecord.Id 
                + ' | Ref: ' + result.leadReferenceNumber);
            
        } else if (result.status == INS_SRV_DotsureLeadResponse.ResponseStatus.CLIENT_ERROR) {
            
            // CLIENT ERROR (400/401/403) — Failure store karo
            leadRecord.Dialer_Failure_Reason__c = result.failureMessage;
            leadRecord.Lead_Closing_Comment__c = result.failureMessage;
            leadRecord.Referred_System_Reference_Number__c = 'Dotsure Failed';
            
            LOGGER.warn('Dotsure sync CLIENT_ERROR for Lead: ' + leadRecord.Id 
                + ' | HTTP: ' + result.httpStatusCode 
                + ' | Error: ' + result.failureMessage);
            
        } else if (result.status == INS_SRV_DotsureLeadResponse.ResponseStatus.SERVER_ERROR) {
            
            // SERVER ERROR (5xx) — Pending mark karo
            leadRecord.Dialer_Failure_Reason__c = result.failureMessage;
            leadRecord.Referred_System_Reference_Number__c = 'Dotsure Pending';
            
            LOGGER.warn('Dotsure sync SERVER_ERROR for Lead: ' + leadRecord.Id 
                + ' | HTTP: ' + result.httpStatusCode 
                + ' | Error: ' + result.failureMessage);
            
        } else {
            

            String unknownError = String.isNotBlank(result.failureMessage) 
                ? result.failureMessage 
                : 'Unknown response from Dotsure';
            
            leadRecord.Dialer_Failure_Reason__c = unknownError;
            leadRecord.Referred_System_Reference_Number__c = 'Dotsure Failed';
            
            LOGGER.error('Dotsure sync UNKNOWN status for Lead: ' + leadRecord.Id 
                + ' | HTTP: ' + result.httpStatusCode 
                + ' | Error: ' + unknownError);
        }
        
        // UoW commit
        sbgplatform.fflib_SObjectUnitOfWork uow =
            new sbgplatform.fflib_SObjectUnitOfWork(
                new List<SObjectType>{Lead.SObjectType},
                new INS_UTIL_SystemModeDML()
            );
        
        uow.registerDirty(leadRecord);
        uow.commitWork();
        
    } catch (Exception e) {
        LOGGER.error('INS_DotsureService Exception: ' + e.getMessage() 
            + ' | ' + e.getStackTraceString());
        throw e;
    }
}
}