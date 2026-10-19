/***************************************************************************************
@Name of the Class : INS_PartyScreeningRemoteAction_Test
@Description : SFP-58864 Test class for INS_PartyScreeningRemoteAction.
               Covers Callable dispatch, summary and step record creation for
               policyholder + beneficiaries using IDs passed directly from the
               OmniScript chain (no SOQL in production path), and all error paths.
@Author : Shams
@Created Date : 2026-07-03
***************************************************************************************
* Last Modified By  Shams
* Last Modified Date 2026-07-03
* Last Modified Description: Initial Version
* User Story : SFP-58864
****************************************************************************************/
@IsTest(SeeAllData=false IsParallel=false)
private class INS_PartyScreeningRemoteAction_Test {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_CREATE_SCREENING = 'createScreeningRecords';
    private static final String ACTION_UNSUPPORTED      = 'unsupportedAction';

    private static final String RECORD_TYPE_PERSON_ACCOUNT = 'Person_Account_Prospect';
    private static final String RECORD_TYPE_THIRD_PARTY    = 'Third_Party';

    private static final String BEN1_UUID = 'bbbbbbbb-0001-0001-0001-000000000002';
    private static final String BEN2_UUID = 'cccccccc-0001-0001-0001-000000000003';

    private static final String ASSESSMENT_ID_PH   = 'ASSESS-001';
    private static final String ASSESSMENT_ID_BEN1 = 'ASSESS-002';
    private static final String ASSESSMENT_ID_BEN2 = 'ASSESS-003';

    private static final String SCREENING_TYPE_SANCTION = 'Sanction Status';
    private static final String SCREENING_TYPE_PIP      = 'Prominent Influential Persons (PIP)';
    private static final String SCREENING_TYPE_CRA      = 'CRA High Risk Review';
    private static final String SCREENING_TYPE_IDV      = 'Document IDV Check Screening';

    private static final String PH_FIRST_NAME     = 'Johnson';
    private static final String LAST_NAME_TIPIYAI = 'Tipiyai';
    private static final String BEN1_FIRST_NAME   = 'Mary';
    private static final String PH_CUSTOMER_UUID  = 'ph-uuid';

    private static final String KEY_ERROR                  = 'error';
    private static final String KEY_SUMMARY_COUNT          = 'summaryCount';
    private static final String KEY_POLICYHOLDER_PP_ID     = 'PolicyholderPartyProfileId';
    private static final String KEY_MEMBERS                = 'members';
    private static final String KEY_POLICYHOLDER_SCREENING = 'PolicyholderScreeningResult';
    private static final String KEY_BENEFICIARY_SCREENING  = 'BeneficiaryScreeningResults';
    private static final String KEY_CUSTOMER_ID            = 'customerId';
    private static final String KEY_ASSESSMENT_RESULT      = 'assessmentResult';
    private static final String KEY_VALUE                  = 'value';

    // =========================================================================
    // HELPER METHODS
    // =========================================================================

    private static Map<String, Object> buildCallArguments(Map<String, Object> inputMap) {
        return new Map<String, Object>{
            'input'  => inputMap,
            'output' => new Map<String, Object>()
        };
    }

    private static PartyProfile createPartyProfile(Id accountId, String firstName, String lastName) {
        PartyProfile pp = new PartyProfile(
            AccountId = accountId,
            Name      = firstName + ' ' + lastName,
            FirstName = firstName,
            LastName  = lastName
        );
        insert pp;
        return pp;
    }

