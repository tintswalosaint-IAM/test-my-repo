/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_CustomerList
@ Description       :Class for dealing with customer list API and sending the result to the main container and storing the values in the wrapper 
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/** 
* @description This for dealing with customer list API and sending the result to the main container and storing the values in the wrapper 
*/
public class AOB_CustomerList {
    private AOB_CustomerList(){}
    // HTTP Constants
    private static final String HTTP_METHOD = 'GET';
    private static final String PATH_CALLOUT = '/external-partners/customer-list';
    
    // Response status constants
    private static final String STATUS_SUCCESS = 'SUCCESS';
    private static final String STATUS_FAILED = 'FAILED';
    private static final String STATUS_NO_CONTENT = 'NO_CONTENT';
    
    // Using for test classes
    @testVisible
    private static Integer mockHttpStatusCode;
    @testVisible
    private static String mockHttpStatus;
    @testVisible
    private static String mockHttpBody = '';
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CustomerList');

    /** 
    * @description This method used for main callout that is AOB_CustomerList API 
    * @param leadList
    * @return Returns a callout response in map format for remaining processing
    */
    public static String invokeCustomerList(List<Lead> leadList) {
        if (leadList != null && !leadList.isEmpty()) {
            Map<String, Object> responseObject = invokeCustomerCheckBeforeProceed(leadList[0]);
            if (responseObject != null) {
                System.debug('response is ' + JSON.serialize(responseObject));
                return JSON.serialize(responseObject);
            }
        }
        return null;
    }

    /** 
    * @description This method used for main callout that is AOB_CustomerList API 
    * @param leadRecord
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> invokeCustomerCheckBeforeProceed(Lead leadRecord) {
        CustomerData customerData = new CustomerData(
            leadRecord.FirstName,
            leadRecord.LastName,
            leadRecord.AOB_Date_of_Birth__c,
            leadRecord.Id
        );
        return performCustomerCheck(customerData);
    }

    /** 
    * @description This method used for main callout that is AOB_CustomerList API 
    * @param appRecord
    * @return Returns a callout response in map format for remaining processing
    */
    public static Map<String, Object> invokeChildCustomerList(Application__c appRecord) {
        CustomerData customerData = new CustomerData(
            appRecord.AOB_FirstName__c,
            appRecord.AOB_LastName__c,
            appRecord.AOB_DOB__c,
            appRecord.Id
        );
        return performCustomerCheck(customerData);
    }

    /**
    * @description Common method to perform customer check API call
    * @param customerData Customer data wrapper
    * @return API response as Map
    */
    private static Map<String, Object> performCustomerCheck(CustomerData customerData) {
        try {
            String endpoint = buildEndpoint(customerData);
            HttpRequest httpRequest = AOB_API_Utils.getHeaders(endpoint, HTTP_METHOD);
            HttpResponse httpResponse = executeHttpRequest(httpRequest);
            
            return processHttpResponse(httpResponse, customerData);
        } catch (Exception ex) {
            LOGGER.error('AOB_CustomerList:Some Un-Handled Exception Occurred', ex);
            return createErrorResponse(STATUS_FAILED, null, ex.getMessage());
        }
    }

