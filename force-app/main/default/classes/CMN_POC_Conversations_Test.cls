@IsTest
public with sharing class CMN_POC_Conversations_Test {
    @IsTest
    private static void shouldGetAccountConversations() {
        List<List<CMN_Conversation__c>> expectedConversations = new List<List<CMN_Conversation__c>>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
            expectedConversations = CMN_POC_Conversations.getAccountConversations(setupData.accountIds);
            Test.stopTest();
        }

        System.assertEquals(1, expectedConversations.size(), 'There should be one list of conversations');
    }

    private class SetupDataClass {
        User testUser;
        Account testAccount;
        Account testAccountWithoutConversations;
        List<CMN_Conversation__c> testConversations;
        List<Id> accountIds;

        /**
        * @description Class to create setup data
        */
        public SetupDataClass() {
            createTestUser();
            createTestAccountForConversationInsert();
        }

        private void createTestUser() {
            Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            testUser = new User(
                    Alias = 'testuser',
                    Email='testuser@test.test',
                    EmailEncodingKey='UTF-8',
                    LastName='Test User',
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = profile.Id,
                    TimeZoneSidKey='Europe/Berlin',
                    Username='test.user.dev@stdb.chnwrmdev',
                    RM_AE_Code__c = '0054321');

            insert testUser;
        }

        /**
        * @description Method to create test data
        * @param actionedConversations boolean value if conversations need to be actioned or not
        */
        public void createTestData(Boolean actionedConversations) {
            createTestAccount();
            createTestAccountForConversationInsert();
            if (actionedConversations) {
                createActionedTestConversations();
            } else {
                createTestConversations();
            }
        }

        private void createTestAccount() {
            accountIds = new List<Id>();
            testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.ExternalCIFId__c = '100001';
            testAccount.RelationshipMgrCode__c = '0054321';
            insert testAccount;
            accountIds.add(testAccount.Id);
        }

        private void createTestAccountForConversationInsert() {
            testAccountWithoutConversations = new Account();
            testAccountWithoutConversations.Name = 'Test Account Without Conversations';
            testAccountWithoutConversations.ExternalCIFId__c = '909090909';
            testAccountWithoutConversations.RelationshipMgrCode__c = '0054321';
            insert testAccountWithoutConversations;
        }

        private void createTestConversations() {
            testConversations = new List<CMN_Conversation__c>();
            List<String> conversationIds = prepareConversationIds();
            for (Integer i = 0; i < 3; i ++) {
                CMN_Conversation__c conversation =  new CMN_Conversation__c();
                conversation.Account__c = testAccount.Id;
                conversation.AE_Number__c = '0054321';
                conversation.Status__c = 'In Progress';
                conversation.IsActive__c = true;
                conversation.CMN_ConversationId__c = conversationIds.get(i);
                testConversations.add(conversation);
            }

            insert testConversations;
        }

        private void createActionedTestConversations() {
            testConversations = new List<CMN_Conversation__c>();
            List<String> conversationIds = prepareConversationIds();
            for (Integer i = 0; i < 3; i ++) {
                CMN_Conversation__c conversation =  new CMN_Conversation__c();
                conversation.Account__c = testAccount.Id;
                conversation.AE_Number__c = '0054321';
                conversation.Status__c = 'Actioned';
                conversation.Details__c = 'testdetails';
                conversation.Response__c = 'testresponse';
                conversation.Reason__c = 'testreason';
                conversation.IsActive__c = true;
                conversation.CMN_ConversationId__c = conversationIds.get(i);
                testConversations.add(conversation);
            }

            insert testConversations;
        }

        private List<String> prepareConversationIds() {
            List<String> convIds = new List<String>();
            Date today = System.today();
            String year = String.valueOf(today.year()).substring(2,4);
            String month = String.valueOf(today.month());
            if (month.length() == 1) {
                month=0+month;
            }
            String day = String.valueOf(today.day());
            if (day.length() == 1) {
                day=0+day;
            }

            convIds.add(year+month+day+1111);
            convIds.add(year+month+day+2222);
            convIds.add(year+month+day+3333);

            return convIds;
        }
    }

}