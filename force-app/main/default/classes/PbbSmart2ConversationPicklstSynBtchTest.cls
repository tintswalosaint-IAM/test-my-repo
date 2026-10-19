/**
* @description Test class for PbbSmart2ConversationPicklistSyncBatch class
*
* @author		Lukasz Kojzar
* @date		21/10/2022
*/
@IsTest
private class PbbSmart2ConversationPicklstSynBtchTest {
    @IsTest
    private static void testBatch() {
        String testResponse = 'testResponse';
        String testReason = 'testReason';
        String testSC = 'testSC';
        List<Conversation_Value__c> cValues = new List<Conversation_Value__c>{
                new Conversation_Value__c(
                    Response__c = testResponse,
                    Reason__c = testReason,
                    Sub_Category__c = testSC
                )
        };
        Test.startTest();
        Database.executeBatch(new PbbSmart2ConversationPicklistSyncBatch(cValues));
        Test.stopTest();
        cValues = [SELECT Id, Response__c, Reason__c, Sub_Category__c FROM Conversation_Value__c];
        System.assertEquals(1, cValues.size(), 'Conversation Value should be inserted');
        System.assertEquals(testResponse, cValues[0].Response__c, 'Incorrect Response');
        System.assertEquals(testReason, cValues[0].Reason__c, 'Incorrect Reason');
        System.assertEquals(testSC, cValues[0].Sub_Category__c, 'Incorrect Sub Category');
    }

    @IsTest
    private static void testErrorOnInsert() {
        final String str256chars = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456';
        List<Conversation_Value__c> cValues = new List<Conversation_Value__c>{
                new Conversation_Value__c(
                    Response__c = str256chars
                )
        };
        Test.startTest();
        Database.executeBatch(new PbbSmart2ConversationPicklistSyncBatch(cValues));
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Conversation_Value__c], 'No Conversation Value should be inserted');
    }
}