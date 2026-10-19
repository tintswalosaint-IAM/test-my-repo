/**
* @description Class for generating access tokens and calling Coza Lead Api
* @author Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Sept 2023
*/
public class INS_CozaLeadAPICallout {
    public static String accessToken;
   
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CozaLeadAPICallout');
    
/**
* @description       : Static method to Retrieve Access Token
**/
    
    public static void getAccessToken() {
        
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:INS_JwksToken/as/token.oauth2');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'Application/json');       
        String body = 'grant_type={!$Credential.INS_TokenJwks.grant_type}'+
            '&client_id={!$Credential.INS_TokenJwks.client_id}'+
            '&client_secret={!$Credential.INS_TokenJwks.client_secret}'; 
        request.setBody(body);
        

            
            Http http = new Http();
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200)
            {
                
                JWKSResult resultToken = (JWKSResult)JSON.deserialize(response.getBody(), JWKSResult.class);
                accessToken = resultToken.access_token; 
            }             
    
    }
    
    
    /**
* @description       : Send Salesforce lead data to SAP
* @param             leadIds
**/
    @future(callout = true)
    public static void sendLeadToSAP(List<String> leadIds) {
        try{
            LOGGER.info('INS_CozaLeadAPICallout.sendLeadToSAP');
            
            getAccessToken();
            if(accessToken != null && accessToken != '')
            {
                String cifCountry = '{!$Credential.INS_CozaLeadCren.cifCountry}';
                String channelName = '{!$Credential.INS_CozaLeadCren.channelName}';
                String channelId = '{!$Credential.INS_CozaLeadCren.channelId}';
                String xfapiinteractionid = '{!$Credential.INS_CozaLeadCren.xfapiinteractionid}';
                String xibmclientid = '{!$Credential.INS_CozaLeadCren.xibmclientid}';
                String clientCertificate1 = '{!$Credential.INS_CozaLeadCren.XClientCertificate1}';
                String clientCertificate2 = '{!$Credential.INS_CozaLeadCren.XClientCertificate2}';
                String clientCertificate3 = '{!$Credential.INS_CozaLeadCren.XClientCertificate3}';
                String xibmclientsecret = '{!$Credential.INS_CozaLeadCren.xibmclientsecret}';
                
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:INS_APICozaGateway' + '/experience/LeadandOpportunityManagement/v1');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'Application/json');
                request.setHeader('Accept', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + accessToken);
                request.setHeader('cifCountry', cifCountry);
                request.setHeader('channelName', channelName);
                request.setHeader('channelId', channelId);
                request.setHeader('x-fapi-interaction-id', xfapiinteractionid);
                request.setHeader('x-ibm-client-id',xibmclientid);
                request.setHeader('x-ibm-client-secret', xibmclientsecret);
                request.setHeader('X-Client-Certificate',clientCertificate1+''+clientCertificate2+''+clientCertificate3);
                
                String jsonBody = INS_CozaLeadToSAP.createLeadJson(leadIds);
                request.setBody(jsonBody);
                Http http = new Http();
                HttpResponse response = http.send(request);   
                if(response.getStatusCode() != 200)
                { 
                    throw new AOB_CustomException(response.getBody());   
                }                
            }
        }
        
        catch(exception e){
            
            throw e;

            
        }
        
    }
    
    
    
/**
* @description       : Class to return the required attribute for JWKToken
* @author            : Raja Arsalan
**/
    public class JWKSResult{
/**
* @description    : Property to get the accessToken
**/
        public String access_token { get; set; } 
/**
* @description    : Property to get the error_description
**/
        public String error_description { get; set; } 
/**
* @description    : Property to get the error
**/
        public String error { get; set; } 
        
    }
    
   
    

    
    
}