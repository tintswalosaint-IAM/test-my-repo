/**
 * @description       : Service class that shortens long URLs using AppsFlyer OneLink API v2.0
 * @author            : Jaco de Lange
 * @group             : SFP-453856 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @created date      : 27-10-2025
**/
public with sharing class INS_URL_ShorteningServiceAppsFlyer {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_URL_ShorteningService');
  
    // DTOs for parsing AppsFlyer OneLink API response
    public class AppsFlyerResponse {
        public String shorturl;
        public String fullurl;
    }

    /**
     * @description   Calls AppsFlyer OneLink API to shorten a URL
     * @param         longUrl - The payment gateway landing page URL to be shortened
     * @return        Shortened OneLink URL (e.g. https://myapp.onelink.me/i2hG/payment_slug)
     */
    public static String createShortUrl(String longUrl) {
        if (String.isBlank(longUrl)) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | URL to shorten cannot be blank ');
            return null;
        }

        HttpRequest req = new HttpRequest();
        // Uses Named Credential base path + AppsFlyer specific template path i2hG
        req.setEndpoint('callout:CHNW_IAM_AR_SortenLongURLN/api/v2.0/shortlinks/i2hG');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Bearer ' + '{!$Credential.CHNW_IAM_AR_SortenLongURLE.token}');

        // Construct AppsFlyer payload mapping the web fallback destination parameters
        Map<String, Object> dataBlock = new Map<String, Object>{
            'pid' => 'email_marketing',
            'c' => 'invoice_collection',
            'af_channel' => 'newsletter',
            'af_web_dp' => longUrl,
            'af_ios_url' => longUrl,
            'af_android_url' => longUrl
        };

        Map<String, Object> requestBody = new Map<String, Object>{
            'ttl' => '90d',
            'data' => dataBlock
        };
        
        req.setBody(JSON.serialize(requestBody));
        Http http = new Http();

        try {
            HttpResponse res = http.send(req);
           
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                AppsFlyerResponse responseObj = (AppsFlyerResponse) JSON.deserialize(res.getBody(), AppsFlyerResponse.class);
                
                // Clean structural check avoiding complex nested negations
                if (responseObj == null || String.isBlank(responseObj.shorturl)) {
                    return null;
                }
                return responseObj.shorturl;
            } 
            
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | API Error status code: ' + res.getStatusCode() + ' | Body: ' + res.getBody());
            return null;

        } catch (System.CalloutException ex) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | call out exception | ' + ex.getMessage());
            return null;
        } catch (System.JSONException ex) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | JSON parsing exception | ' + ex.getMessage());
            return null;
        }
    }
}