/**
* @description SFP-32986 Class used to process ID and Address request from   Rely comply 
*  
* @author IKYATHA NAIDU,Swapnil Walse
* 
* @date 23/04/2024
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Modification Description :Updated to latest version
*/ 

  public with sharing class ICS_API_GBGIDPOAVerifyProcessResult extends CMN_API_HttpBaseInbound {
    
    // Stores the class name of ICS_API_GBGIDPOAVerifyProcessResult
    public static final String SERVICE_NAME = ICS_API_GBGIDPOAVerifyProcessResult.class.getName();

    // store ResponseInfo
    string responseInfo='';

    //defined  to initialize and use instance of class
    ICS_API_GBGIDPOAProcessResultHandler handler = new ICS_API_GBGIDPOAProcessResultHandler();

    /**
      * @description An override of the initialise base method
      */
    protected override void initialise() {
        super.initialise();      
    }

    /**
    * @description An override of base method which adds parsing of the inbound requestBody into baseRequestDTO
    */
      @testvisible
    protected virtual override void processRequest() {     
        super.processRequest();        
       
         responseInfo = handler.responseCall(requestBody,SERVICE_NAME);
        response.responseBody = blob.valueof(responseInfo);
    }  
   
}