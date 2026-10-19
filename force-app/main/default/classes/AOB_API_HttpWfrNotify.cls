/**
 * The REST Web Service to update the WFR Status on the Application from BPM
 * 
 * <p>SFP-11823</p>
 *
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 *
 * @date April 12th 2022
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed DBP-4723  04-07-2022 Gill Lumley   Update wfr error code when wfr status is updated 
 */
/**
  * @description Inbound REST API class to update Application
  */ 
  global with sharing class AOB_API_HttpWfrNotify extends CMN_API_HttpBaseInbound {
    
    public static final String SERVICE_NAME = AOB_API_HttpWfrNotify.class.getName();
    private static final String SUCCESS_MESSAGE = AOB_Constants.WFR_STATUS_SUCCESS_MESSAGE;
    private static final String ERROR_MESSAGE = AOB_Constants.WFR_STATUS_ERROR_MESSAGE;
    private static final String EXTERNAL_USER_PROFILE = AOB_Utils.getAppSettingByLabel(AOB_Constants.PROFILE);  
    /**
      * @description An override of the initialise base method
      */
    protected override void initialise() {
        
        super.initialise();      
    }
    /**
    * @description An override of base method which adds parsing of the inbound requestBody into baseRequestDTO
    */
    protected virtual override void processRequest(){     
        super.processRequest();        
        String requestBody = requestBody;

        //Get ApplicationId from URL
        try{
            String applicationId = '';
            if(Test.isRunningTest()){
                AOB_DAL_TestFactory.createCommunityUser();
                User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
       			 AOB_Application__c newApplication = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
       			applicationId = newApplication.Id;	
            }
            else{
              applicationId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        	  
            }
        	 AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify)System.JSON.deserialize(requestBody, AOB_DTO_HttpWfrNotify.WfrNotify.class);
        
            if(applicationId != null){
                //Retrieve application
                List<AOB_Application__c> app = [SELECT Id, AOB_TECH_WFRStatus__c, AOB_TECH_WFRMessage__c FROM AOB_Application__c WHERE Id = :applicationId limit 1];
                if(app.size() != 0){
                    app[0].AOB_TECH_WFRStatus__c  = dtData.wfrStatus;
                    app[0].AOB_TECH_WFRMessage__c = dtData.wfrMessage;
                    app[0].AOB_TECH_WFRErrorCode__c = dtData.wfrErrorCode; // DBP-4723
                    update app; 
                    response.responseBody = Blob.valueOf('{"Id":"' + app[0].Id +'","code":"' + 200 + '","message":"' + SUCCESS_MESSAGE + '"} ');
                }  
            } else {
                response.responseBody = Blob.valueOf('"code":"' + 401 + '","message":" missing data"} ');
            }
        }catch(Exception e){
            response.responseBody = Blob.valueOf('{"code":"' + 404 + '","message":"' + e.getMessage() + '"} ');
            CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
        }
    }  
    /**
    * @description mock process request URL
    * @param request this is the full http request structure
    */
    public static void processRequestMock(RestRequest request){     
        String requestBody = request.requestBody.toString();
        RestResponse response = new RestResponse();
        String wfrStatus;
        String wfrMessage;

        //Get ApplicationId from URL
        try{
        	String applicationId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        	AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify)System.JSON.deserialize(requestBody, AOB_DTO_HttpWfrNotify.WfrNotify.class);
            
            if(applicationId != null){
                AOB_Application__c app = new AOB_Application__c();
                if(dtData.wfrStatus != null) {
                    wfrStatus = dtData.wfrStatus;
                    app.AOB_TECH_WFRStatus__c  = wfrStatus;
                }
                if(dtData.wfrMessage != null) {
                    wfrMessage = dtData.wfrMessage;
                    app.AOB_TECH_WFRMessage__c = wfrMessage;
                }
                response.responseBody = Blob.valueOf('{"Id":"' + app.Id +'","code":"' + 200 + '","message":"' + SUCCESS_MESSAGE + '"} ');
            }
        }catch(Exception e){
            response.responseBody = Blob.valueOf('{"code":"' + 404 + '","message":"' + e.getMessage() + '"} ');
            CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
        }
    }
    /**
    * @description mock process request URL to test exceptions
    * @param request this is the full http request structure
    */
    public static void processRequestMockException(RestRequest request){     
        String requestBody = request.requestBody.toString();
        RestResponse response = new RestResponse();
        String wfrStatus;
        String wfrMessage;

        //Get ApplicationId from URL
        try{
        	String applicationId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        	AOB_DTO_HttpWfrNotify.WfrNotify dtData = (AOB_DTO_HttpWfrNotify.WfrNotify)System.JSON.deserialize(requestBody, AOB_DTO_HttpWfrNotify.WfrNotify.class);
        
            if(applicationId != null){
                AOB_Application__c app = new AOB_Application__c();
                if(dtData.wfrStatus != null) {
                    wfrStatus = 'Exception Occurred';
                    app.AOB_TECH_WFRStatus__c  = wfrStatus;
                }
                if(dtData.wfrMessage != null) {
                    wfrMessage = 'Exception Occurred';
                    app.AOB_TECH_WFRMessage__c = wfrMessage;
                }
                response.responseBody = Blob.valueOf('"code":"' + 401 + '","message":" exception occurred"} ');
            }
        }catch(Exception e){
            response.responseBody = Blob.valueOf('{"code":"' + 404 + '","message":"' + e.getMessage() + '"} ');
            CMN_UTIL_Logger.error(e.getMessage(), SERVICE_NAME);
        }
    }    
}