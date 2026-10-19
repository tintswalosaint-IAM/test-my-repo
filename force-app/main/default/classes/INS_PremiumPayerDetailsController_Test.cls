/**
 * @description : SFP-50219- test class INS_PremiumPayerDetailsController_Test for payment method INS_PremiumPayerDetailsController.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @date August 28th 2024
 */
@isTest
public class INS_PremiumPayerDetailsController_Test {

    // Static variable to hold the user instance
    static User testUser;

    // Method to create the test user once and reuse it
    public static void createTestUser() {
        if (testUser == null) {
            // Create the test user with relevant fields
            testUser = new User(
                Username = 'testuser112xyz@example.com',
                LastName = '112xyz',
                Email = 'testuser@example.com',
                Alias = 'tuser',
                ProfileId = UserInfo.getProfileId(),
                User_Country__c = 'UG', // Set the custom user country field for testing
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/New_York'
            );
            insert testUser;
        }
    }

    /**
     * @description  test class testgetPaymentMethod for getPaymentMethod.
     */
    @isTest
    static void testgetPaymentMethod() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            // Test the getPaymentMethod method
            INS_Country_and_Payment_Method_Configs__mdt mdtRecord = INS_PremiumPayerDetailsController.getPaymentMethod('4d4ad02e-3a29-4bcf-a0a9-13b38d2121f2', 'Product A','Liberty','UG');
            // Add assertions
            Assert.areNotEqual(null, mdtRecord, 'MDT Record should not be null');
        }
    }

    /**
     * @description  test class testgetDebitOrderDate for getDebitOrderDate.
     */
    @isTest
    static void testgetDebitOrderDate() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest();
            List<String> recordList = INS_PremiumPayerDetailsController.getDebitOrderDate();
            Assert.areNotEqual(0, recordList.size(), 'Debit order date list should not be empty');
            Test.stopTest();
        }
    }

    /**
     * @description  test class testgetBranches for getBranches.
     */
    @isTest
    static void testgetBranches() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest();
            List<INS_Branches__mdt> mdtRecords = INS_PremiumPayerDetailsController.getBranches('UG');
            Assert.areNotEqual(null, mdtRecords, 'MDT Records should not be null');
            Test.stopTest();
        }
    }

    /**
     * @description  test class testgetBranches_BlankRecords for getBranches with no records.
     */
    @isTest
    static void testgetBranches_BlankRecords() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest();
            List<INS_Branches__mdt> mdtRecords = INS_PremiumPayerDetailsController.getBranches('SA');
            
            Assert.isNull( mdtRecords, 'MDT Records should be empty for non-existing country');
            Test.stopTest();
        }
    }

    /**
     * @description  test class testgetPaymentMethodDetails for getPaymentMethodDetails.
     */
    @isTest
    static void testgetPaymentMethodDetails() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest();
            INS_PremiumPayerPaymentMehodConfig__mdt mdtRecord = INS_PremiumPayerDetailsController.getPaymentMethodDetails('Card Payment');
            Assert.areNotEqual(null, mdtRecord, 'MDT Record should not be null for existing payment method');
            Test.stopTest();
        }
    }

    /**
     * @description  test class testgetPaymentMethodDetails_Null for getPaymentMethodDetails with null input.
     */
    @isTest
    static void testgetPaymentMethodDetails_Null() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest();
            try {
                INS_PremiumPayerDetailsController.getPaymentMethodDetails(null);
            } catch (Exception ex) {
                Assert.areEqual('Script-thrown exception', ex.getMessage(), 'exception was caught');
            }
            Test.stopTest();
        }
    }

    /**
     * @description  test class testgetBranches_NoRecords for getBranches with no records.
     */
    @isTest
    static void testgetBranches_NoRecords() {
        // Ensure the test user is created
        createTestUser();
        
        // Run as the test user
        System.runAs(testUser) {
            Test.startTest();
            List<INS_Branches__mdt> mdtRecords = INS_PremiumPayerDetailsController.getBranches('ZZ');
            Assert.isNull(mdtRecords, 'MDT Records should be empty for non-existing country');
            Test.stopTest();
        }
    }
}