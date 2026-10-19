/**
 * @description SFP-5420 - Test class for the controller with Chatbot requests
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 * 
 * @lastModifiedBy Raymond Magezi (magezir2@stanbic.com)
 *
 * @date Sep 24th 2021
 * 
 * @lastModifiedDate July 07th 2025
 */
@isTest
private class SVC_ChatBotHandler_TEST {
    private static final String QUEUE_API_NAME = 'UG_CCC_live_chat_cases';
	private static final String QUEUE_API_NAME_LS = 'LS_CCC_Chat';
    private static final String WHATSAPP_TYPE = 'WhatsApp';
    private static final String LOGIN_ISSUE = 'Login issue';
    private static final String SITE_ACCESS_ISSUE = 'I have issue with access to the site';
    private static final String UGANDA_PHONE = '+256700550550';
    private static final String RESULT_NOT_NULL_MSG = 'Result should not be null';
    private static final String ONE_RESULT_MSG = 'Should return one result';
    private static final String UTF8 = 'UTF-8';
    private static final String EN_US = 'en_US';
    private static final String AFRICA_JHB = 'Africa/Johannesburg';
    private static final String ACTIVE = 'Active';
    
    private static String uniqueUsername(String base) {
        return base + '.' + System.currentTimeMillis() + '@example.com.test';
    }
    
    @testSetup
    static void setupTestData() {
        List<MessagingChannel> channels = new List<MessagingChannel>();
        channels.add(new MessagingChannel(
            MessageType = WHATSAPP_TYPE,
            MessagingPlatformKey = 'whatsapp:' + UGANDA_PHONE,
            DeveloperName = 'UG_CCC_256700550550',
            MasterLabel = 'UG CCC +256700550550'
        ));
        channels.add(new MessagingChannel(
            MessageType = WHATSAPP_TYPE,
            MessagingPlatformKey = 'whatsapp:+26662099222',
            DeveloperName = 'LS_CCC_26662099222',
            MasterLabel = 'LS CCC +26662099222'
        ));
        channels.add(new MessagingChannel(
            MessageType = WHATSAPP_TYPE,
            MessagingPlatformKey = 'whatsapp:+26662099223',
            DeveloperName = 'LS_CCC_26662099223',
            MasterLabel = 'LS CCC +26662099223'
        ));
        insert channels;
    }

    /**
     * @description Tests case creation for live chat transcript requests through chatbot interface
     */
    @isTest
    private static void createCaseTest() {
        Account newAccount = CMN_DAL_DataFactory.newAccount('IndustriesBusiness');
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;
        
        LiveChatTranscript newTranscript = new LiveChatTranscript(
            ContactId = newContact.Id,
            AccountId = newAccount.Id,
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = '0000-0000-0x00-0000-x000'
        );
        insert newTranscript;
        
        Test.startTest();
        SVC_ChatBotHandler.ChatBotTempInput input = new SVC_ChatBotHandler.ChatBotTempInput();
        input.caseSubject = LOGIN_ISSUE;
        input.caseDescription = SITE_ACCESS_ISSUE;
        input.queueApiName = QUEUE_API_NAME;
        input.routableId = newTranscript.Id;

        List<SVC_ChatBotHandler.ChatBotTempOutput> result = SVC_ChatBotHandler.createCase(
            new List<SVC_ChatBotHandler.ChatBotTempInput>{input}
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, result, RESULT_NOT_NULL_MSG);
        Assert.areEqual(1, result.size(), ONE_RESULT_MSG);
    }
   

    /**
     * @description Tests case creation for WhatsApp messaging requests through Uganda queue
     */
    @isTest
    private static void createCaseByWhatsappTest() {
        Long timestamp = System.currentTimeMillis();
        
        MessagingChannel channel = new MessagingChannel(
            MessageType = WHATSAPP_TYPE,
            DeveloperName = 'Test_Channel_' + timestamp,
            MasterLabel = 'Test Channel',
            MessagingPlatformKey = 'TestPlatformKey_' + timestamp
        );
        insert channel;

        User testUser = new User(
            Username = uniqueUsername('testuser1'),
            Alias = 'tuser1',
            LastName = 'TestUser',
            Email = 'testuser1@example.com',
            EmailEncodingKey = UTF8,
            LanguageLocaleKey = EN_US,
            LocaleSidKey = EN_US,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = AFRICA_JHB
        );
        insert testUser;

        Test.startTest();
        
        List<SVC_ChatBotHandler.ChatBotTempOutput> result;
        System.runAs(testUser) {
            MessagingEndUser endUser = new MessagingEndUser(
                Name = 'whatsapp:+1234567890',
                MessagingChannelId = channel.Id,
                MessageType = WHATSAPP_TYPE,
                MessagingPlatformKey = 'TestPlatformKey_' + timestamp
            );
            insert endUser;

            MessagingSession session = new MessagingSession(
                MessagingChannelId = channel.Id,
                MessagingEndUserId = endUser.Id,
                Status = ACTIVE
            );
            insert session;
            
            SVC_ChatBotHandler.ChatBotTempInput input = new SVC_ChatBotHandler.ChatBotTempInput();
            input.caseSubject = LOGIN_ISSUE;
            input.caseDescription = SITE_ACCESS_ISSUE;
            input.queueApiName = QUEUE_API_NAME;
            input.routableId = session.Id;

            result = SVC_ChatBotHandler.createCase(
                new List<SVC_ChatBotHandler.ChatBotTempInput>{input}
            );
        }
        
        Test.stopTest();
        
        Assert.areNotEqual(null, result, RESULT_NOT_NULL_MSG);
        Assert.areEqual(1, result.size(), ONE_RESULT_MSG);
    }
    
