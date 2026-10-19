/**
* @description       : Controller to request for KYC Process
* @author            : NAGENDRAPRASAD MYLAVARAPU
* @last modified on  : 02-04-2024
* @last modified by  : Nagendra Mylavarapu
*/

public without sharing   class KYC_API_CreatePartyProfileResultHandler {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('KYC_API_CreatePartyProfileResultHandler');
     private static String failedString = 'Failed';
   

 /**
    * @description Global static method to handle the HTTP POST request for attaching PIV documents.
    * The method parses the incoming JSON request body, processes the documents, and returns a response.
    * @author Nagendra Mylavarapu | 11-03-2024
    * @param cliDetails 
    **/
    
    public  string responseCall(string requestData) {
        // Create an instance of the response DTO to be returned
        KYC_DTO_ClientWrapper.Response dtoResponse = new KYC_DTO_ClientWrapper.Response();
        try {
            // Parse the incoming JSON request body into a strongly typed request object
            KYC_DTO_ClientWrapper requestBody = (KYC_DTO_ClientWrapper) JSON.deserializeStrict(
               requestData, KYC_DTO_ClientWrapper.class
            );
            // Call the method to attach PIV documents and set the response
            dtoResponse = KYC_CTRL_PartyProfile.processKycTest(JSON.serialize(requestBody));
               return json.serialize(dtoResponse);
        } catch (JSONException e) {
            // Handle JSON parsing exceptions
            dtoResponse.status = failedString;
            dtoResponse.responseCode = SVC_UTIL_CrossOrg.STATUS_CODE_400;
            dtoResponse.message = String.valueOf(e); 
              
            // Log the error using a custom logger
            LOGGER.error('KYC_INT_InboundDocumentUpload.attachPIVDocument Exception', new String[] {'KYC_INT_InboundDocumentUpload.attachPIVDocument', dtoResponse.message});
         	return json.serialize(dtoResponse);
        } catch (Exception e) {
            // Handle all other exceptions
            dtoResponse.status = failedString;
            dtoResponse.responseCode = 500;
            dtoResponse.message = String.valueOf(e);
              
            // Log the error using a custom logger
            LOGGER.error('KYC_INT_InboundDocumentUpload.attachPIVDocument Exception', new String[] {'KYC_INT_InboundDocumentUpload.attachPIVDocument', dtoResponse.message});
        	 return json.serialize(dtoResponse);
        } 
            
         
            
            
        
    }
}