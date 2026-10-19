/**
 * @description       : Callable implementation for OmniStudio Remote Actions.
 *                   	Calls the Quick Quote creation API and maps the response
 *                   	back to OmniScript output for the Flexi Protect journey.
 * @author            : Irshad
 * @group             : API
 * @last modified on  : 11/05/2026
 * @User-Story        : SFP-55635
 **/
public with sharing class INS_CTRL_CallQuoteCreation implements Callable {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_CREATE_QUOTE       = 'createQuickQuote';

    // API response statuses
    private static final String STATUS_FAILED             = 'Failed';
    private static final String STATUS_SUCCESS            = 'Success';

    // Payload literals
    private static final String CHANNEL_SALESFORCE        = 'Salesforce';
    private static final String COUNTRY_KE                = 'KE';
    private static final String PHONE_PREFIX_KE           = '+254';
    private static final String IDENTITY_DOC_TYPE         = 'SAIDENTITYDOCUMENT';
    private static final String MEMBER_TYPE_MAIN          = 'MAININSURED';
    private static final String ALLOCATION_TYPE_PCT       = 'PERCENTAGE';
    private static final String BENEFIT_TYPE_MAIN_FUNERAL = 'MAINFUNERAL';
    private static final String BENEFIT_KEY_MAIN_FUNERAL  = '1.MAINFUNERAL';
    private static final String BENEFIT_DURATION_MONTHLY  = 'Monthly';
    private static final String DOB_FORMAT                 = 'yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'';

    private static final Integer DEFAULT_ALLOCATION_AMOUNT = 100;
    private static final Integer DEFAULT_ANNUAL_INCREASE   = 0;

    // Response map keys
    private static final String KEY_HAS_ERROR   = 'hasError';
    private static final String KEY_QUOTE_ID    = 'quoteId';

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

        if (actionType == ACTION_CREATE_QUOTE) {
            return callCreateQuoteAPI(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // =========================================================================
    // API CALL
    // =========================================================================

    private static Object callCreateQuoteAPI(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        INS_Quick_Quote_Wrapper.QuotePayload payload = generateRequestPayload(input);
        String payloadJson = JSON.serialize(payload);

        String response;
        Integer statusCode;

        try {
            INS_API_QuoteCreation service = new INS_API_QuoteCreation();
            service.setExceptionOnError(false); 
            response   = service.postQuickQuote(payloadJson);
            statusCode = service.getStatusCode();          
            
        } catch (Exception e) {
            throw new AuraHandledException('Quote API call failed: ' + e.getMessage());
        }

        Map<String, Object> jsonResponseMap;
        try {
            jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            
        } catch (Exception e) {
            throw new AuraHandledException('Failed to parse Quote API response: ' + e.getMessage());
        }

        Map<String, Object> createQuoteResponseMap = buildQuoteResponseMap(
            statusCode, jsonResponseMap
        );

        output.put('CreateQuoteResponse', createQuoteResponseMap);
        return output;
    }

    // =========================================================================
    // RESPONSE MAPPING
    // =========================================================================

    private static Map<String, Object> buildQuoteResponseMap(
        Integer statusCode,
        Map<String, Object> jsonResponseMap
    ) {
        Map<String, Object> responseMap = new Map<String, Object>();

        if (statusCode == 200 || statusCode == 201) {
            Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');

            if (validation == null) {
                responseMap.put(KEY_HAS_ERROR, 'false');
                mapFirstBenefitToResponse(jsonResponseMap, responseMap);
                responseMap.put(KEY_QUOTE_ID, (String) jsonResponseMap.get(KEY_QUOTE_ID));
                return responseMap;
            }

            String resultStatus = (String) validation.get('ResultStatus');

            if (STATUS_FAILED.equalsIgnoreCase(resultStatus)) {
                responseMap.put(KEY_HAS_ERROR,   'true');
                responseMap.put('errorMessage', validation.get('Message'));
                return responseMap;
            }

            if (STATUS_SUCCESS.equalsIgnoreCase(resultStatus)) {
                responseMap.put(KEY_HAS_ERROR, 'false');
                responseMap.put(KEY_QUOTE_ID,  (String) jsonResponseMap.get(KEY_QUOTE_ID));
                mapFirstBenefitToResponse(jsonResponseMap, responseMap);
                return responseMap;
            }

            // Unknown ResultStatus — still return clean shape, no rawResponse
            responseMap.put(KEY_HAS_ERROR,   'true');
            responseMap.put('errorMessage', 'Unknown validation status: ' + resultStatus);

        } else {
            responseMap.put(KEY_HAS_ERROR,   'true');
            responseMap.put('errorMessage', 'API returned status: ' + statusCode);
        }

        return responseMap;
    }

    /**
     * Extracts memberId and benefit fields from the first member's first benefit.
     * No-op if members or benefits are absent — avoids NPE on partial responses.
     */
    private static void mapFirstBenefitToResponse(
        Map<String, Object> jsonResponseMap,
        Map<String, Object> responseMap
    ) {
        List<Object> members = (List<Object>) jsonResponseMap.get('members');
        if (members == null || members.isEmpty()) {
            return;
        }

        Map<String, Object> memberMap    = (Map<String, Object>) members[0];
        List<Object>        benefits     = (List<Object>) memberMap.get('benefits');
        if (benefits == null || benefits.isEmpty()) {
            return;
        }

        Map<String, Object> benefitMap = (Map<String, Object>) benefits[0];
        responseMap.put('memberId',          (String)  benefitMap.get('memberId'));
        responseMap.put('benefitAmountValue', (String)  benefitMap.get('benefitAmountValue'));
        responseMap.put('coverAmount',        (Decimal) benefitMap.get('coverAmount'));
        responseMap.put('duration',           (String)  benefitMap.get('duration'));
        responseMap.put('benefitKey',         (String)  benefitMap.get('benefitKey'));
    }

    // =========================================================================
    // PAYLOAD BUILDER
    // =========================================================================

    private static INS_Quick_Quote_Wrapper.QuotePayload generateRequestPayload(
        Map<String, Object> input
    ) {
        Map<String, Object> membersWrapper   = getRequiredMap(input, 'MembersDetails');
        Map<String, Object> productsMetadata = getRequiredMap(input, 'INS_Products');
        String accountId = getString(input, 'accountId');

        INS_Quick_Quote_Wrapper.QuotePayload payload = new INS_Quick_Quote_Wrapper.QuotePayload();
        payload.quoteId              = '';
        payload.requestId            = '';
        payload.channel              = CHANNEL_SALESFORCE;
        payload.annualBenefitIncrease = DEFAULT_ANNUAL_INCREASE;
        payload.cashBackOption        = false;
        payload.consultantCode        = getCurrentUserEmployeeNumber();

        INS_Quick_Quote_Wrapper.ProductRules productRules = new INS_Quick_Quote_Wrapper.ProductRules();
        productRules.productId             = getString(productsMetadata, 'Product_Code__c');
        productRules.annualBenefitIncrease = DEFAULT_ANNUAL_INCREASE;
        productRules.waiveWaitingPeriod    = false;
        payload.productRules = productRules;

        payload.members = new List<INS_Quick_Quote_Wrapper.Member>{
            buildMember(membersWrapper, productsMetadata, accountId)
        };

        return payload;
    }

    private static INS_Quick_Quote_Wrapper.Member buildMember(
        Map<String, Object> membersWrapper,
        Map<String, Object> productsMetadata,
        String accountId
    ) {
        INS_Quick_Quote_Wrapper.Member member = new INS_Quick_Quote_Wrapper.Member();
        member.firstName            = getString(membersWrapper, 'FirstName');
        member.lastName             = getString(membersWrapper, 'LastName');
        member.identityNumber       = getString(membersWrapper, 'IdNumber');
        member.gender               = getString(membersWrapper, 'Gender');
        member.email                = getString(membersWrapper, 'Email');
        member.identityDocumentType = IDENTITY_DOC_TYPE;
        member.memberType           = MEMBER_TYPE_MAIN;
        member.customerExternalId   = accountId;
        member.idCountryOfIssue     = getString(productsMetadata, 'Country__c');

        String countryCode  = getString(productsMetadata, 'Country__c');
        String rawPhone     = getString(membersWrapper, 'PhoneNumber');
        member.contactNumber = COUNTRY_KE.equals(countryCode)
            ? PHONE_PREFIX_KE + rawPhone
            : rawPhone;

        member.dateOfBirth = formatDateOfBirth(getString(membersWrapper, 'OS_DateOfBirth'));
        member.benefits    = new List<INS_Quick_Quote_Wrapper.Benefit>{
            buildBenefit(productsMetadata)
        };

        return member;
    }

    private static INS_Quick_Quote_Wrapper.Benefit buildBenefit(
        Map<String, Object> productsMetadata
    ) {
        INS_Quick_Quote_Wrapper.Beneficiaries beneficiaries = new INS_Quick_Quote_Wrapper.Beneficiaries();
        beneficiaries.allocationAmount = DEFAULT_ALLOCATION_AMOUNT;
        beneficiaries.allocationType   = ALLOCATION_TYPE_PCT;

        INS_Quick_Quote_Wrapper.Benefit benefit = new INS_Quick_Quote_Wrapper.Benefit();
        benefit.benefitType   = BENEFIT_TYPE_MAIN_FUNERAL;
        benefit.benefitKey    = BENEFIT_KEY_MAIN_FUNERAL;
        benefit.coverAmount   = (Double) productsMetadata.get('Default_Cover_Amount__c');
        benefit.duration      = BENEFIT_DURATION_MONTHLY;
        benefit.beneficiaries = new List<INS_Quick_Quote_Wrapper.Beneficiaries>{ beneficiaries };

        return benefit;
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    /**
     * Isolated SOQL for current user's employee number.
     * Null-safe — returns empty string if EmployeeNumber not set or the
     * running user cannot be read (checks object/field access explicitly,
     * since this runs in a guest/OmniScript context where FLS may restrict
     * access to the User object's fields).
     */
    private static String getCurrentUserEmployeeNumber() {
        if (!Schema.SObjectType.User.fields.EmployeeNumber.isAccessible()) {
            return '';
        }

        List<User> users = [
            SELECT EmployeeNumber
            FROM   User
            WHERE  Id = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT  1
        ];

        return (users.isEmpty() || users[0].EmployeeNumber == null)
            ? '' : users[0].EmployeeNumber;
    }

    /**
     * Parses DOB string to ISO-8601 UTC datetime string.
     * Throws AuraHandledException on invalid format.
     */
    private static String formatDateOfBirth(String dobStr) {
        if (String.isBlank(dobStr)) {
            throw new AuraHandledException('DateOfBirth is required in MembersDetails.');
        }
        try {
            Date     dobDate     = Date.valueOf(dobStr);
            Datetime dobDatetime = Datetime.newInstanceGMT(
                dobDate.year(), dobDate.month(), dobDate.day(), 0, 0, 0
            );
            return dobDatetime.formatGMT(DOB_FORMAT);
        } catch (Exception e) {
            throw new AuraHandledException('Invalid DateOfBirth format: ' + dobStr);
        }
    }

    private static Map<String, Object> getRequiredMap(Map<String, Object> parent, String key) {
        Object val = parent.get(key);
        if (!(val instanceof Map<String, Object>)) {
            throw new AuraHandledException('Required map missing or invalid: ' + key);
        }
        return (Map<String, Object>) val;
    }

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val == null ? null : String.valueOf(val);
    }
}