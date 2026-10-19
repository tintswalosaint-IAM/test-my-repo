/**
 * @description             : API class for creating quote
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 *                          
 */
public with sharing class INS_API_QuoteBenefits extends sbgplatform.ApiService{
	private static final String NAMED_CREDENTIAL = 'KYC_MulesoftConnect_NC';
    private static final String EC_NAME = 'KYC_MulesoftConnect_ENC';
    @TestVisible
    private static String testAccessToken;
    private static Map<String, Generic_Config__mdt> configMap = Generic_Config__mdt.getAll();
    private static final String REQUEST_ENV = configMap.get('FuneralClaims_ENV').Value__c;
    public INS_API_QuoteBenefits() {
         super(NAMED_CREDENTIAL);
    }
    
    /**
     * @description Framework extension point. Attaches RealPay IBM-gateway headers (client_id /
     *   client_secret / org_client_id via EC `INS_API_QuoteCreation*` merge fields) + Bearer + product/channel/
     *   transaction headers. Same pattern as INS_API_InitiatePush + INS_Funeral_Claims.
     */
    public override HttpRequest prepareHttpRequest(String path, String method, Object requestBody, String contentType) {
        HttpRequest req = super.prepareHttpRequest(path, method, requestBody, contentType);
        req.setHeader('business_unit', 'Liberty'); 
        req.setHeader('Authorization', 'Bearer ' + getAccessTokenForRequest());        
        req.setHeader('client_id', '{!$Credential.' + EC_NAME + '.Kyc_client_id}'); 
        req.setHeader('org_client_id', 'Dev_Testing');
        req.setHeader('country_code', INS_Quote_Helper.CLIENT_COUNTRY_KE);        
        req.setHeader('channel', 'salesforce');
        req.setHeader('transaction_id', generateTransactionId());
        req.setHeader('accept', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);
        req.setHeader('content-type', sbgplatform.ApiService.CONTENT_TYPE_APPLICATION_JSON);

        return req;
    }

    @TestVisible
    private static String getAccessTokenForRequest() {
        return String.isNotBlank(testAccessToken) ? testAccessToken : KYC_SRV_GenerateAccessToken.getAccessToken();
    }
    
    private static String generateTransactionId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.substring(0, 8) + '-' + h.substring(8, 12) + '-' + h.substring(12, 16) +
            '-' + h.substring(16, 20) + '-' + h.substring(20);
    }
    
     public  String putQuoteBenefits(String JSONrequestPayload, String quoteId) { 
        String path = '/' +REQUEST_ENV +'-sbg-exp-insurance-lifequote-legacy-api/api/quotes/'+quoteId+'/benefits';   
        
        return (String) this.put(path, JSONrequestPayload);
    }
}