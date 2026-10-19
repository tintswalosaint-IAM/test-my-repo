@IsTest
public class AOB_SRV_Document_TEST {
  @TestSetup
  public static void testSetUp() {
    User communityUser = AOB_DAL_TestFactory.createCommunityUser();
  }

  /**
   * @description This method is used to test getDocument methd
   */
  @isTest
  public static void AOB_callGetToken_Test() {
    User communityUser = [
      SELECT Id
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      Blob doc = AOB_SRV_Document.callGetDocument('');
      Test.stopTest();
      System.assertNotEquals(doc, null);
    }
  }
}