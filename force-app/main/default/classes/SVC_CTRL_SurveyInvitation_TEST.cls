/***************************************************************************************
@Name of the Component : SVC_CTRL_SurveyInvitation_TEST
@Description : Test class for SVC_CTRL_SurveyInvitation
@Author : Raymond Magezi
@Created Date : 15-04-2026
User Story: SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 22-04-2026
@Modification description: Removed forceException tests. Updated to use mock pattern
    for selector results via injectable SEL_BranchUnit mock subclass.
 User Story: SFP-57596
***************************************************************************************/
@IsTest(SeeAllData=false)
private class SVC_CTRL_SurveyInvitation_TEST {

    private static final String BRANCH_NAME = 'ACACIA MALL';
    private static final String DEPT_NAME = 'Human Resources';
    private static final String MOCK_LINK = 'https://test.salesforce.com/survey/mock';
    private static final String FAKE_SURVEY_ID = Survey.SObjectType.getDescribe().getKeyPrefix() + '000000000001';
    private static final String BRANCH_NTINDA = 'NTINDA';
    private static final String ASSERT_AURA_EXCEPTION = 'Should throw AuraHandledException when selector fails';

    /**
     * @description Mock SEL_BranchUnit that throws errors for negative test paths
     */
    private class MockBranchUnitSelector extends SEL_BranchUnit {
        public override List<Map<String, String>> selectActiveBranches() {
            throw new AuraHandledException('Mock branch error');
        }
        public override List<Map<String, String>> selectActiveDepartments() {
            throw new AuraHandledException('Mock department error');
        }
    }

    /**
     * @description Mock SEL_SurveyInvitation that throws errors for negative test paths
     */
    private class MockSurveyInvitationSelector extends SEL_SurveyInvitation {
        public override List<SurveyInvitation> selectByBranchName(String branchName) {
            throw new AuraHandledException('Mock branch invitation error');
        }
        public override List<SurveyInvitation> selectByDepartmentName(String departmentName) {
            throw new AuraHandledException('Mock department invitation error');
        }
    }

    /**
     * @description Mock SEL_SurveyInvitation that returns a result with an InvitationLink
     */
    private class MockSurveyInvitationSelectorWithResults extends SEL_SurveyInvitation {
        private List<SurveyInvitation> buildResult() {
            return (List<SurveyInvitation>) JSON.deserialize(
                '[{"InvitationLink":"' + MOCK_LINK + '"}]', List<SurveyInvitation>.class
            );
        }
        public override List<SurveyInvitation> selectByBranchName(String branchName) {
            return buildResult();
        }
        public override List<SurveyInvitation> selectByDepartmentName(String departmentName) {
            return buildResult();
        }
    }

    /**
     * @description Test getBranchOptions returns picklist values
     */
    @isTest
    private static void testGetBranchOptionsPositiveOutcome() {
        Test.startTest();
        List<Map<String, String>> results = SVC_CTRL_SurveyInvitation.getBranchOptions();
        Test.stopTest();
        Assert.isTrue(!results.isEmpty(), 'Branch options should be returned');
    }

