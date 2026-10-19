/**
 * @description       : API class for ProductRules API
 * @author            : Irshad
 * @group             : API
 * @last modified on  : 11/05/2026
 * @User-Story        : SFP-51843
 * 
 */

public with sharing class INS_CTRL_ProductsRules implements Callable {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_PRODUCT_RULES    = 'callProductsRulesAPI';
    private static final String DEFAULT_PRODUCT_CODE    = '32';
    private static final String KEY_PRODUCT_CODE        = 'ProductCode';
    private static final String KEY_SUM_ASSURED_LIMITS  = 'SumAssuredLimits';
    private static final String KEY_PRODUCT_BENEFIT_RULES = 'ProductBenefitRules';
    @TestVisible
    private static String testResponseBody;
    @TestVisible
    private static Integer testStatusCode;

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

        if (actionType == ACTION_PRODUCT_RULES) {
            return callProductsRulesAPI(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // =========================================================================
    // API CALL
    // =========================================================================

    private static Object callProductsRulesAPI(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        String productCode = getString(input, KEY_PRODUCT_CODE);
        if (String.isBlank(productCode)) {
            productCode = DEFAULT_PRODUCT_CODE;
        }

        String responseBody;
        Integer statusCode;

        try {
            if(Test.isRunningTest() && testResponseBody != null){
            	responseBody = testResponseBody;
				statusCode = testStatusCode;    
            }else{
            	INS_API_ProductsRules service = new INS_API_ProductsRules();
                service.setExceptionOnError(false);
                responseBody = service.getProductRules(productCode);
                statusCode   = service.getStatusCode();   
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Products Rules API call failed: ' + e.getMessage());
        }

        if (String.isBlank(responseBody)) {
            throw new AuraHandledException('Empty response from Products Rules API. Status: ' + statusCode);
        }

        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to parse Products Rules API response: ' + e.getMessage());
        }

        List<Map<String, Object>> allSumAssuredLimits = extractSumAssuredLimits(responseMap);

        output.put('statusCode',           statusCode);
        output.put('productRulesResponse', allSumAssuredLimits);
        return output;
    }

    // =========================================================================
    // RESPONSE MAPPING
    // =========================================================================

    /**
     * Extracts SumAssuredLimits from every ProductBenefitRules entry.
     * Returns empty list if ProductBenefitRules is absent or empty.
     */
    private static List<Map<String, Object>> extractSumAssuredLimits(
        Map<String, Object> responseMap
    ) {
        List<Map<String, Object>> allSumAssuredLimits = new List<Map<String, Object>>();

        Object rulesObj = responseMap.get(KEY_PRODUCT_BENEFIT_RULES);
        if (!(rulesObj instanceof List<Object>)) {
            return allSumAssuredLimits;
        }

        List<Object> productBenefitRules = (List<Object>) rulesObj;

        for (Object ruleObj : productBenefitRules) {
            if (!(ruleObj instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> rule = (Map<String, Object>) ruleObj;

            Object limitsObj = rule.get(KEY_SUM_ASSURED_LIMITS);
            if (!(limitsObj instanceof List<Object>)) {
                continue;
            }

            for (Object limitObj : (List<Object>) limitsObj) {
                if (limitObj instanceof Map<String, Object>) {
                    allSumAssuredLimits.add((Map<String, Object>) limitObj);
                }
            }
        }

        return allSumAssuredLimits;
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        if(val != null){
            return String.valueOf(val);
        }
        return null;
    
        
    }
}