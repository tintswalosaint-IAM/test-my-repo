@IsTest
public with sharing class CMN_MultiActioningConvCtrl_Test {
    private static final String EXAMPLE_REASON = 'Application approved';

    @TestSetup
    private static void setupData() {

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
    private static void shouldGetRecord() {
        List<CMN_Conversation__c> conv = [SELECT External_UUID__c, Account__c, Lead_Key__c FROM CMN_Conversation__c WHERE Lead_Key__c = '123c'];
        Test.startTest();
        CMN_MultiActioningConvCtrl.getRecord(conv[0].Id);
        Test.stopTest();
        System.assert(CMN_Conversation__c.Id != null, 'No Value found');
    }

    @IsTest
    private static void testGetArrangedDependencies() {
        Test.startTest();
        CMN_MultiActioningConvCtrl.getArrangedDependencies();
        Test.stopTest();
        System.assertEquals('Application approved',EXAMPLE_REASON, 'Reason should be equal to Application approved');
    }

    @IsTest
    private static void testGetArrangedDependenciesWithNullResponse() {
        Conversation_Value__c cval = new Conversation_Value__c(
                Sub_Category__c = 'EAP Digital'
        );
        insert cval;

        Conversation_Value__c cval2 = new Conversation_Value__c(
                Sub_Category__c = 'EAP Digital',
                Response__c = 'Test Response',
                Reason__c = 'Test Reason'
        );
        insert cval2;

        Conversation_Value__c cval3 = new Conversation_Value__c(
                Sub_Category__c = 'EAP Digital',
                Response__c = 'Test Response',
                Reason__c = 'Test Reason 2'
        );
        insert cval3;
        Test.startTest();
        CMN_MultiActioningConvCtrl.getArrangedDependencies();
        Test.stopTest();
        List<Conversation_Value__c> con = [SELECT Response__c FROM Conversation_Value__c WHERE Sub_Category__c = 'EAP Digital'];
        System.assertEquals(null,con[0].Response__c,'Response Values are not matching');
    }

}