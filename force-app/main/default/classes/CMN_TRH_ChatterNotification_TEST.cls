/**
 * @description Test class
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/05/04
 */
@isTest
public class CMN_TRH_ChatterNotification_TEST {
    /**
     * @description To check platform event
     */
    @isTest
    private static void processRecordTest() {
        WI_ChatterNotification__e ev = new WI_ChatterNotification__e(
            WI_UserId__c = UserInfo.getUserId(),
            WI_Message__c = 'Test message'
        );
        Test.startTest();
        EventBus.publish(ev);
        Test.stopTest();
        List<FeedItem> items = [SELECT Id FROM FeedItem WHERE ParentId = :UserInfo.getUserId()];
        Assert.isTrue(items.size() > 0, 'Feed Item creation error');
    }
}