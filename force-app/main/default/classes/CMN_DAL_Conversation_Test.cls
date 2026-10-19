/**
 * @description Test Class for CMN_DAL_Conversation Class
 * @author BlueSky
 * @date October 2021
 */
@isTest
public class CMN_DAL_Conversation_Test {
    
    @TestSetup
    private static void setup() {
        // create account
        Account account = new Account();
        account.LastName = 'Test1';
        insert account;
        // create conversation
        Id userId = UserInfo.getUserId();
        User user = [SELECT RM_AE_Code__c FROM User WHERE Id = :userId LIMIT 1];
        CMN_Conversation__c conversation = new CMN_Conversation__c();
        conversation.AE_Number__c = user.RM_AE_Code__c;
        conversation.Account__c = account.Id;
        conversation.Status__c = null;
        insert conversation;

        CMN_Conversation__c actionedConversationWithOpp = new CMN_Conversation__c();
        actionedConversationWithOpp.AE_Number__c = user.RM_AE_Code__c;
        actionedConversationWithOpp.Account__c = account.Id;
        actionedConversationWithOpp.Reason__c = 'Test Reason';
        actionedConversationWithOpp.Response__c = 'Test Response';
        actionedConversationWithOpp.Status__c = 'Actioned';
        actionedConversationWithOpp.CreatedDate = System.today() - 31;
        insert actionedConversationWithOpp;

        CMN_Conversation__c actionedConversationWithoutOpp = new CMN_Conversation__c();
        actionedConversationWithoutOpp.AE_Number__c = user.RM_AE_Code__c;
        actionedConversationWithoutOpp.Account__c = account.Id;
        actionedConversationWithoutOpp.Reason__c = 'Test Reason';
        actionedConversationWithoutOpp.Response__c = 'Test Response';
        actionedConversationWithoutOpp.Status__c = 'Actioned';
        actionedConversationWithoutOpp.CreatedDate = System.today() - 91;
        insert actionedConversationWithoutOpp;

        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp';
        testOpp.StageName = 'New';
        testOpp.CloseDate = System.today()+30;
        testOpp.AccountId = account.Id;
        testOpp.CMN_NBAConversation__c = actionedConversationWithOpp.Id;
        insert testOpp;
    }
    
    @isTest
    private static void testConversationsByAECode() {
        Id userId = UserInfo.getUserId();
        Account account = [SELECT Id FROM Account WHERE LastName = 'Test1'];

        Test.startTest();
        List<CMN_Conversation__c> conversationsAccount = CMN_DAL_Conversation.getAccountConversations(account.Id);
        System.assertNotEquals(null, conversationsAccount, 'conversationsAccount should not be null');
        String rmAeCode = CMN_DAL_Conversation.getRmAeCode(userId);
        List<CMN_Conversation__c> conversationsHome = CMN_DAL_Conversation.getConversationsByRmAeCode(rmAeCode);
        System.assertNotEquals(null, conversationsHome, 'conversationsHome should not be null');
        Set<String> leadKeys = new Set<String>();
        for (CMN_Conversation__c conv : conversationsAccount) {
            leadKeys.add(conv.Lead_Key__c);
        }
        List<CMN_Conversation__c> conversationsConversationId = CMN_DAL_Conversation.getConversationsByConversationIds(leadKeys);
        List<CMN_Conversation__c> conversationsActioned = CMN_DAL_Conversation.getActionedConversations();
        List<CMN_Conversation__c> conversationsUnActioned = CMN_DAL_Conversation.getUnActionedConversations();
        Test.stopTest();

        System.assertNotEquals(null, conversationsAccount, 'conversationsAccount should not be null');
        System.assertNotEquals(null, conversationsHome, 'conversationsHome should not be null');
        System.assertNotEquals(null, conversationsConversationId, 'conversationsConversationId should not be null');
        System.assertEquals(1, conversationsActioned.size(), 'conversationActioned size should be equal 1');
        System.assertNotEquals(null, conversationsUnActioned, 'conversationsUnActioned should not be null');
    }
}