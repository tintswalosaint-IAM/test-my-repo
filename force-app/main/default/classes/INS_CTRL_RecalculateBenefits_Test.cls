/**
 * @description       : test class for INS_CTRL_RecalculateBenefits.                      
 * @author            : Irshad
 * @created on        : 03-25-2026
 * @user story        : SFP-55636
 * @last modified by  : Irshad
 */

@isTest
private class INS_CTRL_RecalculateBenefits_Test {

    private static final String QUOTE_ID = 'QUOTE-001';
    private static final String MEMBER_ID = 'MEMBER-001';
    private static final String AMOUNT = '500000';

    private static final Integer HTTP_STATUS_OK = 200;
    private static final Integer HTTP_STATUS_CREATED = 201;
    private static final Integer HTTP_STATUS_BAD_REQUEST = 400;

    private static final String KEY_CREATE_QUOTE_RESPONSE =
        'CreateQuoteResponse';
    private static final String KEY_MEMBER_ID =
        'memberId';
    private static final String KEY_BENEFIT_AMOUNT =
        'BenefitAmount';

    private static final String KEY_VALIDATION_RESULT =
        'ValidationResult';
    private static final String KEY_RESULT_STATUS =
        'ResultStatus';
    private static final String KEY_MESSAGE =
        'Message';
    private static final String KEY_BENEFITS =
        'benefits';

    private static final String KEY_HAS_ERROR =
        'hasError';
    private static final String KEY_RECALCULATED_BENEFITS =
        'ReCalculateBenefits';
    private static final String KEY_RECALCULATION_ERROR =
        'ReCalculateBenefitsError';

    private static final String KEY_BENEFIT_ID =
        'benefitId';
    private static final String KEY_BENEFIT_AMOUNT_VALUE =
        'benefitAmountValue';
    private static final String KEY_BENEFIT_KEY =
        'benefitKey';
    private static final String KEY_BENEFIT_TYPE =
        'benefitType';
    private static final String KEY_BENEFIT_FREQUENCY =
        'benefitFrequencyValue';

    @isTest
    static void recalculateQuote_success() {
        setControllerResponse(
            HTTP_STATUS_OK,
            createSuccessfulResponse()
        );

        Test.startTest();
        String result =
            INS_CTRL_RecalculateBenefits.recalculateQuote(
                QUOTE_ID,
                createInput(Decimal.valueOf('700000'))
            );
        Test.stopTest();

        Map<String, Object> resultMap =
            deserializeToMap(result);

        Assert.areEqual(
            false,
            resultMap.get(KEY_HAS_ERROR),
            'The response should indicate success.'
        );

        List<Object> benefits =
            (List<Object>) resultMap.get(
                KEY_RECALCULATED_BENEFITS
            );

        Assert.areEqual(
            1,
            benefits.size(),
            'One recalculated benefit should be returned.'
        );

        Map<String, Object> firstBenefit =
            (Map<String, Object>) benefits[0];

        Assert.areEqual(
            '1-MAINFUNERAL',
            firstBenefit.get(KEY_BENEFIT_ID),
            'The recalculated main benefit should be returned.'
        );
        Assert.areEqual(
            Decimal.valueOf('680.74'),
            toDecimal(
                firstBenefit.get(KEY_BENEFIT_AMOUNT_VALUE)
            ),
            'The recalculated premium should be returned.'
        );
    }

    @isTest
    static void recalculateQuote_createdStatus_success() {
        setControllerResponse(
            HTTP_STATUS_CREATED,
            createSuccessfulResponse()
        );

        Test.startTest();
        String result =
            INS_CTRL_RecalculateBenefits.recalculateQuote(
                QUOTE_ID,
                createInput(Decimal.valueOf(AMOUNT))
            );
        Test.stopTest();

        Map<String, Object> resultMap =
            deserializeToMap(result);

        Assert.areEqual(
            false,
            resultMap.get(KEY_HAS_ERROR),
            'HTTP 201 should be treated as successful.'
        );
    }

    @isTest
    static void recalculateQuote_validationFailure() {
        String responseBody = JSON.serialize(
            new Map<String, Object>{
                KEY_VALIDATION_RESULT =>
                    new Map<String, Object>{
                        KEY_RESULT_STATUS => 'Failed',
                        KEY_MESSAGE =>
                            'Benefit amount is invalid.'
                    },
                KEY_BENEFITS => new List<Object>()
            }
        );

        setControllerResponse(
            HTTP_STATUS_OK,
            responseBody
        );

        Test.startTest();
        String result =
            INS_CTRL_RecalculateBenefits.recalculateQuote(
                QUOTE_ID,
                createInput(Decimal.valueOf(AMOUNT))
            );
        Test.stopTest();

        Map<String, Object> resultMap =
            deserializeToMap(result);

        Assert.areEqual(
            true,
            resultMap.get(KEY_HAS_ERROR),
            'The response should indicate a validation error.'
        );
        Assert.areEqual(
            'Benefit amount is invalid.',
            resultMap.get(KEY_RECALCULATION_ERROR),
            'The validation error should be returned.'
        );
    }

