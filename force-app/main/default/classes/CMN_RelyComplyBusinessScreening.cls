/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :CMN_RelyComplyBusinessScreening
@description       :Class for dealing with Rely Comply
@Last Modified By  : jagadish Thummala
@Last Modified On  : 11-12-2025
@Modification description : SFP-26345

@ Last Modified By  : Alex Niyonsaba
@ Last Modified On  : Aug 22nd 2025
@ Modification description : Updates made to add a DEFAULT_BUSINESS_REGISTRATION_NUMBER and UNREGISTERED_CLIENT_TYPE that
must only be used when dealing with Pamoja for unregistered businessses, on line 93.
@ User Story : SFP-51695 
***************************************************************************************/
public class CMN_RelyComplyBusinessScreening {
    private CMN_RelyComplyBusinessScreening() {
    }

    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_SIGNATURE = 'x-signature';
    private static final String HEADER_CHANNELID = 'x-channel-id';
    private static final String HEADER_SFUG = 'SFUG';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final String CLIENT_ID = '{!$Credential.UG_BCB_PPB_RELYCOMPLY_EC.client_id}';
    private static final String BUSINESS_SCREENING_PATH_CALLOUT = '/account-screening/business/v1/screen';

    //Only Use UNREGISTERED_CLIENT_TYPE and DEFAULT_BUSINESS_REGISTRATION_NUMBER when dealing with Pamoja for unregistered businessses.
    private static final String UNREGISTERED_CLIENT_TYPE = 'unregistered business';
    private static final String DEFAULT_BUSINESS_REGISTRATION_NUMBER = '0000/000000/00';
    private static final String ERROR_DESCRIPTION = 'ErrorDescription';
    private static final String ERROR_MESSAGE = 'CMN_RelyComplyBusinessScreening.makeRelyComplyBusinessScreening';
    private static final String STATUS = 'status';

    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_RelyComplyBusinessScreening');

    /**
     * @description This method used for main callout for individual screening
     * @param applicationList
     * @param applicationParticipantList
     * @return Returns a callout response in stringified format to process in the UI
     */
    public static String invocableMethod(
        List<Application__c> applicationList,
        List<Application_Participant__c> applicationParticipantList
    ) {
        if (applicationList != null && applicationList.isEmpty() == false) {
            Map<String, Object> response = makeRelyComplyBusinessScreening(
                applicationList,
                applicationParticipantList
            );

            if (response != null && response.containsKey(ERROR_DESCRIPTION) == true) {
                BCB_FlowController.createVerificationRecord(
                    applicationList[0],
                    'Rely Comply-Business',
                    'Failed'
                );
                BCB_FlowController.assignLeadToQueue(
                    applicationList[0].AOB_Lead__c,
                    'UG_BCB_Sanctioned Customer_Queue'
                );
            }
            return JSON.serialize(response);
        }
        return null;
    }

    /**
     * @description This method used for main callout for individual screening
     * @param applicationRecords
     * @param applicationParticipantList
     * @return Returns a callout response in stringified format to process in the UI
     */
    public static Map<String, Object> makeRelyComplyBusinessScreening(
        List<Application__c> applicationRecords,
        List<Application_Participant__c> applicationParticipantList
    ) {
        Application__c applicationRecord = applicationRecords[0];
        Application_Participant__c applicationParticipantRecord = applicationParticipantList[0];

        BCB_RelyComplyBean.businessScreening businessScreening = createBusinessScreening(
            applicationRecord,
            applicationParticipantRecord
        );

        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.relyComplyWebServices();
        String accessToken = CMN_SRV_RelyComply.getAccessToken();
        Map<String, Object> responseToReturnObject = new Map<String, Object>();

        if (System.Test.isRunningTest()) {
            setupTestMock();
        }
        if (String.isBlank(accessToken)) {
            return handleAccessTokenFailure(responseToReturnObject, applicationParticipantRecord);
        }
        HttpRequest httpRequest = createHttpRequest(
            businessScreening,
            accessToken,
            webServiceSetting
        );
        HttpResponse httpResponse = sendHttpRequest(httpRequest);
        //Log API Request Response Pair
        generateFullLog(httpRequest, httpResponse);
        handleHttpResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
        return responseToReturnObject;
    }

