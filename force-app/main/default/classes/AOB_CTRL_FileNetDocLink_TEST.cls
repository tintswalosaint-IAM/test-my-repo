@isTest
public class AOB_CTRL_FileNetDocLink_TEST {
  final static String TEST_TOKEN = 'AAIkYzc0NmM';
  @TestSetup
  static void testSetUp() {
    User communityUser = AOB_DAL_TestFactory.createCommunityUser();
  }

  /**
   * @description This method is used to test getDocument methd
   */
  @isTest
  static void callGetDocument_Test() {
    User communityUser = [
      SELECT Id, ContactId
      FROM USER
      WHERE Email LIKE '%@test.org'
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      DOC_API_GetDocument.DTO_Response response = AOB_CTRL_FileNetDocLink.callGetDocument(
        TEST_TOKEN,
        communityUser.ContactId
      );
      Test.stopTest();
      System.assertNotEquals(null, response, 'respone is null');
    }
  }

  @isTest
  static void callGetToken_Test() {
    User communityUser = [
      SELECT Id, ContactId
      FROM USER
      WHERE Email LIKE '%@test.org' 
      LIMIT 1
    ];
    System.runAs(communityUser) {
      Test.startTest();
      String token = AOB_CTRL_FileNetDocLink.callGetToken();
      Test.stopTest();
      system.assertEquals(token, TEST_TOKEN, '');
    }
  }
}