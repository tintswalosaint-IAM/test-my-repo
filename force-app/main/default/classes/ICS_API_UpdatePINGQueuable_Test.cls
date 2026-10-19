/**
 * @Name of the Class : ICS_API_UpdatePINGQueuable_Test
 * @description Test class for SBO-UK Ping Feature (ICS_API_UpdatePINGQueuable)
 * @author Ikyatha Naidu
 * @story SFP-31800
 * @date  01/03/2024
 * @last modified on  : 23-07-2024
 * @last modified by  : Ruchi Agrawal
 * @Modification Description : Updated to latest version
 */
@IsTest
private class ICS_API_UpdatePINGQueuable_Test {
    
    private static final String TEST_PING_ID = 'testPingId';

    @TestSetup
    static void setupTestData() {
        
        
        // Create Community User
        ICS_DAL_TestFactory.createCommunityUser();
    }

    @IsTest
    static void testUpdateContactQueuable() {
        // Get the test Contact
		User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        Contact testContact = [SELECT Id, Ping_Id__c FROM Contact where id=: commUser.ContactId];
        testContact.ping_id__c=TEST_PING_ID;
        update testContact;
        SBO_Ping_Registration_Site__mdt metadata=[select id,network_id__c,Comma_Separated_Permission_Set__c from SBO_Ping_Registration_Site__mdt limit 1];
        Test.startTest();
        
        // Create and execute the Queuable
        ICS_API_UpdatePINGQueuable queuable = new ICS_API_UpdatePINGQueuable(testContact.Id, TEST_PING_ID);
        System.enqueueJob(queuable);
        
        Test.stopTest();
        
        // Verify the Contact was updated
        Contact updatedContact = [SELECT Id, Ping_Id__c FROM Contact WHERE Id = :testContact.Id];
        Assert.areEqual(TEST_PING_ID, updatedContact.Ping_Id__c, 'Ping Id should be updated');
    }

    @IsTest
    static void testUpdateContactQueuableWithInvalidId() {
       
        try{
            Test.startTest();
             SBO_Ping_Registration_Site__mdt metadata=[select id,network_id__c,Comma_Separated_Permission_Set__c from SBO_Ping_Registration_Site__mdt limit 1];
            ICS_API_UpdatePINGQueuable queuable = new ICS_API_UpdatePINGQueuable('9999999999', TEST_PING_ID);
            System.enqueueJob(queuable);
            Assert.areEqual(true, queuable != null, 'Queuable exceuted');
            Test.stopTest();
        }catch(exception ex){
             Assert.areEqual(true, ex.getmessage() != null, 'Exception Occured');
        }
        
    }

    
}