/**
 * @description Class used to Perform an API call to get History Notes from SAP via ESB Middleware
 * @author Eduardo Salia
 * @date October 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56273
 * @LastModifiedReason: API Code Remediation and Indentation
 */
public with sharing class CMN_API_GetHistoryNotes extends sbgplatform.ApiGatewayService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_API_GetHistoryNotes');
    private static final String NAMED_CREDENTIAL = 'CHNW_PBB_SA_RelationshipManagementN';
    private static final String PATH_GET_NOTES = '/notepad/notes/{0}?note-type=CUSTOMER&categories=ALL&index=1&offset=100';
    private static final String PATH_CREATE_NOTES = '/notepad/notes/';

    public CMN_API_GetHistoryNotes() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description This method performs an API request to ESB
     * @param recordId Id of our Parent record
     * @return CMN_DTO_NoteInformationResponse responseObject
     */
    public CMN_DTO_NoteInformationResponse getLatestClientNotes(Id recordId) {
        Account account = CMN_DAL_Account.findById(recordId);
        String path = String.format(PATH_GET_NOTES, new List<String>{ account.CMN_BPGUID__pc });

        get(path);

        if (getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = getResponseBody();
            if (responseBody != null) {
                return (CMN_DTO_NoteInformationResponse) JSON.deserialize(
                    responseBody,
                    CMN_DTO_NoteInformationResponse.class
                );
            } else {
                LOGGER.error('No response body', (Exception) null);
            }
        } else {
            LOGGER.error('Response status: ' + getStatusCode(), (Exception) null);
        }
        return null;
    }

    /**
     * @description This method performs an API request to ESB
     * @param recordId Id of our Parent record
     * @param noteDetails Details of the History Note on the LWC Component
     * @param noteType Type of the History Note on the LWC Component
     * @return String response
     */
    public String createClientNotes(Id recordId, String noteDetails, String noteType) {
        Account account = CMN_DAL_Account.findById(recordId);
        User user = CMN_DAL_User.getCurrentUser();
        //Prepare Request Data
        CMN_DTO_CreateNoteRequest requestObject = new CMN_DTO_CreateNoteRequest();
        requestObject.comments = noteDetails;
        requestObject.notepadType = 'CUSTOMER';
        requestObject.user = user.EmployeeNumber;
        requestObject.dt = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss');
        requestObject.customer = '{0}';
        String requestBody = JSON.serialize(requestObject);
        requestBody = requestBody.replace('dt', 'date');
        requestBody = requestBody.replace(
            '"{0}"',
            '{"id":"' + account.CMN_BPGUID__pc + '","customerNoteType":"' + noteType + '"}'
        );

        post(PATH_CREATE_NOTES, requestBody);

        if (getStatusCode() == CMN_API_HttpBase.HTTP_CREATED) {
            return String.valueOf(CMN_API_HttpBase.HTTP_CREATED);
        } else {
            LOGGER.error('Response status: ' + getStatusCode(), (Exception) null);
        }
        return null;
    }

    /**
     * @description mocks a response returned from the Get History Notes API
     */
    @testVisible
    private class GetNotesMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody(
                '{\"notes\":[{\"noteDatedOn\":\"2020-12-28T18:24:10\",\"type\":\"APPLICATIONS\",\"noteDetails\":\"TEST\",\"noteCreatedBy\":\"A123456\"}]}'
            );
            return response;
        }
    }

    /**
     * @description mocks a response returned from Create History Notes API
     */
    @testVisible
    private class CreateNotesMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_CREATED);
            return response;
        }
    }
}