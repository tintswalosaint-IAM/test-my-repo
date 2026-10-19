/*
 * @description Test class for CMN_DAL_UserManagerHierarchy
 *
 * @author Raymond Magezi
 *
 * @date 29-01-2026
 *
 * History
 * 29-01-2026 - Raymond Magezi - Initial creation
 */
@IsTest(SeeAllData=false)
private class CMN_DAL_UserManagerHierarchy_TEST {
  
  @IsTest
  private static void testGetManagerByLevelWithValidRequest() {
    User currentUser = [SELECT Id, ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = currentUser.Id;
    request.escalationLevel = 1;

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(
      new List<CMN_DAL_User.ManagerRequest>{ request }
    );
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.areEqual(1, results.size());
  }

  @IsTest
  private static void testGetManagerByLevelWithNullRequest() {
    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(null);
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.isTrue(results.isEmpty());
  }

  @IsTest
  private static void testGetManagerByLevelWithEmptyList() {
    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(
      new List<CMN_DAL_User.ManagerRequest>()
    );
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.isTrue(results.isEmpty());
  }

  @IsTest
  private static void testGetManagerByLevelWithInvalidEscalationLevel() {
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = UserInfo.getUserId();
    request.escalationLevel = 10;

    Test.startTest();
    try {
      CMN_DAL_UserManagerHierarchy.getManagerByLevel(new List<CMN_DAL_User.ManagerRequest>{ request });
      Assert.fail('Expected ManagerLookupException');
    } catch (CMN_DAL_User.ManagerLookupException e) {
      Assert.isTrue(e.getMessage().contains('Escalation level must be between'));
    }
    Test.stopTest();
  }

  @IsTest
  private static void testGetManagerByLevelWithNonUserId() {
    Group testQueue = [SELECT Id FROM Group WHERE Type = 'Queue' LIMIT 1];
    
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = testQueue.Id;
    request.escalationLevel = 1;

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(
      new List<CMN_DAL_User.ManagerRequest>{ request }
    );
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.areEqual(1, results.size());
    Assert.isNotNull(results[0].errorMessage);
  }

  @IsTest
  private static void testGetManagerByLevelBulkProcessing() {
    List<CMN_DAL_User.ManagerRequest> requests = new List<CMN_DAL_User.ManagerRequest>();
    for (Integer i = 0; i < 3; i++) {
      CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
      request.ownerId = UserInfo.getUserId();
      request.escalationLevel = 1;
      requests.add(request);
    }

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(requests);
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.areEqual(3, results.size());
  }

  @IsTest
  private static void testGetManagerByLevelWithNullRequestInList() {
    List<CMN_DAL_User.ManagerRequest> requests = new List<CMN_DAL_User.ManagerRequest>();
    requests.add(null);
    CMN_DAL_User.ManagerRequest validRequest = new CMN_DAL_User.ManagerRequest();
    validRequest.ownerId = UserInfo.getUserId();
    validRequest.escalationLevel = 1;
    requests.add(validRequest);

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(requests);
    Test.stopTest();

    Assert.isNotNull(results);
  }
  
  @IsTest
  private static void testGetManagerByLevelWithZeroEscalationLevel() {
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = UserInfo.getUserId();
    request.escalationLevel = 0;

    Test.startTest();
    try {
      CMN_DAL_UserManagerHierarchy.getManagerByLevel(new List<CMN_DAL_User.ManagerRequest>{ request });
      Assert.fail('Expected ManagerLookupException');
    } catch (CMN_DAL_User.ManagerLookupException e) {
      Assert.isTrue(e.getMessage().contains('Escalation level must be between'));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testGetManagerByLevelWithNullOwnerId() {
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = null;
    request.escalationLevel = 1;

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(
      new List<CMN_DAL_User.ManagerRequest>{ request }
    );
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.areEqual(1, results.size());
    Assert.isNotNull(results[0].errorMessage);
  }
  
  @IsTest
  private static void testGetManagerByLevelWithNullEscalationLevel() {
    CMN_DAL_User.ManagerRequest request = new CMN_DAL_User.ManagerRequest();
    request.ownerId = UserInfo.getUserId();
    request.escalationLevel = null;

    Test.startTest();
    List<CMN_DAL_User.ManagerResult> results = CMN_DAL_UserManagerHierarchy.getManagerByLevel(
      new List<CMN_DAL_User.ManagerRequest>{ request }
    );
    Test.stopTest();

    Assert.isNotNull(results);
    Assert.areEqual(1, results.size());
  }
}