/***************************************************************************************
@Name of the Component : SEL_Case_TEST
@Description : Test class for SEL_Case
@Author : Siarhei Maroz
@Created Date : 18 July 2025
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 29 July 2025
@Modification description: this class was created to test coverage of methods for SEL_Case class
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 28 July 2026
@Modification description: Added testSelectEscalationCandidatesQueryLocator, migrated from
 SEL_UGCaseEscalation_TEST.testGetEscalationCandidatesQueryLocator
 User Story: SFP-59565
/***************************************************************************************
@Last Modified By : Givem Khupai
@Last Modified On : 2026-08-04
@Modification description: SFP-46473 added selectByIds tests, added getSObjectType and
 getSObjectFieldList coverage; SIT merge switched tests to SEL_Case.newInstance(), removed
 selectByIds tests (method removed from selector), fixed testSelectCaseByNumber to requery
 CaseNumber, added coverage for selectCountryById and selectWithTeamNotificationFieldsByIds
 (SFP-58600); restored testSelectEscalationCandidatesQueryLocator (SFP-59565) that was
 dropped by the SIT merge, retained metrics field coverage
***************************************************************************************/
@IsTest(SeeAllData=false)
private class SEL_Case_TEST {

    private static final String CASE_SUBJECT = 'Test Case';
    private static final String SUPPLIED_EMAIL = 'test@test.com';
    private static final String ASSERT_CASE_FOUND = 'Case was not found';
    private static final String ASSERT_CASE_EMPTY = 'Expected no cases returned';

    /*------------------------------------------------------------
    *   Purpose:  Verifies getSObjectType returns Case.SObjectType.
    *--------------------------------------------------------------*/
    @IsTest
    static void getSObjectTypeReturnsCaseSObjectType() {
        SEL_Case selector = SEL_Case.newInstance();

        Test.startTest();
        Schema.SObjectType result = selector.getSObjectType();
        Test.stopTest();

        Assert.areEqual(Case.SObjectType, result, 'SObjectType should be Case');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies getSObjectFieldList returns the expected
    *             fields including TAT milestone date fields.
    *--------------------------------------------------------------*/
    @IsTest
    static void getSObjectFieldListContainsMilestoneFields() {
        SEL_Case selector = SEL_Case.newInstance();

        Test.startTest();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Test.stopTest();

        Assert.isFalse(fieldList.isEmpty(), 'Field list should not be empty');
        Assert.isTrue(fieldList.contains(Case.BusinessHoursId), 'Should contain BusinessHoursId');
        Assert.isTrue(fieldList.contains(Case.SVC_Case_Allocation_Date__c), 'Should contain Allocation Date');
        Assert.isTrue(fieldList.contains(Case.SVC_CaseClassificationDate__c), 'Should contain Classification Date');
        Assert.isTrue(fieldList.contains(Case.SVC_ResolvedDate__c), 'Should contain Resolved Date');
        Assert.isTrue(fieldList.contains(Case.ClosedDate), 'Should contain ClosedDate');
        Assert.isTrue(fieldList.contains(Case.CreatedDate), 'Should contain CreatedDate');
        Assert.isTrue(fieldList.contains(Case.Status), 'Should contain Status');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCaseById returns the correct Case.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCaseByIdReturnsMatchingCase() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCaseById(newCase.Id);
        Test.stopTest();

        Assert.areEqual(1, cases.size(), ASSERT_CASE_FOUND);
        Assert.areEqual(newCase.Id, cases[0].Id, 'Should return the correct Case');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCaseById returns empty list when
    *             the Case does not exist.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCaseByIdReturnsEmptyWhenNotFound() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;
        delete newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCaseById(newCase.Id);
        Test.stopTest();

        Assert.areEqual(0, cases.size(), ASSERT_CASE_EMPTY);
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCaseByNumber returns the correct
    *             Case when queried by its CaseNumber.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCaseByNumberReturnsMatchingCase() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;
        String caseNumber = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id].CaseNumber;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCaseByNumber(caseNumber);
        Test.stopTest();

        Assert.areEqual(1, cases.size(), ASSERT_CASE_FOUND);
        Assert.areEqual(newCase.Id, cases[0].Id, 'Should return the correct Case');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCasesByClaimId returns Cases
    *             matching the Insurance_Claim__c lookup.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCasesByClaimIdReturnsMatchingCases() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCasesByClaimId(newCase.Insurance_Claim__c);
        Test.stopTest();

        Assert.isFalse(cases.isEmpty(), ASSERT_CASE_FOUND);
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCasesByClaimId returns empty list
    *             when no Cases match the claim Id.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCasesByClaimIdReturnsEmptyWhenNoMatch() {
        Id nonExistentClaimId = CMN_DAL_SObjectDomain.generateIncrementalId(Claim.SObjectType);

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCasesByClaimId(nonExistentClaimId);
        Test.stopTest();

        Assert.areEqual(0, cases.size(), ASSERT_CASE_EMPTY);
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCasesByPolicyId returns Cases
    *             matching the Insurance_Policy__c lookup.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCasesByPolicyIdReturnsMatchingCases() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCasesByPolicyId(newCase.Insurance_Policy__c);
        Test.stopTest();

        Assert.isFalse(cases.isEmpty(), ASSERT_CASE_FOUND);
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCountryById returns the Case with
    *             the Case_Owner_Country__c field populated.
    *             SFP-58600
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCountryByIdReturnsMatchingCase() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCountryById(newCase.Id);
        Test.stopTest();

        Assert.areEqual(1, cases.size(), ASSERT_CASE_FOUND);
        Assert.areEqual(newCase.Id, cases[0].Id, 'Should return the correct Case');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectWithTeamNotificationFieldsByIds
    *             returns the Case with service team notification
    *             fields. SFP-58600
    *--------------------------------------------------------------*/
    @IsTest
    static void selectWithTeamNotificationFieldsByIdsReturnsMatchingCases() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectWithTeamNotificationFieldsByIds(new Set<Id>{ newCase.Id });
        Test.stopTest();

        Assert.areEqual(1, cases.size(), ASSERT_CASE_FOUND);
        Assert.areEqual(newCase.Id, cases[0].Id, 'Should return the correct Case');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectEscalationCandidatesQueryLocator
    *             builds and returns a usable QueryLocator.
    *             SFP-59565
    *--------------------------------------------------------------*/
    @IsTest
    static void testSelectEscalationCandidatesQueryLocator() {
        Test.startTest();
        Database.QueryLocator locator = SEL_Case.newInstance()
            .selectEscalationCandidatesQueryLocator('UG', 5, 'Closed');
        Test.stopTest();

        Assert.isNotNull(locator, 'QueryLocator should not be null');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies selectCasesBySuppliedEmail returns the
    *             Case matching the SuppliedEmail field.
    *--------------------------------------------------------------*/
    @IsTest
    static void selectCasesBySuppliedEmailReturnsMatchingCase() {
        Case newCase = new Case(
            Subject = CASE_SUBJECT,
            SuppliedEmail = SUPPLIED_EMAIL
        );
        insert newCase;

        Test.startTest();
        List<Case> cases = SEL_Case.newInstance().selectCasesBySuppliedEmail(SUPPLIED_EMAIL);
        Test.stopTest();

        Assert.areEqual(1, cases.size(), ASSERT_CASE_FOUND);
    }
}