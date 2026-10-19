/**
 * @description      : Class for adding cash back benefit to the quote
 * @author           : Shams Arifeen
 * @date             : April 2025
 */
public with sharing class INS_Cash_Back_Benefit {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Cash_Back_Benefit');

    /**
     * @description       : Invokable method called from a flow (INS_Quick_Quote_Application) to add cash back benefit to the quote.
     * @param requests    : List of AnnualBenefitIncreaseWrapper objects containing the request details.
     * @return           : Returns the cash back premium value if the operation is successful.
     */
    @InvocableMethod(label = 'Cash Back Benefit')
    public static List<Decimal> addCashBackBenefit(List<CashBackBenefitWrapper> requests) {
        List<Decimal> results = new List<Decimal>();
        
        // Create the request payload using INS_Quick_Quote_Wrapper
        INS_Quick_Quote_Wrapper.CashBackBenefitPayload payload = new INS_Quick_Quote_Wrapper.CashBackBenefitPayload();
        payload.referenceNumber = requests[0].referenceNumber;
        payload.cashBackBenefit = requests[0].cashBackBenefit;

        // Serialize the payload to JSON
        String payloadJson = JSON.serialize(payload);
        
        try {
            // Get OAuth access token from OAuthHelper class
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            
            // Create HTTP request
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:INS_Quote_Named_Credentials' + '/life-quoting/quotes/cashBack');
            httpRequest.setMethod(INS_Quote_Helper.HTTP_METHOD_POST);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setTimeout(60000);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_AUTHORIZATION, INS_Quote_Helper.AUTHORIZATION_TYPE_BEARER + accessToken);
            httpRequest.setHeader(INS_Quote_Helper.HEADER_CLIENT_COUNTRY, INS_Quote_Helper.CLIENT_COUNTRY_SA);
            httpRequest.setBody(payloadJson);
            
            // Send HTTP request
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            // Handle response
            if (response.getStatusCode() == 200) {
                // Extract and return the cashBackPremium value
                Decimal cashBackPremium = handleSuccessfulResponse(response);
                results.add(cashBackPremium);
                return results;
            } else {
                // Handle non-200 responses
                throw new INS_CustomException(response.getBody());
            }
        } catch (Exception ex) {
            //Handle error (log and throw an error to UI )
            LOGGER.error('INS_Cash_Back_Benefit.addCashBackBenefit', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }

    /**
    * @description Handles the Response of Cash Back Benefit API
    * @param response
    * @return Decimal
    **/ 
    public static Decimal handleSuccessfulResponse(HttpResponse response){
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Decimal cashBackPremium = 0;
        if (responseData.containsKey('quoteHeader')) {
            Map<String, Object> quoteHeader = (Map<String, Object>)responseData.get('quoteHeader');
            cashBackPremium = (Decimal)quoteHeader.get('cashBackPremium');
        }
        return cashBackPremium;
    }

    /**
     * @description       : Wrapper Class to pass parameters to the addCashBackBenefit method.
     * @author            : Shams Arifeen
     */
    public class CashBackBenefitWrapper {
        @InvocableVariable(label = 'Quote Number' description = 'The reference number of the quote' required=true)
        public String referenceNumber;
        
        @InvocableVariable(label = 'Cash Back Benefit' description = 'Boolean flag indicating whether cash back benefit should be applied' required=true)
        public Boolean cashBackBenefit;
    }
}