    private static HttpResponse sendHttpRequest(HttpRequest httpRequest) {
        Http http = new Http();
        return http.send(httpRequest);
    }

    private static BCB_RelyComplyBean.businessScreening createBusinessScreening(
        Application__c applicationRecord,
        Application_Participant__c applicationParticipantRecord
    ) {
        BCB_RelyComplyBean.businessScreening businessScreening = new BCB_RelyComplyBean.businessScreening();

        businessScreening.identifier = applicationRecord.WI_ClientType__c != null &&
            applicationRecord.WI_ClientType__c.equalsIgnoreCase(UNREGISTERED_CLIENT_TYPE)
            ? DEFAULT_BUSINESS_REGISTRATION_NUMBER
            : applicationRecord.AOB_RegistrationNumber__c.substring(0, 4) +
              '/' +
              applicationRecord.AOB_RegistrationNumber__c.substring(4, 10) +
              '/' +
              applicationRecord.AOB_RegistrationNumber__c.substring(10);

        businessScreening.businessName = applicationRecord.AOB_BusinessLegalName__c;
        businessScreening.nationality = applicationRecord.AOB_Country__c;
        businessScreening.residence = applicationRecord.AOB_Country__c;
        businessScreening.birthDate = String.valueOf(applicationRecord.AOB_DateofRegistration__c);
        businessScreening.bankProduct = 'Transactional';

        Integer numOfYears =
            System.today().year() - applicationParticipantRecord.AOB_DateofBirth__c.year();
        if (applicationRecord.AOB_Country__c == 'UG') {
            businessScreening.clientType = numOfYears >= 18 ? 'A5A' : 'A5C';
        } else {
            businessScreening.clientType = numOfYears >= 18 ? 'A5B' : 'A5D';
        }

        Map<String, Object> mapTertiorySectorCcodes = new Map<String, Object>();
        if (applicationRecord.AOB_inflightData__c != null) {
            mapTertiorySectorCcodes = (Map<String, Object>) JSON.deserializeUntyped(
                applicationRecord.AOB_inflightData__c
            );
        }

        String tertioryCode = (String) mapTertiorySectorCcodes.get('tertiorySectorCode') ?? '';
        String passTertiryCode = tertioryCode.replaceAll('([A-Za-z])0+', '$1');
        businessScreening.industryId = passTertiryCode;
        businessScreening.onApprovedExchange = false;
        businessScreening.ownerIsBeneficiary = true;

        return businessScreening;
    }

    private static void setupTestMock() {
        if (mockHttpStatusCode != null && mockHttpStatus != null) {
            AOB_HttpMockGenerator.setTestMockResponse(
                mockHttpStatusCode,
                mockHttpStatus,
                mockHttpBody
            );
        }
    }

    private static Map<String, Object> handleAccessTokenFailure(
        Map<String, Object> responseToReturnObject,
        Application_Participant__c applicationParticipantRecord
    ) {
        LOGGER.error(
            'CMN_RelyComplyBusinessScreening.makeRelyComplyBusinessScreening: Access Token Failure',
            new List<String>{ ERROR_MESSAGE, applicationParticipantRecord.Id }
        );
        responseToReturnObject.put(STATUS, 'FAILED');
        responseToReturnObject.put(ERROR_DESCRIPTION, 'Access Token Failure');
        return responseToReturnObject;
    }

    private static HttpRequest createHttpRequest(
        BCB_RelyComplyBean.businessScreening businessScreening,
        String accessToken,
        CMN_WebserviceSetting__mdt webServiceSetting
    ) {
        HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(
            AUTHORIZATION_TYPE_BEARER,
            accessToken
        );
        httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
        httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);

        Blob data = Blob.valueOf(JSON.serialize(businessScreening));
        if (!System.Test.isRunningTest()) {
            Blob result = Crypto.sign(
                'RSA-SHA256',
                data,
                EncodingUtil.base64Decode(webServiceSetting.CMN_AdditionalKey__c)
            );
            httpRequest.setHeader(HEADER_SIGNATURE, EncodingUtil.base64Encode(result));
        }
        httpRequest.setHeader(HEADER_CLIENT_ID, CLIENT_ID);
        httpRequest.setHeader(HEADER_CHANNELID, HEADER_SFUG);
        httpRequest.setEndpoint('callout:UG_BCB_PPB_RELYCOMPLY' + BUSINESS_SCREENING_PATH_CALLOUT);
        httpRequest.setMethod(HTTP_METHOD_POST);
        httpRequest.setBody(JSON.serialize(businessScreening));
        httpRequest.setTimeout(120000);

