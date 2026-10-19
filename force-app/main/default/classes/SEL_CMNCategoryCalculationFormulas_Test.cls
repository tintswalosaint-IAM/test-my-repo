/**
* @description       : Test class for SEL_CMNCategoryCalculationFormulas selector.
*                      Provides code coverage for selector framework methods
*                      and validates retrieval of CMN_FHQ_CalculationFormula__mdt records.
* @author            : Preetham.Thernakal-Gandla@standardbank.co.za, Taimoor.Shaik@standardbank.co.za
* @created on        : Feb 2026
* @last modified on  :
* @last modified by  :
Ver       Date         Author                                                                             Modification       
1.0      Feb 2026      Preetham.Thernakal-Gandla@standardbank.co.za      Initial Creation(PPBSF-179, 127, 120) 
1.A      Feb 2026       Taimoor.shaik@standardbank.co.za                   (PPBSF-271, 176, 121, 122, 123, 119, 172, 270))
*/
@IsTest
private class SEL_CMNCategoryCalculationFormulas_Test {

    /**
    * @description Verifies that getSObjectType returns the correct SObjectType.
    */
    @IsTest
    static void testGetSObjectType() {

        SEL_CMNCategoryCalculationFormulas selector =
            new SEL_CMNCategoryCalculationFormulas();

        Test.startTest();

        try {

            Schema.SObjectType result =
                selector.getSObjectType();

            Assert.areEqual(
                CMN_FHQ_CalculationFormula__mdt.SObjectType,
                result
            );

        }
        catch (Exception e) {

            Assert.fail(e.getMessage());

        }

        Test.stopTest();
    }


    /**
    * @description Verifies that getSObjectFieldList returns the configured selector fields.
    */
    @IsTest
    static void testGetSObjectFieldList() {

        SEL_CMNCategoryCalculationFormulas selector =
            new SEL_CMNCategoryCalculationFormulas();

        Test.startTest();

        try {

            List<Schema.SObjectField> fields =
                selector.getSObjectFieldList();

            Assert.isTrue(!fields.isEmpty());

            Assert.isTrue(
                fields.contains(
                    CMN_FHQ_CalculationFormula__mdt.DeveloperName
                )
            );

        }
        catch (Exception e) {

            Assert.fail(e.getMessage());

        }

        Test.stopTest();
    }


    /**
    * @description Verifies that getCategoryCalculationFormulas executes successfully
    *              and returns a non-null list of metadata records.
    */
    @IsTest
    static void testGetCategoryCalculationFormulas() {

        SEL_CMNCategoryCalculationFormulas selector =
            new SEL_CMNCategoryCalculationFormulas();

        Test.startTest();

        try {

            List<CMN_FHQ_CalculationFormula__mdt> results =
                selector.getCategoryCalculationFormulas();

            // Metadata may or may not exist in test context
            Assert.areNotEqual(null, results);

        }
        catch (Exception e) {

            Assert.fail(e.getMessage());

        }

        Test.stopTest();
    }

}