/**
* @Name of the Class : ICS_CTRL_GBG_Test
* @description class used as test Class for ICS_CTRL_GBG controller for SBO-UK - Story:SFP-37310 
* @Author Ikyatha Naidu 
* @Date 01/03/2024
* @Last Modified On  : 01/07/2024
* @Last Modified By  : Ikyatha Naidu
* @Modification Description : SFP-37310 class used for adding test methods for ICS_CTRL_GBG_Test for SBO-UK
* 
* @last modified on: 10-06-2025
 * @last modified by: Ridhima Saxena
 * Story: SFP-50149 
*/
@isTest
public class ICS_CTRL_GBG_Test {
    
    @TestSetup
    static void setupTestData() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
        
        // Create custom metadata for ics_gbg
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = 'ics_customlabel__mdt.ics_gbg';
        customMetadata.label = 'ICS GBG';
        
        Metadata.CustomMetadataValue descField = new Metadata.CustomMetadataValue();
        descField.field = 'Description__c';
        descField.value = '{"ics_serverSentUrl": "https://example.com"}';
        customMetadata.values.add(descField);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
   }
    
    @isTest
    static void testCallGBGToken() {
        user commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
       
            String response = ICS_CTRL_GBG.callGBGToken(commUser.Contact.AccountId);
            Assert.isNotNull(response, 'Expected a response from callGBGToken');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetLandingPageJSON() {
        Test.startTest();
        ics_customlabel__mdt labelData = ICS_CTRL_GBG.getLandingPageJSON('ics_gbg');
        Test.stopTest();
        
        Assert.isNotNull(labelData, 'Expected a non-null labelData');
        Assert.areEqual('ics_gbg', labelData.DeveloperName, 'Expected DeveloperName to be ics_gbg');
    }
    
    @isTest
    static void testGetAccountId() {
        user commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            String accountId = ICS_CTRL_GBG.getAccountId();
            Assert.isNotNull(accountId, 'Expected a non-null accountId');
            Assert.areEqual(commUser.Contact.AccountId, accountId, 'AccountId should match the user\'s account');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testReturnGBGToken() {
        user commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            String response = ICS_CTRL_GBG.returnGBGToken();
            Assert.isNotNull(response, 'Expected a response from returnGBGToken');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCallPOAVerification() {
        user commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            String response = ICS_CTRL_GBG.callPOAVerification(commUser.Contact.AccountId);
            Assert.isNotNull(response, 'Expected a response from callPOAVerification');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testExceptionHandling() {
        user commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            try {
                // Attempt to call a method with invalid data to trigger an exception
                ICS_CTRL_GBG.callGBGToken(null);
                Assert.fail('Expected an AuraHandledException to be thrown');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().length() > 0, 'Exception message should not be empty');
            }
        }
        Test.stopTest();
    }
 	 @isTest
    static void testCallGBGTokenCatch() {
        Test.startTest();
        try {
            ICS_CTRL_GBG.callGBGToken('invalid_id_123');
            Assert.fail('Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
            Assert.isTrue(e.getMessage().length() > 0, 'Exception message should not be empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetLandingPageJSONCatch() {
        Test.startTest();
        try {
           
            ICS_CTRL_GBG.getLandingPageJSON('NON_EXISTENT_LABEL');
            Assert.fail('Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
            Assert.isTrue(e.getMessage().length() > 0, 'Exception message should not be empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testReturnGBGTokenCatch() {
        User userNoContact = new User(
            Username = 'testnocontact@example.com',
            Email = 'testnocontact@example.com',
            LastName = 'Test',
            Alias = 'tnocon',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert userNoContact;
        
        Test.startTest();
        System.runAs(userNoContact) {
            try {
                ICS_CTRL_GBG.returnGBGToken();
                Assert.fail('Expected an AuraHandledException to be thrown');
            } catch (AuraHandledException e) {
                Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
                Assert.isTrue(e.getMessage().length() > 0, 'Exception message should not be empty');
            }
        }
        Test.stopTest();
    }
        

}