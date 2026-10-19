/*
 * @description Test class for CMN_DAL_User
 * Part of apex-lang open-source project (http://code.google.com/p/apex-lang/)
 * Licensed under Apache License 2.0
 *
 * @author richard van hook
 *
 * @date 2012
 *
 * History
 * VCCC-378 - Forked from apex-lang project, updated for latest Salesforce APIs
 */
@IsTest(SeeAllData=false)
private class CMN_DAL_User_TEST {
  @IsTest
  private static void testIsCurrentUserSystemAdmin() {
    Test.startTest();
    Boolean result = CMN_DAL_User.isCurrentUserSystemAdmin();
    Test.stopTest();

    Assert.isNotNull(result);
  }

  /*
   * tests that user is not found if fake or random federation id is used
   */
  @IsTest
  private static void testFindUserByFederationIdNegative() {
    Test.startTest();
    User result = CMN_DAL_User.findUserByFederationId(
      CMN_DAL_SObjectDomain.generateRandomEmail()
    );
    Test.stopTest();

    Assert.isNull(result);
  }

  /*
   * tests that active users can be found by profile name
   */
  @IsTest
  private static void testFindUserByProfile() {
    Test.startTest();
    List<User> results = CMN_DAL_User.findActiveByProfileName(
      'System Administrator',
      new Set<String>{ 'Id' },
      true
    );
    Test.stopTest();

    Assert.isNotNull(results);
  }

  @IsTest
  private static void testFindByUserId() {
    Test.startTest();
    User result = CMN_DAL_User.findByUserId(UserInfo.getUserId());
    Test.stopTest();

    Assert.isNotNull(result);
  }

  @IsTest
  private static void testGetCurrentUser() {
    Test.startTest();
    User result = CMN_DAL_User.getCurrentUser();
    Test.stopTest();

    Assert.areEqual(UserInfo.getUserId(), result.Id);
  }

  @IsTest
  private static void testFindRandomActiveByProfileName() {
    Test.startTest();
    User result = CMN_DAL_User.findRandomActiveByProfileName('System Administrator');
    Test.stopTest();

    Assert.isNotNull(result);
  }

  @IsTest
  private static void testFindByUsername() {
    Test.startTest();
    List<User> results = CMN_DAL_User.findByUsername(new Set<String>{ UserInfo.getUserName() });
    Test.stopTest();

    Assert.isFalse(results.isEmpty());
  }

  @IsTest
  private static void testFindByProfileName() {
    Test.startTest();
    List<User> results = CMN_DAL_User.findByProfileName(new Set<String>{ 'System Administrator' });
    Test.stopTest();

    Assert.isFalse(results.isEmpty());
  }

  @IsTest
  private static void testGetManagerByLevel() {
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = UserInfo.getUserId();
    request.escalationLevel = 1;

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_User.getManagerByLevel(new List<CMN_DAL_User.ManagerRequest>{ request });
    Test.stopTest();

    Assert.isNotNull(results);
  }
}