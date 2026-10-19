/**
* @description       : Test class for SEL_CMNRuleSetVersion selector.
*                      Provides code coverage for selector framework methods
*                      and selectById retrieval scenarios.
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
@IsTest
private class SEL_CMNRuleSetVersion_Test {

    /**
    * @description Creates CMN_Rule_Set_Version__c test data used across test methods.
    */
    @testSetup
    static void setupData() {
        List<CMN_Rule_Set_Version__c> records =
            new List<CMN_Rule_Set_Version__c>{

                new CMN_Rule_Set_Version__c(
                    Name = 'Version 1',
                    CMN_Return_Rate__c = 5,
                    CMN_Withdrawal_Rate__c = 4,
                    CMN_Default_Retirement_Age__c = 60
                ),

                new CMN_Rule_Set_Version__c(
                    Name = 'Version 2',
                    CMN_Return_Rate__c = 6,
                    CMN_Withdrawal_Rate__c = 5,
                    CMN_Default_Retirement_Age__c = 65
                )
            };

        insert records;
    }


    /**
    * @description Verifies that getSObjectType returns the correct SObjectType.
    */
    @IsTest
    static void testGetSObjectType() {

        SEL_CMNRuleSetVersion selector =
            new SEL_CMNRuleSetVersion();

        Test.startTest();

        try {

            Schema.SObjectType result =
                selector.getSObjectType();

            Assert.areEqual(
                CMN_Rule_Set_Version__c.SObjectType,
                result);

        }
        catch (Exception e) {
            Assert.fail(e.getMessage());
        }

        Test.stopTest();
    }


    /**
    * @description Verifies that getSObjectFieldList returns the expected selector fields.
    */
    @IsTest
    static void testGetSObjectFieldList() {

        SEL_CMNRuleSetVersion selector =
            new SEL_CMNRuleSetVersion();

        Test.startTest();

        try {

            List<Schema.SObjectField> fields =
                selector.getSObjectFieldList();

            Assert.isTrue(fields.size() > 0);

            Assert.isTrue(
                fields.contains(CMN_Rule_Set_Version__c.Name)
            );

        }
        catch (Exception e) {
            Assert.fail(e.getMessage());
        }

        Test.stopTest();
    }


    /**
    * @description Verifies that selectById returns null when a null Id is provided.
    */
    @IsTest
    static void testSelectById_Null() {

        SEL_CMNRuleSetVersion selector =
            new SEL_CMNRuleSetVersion();

        Test.startTest();

        try {

            CMN_Rule_Set_Version__c result =
                selector.selectById(null);

            Assert.areEqual(null, result);

        }
        catch (Exception e) {
            Assert.fail(e.getMessage());
        }

        Test.stopTest();
    }


    /**
    * @description Verifies that selectById returns the correct record for a valid Id.
    */
    @IsTest
    static void testSelectById_Valid() {

        CMN_Rule_Set_Version__c rec =
            [SELECT Id
             FROM CMN_Rule_Set_Version__c
             WHERE Name = 'Version 1'
             LIMIT 1];

        SEL_CMNRuleSetVersion selector =
            new SEL_CMNRuleSetVersion();

        Test.startTest();

        try {

            CMN_Rule_Set_Version__c result =
                selector.selectById(rec.Id);

            Assert.areNotEqual(null, result);

            Assert.areEqual(
                rec.Id,
                result.Id);

        }
        catch (Exception e) {
            Assert.fail(e.getMessage());
        }

        Test.stopTest();
    }

}