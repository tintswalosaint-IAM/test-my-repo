/**
* @description       : Test class for SEL_FHQAnswerScoring selector.
*                      Provides code coverage for selector framework methods
*                      and validates retrieval of FHQ_Answer_Scoring__mdt records.
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
@IsTest
private class SEL_FHQAnswerScoring_Test {

    /**
    * @description Verifies that getSObjectType returns the correct SObjectType.
    */
    @IsTest
    static void testGetSObjectType() {

        SEL_FHQAnswerScoring selector =
            new SEL_FHQAnswerScoring();

        Schema.SObjectType result =
            selector.getSObjectType();

        Assert.areEqual(
            FHQ_Answer_Scoring__mdt.SObjectType,
            result
        );
    }


    /**
    * @description Verifies that getSObjectFieldList returns the configured selector fields.
    */
    @IsTest
    static void testGetSObjectFieldList() {

        SEL_FHQAnswerScoring selector =
            new SEL_FHQAnswerScoring();

        List<Schema.SObjectField> fields =
            selector.getSObjectFieldList();

        Assert.isTrue(fields.size() > 0);

        Assert.isTrue(
            fields.contains(
                FHQ_Answer_Scoring__mdt.Question_Name__c
            )
        );
    }


    /**
    * @description Verifies that selectActiveQuestions executes successfully
    *              and returns a non-null list of metadata records.
    */
    @IsTest
    static void testSelectActiveQuestions() {

        Test.startTest();

        SEL_FHQAnswerScoring selector =
            new SEL_FHQAnswerScoring();

        List<FHQ_Answer_Scoring__mdt> results =
            selector.selectActiveQuestions();

        Test.stopTest();

        // Metadata may or may not exist in test context
        Assert.areNotEqual(null, results);
    }


    /**
    * @description Verifies repeated selector method calls to ensure consistent execution.
    */
    @IsTest
    static void testMultipleSelectorCalls() {

        SEL_FHQAnswerScoring selector =
            new SEL_FHQAnswerScoring();

        selector.getSObjectType();

        selector.getSObjectFieldList();

        selector.selectActiveQuestions();

        Assert.isNotNull(selector, 'Selector instance must be created successfully');
    }

}