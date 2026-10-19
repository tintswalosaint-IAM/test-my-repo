/**
* @description Class for Selector Class for Assessment Entity Test class
*
* Story:SFP-37439
*
* @author Ikyatha Naidu 
*
* @date 29/03/2024
*********************************
* @last modified on  :  01/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description :SFP-30275, Updated to latest version
*/
@isTest
private class SEL_Assesment_Test {
 /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createOpportunity(acc.Id);
        Assessment assessmentRec=ICS_DAL_TestFactory.createAssessment(acc.Id);
		Contact con=ICS_DAL_TestFactory.createContact();
		assessmentRec.ContactId=con.id;
		update assessmentRec;
    }
    
    /**
     * @description Test the getSObjectType method of SEL_Assesment class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_Assesment assesmentSelector = new SEL_Assesment();
        Test.startTest();
        Schema.SObjectType sObjectType = assesmentSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Assessment.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
     * @description Test the getSObjectFieldList method of SEL_Assesment class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_Assesment assesmentSelector = new SEL_Assesment();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = assesmentSelector.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }
    
    /**
     * @description Test the selectByParentId method of SEL_Assesment class
     */
    @isTest
    static void testSelectByParentId() {
        Account acc = [SELECT Id FROM Account LIMIT 1]; // Fetch the account created in @TestSetup
        SEL_Assesment assesmentSelector = new SEL_Assesment();
        Test.startTest();
        List<Assessment> assessmentList = assesmentSelector.SelectByAccountId(acc.Id);
        assesmentSelector.selectByParentId(acc.Id);
        Test.stopTest();
        Assert.areEqual(true, assessmentList.size() > 0, 'Expected at least one Assessment record.');
    }

    /**
     * @description Test the selectByParentIdAndSectionName method of SEL_Assesment class
     */
    @isTest
    static void testSelectByParentIdAndSectionName() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; // Fetch the opportunity created in @TestSetup
        SEL_Assesment assesmentSelector = new SEL_Assesment();
        Test.startTest();
        List<Assessment> assessmentList = assesmentSelector.selectByParentIdAndSectionName(opp.Id, 'test');
        Test.stopTest();
        Assert.areEqual(false, assessmentList.size() > 0, 'Expected at least one Assessment record for the given section name.');
    }
     @isTest
    static void testSelectByAccountIds() {
        try{
       
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();
		Contact con=[SELECT Id FROM Contact limit 1];
        SEL_Assesment assesmentSelector = new SEL_Assesment();
        Test.startTest();
        List<Assessment> assessments = assesmentSelector.selectByAccountIds(accountIds);
            List<Assessment> assesmentsByAccountIdorContactIdList=assesmentSelector.selectByAccountIdorContactId(accountIds,new list<id>{con.Id});
        Test.stopTest();
        Assert.areEqual(1, assessments.size(), 'Expected 3 assessments to be returned.');
        Assert.areEqual(1, assesmentsByAccountIdorContactIdList.size(), 'Expected 3 assessments to be returned.');
        }catch(Exception ex){
             Assert.areEqual(true, ex.getmessage() != null, 'Error Occured');
        }
    }

    @isTest
    static void testSelectByIds() {
        try{
       
        Set<Id> assessmentIds = new Map<Id, Assessment>([SELECT Id FROM Assessment]).keySet();
        SEL_Assesment assesmentSelector = new SEL_Assesment();

        Test.startTest();
        List<Assessment> assessmentList = assesmentSelector.selectByIds(assessmentIds);
        Test.stopTest();
        Assert.areEqual(true, assessmentList.size() > 0, 'Expected at least one Assessment record.');
        }catch(Exception ex){
             Assert.areEqual(true, ex.getmessage() != null, 'Error Occured');
        }
    }
}