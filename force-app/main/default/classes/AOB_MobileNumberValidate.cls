/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_MobileNumberValidate
@ Description       :Class for dealing with Mobile number validate api and sending the result to the main container and storing the values in the wrapper 
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
public class AOB_MobileNumberValidate {
    private AOB_MobileNumberValidate(){}
    // HTTP Constants
    private static final String HTTP_METHOD = 'POST';
    private static final String PATH_CALLOUT = '/mobile-number/validation';
    // Used for test classes
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_MobileNumberValidate');
    public static responseWrapper response;
    /**
     * @description invoke mobile number validation
     * @param applicationList
     * @return String
     */
    public static String invokeMobileNumberCallout(List<Application__c> applicationList) {
        if (applicationList == null || applicationList.isEmpty()) {
            throw new AuraHandledException('application is null');
        }
        Map<String, Object> responseObject = makeMobileMoneyVerifyCallout(applicationList.get(0));
        if (responseObject != null) {
            return JSON.serialize(responseObject);
        }
        
        return null; 
    }
    
    /**
     * @description invoke mobile number validation
     * @param applicationRecord
     * @return String
     */    
    public static Map<String, Object> makeMobileMoneyVerifyCallout(Application__c applicationRecord) {
        Map<String,Object> mData = new AOB_SEL_CustomMetaDataType().getMetadataByType('AOB_MobileNumberValidate');
        AOB_MobileNumberValidateBean mobileNumberValidateBeanRecord = new AOB_MobileNumberValidateBean();
        AOB_MobileNumberValidateBean.PayLoad payload = new AOB_MobileNumberValidateBean.PayLoad();
        AOB_MobileNumberValidateBean.RequestData requestData = new AOB_MobileNumberValidateBean.RequestData();
        AOB_MobileNumberValidateBean.ValidateCustomer validateCustomer = new AOB_MobileNumberValidateBean.ValidateCustomer();
        AOB_MobileNumberValidateBean.Body body = new AOB_MobileNumberValidateBean.Body();
        payload.area = string.valueOf(mData.get('payload.area'))??'';
        payload.CustomerRef = '256' + applicationRecord.AOB_Phone__c;
        String serviceCode = string.valueOf(mData.get('serviceCode'))??'';
        String mobileNumSeries = String.valueOf(mData.get('mobileNumSeries')) ?? '';
        Set<String> mobileCodeMTNSet = new Set<String>(
            mobileNumSeries.split(',')
        );

        if (mobileCodeMTNSet.contains(applicationRecord.AOB_Phone__c.substring(0, 2))) {
            serviceCode = String.valueOf(mData.get('serviceCodeMTN')) ?? '';
        }

        payload.ServiceCode = serviceCode; 
        requestData.PayLoad = payload;
        validateCustomer.requestData = requestData;
        body.ValidateCustomer = validateCustomer;
        mobileNumberValidateBeanRecord.Body = body;

        HttpRequest httpRequest = AOB_API_Utils.getHeaders(PATH_CALLOUT, HTTP_METHOD);
        httpRequest.setBody(JSON.serialize(mobileNumberValidateBeanRecord));

        // Make HTTP Request
        try {
            Http http = new Http();
            HttpResponse httpResponse = new HttpResponse();

            if (System.Test.isRunningTest()&& mockHttpStatusCode != null && mockHttpStatus != null) {
                    AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpbody);
            }

            httpResponse = http.Send(httpRequest);

            if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                String responseBody = httpResponse.getBody();
                if (String.isBlank(responseBody)) {
                    LOGGER.error('AOB_MobileNumberValidate.makeMobileMoneyVerifyCallout: No response body', new String[] {'AOB_MobileNumberValidate.makeMobileMoneyVerifyCallout', applicationRecord.Id});
                    return handleNoContentResponse();
                }
                response = (responseWrapper) JSON.deserialize(responseBody, responseWrapper.class);
                if(response.body.validateCustomerResponse.validateCustomerResult.details.status.statusCode == '0'){
                    String customerName =response.body.validateCustomerResponse.validateCustomerResult.details.resultz.customerName;
                    // Now you have the customer name
                    return new Map<String, Object>{
                        'status' => 'SUCCESS',
                        'statusCode' =>response.body.validateCustomerResponse.validateCustomerResult.details.status.statusCode,
                        'CustomerName' => customerName,
                        'Description'=>response.body.validateCustomerResponse.validateCustomerResult.details.status.description
                    };
                }else {
                    return handleFailedResponse(httpResponse, applicationRecord.Id);
                }
            } else {
                return handleFailedResponse(httpResponse, applicationRecord.Id);
            }
        } catch (Exception ex) {
            LOGGER.error('AOB_MobileNumberValidate.makeMobileMoneyVerifyCallout', ex);
            return new Map<String, Object>{
                'status' => 'FAILED',
                'ErrorDescription' => ex.getMessage()
            };
        }
    }
    /**
     * @description invoke handle Failed Response method
     * @param httpResponse
     * @param applicationRecord
     * @return Map<String, Object>
     */  
    private static Map<String, Object> handleFailedResponse(HttpResponse httpResponse, String applicationRecordId) {
        String errorMessage = response.body.validateCustomerResponse.validateCustomerResult.details.status.description;
       if (httpResponse.getStatusCode() != CMN_API_HttpBase.HTTP_OK) {
            Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            errorMessage = (String) responseObject.get('moreInformation');
        }

        LOGGER.error('AOB_MobileNumberValidate.makeMobilMoneyVerifyCallout', new String[] {errorMessage, applicationRecordId});

        return new Map<String, Object>{
            'status' => 'FAILED',
            'statusCode' => response.body.validateCustomerResponse.validateCustomerResult.details.status.statusCode,
            'ErrorDescription' => errorMessage,
            'CustomerName' =>  response.body.validateCustomerResponse.validateCustomerResult.details.resultz.customerName
        };
    }

    /**
     * @description invoke  handle No Content Response
     * @return Map<String, Object>
     */  
    private static Map<String, Object> handleNoContentResponse() {
        return new Map<String, Object>{
            'status' => 'NO_CONTENT',
            'statusCode' => 204,
            'ErrorDescription' => 'No response body'
        };
    }

    /**
     * @description Wrapper class to parse the resppnse
     */ 
    public class ResponseWrapper {
        // Represents the body of the response
        public Body body;
    }
    
    class Body {
        // Contains the response data after validating a customer
        public ValidateCustomerResponse validateCustomerResponse;
    }
    
    class ValidateCustomerResponse {
        // Represents the result of the customer validation process
        public ValidateCustomerResult validateCustomerResult;
    }
    
    class ValidateCustomerResult {
        // Holds detailed information about the validation result
        public Details details;
    }
    
    class Details {
        // Contains the status code and description of the validation result
        public Status status;
        // Holds specific details about the validated customer
        public Resultz resultz;
    }
    
    class Status {
        // Status code of the validation result
        public String statusCode; 
        // Description of the status
        public String description; 
    }
    
    class Resultz {
        // Reference of the customer
        public String customerReference; 
        // Area of the customer
        public String area; 
        // Status code of the customer
        public String statusCode; 
        // Description of the status
        public String statusDescription; 
        // Name of the customer
        public String customerName; 
        // Taxpayer identification number of the customer
        public String tin; 
        // Type of customer
        public String customerType; 
        // Outstanding balance of the customer
        public String outstandingBalance; 
    }
    
}