    /**
     * @description Tests case creation for Lesotho WhatsApp messaging requests with chat branch
     */
    @isTest
    private static void createCaseByLSWhatsappTest() {
        Long timestamp = System.currentTimeMillis();
        
        MessagingChannel channel = new MessagingChannel(
            MessageType = WHATSAPP_TYPE,
            DeveloperName = 'Test_Channel_LS_' + timestamp,
            MasterLabel = 'Test Channel LS',
            MessagingPlatformKey = 'TestPlatformKey_LS_' + timestamp
        );
        insert channel;

        User testUser = new User(
            Username = uniqueUsername('testuser2'),
            Alias = 'tuser2',
            LastName = 'TestUserLS',
            Email = 'testuser2@example.com',
            EmailEncodingKey = UTF8,
            LanguageLocaleKey = EN_US,
            LocaleSidKey = EN_US,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = AFRICA_JHB
        );
        insert testUser;

        Test.startTest();
        
        List<SVC_ChatBotHandler.ChatBotTempOutput> result;
        System.runAs(testUser) {
            MessagingEndUser endUser = new MessagingEndUser(
                Name = 'whatsapp:+26662099221',
                MessagingChannelId = channel.Id,
                MessageType = WHATSAPP_TYPE,
                MessagingPlatformKey = 'TestPlatformKey_LS_' + timestamp
            );
            insert endUser;

            MessagingSession session = new MessagingSession(
                MessagingChannelId = channel.Id,
                MessagingEndUserId = endUser.Id,
                Status = ACTIVE
            );
            insert session;
            
            SVC_ChatBotHandler.ChatBotTempInput input = new SVC_ChatBotHandler.ChatBotTempInput();
            input.caseSubject = LOGIN_ISSUE;
            input.caseDescription = SITE_ACCESS_ISSUE;
            input.queueApiName = QUEUE_API_NAME_LS;
            input.routableId = session.Id;
            input.branch = 'chat';

            result = SVC_ChatBotHandler.createCase(
                new List<SVC_ChatBotHandler.ChatBotTempInput>{input}
            );
        }
        
        Test.stopTest();
        
        Assert.areNotEqual(null, result, RESULT_NOT_NULL_MSG);
        Assert.areEqual(1, result.size(), ONE_RESULT_MSG);
    }
    /**
     * @description Tests case creation for Lesotho WhatsApp messaging requests with Query branch
     */
    @isTest
    private static void createCaseByLSWhatsappTest1() {
        Long timestamp = System.currentTimeMillis();
        
        MessagingChannel channel = new MessagingChannel(
            MessageType = WHATSAPP_TYPE,
            DeveloperName = 'Test_Channel_LS2_' + timestamp,
            MasterLabel = 'Test Channel LS2',
            MessagingPlatformKey = 'TestPlatformKey_LS2_' + timestamp
        );
        insert channel;

        User testUser = new User(
            Username = uniqueUsername('testuser3'),
            Alias = 'tuser3',
            LastName = 'TestUserLS2',
            Email = 'testuser3@example.com',
            EmailEncodingKey = UTF8,
            LanguageLocaleKey = EN_US,
            LocaleSidKey = EN_US,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            TimeZoneSidKey = AFRICA_JHB
        );
        insert testUser;

        Test.startTest();
        
        List<SVC_ChatBotHandler.ChatBotTempOutput> result;
        System.runAs(testUser) {
            MessagingEndUser endUser = new MessagingEndUser(
                Name = 'whatsapp:+26662099222',
                MessagingChannelId = channel.Id,
                MessageType = WHATSAPP_TYPE,
                MessagingPlatformKey = 'TestPlatformKey_LS2_' + timestamp
            );
            insert endUser;

            MessagingSession session = new MessagingSession(
                MessagingChannelId = channel.Id,
                MessagingEndUserId = endUser.Id,
                Status = ACTIVE
            );
            insert session;
            
            SVC_ChatBotHandler.ChatBotTempInput input = new SVC_ChatBotHandler.ChatBotTempInput();
            input.caseSubject = LOGIN_ISSUE;
            input.caseDescription = SITE_ACCESS_ISSUE;
            input.queueApiName = QUEUE_API_NAME_LS;
            input.routableId = session.Id;
            input.branch = 'Query';

            result = SVC_ChatBotHandler.createCase(
                new List<SVC_ChatBotHandler.ChatBotTempInput>{input}
            );
        }
        
        Test.stopTest();
        
        Assert.areNotEqual(null, result, RESULT_NOT_NULL_MSG);
        Assert.areEqual(1, result.size(), ONE_RESULT_MSG);
    }

}