    /**
     * @description Test getBranchOptions throws AuraHandledException when selector fails
     */
    @isTest
    private static void testGetBranchOptionsNegativeOutcome() {
        SVC_CTRL_SurveyInvitation.mockBranchUnitSelector = new MockBranchUnitSelector();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.getBranchOptions();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, ASSERT_AURA_EXCEPTION);
    }

    /**
     * @description Test getDepartmentOptions returns picklist values
     */
    @isTest
    private static void testGetDepartmentOptionsPositiveOutcome() {
        Test.startTest();
        List<Map<String, String>> results = SVC_CTRL_SurveyInvitation.getDepartmentOptions();
        Test.stopTest();
        Assert.isTrue(!results.isEmpty(), 'Department options should be returned');
    }

    /**
     * @description Test getDepartmentOptions throws AuraHandledException when selector fails
     */
    @isTest
    private static void testGetDepartmentOptionsNegativeOutcome() {
        SVC_CTRL_SurveyInvitation.mockBranchUnitSelector = new MockBranchUnitSelector();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.getDepartmentOptions();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, ASSERT_AURA_EXCEPTION);
    }

    /**
     * @description Test getQRCodeBaseUrl returns a URL from custom metadata
     */
    @isTest
    private static void testGetQRCodeBaseUrlPositiveOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getQRCodeBaseUrl();
        Test.stopTest();
        Assert.isNotNull(result, 'QR code base URL should be returned');
    }

    /**
     * @description Test getInvitationLinkByBranch returns null for blank input
     */
    @isTest
    private static void testGetInvitationLinkByBranchBlankNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getInvitationLinkByBranch('');
        Test.stopTest();
        Assert.isNull(result, 'Should return null for blank input');
    }

    /**
     * @description Test getInvitationLinkByBranch returns null when no invitation exists
     */
    @isTest
    private static void testGetInvitationLinkByBranchNoMatchNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getInvitationLinkByBranch('NONEXISTENT');
        Test.stopTest();
        Assert.isNull(result, 'Should return null when no match');
    }

    /**
     * @description Test getInvitationLinkByDepartment returns null for blank input
     */
    @isTest
    private static void testGetInvitationLinkByDepartmentBlankNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getInvitationLinkByDepartment('');
        Test.stopTest();
        Assert.isNull(result, 'Should return null for blank input');
    }

    /**
     * @description Test getInvitationLinkByDepartment returns null when no invitation exists
     */
    @isTest
    private static void testGetInvitationLinkByDepartmentNoMatchNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getInvitationLinkByDepartment('NONEXISTENT');
        Test.stopTest();
        Assert.isNull(result, 'Should return null when no match');
    }

    /**
     * @description Test getInvitationLinkByBranch throws AuraHandledException when selector fails
     */
    @isTest
    private static void testGetInvitationLinkByBranchSelectorNegativeOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelector();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.getInvitationLinkByBranch(BRANCH_NAME);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, ASSERT_AURA_EXCEPTION);
    }

    /**
     * @description Test getInvitationLinkByDepartment throws AuraHandledException when selector fails
     */
    @isTest
    private static void testGetInvitationLinkByDepartmentSelectorNegativeOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelector();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.getInvitationLinkByDepartment(DEPT_NAME);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, ASSERT_AURA_EXCEPTION);
    }

    /**
     * @description Test createInvitationForBranch returns null for missing surveyId
     */
    @isTest
    private static void testCreateInvitationForBranchMissingSurveyIdNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.createInvitationForBranch(null, BRANCH_NAME, BRANCH_NAME);
        Test.stopTest();
        Assert.isNull(result, 'Should return null when surveyId is blank');
    }

    /**
     * @description Test createInvitationForBranch returns null for blank branch name
     */
    @isTest
    private static void testCreateInvitationForBranchBlankNameNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.createInvitationForBranch(FAKE_SURVEY_ID, BRANCH_NAME, '');
        Test.stopTest();
        Assert.isNull(result, 'Should return null when branchName is blank');
    }

    /**
     * @description Test createInvitationForDepartment returns null for missing surveyId
     */
    @isTest
    private static void testCreateInvitationForDepartmentMissingSurveyIdNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.createInvitationForDepartment(null, DEPT_NAME);
        Test.stopTest();
        Assert.isNull(result, 'Should return null when surveyId is blank');
    }

    /**
     * @description Test createInvitationForDepartment returns null for blank department
     */
    @isTest
    private static void testCreateInvitationForDepartmentBlankNameNegativeOutcome() {
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.createInvitationForDepartment(FAKE_SURVEY_ID, '');
        Test.stopTest();
        Assert.isNull(result, 'Should return null when departmentName is blank');
    }

    /**
     * @description Test createInvitationForBranch happy path using mock
     */
    @isTest
    private static void testCreateInvitationForBranchPositiveOutcome() {
        SVC_CTRL_SurveyInvitation.mockInvitationLink = MOCK_LINK;
        Test.startTest();
        String link = SVC_CTRL_SurveyInvitation.createInvitationForBranch(FAKE_SURVEY_ID, BRANCH_NTINDA, BRANCH_NTINDA);
        Test.stopTest();
        Assert.areEqual(MOCK_LINK, link, 'Should return the mock invitation link');
    }

    /**
     * @description Test createInvitationForDepartment happy path using mock
     */
    @isTest
    private static void testCreateInvitationForDepartmentPositiveOutcome() {
        SVC_CTRL_SurveyInvitation.mockInvitationLink = MOCK_LINK;
        Test.startTest();
        String link = SVC_CTRL_SurveyInvitation.createInvitationForDepartment(FAKE_SURVEY_ID, 'Legal');
        Test.stopTest();
        Assert.areEqual(MOCK_LINK, link, 'Should return the mock invitation link');
    }

    /**
     * @description Test createInvitationForBranch throws AuraHandledException for non-existent survey Id
     */
    @isTest
    private static void testCreateInvitationForBranchInvalidSurveyIdNegativeOutcome() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.createInvitationForBranch(FAKE_SURVEY_ID, BRANCH_NTINDA, BRANCH_NTINDA);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for invalid survey Id');
    }

    /**
     * @description Test createInvitationForDepartment throws AuraHandledException for non-existent survey Id
     */
    @isTest
    private static void testCreateInvitationForDepartmentInvalidSurveyIdNegativeOutcome() {
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.createInvitationForDepartment(FAKE_SURVEY_ID, 'Legal');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, 'Should throw AuraHandledException for invalid survey Id');
    }

    /**
     * @description Test getInvitationLinkByBranch returns link when invitation exists
     */
    @isTest
    private static void testGetInvitationLinkByBranchPositiveOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelectorWithResults();
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getInvitationLinkByBranch(BRANCH_NAME);
        Test.stopTest();
        Assert.areEqual(MOCK_LINK, result, 'Should return the invitation link');
    }

    /**
     * @description Test getInvitationLinkByDepartment returns link when invitation exists
     */
    @isTest
    private static void testGetInvitationLinkByDepartmentPositiveOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelectorWithResults();
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.getInvitationLinkByDepartment(DEPT_NAME);
        Test.stopTest();
        Assert.areEqual(MOCK_LINK, result, 'Should return the invitation link');
    }

    /**
     * @description Test createInvitationForBranch returns existing link when invitation already exists
     */
    @isTest
    private static void testCreateInvitationForBranchExistingLinkPositiveOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelectorWithResults();
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.createInvitationForBranch(FAKE_SURVEY_ID, BRANCH_NAME, BRANCH_NAME);
        Test.stopTest();
        Assert.areEqual(MOCK_LINK, result, 'Should return existing invitation link');
    }

    /**
     * @description Test createInvitationForDepartment returns existing link when invitation already exists
     */
    @isTest
    private static void testCreateInvitationForDepartmentExistingLinkPositiveOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelectorWithResults();
        Test.startTest();
        String result = SVC_CTRL_SurveyInvitation.createInvitationForDepartment(FAKE_SURVEY_ID, DEPT_NAME);
        Test.stopTest();
        Assert.areEqual(MOCK_LINK, result, 'Should return existing invitation link');
    }

    /**
     * @description Test createInvitationForBranch throws AuraHandledException when selector fails
     */
    @isTest
    private static void testCreateInvitationForBranchSelectorNegativeOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelector();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.createInvitationForBranch(FAKE_SURVEY_ID, BRANCH_NAME, BRANCH_NAME);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, ASSERT_AURA_EXCEPTION);
    }

    /**
     * @description Test createInvitationForDepartment throws AuraHandledException when selector fails
     */
    @isTest
    private static void testCreateInvitationForDepartmentSelectorNegativeOutcome() {
        SVC_CTRL_SurveyInvitation.mockSurveyInvitationSelector = new MockSurveyInvitationSelector();
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            SVC_CTRL_SurveyInvitation.createInvitationForDepartment(FAKE_SURVEY_ID, DEPT_NAME);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(exceptionThrown, ASSERT_AURA_EXCEPTION);
    }
}