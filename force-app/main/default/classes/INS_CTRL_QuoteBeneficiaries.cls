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
 *
 */
public with sharing class INS_CTRL_QuoteBeneficiaries implements callable{

    // =========================================================================
    // CONSTANTS
    // =========================================================================

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

        List<Object> allBeneficiaries = extractInputBeneficiaries(input);
        List<Object> toAdd    = new List<Object>();
        List<Object> toUpdate = new List<Object>();

        for (Object obj : allBeneficiaries) {
            if (!(obj instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> beneficiary = (Map<String, Object>) obj;
            if (String.isBlank(getString(beneficiary, KEY_BENEFICIARY_ID))) {
                toAdd.add(obj);
            } else {
                toUpdate.add(obj);
            }
        }

        List<Object> responseIds = new List<Object>();
        Boolean hasError = false;
        String errorMessage = '';

        if (!toUpdate.isEmpty()) {
            Map<String, Object> result = sendBeneficiaries(quoteId, toUpdate, true);
            hasError = hasError || (Boolean) result.get(KEY_HAS_ERROR);
            errorMessage += String.valueOf(result.get(KEY_ERROR) ?? '');
            responseIds.addAll((List<Object>) result.get(KEY_BENEFICIARIES));
        }

        if (!toAdd.isEmpty()) {
            Map<String, Object> result = sendBeneficiaries(quoteId, toAdd, false);
            hasError = hasError || (Boolean) result.get(KEY_HAS_ERROR);
            errorMessage += String.valueOf(result.get(KEY_ERROR) ?? '');
            responseIds.addAll((List<Object>) result.get(KEY_BENEFICIARIES));
        }

        output.put(KEY_BENEFICIARY_SUMMARY, new Map<String, Object>{
            KEY_HAS_ERROR     => hasError,
            KEY_ERROR         => errorMessage,
            KEY_BENEFICIARIES => responseIds
        });
        return output;
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
    /**
     * @description Adds a new Beneficiary
     * @param quoteId The external quote reference number.
     * @param input   Map containing member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and members list or error.
     */
    @AuraEnabled
    public static Object addBeneficiary(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildBeneficiaryPayload(quoteId, input);
            
            INS_API_QuoteBeneficiaries service = new INS_API_QuoteBeneficiaries();
            service.setExceptionOnError(false);
            String responseBody = service.addBeneficiaries(payloadJson, quoteId);
            Integer statusCode  = service.getStatusCode();
            return processResponse(statusCode, responseBody);
        } catch (Exception ex) {
            throw new AuraHandledException('Add Beneficiary failed: ' + ex.getMessage());
        }
    }

    // =========================================================================
    // RESPONSE PROCESSOR
    // =========================================================================

    /*------------------------------------------------------------
     *  Decomposed from a single method (CC 11 / NPath 480) into
     *  three focused methods: status/body validation stays inline
     *  here (cheap, 2 checks), while list-extraction and per-item
     *  mapping — the parts that drove NPath the hardest — moved to
     *  extractBeneficiariesList() and buildBeneficiarySummary().
     *------------------------------------------------------------*/
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
    // PAYLOAD BUILDER
    // =========================================================================

    @TestVisible        
    private static String buildBeneficiaryPayload(String quoteId, Map<String, Object> input) {
        return buildBeneficiaryPayloadFor(quoteId, extractInputBeneficiaries(input));
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
            phoneContact.text           = phone;
            contactList.add(phoneContact);
        }

        return contactList;
    }

    private static Map<String, Object> errorMap(String message) {
        return new Map<String, Object>{
            KEY_HAS_ERROR => true,
            KEY_ERROR     => message
        };
    }

    private static String getString(Map<String, Object> m, String key) {
        Object val = m.get(key);
        return val == null ? null : String.valueOf(val);
    }

    // =========================================================================
    // WRAPPER CLASSES
    // =========================================================================

    /*------------------------------------------------------------
     *  BeneficiaryWrapper's field count (16) mirrors the external
     *  Mulesoft/lifequote API's beneficiary JSON contract field-for-
     *  field. It is a DTO, not a service class — every field exists
     *  because the wire format requires it, not because of a design
     *  choice that could be simplified. Splitting it (e.g. a
     *  "PersonalDetails" + "AllocationDetails" sub-wrapper) would
     *  require the API to accept nested JSON it does not define.
     *  See sf:TooManyFields.
     *------------------------------------------------------------*/
    // NOSONAR sf:TooManyFields - DTO mirrors external API contract field-for-field
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