    /**
    * @description Builds the API endpoint URL with query parameters
    * @param customerData Customer data for URL parameters
    * @return Formatted endpoint URL
    */
    private static String buildEndpoint(CustomerData customerData) {
        String firstNameParam = customerData.firstName == null 
            ? '': EncodingUtil.urlEncode(customerData.firstName.toUpperCase(), 'UTF-8').replace('+', '%20') ;
        String lastNameParam = EncodingUtil.urlEncode(customerData.lastName.toUpperCase(), 'UTF-8').replace('+', '%20');
        String dobParam = Datetime.newInstance(customerData.dateOfBirth, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        
        return PATH_CALLOUT 
            + '?firstName=' + firstNameParam
            + '&lastName=' + lastNameParam 
            + '&dob=' + dobParam;
    }

    /**
    * @description Executes HTTP request with test mock support
    * @param httpRequest The HTTP request to execute
    * @return HTTP response
    */
    private static HttpResponse executeHttpRequest(HttpRequest httpRequest) {
        Http http = new Http();        
        if (System.Test.isRunningTest()&& mockHttpStatusCode != null && mockHttpStatus != null) {
                AOB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
        }
        
        return http.send(httpRequest);
    }

    /**
    * @description Processes HTTP response and returns formatted response
    * @param httpResponse The HTTP response to process
    * @param customerData Customer data for error messages
    * @return Processed response as Map
    */
    private static Map<String, Object> processHttpResponse(HttpResponse httpResponse, CustomerData customerData) {
        if (httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
            return processSuccessResponse(httpResponse, customerData);
        } else {
            return processErrorResponse(httpResponse, customerData);
        }
    }

    /**
    * @description Processes successful HTTP response (200 OK)
    * @param httpResponse The successful HTTP response
    * @param customerData Customer data for error messages
    * @return Processed success response
    */
    private static Map<String, Object> processSuccessResponse(HttpResponse httpResponse, CustomerData customerData) {
        String responseBody = httpResponse.getBody();
        
        if (String.isBlank(responseBody)) {
            LOGGER.error('AOB_CustomerList.processSuccessResponse', 
                new String[] {'AOB_CustomerList.processSuccessResponse', customerData.recordId});
            return createErrorResponse(STATUS_NO_CONTENT, 204, 'No response body');
        }
        
        AOB_CustomerListBean responseObject = (AOB_CustomerListBean) JSON.deserialize(responseBody, AOB_CustomerListBean.class);
        
        if (hasValidCustomer(responseObject)) {
            Map<String, Object> failedResponse = createErrorResponse(STATUS_FAILED, 200, 'Hello ' + customerData.lastName);
            failedResponse.put('customerId', responseObject.customers[0].uuid);
            return failedResponse;
        } else {
            return createSuccessResponse(STATUS_SUCCESS, 200);
        }
    }

    /**
    * @description Processes error HTTP response (non-200)
    * @param httpResponse The error HTTP response
    * @param customerData Customer data for error messages
    * @return Processed error response
    */
    private static Map<String, Object> processErrorResponse(HttpResponse httpResponse, CustomerData customerData) {
        String errorMessage = 'No Response From Server';
        String responseBody = httpResponse.getBody();
        
        if (String.isNotBlank(responseBody)) {
            try {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                errorMessage = (String) responseObject.get('moreInformation');
            } catch (Exception ex) {
                LOGGER.error('AOB_CustomerList.processErrorResponse: Error parsing response body', ex);
            }
        }
        
        LOGGER.error('AOB_CustomerList.processErrorResponse', 
            new String[] {errorMessage, customerData.recordId});
        
        return createErrorResponse(STATUS_FAILED, httpResponse.getStatusCode(), errorMessage);
    }

    /**
    * @description Checks if response contains valid customer data
    * @param responseObject Parsed response object
    * @return True if valid customer found
    */
    private static Boolean hasValidCustomer(AOB_CustomerListBean responseObject) {
        return responseObject != null 
            && responseObject.customers != null 
            && !responseObject.customers.isEmpty() 
            && responseObject.customers[0].uuid != null;
    }

    /**
    * @description Creates success response map
    * @param status Status string
    * @param statusCode HTTP status code
    * @return Success response map
    */
    private static Map<String, Object> createSuccessResponse(String status, Integer statusCode) {
        return new Map<String, Object>{
            'status' => status,
            'statusCode' => statusCode
        };
    }

    /**
    * @description Creates error response map
    * @param status Status string
    * @param statusCode HTTP status code
    * @param errorDescription Error description
    * @return Error response map
    */
    private static Map<String, Object> createErrorResponse(String status, Integer statusCode, String errorDescription) {
        Map<String, Object> response = new Map<String, Object>{
            'status' => status,
            'ErrorDescription' => errorDescription
        };
        
        if (statusCode != null) {
            response.put('statusCode', statusCode);
        }
        
        return response;
    }

    /**
    * @description Inner class to hold customer data
    */
    private class CustomerData {
        public String firstName;
        public String lastName;
        public Date dateOfBirth;
        public String recordId;

        public CustomerData(String firstName, String lastName, Date dateOfBirth, String recordId) {
            this.firstName = firstName;
            this.lastName = lastName;
            this.dateOfBirth = dateOfBirth;
            this.recordId = recordId;
        }
    }
}