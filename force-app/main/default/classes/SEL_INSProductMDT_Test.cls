/**
 * @description       : Class for Selector Class for INS_Products__mdt Entity Test class
 * @Name of the Class: SEL_INSProductMDT_Test.cls
 * @Story: SFP-55927
 * @date Aug 2026
 * @last modified on: 13-08-2026
 * @last modified by: 
 * @ Modification Description: SFP-55927, Created test methods for SEL_INSProductMDT selector class.
 */
@IsTest
@SuppressWarnings('PMD.TooManyMethods, PMD.AvoidDuplicateLiterals')
public with sharing class SEL_INSProductMDT_Test {
    /**
     * @description   method testGetSObjectType.
     * @author Mahesh Reddy('Mahesh Reddy')
     * @date 13-08-2026
     */ 
    @IsTest
    static void testGetSObjectType() {
        SEL_INSProductMDT selector = new SEL_INSProductMDT();

        Test.startTest();

        Schema.SObjectType sObjectType = selector.getSObjectType();

        Test.stopTest();

        Assert.areEqual(
            INS_Products__mdt.SObjectType,
            sObjectType,
            'The returned SObjectType should match INS_Products__mdt.SObjectType.'
        );
    }
    /**
     * @description   method testGetSObjectFieldList.
     * @author Mahesh Reddy('Mahesh Reddy')
     * @date 13-08-2026
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_INSProductMDT selector = new SEL_INSProductMDT();

        Test.startTest();

        List<Schema.SObjectField> fieldList =
            selector.getSObjectFieldList();

        Test.stopTest();

        Map<String, Schema.SObjectField> fieldMap =
            INS_Products__mdt.SObjectType.getDescribe().fields.getMap();

        Assert.isNotNull(
            fieldList,
            'The field list should not be null.'
        );

        Assert.isTrue(
            !fieldList.isEmpty(),
            'The field list should not be empty.'
        );

        for (Schema.SObjectField field : fieldList) {
            Assert.isTrue(
                fieldMap.containsKey(field.getDescribe().getName()),
                'Field ' + field.getDescribe().getName() +
                ' should exist on INS_Products__mdt.'
            );
        }
    }
    /**
     * @description   method testSelectByCountry.
     * @author Mahesh Reddy('Mahesh Reddy')
     * @date 13-08-2026
     */
    @IsTest
    static void testSelectByCountry() {
        // Get an existing Custom Metadata record.
        List<INS_Products__mdt> productMetadata = [
            SELECT Id,
                Country__c,
                Is_Liberty__c,
                INS_Customer_Brand__c
            FROM INS_Products__mdt
            LIMIT 1
        ];

        Assert.isTrue(
            !productMetadata.isEmpty(),
            'At least one INS_Products__mdt record is required for this test.'
        );

        INS_Products__mdt expectedProduct = productMetadata[0];

        SEL_INSProductMDT selector = new SEL_INSProductMDT();

        Test.startTest();

        List<INS_Products__mdt> results =
            selector.selectByCountry(
                expectedProduct.Country__c,
                expectedProduct.Is_Liberty__c
            );

        Test.stopTest();

        Assert.isNotNull(
            results,
            'The result should not be null.'
        );

        Assert.isTrue(
            !results.isEmpty(),
            'Expected at least one INS_Products__mdt record.'
        );

        Boolean foundExpectedRecord = false;

        for (INS_Products__mdt product : results) {
            if (product.Id == expectedProduct.Id) {
                foundExpectedRecord = true;
                break;
            }
        }

        Assert.isTrue(
            foundExpectedRecord,
            'The expected INS_Products__mdt record should be returned.'
        );
    }
    /**
     * @description   method testSelectByCountryWithNoMatchingCountry.
     * @author Mahesh Reddy('Mahesh Reddy')
     * @date 13-08-2026
     */
    @IsTest
    static void testSelectByCountryWithNoMatchingCountry() {
        SEL_INSProductMDT selector = new SEL_INSProductMDT();

        Test.startTest();

        List<INS_Products__mdt> results =
            selector.selectByCountry(
                'TEST_COUNTRY_THAT_DOES_NOT_EXIST',
                false
            );

        Test.stopTest();

        Assert.isNotNull(
            results,
            'The result should not be null.'
        );

        Assert.isTrue(
            results.isEmpty(),
            'Expected no records for a non-existing country.'
        );
    }
    /**
     * @description   method testSelectByCountryForBothLibertyValues.
     * @author Mahesh Reddy('Mahesh Reddy')
     * @date 13-08-2026
     */
    @IsTest
    static void testSelectByCountryForBothLibertyValues() {
        List<INS_Products__mdt> productMetadata = [
            SELECT Id,
                Country__c,
                Is_Liberty__c,
                INS_Customer_Brand__c
            FROM INS_Products__mdt
            LIMIT 1
        ];

        Assert.isTrue(
            !productMetadata.isEmpty(),
            'At least one INS_Products__mdt record is required for this test.'
        );

        INS_Products__mdt expectedProduct = productMetadata[0];

        SEL_INSProductMDT selector = new SEL_INSProductMDT();

        Test.startTest();

        List<INS_Products__mdt> results =
            selector.selectByCountry(
                expectedProduct.Country__c,
                expectedProduct.Is_Liberty__c
            );

        List<INS_Products__mdt> oppositeResults =
            selector.selectByCountry(
                expectedProduct.Country__c,
                !expectedProduct.Is_Liberty__c
            );

        Test.stopTest();

        Assert.isNotNull(
            results,
            'The result should not be null.'
        );

        Assert.isNotNull(
            oppositeResults,
            'The opposite Liberty result should not be null.'
        );

        Assert.isTrue(
            !results.isEmpty(),
            'Expected a record for the matching Country and Liberty flag.'
        );

        for (INS_Products__mdt product : results) {
            Assert.areEqual(
                expectedProduct.Country__c,
                product.Country__c,
                'Returned records should have the requested Country.'
            );

            Assert.areEqual(
                expectedProduct.Is_Liberty__c,
                product.Is_Liberty__c,
                'Returned records should have the requested Liberty value.'
            );
        }

        for (INS_Products__mdt product : oppositeResults) {
            Assert.areEqual(
                expectedProduct.Country__c,
                product.Country__c,
                'Returned records should have the requested Country.'
            );

            Assert.areEqual(
                !expectedProduct.Is_Liberty__c,
                product.Is_Liberty__c,
                'Returned records should have the opposite Liberty value.'
            );
        }
    }
}