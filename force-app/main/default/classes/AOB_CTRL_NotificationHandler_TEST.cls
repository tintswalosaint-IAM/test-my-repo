@isTest
    public class AOB_CTRL_NotificationHandler_TEST {
      
    @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
          Map<string, string> ApplicationData = new Map<string, string>();
          Account acc = [
            SELECT Id
            FROM Account
            WHERE
              Id IN (
                SELECT AccountId
                FROM Contact
                WHERE Id = :communityUser.contactId
              )
          ];
        ApplicationData.put('AOB_Customer__c', acc.id);
        insert AOB_DAL_TesTFactory.genericObjectCreation(
            'AOB_Application__c',
            ApplicationData
          );
    }
    
      /**
       * @description gets the current application record Test
       *
       */
    @isTest
    public 
    static void getApplicationRecord_Test() {
       User communityUser = [SELECT Id , contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
           Account acc = [
            SELECT Id
            FROM Account
            WHERE
              Id IN (
                SELECT AccountId
                FROM Contact
                WHERE Id = :communityUser.contactId
              )
          ];
          AOB_Application__c app = [
            SELECT Id
            FROM AOB_Application__c
            WHERE AOB_Customer__c = :acc.Id
          ];
        System.runAs(communityUser) {
          Test.startTest();
          app = AOB_CTRL_NotificationHandler.getApplicationRecord(app.Id);
          Test.stopTest();
          System.assertNotEquals(null, app);
        }
    }
}