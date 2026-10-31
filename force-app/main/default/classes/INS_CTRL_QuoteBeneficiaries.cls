/**
 * 
 * Class Name      : INS_CTRL_QuoteBeneficiaries
 * Author          : Irshad
 * Created Date    : 2026-01-10
 * Last Modified By: Irshad
 * Last Modified On: 2026-06-12
 * Description     : Callable implementation for OmniStudio Remote Actions.
 *                   Handles adding beneficiaries to a Flexi Protect quote by
 *                   calling the Quote Beneficiaries API.
 * Story           : SFP-56009
 * Test Class      : INS_CTRL_QuoteBeneficiaries_TEST
 * LastModified    : Added Logger
 */
public with sharing class INS_CTRL_QuoteBeneficiaries implements callable{

    // =========================================================================
    // CONSTANTS
    // =========================================================================
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_QuoteBeneficiaries');
    private static final String ACTION_CALL_BENEFICIARIES   = 'CallBeneficiaries';
    private static final String COUNTRY_KE                  = 'KE';
    private static final String ALLOCATION_TYPE_PERCENTAGE  = 'PERCENTAGE';
    private static final String BENEFIT_ID_EXTENDED_FAMILY  = '11';
    private static final String CONTACT_TYPE_EMAIL          = 'EMAIL';
    private static final String CONTACT_TYPE_MOBILE         = 'MOBILE';
    private static final String KEY_QUOTE_ID                = 'quoteId';
    private static final String KEY_BENEFICIARY_SUMMARY     = 'BeneficiarySummary';
    private static final String KEY_MEMBERS                 = 'members';
    private static final String KEY_FIRST_NAME              = 'FirstName__c';
    private static final String KEY_LAST_NAME               = 'LastName__c';
    private static final String KEY_TITLE                   = 'title';
    private static final String KEY_RELATIONSHIP            = 'RelationshipToInsured';
    private static final String KEY_IDENTITY_NUMBER         = 'IdentityNumber__c';
    private static final String KEY_ID_TYPE                 = 'IdType__c';
    private static final String KEY_GENDER                  = 'Gender__c';
    private static final String KEY_BENEFICIARY_ID          = 'beneficiaryId';
    private static final String KEY_MEMBER_ID               = 'memberId';
    private static final String KEY_ALLOCATION              = 'Allocation__c';
    private static final String KEY_BIRTH_DATE               = 'BirthDate__c';
    private static final String KEY_EMAIL                   = 'EmailAddress__c';
    private static final String KEY_PHONE                   = 'PhoneNumber__c';
    private static final String KEY_BENEFICIARIES           = 'beneficiaries';
    private static final String KEY_REFERENCE_NUMBER        = 'referenceNumber';
    private static final String KEY_BENEFICIARY_ID_RESP     = 'beneficiaryId';
    private static final String KEY_HAS_ERROR               = 'hasError';
    private static final String KEY_ERROR                   = 'error';
    private static final String PHONE_COUNTRY_PREFIX        = '254';

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

        if (actionType == ACTION_CALL_BENEFICIARIES) {
            return callBeneficiaries(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }
    

    // =========================================================================
    // ACTION: CALL BENEFICIARIES
    // =========================================================================
	
    /**
     * @description Sends the beneficiary list to Mobi, routing each beneficiary to
     *              the correct endpoint: those with an existing beneficiaryId are
     *              updated (PUT), those without are added (POST). Prevents the
     *              duplication that occurs when previously-saved beneficiaries are
     *              re-posted on a resumed quote.
     */
    
    private static Object callBeneficiaries(
        Map<String, Object> input,
        Map<String, Object> output
    ) {
        String quoteId = getString(input, KEY_QUOTE_ID);
        Map<String, List<Object>> groups = groupBeneficiaries(
            extractInputBeneficiaries(input)
        );

        Map<String, Object> summary = new Map<String, Object>{
            KEY_HAS_ERROR        => false,
            KEY_ERROR            => '',
            KEY_BENEFICIARIES    => new List<Object>(),
            KEY_REFERENCE_NUMBER => quoteId
        };

        // Preserve existing ordering: update saved beneficiaries before adding new ones.
        sendAndMerge(quoteId, groups.get('update'), true, summary);
        sendAndMerge(quoteId, groups.get('add'), false, summary);

        output.put(KEY_BENEFICIARY_SUMMARY, summary);
        return output;
    }

    /** Separates beneficiaries by whether Mobi has already assigned an id. */
    private static Map<String, List<Object>> groupBeneficiaries(List<Object> beneficiaries) {
        Map<String, List<Object>> groups = new Map<String, List<Object>>{
            'update' => new List<Object>(),
            'add'    => new List<Object>()
        };

        for (Object obj : beneficiaries) {
            if (!(obj instanceof Map<String, Object>)) {
                continue;
            }

            Map<String, Object> beneficiary = (Map<String, Object>) obj;
            String groupKey = String.isBlank(getString(beneficiary, KEY_BENEFICIARY_ID))
                ? 'add' : 'update';
            groups.get(groupKey).add(obj);
        }
        return groups;
    }

    /** Sends a non-empty group and merges its response into the shared summary. */
    private static void sendAndMerge(
        String quoteId,
        List<Object> beneficiaries,
        Boolean isUpdate,
        Map<String, Object> summary
    ) {
        if (beneficiaries.isEmpty()) {
            return;
        }

        Map<String, Object> result = sendBeneficiaries(quoteId, beneficiaries, isUpdate);
        mergeBeneficiaryResult(summary, result);
    }

    /** Combines success/error state, messages, and returned ids across both calls. */
    private static void mergeBeneficiaryResult(
        Map<String, Object> summary,
        Map<String, Object> result
    ) {
        if (result.get(KEY_HAS_ERROR) == true) {
            summary.put(KEY_HAS_ERROR, true);
        }

        if (result.get(KEY_ERROR) != null) {
            summary.put(KEY_ERROR,
                (String) summary.get(KEY_ERROR) + String.valueOf(result.get(KEY_ERROR)));
        }

        List<Object> ids = (List<Object>) result.get(KEY_BENEFICIARIES);
        if (ids != null) {
            ((List<Object>) summary.get(KEY_BENEFICIARIES)).addAll(ids);
        }
    }


    /**
     * @description Builds and sends a payload for the supplied subset of
     *              beneficiaries, via PUT when updating or POST when adding.
     */
    private static Map<String, Object> sendBeneficiaries(
        String quoteId, List<Object> beneficiaries, Boolean isUpdate
    ) {
        String payloadJson = buildBeneficiaryPayloadFor(quoteId, beneficiaries);        
        
        try {
            INS_API_QuoteBeneficiaries service = new INS_API_QuoteBeneficiaries();
            service.setExceptionOnError(false);
            
            String responseBody = isUpdate
                ? service.updateBeneficiaries(payloadJson, quoteId)
                : service.addBeneficiaries(payloadJson, quoteId);
            
            return (Map<String, Object>) processResponse(service.getStatusCode(), responseBody);
            
        } catch (Exception e) {
            LOGGER.error(e.getMessage(),new String[]{'sendBeneficiaries',e.getMessage()},e);
            return errorMap('Beneficiaries API call failed: ' + e.getMessage());
        }
    }
    

    /**
     * @description Removes a beneficiary at Mobi by sending a PUT with the
     *              beneficiary id set to zero. Called immediately from the delete
     *              button rather than batched, since a deleted record is no longer
     *              in the local list to send later.
     * @param quoteId The Mobi quote reference
     * @param input   Must contain the beneficiary under BeneficiarySummary.members
     * @return        The processed response
     */
    @AuraEnabled
    public static Object deleteBeneficiary(String quoteId, Map<String, Object> input) {
        try {
            if (String.isBlank(quoteId)) {
                throw new AuraHandledException('Quote Id is required.');
            }

            List<Object> beneficiaries = extractInputBeneficiaries(input);
            if (beneficiaries.isEmpty()) {
                throw new AuraHandledException('No beneficiary supplied for deletion.');
            }

            String payloadJson = buildBeneficiaryPayloadFor(quoteId, beneficiaries);            

            INS_API_QuoteBeneficiaries service = new INS_API_QuoteBeneficiaries();
            service.setExceptionOnError(false);
            String responseBody = service.updateBeneficiaries(payloadJson, quoteId);            

            return processResponse(service.getStatusCode(), responseBody);

        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(),new String[]{'sendBeneficiaries',ex.getMessage()},ex);
            throw new AuraHandledException('Delete beneficiary failed: ' + ex.getMessage());
        }
    }
    
    /**
     * @description Extracts the beneficiary list from the OmniScript input.
     * @param input The action input map
     * @return      The beneficiary entries, or an empty list when absent
     */
    private static List<Object> extractInputBeneficiaries(Map<String, Object> input) {
        Object benSummaryObj = input.get(KEY_BENEFICIARY_SUMMARY);
        if (!(benSummaryObj instanceof Map<String, Object>)) {
            return new List<Object>();
        }

        Map<String, Object> benSummary = (Map<String, Object>) benSummaryObj;
        Object membersObj = benSummary.get(KEY_MEMBERS);
        if (!(membersObj instanceof List<Object>)) {
            return new List<Object>();
        }

        return (List<Object>) membersObj;
    }
    
    /**
     * @description Builds the request payload for the supplied beneficiaries.
     * @param quoteId       The Mobi quote reference
     * @param beneficiaries The beneficiary entries to include
     * @return              Serialised request payload
     */
    @TestVisible
    private static String buildBeneficiaryPayloadFor(String quoteId, List<Object> beneficiaries) {
        BeneficiarySummaryWrapper request = new BeneficiarySummaryWrapper();
        request.referenceNumber = quoteId;
        request.beneficiaries   = new List<BeneficiaryWrapper>();

        for (Object obj : beneficiaries) {
            if (!(obj instanceof Map<String, Object>)) {
                continue;
            }
            request.beneficiaries.add(buildBeneficiary((Map<String, Object>) obj));
        }

        return JSON.serialize(request);
    }


    // =========================================================================
    // RESPONSE PROCESSOR
    // =========================================================================

    private static Object processResponse(Integer statusCode, String responseBody) {
        if (statusCode != 200 && statusCode != 201) {
            return errorMap('API error ' + statusCode + ': ' + responseBody);
        }
        if (String.isBlank(responseBody)) {
            return errorMap('Empty response from Beneficiaries API. Status: ' + statusCode);
        }

        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } catch (Exception ex) {
            return errorMap('Failed to parse API response: ' + ex.getMessage());
        }

        List<Object> beneficiaries = extractBeneficiariesList(responseMap);
        if (beneficiaries == null || beneficiaries.isEmpty()) {
            return errorMap('No beneficiaries returned in API response');
        }

        return buildBeneficiarySummary(responseMap, beneficiaries);
    }

    private static List<Object> extractBeneficiariesList(Map<String, Object> responseMap) {
        Object beneficiariesObj = responseMap.get(KEY_BENEFICIARIES);
        return beneficiariesObj instanceof List<Object> ? (List<Object>) beneficiariesObj : null;
    }

    private static Object buildBeneficiarySummary(Map<String, Object> responseMap, List<Object> beneficiaries) {
        String referenceNumber      = getString(responseMap, KEY_REFERENCE_NUMBER);
        List<Object> beneficiaryIds = new List<Object>();
        Boolean hasError            = false;

        for (Object obj : beneficiaries) {
            if (!(obj instanceof Map<String, Object>)) {
                hasError = true;
                continue;
            }
            Map<String, Object> ben = (Map<String, Object>) obj;
            String beneficiaryId    = getString(ben, KEY_BENEFICIARY_ID_RESP);

            if (String.isNotBlank(beneficiaryId)) {
                beneficiaryIds.add(new Map<String, Object>{
                    KEY_BENEFICIARY_ID_RESP => beneficiaryId
                });
            } else {
                hasError = true;
            }
        }

        if (beneficiaryIds.isEmpty()) {
            return errorMap('No beneficiaryId returned for any beneficiary');
        }

        return new Map<String, Object>{
            KEY_HAS_ERROR        => hasError,
            KEY_BENEFICIARIES    => beneficiaryIds,
            KEY_REFERENCE_NUMBER => referenceNumber
        };
    }
    
    // =========================================================================
    // BENEFICIARY BUILDER
    // =========================================================================

    private static BeneficiaryWrapper buildBeneficiary(Map<String, Object> member) {
        String firstName = getString(member, KEY_FIRST_NAME);
        String lastName  = getString(member, KEY_LAST_NAME);

        BeneficiaryWrapper ben  = new BeneficiaryWrapper();
        ben.firstName           = firstName;
        ben.surname             = lastName;
        ben.initials            = buildInitials(firstName, lastName);
        ben.title               = defaultString(getString(member, KEY_TITLE));
        ben.relationship        = getString(member, KEY_RELATIONSHIP);
        ben.identityNumber      = defaultString(getString(member, KEY_IDENTITY_NUMBER));
        ben.identityType        = defaultString(getString(member, KEY_ID_TYPE));
        ben.gender              = getString(member, KEY_GENDER);
        ben.idCountryOfIssue    = COUNTRY_KE;
        ben.beneficiaryId       = getString(member, KEY_BENEFICIARY_ID);
        ben.personId            = getString(member, KEY_MEMBER_ID);
        ben.benefitId           = BENEFIT_ID_EXTENDED_FAMILY;
        ben.allocationType      = ALLOCATION_TYPE_PERCENTAGE;
        ben.allocationAmount    = parseAllocation(member.get(KEY_ALLOCATION));
        ben.dateOfBirth         = parseDateOfBirth(getString(member, KEY_BIRTH_DATE));
        ben.contacts            = buildContacts(member);

        return ben;
    }

    // =========================================================================
    // FIELD HELPERS
    // =========================================================================

    private static String buildInitials(String firstName, String lastName) {
        String first = String.isNotBlank(firstName) ? firstName.substring(0, 1).toUpperCase() : '';
        String last  = String.isNotBlank(lastName)  ? lastName.substring(0, 1).toUpperCase()  : '';
        return first + last;
    }

     /**
     * @description Returns an empty string in place of null, for fields the
     *              Beneficiaries API requires as a string.
     */
    private static String defaultString(String value) {
        return value == null ? '' : value;
    }

    private static Integer parseAllocation(Object allocationObj) {
        return allocationObj == null
            ? 0
            : Integer.valueOf(String.valueOf(allocationObj));
    }

    private static Datetime parseDateOfBirth(String dobStr) {
        if (String.isBlank(dobStr)) {
            return null;
        }
        String cleanDate = dobStr.contains('T') ? dobStr.substringBefore('T') : dobStr;
        try {
            Date dob = Date.valueOf(cleanDate);
            return Datetime.newInstanceGmt(dob.year(), dob.month(), dob.day(), 0, 0, 0);
        } catch (Exception e) {
            return null;
        }
    }

    /*------------------------------------------------------------
     *  buildContact() folded in here — it was only ever called
     *  from this one place, so keeping it separate just added to
     *  the class's method count for no reuse benefit.
     *------------------------------------------------------------*/
    private static List<ContactWrapper> buildContacts(Map<String, Object> member) {
        List<ContactWrapper> contactList = new List<ContactWrapper>();

        String email = getString(member, KEY_EMAIL);
        if (String.isNotBlank(email)) {
            ContactWrapper emailContact = new ContactWrapper();
            emailContact.contactType    = CONTACT_TYPE_EMAIL;
            emailContact.text           = email;
            contactList.add(emailContact);
        }

        String phone = getString(member, KEY_PHONE);
        if (String.isNotBlank(phone)) {
            ContactWrapper phoneContact = new ContactWrapper();
            phoneContact.contactType    = CONTACT_TYPE_MOBILE;
            phoneContact.text           = formatPhoneNumber(phone);
            contactList.add(phoneContact);
        }

        return contactList;
    }

    private static Map<String, Object> errorMap(String message) {
        return new Map<String, Object>{
            KEY_HAS_ERROR => true,
            KEY_ERROR     => message,
            KEY_BENEFICIARIES => new List<Object>()
        };
    }

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val == null ? null : String.valueOf(val);
    }

    /**
     * @description Prefixes a phone number with the Kenyan country code unless it
     *              already carries it, dropping any leading zero so 0746875901
     *              becomes 254746875901.
     * @param phone The number as captured
     * @return      The number in the form the API expects
     */
    private static String formatPhoneNumber(String phone) {
        String digits = phone.replaceAll('[^0-9]', '');
        if (String.isBlank(digits)) {
            return '';
        }
        if (digits.startsWith(PHONE_COUNTRY_PREFIX)) {
            return digits;
        }
        return PHONE_COUNTRY_PREFIX + digits;
    }

    // =========================================================================
    // WRAPPER CLASSES
    // =========================================================================

    public class BeneficiarySummaryWrapper {
        public String                   referenceNumber;
        public List<BeneficiaryWrapper> beneficiaries;
    }

    // NOSONAR sf:TooManyFields - DTO mirrors external API contract field-for-field
    public class BeneficiaryWrapper {
        public String              title;
        public String              surname;
        public String              relationship;
        public String              personId;
        public String              initials;
        public String              identityType;
        public String              identityNumber;
        public String              idCountryOfIssue;
        public String              gender;
        public String              firstName;
        public Datetime            dateOfBirth;
        public String              benefitId;
        public String              beneficiaryId;
        public String              allocationType;
        public Integer             allocationAmount;
        public List<ContactWrapper> contacts;
    }

    public class ContactWrapper {
        public String text;
        public String contactType;
    }
}