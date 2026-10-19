/***************************************************************************************
@ Author            :Jagadish
@ Date              :june 2025
@ Name of the Class :UG_PPB_AOB_FetchUgandaProducts_Test
@ Description       : Test class to cover the test scenarios of UG_PPB_AOB_FetchUgandaProducts
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :11th SEP
@ Modification Description : SFP-49192
***************************************************************************************/
@isTest
private class UG_PPB_AOB_FetchUgandaProducts_Test {   
    
    // Test successful retrieval of active Uganda products
    @isTest
    static void testGetActiveUgandaProductAgent_Success() {
        List<Product2> testProducts = AOB_TestDataFactory.createMultipleProducts(5);
        insert testProducts;
        // Run as a standard user to test SECURITY_ENFORCED
        User standardUser = createTestUser('Standard User', 'StandardUser@test.com');
        System.runAs(standardUser) {
            Test.startTest();
            List<ug_ppb_aob_fetchUgandaProducts.ProductRecords> results = ug_ppb_aob_fetchUgandaProducts.getActiveUgandaProductAgent();
            Test.stopTest();
            
            // Verify results
            Assert.areNotEqual(null, results, 'Result list should not be null');
            Assert.areEqual(1, results.size(), 'Expected exactly one ProductRecords instance');
            Assert.areNotEqual(null, results[0].productName, 'Product names list should not be null');
            Assert.areEqual(2, results[0].productName.size(), 'Expected exactly two product names');
        }
    }
    
    
    // Helper method to create a test user
    private static User createTestUser(String profileName, String email, String profileOverride) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileOverride LIMIT 1];
        User user = new User(
            Alias = 'testu',
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = email + System.currentTimeMillis()
        );
        insert user;
        return user;
    }
    @IsTest
    static void testGetActiveUgandaProductAgent_Exception() {
        // Enable exception for this test
        UG_PPB_AOB_FetchUgandaProducts.throwTestException = true;
        
        Test.startTest();
        try {
            UG_PPB_AOB_FetchUgandaProducts.getActiveUgandaProductAgent();
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            // Fix: Check for the correct part of the message
            Assert.areEqual('Script-thrown exception',  e.getMessage());
            
        }
        Test.stopTest();
    }

    // Helper method to create a test user with Standard User profile
    private static User createTestUser(String profileName, String email) {
        return createTestUser(profileName, email, 'Standard User');
    }
}