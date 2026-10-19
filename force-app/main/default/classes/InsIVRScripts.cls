/**
* @author            : Ihtishaam Mohammoodally
* @description       : Class to launch a flow for creation of records when inbound call is recieved by the agent[SFP-32781]
* @date 			 : 22-07-2024
* @testclass 		 : InsIVRScriptsTest
* @Last Modified On  : 22-07-2024
**/
global with sharing class InsIVRScripts implements omnistudio.VlocityOpenInterface{
    
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('InsIVRScripts');
       
    
/**
* @purpose       : Method to be invoke by omniscript to create engagement record.
* @parameter     : methodName,inputMap,outMap,options
* @return        : isSuccess 
**/    
    public static Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean isSuccess = true;
        try{
            if('runFlow'.equals(methodName)){
                outMap = runFlow((String)inputMap.get('recordId'),(String)inputMap.get('amazonConnectContactId'),outMap);
            }   
        }
        catch(Exception ex){
            isSuccess = false;
            logger.error('InsIVRScripts : invokeMethod : Unhandled Exception '+ ex.getMessage() + ' Line Exception '+ ex.getLineNumber() + ' Stack trace: ' + ex.getStackTraceString());
        }        
        return isSuccess;	 
    }
    
/**
* @purpose       : To run an autolaunchflow to create engagement records
* @parameter     : recordId,amazonConnectContactId
* @return     : outMap
**/
   public static Map<String, Object> runFlow(String recordId,String amazonConnectContactId,Map<String, Object> outMap){
        if(String.isNotBlank(recordId)){
            
            Map<String, Object> params = new Map<String, Object>();
            params.put('RecordId', recordId);
            params.put('AmazonConnectContactId',amazonConnectContactId);             
            Flow.Interview.Ins_CreateEngagementInteraction_Topic  insuranceEngagementRecords = new Flow.Interview.Ins_CreateEngagementInteraction_Topic(params);
            insuranceEngagementRecords.start();
            outMap.put('EngagementInteractionId',(Object)insuranceEngagementRecords.getVariableValue('EngagementInteractionId'));
            outMap.put('EngagementAttendeeId',(Object)insuranceEngagementRecords.getVariableValue('EngagementAttendeeId'));
        }
        return outMap;
    }
}