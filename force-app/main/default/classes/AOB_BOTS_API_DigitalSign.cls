/**
* @description  class used  for DigitalSign
* @date Jan 3rd 2023
*/
public class AOB_BOTS_API_DigitalSign{
    
    private static final String RQUEST_METHOD='POST';
    private static final String RQUEST_ENDPOINT=System.label.signingHUBSign;
    private static final String AUTHORIZATION='Authorization';
    private static final String CONTENT_TYPE='Content-Type';
    private static final String ACCEPT='Accept';
    private static final String APPLICATION_JSON='application/json';
     /**
      * @description  class used  for DigitalSign
      * @param jsonBody String
      * @param documnetId String
      * @param packageId String
      * @return integer
     */
    public static Integer digitalSteps(String jsonBody, String documnetId,String packageId){
        String accesToken=AOB_BOTS_SRV_SigningHUB.getAccessToken();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(RQUEST_ENDPOINT+packageId+'/documents/'+documnetId+'/fields/autoplace');
        req.setMethod(RQUEST_METHOD);
        req.setHeader(AUTHORIZATION, 'Bearer '+accesToken);
        req.setHeader(CONTENT_TYPE,APPLICATION_JSON);
        req.setHeader(ACCEPT,APPLICATION_JSON);
        req.setBody(jsonBody);
        req.setTimeout(120000);
        HTTPResponse res = http.send(req);
        return res.getStatusCode();
    }
   
}