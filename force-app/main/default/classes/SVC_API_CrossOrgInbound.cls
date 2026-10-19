/**
 * @description API and DTO to facilitate the integration between Salesforce instances using named credentials, this
 * class handles inbound call to create and service the case
 *
 * @see SVC_DAL_CrossOrg
 *
 * @author Accenture
 *
 * @date July 2022
 *
 */

@RestResource(UrlMapping='/CrossOrgInbound/*')
global with sharing class SVC_API_CrossOrgInbound
{

    /**
     * @description POST processing to validate the input, create the case and return the new values
     *
     **/
    @HttpPost
    global static void doPost()
    {
        RestResponse response = RestContext.response;
        Savepoint operationSavePoint = Database.setSavepoint();
        try
        {
            String dtoRequestAsString = RestContext.request.requestBody.toString();
            SVC_DTO_CrossOrgCaseCreateRequest dtoRequest = (SVC_DTO_CrossOrgCaseCreateRequest) JSON.deserialize(dtoRequestAsString, SVC_DTO_CrossOrgCaseCreateRequest.class);

            DTO_Response dtoResponse = SVC_UTIL_CrossOrg.createNewCase(dtoRequest);
            response.responseBody = Blob.valueOf(JSON.serialize(dtoResponse));
        }
        catch (Exception e)
        {
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
    global class SVC_DTO_CrossOrgCaseCreateRequest
    {
        public String sourceCaseId;
        public String sourceCaseNumber;
        public String caseSubject;
        public String caseDescription;
        global String caseSource;
        public String destinationTeam;
        public String federationId;
        public String namedCredential;
        public String amazonConnectContactId;
        public String recordTypeName;
        public String svcExternalCifCountry;
        global String webEmail;
        global String webName;
        global String webPhone;
    }

    /**
     * @description DTO to represent the structure of the response
     */
    public class DTO_Response
    {
        public String caseId;
        public String caseNumber;
        public Integer responseCode;
        public String message;

        public DTO_Response()
        {
            this.caseId = caseId;
            this.caseNumber = caseNumber;
            this.message = message;
            this.responseCode = responseCode;
        }
    }
}