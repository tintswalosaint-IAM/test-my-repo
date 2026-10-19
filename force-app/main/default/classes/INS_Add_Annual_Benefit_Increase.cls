/**
 * @description      : Class for add annual benefit increase to the quote
 * @author           : Shams Ul Arifeen
 * @date             : October 2023
 */
public with sharing class INS_Add_Annual_Benefit_Increase{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Add_Annual_Benefit_Increase');

    /**
     * @description       : Invokable method called from a flow (INS_Quick_Quote_Application) add annual benefit increase to the quote.
     * @author            : Shams Ul Arifeen
     * @param requests List of AnnualBenefitIncreaseWrapper objects containing the request details.
     **/
    @InvocableMethod(label = 'Add Annual Benefit Increase')
    public static void addAnnualBenefitIncrease(List < AnunualBenefitIncreaseWrapper > requests){

        // Create the request payload using INS_Quick_Quote_Wrapper
        INS_Quick_Quote_Wrapper.AnnualBenefitIncreasePayload payload = new INS_Quick_Quote_Wrapper.AnnualBenefitIncreasePayload();

        payload.referenceNumber = requests[0].quoteNumber;
        payload.annualBenefitIncrease = Decimal.valueOf(requests[0].anunualBenefitIncrease);

        // Serialize the payload to JSON
        String payloadJson = JSON.serialize(payload);
        try{
            // Get OAuth access token from OAuthHelper class
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            // Create HTTP request
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes/' + requests[0].quoteNumber + '/abi');
            httpRequest.setMethod(INS_Quote_Helper.HTTP_METHOD_PUT);
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
            if (response.getStatusCode() != 200){throw new INS_CustomException(response.getBody());
            }
        } catch (Exception ex){
            //Handle error (log and throw an error to UI )
            LOGGER.error('INS_Add_Annual_Benefit_Increase.addAnnualBenefitIncrease', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }

    /**
     * @description       : Wrapper Class to pass in the addAnnualBenefitIncrease.
     * @author            : Shams Ul Arifeen
     **/
    public class AnunualBenefitIncreaseWrapper{
        @InvocableVariable(label = 'Quote Number')
        public String quoteNumber;
        @InvocableVariable(label = 'Annual Benefit Increase')
        public String anunualBenefitIncrease;
    }
}