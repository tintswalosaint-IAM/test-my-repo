/**
 * @description : INS_CVC_Verification to make callouts to the generate and validate CVC verification code
 * @author : Shams Ul Arifeen
 * @group : Cloudsmiths
 * @last modified on  : 07-26-2024
 ***************************************************************************************
 * Last Modified By  Alexandr Goryachko
 * Last Modified Date 23/03/2026
 * Last Modified Description: Added timeout 30 seconds
 * User Story : SFP-53455
 ***************************************************************************************
 * Last Modified By  Ross Kshirsagar
 * Last Modified Date 04/08/2026
 * Last Modified Description: API Code Remediation. Migrated to sbgplatform.ApiService framework
 *   on the dedicated CHNW_IAM_INS_CVCVerificationN Named Credential (URL carries the full endpoint
 *   path). Bearer + IBM DataPower headers (client_id / client_secret / org_client_id via
 *   LibertyGatewayE Reg_* merge fields; country_code / channel / transaction_id / accept)
 *   injected via prepareHttpRequest override.
 * User Story : SFP-57763
 ***************************************************************************************
 **/
public with sharing class INS_CVC_Verification extends sbgplatform.ApiService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_CVC_Verification');
    private static final String NAMED_CREDENTIAL = 'CHNW_IAM_INS_CVCVerificationN';
    private static final String EC_NAME = 'CHNW_IAM_INS_LibertyGatewayE';

    // Per-call header value injected into prepareHttpRequest via the framework's build path.
    // Set on the instance before calling post()/put(), then read inside the override.
    public String clientCountry;

    public INS_CVC_Verification() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description Framework extension point. Builds the HttpRequest manually so the endpoint is
     *   `callout:<NC>` (no trailing slash — CVCVerificationN carries the full path in its Url) with
     *   Bearer + IBM DataPower headers attached. Same shape as the sibling Liberty callers, sharing
     *   the LibertyGatewayE `Reg_*` merge fields (same underlying Liberty IBM app subscription).
     *   `country_code` header is set from the per-call `clientCountry` instance field.
     */
    public override HttpRequest prepareHttpRequest(String path, String method, Object requestBody, String contentType) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CREDENTIAL + (String.isBlank(path) ? '' : path));
        req.setMethod(method);
        req.setTimeout(30000);
        if (String.isNotBlank(contentType)) {
            req.setHeader('content-type', contentType);
        } else {
            req.setHeader('content-type', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);
        }
        if (requestBody != null && requestBody instanceof String) {
            req.setBody((String) requestBody);
        }
        req.setHeader('Authorization', 'Bearer ' + CMN_Generate_Token_Helper.getAccessToken());
        req.setHeader('client_id', '{!$Credential.' + EC_NAME + '.Reg_client_id}');
        req.setHeader('org_client_id', '{!$Credential.' + EC_NAME + '.Reg_client_id}');
        if (String.isNotBlank(clientCountry)) {
            req.setHeader('country_code', clientCountry);
        }
        req.setHeader('transaction_id', generateTransactionId());
        req.setHeader('accept', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);
        return req;
    }

    private static String generateTransactionId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.substring(0, 8) +
            '-' +
            h.substring(8, 12) +
            '-' +
            h.substring(12, 16) +
            '-' +
            h.substring(16, 20) +
            '-' +
            h.substring(20);
    }

    /**
     * @description Method to generate CVC Verification code.
     * @param cellphoneNumber Cellphone number for SMS delivery (goes into request body)
     * @param emailAddress Email address for email delivery (goes into request body)
     * @param clientCountry ISO country code — attached as the `country_code` header via prepareHttpRequest
     * @param verificationType Verification type e.g. Liberty (goes into request body)
     * @param channel Channel id (goes into request body as `channelId`)
     * @param ContactId Contact id (goes into request body)
     * @return VerificationResponse initiated verification response
     */
    @AuraEnabled
    public static VerificationResponse generateCVCVerificationCode(
        String cellphoneNumber,
        String emailAddress,
        String clientCountry,
        String verificationType,
        String channel,
        String ContactId
    ) {
        Map<String, Object> payloadMap = new Map<String, Object>();
        payloadMap.put('channelId', channel);
        payloadMap.put('contactId', ContactId);
        payloadMap.put('verificationType', verificationType);
        if (String.isNotBlank(emailAddress)) {
            payloadMap.put('emailAddress', emailAddress);
        }
        if (String.isNotBlank(cellphoneNumber)) {
            payloadMap.put('cellphoneNumber', cellphoneNumber);
        }

        try {
            INS_CVC_Verification service = new INS_CVC_Verification();
            service.clientCountry = clientCountry;
            String responseBody = (String) service.post('', JSON.serialize(payloadMap));
            if (responseBody == null) {
                return new VerificationResponse();
            }
            return (VerificationResponse) JSON.deserialize(responseBody, VerificationResponse.class);
        } catch (Exception ex) {
            LOGGER.error('INS_CVC_Verification.generateCVCVerificationCode', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Method to validate CVC Verification code.
     * @param verificationCodeId Verification code id returned on initiation
     * @param validationPattern Pattern entered by the user
     * @param clientCountry ISO country code — attached as the `country_code` header via prepareHttpRequest
     * @return ValidationResponse validation result
     */
    @AuraEnabled
    public static ValidationResponse validateCVCVerificationCode(
        String verificationCodeId,
        String validationPattern,
        String clientCountry
    ) {
        INS_ValidateCVCRequest payloadData = new INS_ValidateCVCRequest();
        payloadData.verificationCode = validationPattern;

        try {
            String path = '/' + verificationCodeId;
            INS_CVC_Verification service = new INS_CVC_Verification();
            service.clientCountry = clientCountry;
            String responseBody = (String) service.put(path, JSON.serialize(payloadData));
            if (responseBody == null) {
                return new ValidationResponse();
            }
            ValidationResponse validationResponse = (ValidationResponse) JSON.deserialize(
                responseBody,
                ValidationResponse.class
            );
            if (validationResponse.validation == INS_Quote_Helper.failed) {
                throw new AOB_CustomException(validationResponse.reason);
            }
            return validationResponse;
        } catch (Exception ex) {
            LOGGER.error('INS_CVC_Verification.validateCVCVerificationCode', ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Class to set returned initiate CVC Api response.
     */
    public class VerificationResponse {
        @AuraEnabled
        public String verificationCodeId { get; set; }
        @AuraEnabled
        public String validationPattern { get; set; }
    }

    /**
     * @description Class to set payload validate CVC Api request.
     */
    public class INS_ValidateCVCRequest {
        public String verificationCode;
    }

    /**
     * @description Class to set returned validate CVC Api response.
     */
    public class ValidationResponse {
        @AuraEnabled
        public String validation;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public Integer errorCode;
    }

    /**
     * @description Mocks a successful initiate response returned from the CVC Verification API.
     *   Route-aware: OAuth token endpoint returns Bearer JSON so the helper's mint succeeds;
     *   the CVC endpoint returns the verification-code initiation payload.
     */
    @testVisible
    private class CVCInitiateSuccessMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint() != null && request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
                response.setStatus('OK');
                response.setBody('{"access_token":"test-bearer","token_type":"bearer","expires_in":3600}');
                return response;
            }
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setStatus('OK');
            response.setBody(
                '{"verificationCodeId":"ff237671-e399-472e-b69b-7bf6292d53b7","validationPattern":"____****",' +
                    '"status":[{"name":"SMS_PENDING_ACCEPTED","description":"Message sent to next instance"},' +
                    '{"name":"EMAIL_SENT","description":"Email is delivered"}]}'
            );
            return response;
        }
    }

    /**
     * @description Mocks a successful validate response returned from the CVC Verification API.
     *   Route-aware: OAuth token endpoint returns Bearer JSON; CVC endpoint returns validation success.
     */
    @testVisible
    private class CVCValidateSuccessMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint() != null && request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
                response.setStatus('OK');
                response.setBody('{"access_token":"test-bearer","token_type":"bearer","expires_in":3600}');
                return response;
            }
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setStatus('OK');
            response.setBody('{"validation":"Success","reason":"","errorCode":0}');
            return response;
        }
    }

    /**
     * @description Mocks a failure validate response returned from the CVC Verification API.
     *   Route-aware: OAuth token endpoint still returns Bearer so the helper mint succeeds; the
     *   CVC endpoint returns the validation-failed payload.
     */
    @testVisible
    private class CVCValidateFailureMock implements HttpCalloutMock {
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint() != null && request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
                response.setStatus('OK');
                response.setBody('{"access_token":"test-bearer","token_type":"bearer","expires_in":3600}');
                return response;
            }
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setStatus('OK');
            response.setBody('{"validation":"failed","reason":"Failed to validate CVC Code","errorCode":0}');
            return response;
        }
    }
}