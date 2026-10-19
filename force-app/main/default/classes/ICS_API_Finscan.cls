/**
 * @description Finscan API controller
 * @author Gnitsevich Anton
 * Modified by Ofentse Sacha
 * @date May 2024
 */
public with sharing class ICS_API_Finscan { 
       /**
	* @description ICS_API_Finscan constructor
	*/
     private ICS_API_Finscan() {
 
     }
    /**
     * @description logger instance used for logging messages in the ICS_API_Finscan class.
     * created using the sbgplatform.rflib_LoggerUtil factory method.
     */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS Screening - ICS_API_Finscan');
    /**
     * @description holds the name of the ICS Finscan development environment on the Mdt.
     */
    private static final String ICS_FINSCAN_DEV = 'ICS_API_FINSCAN_DEV';
    /**
     * @description holds the name of the ICS Finscan production environment on the Mdt.
     */
    private static final String ICS_FINSCAN_PROD = 'ICS_API_FINSCAN_PROD';
    /**
    * @description  Environment instance for web service settings
    */     
    private static final String ENVIRONMENT = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox ? ICS_FINSCAN_DEV : ICS_FINSCAN_PROD;
    /**
     * @description is the endpoint path for the current wrapper multi-lookup operation.
     */
    private static final String PATH_MULTILOOKUP = '/multi/lookup';
    /**
     * @description is the endpoint path for the current wrapper pairs update operation.
     */
    private static final String PATH_PAIRSUPDATE = '/pairs/update';
    /**
     * @description is the endpoint path for the current wrapper clients update operation.
     */
    private static final String PATH_CLIENTUPDATE = '/clients/update';
    /**
     * @description indicates that the request status is pass (value = 0).
     */
    private static final Integer REQUEST_STATUS_PASS = 0;
    /**
     * @description indicates that the request status is pending (value = 1).
     */
    private static final Integer REQUEST_STATUS_PENDING = 1;
    /**
     * @description indicates that the request status is fail (value = 2).
     */
    private static final Integer REQUEST_STATUS_FAIL = 2;
    /**
     * @description is the bucket name for ONBDG applicants.
     */
    private static final String APPLICANT_BUCKET = 'ONBDG';
    /**
     * @description bucket name for SAPIM applicants in the Isle of Man.
     */
    private static final String ISLEOFMAN_BUCKET = 'SAPIM';
    /**
     * @description SBO recordType name string.
	*/
    private static final String SBO_RECORDTYPE = 'ICS_PartyProfile';
    /**
     * @description Retrieves the CMN_WebserviceSetting__mdt metadata record for the Finscan API, 
     *              using different settings based on whether the environment is a sandbox or production.
     * @return CMN_WebserviceSetting__mdt The metadata record containing the settings for the Finscan API.
     */
    public static CMN_WebserviceSetting__mdt webServiceSetting {
        get {
            if (webServiceSetting == null) {
                webServiceSetting = CMN_WebserviceSetting__mdt.getInstance(ENVIRONMENT);
            }
        return webServiceSetting;
        }
        private set;
    }
    /**
     * @description This method creates a new unique guid value
     * @return String guid
     */
    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
    }
    /**
     * @description This method performs Finscan Lookup callout
     * @param accountId Account Id
     * @return ICS_DTO_FinscanResponse.MultiLookup response data
     */
    public static ICS_DTO_FinscanResponse.MultiLookup doLookup(String accountId) {
        try {
            ICS_SEL_Account accountSelector = new ICS_SEL_Account();
            Account applicantAccount = accountSelector.getAccount(accountId);
            String endpoint = getEndpoint(PATH_MULTILOOKUP);
            List<ICS_DTO_FinscanRequest.Lookup> requestsList = new List<ICS_DTO_FinscanRequest.Lookup>();
            requestsList.add(prepareApplicantRequest(applicantAccount));
            String requestBody = JSON.serialize(requestsList);
            HttpRequest httpRequest = prepareHttpRequest(endpoint, requestBody);
            HttpResponse httpResponse = new Http().send(httpRequest);
            return (ICS_DTO_FinscanResponse.MultiLookup) processHttpResponse(httpResponse, accountId, 'Lookup');
            } catch (Exception ex) {
                logException(accountId, ex, 'Lookup');
                return null;
            }        
    }
    /**
     * @description This method performs Finscan Pairs Update (match outcome information) call
     * @param accountId Account Id
     * @param matchKey Match Key
     * @param outcome Outcome of the party screening step
     * @return ICS_DTO_FinscanResponse.PairsUpdate response data
     */
    public static ICS_DTO_FinscanResponse.PairsUpdate doPairsUpdate(String accountId, Decimal matchKey, PartyScreeningStep outcome) {
        try {
            String endpoint = getEndpoint(PATH_PAIRSUPDATE);
            ICS_DTO_FinscanRequest.PairsUpdate requestApplicant = new ICS_DTO_FinscanRequest.PairsUpdate();
            requestApplicant.applicationId = new List<String>{ APPLICANT_BUCKET };
            requestApplicant.clientId = accountId;
            requestApplicant.pairs = new List<ICS_DTO_FinscanRequest.Pair>();
            ICS_DTO_FinscanRequest.Pair pair = new ICS_DTO_FinscanRequest.Pair();
            pair.listProfileKey = matchKey;
            pair.pairStatus = outcome.Status;
            pair.pairReason = outcome.Reason__c;
            pair.pairComments = outcome.Comments__c;
            requestApplicant.pairs.add(pair);
            String requestBody = JSON.serialize(requestApplicant);
            HttpRequest httpRequest = prepareHttpRequest(endpoint, requestBody);
            HttpResponse httpResponse = new Http().send(httpRequest);
            return (ICS_DTO_FinscanResponse.PairsUpdate) processHttpResponse(httpResponse, accountId, 'Pairs Update');
        } catch (Exception ex) {
            logException(accountId, ex, 'Pairs Update');
            return null;
        }  
    }
    /**
     * @description This method performs Finscan Client Update call
     * @param accountId Account Id
     * @param decision Decision for the client (onboarded or cancelled)
     * @return ICS_DTO_FinscanResponse.ClientUpdate response data
     */
    public static ICS_DTO_FinscanResponse.ClientUpdate doClientUpdate(String accountId, String decision) {     
        try {
            ICS_SEL_Account accountSelector = new ICS_SEL_Account();
            Account clientAccount = accountSelector.getAccount(accountId);
            String endpoint = getEndpoint(PATH_CLIENTUPDATE);
            ICS_DTO_FinscanRequest.ClientUpdate requestApplicant = new ICS_DTO_FinscanRequest.ClientUpdate();
            requestApplicant.applicationId = APPLICANT_BUCKET;
            requestApplicant.clientId = clientAccount.Id;
            requestApplicant.nameLine = clientAccount.FirstName + ' ' + clientAccount.LastName;
            if (decision == 'onboarded') {
                requestApplicant.newApplicationId = ISLEOFMAN_BUCKET;
                requestApplicant.newClientId = clientAccount.AccountNumber;
            } else if (decision == 'cancelled') {
                requestApplicant.clientStatus = 1;
            }
            String requestBody = JSON.serialize(requestApplicant);
            HttpRequest httpRequest = prepareHttpRequest(endpoint, requestBody);
            HttpResponse httpResponse = new Http().send(httpRequest);
            return (ICS_DTO_FinscanResponse.ClientUpdate) processHttpResponse(httpResponse, accountId, 'Client Update');
        } catch (Exception ex) {
            logException(accountId, ex, 'Client Update');
            return null;
        }       
    }
    /**
     * @description Prepares an HTTP request with the given endpoint and request body.
     * @param endpoint The endpoint for the HTTP request.
     * @param requestBody The body of the HTTP request.
     * @return HttpRequest The prepared HTTP request.
     */
    private static HttpRequest prepareHttpRequest(String endpoint, String requestBody) {
        HttpRequest httpRequest = new HttpRequest();
        String fApiInteractionId = createGUID();
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, fApiInteractionId);
        httpRequest.setClientCertificateName('chnw_sbo_uk_onboardingazurec');
        httpRequest.setEndpoint(endpoint);
        httpRequest.setBody(requestBody);
        httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
        httpRequest.setTimeout(120000);
        return httpRequest;
    }
    /**
     * @description Processes the HTTP response and returns the deserialized response object if valid.
     * @param httpResponse The HTTP response to be processed.
     * @param accountId The account ID related to the request.
     * @param requestType The type of the request (for logging purposes).
     * @return The deserialized response object if successful, otherwise null.
     */
    private static Object processHttpResponse(HttpResponse httpResponse, String accountId, String requestType) {
        Integer statusCode = httpResponse.getStatusCode();
        String responseBody = httpResponse.getBody();
        if (statusCode != CMN_API_HttpBase.HTTP_OK || String.isBlank(responseBody)) {
            logError(accountId, statusCode, responseBody, requestType);
            return null;
        }
        Type responseType = getResponseClass(requestType);
        Object responseObject = JSON.deserialize(responseBody, responseType);
        if (responseObject == null || !isValidStatus(getStatus(responseObject))) {
            logError(accountId, statusCode, responseBody, requestType);
            return null;
        }
        setResponseStatusCode(responseObject, statusCode);
        return responseObject;
    }
    /**
     * @description Checks if the status is valid.
     * @param status The status to be checked.
     * @return Boolean indicating if the status is valid.
     */
    private static Boolean isValidStatus(Integer status) {
        return status == REQUEST_STATUS_PASS || status == REQUEST_STATUS_PENDING || status == REQUEST_STATUS_FAIL;
    }
   /**
     * @description Logs an error message with details about the unsuccessful request.
     * @param accountId The account ID related to the request.
     * @param statusCode The HTTP status code received.
     * @param responseBody The body of the HTTP response.
     * @param requestType The type of the request.
     */
    private static void logError(String accountId, Integer statusCode, String responseBody, String requestType) {
        String message = 'Finscan ' + requestType + 'request unsuccessful or response body is empty/incorrect - Account ID: ' + accountId + 'Response Status Code: ' + statusCode + 
            'Response Body: ' + responseBody;
        LOGGER.error(message);
    }
    /**
     * @description Logs an exception that occurred during the HTTP request.
     * @param accountId The account ID related to the request.
     * @param ex The exception that occurred.
     * @param requestType The type of the request.
     */
    private static void logException(String accountId, Exception ex, String requestType) {
        String message = 'Finscan ' + requestType + ' exception - Account ID: ' + accountId + ' Exception Message: ' + ex.getMessage();
        LOGGER.error(message);
    }

    /**
     * @description Retrieves the endpoint based on the path.
     * @param path The path for the endpoint.
     * @return String The endpoint URL.
     */
    private static String getEndpoint(String path) {
        return 'callout:' + webServiceSetting.CMN_NamedCredential__c + path + '?code=' + webServiceSetting.CMN_AdditionalKey__c;
    }
    /**
     * @description Retrieves the response class based on the request type.
     * @param requestType The type of the request.
     * @return Type The class type for deserialization.
     */
    private static Type getResponseClass(String requestType) {
        if (requestType == 'Lookup') {
            return ICS_DTO_FinscanResponse.MultiLookup.class;
        } else if (requestType == 'Pairs Update') {
            return ICS_DTO_FinscanResponse.PairsUpdate.class;
        } else if (requestType == 'Client Update') {
            return ICS_DTO_FinscanResponse.ClientUpdate.class;
        } else {
            return null;
        }
    }
    /**
     * @description Retrieves the status from the response object.
     * @param responseObject The response object.
     * @return Integer The status of the response.
     */
    private static Integer getStatus(Object responseObject) {
        if (responseObject instanceof ICS_DTO_FinscanResponse.MultiLookup) {
            return ((ICS_DTO_FinscanResponse.MultiLookup) responseObject).responses[0].status;
        } else if (responseObject instanceof ICS_DTO_FinscanResponse.PairsUpdate) {
            return ((ICS_DTO_FinscanResponse.PairsUpdate) responseObject).status;
        } else if (responseObject instanceof ICS_DTO_FinscanResponse.ClientUpdate) {
            return ((ICS_DTO_FinscanResponse.ClientUpdate) responseObject).status;
        } else {
            return null;
        }
    }
    /**
     * @description Sets the response status code in the response object.
     * @param responseObject The response object.
     * @param statusCode The status code to be set.
     */
    private static void setResponseStatusCode(Object responseObject, Integer statusCode) {
        if (responseObject instanceof ICS_DTO_FinscanResponse.MultiLookup) {
            ((ICS_DTO_FinscanResponse.MultiLookup) responseObject).responseStatusCode = statusCode;
        } else if (responseObject instanceof ICS_DTO_FinscanResponse.PairsUpdate) {
            ((ICS_DTO_FinscanResponse.PairsUpdate) responseObject).responseStatusCode = statusCode;
        } else if (responseObject instanceof ICS_DTO_FinscanResponse.ClientUpdate) {
            ((ICS_DTO_FinscanResponse.ClientUpdate) responseObject).responseStatusCode = statusCode;
        }
    }
    /**
     * @description This method prepares applicant request data structure
     * @param applicantAccount
     * @return ICS_DTO_FinscanRequest.Lookup request
     */
    private static ICS_DTO_FinscanRequest.Lookup prepareApplicantRequest(Account applicantAccount) {
        ICS_DTO_FinscanRequest.Lookup applicantRequest = new ICS_DTO_FinscanRequest.Lookup();
        SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        PartyProfile applicantParty = partyProfileSelector.selectByAccountAndRecordType(applicantAccount.Id, SBO_RECORDTYPE);
        applicantRequest.applicationId = APPLICANT_BUCKET;
        applicantRequest.clientSearchCode = 0;
        applicantRequest.options = prepareRequestOptions();
        applicantRequest.organizationName = '';
        applicantRequest.userName = '';
        applicantRequest.password = '';
        applicantRequest.clientId = applicantAccount.Id;
        String nameLine = applicantAccount.FirstName;
        if (String.isNotBlank(applicantAccount.MiddleName)) {
            nameLine += ' ' + applicantAccount.MiddleName;
        }
        nameLine += ' ' + applicantAccount.LastName;
        applicantRequest.nameLine = nameLine;
        DateTime birthDatetime = DateTime.newInstance(
            applicantAccount.PersonBirthdate.year(),
            applicantAccount.PersonBirthdate.month(),
            applicantAccount.PersonBirthdate.day()
        );
        applicantRequest.gender = applicantAccount.FinServ__Gender__pc;
        applicantRequest.userField1Label = 'DOB';
        applicantRequest.userField1Value = birthDatetime.format('yyyyMMdd');
        applicantRequest.userFieldsCountry = new List<Integer>();
        if (String.isNotBlank(applicantParty.Country_of_Residence__c)) {
            applicantRequest.userField2Label = 'Country';
            applicantRequest.userField2Value = applicantParty.Country_of_Residence__c;
            applicantRequest.userFieldsCountry.add(2);
        }
        if (String.isNotBlank(applicantParty.Country_of_Nationality__c)) {
            applicantRequest.userField9Label = 'Country';
            applicantRequest.userField9Value = applicantParty.Country_of_Nationality__c;
            applicantRequest.userFieldsCountry.add(9);
        }
        if (String.isNotBlank(applicantParty.Second_Country_of_Nationality__c)) {
            applicantRequest.userField10Label = 'Country';
            applicantRequest.userField10Value = applicantParty.Second_Country_of_Nationality__c;
            applicantRequest.userFieldsCountry.add(10);
        }
        return applicantRequest;
    }
    /**
     * @description This method prepares Finscan request options structure
     * @return ICS_DTO_FinscanRequest.Options request options
     */
    private static ICS_DTO_FinscanRequest.Options prepareRequestOptions() {
        ICS_DTO_FinscanRequest.Options options = new ICS_DTO_FinscanRequest.Options();
        options.addClient = 1;
        options.generateClientId = 0;
        options.updateUserFields = 1;
        options.returnCategory = 1;
        options.returnSearchComplianceRecords = 1;
        options.returnComplianceRecords = 0;
        options.returnSearchDetails = 1;
        options.returnSourceLists = 1;
        options.sendToReview = 1;
        options.skipSearch = 0;
        options.skipClientUpdate = 0;
        options.processUBO = 0;
        options.searchUBOMembers = 0;
        return options;
    }
    /**API Mock Responses
    
    /**
     * @description mocks a pending response returned from the multi/lookup API
     */
    @testVisible
    private class ScreeningPendingMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":1,\"message\":\"Lookup PENDING:\\r\\nINFO: 4 PENDING records found\",\"returned\":2,\"notReturned\":0,\"resultsCount\":2,\"hitCount\":0,\"pendingCount\":2,\"safeCount\":0,\"duplicateCount\":0,\"version\":\"v6.8.1.0 - Released October 6, 2023\",\"responses\":[{\"status\":1,\"message\":\"Lookup PENDING: \\r\\nINFO: 4 PENDING records found\",\"returned\":2,\"notReturned\":0,\"resultsCount\":2,\"hitCount\":0,\"pendingCount\":2,\"safeCount\":0,\"duplicateCount\":0,\"complianceRecords\":[{\"pairStatus\":\"New\",\"pairReason\":\"New\",\"pairComments\":\"\",\"applicationDisplayName\":\"ONBOARDING\",\"applicationId\":\"ONBDG\",\"clientId\":\"0013L00000baSiHQAU\",\"clientKey\":2386394269,\"clientFullName\":\"JOHN JOHNS\",\"listKey\":2000,\"listName\":\"LSEG World-Check\",\"listId\":\"WC\",\"listVersion\":\"20210730\",\"listModifyDate\":\"7.31.2021 11:12:01 PM\",\"listProfileId\":\"1191600\",\"listProfileKey\":1864835,\"linkSingleStringName\":\"JOHN J JOHNS\",\"listParentSingleStringName\":\"JOHN J JOHNS\",\"listCategory\":\"INDIVIDUAL\",\"listPEPCategory\":\"PEP IO\",\"listDOBs\":\"\",\"listCountries\":\"USA;UNITED KINGDOM\",\"rankString\":\"NEBEEEBE\",\"rankScore\":72.22000122070313,\"ranktype\":\"A\",\"rankweight\":\"999\",\"pairLoadDate\":\"10.26.2023 11:01:00 AM\",\"eAddressTo\":\"\",\"eAddressCC\":\"\",\"origin\":\"SEARCH\",\"secondsviewed\":\"0\",\"initialUser\":\"\",\"isPairParentFlag\":1,\"pairMetSearchCriteriaFlag\":1,\"editableDueToAssignmentFlag\":1,\"modifyDate\":\"10.26.2023 11:01:00 AM\",\"modifiedByUser\":\"webservices\",\"pairReportType\":0,\"finscanCategory\":[\"Standard Bank::PEPs-and-Crime\"],\"wrapperStatus\":1,\"sourceLists\":null,\"listRecordDetail\":null,\"listReviewLink\":\"\"},{\"pairStatus\":\"New\",\"pairReason\":\"New\",\"pairComments\":\"\",\"applicationDisplayName\":\"ONBOARDING\",\"applicationId\":\"ONBDG\",\"clientId\":\"0013L00000baSiHQAU\",\"clientKey\":2386394269,\"clientFullName\":\"JOHN JOHNS\",\"listKey\":2000,\"listName\":\"LSEG World-Check\",\"listId\":\"WC\",\"listVersion\":\"20200205\",\"listModifyDate\":\"8.19.2016 3:31:23 PM\",\"listProfileId\":\"1235595\",\"listProfileKey\":1909201,\"linkSingleStringName\":\"BILL JOHNS\",\"listParentSingleStringName\":\"BILL JOHNS\",\"listCategory\":\"INDIVIDUAL\",\"listPEPCategory\":\"PEP N\",\"listDOBs\":\"\",\"listCountries\":\"USA\",\"rankString\":\"E1BEEEBN\",\"rankScore\":73.5999984741211,\"ranktype\":\"A\",\"rankweight\":\"999\",\"pairLoadDate\":\"10.26.2023 11:01:00 AM\",\"eAddressTo\":\"\",\"eAddressCC\":\"\",\"origin\":\"SEARCH\",\"secondsviewed\":\"0\",\"initialUser\":\"\",\"isPairParentFlag\":1,\"pairMetSearchCriteriaFlag\":1,\"editableDueToAssignmentFlag\":1,\"modifyDate\":\"10.26.2023 11:01:00 AM\",\"modifiedByUser\":\"webservices\",\"pairReportType\":0,\"finscanCategory\":[\"Standard Bank::PEPs-and-Crime\"],\"wrapperStatus\":1,\"sourceLists\":null,\"listRecordDetail\":null,\"listReviewLink\":\"\"},{\"pairStatus\":\"New\",\"pairReason\":\"New\",\"pairComments\":\"\",\"applicationDisplayName\":\"ONBOARDING\",\"applicationId\":\"ONBDG\",\"clientId\":\"0013L00000baSiHQAU\",\"clientKey\":2386394269,\"clientFullName\":\"JOHN JOHNS\",\"listKey\":2000,\"listName\":\"LSEG World-Check\",\"listId\":\"WC\",\"listVersion\":\"20230920\",\"listModifyDate\":\"9.22.2023 1:01:36 AM\",\"listProfileId\":\"180684\",\"listProfileKey\":2500683,\"linkSingleStringName\":\"JOHN JOHNS\",\"listParentSingleStringName\":\"JOHN JOHNS\",\"listCategory\":\"INDIVIDUAL\",\"listPEPCategory\":\"PEP N-R\",\"listDOBs\":\"1984-08-17\",\"listCountries\":\"CHINA;ZIMBABWE\",\"rankString\":\"EEEEEE\",\"rankScore\":100.0,\"ranktype\":\"A\",\"rankweight\":\"999\",\"pairLoadDate\":\"10.26.2023 11:01:00 AM\",\"eAddressTo\":\"\",\"eAddressCC\":\"\",\"origin\":\"SEARCH\",\"secondsviewed\":\"0\",\"initialUser\":\"\",\"isPairParentFlag\":1,\"pairMetSearchCriteriaFlag\":1,\"editableDueToAssignmentFlag\":1,\"modifyDate\":\"10.26.2023 11:01:00 AM\",\"modifiedByUser\":\"webservices\",\"pairReportType\":0,\"finscanCategory\":[\"Standard Bank::PEPs-and-Crime\"],\"wrapperStatus\":1,\"sourceLists\":null,\"listRecordDetail\":null,\"listReviewLink\":\"\"},{\"pairStatus\":\"New\",\"pairReason\":\"New\",\"pairComments\":\"\",\"applicationDisplayName\":\"ONBOARDING\",\"applicationId\":\"ONBDG\",\"clientId\":\"0013L00000baSiHQAU\",\"clientKey\":2386394269,\"clientFullName\":\"JOHN JOHNS\",\"listKey\":5023,\"listName\":\"Standard Bank Black List\",\"listId\":\"*STBB\",\"listVersion\":\"20210707\",\"listModifyDate\":\"7.7.2021 7:25:38 PM\",\"listProfileId\":\"SBSA000065\",\"listProfileKey\":13628987,\"linkSingleStringName\":\"JOHN JOHNS\",\"listParentSingleStringName\":\"JOHN JOHNS\",\"listCategory\":\"\",\"listPEPCategory\":\"\",\"listDOBs\":\"\",\"listCountries\":\"\",\"rankString\":\"EEEEEE\",\"rankScore\":100.0,\"ranktype\":\"A\",\"rankweight\":\"999\",\"pairLoadDate\":\"10.26.2023 11:01:00 AM\",\"eAddressTo\":\"\",\"eAddressCC\":\"\",\"origin\":\"SEARCH\",\"secondsviewed\":\"0\",\"initialUser\":\"\",\"isPairParentFlag\":1,\"pairMetSearchCriteriaFlag\":1,\"editableDueToAssignmentFlag\":1,\"modifyDate\":\"10.26.2023 11:01:00 AM\",\"modifiedByUser\":\"webservices\",\"pairReportType\":0,\"finscanCategory\":null,\"wrapperStatus\":1,\"sourceLists\":null,\"listRecordDetail\":null,\"listReviewLink\":\"\"}],\"clientId\":\"0013L00000baSiHQAU\",\"clientKey\":2386394269,\"version\":\"v6.8.1.0 - Released October 6, 2023\",\"isiReserved\":\"\",\"searchResults\":[{\"searchName\":\"Individual Name Search\",\"clientId\":\"0013L00000baSiHQAU\",\"clientKey\":0,\"clientName\":\"JOHN JOHNS\",\"specificElement\":\"\",\"returned\":4,\"notReturned\":0,\"sequenceNumber\":1855,\"searchDateTime\":\"2023-10-26T11:12:01.343\",\"searchMatches\":[{\"displayOrder\":\"1\",\"listId\":\"WC\",\"listName\":\"LSEG World-Check\",\"version\":\"20230920\",\"listProfileKey\":2500683,\"listProfileId\":\"180684\",\"recordType\":\"I\",\"displayLine\":\"JOHN JOHNS\",\"isParentFlag\":1,\"dynamicFields\":{\"listParentSingleStringName\":\"JOHN JOHNS\",\"listSingleStringType\":\"Primary\",\"listGender\":\"M \",\"listAliases\":\"JOHN JOHNZ;JON JOHNS\",\"listCategory\":\"INDIVIDUAL\",\"listPEPCategory\":\"PEP N-R\",\"listDOBs\":\"1984-08-17\",\"listCountries\":\"CHINA;ZIMBABWE\",\"listCitizenships\":\"ZIMBABWE\",\"listNationalIds\":\"\",\"listPassports\":\"\"},\"fnsCategories\":\"Standard Bank::PEPs\",\"rankString\":\"EEEEEE\",\"rankScore\":100.0,\"rankType\":0,\"rankValue\":\"999\",\"configurationKey\":1,\"rankLabelKey\":-1,\"rankLabel1\":\"Significant Name 1\",\"rankLabel1FieldName\":\"NAME_FIELD_1\",\"rankLabel2\":\"Significant Name 2\",\"rankLabel2FieldName\":\"NAME_FIELD_2\",\"rankLabel3\":\"Significant Name 3\",\"rankLabel3FieldName\":\"NAME_FIELD_3\",\"rankLabel4\":\"Significant Name 4\",\"rankLabel4FieldName\":\"NAME_FIELD_4\",\"rankLabel5\":\"Significant Name 5\",\"rankLabel5FieldName\":\"NAME_FIELD_5\",\"rankLabel6\":\"Significant Name 6\",\"rankLabel6FieldName\":\"NAME_FIELD_6\",\"rankLabel7\":\"\",\"rankLabel7FieldName\":\"NOT_USED\",\"rankLabel8\":\"\",\"rankLabel8FieldName\":\"NOT_USED\",\"rankLabel9\":\"\",\"rankLabel9FieldName\":\"NOT_USED\",\"rankLabel10\":\"\",\"rankLabel10FieldName\":\"NOT_USED\",\"rankLabel11\":\"\",\"rankLabel11FieldName\":\"NOT_USED\",\"rankLabel12\":\"\",\"rankLabel12FieldName\":\"NOT_USED\",\"rankLabel13\":\"\",\"rankLabel13FieldName\":\"NOT_USED\",\"reviewStatus\":\"New\",\"reviewReason\":\"New\",\"reviewComment\":\"\",\"listRecordDetail\":{\"listRecord\":{\"dowJones\":null,\"dowJonesAdverseMediaEntities\":null,\"dowJonesHighRiskFactors\":null,\"dowJonesSanctionsOwnershipResearch\":null,\"worldCheck\":{\"person\":{\"title\":\"\",\"position\":\"\",\"names\":{\"first_name\":\"JOHN\",\"last_name\":\"GORERAZA\",\"aliases\":[{\"aliasType\":\"Alias Name\",\"aliasName\":\"JON JONS\",\"language\":\"\"},{\"aliasType\":\"Alternative Spelling\",\"aliasName\":\"JOHN JONS\",\"language\":\"\"}]},\"agedata\":{\"age\":\"33\",\"as_of_date\":\"2017-08-17\",\"dob\":\"\",\"deceased\":\"\",\"generatedDOB\":\"1984-08-17\"},\"dobs\":{\"dob\":[]},\"ssn\":\"\",\"ei\":\"M\",\"updatecategory\":\"C3\",\"updatecategoryDescription\":\"\"},\"details\":{\"further_information\":\"[BIOGRAPHY] Co-Owner of Boulware Consulting (reported Oct 2013 - ). Majority Shareholder of Tolrose Gold Mine (Oct 2013 - ). Manager of Gushungo Dairy Estate (reported 2009 - ). [IDENTIFICATION] Grace Mugabe (PEP) (mother). Patterson Timba (PEP) (business associate). [REPORTS] Aug 2022 - no further information reported.\",\"passports\":{\"passport\":[]},\"place_of_birth\":\"\",\"locations\":{\"location\":[{\"country\":\"CHINA\",\"city\":\"Beijing\",\"state\":\"\",\"location\":\"\"},{\"country\":\"ZIMBABWE\",\"city\":\"Harare\",\"state\":\"Harare\",\"location\":\"\"}]},\"citizenships\":{\"citizenship\":[\"ZIMBABWE\"]},\"companies\":[{\"company\":\"\",\"companyName\":\"Gushungo Dairy Estate\",\"listProfileKey\":0,\"pep\":\"\",\"pepDescription\":\"\",\"category\":\"\",\"listCategory\":\"\"},{\"company\":\"\",\"companyName\":\"Tolrose Gold Mine\",\"listProfileKey\":0,\"pep\":\"\",\"pepDescription\":\"\",\"category\":\"\",\"listCategory\":\"\"}],\"linked_to\":{\"uid\":[\"1339895\",\"28775\",\"180683\"],\"listProfileKey\":[2011775,3656574,2500672],\"name\":[\"PATTERSON TIMBA\",\"GRACE MUGABE\",\"STANLEY GORERAZA\"],\"pep\":[\"PEP N\",\"PEP NG\",\"PEP N\"],\"pepDescription\":[\"PEP National Government\",\"PEP Non\u2010Government\",\"PEP National Government\"],\"category\":[\"INDIVIDUAL\",\"INDIVIDUAL\",\"DIPLOMAT\"],\"listCategory\":[\"Standard Bank::PEPs\",\"Standard Bank::SANCTIONS-INDIVIDUALS, Standard Bank::PEPs\",\"Standard Bank::PEPs\"]},\"identification_numbers\":{\"identification_number\":[]},\"keywords\":{\"keyword\":[],\"keywordDescription\":[]},\"external_sources\":{\"uri\":[\"www.test.test\",\"www.test.test\"]}},\"category\":\"INDIVIDUAL\",\"categoryDescription\":\"Person accused, investigated, arrested, charged, indicted, detained, questioned, or on trial for World-Check related crimes, but not yet convicted. Individual appointed to a PEP position (as opposed to elected). Individual appearing on a regulatory, law enforcement, or global sanctions watch list such as OFAC, disqualified directors or Interpol. Immediate relative or close associate of primary PEPs.\",\"entered\":\"2003-08-27 \",\"subcategory\":\"PEP N-R\",\"subcategoryDescription\":\"PEP National Government \u2010 Immediate Relative\",\"uid\":\"180684\",\"updated\":\"2023-09-20 \",\"listId\":\"WC\",\"listVersion\":\"20230920\",\"loadDate\":\"2023-09-22T01:01:36\",\"deleted\":\"N\",\"listCategory\":\"Standard Bank::PEPs\",\"listType\":\"World-Check\",\"listProfileKey\":2500683},\"worldCheckSanctionsSet\":null,\"info4C\":null,\"innovative\":null,\"rdc\":null,\"wco\":null},\"listId\":\"WC\",\"listInstructions\":\"\"}},{\"displayOrder\":\"2\",\"listId\":\"*STBB\",\"listName\":\"Standard Bank Black List\",\"version\":\"20210707\",\"listProfileKey\":13628987,\"listProfileId\":\"SBSA000065\",\"recordType\":\"I\",\"displayLine\":\"JOHN JOHNS\",\"isParentFlag\":1,\"dynamicFields\":{\"listParentSingleStringName\":\"JOHN JOHNS\",\"listSingleStringType\":\"Primary\",\"listGender\":\" \",\"listAliases\":\"\",\"listCategory\":\"\",\"listPEPCategory\":\"\",\"listDOBs\":\"\",\"listCountries\":\"\",\"listCitizenships\":\"\",\"listNationalIds\":\"\",\"listPassports\":\"\"},\"fnsCategories\":\"\",\"rankString\":\"EEEEEE\",\"rankScore\":100.0,\"rankType\":0,\"configurationKey\":1,\"rankLabelKey\":-1,\"rankLabel1\":\"Significant Name 1\",\"rankLabel1FieldName\":\"NAME_FIELD_1\",\"rankLabel2\":\"Significant Name 2\",\"rankLabel2FieldName\":\"NAME_FIELD_2\",\"rankLabel3\":\"Significant Name 3\",\"rankLabel3FieldName\":\"NAME_FIELD_3\",\"rankLabel4\":\"Significant Name 4\",\"rankLabel4FieldName\":\"NAME_FIELD_4\",\"rankLabel5\":\"Significant Name 5\",\"rankLabel5FieldName\":\"NAME_FIELD_5\",\"rankLabel6\":\"Significant Name 6\",\"rankLabel6FieldName\":\"NAME_FIELD_6\",\"rankLabel7\":\"\",\"rankLabel7FieldName\":\"NOT_USED\",\"rankLabel8\":\"\",\"rankLabel8FieldName\":\"NOT_USED\",\"rankLabel9\":\"\",\"rankLabel9FieldName\":\"NOT_USED\",\"rankLabel10\":\"\",\"rankLabel10FieldName\":\"NOT_USED\",\"rankLabel11\":\"\",\"rankLabel11FieldName\":\"NOT_USED\",\"rankLabel12\":\"\",\"rankLabel12FieldName\":\"NOT_USED\",\"rankLabel13\":\"\",\"rankLabel13FieldName\":\"NOT_USED\",\"rankValue\":\"999\",\"reviewStatus\":\"New\",\"reviewReason\":\"New\",\"reviewComment\":\"\",\"listRecordDetail\":{\"listRecord\":{\"dowJones\":null,\"dowJonesAdverseMediaEntities\":null,\"dowJonesHighRiskFactors\":null,\"dowJonesSanctionsOwnershipResearch\":null,\"worldCheck\":null,\"worldCheckSanctionsSet\":null,\"info4C\":null,\"innovative\":{\"listKey\":5023,\"listId\":\"*STBB\",\"listVersion\":\"20210707\",\"listType\":\"Standard Bank Black List\",\"listProfileKey\":13628987,\"nameAddressRecord\":{\"id\":\"SBSA000065\",\"active\":\"Y\",\"recordType\":\"I\",\"trackingInformation\":[],\"person\":[{\"type\":\"Primary\",\"fullName\":\"JOHN JOHNS\",\"additionalPersonFields\":[]}],\"entity\":[],\"physicalAttributes\":[],\"socialAttributes\":[],\"vessel\":[],\"address\":[],\"dates\":[],\"idNumbers\":[],\"textInfo\":[{\"type\":\"Unclassified\",\"value\":\"NA\",\"additionalFields\":[{\"order\":\"1\",\"type\":\"Original Type\",\"value\":\"NavRecordType\"}]}],\"associations\":[],\"linkedTo\":[],\"URLS\":[],\"additionalInformation\":[]},\"specificRecord\":{\"id\":null,\"value\":null},\"singleStringName\":\"JOHN JOHNS\",\"loadDate\":\"2021-07-07T19:25:38\",\"deleted\":\"N\",\"listCategory\":\"\",\"brandingDisplayURL\":\"\",\"brandingHomeURL\":\"\",\"brandingCopyright\":\"\"},\"rdc\":null,\"wco\":null},\"listId\":\"*STBB\",\"listInstructions\":\"\"}}],\"searchReports\":null}],\"uboResults\":null,\"premiumResults\":[],\"riskDetails\":{\"overallClientRiskRating\":0,\"overallClientRiskScore\":0,\"cipRiskScore\":0,\"screeningResultsRiskScore\":0,\"clientExtendedRisk\":[],\"clientRiskHistory\":[]},\"searchAuditListOutputs\":[],\"prefixStatus\":4,\"prefixResults\":[]}],\"isiReserved\":\"\",\"networkKey\":0}');
            return response;
        }
    }
    /**
     * @description mocks a pass response returned from the multi/lookup API
     */
    @testVisible
    private class ScreeningPassMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":0,\"message\":\"Lookup PASSED\",\"returned\":0,\"notReturned\":0,\"resultsCount\":0,\"hitCount\":0,\"pendingCount\":0,\"safeCount\":0,\"duplicateCount\":0,\"version\":\"v6.8.0.0 - Released August 11, 2023\",\"responses\":[{\"status\":0,\"message\":\"Lookup PASSED\",\"returned\":0,\"notReturned\":0,\"resultsCount\":0,\"hitCount\":0,\"pendingCount\":0,\"safeCount\":0,\"duplicateCount\":0,\"complianceRecords\":[],\"clientId\":\"0013L00000R1rkBQAR\",\"clientKey\":2372780290,\"version\":\"v6.8.0.0 - Released August 11, 2023\",\"isiReserved\":\"\",\"searchResults\":[{\"searchName\":\"Individual Name Search\",\"clientId\":\"0013L00000R1rkBQAR\",\"clientKey\":0,\"clientName\":\" JOHN JOHNS\",\"specificElement\":\"\",\"returned\":0,\"notReturned\":0,\"sequenceNumber\":22770,\"searchDateTime\":\"2023-10-04T10:19:36.263\",\"searchMatches\":[],\"searchReports\":null}]}]}');
            return response;
        }
    }
    /**
     * @description mocks an error response returned from the multi/lookup API
     */
    @testVisible
    private class ScreeningErrorMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":3,\"message\":\"ERROR: SLLookupMulti (Processing Records): \\r\\nSee individual records for details\",\"returned\":0,\"notReturned\":0,\"resultsCount\":0,\"hitCount\":0,\"pendingCount\":0,\"safeCount\":0,\"duplicateCount\":0,\"version\":\"v6.8.0.0 - Released August 11, 2023\",\"responses\":[{\"status\":3,\"message\":\"Exception in SSQSearchQueryGet(): \\r\\n\\tMessage: An item with the same key has already been added.\\r\\nERROR: SLLookup (User Fields):\\r\\nUnable to retrieve User Field Definitions\",\"returned\":0,\"notReturned\":0,\"resultsCount\":0,\"hitCount\":0,\"pendingCount\":0,\"safeCount\":0,\"duplicateCount\":0,\"complianceRecords\":[],\"clientId\":\"0013L00000cFsYFQA0\",\"clientKey\":0,\"version\":\"v6.8.0.0 - Released August 11, 2023\",\"isiReserved\":\"\",\"searchResults\":[]}]}');
            return response;
        }
    }
    /**
     * @description mocks an invalid response returned from the multi/lookup API
     */
    @testVisible
    private class ScreeningInvalidMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status');
            return response;
        }
    }
    /**
     * @description mocks a response returned from the pairs/update API
     */
    @testVisible
    private class UpdatePairsMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":1,\"message\":\"\"}');
            return response;
        }
    }
    /**
     * @description mocks an error response returned from the pairs/update API
     */
    @testVisible
    private class UpdatePairsErrorMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":3,\"message\":\"\"}');
            return response;
        }
    }
    /**
     * @description mocks an invalid response returned from the pairs/update API
     */
    @testVisible
    private class UpdatePairsInvalidMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":1,\"mess}');
            return response;
        }
    }
    /**
     * @description mocks a response returned from the clients/update API, onboarded
     */
    @testVisible
    private class UpdateClientOnboardMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":0,\"message\":\"Completed\",\"version\":\"v6.8.0.0 - Released August 11, 2023\",\"clientId\":\"BPIDval\",\"oldClientId\":\"0013L00000R1rkBQAR\",\"clientKey\":2359060690,\"applicationId\":\"SAPIM\",\"oldApplicationId\":\"ONBDG\"}');
            return response;
        }
    }
    /**
     * @description mocks a response returned from the clients/update API, cancelled
     */
    @testVisible
    private class UpdateClientCancelMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":0,\"message\":\"Completed\",\"version\":\"v6.8.0.0 - Released August 11, 2023\",\"clientId\":\"0013L00000R1rkBQAR\",\"clientKey\":2359060690,\"applicationId\":\"ONBDG\",\"clientStatus\":1}');
            return response;
        }
    }   
    /**
     * @description mocks an error response returned from the clients/update API
     */
    @testVisible
    private class UpdateClientErrorMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":3,\"message\":\"Failed\",\"version\":\"v6.8.0.0 - Released August 11, 2023\"}');
            return response;
        }
    }
    /**
     * @description mocks an invalid response returned from the clients/update API
     */
    @testVisible
    private class UpdateClientInvalidMockResponse implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        @testVisible
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{\"status\":0,\"mess');
            return response;
        }
    }
}