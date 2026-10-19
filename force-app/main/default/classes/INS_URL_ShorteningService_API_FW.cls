/**
 * @description       : Service class that shortens long URLs using AppsFlyer OneLink API v2.0
 * @author            : Jaco de Lange
 * @group             : SFP-453856 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @created date      : 27-10-2025
 * @LastModified      : July 2026
 * @LastModifiedReason Refactored to align with the secured `sbgplatform.ApiService` architectural pattern.
 * bubbling via INS_CustomException, and route-aware unit testing mocks.
**/
public without sharing class INS_URL_ShorteningService_API_FW extends sbgplatform.ApiService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('INS_URL_ShorteningService');
    
    private static final String NAMED_CREDENTIAL = 'CHNW_IAM_AR_SortenLongURLN';
    private static final String EC_NAME = 'CHNW_IAM_AR_SortenLongURLE';

    // DTOs for parsing AppsFlyer OneLink API response
    public class AppsFlyerResponse {
        public String shorturl;
        public String fullurl;
    }
    
    public INS_URL_ShorteningService_API_FW() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * @description   Calls AppsFlyer OneLink API via ApiService framework to shorten a URL
     * @param         longUrl - The payment gateway landing page URL to be shortened
     * @return        Shortened OneLink URL string
     */
    public static String createShortUrl(String longUrl) {
        if (String.isBlank(longUrl)) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | URL to shorten cannot be blank ');
            return null;
        }

        try {
            // Construct AppsFlyer payload payload mapping the web fallback destination parameters
            Map<String, Object> dataBlock = new Map<String, Object>{
                'pid' => 'email_marketing',
                'c' => 'invoice_collection',
                'af_channel' => 'newsletter',
                'af_web_dp' => longUrl,
                'af_ios_url' => longUrl,
                'af_android_url' => longUrl
            };

            Map<String, Object> payload = new Map<String, Object>{
                'ttl' => '90d',
                'data' => dataBlock
            };

            String path = '/api/v2.0/shortlinks/i2hG';

            String responseBody = (String) new INS_URL_ShorteningService_API_FW().post(path, JSON.serialize(payload));

            if (responseBody == null) {
                LOGGER.error(
                    'INS_URL_ShorteningService_API_FW.createShortUrl: No response body received from gateway',
                    new List<String>{ 'INS_URL_ShorteningService_API_FW.createShortUrl' }
                );
                return null;
            }

            AppsFlyerResponse responseObj = (AppsFlyerResponse) JSON.deserialize(responseBody, AppsFlyerResponse.class);
            
            if (responseObj == null || String.isBlank(responseObj.shorturl)) {
                return null;
            }

            return responseObj.shorturl;

        } catch (Exception ex) {
            LOGGER.error(
                'INS_URL_ShorteningService_API_FW.createShortUrl: Unhandled Exception Occurred',
                new List<String>{ 'INS_URL_ShorteningService_API_FW.createShortUrl', ex.getMessage() }
            );
            throw new INS_CustomException(ex);
        }
    }
    
    /**
     * @description Framework extension point. Intercepts outbound callouts to inject authorization 
     * tokens and credential headers from External Credentials.
     */
    public override HttpRequest prepareHttpRequest(String path, String method, Object requestBody, String contentType) {
        HttpRequest req = super.prepareHttpRequest(path, method, requestBody, contentType);

        // Security pattern layer integrations
        req.setHeader('Authorization', 'Bearer ' + '{!$Credential.' + EC_NAME + '.token}');
        req.setHeader('accept', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);
        req.setHeader('Content-Type',  sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);
        return req;
    }

    /**
     * @description Mocks a successful response from AppsFlyer shortlinks system.
     * Route-aware to support CMN_Generate_Token_Helper authorization passes safely.
     */
    @testVisible
    private class ShortenUrlSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            
            if (request.getEndpoint() != null && request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setStatusCode(200);
                response.setStatus('OK');
                response.setBody('{"access_token":"test-bearer","token_type":"bearer","expires_in":3600}');
                return response;
            }
            
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"shorturl":"https://myapp.onelink.me/i2hG/payment_request_2026","fullurl":"https://app.appsflyer.com/id123"}');
            return response;
        }
    }

    /**
     * @description Mocks a failure response from AppsFlyer shortlinks system.
     */
    @testVisible
    private class ShortenUrlFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            
            if (request.getEndpoint() != null && request.getEndpoint().containsIgnoreCase('LibertyOAuth')) {
                response.setStatusCode(200);
                response.setStatus('OK');
                response.setBody('{"access_token":"test-bearer","token_type":"bearer","expires_in":3600}');
                return response;
            }
            
            response.setStatusCode(500);
            response.setStatus('Internal Server Error');
            response.setBody('{"error":{"errorCode":500,"errorMessage":"Shortlink creation failed"}}');
            return response;
        }
    }
}