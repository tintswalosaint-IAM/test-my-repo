/**
 * @description Test class testing all common CMN copy tasks
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
@IsTest(SeeAllData=false)
private class CMN_SPC_Workers_TEST {
  @TestSetup
  static void insertTestData() {
    //adding some data to the custom setting so we can enable users in these profiles
    String adminUsername = CMN_DAL_User.findRandomActiveByProfileName(
        CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
      )
      .Username;

    List<CMN_SPC_UsersToEnable__c> customSettings = new List<CMN_SPC_UsersToEnable__c>();

    customSettings.add(
      CMN_DAL_DataFactory.newSpcUsersToEnable(
        CMN_DAL_Profile.PROFILE_STANDARD_USER,
        CMN_DAL_Profile.PROFILE_STANDARD_USER,
        null
      )
    );
    customSettings.add(
      CMN_DAL_DataFactory.newSpcUsersToEnable(
        CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER,
        CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER,
        null
      )
    );
    customSettings.add(
      CMN_DAL_DataFactory.newSpcUsersToEnable(
        CMN_UTIL_Random.randomAlphabetic(10),
        CMN_UTIL_String.EMPTY,
        adminUsername
      )
    );

    CMN_DAL_SObjectDomain.insertDBObjects(customSettings);

    CMN_DAL_DataFactory.createFeatureSwitch(UserInfo.getOrganizationId());
    CMN_DAL_DataFactory.createFeatureSwitch(
      CMN_DAL_User.findRandomActiveByProfileName(
          CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
        )
        .Id
    );
  }

  /**
   * @description This method tests whether the user email has changed after the queued job ran
   */
  @IsTest
  private static void enableUsers() {
    //getting random user to change email address with .invalid appended for the purpose of simulating a post copy scenario
    User adminUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
    );
    User chatterFreeUser = CMN_DAL_User.findByProfileName(
      new Set<String>{ CMN_DAL_Profile.PROFILE_CHATTER_FREE_USER }
    )[0];

    CMN_SPC_EnableUsers enableUsers = new CMN_SPC_EnableUsers();

    String adminUsername = CMN_DAL_UsersToEnable.getUsername()
      .CMN_SPC_EnableUsername__c;

    User singleUsernameToEnable = CMN_DAL_User.findByUsername(
      new Set<String>{ adminUsername }
    )[0];

    System.runAs(adminUser) {
      singleUsernameToEnable.Username =
        singleUsernameToEnable.Username +
        '.' +
        enableUsers.context.sandboxName();
      chatterFreeUser.Username =
        chatterFreeUser.Username +
        '.' +
        enableUsers.context.sandboxName();
      chatterFreeUser.Email =
        chatterFreeUser.Email + CMN_DAL_User.EMAIL_INVALID;
      chatterFreeUser.IsActive = false;

      CMN_DAL_SObjectDomain.updateDBObject(chatterFreeUser);
    }

    chatterFreeUser = CMN_DAL_User.findByUserId(chatterFreeUser.Id);
    //verify if email address has .invalid appended
    System.assert(chatterFreeUser.Email.endsWith(CMN_DAL_User.EMAIL_INVALID));

    Test.startTest();

    System.runAs(adminUser) {
      enableUsers.run();
    }

    Test.stopTest();

    adminUser = CMN_DAL_User.findByUserId(adminUser.Id);
    chatterFreeUser = CMN_DAL_User.findByUserId(chatterFreeUser.Id);
    singleUsernameToEnable = CMN_DAL_User.findByUserId(
      singleUsernameToEnable.Id
    );

    //check if the email address doesn't end with .invalid
    System.assert(!chatterFreeUser.Email.endsWith(CMN_DAL_User.EMAIL_INVALID));
    System.assert(
      !singleUsernameToEnable.Email.endsWith(CMN_DAL_User.EMAIL_INVALID)
    );

    //check if the user is active
    System.assertEquals(true, chatterFreeUser.IsActive);
  }

  /**
   * @description Ensures we cover the code for Mock Sandbox Context class getter
   */
  @IsTest
  private static void testMockSandboxContext() {
    CMN_SPC_EnableUsers enableUsers = new CMN_SPC_EnableUsers();

    String orgId = enableUsers.context.organizationId();
    String sandboxId = enableUsers.context.sandboxId();

    System.assertEquals(UserInfo.getOrganizationId(), orgId);
    System.assertEquals(UserInfo.getOrganizationId(), sandboxId);
  }

  /**
   * @description This method tests if the org default feature switch is disabled after queued job has ran
   */
  @IsTest
  private static void disableApiCalls() {
    User adminUser = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
    );
    CMN_SPC_DisableApiCalls disableCalls = new CMN_SPC_DisableApiCalls();

    Test.startTest();

    System.runAs(adminUser) {
      disableCalls.run();
    }

    Test.stopTest();

    CMN_FeatureSwitches__c orgDefaultFeatureSwitch = CMN_DAL_FeatureSwitches.getFeatureSwitch(
      UserInfo.getOrganizationId()
    );
    System.assertEquals(
      true,
      orgDefaultFeatureSwitch.CMN_DisableAllOutboundAPICalls__c
    );
  }
}