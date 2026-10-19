/**
 * @description  test class for SEL_INSCountryandPaymentMethodConfigs
 * @author Khaliq Abdul (khaliq.abdul@standardbank.co.za)
 * @date August 27th 2024
 */
@isTest
public class SEL_INSCountryandPaymentMethod_Test {

    /**
     * @description  Tests if the correct SObjectType is returned from the metadata selector.
     * @author Khaliq Abdul
     */
    @isTest
    static void validateCorrectSObjectTypeReturned() {
        Test.startTest();
        
        SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        Schema.SObjectType sObjectType = metadataSelector.getSObjectType();
        
        // Assertion with expected and actual values
        Assert.areEqual(
            INS_Country_and_Payment_Method_Configs__mdt.SObjectType, 
            sObjectType, 
            'Expected SObjectType to be INS_Country_and_Payment_Method_Configs__mdt, but got ' + sObjectType
        );
        
        Test.stopTest();
    }
    
    /**
     * @description  Tests if the field list returned by the metadata selector contains the expected fields.
     * @author Khaliq Abdul
     */
    @IsTest
    static void ensureFieldListContainsExpectedFields() {
        Test.startTest();
        
        SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        List<Schema.SObjectField> sObjectFieldList = metadataSelector.getSObjectFieldList();
        
        Map<String, Schema.SObjectField> fieldMap = INS_Country_and_Payment_Method_Configs__mdt.SObjectType.getDescribe().fields.getMap();
        
        // Assertion for size check
        Assert.isTrue(
            sObjectFieldList.size() > 0, 
            'Expected field list size to be greater than 0, but got ' + sObjectFieldList.size()
        );
        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(
                fieldMap.containsKey(field.getDescribe().getName()), 
                'Field ' + field.getDescribe().getName() + ' not found in expected field map'
            );
        }
        
        Test.stopTest();
    }
    
    /**
     * @description  Tests if the metadata selector can query the records for a given country and payment method.
     * @author Khaliq Abdul
     */
    @isTest
    static void verifyQueryRecordsReturnsExpectedResults() {
        Test.startTest();
        
        SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        List<INS_Country_and_Payment_Method_Configs__mdt> mdtRecords = metadataSelector.selectByCountryAndProductId('UG', '7e919532-3c62-4013-aada-c5931c495de3');
        
        // Assert that the correct number of records is returned
        Assert.areEqual(
            1, 
            mdtRecords.size(), 
            'Expected exactly 1 record, but found ' + mdtRecords.size()
        );
        
        Test.stopTest();
    }

    /**
     * @description  Tests for invalid country or payment method inputs to ensure proper exception handling.
     * @author Khaliq Abdul
     */
    @isTest
    static void testInvalidInputHandling() {
        Test.startTest();
        
        SEL_INSCountryandPaymentMethodConfigs metadataSelector = new SEL_INSCountryandPaymentMethodConfigs();
        
        // Negative test for invalid country code
        try {
            metadataSelector.selectByCountryAndProductId('INVALID_COUNTRY', '7e919532-3c62-4013-aada-c5931c495de3');
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().contains('No records found'), 
                'Unexpected exception message: ' + e.getMessage()
            );
        }
        
        // Negative test for invalid payment method
        try {
            metadataSelector.selectByCountryAndProductId('UG', 'INVALID_PAYMENT_METHOD');
        } catch (Exception e) {
            Assert.isTrue(
                e.getMessage().contains('No records found'), 
                'Unexpected exception message: ' + e.getMessage()
            );
        }
        
        Test.stopTest();
    }
}