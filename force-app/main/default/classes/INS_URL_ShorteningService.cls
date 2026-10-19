/**
 * @description       : Service class that shorten long url
 * @author            : Jaco de Lange
 * @group             : SFP-453856 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @created date      : 27-10-2025
 *
 * @Last Modified By  Alexandr Goryachko
 * @Last Modified Date 26-11-2025
 * @Last Modified Description: Added settimeout
 * @User story: SFP-53455
 **/
public with sharing class INS_URL_ShorteningService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_URL_ShorteningService');
  
    // DTOs for parsing TinyURL API response
    public class TinyUrlResponse {
        public TinyUrlData data;
    }

    public class TinyUrlData {
        public String tiny_url;
        public String url;
        public String domain;
    }

    /**
     * @description   Calls TinyURL API to shorten a URL
     * @param         longUrl - The URL to be shortened
     * @return        Shortened TinyURL (e.g. https://tinyurl.com/xyz123)
     */
    public static String createShortUrl(String longUrl) {
        if (String.isBlank(longUrl)) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | URL to shorten cannot be blank ');
            throw new AuraHandledException('Long URL cannot be blank');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CHNW_IAM_AR_SortenLongURLN' + '/create');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(30000);
        req.setHeader('Authorization', 'Bearer ' + '{!$Credential.CHNW_IAM_AR_SortenLongURLE.token}');

        // JSON body format for TinyURL API v2
        Map<String, Object> requestBody = new Map<String, Object>{
            'url' => longUrl
        };
        req.setBody(JSON.serialize(requestBody));

        Http http = new Http();

        try {
            HttpResponse res = http.send(req);
           
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                TinyUrlResponse responseObj = (TinyUrlResponse) JSON.deserialize(res.getBody(), TinyUrlResponse.class);
                if (responseObj != null && responseObj.data != null && !String.isBlank(responseObj.data.tiny_url)) {
                    return responseObj.data.tiny_url;
                } else {
                    return null;
                }
            } else {
                return null;
            }

        } catch (System.CalloutException ex) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | call out exception | ' + ex.getMessage());
            return null;
        } catch (System.JSONException ex) {
            LOGGER.error('INS_URL_ShorteningService | createShortUrl | JSON parsing exception | ' + ex.getMessage());
            return null;
        }
    }
}