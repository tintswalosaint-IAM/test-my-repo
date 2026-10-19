/**
 * @description       : test class for INS_CTRL_QuoteBenefitsRequestBuilder.                      
 * @author            : Irshad
 * @created on        : 03-25-2026
 * @user story        : SFP-55636
 * @last modified by  : Irshad
 */
@isTest
private class INS_CTRL_QuoteBenefitsRequest_TEST {

    private static final String QUOTE_ID = 'QUOTE-001';
    private static final String MEMBER_ID = 'MEMBER-001';
    private static final String AMOUNT = '500000';

    private static final String KEY_CREATE_QUOTE_RESPONSE =
        'CreateQuoteResponse';
    private static final String KEY_BENEFITS =
        'benefits';
    private static final String KEY_BENEFIT_AMOUNT =
        'BenefitAmount';

    private static final String KEY_QUOTE_ID =
        'quoteId';
    private static final String KEY_MEMBER_ID =
        'memberId';
    private static final String KEY_REFERENCE_NUMBER =
        'referenceNumber';

    private static final String KEY_BENEFIT_ID =
        'benefitId';
    private static final String KEY_BENEFIT_KEY =
        'benefitKey';
    private static final String KEY_BENEFIT_TYPE =
        'benefitType';
    private static final String KEY_BENEFIT_FREQUENCY =
        'benefitFrequencyValue';
    private static final String KEY_BENEFIT_AMOUNT_VALUE =
        'benefitAmountValue';

    @isTest
    static void buildRequest_singleBenefit_success() {
        Map<String, Object> input = createSingleBenefitInput(
            Decimal.valueOf(AMOUNT)
        );

        Test.startTest();
        String requestJson =
            INS_CTRL_QuoteBenefitsRequestBuilder.buildRequest(
                QUOTE_ID,
                input
            );
        Test.stopTest();

        Map<String, Object> requestMap =
            deserializeToMap(requestJson);

        Assert.areEqual(
            QUOTE_ID,
            requestMap.get(KEY_REFERENCE_NUMBER),
            'The quote reference number should be populated.'
        );

        List<Object> benefits =
            (List<Object>) requestMap.get(KEY_BENEFITS);

        Assert.areEqual(
            1,
            benefits.size(),
            'One main benefit should be generated.'
        );

        Map<String, Object> benefit =
            (Map<String, Object>) benefits[0];

        Assert.areEqual(
            '1-MAINFUNERAL',
            benefit.get(KEY_BENEFIT_ID),
            'The main benefit ID should be populated.'
        );
        Assert.areEqual(
            '1.MAINFUNERAL',
            benefit.get(KEY_BENEFIT_KEY),
            'The main benefit key should be populated.'
        );
        Assert.areEqual(
            'MAINFUNERAL',
            benefit.get(KEY_BENEFIT_TYPE),
            'The main benefit type should be populated.'
        );
        Assert.areEqual(
            MEMBER_ID,
            benefit.get(KEY_MEMBER_ID),
            'The member ID should be populated.'
        );
        Assert.areEqual(
            'MONTHLY',
            benefit.get(KEY_BENEFIT_FREQUENCY),
            'The default frequency should be MONTHLY.'
        );
        Assert.areEqual(
            Decimal.valueOf(AMOUNT),
            toDecimal(benefit.get(KEY_BENEFIT_AMOUNT_VALUE)),
            'The selected benefit amount should be populated.'
        );
    }

