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

@RestResource(UrlMapping='/CrossOrgInBoundContDoc/*')
global with sharing class SVC_API_CrossOrgInBoundContDoc {
    
    /**
     * @description POST processing to validate the input, create the case and return the new values
     *
     **/
    @HttpPost
    global static void doPost(){
        RestResponse response = RestContext.response;
        Savepoint operationSavePoint = Database.setSavepoint();

        try{
            String dtoRequestAsString = RestContext.request.requestBody.toString();
            SVC_DTO_CrossOrgCaseContDocDestOrgRequest dtoRequest = (SVC_DTO_CrossOrgCaseContDocDestOrgRequest) JSON.deserialize(dtoRequestAsString, SVC_DTO_CrossOrgCaseContDocDestOrgRequest.class); 

            SVC_DTO_CrossOrgCaseContDocDestOrgResponse dtoResponse = SVC_UTIL_CrossOrg.createNewContDoc(dtoRequest);
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
    global class SVC_DTO_CrossOrgCaseContDocDestOrgRequest
    {
        global String namedCredential;
        global String destinationCaseId;
        global String linkedEntityId;
        global String contentDocumentId;
        global String shareType;
        global String visibility;
        global String title;
        global String pathOnClient;
        global String versionNumber;
        }

    /**
     * @description DTO to represent the structure of the response
     */
    global class SVC_DTO_CrossOrgCaseContDocDestOrgResponse
    {
        public Integer responseCode;
        public String message;

    }
}