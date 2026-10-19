/**
 * @description       : INS_QuickQuoteApplicationController_Test class to test the methods available in INS_QuickQuoteApplicationController
 * @author            : Shamsul Arifeen 
 * @date September 2024
**/
@isTest
public class INS_QuickQuoteApplicationController_Test {

    // @TestSetup method to create common test data
    @TestSetup
    static void setupTestData() {
        // Create the test user with relevant fields
        User testUser = new User(
            Username = 'testuser112xyz@example.com',
            LastName = '112xyz',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = UserInfo.getProfileId(),
            User_Country__c = 'UG', // Set the custom user country field for testing
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Africa/Kampala'
        );
        insert testUser;
    }

    @isTest
    static void testGetPaymentDetails() {
        // Fetch the test user created in the @TestSetup method
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            
            // Act - Get payment details custom metadata
            INS_QuickQuoteApplicationController.getPaymentDetails();
            Payment_Method_config__mdt emptyPaymentDetails = INS_QuickQuoteApplicationController.getRecord('', '');
            Assert.areEqual(null, emptyPaymentDetails, 'Expected null when country and company are empty.');
            
            Test.stopTest();
        }
    }

    @isTest
    static void testGetPaymentMethods() {
        // Fetch the test user created in the @TestSetup method
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            
            // Act - Get payment methods from custom metadata
            List<String> paymentMethods = INS_QuickQuoteApplicationController.getPaymentMethods();
            Assert.areNotEqual(0, paymentMethods.size(), 
                'Expected no payment methods to be returned.');
            
            Test.stopTest();
        }
    }

    @isTest
    static void testGetDebitOrderDate() {
        // Fetch the test user created in the @TestSetup method
        User testUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            
            // Act - Get debit order date from custom metadata
            List<String> debitOrderDates = INS_QuickQuoteApplicationController.getDebitOrderDate();
            Assert.areNotEqual(0, debitOrderDates.size(), 
                'Expected no debit order dates to be returned.');
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetBranches() {
        // Fetch the test user created in the @TestSetup method
        User testUser = [SELECT User_Country__c FROM User WHERE Alias = 'tuser' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            
            // Act - Get branches custom metadata
            List<INS_Branches__mdt> branches = INS_QuickQuoteApplicationController.getBranches(testUser.User_Country__c);
            // Test empty scenario
            List<INS_Branches__mdt> emptyBranches = INS_QuickQuoteApplicationController.getBranches('');
            Assert.areEqual(null, emptyBranches, 'Expected null when user country is empty.');
            
            // Act - Get branch code custom metadata
            String branchCode = INS_QuickQuoteApplicationController.getBrancheCode(testUser.User_Country__c, 'Arua');
            // Test empty scenario
            String emptyBranchCode = INS_QuickQuoteApplicationController.getBrancheCode(testUser.User_Country__c, '');
            Assert.areEqual(null, emptyBranchCode, 'Expected null when branch name is empty.');
            
            Test.stopTest();
        }
    }
}