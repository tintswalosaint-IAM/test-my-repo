/**
 * 
 * Class Name      : INS_CTRL_QuoteAdditionalBenefits
 * Author          : Irshad
 * Created Date    : 2026-01-10
 * Last Modified By: Irshad
 * Last Modified On: 2026-06-12
 * Description     : Callable implementation for OmniStudio Remote Actions.
 *                   Handles adding and updating additional benefits (cashback,
 *                   annual increase, payment frequency) on a Flexi Protect quote.
 * Story           : SFP-55635
 * Test Class      : INS_CTRL_QuoteAdditionalBenefits_TEST
 */
public with sharing class INS_CTRL_QuoteAdditionalBenefits implements Callable {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_WITH_CASHBACK    = 'AdditionalBenefitsWithCashback';
    private static final String ACTION_WITHOUT_CASHBACK = 'AdditionalBenefitsWithoutCashback';

    private static final String DEFAULT_CASHBACK_VALUE    = 'true';
    private static final String DEFAULT_PAYMENT_FREQUENCY = 'Monthly';
    private static final String DEFAULT_AUTOMATIC_BENEFIT = '5';
    private static final String CASHBACK_NO               = 'No';
    private static final String CASHBACK_VALUE_FALSE      = 'false';
    private static final String BENEFIT_TYPE_ANNUAL       = 'AnnualBenefitIncrease';
    private static final String BENEFIT_TYPE_CASHBACK     = 'CashBackOption';
    private static final String KEY_PERSONALISED_QUOTE    = 'PersonalisedQuote';
    private static final String KEY_CASHBACK_BENEFIT      = 'CashbackBenefit';
    private static final String KEY_PAYMENT_FREQUENCY     = 'PaymentFrequency';
    private static final String KEY_AUTOMATIC_BENEFIT     = 'AutomaticBenefit';
    private static final String KEY_QUOTE_ID              = 'quoteId';
    private static final String KEY_ERROR                 = 'error';
    private static final String KEY_ERROR_DESCRIPTION     = 'errorDescription';
    private static final String KEY_RESULT                = 'result';
    private static final String KEY_HAS_ERROR             = 'hasError';
    private static final String POPULATE_PREMIUMS_ERROR   = 'populatePremiumsError';

    // =========================================================================
    // CALLABLE ENTRY POINT
    // =========================================================================

    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get('input') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get('output') instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');

        if (actionType == ACTION_WITH_CASHBACK) {
            return additionalBenefitsWithCashback(input, output);
        }
        if (actionType == ACTION_WITHOUT_CASHBACK) {
            return additionalBenefitsWithoutCashback(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // =========================================================================
    // ACTION: WITH CASHBACK
    // =========================================================================

    private static Object additionalBenefitsWithCashback(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        String quoteId           = getString(input, KEY_QUOTE_ID);
        String cashbackValue     = DEFAULT_CASHBACK_VALUE;
        String paymentFrequency  = DEFAULT_PAYMENT_FREQUENCY;
        String automaticBenefit  = DEFAULT_AUTOMATIC_BENEFIT;
        Boolean isPersonalisedQuote = false;

        Object pqObj = input.get(KEY_PERSONALISED_QUOTE);
        if (pqObj instanceof Map<String, Object>) {
            Map<String, Object> personalisedQuote = (Map<String, Object>) pqObj;
            isPersonalisedQuote = true;

            if (CASHBACK_NO.equalsIgnoreCase(getString(personalisedQuote, KEY_CASHBACK_BENEFIT))) {
                cashbackValue = CASHBACK_VALUE_FALSE;
            }
            paymentFrequency = getString(personalisedQuote, KEY_PAYMENT_FREQUENCY);
            automaticBenefit = getString(personalisedQuote, KEY_AUTOMATIC_BENEFIT);
        }

        String payloadJson = buildPayloadJson(quoteId, paymentFrequency, cashbackValue, automaticBenefit);

        String responseBody;
        Integer statusCode;

        try {
            INS_API_QuoteAdditionalBenefits service = new INS_API_QuoteAdditionalBenefits();
            service.setExceptionOnError(false);
            if (isPersonalisedQuote) {
                responseBody = service.updateAdditionalBenefits(payloadJson, quoteId);
            } else {
                responseBody = service.addAdditionalBenefits(payloadJson, quoteId);
            }
            statusCode = service.getStatusCode();
        } catch (Exception e) {
            throw new AuraHandledException('Additional Benefits API call failed: ' + e.getMessage());
        }

        return handleApiResponse(responseBody, statusCode, isPersonalisedQuote, output);
    }

    // =========================================================================
    // ACTION: WITHOUT CASHBACK
    // =========================================================================

    private static Object additionalBenefitsWithoutCashback(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        String quoteId = getString(input, KEY_QUOTE_ID);

        String payloadJson = buildPayloadJson(
            quoteId,
            DEFAULT_PAYMENT_FREQUENCY,
            DEFAULT_CASHBACK_VALUE,
            DEFAULT_AUTOMATIC_BENEFIT
        );

        String responseBody;
        Integer statusCode;

        try {
            INS_API_QuoteAdditionalBenefits service = new INS_API_QuoteAdditionalBenefits();
            service.setExceptionOnError(false);            
            responseBody = service.addAdditionalBenefits(payloadJson, quoteId);
            statusCode   = service.getStatusCode();
        } catch (Exception e) {
            throw new AuraHandledException('Additional Benefits API call failed: ' + e.getMessage());
        }

        return handleApiResponse(responseBody, statusCode, false, output);
    }

    // =========================================================================
    // RESPONSE HANDLING
    // =========================================================================

    /**
     * Unified response handler for both actions.
     * Routes to populatePremiums (POST) or responseFromPutCall (PUT) on success.
     * Writes structured error keys on failure.
     */
    private static Object handleApiResponse(
        String responseBody,
        Integer statusCode,
        Boolean isPutCall,
        Map<String, Object> output
    ) {
        if (String.isBlank(responseBody)) {
            output.put(KEY_HAS_ERROR, true);
            output.put(POPULATE_PREMIUMS_ERROR, 'Empty response from Additional Benefits API. Status: ' + statusCode);
            return output;
        }

        Map<String, Object> jsonResponseMap;
        try {
            jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } catch (Exception e) {
            output.put(KEY_HAS_ERROR, true);
            output.put(POPULATE_PREMIUMS_ERROR, 'Failed to parse API response: ' + e.getMessage());
            return output;
        }

        if (statusCode == 200 || statusCode == 201) {
            if (isPutCall) {
                responseFromPutCall(jsonResponseMap, output);
            } else {
                populatePremiums(jsonResponseMap, output);
            }
        } else {
            output.put(KEY_HAS_ERROR, true);
            Object errorObj = jsonResponseMap.get(KEY_ERROR);
            if (errorObj instanceof Map<String, Object>) {
                Map<String, Object> errorObjMap = (Map<String, Object>) errorObj;
                output.put(POPULATE_PREMIUMS_ERROR, getString(errorObjMap, KEY_ERROR_DESCRIPTION));
            } else {
                output.put(POPULATE_PREMIUMS_ERROR, 'API returned status: ' + statusCode);
            }
        }

        return output;
    }

    /**
     * Maps POST response premiums onto output.
     * Accepts pre-parsed Map to avoid double-parsing.
     */
    private static void populatePremiums(
        Map<String, Object> responseMap,
        Map<String, Object> output
    ) {
        output.put(KEY_HAS_ERROR,                        false);
        output.put('monthlyPremium',                     (Decimal) responseMap.get('monthlyPremium'));
        output.put('monthlyCashbackPremium',             (Decimal) responseMap.get('monthlyCashbackPremium'));
        output.put('monthlyCashbackBenefitPremium',      (Decimal) responseMap.get('monthlyCashbackBenefitPremium'));
        output.put('annualPremium',                      (Decimal) responseMap.get('annualPremium'));
        output.put('annualCashbackPremium',              (Decimal) responseMap.get('annualCashbackPremium'));
        output.put('annualCashbackBenefitPremium',       (Decimal) responseMap.get('annualCashbackBenefitPremium'));
    }

    /**
     * Maps PUT response result onto output.
     * Accepts pre-parsed Map to avoid double-parsing.
     */
    private static void responseFromPutCall(
        Map<String, Object> responseMap,
        Map<String, Object> output
    ) {
        output.put(KEY_HAS_ERROR, false);
        if (responseMap.containsKey(KEY_RESULT)) {
            output.put(KEY_RESULT, responseMap.get(KEY_RESULT));
        }
    }

    // =========================================================================
    // PAYLOAD BUILDER
    // =========================================================================

    private static String buildPayloadJson(
        String quoteId,
        String paymentFrequency,
        String cashbackValue,
        String annualBenefitValue
    ) {
        RequestWrapper reqWrapper       = new RequestWrapper();
        reqWrapper.quoteNumber          = quoteId;
        reqWrapper.paymentFrequency     = paymentFrequency;
        reqWrapper.additionalBenefits   = new List<Object>();

        AdditionalBenefitWrapper annualBenefit = new AdditionalBenefitWrapper();
        annualBenefit.benefitType  = BENEFIT_TYPE_ANNUAL;
        annualBenefit.benefitValue = annualBenefitValue;
        reqWrapper.additionalBenefits.add(annualBenefit);

        AdditionalBenefitCashbackWrapper cashBack = new AdditionalBenefitCashbackWrapper();
        cashBack.benefitType  = BENEFIT_TYPE_CASHBACK;
        cashBack.benefitValue = toBoolean(cashbackValue);
        reqWrapper.additionalBenefits.add(cashBack);

        return JSON.serialize(reqWrapper);
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val == null? null: String.valueOf(val);       
        
    }

    /**
     * @description Converts the cashback selection to a boolean, tolerating both
     *              Yes/No and true/false representations.
     * @param value The raw selection value
     * @return      True when cashback is selected
     */
    private static Boolean toBoolean(String value) {
        if (String.isBlank(value)) {
            return false;
        }
        return 'Yes'.equalsIgnoreCase(value) || 'true'.equalsIgnoreCase(value);
    }

    // =========================================================================
    // INNER WRAPPER CLASSES
    // =========================================================================

    private class RequestWrapper {
        private String quoteNumber;
        private String paymentFrequency;
        private List<Object> additionalBenefits;
    }

    private class AdditionalBenefitWrapper {
        private String benefitType;
        private String benefitValue;
    }
    /**
     * @description Cashback carries a JSON boolean rather than a string, so it
     *              needs its own wrapper type.
     */
    private class AdditionalBenefitCashbackWrapper {
        private String benefitType;
        private Boolean benefitValue;
    }
}