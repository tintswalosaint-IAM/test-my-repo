/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : INS_CTRL_QuoteMembers
 * Author          : Irshad
 * Created Date    : 2026-03-29
 * Last Modified By: Irshad
 * Last Modified On: 2026-06-12
 * Description     : Service class for managing quote members via LWC direct Apex calls.
 *                   Handles adding, editing members and calculating benefit premiums
 *                   on an existing quote by calling the Quick Quote Members and
 *                   Benefit Premiums services.
 * Story           : SFP-55635
 * Test Class      : INS_CTRL_QuoteMembers_TEST
 */
public with sharing class INS_CTRL_QuoteMembers {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String STATUS_SUCCESS            = 'Success';
    private static final String DEFAULT_FREQUENCY         = 'MONTHLY';
    private static final String DEFAULT_PREFIX            = 'R';
    private static final String DEFAULT_PREMIUM_TYPE      = 'NORMALPREMIUM';
    private static final String KEY_FIRST_NAME            = 'firstName';
    private static final String KEY_SURNAME               = 'surname';
    private static final String KEY_RELATIONSHIP          = 'relationship';
    private static final String KEY_MEMBER_TYPE           = 'memberType';
    private static final String KEY_MEMBER_ID             = 'memberId';
    private static final String KEY_ID_NUMBER             = 'idNumber';
    private static final String KEY_IDENTITY_DOC_TYPE     = 'identityDocumentType';
    private static final String KEY_GENDER                = 'gender';
    private static final String KEY_DATE_OF_BIRTH         = 'dateOfBirth';
    private static final String KEY_BPID                  = 'bpid';
    private static final String KEY_BENEFITS              = 'benefits';
    private static final String KEY_BENEFIT_AMOUNT_VALUE  = 'benefitAmountValue';
    private static final String KEY_AMOUNT                = 'amount';
    private static final String KEY_BENEFIT_ID            = 'benefitId';
    private static final String KEY_BENEFIT_KEY           = 'benefitKey';
    private static final String KEY_BENEFIT_TYPE          = 'benefitType';
    private static final String KEY_BENEFIT_FREQ          = 'benefitFrequencyValue';
    private static final String KEY_PREFIX                = 'prefix';
    private static final String KEY_VALIDATION_RESULT     = 'ValidationResult';
    private static final String KEY_RESULT_STATUS         = 'ResultStatus';
    private static final String KEY_MESSAGE               = 'Message';
    private static final String KEY_HAS_ERROR             = 'hasError';
    private static final String KEY_MEMBERS               = 'members';
    private static final String KEY_ERROR                 = 'error';
    private static final String KEY_BENEFITS_RESP         = 'benefits';

    // =========================================================================
    // PUBLIC AURA-ENABLED METHODS
    // =========================================================================

    /**
     * @description Adds a new member to an existing quote.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and members list or error.
     */
    @AuraEnabled
    public static String addMember(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildMemberPayload(quoteId, input);
            INS_API_QuoteMembers service = new INS_API_QuoteMembers();
            service.setExceptionOnError(false);
            String responseBody = service.addMemebrs(payloadJson, quoteId);
            Integer statusCode  = service.getStatusCode();
            return processMemberResponse(statusCode, responseBody);
        } catch (Exception ex) {
            throw new AuraHandledException('Add member failed: ' + ex.getMessage());
        }
    }

    /**
     * @description Edits an existing member on a quote.
     * @param quoteId The external quote reference number.
     * @param input   Map containing updated member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and members list or error.
     */
    @AuraEnabled
    public static String editMember(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildMemberPayload(quoteId, input);
            INS_API_QuoteMembers service = new INS_API_QuoteMembers();
            service.setExceptionOnError(false);
            String responseBody = service.editMemebrs(payloadJson, quoteId);
            Integer statusCode  = service.getStatusCode();
            return processMemberResponse(statusCode, responseBody);
        } catch (Exception ex) {
            throw new AuraHandledException('Edit member failed: ' + ex.getMessage());
        }
    }

    /**
     * @description Calculates benefit premiums for given members without saving.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and calculated premiums or error.
     */
    @AuraEnabled
    public static String calculateBenefits(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildBenefitCalculationPayload(quoteId, input);            
            INS_API_QuoteBenefitPremiums service = new INS_API_QuoteBenefitPremiums();
            service.setExceptionOnError(false);
            String responseBody = service.getBenefitPremiums(quoteId, payloadJson);
            Integer statusCode  = service.getStatusCode();
            return processCalculateResponse(statusCode, responseBody);
        } catch (Exception ex) {
            throw new AuraHandledException('Benefit calculation failed: ' + ex.getMessage());
        }
    }


    /**
     * @description Calculates benefit premiums for given members without saving.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and calculated premiums or error.
     */
    @AuraEnabled
    public static String editMainMemberBenefits(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildBenefitCalculationPayload(quoteId, input);
           
            INS_API_QuoteBenefits service = new INS_API_QuoteBenefits();
            service.setExceptionOnError(false);
            String responseBody = service.putQuoteBenefits(quoteId,payloadJson);
            Integer statusCode  = service.getStatusCode();
            return processCalculateResponse(statusCode, responseBody);
        } catch (Exception ex) {
            throw new AuraHandledException('Benefit calculation failed: ' + ex.getMessage());
        }
    }

    // =========================================================================
    // PAYLOAD BUILDERS
    // =========================================================================

    /**
     * @description Builds the serialised JSON request payload for Add/Edit Members API.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member and benefit details from LWC.
     * @return        Serialised JSON string of the member payload.
     */
    private static String buildMemberPayload(String quoteId, Map<String, Object> input) {
        INS_Quick_Quote_Wrapper.MemberPayload request = new INS_Quick_Quote_Wrapper.MemberPayload();        
        String accountId = (String)input.get('prospectAccountId');        
        if (String.isBlank(accountId)) {
            throw unauthorised();
        }else{
            List<Quote> quoteList;
            quoteList = new SEL_Quote().selectInProgressByAccIdsWoSharing(new List<Id>{ accountId });
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

        // Validate quoteId against stored value
        request.referenceNumber  = quoteId;
        Object thirdPartyValue = input.get('thirdPartyPolicy');
        request.thirdPartyPolicy = thirdPartyValue == null
            ? false
            : Boolean.valueOf(String.valueOf(thirdPartyValue));

        INS_Quick_Quote_Wrapper.AddMember member = new INS_Quick_Quote_Wrapper.AddMember();
        member.firstName            = getString(input, KEY_FIRST_NAME);
        member.surname              = getString(input, KEY_SURNAME);
        member.relationship         = getString(input, KEY_RELATIONSHIP);
        member.memberType           = getString(input, KEY_MEMBER_TYPE);
        member.memberId             = getString(input, KEY_MEMBER_ID);
        member.idNumber             = getString(input, KEY_ID_NUMBER);
        member.identityDocumentType = getString(input, KEY_IDENTITY_DOC_TYPE);
        member.gender               = getString(input, KEY_GENDER);
        member.dateOfBirth          = getString(input, KEY_DATE_OF_BIRTH);
        member.bpid                 = getString(input, KEY_BPID);
        member.benefits             = mapBenefits(input, true);

        request.members = new List<INS_Quick_Quote_Wrapper.AddMember>{ member };
        return JSON.serialize(request);
    }

    private static AuraHandledException unauthorised() {
        AuraHandledException e = new AuraHandledException('Unauthorised request.');
        e.setMessage('Unauthorised request.');
        return e;
    }

    /**
     * @description Builds the serialised JSON payload for the Benefit Calculation API.
     *              Maps only gender, dateOfBirth, and benefits — minimum required for calculation.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member and benefit details from LWC.
     * @return        Serialised JSON string of the calculation payload.
     */
    private static String buildBenefitCalculationPayload(String quoteId, Map<String, Object> input) {
        CalculatePremiumWrapper request = new CalculatePremiumWrapper();
        request.referenceNumber  = quoteId;        
        Object thirdPartyValue = input.get('thirdPartyPolicy');
        request.thirdPartyPolicy = thirdPartyValue == null
            ? false
            : Boolean.valueOf(String.valueOf(thirdPartyValue));

        INS_Quick_Quote_Wrapper.AddMember member = new INS_Quick_Quote_Wrapper.AddMember();
        member.gender      = getString(input, KEY_GENDER);
        member.dateOfBirth = getString(input, KEY_DATE_OF_BIRTH);
        member.firstName      = getString(input, 'firstName');
        member.surname      = getString(input, 'surname');

        request.members  = new List<INS_Quick_Quote_Wrapper.AddMember>{ member };
        request.benefits = mapBenefits(input, false);

        return JSON.serialize(request, true);
    }

    // =========================================================================
    // BENEFITS MAPPER
    // =========================================================================

    /**
     * @description Maps incoming LWC benefit objects to MemberBenefit wrappers.
     *              Skips zero-amount benefits.
     * @param input         Input map containing a 'benefits' list.
     * @param includeMember If true, maps member-specific fields (benefitId, prefix, premiumType).
     * @return              List of populated MemberBenefit wrappers.
     */
    private static List<INS_Quick_Quote_Wrapper.MemberBenefit> mapBenefits(
        Map<String, Object> input,
        Boolean includeMember
    ) {
        List<INS_Quick_Quote_Wrapper.MemberBenefit> benefitList =
            new List<INS_Quick_Quote_Wrapper.MemberBenefit>();

        Object rawBenefits = input.get(KEY_BENEFITS);
        if (!(rawBenefits instanceof List<Object>)) {
            return benefitList;
        }

        for (Object obj : (List<Object>) rawBenefits) {
            Map<String, Object> b = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

             Object amountObj = b.get(KEY_BENEFIT_AMOUNT_VALUE) == null
                ? b.get(KEY_AMOUNT)
                : b.get(KEY_BENEFIT_AMOUNT_VALUE);

            Decimal amount = amountObj == null
                ? 0
                : Decimal.valueOf(String.valueOf(amountObj));

            if (amount == 0) {
                continue;
            }

            INS_Quick_Quote_Wrapper.MemberBenefit benefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
            benefit.benefitKey            = getStringFromMap(b, KEY_BENEFIT_KEY);
            benefit.benefitType           = getStringFromMap(b, KEY_BENEFIT_TYPE);
            benefit.benefitAmountValue    = amount;
            benefit.benefitFrequencyValue = b.get(KEY_BENEFIT_FREQ) == null
                ? DEFAULT_FREQUENCY
                : String.valueOf(b.get(KEY_BENEFIT_FREQ));

            if (includeMember) {
                benefit.benefitId  = getStringFromMap(b, KEY_BENEFIT_ID);
                benefit.premiumType = DEFAULT_PREMIUM_TYPE;
                benefit.prefix      = b.get(KEY_PREFIX) == null
                    ? DEFAULT_PREFIX
                    : String.valueOf(b.get(KEY_PREFIX));
            }

            benefitList.add(benefit);
        }

        return benefitList;
    }

    // =========================================================================
    // RESPONSE PROCESSORS
    // =========================================================================

    /**
     * @description Processes Add/Edit Member API response.
     *              Checks ValidationResult block for Success/Failure.
     * @param statusCode   HTTP status code.
     * @param responseBody Raw JSON response body.
     * @return             Serialised JSON result string.
     */
    private static String processMemberResponse(Integer statusCode, String responseBody) {
        if (String.isBlank(responseBody)) {
            return errorResponse('Empty response from Members API. Status: ' + statusCode);
        }

        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } catch (Exception e) {
            return errorResponse('Failed to parse API response: ' + e.getMessage());
        }

        if (statusCode == 200 || statusCode == 201) {
            Object validationObj = responseMap.get(KEY_VALIDATION_RESULT);
            if (!(validationObj instanceof Map<String, Object>)) {
                return errorResponse('Unexpected response format — ValidationResult missing');
            }

            Map<String, Object> validation = (Map<String, Object>) validationObj;
            String resultStatus = (String) validation.get(KEY_RESULT_STATUS);

            if (STATUS_SUCCESS.equalsIgnoreCase(resultStatus)) {
                return JSON.serialize(new Map<String, Object>{
                    KEY_HAS_ERROR => false,
                    KEY_MEMBERS   => responseMap.get(KEY_MEMBERS)
                });
            }

            return JSON.serialize(new Map<String, Object>{
                KEY_HAS_ERROR => true,
                KEY_ERROR     => validation.get(KEY_MESSAGE)
            });
        }

        return errorResponse('Service error: ' + statusCode + ' - ' + responseBody);
    }

    /**
     * @description Processes Benefit Calculation API response.
     * @param statusCode   HTTP status code.
     * @param responseBody Raw JSON response body.
     * @return             Serialised JSON result string.
     */
    private static String processCalculateResponse(Integer statusCode, String responseBody) {
        if (String.isBlank(responseBody)) {
            return errorResponse('Empty response from Benefit Calculation API. Status: ' + statusCode);
        }

        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } catch (Exception e) {
            return errorResponse('Failed to parse Benefit Calculation response: ' + e.getMessage());
        }

        if (statusCode == 200 || statusCode == 201) {
            return JSON.serialize(new Map<String, Object>{
                KEY_HAS_ERROR     => false,
                KEY_BENEFITS_RESP => responseMap.get(KEY_BENEFITS_RESP),
                KEY_MEMBERS       => responseMap.get(KEY_MEMBERS)
            });
        }

        return errorResponse('Service error: ' + statusCode + ' - ' + responseBody);
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static String errorResponse(String message) {
        return JSON.serialize(new Map<String, Object>{
            KEY_HAS_ERROR => true,
            KEY_ERROR     => message
        });
    }

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val == null ? null : String.valueOf(val) ;
    }

    private static String getStringFromMap(Map<String, Object> m, String key) {
        return m.get(key) == null ? null  : String.valueOf(m.get(key));
    }

    // =========================================================================
    // INNER WRAPPER CLASS
    // =========================================================================

    private class CalculatePremiumWrapper {
        private String referenceNumber;
        private Boolean thirdPartyPolicy;
        private List<INS_Quick_Quote_Wrapper.AddMember> members;
        private List<INS_Quick_Quote_Wrapper.MemberBenefit> benefits;
    }
}