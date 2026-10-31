/**
 * @description Mints OAuth Bearer tokens via the CHNW_IAM_INS_LibertyOAuthN Named Credential
 *   for downstream Liberty insurance API callouts (Funeral Claims, RealPay, etc.). Migrated
 *   from raw Http.send to the sbgplatform.ApiService framework so tests can intercept the
 *   token mint via the framework mock — removing the per-caller test-bypass workaround.
 * @author Khaliq Abdul (khaliq.abdul@standardbank.co.za)
 * @date Feb 19th 2024
 * @LastModified: March, 2026
 * @Author Alexandr Goryachko
 * @UserStory: SFP-53455
 * @LastModifiedReason: Added retry loop (up to 3 attempts) on non-200 / empty body
 * @LastModified: May, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-60467
 * @LastModifiedReason: API Code Remediation — extend sbgplatform.ApiService, replace raw Http.send
 *   with framework post(). Retry loop preserved.
 */
public with sharing class CMN_Generate_Token_Helper extends sbgplatform.ApiService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger('CMN_Generate_Token_Helper');

    private static final String NAMED_CREDENTIAL = 'CHNW_IAM_INS_LibertyOAuthN';
    private static final String EC_NAME = 'CHNW_IAM_INS_LibertyOAuthE';
    private static final String CONTENT_TYPE_FORM_URLENCODED = 'application/x-www-form-urlencoded';
    private static final Integer MAX_ATTEMPTS = 3;

    public CMN_Generate_Token_Helper() {
        super(NAMED_CREDENTIAL);
        setTimeout(30000);
        setExceptionOnError(false);
    }

    /**
     * @description Framework extension point. The NC URL targets the OAuth token endpoint in full
     *   (no path appendage). We bypass the framework's path-prefixed endpoint construction by
     *   building the request from scratch — calling super.prepareHttpRequest with the path-prefix
     *   pattern triggers a CalloutException on this specific NC at platform level even though
     *   the same `callout:NCName` works fine via raw Http.send. Both routes ultimately call
     *   http.Send() — the difference is purely in how the platform resolves the endpoint.
    */
    public override HttpRequest prepareHttpRequest(String path, String method, Object requestBody, String contentType) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CREDENTIAL);
        req.setMethod(method);
        req.setTimeout(30000);
        if (String.isNotBlank(contentType)) {
            req.setHeader('content-type', contentType);
        }
        if (requestBody != null && requestBody instanceof String) {
            req.setBody((String) requestBody);
        }
        return req;
    }

    /**
     * @description Obtains an OAuth access token from the INS insurance-claims realm.
     *   Retries up to MAX_ATTEMPTS times on non-200 / empty body (preserves Alexandr's behavior).
    * @return String representing the OAuth access token.
	*/
    public static String getAccessToken() {
        try {
            final String clientId = '{!$Credential.' + EC_NAME + '.client_id}';
            final String clientSecret = '{!$Credential.' + EC_NAME + '.client_secret}';
            final String payload =
                'client_id=' +
                clientId +
                '&client_secret=' +
                clientSecret +
                '&grant_type=client_credentials&scope=insurance-claims.*.*';

            CMN_Generate_Token_Helper svc = new CMN_Generate_Token_Helper();
            String responseBody = null;
            Integer attempts = 0;
            do {
                responseBody = (String) svc.post('', payload, CONTENT_TYPE_FORM_URLENCODED);
                attempts++;
            } while ((svc.getStatusCode() != 200 || String.isBlank(responseBody)) && attempts < MAX_ATTEMPTS);

            if (svc.getStatusCode() != 200) {
                LOGGER.error(
                    'CMN_Generate_Token_Helper.getAccessToken',
                    new List<String>{
                        'CMN_Generate_Token_Helper.getAccessToken',
                        String.valueOf(svc.getStatusCode()) +
                        ' ' +
                        responseBody
            }
                );
            }
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            return (String) responseMap.get('access_token');
        } catch (Exception ex) {
            LOGGER.error('CMN_Generate_Token_Helper.getAccessToken', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }
}