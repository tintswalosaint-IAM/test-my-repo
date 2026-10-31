/**
 * @description       : Handles quote recalculation by calling the
 *                      Quick Quote Benefits service.
 * @author            : Irshad
 * @created on        : 03-25-2026
 * @user story        : SFP-55636
 * @last modified by  : Irshad
 */
public with sharing class INS_CTRL_RecalculateBenefits {

    private static final Integer HTTP_STATUS_OK = 200;
    private static final Integer HTTP_STATUS_CREATED = 201;
    private static final String STATUS_SUCCESS = 'Success';
    private static final String KEY_VALIDATION_RESULT ='ValidationResult';
    private static final String KEY_RESULT_STATUS = 'ResultStatus';
    private static final String KEY_MESSAGE =  'Message';
    private static final String KEY_BENEFITS = 'benefits';
    private static final String RESPONSE_HAS_ERROR = 'hasError';
    private static final String RESPONSE_BENEFITS ='ReCalculateBenefits';
    private static final String RESPONSE_ERROR ='ReCalculateBenefitsError';

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_RecalculateBenefits');
    

    @TestVisible
    private static String testResponseBody;

    @TestVisible
    private static Integer testStatusCode;

    /**
     * @description Recalculates the quote benefits.
     * @param quoteId Quote reference number.
     * @param input Quote and benefit information.
     * @return Serialized success or error response.
     */
    @AuraEnabled
    public static String recalculateQuote(
        String quoteId,
        Map<String, Object> input
    ) {
        try {
            validateRequest(quoteId, input);

            String payloadJson =
                INS_CTRL_QuoteBenefitsRequestBuilder.buildRequest(
                    quoteId,
                    input
                );

            ServiceResponse serviceResponse =
                executeQuoteBenefitsCallout(
                    payloadJson,
                    quoteId
                );

            return processServiceResponse(serviceResponse);

        } catch (Exception exceptionValue) {
            throw new AuraHandledException(
                'Unable to recalculate quote benefits: ' +
                exceptionValue.getMessage()
            );
        }
    }

    /**
     * @description Generates the request payload for the Quote Benefits API.
     * @param quoteId Quote reference number.
     * @param input Quote and benefit information.
     * @return Serialized request payload.
     */
    @AuraEnabled
    public static String generateQuickQuoteBenefitsRequest(
        String quoteId,
        Map<String, Object> input
    ) {
        try {
            validateRequest(quoteId, input);

            return INS_CTRL_QuoteBenefitsRequestBuilder.buildRequest(
                quoteId,
                input
            );

        } catch (Exception exceptionValue) {
            LOGGER.error(
                'INS_CTRL_RecalculateBenefits.' +
                'generateQuickQuoteBenefitsRequest',
                exceptionValue
            );

            throw new AuraHandledException(
                'Unable to generate Quote Benefits request: ' +
                exceptionValue.getMessage()
            );
        }
    }

    /**
     * @description Validates controller input.
     */
    private static void validateRequest(
        String quoteId,
        Map<String, Object> input
    ) {
        if (String.isBlank(quoteId)) {
            throw new IllegalArgumentException(
                'Quote Id is required.'
            );
        }        
        String accountId = (String)input.get('ProspectAccountId');
        
        if (input == null) {
            throw new IllegalArgumentException(
                'Input is required.'
            );
        }else{          
           
                       
            if (String.isBlank(accountId)) {
                throw unauthorised();
            }
            
            List<Quote> quoteList;
            quoteList = new SEL_Quote().guestUserQuoteInProgressByAccIds(new List<Id>{ accountId });
           
            if (quoteList.isEmpty()) {                
                throw unauthorised();
            }

            Boolean matched = false;
            for (Quote q : quoteList) {
                if (quoteId == q.UnderwriterQuoteReferenceNumber__c) {
                    matched = true;
                    break;
                }
            }
            if (!matched) {
                throw unauthorised();
            }
            
        }
    }


    private static AuraHandledException unauthorised() {
        AuraHandledException e = new AuraHandledException('Unauthorised request.');
        e.setMessage('Unauthorised request.');
        return e;
    }

    /**
     * @description Executes the Quote Benefits API callout.
     */
    private static ServiceResponse executeQuoteBenefitsCallout(
        String payloadJson,
        String quoteId
    ) {
        ServiceResponse result = new ServiceResponse();

        if (Test.isRunningTest() && testResponseBody != null) {
            result.responseBody = testResponseBody;
            result.statusCode = testStatusCode;
            return result;
        }

        INS_API_QuoteBenefits service =
            new INS_API_QuoteBenefits();

        result.responseBody = service.putQuoteBenefits(
            payloadJson,
            quoteId
        );
        result.statusCode = service.getStatusCode();

        return result;
    }

    /**
     * @description Processes the API response.
     */
    private static String processServiceResponse(
        ServiceResponse serviceResponse
    ) {
        if (!isSuccessfulStatus(serviceResponse.statusCode)) {
            return createErrorResponse(
                'Error: ' +
                serviceResponse.statusCode +
                ' - ' +
                serviceResponse.responseBody
            );
        }

        if (String.isBlank(serviceResponse.responseBody)) {
            return createErrorResponse(
                'Quote Benefits API returned an empty response.'
            );
        }

        Map<String, Object> responseMap =
            (Map<String, Object>) JSON.deserializeUntyped(
                serviceResponse.responseBody
            );

        Map<String, Object> validationResult =
            (Map<String, Object>) responseMap.get(
                KEY_VALIDATION_RESULT
            );

        if (!isSuccessfulValidation(validationResult)) {
            Object validationMessage =
                validationResult == null
                    ? 'Validation result was not returned.'
                    : validationResult.get(KEY_MESSAGE);

            return createErrorResponse(validationMessage);
        }

        return createSuccessResponse(
            (List<Object>) responseMap.get(KEY_BENEFITS)
        );
    }

    /**
     * @description Determines whether an HTTP status is successful.
     */
    private static Boolean isSuccessfulStatus(
        Integer statusCode
    ) {
        return statusCode == HTTP_STATUS_OK ||
            statusCode == HTTP_STATUS_CREATED;
    }

    /**
     * @description Determines whether API validation succeeded.
     */
    private static Boolean isSuccessfulValidation(
        Map<String, Object> validationResult
    ) {
        if (validationResult == null) {
            return false;
        }

        String resultStatus =
            (String) validationResult.get(KEY_RESULT_STATUS);

        return STATUS_SUCCESS.equalsIgnoreCase(resultStatus);
    }

    /**
     * @description Creates the successful response.
     */
    private static String createSuccessResponse(
        List<Object> benefits
    ) {
        return JSON.serialize(
            new Map<String, Object>{
                RESPONSE_HAS_ERROR => false,
                RESPONSE_BENEFITS => benefits
            }
        );
    }

    /**
     * @description Creates the error response.
     */
    private static String createErrorResponse(
        Object errorMessage
    ) {
        return JSON.serialize(
            new Map<String, Object>{
                RESPONSE_HAS_ERROR => true,
                RESPONSE_ERROR => errorMessage
            }
        );
    }

    /**
     * @description Internal API response wrapper.
     */
    private class ServiceResponse {
        private Integer statusCode;
        private String responseBody;
    }
}