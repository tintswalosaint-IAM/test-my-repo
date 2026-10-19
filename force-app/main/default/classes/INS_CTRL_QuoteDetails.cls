/**
* @description  : INS_CTRL_QuoteDetails.cls to get the latest quote data from Mobi
* @SFP-50909    : The class has been created to connect to Mobi to get the quote data by passing quoteId
* @author       : Irshad Alam (irshad.alam@standardbank.co.za)
* @date         : March 2026
*/
public with sharing class INS_CTRL_QuoteDetails implements Callable {

    private static final String ACTION_GET_QUICK_QUOTE = 'getQuickQuote';

    private static final String KEY_INPUT         = 'input';
    private static final String KEY_OUTPUT        = 'output';
    private static final String KEY_QUOTE_ID      = 'quoteId';
    private static final String KEY_HAS_ERROR     = 'hasError';
    private static final String KEY_ERROR         = 'error';
    private static final String KEY_SALE_DATA     = 'saleData';
    private static final String KEY_BENEFIT_ARRAY = 'benefitArray';
    private static final String KEY_ROLEPLAYER_ARRAY = 'benefitRoleplayerArray';
    private static final String ROLEPLAYER_TYPE_BENEFICIARY = 'Beneficiary';

    private static final String RELATIONSHIP_MAIN_API = 'Main';
    private static final String RELATIONSHIP_MAIN_UI  = 'Myself';

    private static final Integer HTTP_OK      = 200;
    private static final Integer HTTP_CREATED = 201;    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_QuoteDetails');

    public Object call(String actionType, Map<String, Object> args) {
        if (!(args.get(KEY_INPUT) instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing input map for action: ' + actionType);
        }
        if (!(args.get(KEY_OUTPUT) instanceof Map<String, Object>)) {
            throw new AuraHandledException('Invalid or missing output map for action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get(KEY_INPUT);
        Map<String, Object> output = (Map<String, Object>) args.get(KEY_OUTPUT);

        if (actionType == ACTION_GET_QUICK_QUOTE) {
            return getQuickQuote((String) input.get(KEY_QUOTE_ID), output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    @AuraEnabled(cacheable=false)
    public static Object getQuickQuote(String quoteId, Map<String, Object> output) {
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Quote Id is required.');
        }
        if (output == null) {
            output = new Map<String, Object>();
        }

        String responseBody;
        Integer statusCode;

        try {
            INS_API_QuoteDetails service = new INS_API_QuoteDetails();
            service.setExceptionOnError(false);
            responseBody = service.getQuoteDetails(quoteId);
            statusCode   = service.getStatusCode();
        } catch (Exception e) {
            throw new AuraHandledException('Quote Details API call failed: ' + e.getMessage());
        }

        if (String.isBlank(responseBody)) {
            return errorResponse(output, 'Empty response from Quote Details API. Status: ' + statusCode);
        }

        Map<String, Object> jsonResponseMap;
        try {
            jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        } catch (Exception e) {
            return errorResponse(output, 'Failed to parse Quote Details response: ' + e.getMessage());
        }

        if (statusCode != HTTP_OK && statusCode != HTTP_CREATED) {
            return errorResponse(output, extractErrorDescription(jsonResponseMap, statusCode));
        }

        return buildSuccessResponse(jsonResponseMap, output);
    }

    /**
     * @description Maps saleData onto the output map, reconstructing the member
     *              and benefit structure from benefitArray.
     */
    private static Map<String, Object> buildSuccessResponse(
        Map<String, Object> jsonResponseMap, Map<String, Object> output
    ) {
        Object saleDataObj = jsonResponseMap.get(KEY_SALE_DATA);
        if (!(saleDataObj instanceof Map<String, Object>)) {
            return errorResponse(output, 'saleData missing from Quote Details response');
        }

        Map<String, Object> saleData = (Map<String, Object>) saleDataObj;
        Object benefitArray = saleData.get(KEY_BENEFIT_ARRAY);        

        List<Map<String, Object>> members = buildMembers(benefitArray);
        List<Map<String, Object>> beneficiaries = buildBeneficiaries(benefitArray);

        output.put(KEY_HAS_ERROR, false);
        output.put('saleReferenceId', jsonResponseMap.get('saleReferenceId'));
        output.put('policyNettPremium', saleData.get('policyNettPremium'));
        output.put('premiumFrequency', saleData.get('premiumFrequency'));
        output.put('policyStatus', saleData.get('status'));
        output.put('thirdPartyPolicy', saleData.get('thirdPartyPolicy'));
        output.put('members', members);
        output.put('beneficiaries', beneficiaries);
        output.put('membersTotalAmount', sumAcrossMembers(members, 'amount'));
        output.put('membersTotalMonthlyAmount', sumAcrossMembers(members, 'monthlyPremium'));

        return output;
    }

    /**
     * @description Groups benefitArray entries by roleplayer into member records.
     *              Grouping key is the roleplayer id number when present, falling
     *              back to name + date of birth + relationship, because the id
     *              number is optional for dependants.
     */
    private static List<Map<String, Object>> buildMembers(Object benefitArrayObj) {
        Map<String, Map<String, Object>> membersByKey = new Map<String, Map<String, Object>>();

        if (!(benefitArrayObj instanceof List<Object>)) {
            return new List<Map<String, Object>>();
        }

        for (Object benefitObj : (List<Object>) benefitArrayObj) {
            if (!(benefitObj instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> benefit = (Map<String, Object>) benefitObj;
            Map<String, Object> roleplayer = firstRoleplayer(benefit);

            if (roleplayer == null) {
                continue;
            }

            String memberId = buildMemberId(roleplayer);
            if (String.isBlank(memberId)) {
                continue;
            }

            if (!membersByKey.containsKey(memberId)) {
                membersByKey.put(memberId, buildMemberRecord(roleplayer, memberId));
            }

            Map<String, Object> benefitRecord = buildBenefitRecord(benefit);
            if (benefitRecord != null) {
                ((List<Object>) membersByKey.get(memberId).get('benefits')).add(benefitRecord);
            }
        }

        return finaliseMembers(membersByKey.values());
    }

    /**
     * @description Extracts beneficiaries from benefitArray. Beneficiaries appear
     *              as additional entries in each benefit's benefitRoleplayerArray,
     *              marked with benefitRoleplayerType 'Beneficiary', and repeat
     *              across every benefit belonging to the main member. They are
     *              deduplicated by name and date of birth.
     * @param benefitArrayObj The benefitArray from saleData
     * @return                Deduplicated list of beneficiary records
     */
    private static List<Map<String, Object>> buildBeneficiaries(Object benefitArrayObj) {
        Map<String, Map<String, Object>> beneficiariesByKey =
            new Map<String, Map<String, Object>>();

        if (!(benefitArrayObj instanceof List<Object>)) {
            return new List<Map<String, Object>>();
        }

        for (Object benefitObj : (List<Object>) benefitArrayObj) {
            if (!(benefitObj instanceof Map<String, Object>)) {
                continue;
            }
            Map<String, Object> benefit = (Map<String, Object>) benefitObj;

            Object roleplayerArrayObj = benefit.get(KEY_ROLEPLAYER_ARRAY);
            if (!(roleplayerArrayObj instanceof List<Object>)) {
                continue;
            }

            for (Object roleplayerObj : (List<Object>) roleplayerArrayObj) {
                if (!(roleplayerObj instanceof Map<String, Object>)) {
                    continue;
                }
                Map<String, Object> roleplayer = (Map<String, Object>) roleplayerObj;

                String roleplayerType = getString(roleplayer, 'benefitRoleplayerType');
                if (!ROLEPLAYER_TYPE_BENEFICIARY.equalsIgnoreCase(roleplayerType)) {
                    continue;
                }

                String beneficiaryKey = buildMemberId(roleplayer);
                if (!beneficiariesByKey.containsKey(beneficiaryKey)) {
                    beneficiariesByKey.put(beneficiaryKey, buildBeneficiaryRecord(roleplayer));
                }
            }
        }

        return finaliseBeneficiaries(beneficiariesByKey.values());
    }

    /**
     * @description Builds a beneficiary record in the shape the beneficiary screen
     *              consumes.
     * @param roleplayer The beneficiary roleplayer entry
     * @return           Beneficiary record
     */
    private static Map<String, Object> buildBeneficiaryRecord(Map<String, Object> roleplayer) {
        return new Map<String, Object>{
            'FirstName__c'          => getString(roleplayer, 'benefitRoleplayerFirstname'),
            'LastName__c'           => getString(roleplayer, 'benefitRoleplayerLastname'),
            'BirthDate__c'          => getString(roleplayer, 'benefitRoleplayerDateOfBirth'),
            'IdentityNumber__c'     => getString(roleplayer, 'benefitRoleplayerIdNumber'),
            'Gender__c'             => getString(roleplayer, 'benefitRoleplayerGender'),
            'EmailAddress__c'       => getString(roleplayer, 'benefitRoleplayerEmailAddress'),
            'PhoneNumber__c'        => getString(roleplayer, 'benefitRoleplayerCellphone'),
            'RelationshipToInsured' => getString(roleplayer, 'benefitRoleplayerRelationshipToOwner'),
            'Allocation__c'         => toDecimal(roleplayer.get('benefitRoleplayerPercentage')),
            'Beneficiary_Id__c'     => getString(roleplayer, 'benefitRoleplayerUniqueIdentifier'),
            'beneficiaryId'         => getString(roleplayer, 'benefitRoleplayerUniqueIdentifier')
        };
    }

    /**
     * @description Adds display name and positional key to each beneficiary.
     * @param beneficiaries The deduplicated beneficiary records
     * @return              Finalised beneficiary list
     */
    private static List<Map<String, Object>> finaliseBeneficiaries(
        List<Map<String, Object>> beneficiaries
    ) {
        List<Map<String, Object>> finalised = new List<Map<String, Object>>();
        Integer index = 1;

        for (Map<String, Object> beneficiary : beneficiaries) {
            beneficiary.put('fullName', buildFullName(beneficiary));
            beneficiary.put('key', index);
            beneficiary.put('index', String.valueOf(index).leftPad(2, '0'));
            finalised.add(beneficiary);
            index++;
        }

        return finalised;
    }

    /**
     * @description Builds the member id in the format Mobi expects:
     *              FirstName-LastName-YYYYMMDD. Derived rather than read from the
     *              response, because the Mobi GET does not return a member id.
     * @param roleplayer The benefit roleplayer entry
     * @return           The derived member id, or null when components are missing
     */
    private static String buildMemberId(Map<String, Object> roleplayer) {
        String firstName   = getString(roleplayer, 'benefitRoleplayerFirstname');
        String lastName    = getString(roleplayer, 'benefitRoleplayerLastname');
        String dateOfBirth = getString(roleplayer, 'benefitRoleplayerDateOfBirth');

        if (String.isBlank(lastName) || String.isBlank(dateOfBirth)) {
            return null;
        }
        String safeFirstName = firstName == null ? '' : firstName;
        return safeFirstName + '-' + lastName + '-' + dateOfBirth.replace('-', '');
        
    }

    /**
     * @description Returns the first roleplayer from a benefit, or null if absent.
     */
    private static Map<String, Object> firstRoleplayer(Map<String, Object> benefit) {
        Object roleplayerArrayObj = benefit.get(KEY_ROLEPLAYER_ARRAY);
        if (!(roleplayerArrayObj instanceof List<Object>)) {
            return null;
        }
        List<Object> roleplayers = (List<Object>) roleplayerArrayObj;
        if (roleplayers.isEmpty() || !(roleplayers[0] instanceof Map<String, Object>)) {
            return null;
        }
        return (Map<String, Object>) roleplayers[0];
    }

    

    /**
     * @description Builds a member record from a roleplayer entry.
     *              Translates the API's 'Main' relationship to the UI's 'Myself'.
     */
    private static Map<String, Object> buildMemberRecord(Map<String, Object> roleplayer, String memberId) {
        String relationship = getString(roleplayer, 'benefitRoleplayerRelationshipToOwner');
        if (RELATIONSHIP_MAIN_API.equalsIgnoreCase(relationship)) {
            relationship = RELATIONSHIP_MAIN_UI;
        }

        return new Map<String, Object>{
            'memberId'              => memberId,
            'Member_Id__c'          => memberId,
            'FirstName__c'          => getString(roleplayer, 'benefitRoleplayerFirstname'),
            'LastName__c'           => getString(roleplayer, 'benefitRoleplayerLastname'),
            'BirthDate__c'          => getString(roleplayer, 'benefitRoleplayerDateOfBirth'),
            'IdentityNumber__c'     => getString(roleplayer, 'benefitRoleplayerIdNumber'),
            'Gender__c'             => getString(roleplayer, 'benefitRoleplayerGender'),
            'EmailAddress__c'       => getString(roleplayer, 'benefitRoleplayerEmailAddress'),
            'PhoneNumber__c'        => getString(roleplayer, 'benefitRoleplayerCellphone'),
            'RelationshipToInsured' => relationship,
            'benefits'              => new List<Object>()
        };
    }

    /**
     * @description Maps a benefit entry to the data shape the LWCs merge onto their
     *              own static benefit definitions. Returns null when the benefit id
     *              has no INS_MemberRelation__mdt mapping, so unmapped benefits are
     *              skipped rather than breaking the whole retrieval.
     */
    private static Map<String, Object> buildBenefitRecord(Map<String, Object> benefit) {
        String publicBenefitId = getString(benefit, 'benefitId');
        INS_MemberRelation__mdt mapping = INS_DTO_BenefitMapping.getByPublicBenefitId(publicBenefitId);
        if (mapping == null) {
            System.debug(LoggingLevel.WARN,
                'No INS_MemberRelation__mdt mapping for benefitId: ' + publicBenefitId);
            return null;
        }

        return new Map<String, Object>{
            'id'             => publicBenefitId,
            'key'            => publicBenefitId + '.' + mapping.Benefit_Type__c,
            'type'           => mapping.Benefit_Type__c,
            'name'           => mapping.Benefit_Name__c,
            'enableDefault'  => mapping.Is_Default__c,
            'amount'         => toDecimal(benefit.get('benefitSumAssured')),
            'monthlyPremium' => toDecimal(benefit.get('benefitPremium'))
        };
    }

    /**
     * @description Adds per-member totals and a display name to each member record.
     */
    private static List<Map<String, Object>> finaliseMembers(List<Map<String, Object>> members) {
        List<Map<String, Object>> finalised = new List<Map<String, Object>>();
        Integer index = 1;

        for (Map<String, Object> member : members) {
            List<Object> benefits = (List<Object>) member.get('benefits');

            member.put('Cover__c', sumBenefitField(benefits, 'amount'));
            member.put('Monthly_Premium__c', sumBenefitField(benefits, 'monthlyPremium'));
            member.put('fullName', buildFullName(member));
            member.put('index', String.valueOf(index).leftPad(2, '0'));
            member.put('Add_additional_benefits__c', benefits.size() > 1);

            finalised.add(member);
            index++;
        }

        return finalised;
    }

    private static String buildFullName(Map<String, Object> member) {
        String firstName = getString(member, 'FirstName__c');
        String lastName  = getString(member, 'LastName__c');
        return ((firstName == null ? '' : firstName) + ' ' + (lastName == null ? '' : lastName)).trim();
    }

    private static Decimal sumBenefitField(List<Object> benefits, String fieldName) {
        Decimal total = 0;
        for (Object benefitObj : benefits) {
            Map<String, Object> benefit = (Map<String, Object>) benefitObj;
            Decimal value = (Decimal) benefit.get(fieldName);
            if (value != null) {
                total += value;
            }
        }
        return total;
    }

    private static Decimal sumAcrossMembers(List<Map<String, Object>> members, String benefitFieldName) {
        Decimal total = 0;
        for (Map<String, Object> member : members) {
            total += sumBenefitField((List<Object>) member.get('benefits'), benefitFieldName);
        }
        return total;
    }

    private static String extractErrorDescription(Map<String, Object> jsonResponseMap, Integer statusCode) {
        Object errorObj = jsonResponseMap.get(KEY_ERROR);
        if (errorObj instanceof Map<String, Object>) {
            Map<String, Object> errorMap = (Map<String, Object>) errorObj;
            Object description = errorMap.get('errorDescription');
            if (description != null) {
                return String.valueOf(description);
            }
        }
        return 'API returned status: ' + statusCode;
    }

    private static Map<String, Object> errorResponse(Map<String, Object> output, String message) {
        output.put(KEY_HAS_ERROR, true);
        output.put('ErrorResponse', message);
        return output;
    }

    private static String getString(Map<String, Object> source, String key) {
        Object value = source.get(key);
        return value == null ? null : String.valueOf(value);
    }

    private static Decimal toDecimal(Object value) {
        if (value == null) {
            return null;
        }
        String stringValue = String.valueOf(value);
        if (String.isBlank(stringValue)) {
            return null;
        }
        try {
            return Decimal.valueOf(stringValue);
        } catch (Exception e) {
            return null;
        }
    }
}