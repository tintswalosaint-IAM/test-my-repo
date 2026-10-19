/***************************************************************************************
@Name of the Class : INS_PartyConsentRemoteAction
@Description : SFP-58864 Remote Action to create 4 PartyConsent records per beneficiary
               in the Insurance AR beneficiary flow. Called from the
               InsuranceAR_CreateBeneficiaryConsent Integration Procedure after party
               profile creation is complete.
@Author : Shams Arifeen
@Created Date : 2026-06-26
***************************************************************************************
* Last Modified By  Shams Arifeen
* Last Modified Date 2026-06-26
* Last Modified Description: Initial Version
* User Story : SFP-58864
****************************************************************************************/
global without sharing class INS_PartyConsentRemoteAction implements Callable {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PartyConsentRemoteAction');

    private static final String KEY_SUCCESS = 'success';

    private static final List<String> CONSENT_ACTIONS = new List<String>{
        'PrivacyPolicyAcceptance',
        'CrossBorderDataTransfer',
        'BiometricProcessing',
        'ComplianceScreening'
    };

    private static final Map<String, String> NAME_SUFFIXES = new Map<String, String>{
        'PrivacyPolicyAcceptance' => 'PRIVACY',
        'CrossBorderDataTransfer' => 'XBORDER',
        'BiometricProcessing'     => 'BIOMETRIC',
        'ComplianceScreening'     => 'COMPLIANCE'
    };

    /**
    * @description Callable entry point — dispatches to the appropriate handler based on actionType
    * @author Shams Arifeen | 2026-06-26
    * @param actionType Action identifier — supports 'createConsents'
    * @param args Map containing 'input' and 'output' maps
    * @return Object result map
    **/
    global Object call(String actionType, Map<String, Object> args) {
        Map<String, Object> inputMap  = (Map<String, Object>) args.get('input');
        Map<String, Object> outputMap = (Map<String, Object>) args.get('output');

        if (actionType == 'createConsents') {
            return createConsents(inputMap, outputMap);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    /**
    * @description AuraEnabled wrapper — catches unhandled exceptions and re-throws as AuraHandledException
    * @author Shams Arifeen | 2026-06-26
    * @param inputMap Map of input values from the Integration Procedure
    * @param outputMap Map to populate with results
    * @return Object output map
    **/
    @AuraEnabled(cacheable=false)
    public static Object createConsents(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        try {
            return createConsentsInternal(inputMap, outputMap);
        } catch (Exception caughtException) {
            LOGGER.error('INS_PartyConsentRemoteAction.createConsents ' + caughtException.getMessage() + ' Line Exception ' + caughtException.getLineNumber() + ' Stack trace: ' + caughtException.getStackTraceString());
            throw new AuraHandledException(caughtException.getTypeName() + ' (line ' + caughtException.getLineNumber() + '): ' + caughtException.getMessage());
        }
    }

    /**
    * @description Orchestrates input validation, account/individual resolution,
    *              existing-consent deduplication, consent record building, and bulk insert.
    * @author Shams Arifeen | 2026-06-26
    * @param inputMap Map containing 'members' (BeneficiarySummary.members array),
    *                 'CaptureSource', and 'BusinessBrandName'
    * @param outputMap Map to populate with success flag
    * @return Object output map
    **/
    private static Object createConsentsInternal(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        LOGGER.debug('INS_PartyConsentRemoteAction.createConsentsInternal - inputMap keys: {0}', new List<Object>{ inputMap.keySet() });
        LOGGER.debug('INS_PartyConsentRemoteAction - raw members: {0}', new List<Object>{ JSON.serialize(inputMap.get('members')) });

        String captureSource = (String) inputMap.get('CaptureSource');
        String brandName     = (String) inputMap.get('BusinessBrandName');
        List<Map<String, Object>> memberList = toMemberList(inputMap.get('members'));
        LOGGER.debug('INS_PartyConsentRemoteAction - memberList count: {0}, captureSource: {1}, brandName: {2}', new List<Object>{ memberList.size(), captureSource, brandName });

        if (hasBlankInputs(memberList, captureSource, brandName, outputMap)) {
            return outputMap;
        }

        Set<Id> accountIds = collectAccountIds(memberList);
        LOGGER.debug('INS_PartyConsentRemoteAction - beneficiaryAccountId count collected: {0}', new List<Object>{ accountIds.size() });
        if (accountIds.isEmpty()) {
            LOGGER.warn('INS_PartyConsentRemoteAction: no valid beneficiaryAccountId values found in members');
            outputMap.put(KEY_SUCCESS, false);
            return outputMap;
        }

        Map<Id, Id> accountToIndividualMap  = resolvePersonIndividualIds(accountIds);
        Set<Id>     individualsWithConsents  = findExistingConsentIndividuals(new Set<Id>(accountToIndividualMap.values()));
        LOGGER.debug('INS_PartyConsentRemoteAction - accountToIndividualMap: {0}, individualsWithExistingConsents: {1}', new List<Object>{ accountToIndividualMap.size(), individualsWithConsents.size() });

        BusinessBrand brand = new SEL_BusinessBrand().selectByName(brandName);
        if (brand == null) {
            throw new AuraHandledException('BusinessBrand not found: ' + brandName + '. Consent records cannot be created.');
        }

        List<PartyConsent> consentsToInsert = buildAllConsents(accountToIndividualMap, individualsWithConsents, brand.Id, captureSource);
        LOGGER.debug('INS_PartyConsentRemoteAction - consentsToInsert count: {0}', new List<Object>{ consentsToInsert.size() });
        if (!consentsToInsert.isEmpty()) {
            sbgplatform.fflib_SObjectUnitOfWork uow =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            uow.registerNew(consentsToInsert);
            uow.commitWork();
        }

        outputMap.put(KEY_SUCCESS, true);
        LOGGER.debug('INS_PartyConsentRemoteAction - complete. success: true, consents inserted: {0}', new List<Object>{ consentsToInsert.size() });
        return outputMap;
    }

    /**
    * @description Validates that the member list and required string inputs are present.
    *              Sets success=false and logs a warning for whichever guard fails first.
    * @author Shams Arifeen | 2026-06-26
    * @param memberList Parsed member list
    * @param captureSource CaptureSource from inputMap
    * @param brandName BusinessBrandName from inputMap
    * @param outputMap Populated with success=false when a guard fails
    * @return true if any input is invalid (caller should return early), false if all are valid
    **/
    private static Boolean hasBlankInputs(List<Map<String, Object>> memberList, String captureSource, String brandName, Map<String, Object> outputMap) {
        if (memberList.isEmpty()) {
            LOGGER.warn('INS_PartyConsentRemoteAction: members list is empty, skipping consent creation');
            outputMap.put(KEY_SUCCESS, false);
            return true;
        }
        if (String.isBlank(captureSource)) {
            LOGGER.warn('INS_PartyConsentRemoteAction: CaptureSource is blank, skipping consent creation');
            outputMap.put(KEY_SUCCESS, false);
            return true;
        }
        if (String.isBlank(brandName)) {
            LOGGER.warn('INS_PartyConsentRemoteAction: BusinessBrandName is blank, skipping consent creation');
            outputMap.put(KEY_SUCCESS, false);
            return true;
        }
        return false;
    }

    /**
    * @description Collects non-blank beneficiaryAccountId values from the member list.
    * @author Shams Arifeen | 2026-06-26
    * @param memberList Parsed beneficiary member list
    * @return Set of Account Ids
    **/
    private static Set<Id> collectAccountIds(List<Map<String, Object>> memberList) {
        Set<Id> accountIds = new Set<Id>();
        for (Map<String, Object> memberMap : memberList) {
            String accountIdStr = (String) memberMap.get('beneficiaryAccountId');
            if (String.isNotBlank(accountIdStr)) {
                accountIds.add((Id) accountIdStr);
            }
        }
        return accountIds;
    }

    /**
    * @description Queries Account records for the given Ids and builds a map of Account Id
    *              to PersonIndividualId, logging a warning for any account without one.
    * @author Shams Arifeen | 2026-06-26
    * @param accountIds Set of beneficiary Account Ids
    * @return Map from Account Id to PersonIndividualId
    **/
    private static Map<Id, Id> resolvePersonIndividualIds(Set<Id> accountIds) {
        Map<Id, Id> accountToIndividualMap = new Map<Id, Id>();
        for (Account acc : new SEL_Account().selectByIdsWithPersonIndividualId(accountIds)) {
            if (acc.PersonIndividualId == null) {
                LOGGER.warn('INS_PartyConsentRemoteAction: Account ' + acc.Id + ' has no PersonIndividualId — skipping');
            } else {
                accountToIndividualMap.put(acc.Id, acc.PersonIndividualId);
            }
        }
        return accountToIndividualMap;
    }

    /**
    * @description Queries existing PartyConsent records for the given individual Ids
    *              and returns the set of Individual Ids that already have consents.
    * @author Shams Arifeen | 2026-06-26
    * @param individualIds Set of Individual (PersonIndividualId) Ids to check
    * @return Set of Individual Ids that already have at least one consent record
    **/
    private static Set<Id> findExistingConsentIndividuals(Set<Id> individualIds) {
        Set<Id> individualsWithConsents = new Set<Id>();
        for (PartyConsent existing : new SEL_PartyConsent().selectByPartyIdsAndActions(individualIds, CONSENT_ACTIONS)) {
            individualsWithConsents.add(existing.PartyId);
        }
        return individualsWithConsents;
    }

    /**
    * @description Builds 4 PartyConsent records for each account whose individual does not
    *              already have consent records.
    * @author Shams Arifeen | 2026-06-26
    * @param accountToIndividualMap Account Id → Individual Id
    * @param individualsWithConsents Individual Ids to skip (already have consents)
    * @param brandId BusinessBrand record Id
    * @param captureSource CaptureSource value
    * @return List of PartyConsent records ready for insert
    **/
    private static List<PartyConsent> buildAllConsents(Map<Id, Id> accountToIndividualMap, Set<Id> individualsWithConsents, Id brandId, String captureSource) {
        List<PartyConsent> consentsToInsert = new List<PartyConsent>();
        for (Id accountId : accountToIndividualMap.keySet()) {
            Id individualId = accountToIndividualMap.get(accountId);
            if (individualsWithConsents.contains(individualId)) {
                LOGGER.warn('INS_PartyConsentRemoteAction: Individual ' + individualId + ' already has consents — skipping');
                continue;
            }
            for (String action : CONSENT_ACTIONS) {
                consentsToInsert.add(buildConsent(accountId, individualId, brandId, action, captureSource));
            }
        }
        return consentsToInsert;
    }

    /**
    * @description Builds a single PartyConsent sObject with all required fields set
    * @author Shams Arifeen | 2026-06-26
    * @param accountId Id of the beneficiary Person Account
    * @param individualId Id of the Individual record (Account.PersonIndividualId)
    * @param brandId Id of the BusinessBrand record
    * @param action Action__c picklist value
    * @param captureSource CaptureSource value passed from the embedding flow
    * @return PartyConsent
    **/
    private static PartyConsent buildConsent(Id accountId, Id individualId, Id brandId, String action, String captureSource) {
        String nameSuffix = NAME_SUFFIXES.get(action);
        return new PartyConsent(
            Name                    = 'PC-' + accountId + '-' + nameSuffix + '-' + Datetime.now().getTime(),
            PartyId                 = individualId,
            BusinessBrandId         = brandId,
            Action__c               = action,
            PrivacyConsentStatus    = 'OptIn',
            CaptureContactPointType = 'Web',
            CaptureSource           = captureSource,
            CaptureDate             = Date.today(),
            EffectiveFrom           = Date.today()
        );
    }

    /**
    * @description Normalises the members collection to a List regardless of whether the
    *              IP delivers it as a JSON array or an integer-keyed map
    * @author Shams Arifeen | 2026-06-26
    * @param membersObject Raw members value from inputMap
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
            Map<String, Object> keyedMap = (Map<String, Object>) membersObject;
            List<String> keys = new List<String>(keyedMap.keySet());
            keys.sort();
            for (String key : keys) {
                memberList.add((Map<String, Object>) keyedMap.get(key));
            }
        }
        return memberList;
    }
}