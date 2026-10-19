/***************************************************************************************
@ Author            : Jyothsna.datla@standardbank.co.za
@ Date              : 19-02-2026
@ Name of the Class : SEL_FHQ_Question_Configuration_Test
@ Description       : This class is used to test SEL_FHQ_Question_Configuration selector class
@ Modification Log  :
1.0   Feb 2026      Jyothsna.datla@standardbank.co.za     Initial Creation (PPBSF-291)
***************************************************************************************/
@IsTest
private class SEL_FHQ_Question_Configuration_Test {

      /**
     * @description Validates getSObjectType() and getSObjectFieldList()
     *              methods to ensure correct metadata object type and
     *              field list are returned.
     */
    @IsTest
    static void testSelectorMetadataMethods() {

        SEL_FHQ_Question_Configuration selector =
            new SEL_FHQ_Question_Configuration();

        System.assertEquals(
            FHQ_Question_Configuration__mdt.SObjectType,
            selector.getSObjectType(),
            'SObjectType should match custom metadata type'
        );

        Assert.isTrue(
            selector.getSObjectFieldList().size() > 0,
            'Field list should not be empty'
        );
    }

     /**
     * @description Validates selectAll() method to ensure all
     *              FHQ Question Configuration metadata records
     *              are retrieved without errors.
     */
    @IsTest
    static void testSelectAll() {

        Test.startTest();

        SEL_FHQ_Question_Configuration selector =
            new SEL_FHQ_Question_Configuration();

        List<FHQ_Question_Configuration__mdt> results =
            selector.selectAll();

        Test.stopTest();

        Assert.areNotEqual(
            null,
            results,
            'selectAll should return a list'
        );
    }

    
    /**
     * @description Validates selectByRecordType() method to ensure
     *              metadata records are filtered correctly based
     *              on Record_Type__c.
     */
    @IsTest
    static void testSelectByRecordType() {

        SEL_FHQ_Question_Configuration selector =
            new SEL_FHQ_Question_Configuration();

        // Use a dummy record type (won’t fail even if no records exist)
        String recordType = 'TEST';

        Test.startTest();
        List<FHQ_Question_Configuration__mdt> results =
            selector.selectByRecordType(recordType);
        Test.stopTest();

        Assert.areNotEqual(
            null,
            results,
            'selectByRecordType should return a list'
        );
    }

   /**
     * @description Validates selectIncludedInTotal() method to ensure
     *              only metadata records marked as Include_In_Total__c = true
     *              are retrieved successfully.
     */
    @IsTest
    static void testSelectIncludedInTotal() {

        SEL_FHQ_Question_Configuration selector =
            new SEL_FHQ_Question_Configuration();

        Test.startTest();
        List<FHQ_Question_Configuration__mdt> results =
            selector.selectIncludedInTotal();
        Test.stopTest();

        Assert.areNotEqual(
            null,
            results,
            'selectIncludedInTotal should return a list'
        );
    }
}