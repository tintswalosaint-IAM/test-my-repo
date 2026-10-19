/**
 * @description Test Class for CMN_CTRL_Conversation
 * @author Joan MacDonald
 * @date October 2021
 * 
 * 2024-02-27   Derek Hughes    Added method to cover code in CMN_DTO_ConversationsResponse
 */
@IsTest
public class CMN_CTRL_Conversation_Test {

    @IsTest
    private static void shouldGetBankerConversationsWithRecordId() {
        List<CMN_Conversation__c> expectedConversations = new List<CMN_Conversation__c>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
                expectedConversations = CMN_CTRL_Conversation.getBankerConversations(setupData.testAccount.Id, null);
            Test.stopTest();
        }

        List<CMN_Conversation__c> actionedConversations = [SELECT Id, Name, IsActive__c, CMN_ConversationId__c, AE_Number__c, Status__c, Reason__c, Response__c, Details__c FROM CMN_Conversation__c WHERE AE_Number__c = :setupData.testUser.RM_AE_Code__c AND Status__c = 'Actioned'];
        System.assertEquals(2, expectedConversations.size(), 'Two conversation should be expected on account');
        System.assertEquals(1, actionedConversations.size(), 'One conversation should be actioned');
    }

    @IsTest
    private static void shouldGetBankerConversationsWithoutRecordId() {
        List<CMN_Conversation__c> expectedConversations = new List<CMN_Conversation__c>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
                expectedConversations = CMN_CTRL_Conversation.getBankerConversations(null, setupData.testUser.RM_AE_Code__c);
            Test.stopTest();
        }

        List<CMN_Conversation__c> actionedConversations = [SELECT Id, Name, IsActive__c, CMN_ConversationId__c, AE_Number__c, Status__c, Reason__c, Response__c, Details__c FROM CMN_Conversation__c WHERE AE_Number__c = :setupData.testUser.RM_AE_Code__c AND Status__c = 'Actioned'];
        System.assertEquals(2, expectedConversations.size(), 'Two conversation should be expected');
        System.assertEquals(2, actionedConversations.size(), 'Two conversation should be actioned');
    }

    @IsTest
    private static void shouldGetBankerConversationsWithoutRecordIdAndAENumber() {
        List<CMN_Conversation__c> expectedConversations = new List<CMN_Conversation__c>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
                expectedConversations = CMN_CTRL_Conversation.getBankerConversations(null, null);
            Test.stopTest();
        }

        List<CMN_Conversation__c> actionedConversations = [SELECT Id, Name, IsActive__c, CMN_ConversationId__c, AE_Number__c, Status__c, Reason__c, Response__c, Details__c FROM CMN_Conversation__c WHERE AE_Number__c = :setupData.testUser.RM_AE_Code__c AND Status__c = 'Actioned'];
        System.assertEquals(2, expectedConversations.size(), 'Two conversation should be expected');
        System.assertEquals(2, actionedConversations.size(), 'Two conversation should be actioned');
    }

    @IsTest
    private static void shouldGetGroupedBankerConversationsWithRecordId() {
        List<CMN_CTRL_Conversation.GroupedConversationWrapper> expectedConversations = new List<CMN_CTRL_Conversation.GroupedConversationWrapper>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
            expectedConversations = CMN_CTRL_Conversation.getGroupedBankerConversations(setupData.testAccount.Id, null);
            Test.stopTest();
        }

        List<CMN_Conversation__c> actionedConversations = [SELECT Id, Name, IsActive__c, CMN_ConversationId__c, AE_Number__c, Status__c, Reason__c, Response__c, Details__c FROM CMN_Conversation__c WHERE AE_Number__c = :setupData.testUser.RM_AE_Code__c AND Status__c = 'Actioned'];
        System.assertEquals(1, expectedConversations.size(), 'One grouping should be expected');
        System.assertEquals(1, actionedConversations.size(), 'Two conversation should be actioned');
    }

    @IsTest
    private static void shouldGetGroupedBankerConversationsWithoutRecordId() {
        List<CMN_CTRL_Conversation.GroupedConversationWrapper> expectedConversations = new List<CMN_CTRL_Conversation.GroupedConversationWrapper>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
            expectedConversations = CMN_CTRL_Conversation.getGroupedBankerConversations(null, setupData.testUser.RM_AE_Code__c);
            Test.stopTest();
        }

        List<CMN_Conversation__c> actionedConversations = [SELECT Id, Name, IsActive__c, CMN_ConversationId__c, AE_Number__c, Status__c, Reason__c, Response__c, Details__c FROM CMN_Conversation__c WHERE AE_Number__c = :setupData.testUser.RM_AE_Code__c AND Status__c = 'Actioned'];
        System.assertEquals(2, expectedConversations.size(), 'One grouping should be expected');
        System.assertEquals(2, actionedConversations.size(), 'Two conversation should be actioned');
    }

    @IsTest
    private static void shouldGetGroupedBankerConversationsWithoutRecordIdAndAENumber() {
        List<CMN_CTRL_Conversation.GroupedConversationWrapper> expectedConversations = new List<CMN_CTRL_Conversation.GroupedConversationWrapper>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
            expectedConversations = CMN_CTRL_Conversation.getGroupedBankerConversations(null, null);
            Test.stopTest();
        }

        List<CMN_Conversation__c> actionedConversations = [SELECT Id, Name, IsActive__c, CMN_ConversationId__c, AE_Number__c, Status__c, Reason__c, Response__c, Details__c FROM CMN_Conversation__c WHERE AE_Number__c = :setupData.testUser.RM_AE_Code__c AND Status__c = 'Actioned'];
        System.assertEquals(2, expectedConversations.size(), 'One grouping should be expected');
        System.assertEquals(2, actionedConversations.size(), 'Two conversation should be actioned');
    }

    @IsTest
    private static void shouldGetCustomerOnAPage() {
        List<COAP_DTO_CoapPoapComponent> expectedWrappers = new List<COAP_DTO_CoapPoapComponent>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
               expectedWrappers = CMN_CTRL_Conversation.getCustomerOnAPage(setupData.testAccountWithoutConversations.Id, 'coap');
            Test.stopTest();
        }

        Assert.areEqual(2, expectedWrappers.size(),'two components wrappers should be created');
        for (COAP_DTO_CoapPoapComponent item : expectedWrappers) {
            if (item.message == 'profile') {
                Assert.areEqual('coap_comp_profile', item.componentName, 'correct Profile component should be assigned');
            }
            if (item.message == 'valueAdded') {
                Assert.areEqual('coap_comp_value_added', item.componentName, 'correct Value Added component should be assigned');
            }
        }
    }

    @IsTest
    private static void shouldGetPortfolioOnAPage() {
        List<COAP_DTO_CoapPoapComponent> expectedWrappers = new List<COAP_DTO_CoapPoapComponent>();
        SetupDataClass setupData = new SetupDataClass();
        setupData.createTestData(false);
        System.runAs(setupData.testUser) {
            Test.startTest();
                expectedWrappers = CMN_CTRL_Conversation.getPortfolioOnAPage('poap');
            Test.stopTest();
        }

        Assert.areEqual(2, expectedWrappers.size(),'two components wrappers should be created');
        for (COAP_DTO_CoapPoapComponent item : expectedWrappers) {
            if (item.message == 'profile') {
                Assert.areEqual('poap_comp_profile', item.componentName, 'correct Profile component should be assigned');
            }
            if (item.message == 'valueAdded') {
                Assert.areEqual('poap_comp_value_added', item.componentName, 'correct Value Added component should be assigned');
            }
        }
    }

    /**
    * @description Additional test to ensure code coverage of all lines in the  CMN_DTO_ConversationsResponse
    * @author Derek Hughes | 27-02-2024 
    **/
    @IsTest
    private static void testDTO () {

        Test.startTest();

            CMN_DTO_ConversationsResponse dto = new CMN_DTO_ConversationsResponse();

            List<CMN_DTO_ConversationsResponse.Conversation> conversations = new List<CMN_DTO_ConversationsResponse.Conversation>();

            CMN_DTO_ConversationsResponse.Conversation conversation = new CMN_DTO_ConversationsResponse.Conversation();

            conversation.newCustN = 123456789;
            conversation.customerNumber = 123456789;
            conversation.clientType = 'Test Value';
            conversation.clientName = 'Test Value';
            conversation.identification = 'Test Value';
            conversation.identifier = 'Test Value';
            conversation.tier = 'Test Value';
            conversation.aeNumber = 'Test Value';
            conversation.conversationId = 'Test Value';
            conversation.category = 'Test Value';
            conversation.catPosition = 1;
            conversation.subCategory = 'Test Value';
            conversation.subCatPosition = 1;
            conversation.detail = 'Test Value';
            conversation.actionScript = 'Test Value';
            conversation.contactType = 'Test Value';
            conversation.response = 'Test Value';
            conversation.reason = 'Test Value';
            conversation.additionalInformation = 'Test Value';
            conversation.expectedRevenue = 12345.00;
            conversation.futureContactDate = 'Test Value';
            conversation.leadKey = 'Test Value';

            conversations.add(conversation);

            dto.totalSize = 100;
            dto.clientPortfolioConversationList = conversations;
            
        Test.stopTest();

        Assert.areEqual(100, dto.totalSize, 'Incorrect DTO size');
        Assert.areEqual(1, dto.clientPortfolioConversationList.size(), 'Incorrect list size');

    }

    private class SetupDataClass {
        User testUser;
        Account testAccount;
        Account testAccountWithoutConversations;
        List<CMN_Conversation__c> testConversations;

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
            testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.ExternalCIFId__c = '100001';
            testAccount.RelationshipMgrCode__c = '0054321';
            insert testAccount;
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