    @isTest
    static void buildRequest_multipleBenefits_success() {
        Test.startTest();
        String requestJson =
            INS_CTRL_QuoteBenefitsRequestBuilder.buildRequest(
                QUOTE_ID,
                createMultipleBenefitsInput()
            );
        Test.stopTest();

        Map<String, Object> requestMap =
            deserializeToMap(requestJson);

        List<Object> benefits =
            (List<Object>) requestMap.get(KEY_BENEFITS);

        Assert.areEqual(
            2,
            benefits.size(),
            'Both valid benefits should be included.'
        );

        Map<String, Object> firstBenefit =
            (Map<String, Object>) benefits[0];

        Assert.areEqual(
            'BENEFIT-001',
            firstBenefit.get(KEY_BENEFIT_ID),
            'The ID field should populate benefitId.'
        );
        Assert.areEqual(
            '10.FUNERAL',
            firstBenefit.get(KEY_BENEFIT_KEY),
            'The key field should populate benefitKey.'
        );
        Assert.areEqual(
            'FUNERAL',
            firstBenefit.get(KEY_BENEFIT_TYPE),
            'The type field should populate benefitType.'
        );
        Assert.areEqual(
            'ANNUAL',
            firstBenefit.get(KEY_BENEFIT_FREQUENCY),
            'The supplied frequency should be retained.'
        );
        Assert.areEqual(
            Decimal.valueOf('50000'),
            toDecimal(
                firstBenefit.get(KEY_BENEFIT_AMOUNT_VALUE)
            ),
            'The supplied benefit amount should be populated.'
        );
        Assert.areEqual(
            MEMBER_ID,
            firstBenefit.get(KEY_MEMBER_ID),
            'The member ID should be populated.'
        );

        Map<String, Object> secondBenefit =
            (Map<String, Object>) benefits[1];

        Assert.areEqual(
            'BENEFIT-002',
            secondBenefit.get(KEY_BENEFIT_ID),
            'The fallback benefit ID should be used.'
        );
        Assert.areEqual(
            '31.REPATRIATION',
            secondBenefit.get(KEY_BENEFIT_KEY),
            'The fallback benefit key should be used.'
        );
        Assert.areEqual(
            'REPATRIATION',
            secondBenefit.get(KEY_BENEFIT_TYPE),
            'The fallback benefit type should be used.'
        );
        Assert.areEqual(
            'MONTHLY',
            secondBenefit.get(KEY_BENEFIT_FREQUENCY),
            'MONTHLY should be used when frequency is absent.'
        );
        Assert.areEqual(
            Decimal.valueOf('100000'),
            toDecimal(
                secondBenefit.get(KEY_BENEFIT_AMOUNT_VALUE)
            ),
            'The fallback benefit amount should be used.'
        );
    }

    @isTest
    static void buildRequest_zeroAmountWithoutId_skipped() {
        Test.startTest();
        String requestJson =
            INS_CTRL_QuoteBenefitsRequestBuilder.buildRequest(
                QUOTE_ID,
                createZeroAmountBenefitsInput()
            );
        Test.stopTest();

        Map<String, Object> requestMap =
            deserializeToMap(requestJson);

        List<Object> benefits =
            (List<Object>) requestMap.get(KEY_BENEFITS);

        Assert.areEqual(
            1,
            benefits.size(),
            'A zero-value benefit without an ID should be skipped.'
        );

        Map<String, Object> remainingBenefit =
            (Map<String, Object>) benefits[0];

        Assert.areEqual(
            'BENEFIT-EXISTING',
            remainingBenefit.get(KEY_BENEFIT_ID),
            'An existing zero-value benefit should be retained.'
        );
        Assert.areEqual(
            Decimal.valueOf('0'),
            toDecimal(
                remainingBenefit.get(KEY_BENEFIT_AMOUNT_VALUE)
            ),
            'The retained benefit should have a zero amount.'
        );
    }

    private static Map<String, Object> createSingleBenefitInput(
        Decimal benefitAmount
    ) {
        return new Map<String, Object>{
            KEY_CREATE_QUOTE_RESPONSE =>
                new Map<String, Object>{
                    KEY_QUOTE_ID => QUOTE_ID,
                    KEY_MEMBER_ID => MEMBER_ID,
                    'coverAmount' => benefitAmount
                },
            KEY_BENEFIT_AMOUNT => benefitAmount
        };
    }

    private static Map<String, Object>
        createMultipleBenefitsInput() {

        return new Map<String, Object>{
            KEY_CREATE_QUOTE_RESPONSE =>
                new Map<String, Object>{
                    KEY_QUOTE_ID => QUOTE_ID,
                    KEY_MEMBER_ID => MEMBER_ID
                },
            KEY_BENEFITS => new List<Object>{
                new Map<String, Object>{
                    'id' => 'BENEFIT-001',
                    'key' => '10.FUNERAL',
                    'type' => 'FUNERAL',
                    'amount' => 50000,
                    'frequency' => 'ANNUAL'
                },
                new Map<String, Object>{
                    KEY_BENEFIT_ID => 'BENEFIT-002',
                    KEY_BENEFIT_KEY => '31.REPATRIATION',
                    KEY_BENEFIT_TYPE => 'REPATRIATION',
                    KEY_BENEFIT_AMOUNT_VALUE => 100000
                }
            }
        };
    }

    private static Map<String, Object>
        createZeroAmountBenefitsInput() {

        return new Map<String, Object>{
            KEY_CREATE_QUOTE_RESPONSE =>
                new Map<String, Object>{
                    KEY_QUOTE_ID => QUOTE_ID,
                    KEY_MEMBER_ID => MEMBER_ID
                },
            KEY_BENEFITS => new List<Object>{
                new Map<String, Object>{
                    'key' => '12.AIRTIME',
                    'type' => 'AIRTIME',
                    'amount' => 0
                },
                new Map<String, Object>{
                    'id' => 'BENEFIT-EXISTING',
                    'key' => '7.CATERING',
                    'type' => 'CATERING',
                    'amount' => 0
                }
            }
        };
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
}