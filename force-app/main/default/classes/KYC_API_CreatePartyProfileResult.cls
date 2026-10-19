/**
* @description  
*  
* @author Nagendra Mylavarapu
* 
* @date Jan 12 2024
* Last Modified By  Nagendra Mylavarapu
* Last Modified Date 23/04/2024
*/ 

  public without sharing class KYC_API_CreatePartyProfileResult extends CMN_API_HttpBaseInbound {
    
    // Stores the class name of KYC_API_CreatePartyProfileResult
    public static final String SERVICE_NAME = KYC_API_CreatePartyProfileResult.class.getName();

    // store ResponseInfo
    string responseInfo='';

    //defined  to initialize and use instance of class
    KYC_API_CreatePartyProfileResultHandler handler = new KYC_API_CreatePartyProfileResultHandler();

    /**
      * @description An override of the initialise base method
      */
    protected override void initialise() {
        super.initialise();      
    }

    /**
    * @description An override of base method which adds parsing of the inbound requestBody into baseRequestDTO
    */
    protected virtual override void processRequest() {     
        super.processRequest();        
       
		  responseInfo = handler.responseCall(requestBody);
        response.responseBody = blob.valueof(responseInfo);
    }  
   
}