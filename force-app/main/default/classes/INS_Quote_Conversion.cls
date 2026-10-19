/**
 * @description   Sends a POST request to the Quote Conversion API endpoint with the provided applicant details.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param requestDetails containing applicant details.
 * @return HttpResponse object containing the response from the API.
 * @date Nov 07th 2023
 */
public class INS_Quote_Conversion {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Quote_Conversion');
	private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_COUNTRY = 'x-iam-country';
    private static final String CLIENT_COUNTRY_SA = 'SA';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    /**
 * @description class  BaseException implements Exception class
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
    public virtual class BaseException extends Exception{}
    /**
 * @description class  CustomException implements BaseException class
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
    public class CustomException extends BaseException{}
    
    /**
     * @description Obtains the Request  for API.
     *
     * @return.
     */
    public class Request {
        @InvocableVariable(label='quoteNumber' description='quoteNumber' required=true)
        public String quoteNumber;
        @InvocableVariable(label='otp' description='otp' required=true)
        public String otp;
    }
     /**
     * @description Obtains the Response  from API Response.
     *
     * @return Boolean representing the Response class.
     */
    public class Response{
        @InvocableVariable
        public Boolean isSuccess;
        @InvocableVariable
        public String policyNumber;
        @InvocableVariable
        public String referenceNumber;
        
    }
     /**
     * @description Invocable method to quoteConversion  for the provided applicants.
     *
     * @param requestDetails
     * @return List<Response>
     */
    
    @InvocableMethod( Label = 'Quote Conversion' Description = 'Quote Conversion' )
    public static List<Response> quoteConversion(List<Request> requestDetails){
        try{
           
            List<Response> responseList = new List<Response> ();
            Request req = requestDetails[0];
            QuoteconversionRequestWrapper wrap = new QuoteconversionRequestWrapper();
            wrap.promoCode = 'tosvug'; // API looking some value
            wrap.campaignCode = 'jisotihupa'; // API looking some value
            wrap.consultantCode = [Select id,EmployeeNumber from User where id=:userInfo.getUserID()].EmployeeNumber;
            wrap.otpNumber = req.otp;
            wrap.quoteNumber = req.quoteNumber;
            wrap.otpDate = String.valueOf(system.now());
            wrap.referenceNumber = req.quoteNumber;
            wrap.channel = 'Salesforce';
            
            String payloadJson = JSON.serialize(wrap);
            String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes/conversion');
            request.setMethod(HTTP_METHOD_POST);
            request.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            request.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
			request.setTimeout(60000);						  
            request.setHeader(HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + accessToken);
            request.setHeader(HEADER_CLIENT_COUNTRY, CLIENT_COUNTRY_SA);
          	request.setBody(payloadJson);
             Http http = new Http();
            // Send HTTP request
             system.debug('request'+ request.getBody());
            HttpResponse response = http.send(request);
             system.debug('response'+ response.getBody());
            // Handle response based on status code
            if (response.getStatusCode() == 200) {
                // Handle successful response               
                QuoteconversionResponseWrapper wrapper = (QuoteconversionResponseWrapper) JSON.deserialize( response.getBody(), QuoteconversionResponseWrapper.class);//use this to fetch value from response 
                Response responses = new Response();
                if(wrapper.referenceNumber != null & wrapper.validationResult.isValid)
                {
                    responses.isSuccess = true;
                    responses.policyNumber = wrapper.PolicyNumber;
                    responses.referenceNumber = wrapper.referenceNumber;
                    responseList.add(responses);
                }
                else
                {
                   //Log and Throw error response for debugging purposes
                    throw new INS_CustomException(wrapper.validationResult.validationMessages[0]);
				
                }
            } else {
                // Log and Throw error response for debugging purposes
                throw new INS_CustomException(response.getBody());
				
            }
            return  responseList;       
        }
        Catch(Exception ex){
            // Log and Throw error response for debugging purposes
            LOGGER.error('INS_Quote_Conversion.quoteConversion', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }
}