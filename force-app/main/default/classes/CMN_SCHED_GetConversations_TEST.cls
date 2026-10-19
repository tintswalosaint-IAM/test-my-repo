/**
* @description Test Class that Gets NBA Conversation Records
*
* @author BlueSky
*
* @date October 2021
*/
@isTest
public with sharing class CMN_SCHED_GetConversations_TEST {
    
    private static final Id ACCOUNT_RECORDTYPE_PERSON_ID =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static final String CRON_EXPRESSION = '0 0 0 3 9 ? 2030';

    @TestSetup
    static void setup() {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LastName = 'TestLastName',
            FirstName = 'TestFirstName',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            RM_AE_Code__c = '0054321',
            Alias = 'test',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            isActive = true
        );
        insert user;

        Account testAccount = new Account();
        testAccount.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON_ID;
        testAccount.FirstName = 'Tester';
        testAccount.LastName = 'Tests';
        testAccount.RelationshipMgrCode__c = '0054321';
        testAccount.ExternalCIFId__c = '000100001';
        insert testAccount;
        testAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccount.Id];
        Contact testContact = [SELECT Id, CMN_CustomerBPID__c FROM Contact WHERE Id = :testAccount.PersonContactId];
        testContact.CMN_CustomerBPID__c = '000100001';
        update testContact;

        Account testAccount2 = new Account();
        testAccount2.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON_ID;
        testAccount2.FirstName = 'Test Name';
        testAccount2.LastName = 'Test Surname';
        testAccount2.RelationshipMgrCode__c = '0054321';
        testAccount2.ExternalCIFId__c = '100002';
        insert testAccount2;
        testAccount2 = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccount2.Id];
        Contact testContact2 = [SELECT Id, CMN_CustomerBPID__c FROM Contact WHERE Id = :testAccount2.PersonContactId];
        testContact2.CMN_CustomerBPID__c = '100002';
        update testContact2;

        CMN_Conversation__c testConversation = new CMN_Conversation__c();
        testConversation.Category__c = 'test_id';
        testConversation.Lead_Key__c = '000000123456789012';
        testConversation.Status__c = 'In Progress';
        testConversation.Account__c = testAccount.Id;
        insert testConversation;
    }

    @isTest
    static void testScheduler() {
        Test.startTest();
        String jobId = System.schedule('testScheduledApex', CRON_EXPRESSION, new CMN_SCHED_GetConversations());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(CRON_EXPRESSION, ct.CronExpression);
        System.assertEquals('2030-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    }

    @isTest
    static void testConversationBatch() {
        Test.startTest();
        CMN_BATCH_GetConversations batch = new CMN_BATCH_GetConversations();
        Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        System.assertEquals(4, [SELECT COUNT() FROM CMN_Conversation__c]);
        CMN_Conversation__c testConversation = [SELECT Id, Status__c FROM CMN_Conversation__c WHERE Category__c = 'test_id'];
        System.assertEquals('In Progress', testConversation.Status__c);
    }

    @isTest
    static void testConversationSendUpdate() {
        CMN_Conversation__c testConversation = [SELECT Id,Account__c, Status__c FROM CMN_Conversation__c WHERE Category__c = 'test_id'];
        testConversation.Reason__c = 'Accept Review';
        testConversation.Response__c = 'Accepted Review';
        testConversation.Details__c = 'Accept Review actioned';
        update testConversation;
        Test.startTest();
        List<String> conversationIds = new List<String>();
        conversationIds.add(testConversation.Id);
        CMN_FLOW_SendConversation.sendConversations(conversationIds);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM CMN_Conversation__c]);
    }
}