        return httpRequest;
    }

    private static void handleHttpResponse(
        HttpResponse httpResponse,
        Map<String, Object> responseToReturnObject,
        Application_Participant__c applicationParticipantRecord
    ) {
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = httpResponse.getBody();

            if (String.isNotBlank(responseBody)) {
                BCB_RelyComplyBusinessScreeningResponse businessResponse = (BCB_RelyComplyBusinessScreeningResponse) JSON.deserialize(
                    responseBody,
                    BCB_RelyComplyBusinessScreeningResponse.class
                );
                responseToReturnObject.put(STATUS, 'SUCCESS');
                responseToReturnObject.put('statusCode', 200);
                responseToReturnObject.put('assessmentId', businessResponse.assessmentId);
                responseToReturnObject.put('assessmentStatus', businessResponse.result);
            } else {
                responseToReturnObject.put(STATUS, 'SUCCESS');
                responseToReturnObject.put('statusCode', 200);
                responseToReturnObject.put(ERROR_DESCRIPTION, 'No response body');
                LOGGER.error(
                    'CMN_RelyComplyBusinessScreening.makeRelyComplyBusinessScreening: No response body',
                    new List<String>{ ERROR_MESSAGE, applicationParticipantRecord.Id }
                );
            }
        } else {
            handleErrorResponse(httpResponse, responseToReturnObject, applicationParticipantRecord);
        }
    }

    private static void handleErrorResponse(
        HttpResponse httpResponse,
        Map<String, Object> responseToReturnObject,
        Application_Participant__c applicationParticipantRecord
    ) {
        String errorMessage = 'No Response From Server';
        if (httpResponse.getBody() != null) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(
                httpResponse.getBody()
            );
            errorMessage = (String) responseObject.get('moreInformation');
            LOGGER.error(
                'CMN_RelyComplyBusinessScreening.makeRelyComplyBusinessScreening: Need More Information',
                new List<String>{
                    ERROR_MESSAGE,
                    applicationParticipantRecord.Id,
                    JSON.serialize(responseObject)
                }
            );
        }
        responseToReturnObject.put(STATUS, 'FAILED');
        responseToReturnObject.put('statusCode', httpResponse.getStatusCode());
        responseToReturnObject.put(ERROR_DESCRIPTION, errorMessage);
        LOGGER.error(
            'CMN_RelyComplyBusinessScreening.makeRelyComplyBusinessScreening: No Response From Server',
            new List<String>{
                ERROR_MESSAGE,
                applicationParticipantRecord.Id,
                JSON.serialize(responseToReturnObject)
            }
        );
    }

    private static void generateFullLog(HttpRequest req, HttpResponse res) {
        Map<String, String> requestHeaders = new Map<String, String>{
            'Business Screening HEADER_CLIENT_ID' => req.getHeader(HEADER_CLIENT_ID),
            'Business Screening HEADER_SIGNATURE' => req.getHeader(HEADER_SIGNATURE),
            'Business Screening Endpoint' => req.getEndpoint()
        };

        Map<String, Object> fullLog = new Map<String, Object>();

        fullLog.put('Business Screening request_method', req.getMethod());
        fullLog.put('Business Screening Rely Comply request_headers', requestHeaders);
        fullLog.put(
            'Business Screening Rely Comply request_body',
            JSON.deserializeUntyped(req.getBody())
        );

        fullLog.put('Business Screening response_status_code', res.getStatusCode());
        fullLog.put('Business Screening response_status', res.getStatus());

        try {
            fullLog.put('Business Screening response_body', JSON.deserializeUntyped(res.getBody()));
        } catch (Exception e) {
            fullLog.put('response_body', res.getBody());
        }

        String finalLogEntry = JSON.serializePretty(fullLog);

        System.debug('FULL INTEGRATION LOG:\n' + finalLogEntry);
    }
}