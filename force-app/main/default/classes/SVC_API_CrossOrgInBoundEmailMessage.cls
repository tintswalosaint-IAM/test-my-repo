/**
 * @description API and DTO to facilitate the integration between Salesforce instances using named credentials, this
 * class handles inbound call to create and service the case
 *
 * @see SVC_API_CrossOrgEmail_Test
 *
 * @author Angola Team
 *
 * @date September 2022
 *
 */

@RestResource(UrlMapping='/CrossOrgInBoundEmailMessage/*')
global with sharing class SVC_API_CrossOrgInBoundEmailMessage {
    
    /**
     * @description POST processing to validate the input, create the case and return the new values
     *
     **/
    @HttpPost
    global static void doPostEmailMessage(){
        RestResponse response = RestContext.response;
        Savepoint operationSavePoint = Database.setSavepoint();

        try{
            String dtoRequestAsString = RestContext.request.requestBody.toString();
            SVC_DTO_CrossOrgSelectCaseonDestOrgRequest dtoRequest = (SVC_DTO_CrossOrgSelectCaseonDestOrgRequest) JSON.deserialize(dtoRequestAsString, SVC_DTO_CrossOrgSelectCaseonDestOrgRequest.class); 

            SVC_DTO_CrossOrgSelectCaseonDestOrgResponse dtoResponse = SVC_UTIL_CrossOrg.createNewEmailMessage(dtoRequest);
            response.responseBody = Blob.valueOf(JSON.serialize(dtoResponse));

            }
            catch(Exception e){
                response.responseBody = Blob.valueOf(JSON.serialize(new errorMessageWrapperClass(SVC_UTIL_CrossOrg.ERROR_UNKNOWN, e.getMessage())));
                response.statusCode = SVC_UTIL_CrossOrg.STATUS_CODE_400;
                Database.rollback(operationSavePoint);
            }
    }

    /**
     * @description Wrapper class for Error response
     */
    global class ErrorMessageWrapperClass
    {
        public String errorType { get; set; }
        public String errorMessage { get; set; }

        public ErrorMessageWrapperClass(String errorType, String errorMessage)
        {
            this.errorType = errorType;
            this.errorMessage = errorMessage ;
        }
    }

    /**
     * @description DTO to represent the structure of the request
     */
    global class SVC_DTO_CrossOrgSelectCaseonDestOrgRequest
    {
        global String namedCredential;
        global String destinationCaseId;
        global String fromAddress;
        global String toAddress;
        global String fromName;
        global String subject;
        global String headers;
        global String htmlBody;
        global String textBody;
        global Boolean isBounced;
    }

    /**
     * @description DTO to represent the structure of the response
     */
    global class SVC_DTO_CrossOrgSelectCaseonDestOrgResponse
    {
         public Integer responseCode;
         public String message;
    }
}