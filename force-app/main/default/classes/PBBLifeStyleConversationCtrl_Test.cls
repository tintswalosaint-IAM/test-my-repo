/**
* @author       Sandile mathe
* @description  This test class for PBBLifeStyleConversationCtrl
*               
* @date         April 2021
**/
@isTest
public class PBBLifeStyleConversationCtrl_Test {
    private static final String GUID_CLIENT_NAME = 'Account With GUID Test';
    private static final String NO_GUID_CLIENT_NAME = 'Account Without GUID Test';
    private static final String INTERNAL_SERVER_ERROR = 'Internal server error';
    
    private static final String EXAMPLE_SUB_CATEGORY = 'VAF Optimiser';
    private static final String EXAMPLE_RESPONSE = 'Accept Offer';
    private static final String EXAMPLE_REASON = 'Application approved';
    
    @TestSetup
    private static  void setupData() {

        Account acc = new Account(
                Name = 'test',
                ExternalCIFUUID__c = '4554f98f7ch50135000000000ab6f434',
                ExternalCIFId__c = '0530754246'
        );
        insert acc;
        CMN_Conversation__c conv = new CMN_Conversation__c(
                External_UUID__c = '4536456',
                Account__c = acc.Id,
                Lead_Key__c = '123a'
        );
        CMN_Conversation__c conv2 = new CMN_Conversation__c(
                External_UUID__c = '435654',
                Account__c = acc.Id,
                Lead_Key__c = '123b'
        );
        CMN_Conversation__c conv3 = new CMN_Conversation__c(
                External_UUID__c = '43565478',
                Account__c = acc.Id,
                Lead_Key__c = '123c'
        );
        insert new List<CMN_Conversation__c> {conv, conv2, conv3};
    }

    @IsTest
    private static void testgetRecord() {
        List<CMN_Conversation__c> conv = [SELECT External_UUID__c, Account__c, Lead_Key__c FROM CMN_Conversation__c WHERE Lead_Key__c = '123c'];
        Test.startTest();
        PBBLifeStyleConversationCtrl.getRecord(conv[0].Id);
        Test.stopTest();
        System.assert(CMN_Conversation__c.Id != null, 'No Value found');
    }
    
    @IsTest
    private static void testCreateNewConversation() {
        CMN_Conversation__c conv = new CMN_Conversation__c(OwnerId=UserInfo.getUserId(), Reason__c=EXAMPLE_REASON );
        Test.startTest();
        PBBLifeStyleConversationCtrl.createNewConversation(conv);
        PBBLifeStyleConversationCtrl.saveData(conv);
        Test.stopTest();
        List<CMN_Conversation__c> convs = [SELECT External_UUID__c, Account__c, Lead_Key__c, Sub_Category__c FROM CMN_Conversation__c WHERE Lead_Key__c = '123c'];
        System.assertEquals(null,convs[0].Sub_Category__c,'Record did not save');
    }

    @IsTest
    private static void testCreateNewConversationError() {
        Id invalidId;
        CMN_Conversation__c conv = new CMN_Conversation__c(OwnerId=invalidId, Reason__c=EXAMPLE_REASON );
        Test.startTest();
        try {
            PBBLifeStyleConversationCtrl.createNewConversation(conv);
            System.assert(false, 'Exception should be thrown');
        } catch (PBBLifeStyleConversationCtrl.PBBLifeStyleConversationException ex) {
            System.assert(ex.getMessage().contains('Owner ID: owner cannot be blank'), 'Wrong exception message: ' + ex.getMessage());
        } catch (Exception ex) {
            System.assert(false, 'Wrong Exception type: ' + ex.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    private static void testSaveDataError() {
        CMN_Conversation__c conv = new CMN_Conversation__c(OwnerId=UserInfo.getUserId(), Reason__c=EXAMPLE_REASON );
        Test.startTest();
        try {
            PBBLifeStyleConversationCtrl.saveData(conv);
            System.assert(false, 'Exception should be thrown');
        } catch (PBBLifeStyleConversationCtrl.PBBLifeStyleConversationException ex) {
            System.assert(ex.getMessage().contains('Id not specified in an update call'), 'Wrong exception message: ' + ex.getMessage());
        } catch (Exception ex) {
            System.assert(false, 'Wrong Exception type: ' + ex.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    private static void testGetConversations() {
        List<Account> acc = [SELECT Id, Name, ExternalCIFUUID__c, ExternalCIFId__c FROM Account WHERE Name = 'test'];
        Test.startTest();
        PBBLifeStyleConversationCtrl.getConversations(acc[0].Id);
        Test.stopTest();
        System.assert(CMN_Conversation__c.Account__c != null,'No Conversation was retrieved');
    }
    @IsTest
    private static void testNewConversation() {

        List<Account> acc = [SELECT Id, Name, ExternalCIFUUID__c, ExternalCIFId__c FROM Account WHERE Name = 'test'];
        Test.startTest();
        PBBLifeStyleConversationCtrl.newConversation(acc[0].Id);
        Test.stopTest();
        List<CMN_Conversation__c> conv = [SELECT External_UUID__c, Account__c, Lead_Key__c FROM CMN_Conversation__c WHERE Lead_Key__c = '123c'];
        System.assertNotEquals(null, conv[0].Id,'New Conversation was not added');
    }

    @IsTest
    private static void testGetArrangedDependancies() {
        Conversation_Value__c cval = new Conversation_Value__c(
                Sub_Category__c = 'Product Conversations',
                Reason__c = 'Never offer again',
                Response__c = 'Could not discuss with client'
        );
        Conversation_Value__c cval2 = new Conversation_Value__c(
                Sub_Category__c = 'Professionals Maturity',
                Reason__c = 'Never offer again',
                Response__c = 'Could not discuss with client'
        );
        Conversation_Value__c cval3 = new Conversation_Value__c(
                Sub_Category__c = 'Contact Mgt - Collections',
                Reason__c = 'Refused to Authenticate',
                Response__c = 'Could not discuss with client'
        );
        Conversation_Value__c cval4 = new Conversation_Value__c(
                Sub_Category__c = 'Contact Mgt - Card Welcome',
                Reason__c = 'Refused to Authenticate',
                Response__c = 'Could not discuss with client'
        );
        insert new List<Conversation_Value__c>{cval, cval2, cval3, cval4};
        Test.startTest();
        PBBLifeStyleConversationCtrl.getArrangedDependancies();
        Test.stopTest();
        System.assertEquals('Application approved', EXAMPLE_REASON, 'Incorrect reason');
    }
    
    @IsTest
    private static void testGetArrangedDependanciesWithNullResponse() {
        Conversation_Value__c cval = new Conversation_Value__c(
                Sub_Category__c = 'EAP Digital'
        );
     	insert cval;
        Test.startTest();
        PBBLifeStyleConversationCtrl.getArrangedDependancies();
        Test.stopTest();
        List<Conversation_Value__c> con = [SELECT Response__c FROM Conversation_Value__c WHERE Sub_Category__c = 'EAP Digital'];
        System.assertEquals(null,con[0].Response__c,'Response Values are not matching');
    }
}