/***************************************************************************************
@Name of the Class : INS_PartyProfileRemoteAction
@Description : SFP-58522 Remote Action to create or retrieve Person Accounts (Third_Party)
               and Party Profiles (KYC) for beneficiaries, and find-or-create the
               policyholder Party Profile, in the Insurance AR beneficiary flow.
@Author : Shams
@Created Date : 2026-06-15
***************************************************************************************
* Last Modified By  Shams
* Last Modified Date 2026-06-15
* Last Modified Description: Initial Version
* User Story : SFP-58522
****************************************************************************************/
global without sharing class INS_PartyProfileRemoteAction implements Callable {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PartyProfileRemoteAction');

    private static final String KEY_IDENTITY_NUMBER = 'IdentityNumber__c';
    private static final String KEY_FIRST_NAME      = 'FirstName__c';
    private static final String KEY_LAST_NAME       = 'LastName__c';
    private static final String KEY_BIRTH_DATE      = 'BirthDate__c';
    private static final String KEY_PHONE_NUMBER    = 'PhoneNumber__c';
    private static final String KEY_EMAIL_ADDRESS   = 'EmailAddress__c';
    private static final String KEY_GENDER          = 'Gender__c';
    private static final String KEY_ID_TYPE         = 'IdType__c';
    private static final String KEY_BENEFICIARY_ID  = 'Beneficiary_Id__c';

    /**
    * @description Callable entry point — dispatches to the appropriate handler based on actionType
    * @author Shams | 2026-06-15
    * @param actionType Action identifier — supports 'processBeneficiaries'
    * @param args Map containing 'input' and 'output' maps
    * @return Object result map
    **/
    global Object call(String actionType, Map<String, Object> args) {
        Map<String, Object> inputMap  = (Map<String, Object>) args.get('input');
        Map<String, Object> outputMap = (Map<String, Object>) args.get('output');
        if (actionType == 'processBeneficiaries') {
            return processBeneficiaries(inputMap, outputMap);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    /**
    * @description AuraEnabled wrapper — catches unhandled exceptions and re-throws as AuraHandledException
    * @author Shams | 2026-06-15
    * @param inputMap Map of input values from the Integration Procedure
    * @param outputMap Map to populate with results
    * @return Object output map with BeneficiarySummary
    **/
    @AuraEnabled(cacheable=false)
    public static Object processBeneficiaries(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        try {
            return processBeneficiariesInternal(inputMap, outputMap);
        } catch (Exception caughtException) {
            LOGGER.error('INS_PartyProfileRemoteAction.processBeneficiaries ' + caughtException.getMessage() + ' Line Exception ' + caughtException.getLineNumber() + ' Stack trace: ' + caughtException.getStackTraceString());
            throw new AuraHandledException(caughtException.getTypeName() + ' (line ' + caughtException.getLineNumber() + '): ' + caughtException.getMessage());
        }
    }

    /**
    * @description Orchestrates account lookup/creation, party profile lookup/creation,
    *              party profile linking, and enriched member output
    * @author Shams | 2026-06-15
    * @param inputMap Map containing 'OpportunityId', 'Country', 'PolicyholderInfo' and 'BeneficiarySummary'
    * @param outputMap Map to populate with enriched BeneficiarySummary and PolicyholderPartyProfileId
    * @return Object output map
    **/
    private static Object processBeneficiariesInternal(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        LOGGER.debug('INS_PartyProfileRemoteAction.processBeneficiariesInternal - inputMap keys: {0}', new List<Object>{ inputMap.keySet() });

        String opportunityId = (String) inputMap.get('OpportunityId');
        String country       = (String) inputMap.get('Country');

        Map<String, Object> policyholderInfoMap = (Map<String, Object>) inputMap.get('PolicyholderInfo');
        if (policyholderInfoMap == null) {
            LOGGER.warn('INS_PartyProfileRemoteAction - PolicyholderInfo is missing, aborting');
            outputMap.put('error', 'PolicyholderInfo is missing');
            return outputMap;
        }
        String policyholderPartyProfileId = findOrCreatePolicyholderPartyProfile(policyholderInfoMap, opportunityId);
        LOGGER.debug('INS_PartyProfileRemoteAction - policyholderPartyProfileId resolved: {0}', new List<Object>{ policyholderPartyProfileId });

        Map<String, Object> beneficiarySummaryMap = (Map<String, Object>) inputMap.get('BeneficiarySummary');
        if (beneficiarySummaryMap == null) {
            LOGGER.warn('INS_PartyProfileRemoteAction - BeneficiarySummary is missing, aborting');
            outputMap.put('error', 'BeneficiarySummary is missing');
            return outputMap;
        }

        List<Map<String, Object>> memberList = toMemberList(beneficiarySummaryMap.get('members'));
        LOGGER.debug('INS_PartyProfileRemoteAction - raw BeneficiarySummary.members: {0}', new List<Object>{ JSON.serialize(beneficiarySummaryMap.get('members')) });
        LOGGER.debug('INS_PartyProfileRemoteAction - memberList count: {0}', new List<Object>{ memberList.size() });
        if (memberList.isEmpty()) {
            LOGGER.warn('INS_PartyProfileRemoteAction - memberList is empty, skipping account/party profile processing');
            outputMap.put('BeneficiarySummary', beneficiarySummaryMap);
            outputMap.put('PolicyholderPartyProfileId', policyholderPartyProfileId);
            return outputMap;
        }

        Set<String> identityNumberSet = collectIdentityNumbers(memberList);
        Id accountRecordTypeId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName().get('Third_Party').getRecordTypeId();

        Map<String, Id> identityNumberToAccountIdMap = buildAccountLookupMap(memberList, identityNumberSet, accountRecordTypeId);
        LOGGER.debug('INS_PartyProfileRemoteAction - identityNumbers: {0}, accounts matched before create: {1}', new List<Object>{ identityNumberSet.size(), identityNumberToAccountIdMap.size() });
        createMissingAccounts(memberList, identityNumberToAccountIdMap, accountRecordTypeId, country);
        LOGGER.debug('INS_PartyProfileRemoteAction - accounts total after createMissingAccounts: {0}', new List<Object>{ identityNumberToAccountIdMap.size() });

        Set<Id> allBeneficiaryAccountIds = new Set<Id>(identityNumberToAccountIdMap.values());
        Map<String, Id> identityNumberToPartyProfileIdMap = buildPartyProfileLookupMap(allBeneficiaryAccountIds, identityNumberSet);
        LOGGER.debug('INS_PartyProfileRemoteAction - party profiles matched before create: {0}', new List<Object>{ identityNumberToPartyProfileIdMap.size() });
        createMissingPartyProfiles(memberList, identityNumberToPartyProfileIdMap);
        LOGGER.debug('INS_PartyProfileRemoteAction - party profiles total after createMissingPartyProfiles: {0}', new List<Object>{ identityNumberToPartyProfileIdMap.size() });

        updateLinkedPartyProfiles(memberList, identityNumberToAccountIdMap, identityNumberToPartyProfileIdMap, policyholderPartyProfileId, opportunityId);

        List<Object> enrichedMemberList = buildEnrichedMemberList(memberList, identityNumberToAccountIdMap, identityNumberToPartyProfileIdMap);
        outputMap.put('BeneficiarySummary', new Map<String, Object>{
            'members'         => enrichedMemberList,
            'totalAllocation' => beneficiarySummaryMap.get('totalAllocation')
        });
        outputMap.put('PolicyholderPartyProfileId', policyholderPartyProfileId);
        LOGGER.debug('INS_PartyProfileRemoteAction - complete. enriched members: {0}, PolicyholderPartyProfileId: {1}', new List<Object>{ enrichedMemberList.size(), policyholderPartyProfileId });
        LOGGER.debug('INS_PartyProfileRemoteAction - enriched members detail: {0}', new List<Object>{ JSON.serialize(enrichedMemberList) });
        return outputMap;
    }

    /**
    * @description Collects all non-blank identity numbers from the member list
    * @author Shams | 2026-06-15
    * @param memberList Parsed list of beneficiary member maps
    * @return Set of identity number strings
    **/
    private static Set<String> collectIdentityNumbers(List<Map<String, Object>> memberList) {
        Set<String> identityNumberSet = new Set<String>();
        for (Map<String, Object> memberMap : memberList) {
            String identityNumber = (String) memberMap.get(KEY_IDENTITY_NUMBER);
            if (String.isNotBlank(identityNumber)) {
                identityNumberSet.add(identityNumber);
            }
        }
        return identityNumberSet;
    }

    /**
    * @description Builds a map of identity number → Account Id using two lookup strategies:
    *              1) bulk lookup by identity number, 2) per-member fallback by name + DOB.
    *              Mirrors INS_Get_Account.selectAccountByName() steps 1 and 2.
    * @author Shams | 2026-06-15
    * @param memberList Member maps to look up
    * @param identityNumberSet Pre-collected identity numbers for bulk query
    * @param accountRecordTypeId Record Type Id for Third_Party accounts
    * @return Map from identity number to existing Account Id
    **/
    private static Map<String, Id> buildAccountLookupMap(List<Map<String, Object>> memberList, Set<String> identityNumberSet, Id accountRecordTypeId) {
        SEL_Account accountSelector = new SEL_Account();
        Map<String, Id> identityNumberToAccountIdMap = new Map<String, Id>();

        for (Account account : accountSelector.selectByIdentityNumbersAndRecordType(identityNumberSet, accountRecordTypeId)) {
            identityNumberToAccountIdMap.put(account.CMN_IdentityNumber__pc, account.Id);
        }

        for (Map<String, Object> memberMap : memberList) {
            String identityNumber = (String) memberMap.get(KEY_IDENTITY_NUMBER);
            if (String.isBlank(identityNumber) || identityNumberToAccountIdMap.containsKey(identityNumber)) {
                continue;
            }
            String firstName       = (String) memberMap.get(KEY_FIRST_NAME);
            String lastName        = (String) memberMap.get(KEY_LAST_NAME);
            String birthdateString = toIsoDate((String) memberMap.get(KEY_BIRTH_DATE));
            if (String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(birthdateString)) {
                continue;
            }
            List<Account> matchedAccounts = accountSelector.selectByNameDobAndRecordType(
                firstName, lastName, Date.valueOf(birthdateString), accountRecordTypeId
            );
            if (!matchedAccounts.isEmpty()) {
                identityNumberToAccountIdMap.put(identityNumber, matchedAccounts[0].Id);
            }
        }
        return identityNumberToAccountIdMap;
    }

    /**
    * @description Creates Third_Party Person Account records for members still unmatched after
    *              both lookup steps, then stamps ExternalCIFId__c using a minimal stub update
    *              so the CMN_TRH_Account trigger-set PersonIndividualId is never overwritten.
    * @author Shams | 2026-06-15
    * @param memberList Full member list
    * @param identityNumberToAccountIdMap In-out map — updated in place with newly inserted Account Ids
    * @param accountRecordTypeId Record Type Id for Third_Party accounts
    * @param country Country code to stamp on new accounts
    **/
    private static void createMissingAccounts(List<Map<String, Object>> memberList, Map<String, Id> identityNumberToAccountIdMap, Id accountRecordTypeId, String country) {
        List<Account> newAccountList = new List<Account>();
        for (Map<String, Object> memberMap : memberList) {
            String identityNumber = (String) memberMap.get(KEY_IDENTITY_NUMBER);
            if (String.isBlank(identityNumber) || identityNumberToAccountIdMap.containsKey(identityNumber)) {
                continue;
            }
            newAccountList.add(buildNewAccount(memberMap, accountRecordTypeId, country));
        }
        if (newAccountList.isEmpty()) {
            return;
        }
        sbgplatform.fflib_SObjectUnitOfWork unitOfWorkAccounts =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        unitOfWorkAccounts.registerNew(newAccountList);
        unitOfWorkAccounts.commitWork();
        if (!Schema.sObjectType.Account.isUpdateable()) {
            throw new AuraHandledException('Insufficient permissions to update Account records');
        }
        // Stamp ExternalCIFId__c = Account.Id immediately after insert.
        // Use a minimal stub (Id + ExternalCIFId__c only) so that the full-object
        // update does not clear PersonIndividualId that the CMN_TRH_Account trigger
        // just set — null fields on the in-memory objects would overwrite the DB value.
        List<Account> cifStamp = new List<Account>();
        for (Account account : newAccountList) {
            identityNumberToAccountIdMap.put(account.CMN_IdentityNumber__pc, account.Id);
            cifStamp.add(new Account(Id = account.Id, ExternalCIFId__c = account.Id));
        }
        update cifStamp;
    }

    /**
    * @description Builds a new Third_Party Person Account record from a beneficiary member map.
    * @author Shams | 2026-06-15
    * @param memberMap Beneficiary member map from OmniScript
    * @param accountRecordTypeId Third_Party record type Id
    * @param country Country code to stamp as ExternalCIFCountry__c
    * @return New Account ready for insert
    **/
    private static Account buildNewAccount(Map<String, Object> memberMap, Id accountRecordTypeId, String country) {
        String lastName        = (String) memberMap.get(KEY_LAST_NAME);
        String birthdateString = toIsoDate((String) memberMap.get(KEY_BIRTH_DATE));
        String phoneNumber     = (String) memberMap.get(KEY_PHONE_NUMBER);
        return new Account(
            FirstName                = (String) memberMap.get(KEY_FIRST_NAME),
            LastName                 = String.isNotBlank(lastName) ? lastName : 'Unknown',
            CMN_IdentityNumber__pc   = (String) memberMap.get(KEY_IDENTITY_NUMBER),
            PersonBirthdate          = String.isNotBlank(birthdateString) ? Date.valueOf(birthdateString) : null,
            Phone                    = phoneNumber,
            PersonMobilePhone        = phoneNumber,
            PersonHomePhone          = phoneNumber,
            PersonEmail              = (String) memberMap.get(KEY_EMAIL_ADDRESS),
            FinServ__Gender__pc      = toTitleCase((String) memberMap.get(KEY_GENDER)),
            FinServ__KYCStatus__c    = 'In Queue',
            Receive_Marketing__c     = true,
            ExternalCIFCountry__c    = String.isNotBlank(country) ? country : null,
            RecordTypeId             = accountRecordTypeId
        );
    }

    /**
    * @description Bulk-finds existing Party Profiles for all beneficiary account Ids.
    *              Only entries whose WI_PrimaryIdentificationName__c is in the identity number set are mapped.
    * @author Shams | 2026-06-15
    * @param accountIds Set of beneficiary Account Ids to query against
    * @param identityNumberSet Set of identity numbers used to filter results
    * @return Map from identity number to existing Party Profile Id
    **/
    private static Map<String, Id> buildPartyProfileLookupMap(Set<Id> accountIds, Set<String> identityNumberSet) {
        Map<String, Id> identityNumberToPartyProfileIdMap = new Map<String, Id>();
        if (accountIds.isEmpty()) {
            return identityNumberToPartyProfileIdMap;
        }
        for (PartyProfile existingPartyProfile : new SEL_PartyProfile().selectByAccountIds(accountIds)) {
            if (String.isNotBlank(existingPartyProfile.WI_PrimaryIdentificationName__c)
                    && identityNumberSet.contains(existingPartyProfile.WI_PrimaryIdentificationName__c)) {
                identityNumberToPartyProfileIdMap.put(existingPartyProfile.WI_PrimaryIdentificationName__c, existingPartyProfile.Id);
            }
        }
        return identityNumberToPartyProfileIdMap;
    }

    /**
    * @description Calls KYC_CTRL_PartyProfile.processKycTest for each beneficiary that does not
    *              yet have a Party Profile, then records the new Party Profile Id in the map.
    *              KYC_CTRL_PartyProfile is single-record by design; all checks are disabled.
    * @author Shams | 2026-06-15
    * @param memberList Full member list
    * @param identityNumberToPartyProfileIdMap In-out map — updated in place with new Party Profile Ids
    **/
    private static void createMissingPartyProfiles(List<Map<String, Object>> memberList, Map<String, Id> identityNumberToPartyProfileIdMap) {
        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        for (Map<String, Object> memberMap : memberList) {
            String identityNumber = (String) memberMap.get(KEY_IDENTITY_NUMBER);
            if (String.isBlank(identityNumber) || identityNumberToPartyProfileIdMap.containsKey(identityNumber)) {
                continue;
            }
            KYC_DTO_ClientWrapper kycWrapper = buildWrapper(
                (String) memberMap.get(KEY_FIRST_NAME), (String) memberMap.get(KEY_LAST_NAME), identityNumber,
                toIsoDate((String) memberMap.get(KEY_BIRTH_DATE)), (String) memberMap.get(KEY_PHONE_NUMBER),
                (String) memberMap.get(KEY_EMAIL_ADDRESS), (String) memberMap.get(KEY_ID_TYPE),
                toTitleCase((String) memberMap.get(KEY_GENDER))
            );
            KYC_DTO_ClientWrapper.Response kycResponse =
                KYC_CTRL_PartyProfile.processKycTest(JSON.serialize(kycWrapper), true);
            if (kycResponse.kycProfileId != null) {
                identityNumberToPartyProfileIdMap.put(identityNumber, kycResponse.kycProfileId);
            }
        }
    }

    /**
    * @description Sets AccountId, RelatedPartyProfileId, Opportunity link, and contact fields
    *              on all beneficiary Party Profiles. Covers both newly created and pre-existing PPs.
    *              Field set mirrors INS_PLI_ProcessKYCRecords.initiateKYCProcess.
    * @author Shams | 2026-06-15
    * @param memberList Full member list
    * @param identityNumberToAccountIdMap Identity number → Account Id
    * @param identityNumberToPartyProfileIdMap Identity number → Party Profile Id
    * @param policyholderPartyProfileId Party Profile Id for the policyholder (used as RelatedPartyProfileId)
    * @param opportunityId Opportunity Id to stamp on each Party Profile
    **/
    private static void updateLinkedPartyProfiles(
        List<Map<String, Object>> memberList,
        Map<String, Id> identityNumberToAccountIdMap,
        Map<String, Id> identityNumberToPartyProfileIdMap,
        String policyholderPartyProfileId,
        String opportunityId
    ) {
        List<PartyProfile> partyProfilesToUpdate = new List<PartyProfile>();
        for (Map<String, Object> memberMap : memberList) {
            String identityNumber   = (String) memberMap.get(KEY_IDENTITY_NUMBER);
            if (String.isBlank(identityNumber)) {
                continue;
            }
            Id partyProfileId       = identityNumberToPartyProfileIdMap.get(identityNumber);
            Id beneficiaryAccountId = identityNumberToAccountIdMap.get(identityNumber);
            if (partyProfileId == null) {
                continue;
            }
            partyProfilesToUpdate.add(buildPartyProfileRecord(
                memberMap, partyProfileId, beneficiaryAccountId, policyholderPartyProfileId, opportunityId
            ));
        }
        if (!partyProfilesToUpdate.isEmpty()) {
            sbgplatform.fflib_SObjectUnitOfWork unitOfWorkPartyProfiles =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            for (PartyProfile partyProfileToUpdate : partyProfilesToUpdate) {
                unitOfWorkPartyProfiles.registerDirty(partyProfileToUpdate);
            }
            unitOfWorkPartyProfiles.commitWork();
        }
    }

    /**
    * @description Builds a PartyProfile record for a beneficiary with all contact and linking fields set.
    *              Field set mirrors INS_PLI_ProcessKYCRecords.initiateKYCProcess.
    * @author Shams | 2026-06-15
    * @param memberMap Beneficiary member map
    * @param partyProfileId Id of the Party Profile to update
    * @param beneficiaryAccountId Account Id linked to this Party Profile
    * @param policyholderPartyProfileId Policyholder Party Profile Id (used as RelatedPartyProfileId)
    * @param opportunityId Opportunity Id to stamp
    * @return PartyProfile record ready for registerDirty
    **/
    private static PartyProfile buildPartyProfileRecord(
        Map<String, Object> memberMap,
        Id partyProfileId,
        Id beneficiaryAccountId,
        String policyholderPartyProfileId,
        String opportunityId
    ) {
        String firstName           = (String) memberMap.get(KEY_FIRST_NAME);
        String lastName            = (String) memberMap.get(KEY_LAST_NAME);
        String birthdateString     = toIsoDate((String) memberMap.get(KEY_BIRTH_DATE));
        String primaryEmailAddress = (String) memberMap.get(KEY_EMAIL_ADDRESS);
        String primaryPhone        = (String) memberMap.get(KEY_PHONE_NUMBER);
        String gender              = toTitleCase((String) memberMap.get(KEY_GENDER));
        return new PartyProfile(
            Id                              = partyProfileId,
            AccountId                       = beneficiaryAccountId,
            RelatedPartyProfileId           = policyholderPartyProfileId,
            Opportunity__c                  = String.isNotBlank(opportunityId) ? opportunityId : null,
            Name                            = (String.isNotBlank(firstName) ? firstName + ' ' : '') + (String.isNotBlank(lastName) ? lastName : ''),
            FirstName                       = firstName,
            LastName                        = lastName,
            Gender                          = gender,
            PrimaryPhone                    = String.isNotBlank(primaryPhone) ? primaryPhone : null,
            DateOfBirth                     = String.isNotBlank(birthdateString) ? Date.valueOf(birthdateString) : null,
            PrimaryEmail                    = String.isNotBlank(primaryEmailAddress) ? primaryEmailAddress : null,
            WI_PrimaryIdentificationName__c = (String) memberMap.get(KEY_IDENTITY_NUMBER)
        );
    }

    /**
    * @description Builds the enriched member list by stamping beneficiaryAccountId,
    *              beneficiaryPartyProfileId, and beneficiaryId onto each member map.
    * @author Shams | 2026-06-15
    * @param memberList Full member list
    * @param identityNumberToAccountIdMap Identity number → Account Id
    * @param identityNumberToPartyProfileIdMap Identity number → Party Profile Id
    * @return List of enriched member maps
    **/
    private static List<Object> buildEnrichedMemberList(
        List<Map<String, Object>> memberList,
        Map<String, Id> identityNumberToAccountIdMap,
        Map<String, Id> identityNumberToPartyProfileIdMap
    ) {
        List<Object> processedMemberList = new List<Object>();
        for (Map<String, Object> memberMap : memberList) {
            String identityNumber = (String) memberMap.get(KEY_IDENTITY_NUMBER);
            Map<String, Object> enrichedMemberMap = new Map<String, Object>(memberMap);
            enrichedMemberMap.put('beneficiaryAccountId', identityNumberToAccountIdMap.get(identityNumber));
            enrichedMemberMap.put('beneficiaryPartyProfileId', identityNumberToPartyProfileIdMap.get(identityNumber));
            // beneficiaryId (camelCase, no __c) is required by the BeneficiaryComplianceScreening IP URL template
            enrichedMemberMap.put('beneficiaryId', memberMap.get(KEY_BENEFICIARY_ID));
            processedMemberList.add(enrichedMemberMap);
        }
        return processedMemberList;
    }

    /**
    * @description Find or create a Party Profile for the policyholder account and associate it
    *              with the given Opportunity. Mirrors INS_PLI_ProcessKYCRecords.initiateKYCProcess:
    *              if a Party Profile already exists for the account it is updated with the Opportunity
    *              link and its Id is returned; otherwise a new Party Profile is inserted and returned.
    * @author Shams | 2026-06-15
    * @param policyholderInfoMap Map with keys: AccountId, FirstName, LastName, Gender, Email, Phone, IdNumber
    * @param opportunityId Salesforce Id of the Opportunity to associate with the policyholder Party Profile
    * @return String Party Profile Id, or null if AccountId is blank
    **/
    private static String findOrCreatePolicyholderPartyProfile(Map<String, Object> policyholderInfoMap, String opportunityId) {
        String policyholderAccountId = (String) policyholderInfoMap.get('AccountId');
        if (String.isBlank(policyholderAccountId)) {
            return null;
        }

        List<PartyProfile> existingPartyProfiles = new SEL_PartyProfile().selectByAccountId(policyholderAccountId);
        if (!existingPartyProfiles.isEmpty()) {
            PartyProfile existingPolicyholderPartyProfile = existingPartyProfiles[0];
            if (String.isNotBlank(opportunityId)) {
                sbgplatform.fflib_SObjectUnitOfWork uow =
                    (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
                uow.registerDirty(new PartyProfile(
                    Id             = existingPolicyholderPartyProfile.Id,
                    Opportunity__c = opportunityId
                ));
                uow.commitWork();
            }
            return existingPolicyholderPartyProfile.Id;
        }

        String firstName = (String) policyholderInfoMap.get('FirstName');
        String lastName  = (String) policyholderInfoMap.get('LastName');
        PartyProfile newPartyProfile = new PartyProfile(
            AccountId                       = policyholderAccountId,
            Name                            = (String.isNotBlank(firstName) ? firstName + ' ' : '')
                                              + (String.isNotBlank(lastName) ? lastName : ''),
            FirstName                       = firstName,
            LastName                        = lastName,
            Gender                          = (String) policyholderInfoMap.get('Gender'),
            PrimaryEmail                    = (String) policyholderInfoMap.get('Email'),
            PrimaryPhone                    = (String) policyholderInfoMap.get('Phone'),
            WI_PrimaryIdentificationName__c = (String) policyholderInfoMap.get('IdNumber'),
            Opportunity__c                  = opportunityId
        );
        sbgplatform.fflib_SObjectUnitOfWork uow =
            (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
        uow.registerNew(newPartyProfile);
        uow.commitWork();
        return newPartyProfile.Id;
    }

    /**
    * @description Builds a KYC_DTO_ClientWrapper for a beneficiary with all checks disabled.
    *              Used to call KYC_CTRL_PartyProfile.processKycTest for Party Profile creation only.
    * @author Shams | 2026-06-15
    * @param firstName Beneficiary first name
    * @param lastName Beneficiary last name
    * @param idNumber National ID / passport number
    * @param birthdate ISO date string (yyyy-MM-dd)
    * @param phone Primary phone number
    * @param email Primary email address
    * @param primaryIdType ID document type (e.g. 'National Identity Document')
    * @param gender Gender string (title-cased)
    * @return KYC_DTO_ClientWrapper populated wrapper ready for JSON.serialize
    **/
    private static KYC_DTO_ClientWrapper buildWrapper(
        String firstName, String lastName, String idNumber,
        String birthdate, String phone, String email, String primaryIdType, String gender
    ) {
        KYC_DTO_ClientDetails clientDetails = new KYC_DTO_ClientDetails();
        clientDetails.firstName          = String.isNotBlank(firstName) ? firstName : 'Unknown';
        clientDetails.lastName           = String.isNotBlank(lastName)  ? lastName  : 'Unknown';
        clientDetails.dob                = birthdate;
        clientDetails.idNumber           = idNumber;
        clientDetails.primaryIdType      = primaryIdType;
        clientDetails.primaryPhone       = phone;
        clientDetails.primaryEmail       = email;
        clientDetails.gender             = gender;
        clientDetails.ficPip             = false;
        clientDetails.ficPipRel          = false;
        clientDetails.ficPipRelFirstName = '';
        clientDetails.ficPipRelLastName  = '';
        clientDetails.isEmployed         = false;

        KYC_DTO_ClientWrapper.Checks kycChecks = new KYC_DTO_ClientWrapper.Checks();
        kycChecks.idValidation             = false;
        kycChecks.idv                      = false;
        kycChecks.assessment               = new KYC_DTO_ClientWrapper.Assessment();
        kycChecks.assessment.PEP_Screening = false;
        kycChecks.assessment.CRA           = false;
        kycChecks.assessment.screening     = false;

        KYC_DTO_ClientWrapper kycWrapper = new KYC_DTO_ClientWrapper();
        kycWrapper.clientDetails = clientDetails;
        kycWrapper.checks        = kycChecks;
        return kycWrapper;
    }

    /**
    * @description Normalises the members collection to a List regardless of whether the
    *              OmniScript delivers it as a JSON array or an integer-keyed map
    * @author Shams | 2026-06-15
    * @param membersObject Raw members value from BeneficiarySummary (List<Object> or Map<String,Object>)
    * @return List<Map<String, Object>> ordered list of member maps
    **/
    private static List<Map<String, Object>> toMemberList(Object membersObject) {
        List<Map<String, Object>> memberList = new List<Map<String, Object>>();
        if (membersObject == null) {
            return memberList;
        }
        if (membersObject instanceof List<Object>) {
            for (Object memberObject : (List<Object>) membersObject) {
                memberList.add((Map<String, Object>) memberObject);
            }
        } else if (membersObject instanceof Map<String, Object>) {
            Map<String, Object> keyedMembersMap = (Map<String, Object>) membersObject;
            List<String> memberKeys = new List<String>(keyedMembersMap.keySet());
            memberKeys.sort();
            for (String memberKey : memberKeys) {
                memberList.add((Map<String, Object>) keyedMembersMap.get(memberKey));
            }
        }
        return memberList;
    }

    /**
    * @description Normalises a date string to yyyy-MM-dd for use with Date.valueOf().
    *              Handles formats: yyyy-MM-ddTHH:mm:ssZ | MM/dd/yyyy | yyyy-MM-dd
    * @author Shams | 2026-06-15
    * @param rawDateString Raw date string from OmniScript or IP payload
    * @return String ISO date string (yyyy-MM-dd), or the original value if blank
    **/
    private static String toIsoDate(String rawDateString) {
        if (String.isBlank(rawDateString)) {
            return rawDateString;
        }
        if (rawDateString.contains('T')) {
            return rawDateString.substringBefore('T');
        }
        if (rawDateString.contains('/')) {
            List<String> dateParts = rawDateString.split('/');
            return dateParts[2] + '-' + dateParts[0] + '-' + dateParts[1];
        }
        return rawDateString;
    }

    /**
    * @description Converts an all-caps gender string from the OmniScript (e.g. 'MALE', 'FEMALE')
    *              to the title-case format expected by the FinServ__Gender__pc picklist
    * @author Shams | 2026-06-15
    * @param rawString Raw gender string (e.g. 'MALE', 'FEMALE', or already cased)
    * @return String Title-cased value (e.g. 'Male', 'Female'), or null if blank
    **/
    private static String toTitleCase(String rawString) {
        if (String.isBlank(rawString)) {
            return null;
        }
        return rawString.substring(0, 1).toUpperCase() + rawString.substring(1).toLowerCase();
    }
}