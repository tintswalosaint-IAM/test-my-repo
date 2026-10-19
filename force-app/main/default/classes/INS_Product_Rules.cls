/**
 * @description  Sends a GET request to the INS_Product_Rules API endpoint with the provided Request.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param Request containing applicant details.
 * @return HttpResponse object containing the response from the API.
 * @date Nov 07th 2023
 */
public class INS_Product_Rules {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Product_Rules');
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_COUNTRY = 'x-iam-country';
    private static final String CLIENT_COUNTRY_SA = 'SA';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_GET = 'GET';

    /**
     * @description Invocable method to execute  for the provided requestDetails.
     *
     * @param requestDetails
     * @return List of INS_Product_Rules.Response  containing API response.
     */
    @InvocableMethod(Label = 'ProductRules' Description = 'Use this method to get the Product Rules' Category = 'Product')
    public static List<Response> execute(List<Request> requestDetails) {
        try {
            List<Response> responseList = new List<Response> ();
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:INSProductRules'+'/'+ requestDetails[0].prodId);
            request.setMethod(HTTP_METHOD_GET);
            request.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            request.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            request.setTimeout(120000);
            request.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
            request.setHeader(HEADER_CLIENT_COUNTRY, CLIENT_COUNTRY_SA);
            
            request.setHeader('x-ibm-client-id', '{!$Credential.INSProductRulesExternal.Client_Id}');
            request.setHeader('x-ibm-client-secret', '{!$Credential.INSProductRulesExternal.Client_Secret}');
            
            HttpResponse response = http.send(request);
             
            if (response.getStatusCode() == 200) {
                // Handle successful response
                String jsonPayload = response.getBody().replace('"default":', '"default_g":');
                System.debug('jsonPayload=='+JSON.serializePretty(jsonPayload));
                NewProductWrapper wrapper = (NewProductWrapper) JSON.deserialize( jsonPayload, NewProductWrapper.class);
                Response responses = new Response();
                responses.isSuccess = true;
                responses.jsonResponse = jsonPayload;

                for(NewProductWrapper.ProductSections sectionWrap: wrapper.sections){
                    if(sectionWrap.Name=='MainInsured'){
                        responses.mainInsuredMaxVal = sectionWrap.maxValue;
                        responses.mainInsuredMinVal = sectionWrap.minValue;

                        for(NewProductWrapper.ProductItems prodItemWrap : sectionWrap.productItems) {
                            for(NewProductWrapper.ChildItems childItemWrap : prodItemWrap.childItems) {
                                switch on childItemWrap.name.deleteWhitespace() {
                                    when 'CateringBenefit' {
                                        responses.cateringMaxVal = childItemWrap.maxValue;
                                        responses.cateringMinVal = childItemWrap.minValue;
                                    }
                                    when 'TombstoneBenefit','MemorialBenefit' {
                                        responses.tombstoneMaxVal = childItemWrap.maxValue;
                                        responses.tombstoneMinVal = childItemWrap.minValue;
                                    }
                                    when 'ShoppingBenefit','GroceryBenefit' {
                                        responses.shoppingMaxVal = childItemWrap.maxValue;
                                        responses.shoppingMinVal = childItemWrap.minValue;
                                    }
                                    when 'Transport','RepatriationBenefit' {
                                        responses.transportMaxVal = childItemWrap.maxValue;
                                        responses.transportMinVal = childItemWrap.minValue;
                                    }
                                    when 'RadioAnnouncement','AirtimeBenefit' {
                                        responses.radioMaxVal = childItemWrap.maxValue;
                                        responses.radioMinVal = childItemWrap.minValue;
                                    }
                                }
                            }
                        }
                    }
                }
                responseList.add(responses);
            } else {
                //Log and Throw error response for debugging purposes
              LOGGER.error('INS_Product_Rules.execute: No response body', new String[] {'INS_Product_Rules.execute', response.getBody()});
              throw new INS_CustomException(response.getBody());
            }
            System.debug('responseList=='+JSON.serializePretty(responseList));
            return responseList;
        }
        catch(Exception ex) {
            //Log and Throw error response for debugging purposes
            LOGGER.error('INS_Product_Rules.execute', ex);
            //exclude of test classes
            if (!Test.isrunningtest()) {
                throw new INS_CustomException(ex);
            }
            else {
                return null;
            }
        }
    }


    /**
     * @description Request
     * @param ProductId.
     * @return .
     */
    public class Request {
        @InvocableVariable(label='ProductId' description='ProductId')
        public String prodId;
   }

    /**
     * @description Response
     * @param .
    * @return Response.
    */
    public class Response {
        @InvocableVariable
        public Boolean isSuccess;
        @InvocableVariable
        public Integer mainInsuredMaxVal;
        @InvocableVariable
        public Integer mainInsuredMinVal;
        @InvocableVariable
        public Integer cateringMaxVal;
        @InvocableVariable
        public Integer cateringMinVal;
        @InvocableVariable
        public Integer shoppingMaxVal;
        @InvocableVariable
        public Integer shoppingMinVal;
        @InvocableVariable
        public Integer tombstoneMaxVal;
        @InvocableVariable
        public Integer tombstoneMinVal;
        @InvocableVariable
        public Integer transportMaxVal;
        @InvocableVariable
        public Integer transportMinVal;
        @InvocableVariable
        public Integer radioMaxVal;
        @InvocableVariable
        public Integer radioMinVal;
        @InvocableVariable
        public String jsonResponse;
    }

    /**
     * @description class  BaseException implements Exception class
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     *
     * @date Nov 07th 2023
     */
    public virtual class BaseException extends Exception {}

    /**
     * @description class  CustomException implements BaseException class
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     *
     * @date Nov 07th 2023
     */
    public class CustomException extends BaseException {}
}