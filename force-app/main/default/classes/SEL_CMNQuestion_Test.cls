/**
* @description       : Test class for SEL_CMNQuestion selector.
*                      Provides code coverage for selector framework methods
*                      and validates retrieval of CMN_Question__c records,
*                      including active and ordered questions.
* @author            : Taimoor.Shaik@standardbank.co.za, Preetham.Thernakal-Gandla@standardbank.co.za
* @created on        : Feb 2026
* @last modified on  :
* @last modified by  :
@ Modification Description :
1.0   Feb 2026      Taimoor.Shaik@standardbank.co.za, Preetham.Thernakal-Gandla@standardbank.co.za     Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119,270,172)
*/
@IsTest
private class SEL_CMNQuestion_Test {

    /**
    * @description Creates CMN_Question__c test data used across all test methods.
    */
    @testSetup
    static void setupData() {

        List<CMN_Question__c> questions = new List<CMN_Question__c>{
            new CMN_Question__c(
                Name = 'Q1',
                Is_Active__c = true
            ),
            new CMN_Question__c(
                Name = 'Q2',
                Is_Active__c = true
            ),
            new CMN_Question__c(
                Name = 'Q3',
                Is_Active__c = false
            )
        };

        insert questions;
    }

    /**
    * @description Verifies that getSObjectType returns the correct SObjectType.
    */
    @IsTest
    static void testGetSObjectType() {

        SEL_CMNQuestion selector = new SEL_CMNQuestion();

        Test.startTest();
        try {
            Schema.SObjectType result = selector.getSObjectType();
            Assert.areEqual
 (CMN_Question__c.SObjectType, result);
        } catch (Exception e) {
            Assert.isTrue(false, 'Unexpected exception1: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
    * @description Verifies that getSObjectFieldList returns the configured selector fields.
    */
    @IsTest
    static void testGetSObjectFieldList() {

        SEL_CMNQuestion selector = new SEL_CMNQuestion();

        Test.startTest();
        try {
            List<Schema.SObjectField> fields =
                selector.getSObjectFieldList();
            Assert.isTrue(fields.size() > 0);
        } catch (Exception e) {
            Assert.isTrue(false, 'Unexpected exception2: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
    * @description Verifies that selectById returns null when a null Id is provided.
    */
    @IsTest
    static void testSelectById_Null() {

        SEL_CMNQuestion selector = new SEL_CMNQuestion();

        Test.startTest();
        try {
            CMN_Question__c result = selector.selectById(null);
            Assert.areEqual
 (null, result);
        } catch (Exception e) {
            Assert.isTrue(false, 'Unexpected exception3: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
    * @description Verifies that selectById returns the correct question record.
    */
    @IsTest
    static void testSelectById_Valid() {

        CMN_Question__c question =
            [SELECT Id FROM CMN_Question__c WHERE Name = 'Q1' LIMIT 1];

        SEL_CMNQuestion selector = new SEL_CMNQuestion();

        Test.startTest();
        try {
            CMN_Question__c result =
                selector.selectById(question.Id);

            Assert.areNotEqual(null, result);
            Assert.areEqual
 (question.Id, result.Id);
        } catch (Exception e) {
            Assert.isTrue(false, 'Unexpected exception4: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
    * @description Verifies that selectActiveQuestions returns only active questions.
    */
    @IsTest
    static void testSelectActiveQuestions() {

        SEL_CMNQuestion selector = new SEL_CMNQuestion();

        Test.startTest();
        try {
            List<CMN_Question__c> activeQuestions =
                selector.selectActiveQuestions();

            Assert.areEqual
 (2, activeQuestions.size());

            for (CMN_Question__c q : activeQuestions) {
                Assert.areEqual
 (true, q.Is_Active__c);
            }
        } catch (Exception e) {
            Assert.isTrue(false, 'Unexpected exception5: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
    * @description Verifies that selectActiveQuestionsInOrder returns active questions
    *              sorted in ascending order by CMN_Order__c.
    */
    @IsTest
    static void testSelectActiveQuestionsInOrder() {

        SEL_CMNQuestion selector = new SEL_CMNQuestion();

        Test.startTest();
        try {
            List<CMN_Question__c> orderedQuestions =
                selector.selectActiveQuestionsInOrder();

            Assert.areEqual
 (2, orderedQuestions.size());
            Assert.areEqual
 ('Q1', orderedQuestions[0].Name);
            Assert.areEqual
 ('Q2', orderedQuestions[1].Name);

        } catch (Exception e) {
            Assert.isTrue(false, 'Unexpected exception6: ' + e.getMessage());
        }
        Test.stopTest();
    }
}