    @isTest
    static void recalculateQuote_missingValidationResult() {
        setControllerResponse(
            HTTP_STATUS_OK,
            JSON.serialize(
                new Map<String, Object>{
                    KEY_BENEFITS => new List<Object>()
                }
            )
        );

        Test.startTest();
        String result =
            INS_CTRL_RecalculateBenefits.recalculateQuote(
                QUOTE_ID,
                createInput(Decimal.valueOf(AMOUNT))
            );
        Test.stopTest();

        Map<String, Object> resultMap =
            deserializeToMap(result);

        Assert.areEqual(
            true,
            resultMap.get(KEY_HAS_ERROR),
            'Missing validation should return an error.'
        );
    }

    @isTest
    static void recalculateQuote_httpError() {
        String responseBody = JSON.serialize(
            new Map<String, Object>{
                KEY_MESSAGE => 'Bad request'
            }
        );

        setControllerResponse(
            HTTP_STATUS_BAD_REQUEST,
            responseBody
        );

        Test.startTest();
        String result =
            INS_CTRL_RecalculateBenefits.recalculateQuote(
                QUOTE_ID,
                createInput(Decimal.valueOf(AMOUNT))
            );
        Test.stopTest();

        Map<String, Object> resultMap =
            deserializeToMap(result);

        Assert.areEqual(
            true,
            resultMap.get(KEY_HAS_ERROR),
            'The response should indicate an HTTP error.'
        );
        Assert.areEqual(
            'Error: 400 - ' + responseBody,
            resultMap.get(KEY_RECALCULATION_ERROR),
            'The status and API response should be returned.'
        );
    }

    @isTest
    static void recalculateQuote_invalidJson_throwsException() {
        setControllerResponse(
            HTTP_STATUS_OK,
            'Invalid JSON response'
        );

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            INS_CTRL_RecalculateBenefits.recalculateQuote(
                QUOTE_ID,
                createInput(Decimal.valueOf(AMOUNT))
            );
        } catch (AuraHandledException exceptionValue) {
            exceptionThrown = true;
            exceptionMessage = exceptionValue.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(
            exceptionThrown,
            'Invalid JSON should throw AuraHandledException.'
        );
        Assert.isNotNull(
            exceptionMessage,
            'The exception message should be populated.'
        );
    }

    private static Map<String, Object> createInput(
        Decimal benefitAmount
    ) {
        return new Map<String, Object>{
            KEY_CREATE_QUOTE_RESPONSE =>
                new Map<String, Object>{
                    KEY_MEMBER_ID => MEMBER_ID
                },
            KEY_BENEFIT_AMOUNT => benefitAmount
        };
    }

    private static String createSuccessfulResponse() {
        return JSON.serialize(
            new Map<String, Object>{
                KEY_VALIDATION_RESULT =>
                    new Map<String, Object>{
                        KEY_RESULT_STATUS => 'Success',
                        KEY_MESSAGE => null
                    },
                KEY_BENEFITS => new List<Object>{
                    new Map<String, Object>{
                        KEY_BENEFIT_ID => '1-MAINFUNERAL',
                        KEY_BENEFIT_KEY => '1.MAINFUNERAL',
                        KEY_BENEFIT_TYPE => 'MAINFUNERAL',
                        KEY_BENEFIT_AMOUNT_VALUE => 680.74,
                        KEY_BENEFIT_FREQUENCY => 'MONTHLY',
                        KEY_MEMBER_ID => MEMBER_ID
                    }
                }
            }
        );
    }

    private static void setControllerResponse(
        Integer statusCode,
        String responseBody
    ) {
        INS_CTRL_RecalculateBenefits.testStatusCode =
            statusCode;
        INS_CTRL_RecalculateBenefits.testResponseBody =
            responseBody;
    }

    private static Map<String, Object> deserializeToMap(
        String jsonValue
    ) {
        return (Map<String, Object>)
            JSON.deserializeUntyped(jsonValue);
    }

    private static Decimal toDecimal(Object value) {
        return Decimal.valueOf(String.valueOf(value));
    }
    // =========================================================================
    // generateQuickQuoteBenefitsRequest
    // =========================================================================

    @isTest
    static void generateQuickQuoteBenefitsRequest_success() {
        Test.startTest();
        String payloadJson =
            INS_CTRL_RecalculateBenefits.generateQuickQuoteBenefitsRequest(
                QUOTE_ID,
                createInput(Decimal.valueOf(AMOUNT))
            );
        Test.stopTest();

        Map<String, Object> payload = deserializeToMap(payloadJson);

        Assert.areEqual(
            QUOTE_ID,
            payload.get('referenceNumber'),
            'The quote reference number should be populated in the generated request.'
        );
    }

    @isTest
    static void generateQuickQuoteBenefitsRequest_nullInput_throws() {
        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            INS_CTRL_RecalculateBenefits.generateQuickQuoteBenefitsRequest(
                QUOTE_ID,
                null
            );
        } catch (AuraHandledException exceptionValue) {
            exceptionThrown = true;
            exceptionMessage = exceptionValue.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(
            exceptionThrown,
            'Null input should throw AuraHandledException.'
        );        
    }

   
}