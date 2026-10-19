/***************************************************************************************
@Name of the Class : INS_PartyScreeningRemoteAction
@Description : SFP-58864 Remote Action to create PartyScreeningSummary and
               PartyScreeningStep records for the policyholder and each beneficiary
               after the KYC compliance screening API callouts complete.
               Called from INS_CreateScreeningRecords IP as part of the
               Insurance AR beneficiary chain. Party Profile IDs come directly from
               the OmniScript data context — no SOQL required.
@Author : Shams
@Created Date : 2026-07-03
***************************************************************************************
* Last Modified By  Shams
* Last Modified Date 2026-07-03
* Last Modified Description: Initial Version
* User Story : SFP-58864
****************************************************************************************/
global without sharing class INS_PartyScreeningRemoteAction implements Callable {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PartyScreeningRemoteAction');

    private static final String SUMMARY_STATUS_INITIATED  = 'Initiated';
    private static final String SUMMARY_NAME_ASSESSMENT   = 'Assessment';
    private static final String KEY_PARTY_PROFILE_ID      = 'partyProfileId';
    private static final String KEY_ASSESSMENT_RESULT     = 'assessmentResult';
    private static final String KEY_SCREENING_RESULTS     = 'screeningResults';
    private static final String KEY_SCREENING_TYPE        = 'screeningType';
    private static final String KEY_ASSESSMENT_ID         = 'assessmentId';
    private static final String KEY_RESULT                = 'result';

    /**
    * @description Callable entry point — dispatches to the appropriate handler based on actionType
    * @author Shams | 2026-07-03
    * @param actionType Action identifier — supports 'createScreeningRecords'
    * @param args Map containing 'input' and 'output' maps
    * @return Object result map
    **/
    global Object call(String actionType, Map<String, Object> args) {
        Map<String, Object> inputMap  = (Map<String, Object>) args.get('input');
        Map<String, Object> outputMap = (Map<String, Object>) args.get('output');
        if (actionType == 'createScreeningRecords') {
            return createScreeningRecords(inputMap, outputMap);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    /**
    * @description AuraEnabled wrapper — catches unhandled exceptions and re-throws as AuraHandledException
    * @author Shams | 2026-07-03
    * @param inputMap Map of input values from the Integration Procedure
    * @param outputMap Map to populate with results
    * @return Object output map with createdSummaries
    **/
    @AuraEnabled(cacheable=false)
    public static Object createScreeningRecords(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        try {
            return createScreeningRecordsInternal(inputMap, outputMap);
        } catch (Exception caughtException) {
            LOGGER.error('INS_PartyScreeningRemoteAction.createScreeningRecords ' + caughtException.getMessage() + ' Line Exception ' + caughtException.getLineNumber() + ' Stack trace: ' + caughtException.getStackTraceString());
            throw new AuraHandledException(caughtException.getTypeName() + ' (line ' + caughtException.getLineNumber() + '): ' + caughtException.getMessage());
        }
    }

    /**
    * @description Orchestrates party list construction, summary insertion, step insertion and output building.
    *              Both PolicyholderScreeningResult and each entry in BeneficiaryScreeningResults are
    *              self-describing — the IP stamps the Party Profile Id directly onto each result at
    *              the source, so this class just reads it off, no separate lookup or matching needed.
    * @author Shams | 2026-07-03
    * @param inputMap Keys: PolicyholderScreeningResult {PartyProfileId, customerId, assessmentResult},
    *                       BeneficiaryScreeningResults [{PartyProfileId, customerId, assessmentResult}, ...]
    * @param outputMap Populated with createdSummaries, summaryCount, stepCount
    * @return Object output map
    **/
    private static Object createScreeningRecordsInternal(Map<String, Object> inputMap, Map<String, Object> outputMap) {
        LOGGER.debug('INS_PartyScreeningRemoteAction.createScreeningRecordsInternal - inputMap keys: {0}', new List<Object>{ inputMap.keySet() });
        LOGGER.debug('INS_PartyScreeningRemoteAction - raw PolicyholderScreeningResult: {0}', new List<Object>{ JSON.serialize(inputMap.get('PolicyholderScreeningResult')) });
        LOGGER.debug('INS_PartyScreeningRemoteAction - raw BeneficiaryScreeningResults: {0}', new List<Object>{ JSON.serialize(inputMap.get('BeneficiaryScreeningResults')) });

        List<Map<String, Object>> parties = buildPartiesToProcess(inputMap);
        LOGGER.debug('INS_PartyScreeningRemoteAction - partiesToProcess count: {0}', new List<Object>{ parties.size() });
        for (Integer i = 0; i < parties.size(); i++) {
            LOGGER.debug('INS_PartyScreeningRemoteAction - party[{0}] partyProfileId: {1}, hasAssessmentResult: {2}', new List<Object>{
                i,
                parties[i].get(KEY_PARTY_PROFILE_ID),
                parties[i].get(KEY_ASSESSMENT_RESULT) != null
            });
        }

        List<PartyScreeningSummary> summaries = insertSummaries(parties);
        LOGGER.debug('INS_PartyScreeningRemoteAction - inserted {0} PartyScreeningSummary records', new List<Object>{ summaries.size() });

        List<PartyScreeningStep> steps = insertSteps(parties, summaries);
        LOGGER.debug('INS_PartyScreeningRemoteAction - inserted {0} PartyScreeningStep records', new List<Object>{ steps.size() });

        return buildOutput(outputMap, summaries, steps);
    }

    /**
    * @description Builds the ordered list of { partyProfileId, assessmentResult } entries
    *              for the policyholder (first) followed by each beneficiary.
    * @author Shams | 2026-07-03
    * @param inputMap Raw IP input map
    * @return List of party entries ready for DML
    **/
    private static List<Map<String, Object>> buildPartiesToProcess(Map<String, Object> inputMap) {
        List<Map<String, Object>> parties = new List<Map<String, Object>>();

        Map<String, Object> policyholderScreening = toMap(inputMap.get('PolicyholderScreeningResult'));
        String policyholderPartyProfileIdRaw = policyholderScreening == null ? null : (String) policyholderScreening.get('PartyProfileId');
        LOGGER.debug('INS_PartyScreeningRemoteAction - policyholderPartyProfileId: {0}, policyholderScreening present: {1}', new List<Object>{ policyholderPartyProfileIdRaw, policyholderScreening != null });

        if (policyholderScreening != null && String.isNotBlank(policyholderPartyProfileIdRaw)) {
            Object policyholderAssessmentResult = policyholderScreening.get(KEY_ASSESSMENT_RESULT);
            if (policyholderAssessmentResult != null) {
                parties.add(new Map<String, Object>{
                    KEY_PARTY_PROFILE_ID  => (Id) policyholderPartyProfileIdRaw,
                    KEY_ASSESSMENT_RESULT => policyholderAssessmentResult
                });
            }
        }

        List<Object> beneficiaryScreeningResults = toObjectList(inputMap.get('BeneficiaryScreeningResults'));
        LOGGER.debug('INS_PartyScreeningRemoteAction - beneficiaryScreeningResults count: {0}', new List<Object>{ beneficiaryScreeningResults.size() });

        parties.addAll(buildBeneficiaryEntries(beneficiaryScreeningResults));
        return parties;
    }

    /**
    * @description Builds beneficiary party entries directly from each screening result's own
    *              PartyProfileId — stamped onto the result inside the loop (via a Set Values
    *              step referencing %members:beneficiaryPartyProfileId% for that same iteration)
    *              rather than matched afterwards by array position. This makes each result
    *              self-describing instead of relying on two separate arrays staying in the
    *              same order. The Loop Block wraps the stamped result in its own per-iteration
    *              status object (LoopBlockIterationStatus, <StepName>Status, etc.) alongside the
    *              loopOutput-mapped key, so the actual data is nested one level deeper. Only
    *              PartyProfileId and assessmentResult gate whether an entry is processed.
    * @author Shams | 2026-07-03
    * @param beneficiaryScreeningResults Each entry: {BeneficiaryComplianceScreeningResult: {PartyProfileId, customerId, assessmentResult}, ...loop status flags}
    * @return List of beneficiary party entries
    **/
    private static List<Map<String, Object>> buildBeneficiaryEntries(List<Object> beneficiaryScreeningResults) {
        List<Map<String, Object>> entries = new List<Map<String, Object>>();
        for (Integer i = 0; i < beneficiaryScreeningResults.size(); i++) {
            Map<String, Object> iterationResult = (Map<String, Object>) beneficiaryScreeningResults[i];
            Map<String, Object> screeningResult = toMap(iterationResult.get('BeneficiaryComplianceScreeningResult'));
            if (screeningResult == null) {
                screeningResult = iterationResult;
            }
            String partyProfileId = (String) screeningResult.get('PartyProfileId');
            LOGGER.debug('INS_PartyScreeningRemoteAction - screeningResult[{0}] partyProfileId: {1}', new List<Object>{ i, partyProfileId });

            if (String.isBlank(partyProfileId)) {
                continue;
            }

            Object assessmentResult = screeningResult.get(KEY_ASSESSMENT_RESULT);
            LOGGER.debug('INS_PartyScreeningRemoteAction - assessmentResult found: {0}', new List<Object>{ assessmentResult != null });

            if (assessmentResult == null) {
                continue;
            }
            entries.add(new Map<String, Object>{
                KEY_PARTY_PROFILE_ID  => (Id) partyProfileId,
                KEY_ASSESSMENT_RESULT => assessmentResult
            });
        }
        return entries;
    }

    /**
    * @description Checks CRUD permission then inserts one PartyScreeningSummary per party entry.
    * @author Shams | 2026-07-03
    * @param parties Ordered list of { partyProfileId, assessmentResult } entries
    * @return Inserted PartyScreeningSummary list (with Ids populated)
    **/
    private static List<PartyScreeningSummary> insertSummaries(List<Map<String, Object>> parties) {
        if (!Schema.sObjectType.PartyScreeningSummary.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create PartyScreeningSummary records');
        }
        List<PartyScreeningSummary> summaries = new List<PartyScreeningSummary>();
        for (Map<String, Object> partyEntry : parties) {
            Map<String, Object> assessmentResult = (Map<String, Object>) partyEntry.get(KEY_ASSESSMENT_RESULT);
            summaries.add(new PartyScreeningSummary(
                PartyProfileId               = (Id) partyEntry.get(KEY_PARTY_PROFILE_ID),
                Name                         = SUMMARY_NAME_ASSESSMENT,
                Status                       = SUMMARY_STATUS_INITIATED,
                ScreeningRequestDate         = DateTime.now(),
                ThirdPartySreeningIdentifier = assessmentResult == null ? null : (String) assessmentResult.get(KEY_ASSESSMENT_ID),
                ThirdPartyScreeningResult    = assessmentResult == null ? null : (String) assessmentResult.get(KEY_RESULT)
            ));
        }
        if (!summaries.isEmpty()) {
            insert summaries;
        }
        return summaries;
    }

    /**
    * @description Checks CRUD permission then inserts one PartyScreeningStep per screening result per party.
    * @author Shams | 2026-07-03
    * @param parties Ordered list of party entries (index-aligned with summaries)
    * @param summaries Inserted summaries whose Ids are used as parent references
    * @return Inserted PartyScreeningStep list
    **/
    private static List<PartyScreeningStep> insertSteps(List<Map<String, Object>> parties, List<PartyScreeningSummary> summaries) {
        if (!Schema.sObjectType.PartyScreeningStep.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create PartyScreeningStep records');
        }
        List<PartyScreeningStep> steps = new List<PartyScreeningStep>();
        for (Integer i = 0; i < parties.size(); i++) {
            Map<String, Object> assessmentResult = (Map<String, Object>) parties[i].get(KEY_ASSESSMENT_RESULT);
            if (assessmentResult == null) {
                continue;
            }
            Id summaryId = summaries[i].Id;
            for (Object stepObj : toObjectList(assessmentResult.get(KEY_SCREENING_RESULTS))) {
                Map<String, Object> stepMap = (Map<String, Object>) stepObj;
                String apiType = (String) stepMap.get(KEY_SCREENING_TYPE);
                steps.add(new PartyScreeningStep(
                    ScreeningSummaryId = summaryId,
                    Name               = apiType,
                    Type               = apiType,
                    Status             = SUMMARY_STATUS_INITIATED
                    // IntegrationProviderExecId = (String) stepMap.get('screeningId')
                ));
            }
        }
        if (!steps.isEmpty()) {
            insert steps;
        }
        return steps;
    }

    /**
    * @description Builds the output map with created summary ids and counts.
    * @author Shams | 2026-07-03
    * @param outputMap Map to populate
    * @param summaries Inserted PartyScreeningSummary records
    * @param steps Inserted PartyScreeningStep records
    * @return Populated output map
    **/
    private static Object buildOutput(Map<String, Object> outputMap, List<PartyScreeningSummary> summaries, List<PartyScreeningStep> steps) {
        List<Map<String, Object>> createdSummaries = new List<Map<String, Object>>();
        for (PartyScreeningSummary summary : summaries) {
            createdSummaries.add(new Map<String, Object>{
                'id'               => summary.Id,
                KEY_PARTY_PROFILE_ID => summary.PartyProfileId,
                'assessmentId'     => summary.ThirdPartySreeningIdentifier
            });
        }
        outputMap.put('createdSummaries', createdSummaries);
        outputMap.put('summaryCount', summaries.size());
        outputMap.put('stepCount', steps.size());
        LOGGER.debug('INS_PartyScreeningRemoteAction - complete. summaryCount: {0}, stepCount: {1}', new List<Object>{ summaries.size(), steps.size() });
        return outputMap;
    }

    /**
    * @description Normalises an Object to a List<Object> regardless of whether OmniStudio
    *              delivers it as a JSON array (List<Object>) or an integer-keyed map (Map<String,Object>).
    * @author Shams | 2026-07-03
    * @param rawObject Raw value from the IP input
    * @return List<Object> ordered list, empty if null
    **/
    @TestVisible
    private static List<Object> toObjectList(Object rawObject) {
        if (rawObject == null) {
            return new List<Object>();
        }
        if (rawObject instanceof List<Object>) {
            return (List<Object>) rawObject;
        }
        if (rawObject instanceof Map<String, Object>) {
            return fromKeyedMap((Map<String, Object>) rawObject);
        }
        if (rawObject instanceof String) {
            return toObjectListFromString((String) rawObject);
        }
        return new List<Object>();
    }

    private static List<Object> fromKeyedMap(Map<String, Object> keyedMap) {
        List<String> sortedKeys = new List<String>(keyedMap.keySet());
        sortedKeys.sort();
        List<Object> result = new List<Object>();
        for (String key : sortedKeys) {
            result.add(keyedMap.get(key));
        }
        return result;
    }

    private static List<Object> toObjectListFromString(String s) {
        if (String.isBlank(s)) {
            return new List<Object>();
        }
        Object parsed = JSON.deserializeUntyped(s);
        if (parsed instanceof List<Object>) {
            return (List<Object>) parsed;
        }
        if (parsed instanceof Map<String, Object>) {
            return fromKeyedMap((Map<String, Object>) parsed);
        }
        return new List<Object>();
    }

    @TestVisible
    private static Map<String, Object> toMap(Object rawObject) {
        if (rawObject == null) {
            return null;
        }
        if (rawObject instanceof Map<String, Object>) {
            return (Map<String, Object>) rawObject;
        }
        if (rawObject instanceof String) {
            String s = (String) rawObject;
            if (String.isBlank(s)) {
                return null;
            }
            return (Map<String, Object>) JSON.deserializeUntyped(s);
        }
        return null;
    }
}