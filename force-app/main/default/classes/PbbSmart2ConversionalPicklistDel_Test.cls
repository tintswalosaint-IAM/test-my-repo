/**
 * This test class for PbbSmart2ConversionalPicklistDel
 *
 * @author		Lukasz Kojzar
 * @date	    October 2022
*/
@IsTest	
private class PbbSmart2ConversionalPicklistDel_Test {

    private static final String CRON_EXP = '0 0 0 ? * * *';

    @TestSetup
    private static void testSetup() {
        insert new Conversation_Value__c(
                Reason__c = 'Application submitted',
                Response__c = 'Accepted Offer',
                Sub_Category__c = 'Cash - Settlements'
        );
        if ([SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :PbbSmart2ConversionalPicklistDel_Sched.JOB_NAME] > 0) {
            PbbSmart2ConversionalPicklistDel_Sched.unscheduleMe();
        }
    }

    @IsTest	
	private static void testScheduler(){
        Test.startTest();
        PbbSmart2ConversionalPicklistDel_Sched.scheduleMe();
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :PbbSmart2ConversionalPicklistDel_Sched.JOB_NAME], 'Job should be scheduled');
    }

    @IsTest
    private static void testUnscheduler() {
        PbbSmart2ConversionalPicklistDel_Sched.scheduleMe();
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :PbbSmart2ConversionalPicklistDel_Sched.JOB_NAME], 'Job should be scheduled as prerequisite');
        Test.startTest();
        PbbSmart2ConversionalPicklistDel_Sched.unscheduleMe();
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :PbbSmart2ConversionalPicklistDel_Sched.JOB_NAME], 'No job should be scheduled');
    }

    @IsTest
    private static void testErrorOnDelete() {
        PbbSmart2ConversionalPicklistDel.testError = true;
        Test.startTest();
        Database.executeBatch(new PbbSmart2ConversionalPicklistDel());
        Test.stopTest();
        System.assert([SELECT COUNT() FROM Conversation_Value__c] > 0, 'Conversation Value should not be deleted');
    }

    @IsTest
    private static void gettingReasonAndResponseTest() {
        String expectedTokenValue = 'testTokenValueCache';
        Cache.OrgPartition orgPart = cache.Org.getPartition(PBB_SRV_GatewayRequestProvider.PARTITION_TOKENS);
        orgPart.put(PBB_SRV_GatewayRequestProvider.PARTITION_TOKEN_NAME, expectedTokenValue, 7000);
        Test.startTest();
        PbbSmart2ConversationPicklistSync.mergeResponseAndReason();
        Test.stopTest();
        List<Conversation_Value__c> cValues = [SELECT Id, Sub_Category__c, Reason__c, Response__c FROM Conversation_Value__c WHERE Sub_Category__c != 'Cash - Settlements'];
        System.assertEquals(2, cValues.size(), 'Incorrect number of inserted Conversation Values');
        for (Conversation_Value__c cv : cValues) {
            System.assertEquals('Application submitted', cv.Reason__c, 'Wrong Reason');
            System.assertEquals('Accepted Offer', cv.Response__c, 'Wrong Response');
            if (cv.Sub_Category__c.length() > 4) {
                System.assertEquals('Cash - Device Expiry', cv.Sub_Category__c, 'Wrong Sub Category');
            } else {
                System.assertEquals('Cash', cv.Sub_Category__c, 'Wrong Sub Category');
            }
        }
    }

    @IsTest
    private static void testSendHttpError() {
        SRV_HttpRequestSender sender = new SRV_HttpRequestSender();
        sender.throwException = true;
        Test.startTest();
        HttpResponse res = sender.send(new HttpRequest(),1);
        Test.stopTest();
        System.assertEquals(null, res, 'Response should not be received due to error');
    }
}