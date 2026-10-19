/**
 * @description Class for Selector Class for Applicant Entity Test class
 *
 * Story: SFP-37439
 *
 * @autor Ikyatha Naidu
 *
 * @date 29/03/2024
 *********************************
 * @last modified on  :  01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @ Modification Description : SFP-30275, used new field signing arrangement SBO-UK
 */
@IsTest
private class SEL_Applicant_Test {
    
    // Constant to avoid duplicate literals
    private static final String EXPECTED_DATA_MESSAGE = 'Expected applicantData to contain at least one item.';
    
    /**
     * @description Setup test data for Applicant tests
     */
    @testSetup
    static void setupTestData() {
        Account accRec = ICS_DAL_TestFactory.createAccount();
        PartyProfile profileData = ICS_DAL_TestFactory.createPartyProfile(accRec.Id); 
        ApplicationForm appForm = ICS_DAL_TestFactory.createApplicationForm(accRec.Id);
        ICS_DAL_TestFactory.createApplicant(accRec.Id, profileData.Id, appForm.Id);
    }

    /**
     * @description Verify the SObjectType functionality
     */
    @IsTest
    static void testGetSObjectType() {
        SEL_Applicant accountSelector = new SEL_Applicant();
        Schema.SObjectType sObjectType = accountSelector.getSObjectType();
        Assert.areEqual(Applicant.SObjectType, sObjectType, 'Unexpected SObjectType');
    }

    /**
     * @description Verify the SObjectFieldList functionality
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Applicant applicantSelector = new SEL_Applicant();
        List<Schema.SObjectField> sObjectFieldList = applicantSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = Applicant.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(false, sObjectFieldList.isEmpty(), 'Unexpected field count');
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.areEqual(true, fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
    }

    /**
     * @description Verify the selection of Applicant by Account Id
     */
    @IsTest
    static void testSelectByAccountId() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        Applicant applicantData = accountQueryList.selectByAccountId(accRec.Id);
        Test.stopTest();
        Assert.areNotEqual(null, applicantData, EXPECTED_DATA_MESSAGE);
    }

    /**
     * @description Verify the selection of Applicant by PartyProfile Id
     */
    @IsTest
    static void testSelectByPartyProfileId() {
        PartyProfile profileData = [SELECT Id FROM PartyProfile LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        Applicant applicantData = accountQueryList.selectByPartyProfileId(profileData.Id);
        Test.stopTest();
        Assert.areNotEqual(null, applicantData, EXPECTED_DATA_MESSAGE);
    }

    /**
     * @description Verify the selection of Applicants by ApplicationForm Ids
     */
    @IsTest
    static void testSelectByApplicationFormIds() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        List<Applicant> applicantData = accountQueryList.selectByApplicationFormIds(new Set<Id>{appForm.Id});
        Test.stopTest(); 
        Assert.areEqual(false, applicantData.isEmpty(), EXPECTED_DATA_MESSAGE);
    }
    
    /**
     * @description Verify the selection of Applicants by ApplicationForm Ids
     */
    @IsTest
    static void testselectPrimaryApplicantByOppIds() {
        ApplicationForm appForm = [SELECT Id,opportunityid FROM ApplicationForm LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        List<Applicant> applicantData = accountQueryList.selectPrimaryApplicantByOppIds(new List<Id>{appForm.opportunityid});
        Test.stopTest(); 
        Assert.areEqual(false, applicantData.isEmpty(), EXPECTED_DATA_MESSAGE);
    }

    /**
     * @description Verify the selection of Applicants by Account Ids
     */
    @IsTest
    static void testSelectByAccountIds() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        List<Applicant> applicantData = accountQueryList.selectByAccountIds(new Set<Id>{accRec.Id});
        Test.stopTest(); 
        Assert.areEqual(false, applicantData.isEmpty(), EXPECTED_DATA_MESSAGE);
    }

    /**
     * @description Verify the selection of Applicant by Id
     */
    @IsTest
    static void testSelectById() {
        Applicant applicantRec = [SELECT Id FROM Applicant LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        Applicant applicantData = accountQueryList.selectById(applicantRec.Id);
        Test.stopTest(); 
        Assert.areNotEqual(null, applicantData, 'Expected applicantList to contain at least one item.');
    }

    /**
     * @description Verify the selection of Primary Applicants by Account Ids
     */
    @IsTest
    static void testSelectPrimaryApplicantByAccountIds() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_Applicant accountQueryList = new SEL_Applicant();
        Test.startTest();
        List<Applicant> applicantData = accountQueryList.selectPrimaryApplicantByAccountIds(new Set<Id>{accRec.Id});
        Test.stopTest(); 
        Assert.areEqual(false, applicantData.isEmpty(), EXPECTED_DATA_MESSAGE);
    }
}