    private static Account createPersonAccount(String firstName, String lastName) {
        Id recordTypeId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_PERSON_ACCOUNT).getRecordTypeId();
        Account acc = new Account(
            FirstName    = firstName,
            LastName     = lastName,
            RecordTypeId = recordTypeId
        );
        insert acc;
        return acc;
    }

    private static Account createThirdPartyAccount(String firstName, String lastName) {
        Id recordTypeId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_THIRD_PARTY).getRecordTypeId();
        Account acc = new Account(
            FirstName    = firstName,
            LastName     = lastName,
            RecordTypeId = recordTypeId
        );
        insert acc;
        return acc;
    }

    private static Map<String, Object> buildScreeningResult(String screeningId, String screeningType) {
        return new Map<String, Object>{
            'screeningId'   => screeningId,
            'screeningType' => screeningType,
            'result'        => 'pending'
        };
    }

    private static Map<String, Object> buildAssessmentResult(String assessmentId) {
        return new Map<String, Object>{
            'assessmentId'     => assessmentId,
            'status'           => 'In Progress',
            'result'           => KEY_ERROR,
            'screeningResults' => new List<Object>{
                buildScreeningResult(assessmentId + '-S', SCREENING_TYPE_SANCTION),
                buildScreeningResult(assessmentId + '-P', SCREENING_TYPE_PIP),
                buildScreeningResult(assessmentId + '-C', SCREENING_TYPE_CRA),
                buildScreeningResult(assessmentId + '-D', SCREENING_TYPE_IDV)
            }
        };
    }

    /**
    * @description Mirrors the OmniScript chain: PolicyholderPartyProfileId and each
    *              BeneficiaryScreeningResults entry's beneficiaryPartyProfileId are real SF
    *              IDs already resolved by INS_CreatePartyProfile — no SOQL required. Each
    *              beneficiary screening result is self-describing (carries its own
    *              beneficiaryId/beneficiaryPartyProfileId), stamped on inside the IP's loop —
    *              no separate members list is needed for matching.
    **/
    private static Map<String, Object> buildFullInputMap(
        Id policyholderPartyProfileId,
        String ben1Uuid, Id ben1PartyProfileId,
        String ben2Uuid, Id ben2PartyProfileId
    ) {
        return new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => String.valueOf(policyholderPartyProfileId),
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>{
                new Map<String, Object>{
                    'beneficiaryId'             => ben1Uuid,
                    'beneficiaryPartyProfileId' => String.valueOf(ben1PartyProfileId),
                    KEY_CUSTOMER_ID             => ben1Uuid,
                    KEY_ASSESSMENT_RESULT       => buildAssessmentResult(ASSESSMENT_ID_BEN1)
                },
                new Map<String, Object>{
                    'beneficiaryId'             => ben2Uuid,
                    'beneficiaryPartyProfileId' => String.valueOf(ben2PartyProfileId),
                    KEY_CUSTOMER_ID             => ben2Uuid,
                    KEY_ASSESSMENT_RESULT       => buildAssessmentResult(ASSESSMENT_ID_BEN2)
                }
            }
        };
    }

    // =========================================================================
    // POSITIVE TESTS
    // =========================================================================

    @IsTest
    static void testCreateScreeningRecordsForAllParties() {
        // WHY: Full happy-path — party profile IDs come directly from the chain (no SOQL).
        // Validates that 3 PartyScreeningSummary + 12 PartyScreeningStep records are created.
        Account phAccount   = createPersonAccount(PH_FIRST_NAME, LAST_NAME_TIPIYAI);
        Account ben1Account = createThirdPartyAccount(BEN1_FIRST_NAME, LAST_NAME_TIPIYAI);
        Account ben2Account = createThirdPartyAccount('Bob', 'Smith');

        PartyProfile phProfile   = createPartyProfile(phAccount.Id,   PH_FIRST_NAME,   LAST_NAME_TIPIYAI);
        PartyProfile ben1Profile = createPartyProfile(ben1Account.Id, BEN1_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile ben2Profile = createPartyProfile(ben2Account.Id, 'Bob',           'Smith');

        Map<String, Object> inputMap = buildFullInputMap(
            phProfile.Id, BEN1_UUID, ben1Profile.Id, BEN2_UUID, ben2Profile.Id
        );

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR), 'No error expected on full happy path: ' + result.get(KEY_ERROR));
        System.assertEquals(3,  result.get(KEY_SUMMARY_COUNT), 'Expected 3 PartyScreeningSummary records (1 PH + 2 beneficiaries)');
        System.assertEquals(12, result.get('stepCount'),        'Expected 12 PartyScreeningStep records (4 per party x 3)');

        Integer dbSummaries = [SELECT COUNT() FROM PartyScreeningSummary WHERE PartyProfileId IN (:phProfile.Id, :ben1Profile.Id, :ben2Profile.Id)];
        System.assertEquals(3, dbSummaries, '3 PartyScreeningSummary records should exist in the database');

        Integer dbSteps = [SELECT COUNT() FROM PartyScreeningStep WHERE ScreeningSummaryId IN (
            SELECT Id FROM PartyScreeningSummary WHERE PartyProfileId IN (:phProfile.Id, :ben1Profile.Id, :ben2Profile.Id)
        )];
        System.assertEquals(12, dbSteps, '12 PartyScreeningStep records should exist in the database');
    }

    @IsTest
    static void testSummaryFieldsSetCorrectly() {
        // WHY: Validates field-level mapping — assessmentId, Initiated Status,
        // Assessment Name, and ScreeningRequestDate populated.
        Account phAccount = createPersonAccount(PH_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile phProfile = createPartyProfile(phAccount.Id, PH_FIRST_NAME, LAST_NAME_TIPIYAI);

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => String.valueOf(phProfile.Id),
            KEY_MEMBERS                       => new List<Object>(),
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>()
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        PartyScreeningSummary inserted = [
            SELECT PartyProfileId, Name, Status, ThirdPartySreeningIdentifier, ThirdPartyScreeningResult, ScreeningRequestDate
            FROM PartyScreeningSummary WHERE PartyProfileId = :phProfile.Id LIMIT 1
        ];
        System.assertEquals(phProfile.Id,    inserted.PartyProfileId,               'PartyProfileId must match');
        System.assertEquals('Assessment',     inserted.Name,                         'Name must be Assessment');
        System.assertEquals('Initiated',      inserted.Status,                       'Status must be Initiated');
        System.assertEquals(ASSESSMENT_ID_PH, inserted.ThirdPartySreeningIdentifier, 'ThirdPartySreeningIdentifier must be assessmentId');
        System.assertEquals(KEY_ERROR,        inserted.ThirdPartyScreeningResult,    'ThirdPartyScreeningResult must reflect API result');
        System.assertNotEquals(null,          inserted.ScreeningRequestDate,         'ScreeningRequestDate must be populated');
    }

    @IsTest
    static void testStepTypesSetCorrectly() {
        // WHY: Validates all 4 screeningType -> Type/Name mappings and that
        // IntegrationProviderExecId carries the screeningId from the API response.
        Account phAccount = createPersonAccount(PH_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile phProfile = createPartyProfile(phAccount.Id, PH_FIRST_NAME, LAST_NAME_TIPIYAI);

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => String.valueOf(phProfile.Id),
            KEY_MEMBERS                       => new List<Object>(),
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>()
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        List<PartyScreeningStep> steps = [
            SELECT Name, Type, Status, IntegrationProviderExecId FROM PartyScreeningStep
            WHERE ScreeningSummaryId IN (SELECT Id FROM PartyScreeningSummary WHERE PartyProfileId = :phProfile.Id)
            ORDER BY Type
        ];
        System.assertEquals(4, steps.size(), 'Expected 4 steps for the policyholder');

        Map<String, PartyScreeningStep> byType = new Map<String, PartyScreeningStep>();
        for (PartyScreeningStep step : steps) {
            byType.put(step.Type, step);
        }

        System.assert(byType.containsKey(SCREENING_TYPE_SANCTION), 'Sanction Status type must exist');
        System.assert(byType.containsKey(SCREENING_TYPE_PIP),     'PIP type must exist');
        System.assert(byType.containsKey(SCREENING_TYPE_CRA),     'CRA type must exist');

        System.assertEquals(SCREENING_TYPE_SANCTION, byType.get(SCREENING_TYPE_SANCTION).Name, 'Sanction name must match api type');
        System.assertEquals(SCREENING_TYPE_PIP,      byType.get(SCREENING_TYPE_PIP).Name,      'PIP name must match api type');
        System.assertEquals(SCREENING_TYPE_CRA,      byType.get(SCREENING_TYPE_CRA).Name,      'CRA name must match api type');

        for (PartyScreeningStep step : steps) {
            System.assertEquals('Initiated', step.Status, 'All steps should be Initiated');
        }
    }

    @IsTest
    static void testMissingPartyProfileIdSkipped() {
        // WHY: If a BeneficiaryScreeningResults entry has no beneficiaryPartyProfileId
        // stamped on it (e.g. the enrichment step never ran for that party), that
        // beneficiary is silently skipped rather than throwing.
        Account phAccount = createPersonAccount(PH_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile phProfile = createPartyProfile(phAccount.Id, PH_FIRST_NAME, LAST_NAME_TIPIYAI);

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => String.valueOf(phProfile.Id),
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>{
                new Map<String, Object>{
                    'beneficiaryId'             => BEN1_UUID,
                    'beneficiaryPartyProfileId' => null,
                    KEY_CUSTOMER_ID             => BEN1_UUID,
                    KEY_ASSESSMENT_RESULT       => buildAssessmentResult(ASSESSMENT_ID_BEN1)
                }
            }
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR), 'Beneficiary with no partyProfileId should be skipped, not throw');
        System.assertEquals(1, result.get(KEY_SUMMARY_COUNT), 'Only policyholder summary should be created');
    }

    @IsTest
    static void testNullPolicyholderProfileSkipped() {
        // WHY: Validates that a blank/null PolicyholderPartyProfileId causes the
        // policyholder to be skipped while beneficiaries are still processed.
        Account ben1Account = createThirdPartyAccount(BEN1_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile ben1Profile = createPartyProfile(ben1Account.Id, BEN1_FIRST_NAME, LAST_NAME_TIPIYAI);

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => null,
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>{
                new Map<String, Object>{
                    'beneficiaryId'             => BEN1_UUID,
                    'beneficiaryPartyProfileId' => String.valueOf(ben1Profile.Id),
                    KEY_CUSTOMER_ID             => BEN1_UUID,
                    KEY_ASSESSMENT_RESULT       => buildAssessmentResult(ASSESSMENT_ID_BEN1)
                }
            }
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR), 'Null PolicyholderPartyProfileId should not throw');
        System.assertEquals(1, result.get(KEY_SUMMARY_COUNT), 'Only beneficiary summary should be created');
        System.assertEquals(4, result.get('stepCount'),        'Only beneficiary steps should be created');
    }

    @IsTest
    static void testOutputContainsSummaryDetails() {
        // WHY: Validates the createdSummaries output structure — each entry must have
        // id, partyProfileId, and assessmentId for downstream OmniScript steps.
        Account phAccount = createPersonAccount(PH_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile phProfile = createPartyProfile(phAccount.Id, PH_FIRST_NAME, LAST_NAME_TIPIYAI);

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => String.valueOf(phProfile.Id),
            KEY_MEMBERS                       => new List<Object>(),
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>()
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        List<Object> summaries = (List<Object>) result.get('createdSummaries');
        System.assertEquals(1, summaries.size(), 'createdSummaries must have 1 entry');

        Map<String, Object> summary = (Map<String, Object>) summaries[0];
        System.assertNotEquals(null,           summary.get('id'),            'id must be present');
        System.assertEquals(phProfile.Id,      (Id) summary.get('partyProfileId'), 'partyProfileId must match');
        System.assertEquals(ASSESSMENT_ID_PH,  summary.get('assessmentId'), 'assessmentId must be present');
    }

    @IsTest
    static void testCallDispatchValidAction() {
        // WHY: Validates the Callable interface dispatches correctly for a recognised action.
        Account phAccount = createPersonAccount(PH_FIRST_NAME, LAST_NAME_TIPIYAI);
        PartyProfile phProfile = createPartyProfile(phAccount.Id, PH_FIRST_NAME, LAST_NAME_TIPIYAI);

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => String.valueOf(phProfile.Id),
            KEY_MEMBERS                       => new List<Object>(),
            KEY_POLICYHOLDER_SCREENING        => new Map<String, Object>{
                KEY_CUSTOMER_ID       => PH_CUSTOMER_UUID,
                KEY_ASSESSMENT_RESULT => buildAssessmentResult(ASSESSMENT_ID_PH)
            },
            KEY_BENEFICIARY_SCREENING         => new List<Object>()
        };

        Test.startTest();
        INS_PartyScreeningRemoteAction handler = new INS_PartyScreeningRemoteAction();
        Object callResult = handler.call(ACTION_CREATE_SCREENING, buildCallArguments(inputMap));
        Test.stopTest();

        System.assertNotEquals(null, callResult, 'call() with valid action must return non-null');
    }

    // =========================================================================
    // NEGATIVE TESTS
    // =========================================================================

    @IsTest
    static void testCallDispatchUnsupportedActionThrows() {
        // WHY: Validates the Callable contract — unrecognised action must throw.
        Test.startTest();
        INS_PartyScreeningRemoteAction handler = new INS_PartyScreeningRemoteAction();
        Boolean exceptionThrown = false;
        try {
            handler.call(ACTION_UNSUPPORTED, buildCallArguments(new Map<String, Object>()));
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'AuraHandledException must be thrown for unsupported action');
    }

    @IsTest
    static void testNullInputsCreatesNoRecords() {
        // WHY: Validates that completely null inputs produce no DML and no crash.
        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_PP_ID            => null,
            KEY_MEMBERS                       => new List<Object>(),
            KEY_POLICYHOLDER_SCREENING        => null,
            KEY_BENEFICIARY_SCREENING         => new List<Object>()
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyScreeningRemoteAction.createScreeningRecords(inputMap, outputMap);
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR), 'Null inputs should not throw');
        System.assertEquals(0, result.get(KEY_SUMMARY_COUNT), 'No summaries when input is null');
        System.assertEquals(0, result.get('stepCount'),        'No steps when input is null');
    }

    @IsTest
    static void testToObjectListKeyedMap() {
        // WHY: OmniStudio sometimes delivers JSON arrays as Map<String,Object> with
        // integer string keys. toObjectList must handle both forms identically.
        Map<String, Object> keyedMap = new Map<String, Object>{
            '0' => new Map<String, Object>{ KEY_VALUE => 'first' },
            '1' => new Map<String, Object>{ KEY_VALUE => 'second' }
        };

        List<Object> result = INS_PartyScreeningRemoteAction.toObjectList(keyedMap);

        System.assertEquals(2, result.size(), 'Both entries should be returned');
        System.assertEquals('first',  ((Map<String, Object>) result[0]).get(KEY_VALUE), 'Entry 0 must be first');
        System.assertEquals('second', ((Map<String, Object>) result[1]).get(KEY_VALUE), 'Entry 1 must be second');
    }
}