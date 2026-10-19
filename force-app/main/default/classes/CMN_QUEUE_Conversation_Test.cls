@IsTest
private class CMN_QUEUE_Conversation_Test {

    @IsTest
    private static void testAENumberConversations() {
        SetupDataClass setup_data = new SetupDataClass();
        setup_data.createTestData(3);
        Test.startTest();
            CMN_QUEUE_Conversation queueableConversation = new CMN_QUEUE_Conversation(new Map<String, Date> {'123456' => System.today() + 1});
            System.enqueueJob(queueableConversation);
        Test.stopTest();

        List<CMN_Conversation__c> conversations = [SELECT Id, IsActive__c, AE_Number__c, CreatedDate FROM CMN_Conversation__c WHERE Id IN :setup_data.TestConversations];
        for (CMN_Conversation__c conversation : conversations) {
            System.assertEquals(false, conversation.IsActive__c, 'Conversation should not be active');
        }
    }

    @IsTest
    private static void testAccountConversations() {
        SetupDataClass setup_data = new SetupDataClass();
        setup_data.createTestData(3);
        Id testAccountId = setup_data.TestAccounts.get(0).Id;
        Test.startTest();
            CMN_QUEUE_Conversation queueableConversation = new CMN_QUEUE_Conversation(testAccountId, System.today() + 1);
            System.enqueueJob(queueableConversation);
        Test.stopTest();

        List<CMN_Conversation__c> conversations = [SELECT Id, IsActive__c, AE_Number__c, CreatedDate FROM CMN_Conversation__c WHERE Account__c = :testAccountId];
        for (CMN_Conversation__c conversation : conversations) {
            System.assertEquals(false, conversation.IsActive__c, 'Conversation should not be active');
        }
    }

    private class SetupDataClass {
        List<Account> TestAccounts;
        List<CMN_Conversation__c> TestConversations;

        public SetupDataClass() {}

        public void createTestData(Integer number_of_records) {
            createTestAccounts(number_of_records);
            createTestConversations(number_of_records);
        }

        private void createTestAccounts(Integer number_of_accounts) {
            TestAccounts = new List<Account>();
            for(Integer i = 0; i < number_of_accounts; i++) {
                Account acc = new Account();
                acc.Name = 'Test Account ' + i;
                TestAccounts.add(acc);
            }

            insert TestAccounts;
        }

        private void createTestConversations(Integer number_of_conversations) {
            TestConversations = new List<CMN_Conversation__c>();
            for(Account acc : TestAccounts) {
                for (Integer i = 0; i < number_of_conversations; i ++) {
                    CMN_Conversation__c conversation =  new CMN_Conversation__c();
                    conversation.Account__c = acc.Id;
                    conversation.AE_Number__c = '123456';
                    conversation.Status__c = 'In Progress';
                    conversation.IsActive__c = true;
                    TestConversations.add(conversation);
                }
            }

            insert TestConversations;
        }
    }

}