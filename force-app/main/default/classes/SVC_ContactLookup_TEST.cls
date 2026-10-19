/**
 * @description SFP-5420 - Test class for controller methods for the LWC svcContactLookup component
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 *
 * @date Sep 7th 2021
 */
@isTest
private class SVC_ContactLookup_TEST {

    /**
     * @description Generates test data
     */
    @TestSetup
    private static void generateData() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        newContact.FirstName = 'Jo';
        newContact.LastName = 'Smith';
        insert newContact;

        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;

        LiveChatTranscript newTranscript = new LiveChatTranscript(
            SVC_FirstName__c = 'John',
            SVC_LastName__c = 'Smith',
            SVC_Phone__c = '+375298032245',
            SVC_Email__c = 'johnsmith@gmail.com',
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = '0000-0000-000x-000x-000x'
        );
        insert newTranscript;

        SVC_ChatBotHandler.ChatBotTempInput input = new SVC_ChatBotHandler.ChatBotTempInput();
        input.caseSubject = 'Login issue';
        input.caseDescription = 'I have issue with access to the site';
        input.queueApiName = 'UG_CCC_live_chat_cases';
        input.routableId = newTranscript.Id;

        List<SVC_ChatBotHandler.ChatBotTempOutput> result = SVC_ChatBotHandler.createCase(
            new List<SVC_ChatBotHandler.ChatBotTempInput>{input}
        );
    }

    /**
     * @description Checks getting matching contacts on init LWC components
     */
    @isTest
    private static void getContactsTest() {
        LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.setFixedSearchResults(new List<Id>{contact.Id});
        SVC_ContactLookup.DataResponse response = SVC_ContactLookup.getContacts(transcript.Id);
        System.assert(response.isSuccess);
        List<SVC_ContactLookup.DataContact> contacts = (List<SVC_ContactLookup.DataContact>) JSON.deserialize(
            response.result, List<SVC_ContactLookup.DataContact>.class
        );
        System.assert(contacts.size() > 1);

        Case chatCase = [SELECT Id FROM Case LIMIT 1];
        response = SVC_ContactLookup.getContacts(chatCase.Id);
        System.assert(response.isSuccess);
        contacts = (List<SVC_ContactLookup.DataContact>) JSON.deserialize(
            response.result, List<SVC_ContactLookup.DataContact>.class
        );
        System.assert(contacts.size() > 1);
    }

    /**
     * @description Checks searching contacts by substring
     */
    @isTest
    private static void findContactsTest() {
        LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Test.setFixedSearchResults(new List<Id>{contact.Id});
        SVC_ContactLookup.DataResponse response = SVC_ContactLookup.findContacts('Smith');
        System.assert(response.isSuccess);
        List<SVC_ContactLookup.DataContact> contacts = (List<SVC_ContactLookup.DataContact>) JSON.deserialize(
            response.result, List<SVC_ContactLookup.DataContact>.class
        );
        System.assert(contacts.size() == 1);
        System.assert(contacts[0].Name.containsIgnoreCase('Smith'));
    }

    /**
     * @description Checks populating contactId field
     */
    @isTest
    private static void updateContactTest() {
        LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        SVC_ContactLookup.DataResponse response = SVC_ContactLookup.updateContact(transcript.Id, contact.Id);
        System.assert(response.isSuccess);
        transcript = [SELECT Id, ContactId FROM LiveChatTranscript WHERE Id = :transcript.Id];
        System.assertEquals(contact.Id, transcript.ContactId);

        Case chatCase = [SELECT Id FROM Case LIMIT 1];
        response = SVC_ContactLookup.updateContact(chatCase.Id, contact.Id);
        System.assert(response.isSuccess);
        chatCase = [SELECT Id, ContactId FROM Case WHERE Id = :chatCase.Id];
        System.assertEquals(contact.Id, chatCase.ContactId);
    }
    
}