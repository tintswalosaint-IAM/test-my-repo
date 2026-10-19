/**
 * @description       : Test class for INS_SEL_CustomNotification
 * @author            : Raja Arsalan
**/
@isTest
private class INS_SEL_CustomNotification_Test {
/**
 * @description       : Test class for INS_SEL_CustomNotification
 * @author            : Raja Arsalan
**/  
    @isTest
    static void test_selectNotificationTypeById() {
        // Create test data
        CustomNotificationType cn = new CustomNotificationType(DeveloperName = 'TestNotification');


        INS_SEL_CustomNotification selector = new INS_SEL_CustomNotification();
        List<CustomNotificationType> result = selector.selectNotificationTypeById('TestNotification');
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        
        Assert.areEqual(2, fieldList.size(), 'Expected field list to contain 2 fields.');
    }
}