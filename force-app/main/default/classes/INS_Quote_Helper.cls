/**
 * @description      : Helper Class for Strings, constants and common method for INS classes
 * @author           : Shams Ul Arifeen
 * @date             : Jan 2024
 */
public with sharing class INS_Quote_Helper {
 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Quote_Helper');
 
    //Constant for HTTP Headers
    public static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    public static final String HEADER_ACCEPT = 'accept';
    public static final String HEADER_CONTENT_TYPE = 'content-type';
    public static final String HEADER_CLIENT_COUNTRY = 'x-iam-country';
    public static final String CLIENT_COUNTRY_SA = 'SA';
    public static final String CLIENT_COUNTRY_ZA = 'ZA';
    public static final String CLIENT_COUNTRY_KE = 'KE';
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    public static final String HTTP_METHOD_GET = 'GET';
    public static final String HTTP_METHOD_PUT = 'PUT';
    public static final String HTTP_METHOD_POST = 'POST';
    public static final String HTTP_METHOD_PATCH = 'PATCH';
    public static final String X_FAPI_INTERACTION_ID = 'x-fapi-interaction-id';
    public static final String X_CLIENT_CERTIFICATE = 'X-Client-Certificate';
 
    public static final String ORG_CLIENT_ID = 'org_client_id';
    public static final String COUNTRY_CODE = 'country_code';
    public static final String TRANSACTION_ID = 'transaction_id';
    public static final String CLIENT_ID = 'client_id';
    public static final String CLIENTSECRET = 'client_secret';
   
   
 
    //Public Strings
    public static string quoteNumber = 'quoteNumber';
    public static string accessTokenTypeQuote = 'Quote';
    public static string accessTokenTypeCustomer = 'Customer Verification';
    public static string failed = 'failed';
    public static String salesforce = 'salesforce';
    public static String confirmation = 'Confirmation';
 
 
   
    //Helper Methods
 
    /**
     * @description       : Helper method to create a QuoteBenefit object for a specific benefit type
     * @author            : Shams Ul Arifeen
 
     * lastModifiedby     : Vic Wafula
     * lastModifiedDate   : 09/10/2026
     * description        : SFP-51404 Add Premium Frequency
     * @param premiumFrequency
     * @param benefitType
     * @param benefitAmount
     * @param memberId
     * @return            : INS_Quick_Quote_Wrapper.QuoteBenefit
     **/
    public static INS_Quick_Quote_Wrapper.QuoteBenefit createBenefit(String benefitType, Double benefitAmount, string memberId, String premiumFrequency){
        INS_Quick_Quote_Wrapper.QuoteBenefit benefit = new INS_Quick_Quote_Wrapper.QuoteBenefit();
        benefit.benefitId = '';
        benefit.benefitType = benefitType.substringAfter('.');
        benefit.benefitAmountValue = (benefitAmount != null) ? benefitAmount : 0;
        benefit.benefitKey = benefitType;
        benefit.personId = '';
        benefit.benefitFee = 0.0;
        benefit.benefitFrequencyValue = premiumFrequency;
        benefit.memberId = memberId;
        return benefit;
    }
 
    /**
     * @description       : Helper method to create a QuoteBenefit object for a specific benefit type for Quote Member
     * @author            : Shams Ul Arifeen
     * @param benefitType
     * @param benefitAmount
     * @param benefitId
     * @return            : INS_Quick_Quote_Wrapper.MemberBenefit
     **/
    public static INS_Quick_Quote_Wrapper.MemberBenefit createMemberBenefit(String benefitType, Decimal benefitAmount, string benefitId, String premiumFrequency){
        INS_Quick_Quote_Wrapper.MemberBenefit benefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
        benefit.benefitId = (benefit != null) ? benefitId : '';
        benefit.benefitType = benefitType.substringAfter('.');
        benefit.benefitAmountValue = (benefitAmount != null) ? benefitAmount : 0;
        benefit.benefitKey = benefitType;
        benefit.prefix = 'R';
        benefit.premiumType = 'NORMALPREMIUM';
        benefit.benefitFee = 0.0;
        benefit.benefitFrequencyValue = premiumFrequency;
        return benefit;
    }
 
    /**
     * @description       : Obtains the OAuth access token for making API requests.
     * @author            : Shams Ul Arifeen
     * @return            : String
     **/
    public static String getAccessToken(String accessTokenType){
        // Create HTTP request for OAuth token
        HttpRequest request = new HttpRequest();
       
        If(accessTokenType == 'Quote'){
            request.setEndpoint('callout:Standard_Bank_OAuth');
            request.setMethod(INS_Quote_Helper.HTTP_METHOD_POST);
            request.setBody('grant_type=client_credentials&scope=quote');
        }else if(accessTokenType == 'Customer Verification'){
            request.setEndpoint('callout:INS_Customer_Verification_Access_Token');
            request.setMethod(INS_Quote_Helper.HTTP_METHOD_GET);
            // Set request body with multiple scopes (customer and prod)
            request.setBody('grant_type=client_credentials&scope=customer prod');
        }else if(accessTokenType == 'OTP'){
            request.setEndpoint('callout:INS_Generate_and_Validate_OTP/ug/oauth2/token');
            request.setMethod('POST');
            request.setHeader('X-IBM-Client-Id', '{!$Credential.INS_Generate_OTP.Client_Id}');
            request.setHeader('x-ibm-client-secret', '{!$Credential.INS_Generate_OTP.Client_Secret}');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody('grant_type=client_credentials');
        }
   
        try{
            // Send HTTP request
            Http http = new Http();
            HttpResponse response = http.send(request);
           
            // Handle response
            if (response.getStatusCode() == 200) {
                // Handle successful response
                INS_CalloutResults calloutResults = (INS_CalloutResults)JSON.deserialize(response.getBody(), INS_CalloutResults.class);
                return calloutResults.access_token;
            } else {
                throw new INS_CustomException('Error: ' + response.getBody());
            }
        } catch (Exception ex){
            LOGGER.error('INS_Create_Quick_Quote.getAccessToken', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }
 
    /**
    * @description       : Class to set returned Access Token
    * @author            : Shams Ul Arifeen
    * @group             : Cloudsmiths
    **/
    public class INS_CalloutResults{
        /**
         * @description : accessToken getter setter
         */
            public String access_token { get; set; }
        }
}