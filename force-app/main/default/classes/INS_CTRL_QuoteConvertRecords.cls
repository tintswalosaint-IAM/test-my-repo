/**
 * @description  Creates and updates the Salesforce records that follow a successful
 *               quote conversion at Mobi: Person Accounts and Party Profiles for
 *               members and beneficiaries, the Insurance Policy and its
 *               Participants, and updates to the Opportunity and Quote.
 *
 *               Runs in its own transaction, after the conversion has already been
 *               committed at Mobi. A failure here leaves the policy existing at
 *               Mobi with no Salesforce records — it must not roll back the
 *               conversion, and needs a retry or reconciliation path.
 *
 * @story        SFP-56577
 * @author       Irshad
 * Test Class    INS_CTRL_QuoteConvertRecords_TEST
 */
public without sharing class INS_CTRL_QuoteConvertRecords implements Callable {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_QuoteConvertRecords');

    private static final String ACTION_CREATE_RECORDS = 'createConversionRecords';

    private static final String RT_PERSON_PROSPECT = 'Person Account - Prospect';
    private static final String RT_PERSON_3RD_PARTY = 'Third Party';

    private static final String CUSTOMER_TYPE_IAM_LIBERTY = 'IAM Liberty';
    private static final String POLICY_STATUS_AWAITING_KYC = 'Awaiting KYC';
    private static final String QUOTE_STATUS_INACTIVE = 'Inactive';

    private static final String ROLE_PRIMARY_LIFE_ASSURED = 'Primary Life Assured';
    private static final String ROLE_BENEFICIARY = 'Beneficiary';

    private static Map<String, Id> rtCache;

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

        if (actionType == ACTION_CREATE_RECORDS) {
            return createConversionRecords(input, output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // =========================================================================
    // MAIN ORCHESTRATION
    // =========================================================================

    private static Object createConversionRecords(
        Map<String, Object> input, Map<String, Object> output
    ) {
        

        try {
            ConversionContext ctx = new ConversionContext(input);
            ctx.validate();
            
            // 1. Person Accounts for members (excluding the policyholder, who
            //    already has one) and beneficiaries
            Map<String, Id> accountIdsByPersonKey = createPersonAccounts(ctx);
            
            // 2. Party Profiles — needs Account Ids
            createPartyProfiles(ctx, accountIdsByPersonKey);

            // 3. Insurance Policy, linked to the policyholder's account
            Id policyId = createInsurancePolicy(ctx);
            

            // 4. Policy Participants — needs Policy Id and Account Ids
            createPolicyParticipants(ctx, policyId, accountIdsByPersonKey);

            // 5. Opportunity and Quote updates
            updateOpportunityAndQuote(ctx, policyId);

            output.put('conversionRecordsResponse', new Map<String, Object>{
                'hasError'          => false,
                'insurancePolicyId' => policyId,
                'accountsCreated'   => accountIdsByPersonKey.size()
            });

        } catch (Exception e) {
            output.put('conversionRecordsResponse', new Map<String, Object>{
                'hasError'     => true,
                'errorMessage' => 'Failed to create conversion records: ' + e.getMessage()
            });
        }

        return output;
    }

    // =========================================================================
    // 1. PERSON ACCOUNTS
    // =========================================================================

    /**
     * @description Creates Person Accounts for members (Prospect record type) and
     *              beneficiaries (3rd Party record type). The policyholder is
     *              skipped — their account was created at journey start.
     *              A person appearing as both member and beneficiary gets a single
     *              account with the member (Prospect) record type.
     * @return Map of person key (FirstName-LastName-YYYYMMDD) to Account Id
     */
    private static Map<String, Id> createPersonAccounts(ConversionContext ctx) {
        Map<String, Account> accountsByPersonKey = new Map<String, Account>();

        // Members first, so the Prospect record type wins on overlap
        for (Map<String, Object> member : ctx.members) {
            if (ctx.isPolicyholder(member)) {
                continue;
            }
            String personKey = buildPersonKey(member);
            if (String.isBlank(personKey) || accountsByPersonKey.containsKey(personKey)) {
                continue;
            }
            accountsByPersonKey.put(personKey, buildPersonAccount(member, RT_PERSON_PROSPECT));
        }

        for (Map<String, Object> beneficiary : ctx.beneficiaries) {
            String personKey = buildPersonKey(beneficiary);
            if (String.isBlank(personKey) || accountsByPersonKey.containsKey(personKey)) {
                continue;
            }
            accountsByPersonKey.put(personKey, buildPersonAccount(beneficiary, RT_PERSON_3RD_PARTY));
        }

        if (accountsByPersonKey.isEmpty()) {
            return new Map<String, Id>();
        }

        sbgplatform.fflib_SObjectUnitOfWork uow =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        for (Account acc : accountsByPersonKey.values()) {
            uow.registerNew(acc);
        }
        uow.commitWork();

        Map<String, Id> accountIdsByPersonKey = new Map<String, Id>();
        for (String personKey : accountsByPersonKey.keySet()) {
            accountIdsByPersonKey.put(personKey, accountsByPersonKey.get(personKey).Id);
        }
        return accountIdsByPersonKey;
    }

    private static Account buildPersonAccount(Map<String, Object> person, String recordTypeName) {
        Account acc = new Account();
        acc.RecordTypeId             = getRecordTypeId('Account', recordTypeName);
        acc.FirstName                = getString(person, 'FirstName__c');
        acc.LastName                 = getString(person, 'LastName__c');
        acc.PersonGender             = getString(person, 'Gender__c');
        acc.CMN_IdentityNumber__pc   = getString(person, 'IdentityNumber__c');
        acc.PersonEmail              = getString(person, 'EmailAddress__c');
        acc.PersonMobilePhone        = getString(person, 'PhoneNumber__c');
        acc.FinServ__CustomerType__c = CUSTOMER_TYPE_IAM_LIBERTY;

        Date birthDate = parseDate(getString(person, 'BirthDate__c'));
        if (birthDate != null) {
            acc.PersonBirthdate = birthDate;
        }

        return acc;
    }

    // =========================================================================
    // 2. PARTY PROFILES
    // =========================================================================

    private static void createPartyProfiles(
        ConversionContext ctx, Map<String, Id> accountIdsByPersonKey
    ) {
        try{
            List<PartyProfile> profiles = new List<PartyProfile>();

            // Policyholder — account already exists
            profiles.add(buildPartyProfile(ctx.policyholder, ctx.policyholderAccountId, ctx.opportunityId));            
            for (String personKey : accountIdsByPersonKey.keySet()) {
                Map<String, Object> person = ctx.findPersonByKey(personKey);
                if (person != null) {
                    profiles.add(buildPartyProfile(
                        person, accountIdsByPersonKey.get(personKey), ctx.opportunityId));
                }
            }

            if (profiles.isEmpty()) {
                return;
            }

            sbgplatform.fflib_SObjectUnitOfWork uow =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            for (PartyProfile profile : profiles) {
                uow.registerNew(profile);
            }
            uow.commitWork();
        }Catch(exception ex){
            Logger.error('createPartyProfiles exception'+ex.getMessage());   
        }
        
    }

    private static PartyProfile buildPartyProfile(
        Map<String, Object> person, Id accountId, Id opportunityId
    ) {
        return new PartyProfile(
            AccountId                          = accountId,
            Name                               = getString(person, 'FirstName__c')+getString(person, 'LastName__c'),
            FirstName                          = getString(person, 'FirstName__c'),
            LastName                           = getString(person, 'LastName__c'),
            Gender                             = getString(person, 'Gender__c'),
            PrimaryEmail                       = getString(person, 'EmailAddress__c'),
            PrimaryPhone                       = getString(person, 'PhoneNumber__c'),
            WI_PrimaryIdentificationName__c    = getString(person, 'IdentityNumber__c'),
            Opportunity__c                     = opportunityId
        );
    }

    // =========================================================================
    // 3. INSURANCE POLICY
    // =========================================================================

    private static Id createInsurancePolicy(ConversionContext ctx) {
        
        InsurancePolicy policy = new InsurancePolicy(
            NameInsuredId = ctx.policyholderAccountId,
            PolicyName    = ctx.policyNumber,
            Name          = ctx.policyNumber,
            Status        = POLICY_STATUS_AWAITING_KYC
        );

        sbgplatform.fflib_SObjectUnitOfWork uow =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        uow.registerNew(policy);
        uow.commitWork();

        return policy.Id;
    }

    // =========================================================================
    // 4. POLICY PARTICIPANTS
    // =========================================================================

    private static void createPolicyParticipants(
        ConversionContext ctx, Id policyId, Map<String, Id> accountIdsByPersonKey
    ) {
        List<InsurancePolicyParticipant> participants =
            new List<InsurancePolicyParticipant>();

        // Policyholder — Primary Life Assured
        participants.add(new InsurancePolicyParticipant(
            InsurancePolicyId          = policyId,
            PrimaryParticipantAccountId = ctx.policyholderAccountId,
            Role                       = ROLE_PRIMARY_LIFE_ASSURED
        ));

        for (Map<String, Object> beneficiary : ctx.beneficiaries) {
            Id beneficiaryAccountId = accountIdsByPersonKey.get(buildPersonKey(beneficiary));
            if (beneficiaryAccountId == null) {
                continue;
            }
            participants.add(new InsurancePolicyParticipant(
                InsurancePolicyId           = policyId,
                RelatedParticipantAccountId  = beneficiaryAccountId,
                PrimaryParticipantAccountId  = ctx.policyholderAccountId,
                Role                         = ROLE_BENEFICIARY
            ));
        }

        sbgplatform.fflib_SObjectUnitOfWork uow =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        for (InsurancePolicyParticipant participant : participants) {
            uow.registerNew(participant);
        }
        uow.commitWork();
    }

    // =========================================================================
    // 5. OPPORTUNITY AND QUOTE UPDATES
    // =========================================================================

    private static void updateOpportunityAndQuote(ConversionContext ctx, Id policyId) {
        sbgplatform.fflib_SObjectUnitOfWork uow =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();

        uow.registerDirty(new Opportunity(
            Id                        = ctx.opportunityId,
            LS_PolicyNumber__c = ctx.policyNumber
        ));

        if (ctx.quoteId != null) {
            uow.registerDirty(new Quote(
                Id     = ctx.quoteId,
                Status = POLICY_STATUS_AWAITING_KYC
            ));
        }

        uow.commitWork();
    }

    // =========================================================================
    // CONTEXT
    // =========================================================================

    /**
     * @description Parses and validates the action input, exposing the members,
     *              beneficiaries and record ids the conversion needs.
     */
    private class ConversionContext {
        public Id policyholderAccountId;
        public Id opportunityId;
        public Id quoteId;
        public String policyNumber;
        public Map<String, Object> policyholder;
        public List<Map<String, Object>> members      = new List<Map<String, Object>>();
        public List<Map<String, Object>> beneficiaries = new List<Map<String, Object>>();

        public ConversionContext(Map<String, Object> input) {
            policyholderAccountId = toId(input.get('ProspectAccountId'));
            opportunityId         = toId(input.get('OppId'));
            quoteId               = toId(input.get('QuoteId'));
            policyNumber          = resolvePolicyNumber(input);
            members               = resolveMembers(input);
            beneficiaries         = resolveBeneficiaries(input);

            for (Map<String, Object> member : members) {
                if (isPolicyholder(member)) {
                    policyholder = member;
                    break;
                }
            }
        }

	/**
	* @description Policy number arrives nested under quoteConversionResponse
	*              from the conversion IP; root is tolerated as a fallback.
	*/
	private String resolvePolicyNumber(Map<String, Object> input) {
		String value = getString(input, 'policyNumber');
		if (String.isNotBlank(value)) {
			return value;
		}
		Map<String, Object> conversionResponse =
			extractMap(input, 'quoteConversionResponse');
		return conversionResponse == null
			? null
			: getString(conversionResponse, 'policyNumber');
	}
    /**
         * @description Members come from MemberSummary — the journey-current list
         *              the customer confirmed on screen, rather than the retrieve
         *              snapshot in IPResult which predates any edits.
         */
        private List<Map<String, Object>> resolveMembers(Map<String, Object> input) {
            Map<String, Object> memberSummary = extractMap(input, 'MemberSummary');
            if (memberSummary != null) {
                List<Map<String, Object>> fromSummary = extractList(memberSummary, 'members');
                if (!fromSummary.isEmpty()) {
                    return fromSummary;
                }
            }

            Map<String, Object> ipResult = extractMap(input, 'IPResult');
            return ipResult == null
                ? new List<Map<String, Object>>()
                : extractList(ipResult, 'members');
        }

        /**
         * @description Beneficiaries come from BeneficiarySummary — the
         *              journey-current list. IPResult.beneficiaries is a fallback
         *              for a resumed quote where nothing was edited.
         */
        private List<Map<String, Object>> resolveBeneficiaries(Map<String, Object> input) {
            Map<String, Object> beneficiarySummary =
                extractMap(input, 'BeneficiarySummary');
            if (beneficiarySummary != null) {
                List<Map<String, Object>> fromSummary =
                    extractList(beneficiarySummary, 'members');
                if (!fromSummary.isEmpty()) {
                    return fromSummary;
                }
            }

            Map<String, Object> ipResult = extractMap(input, 'IPResult');
            return ipResult == null
                ? new List<Map<String, Object>>()
                : extractList(ipResult, 'beneficiaries');
        }


        public void validate() {
            if (policyholderAccountId == null) {
                throw new AuraHandledException('ProspectAccountId is required.');
            }
            if (opportunityId == null) {
                throw new AuraHandledException('OppId is required.');
            }
            if (String.isBlank(policyNumber)) {
                throw new AuraHandledException('policyNumber is required.');
            }
            if (policyholder == null) {
                throw new AuraHandledException('No policyholder found among the members.');
            }
        }

        public Boolean isPolicyholder(Map<String, Object> member) {
            String rel = getString(member, 'RelationshipToInsured');
            if (String.isBlank(rel)) {
                return false;
            }
            String normalised = rel.toUpperCase().replaceAll('\\s+', '');
            return normalised == 'MYSELF' || normalised == 'SOMEONEELSE'
                || normalised == 'SELF' || normalised == 'MAIN' || normalised == 'MAIN MEMBER';
        }

        public Map<String, Object> findPersonByKey(String personKey) {
            for (Map<String, Object> member : members) {
                if (personKey == buildPersonKey(member)) {
                    return member;
                }
            }
            for (Map<String, Object> beneficiary : beneficiaries) {
                if (personKey == buildPersonKey(beneficiary)) {
                    return beneficiary;
                }
            }
            return null;
        }

        private List<Map<String, Object>> extractList(Map<String, Object> input, String key) {
            List<Map<String, Object>> results = new List<Map<String, Object>>();
            Object listObj = input.get(key);
            if (!(listObj instanceof List<Object>)) {
                return results;
            }
            for (Object obj : (List<Object>) listObj) {
                if (obj instanceof Map<String, Object>) {
                    results.add((Map<String, Object>) obj);
                }
            }
            return results;
        }
		private Map<String, Object> extractMap(Map<String, Object> source, String key) {
            Object value = source.get(key);
            return value instanceof Map<String, Object>
                ? (Map<String, Object>) value
                : null;
        }
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

	

	
    /**
     * @description Builds a stable key for a person — FirstName-LastName-YYYYMMDD —
     *              used to deduplicate across the member and beneficiary lists.
     */
    private static String buildPersonKey(Map<String, Object> person) {
        String firstName = getString(person, 'FirstName__c');
        String lastName  = getString(person, 'LastName__c');
        String birthDate = getString(person, 'BirthDate__c');

        if (String.isBlank(lastName) || String.isBlank(birthDate)) {
            return null;
        }
        return (firstName == null ? '' : firstName) + '-' + lastName
            + '-' + birthDate.replace('-', '');
    }

    private static Id getRecordTypeId(String sObjectName, String rtName) {
        if (rtCache == null) {
            rtCache = new Map<String, Id>();
        }
        String cacheKey = sObjectName + ':' + rtName;
        if (!rtCache.containsKey(cacheKey)) {
            Schema.RecordTypeInfo info = Schema.SObjectType.Account
                .getRecordTypeInfosByName().get(rtName);
            if (info == null) {
                throw new AuraHandledException('Record type not found: ' + rtName);
            }
            rtCache.put(cacheKey, info.getRecordTypeId());
        }
        return rtCache.get(cacheKey);
    }

    private static Date parseDate(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        String cleanValue = value.contains('T') ? value.substringBefore('T') : value;
        try {
            return Date.valueOf(cleanValue);
        } catch (Exception e) {
            return null;
        }
    }

    private static Id toId(Object value) {
        if (value == null || String.isBlank(String.valueOf(value))) {
            return null;
        }
        try {
            return Id.valueOf(String.valueOf(value));
        } catch (Exception e) {
            return null;
        }
    }

    private static String getString(Map<String, Object> source, String key) {
        Object value = source.get(key);
        return value == null ? null : String.valueOf(value);
    }
}