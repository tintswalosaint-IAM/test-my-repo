/**
 * @description Boost Application API Callout Class
 * @author November Sizwe
 * @date September 2022
 */
public class ICS_API_BoostApplication  {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_Boost_Application');    
  
    
    /**
    * @description This method creates a new unique guid value
    * @return String guid
    */
    public static String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }
  
   /**
   * @description This method makes a callout to Boost 
   * @param  payloadString  	Payload JSON string for request body to Boost
   * @return String   			Response body in JSON format 
   */
    public static String boostApplicationCallout(String payloadString) {
        
        HttpRequest httpRequest = new HttpRequest();
        HttpResponse httpResponse = new HttpResponse();
        Http http = new Http();
		String boostResponseBody;
        try{  
            String fApiInteractionId = createGUID();
            CMN_WebserviceSetting__mdt webSettings = CMN_WebserviceSetting__mdt.getInstance('ICS_API_BoostApplication');
            String endpoint =  'callout:' +webSettings.CMN_NamedCredential__c;
            httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
            httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
            httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, fApiInteractionId);
            httpRequest.setClientCertificateName('ICS_Azure_Certificate');
            httpRequest.setEndpoint(endpoint);
            httpRequest.setBody(payloadString);
            httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
            httpRequest.setTimeout(30000); 
            
            httpResponse = http.send(httpRequest);
            boostResponseBody = httpResponse.getBody();
        }
        catch(Exception e){
            LOGGER.error('Error on boostApplicationCallout', e); 
        }

        return boostResponseBody;    
        
    }

}