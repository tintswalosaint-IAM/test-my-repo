/**
 * @description             : Request Builder class for INS_CTRL_QuoteBenefits
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
public with sharing class INS_CTRL_QuoteBenefitsRequestBuilder {

    private static final String DEFAULT_FREQUENCY =
        'MONTHLY';

    private static final String MAIN_BENEFIT_ID =
        '1-MAINFUNERAL';
    private static final String MAIN_BENEFIT_KEY =
        '1.MAINFUNERAL';
    private static final String MAIN_BENEFIT_TYPE =
        'MAINFUNERAL';

    private static final String KEY_CREATE_QUOTE_RESPONSE =
        'CreateQuoteResponse';
    private static final String KEY_MEMBER_ID =
        'memberId';
    private static final String KEY_BENEFITS =
        'benefits';
    private static final String KEY_BENEFIT_AMOUNT =
        'BenefitAmount';


     /**
     * Prevent instantiation of this utility class.
     */
    private INS_CTRL_QuoteBenefitsRequestBuilder() {
    }
    /**
     * @description Builds the Quote Benefits request.
     */
    public static String buildRequest(
        String quoteId,
        Map<String, Object> input
    ) {
        Map<String, Object> createQuoteResponse =
            convertToMap(
                input.get(KEY_CREATE_QUOTE_RESPONSE)
            );

        String memberId =
            (String) createQuoteResponse.get(KEY_MEMBER_ID);

        INS_Quick_Quote_Wrapper.QuoteBenefitRequest request =
            createRequest(quoteId);

        List<Object> incomingBenefits =
            (List<Object>) input.get(KEY_BENEFITS);

        if (incomingBenefits == null ||
            incomingBenefits.isEmpty()) {

            request.benefits.add(
                createMainBenefit(input, memberId)
            );
        } else {
            request.benefits.addAll(
                createIncomingBenefits(
                    incomingBenefits,
                    memberId
                )
            );
        }

        return JSON.serialize(request);
    }

    /**
     * @description Creates the request wrapper.
     */
    private static INS_Quick_Quote_Wrapper.QuoteBenefitRequest
        createRequest(String quoteId) {

        INS_Quick_Quote_Wrapper.QuoteBenefitRequest request =
            new INS_Quick_Quote_Wrapper.QuoteBenefitRequest();

        request.referenceNumber = quoteId;
        request.benefits =
            new List<INS_Quick_Quote_Wrapper.QuoteBenefit>();

        return request;
    }

    /**
     * @description Creates the main funeral benefit.
     */
    private static INS_Quick_Quote_Wrapper.QuoteBenefit
        createMainBenefit(
            Map<String, Object> input,
            String memberId
        ) {

        Object amountValue =
            input.get(KEY_BENEFIT_AMOUNT);

        if (amountValue == null) {
            throw new IllegalArgumentException(
                'Benefit Amount is required.'
            );
        }

        INS_Quick_Quote_Wrapper.QuoteBenefit benefit =
            new INS_Quick_Quote_Wrapper.QuoteBenefit();

        benefit.benefitId = MAIN_BENEFIT_ID;
        benefit.benefitKey = MAIN_BENEFIT_KEY;
        benefit.benefitType = MAIN_BENEFIT_TYPE;
        benefit.benefitAmountValue = Decimal.valueOf(
            String.valueOf(amountValue)
        );
        benefit.benefitFrequencyValue =
            DEFAULT_FREQUENCY;
        benefit.memberId = memberId;

        return benefit;
    }

    /**
     * @description Creates incoming benefit wrappers.
     */
    private static List<INS_Quick_Quote_Wrapper.QuoteBenefit>
        createIncomingBenefits(
            List<Object> incomingBenefits,
            String memberId
        ) {

        List<INS_Quick_Quote_Wrapper.QuoteBenefit> benefits =
            new List<INS_Quick_Quote_Wrapper.QuoteBenefit>();

        for (Object incomingBenefit : incomingBenefits) {
            Map<String, Object> benefitMap =
                convertToMap(incomingBenefit);

            Decimal amount =
                resolveDecimalValue(
                    benefitMap,
                    'amount',
                    'benefitAmountValue'
                );

            if (amount == 0 &&
                benefitMap.get('id') == null) {

                continue;
            }

            benefits.add(
                createBenefit(
                    benefitMap,
                    amount,
                    memberId
                )
            );
        }

        return benefits;
    }

    /**
     * @description Creates an individual benefit wrapper.
     */
    private static INS_Quick_Quote_Wrapper.QuoteBenefit
        createBenefit(
            Map<String, Object> values,
            Decimal amount,
            String memberId
        ) {

        INS_Quick_Quote_Wrapper.QuoteBenefit benefit =
            new INS_Quick_Quote_Wrapper.QuoteBenefit();

        benefit.benefitId = resolveStringValue(
            values,
            'id',
            'benefitId'
        );
        benefit.benefitKey = resolveStringValue(
            values,
            'key',
            'benefitKey'
        );
        benefit.benefitType = resolveStringValue(
            values,
            'type',
            'benefitType'
        );
        benefit.benefitAmountValue = amount;
        benefit.benefitFrequencyValue =
            resolveFrequency(values);
        benefit.memberId = memberId;

        return benefit;
    }

    /**
     * @description Resolves a string using preferred and fallback keys.
     */
    private static String resolveStringValue(
        Map<String, Object> values,
        String preferredKey,
        String fallbackKey
    ) {
        Object resolvedValue =
            values.get(preferredKey);

        if (resolvedValue == null) {
            resolvedValue =
                values.get(fallbackKey);
        }

        return resolvedValue == null
            ? null
            : String.valueOf(resolvedValue);
    }

    /**
     * @description Resolves a decimal using preferred and fallback keys.
     */
    private static Decimal resolveDecimalValue(
        Map<String, Object> values,
        String preferredKey,
        String fallbackKey
    ) {
        Object resolvedValue =
            values.get(preferredKey);

        if (resolvedValue == null) {
            resolvedValue =
                values.get(fallbackKey);
        }

        return resolvedValue == null
            ? 0
            : Decimal.valueOf(
                String.valueOf(resolvedValue)
            );
    }

    /**
     * @description Resolves the benefit frequency.
     */
    private static String resolveFrequency(
        Map<String, Object> values
    ) {
        Object frequency =
            values.get('frequency');

        return frequency == null
            ? DEFAULT_FREQUENCY
            : String.valueOf(frequency);
    }

    /**
     * @description Converts an object into an untyped map.
     */
    private static Map<String, Object> convertToMap(
        Object value
    ) {
        if (value == null) {
            return new Map<String, Object>();
        }

        return (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serialize(value)
        );
    }
}