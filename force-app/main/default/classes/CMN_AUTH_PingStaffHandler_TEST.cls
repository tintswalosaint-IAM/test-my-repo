/**
 * @description Tests the CMN_AUTH_PingStaffHandler (user link and registration handler)
 * <p/>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaffHandler
 * @see CMN_AUTH_PingStaff
 *
 * @author Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date November 2020
 */
@IsTest(SeeAllData=false)
private class CMN_AUTH_PingStaffHandler_TEST {
  /**
   * @description setup the user record required for ping staff registration handler.
   * Staff user needs to be setup with federation id before using ping staff.
   *
   * @return inserted user record
   */
  private static User setup() {
    // staff or admin user should be able to login via ping staff
    User record = CMN_DAL_DataFactory.newUser(
      CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
    );
    insert record;
    return record;
  }

  /**
   * @description expect an exception to be thrown as user email is random and won't match to federated id
   * email used to link FederationId if null throw exception
   */
  @IsTest
  private static void upsertUserTokenNegativeNoEmail() {
    CMN_AUTH_PingStaffHandler handler = new CMN_AUTH_PingStaffHandler();

    try {
      Auth.UserData userData = createRandomUserData();
      userData.email = null;
      handler.createUser(null, userData);
      System.assert(false, 'Expected exception (no email)');
    } catch (Exception e) {
      System.assert(true, 'Error thrown as expected');
    }
  }

  /**
   * @description expect an exception to be thrown as user email is random and won't match to federated id
   * email used to link FederationId if null throw exception
   */
  @IsTest
  private static void upsertUserTokenNegativeFederationIdMismatch() {
    CMN_AUTH_PingStaffHandler handler = new CMN_AUTH_PingStaffHandler();

    try {
      Auth.UserData userData = createRandomUserData();
      userData.email = CMN_DAL_SObjectDomain.generateRandomEmail();
      handler.createUser(null, userData);
      System.assert(false, 'Expected exception (federationId mismatch)');
    } catch (Exception e) {
      System.assert(true, 'Error thrown as expected');
    }
  }

  /**
   * @description test create user handler will upsert oauth token.
   *
   * @see CMN_AUTH_PingStaffHandler.createUser
   */
  @IsTest
  private static void insertUserPositive() {
    User newUser = setup();

    Auth.UserData userData = createUserData(newUser);

    Test.startTest();

    CMN_AUTH_PingStaffHandler handler = new CMN_AUTH_PingStaffHandler();

    User foundUser = handler.createUser(null, userData);

    Test.stopTest();

    System.assertNotEquals(null, foundUser, 'No User was found');
    System.assertEquals(
      userData.email,
      foundUser.Email,
      'Incorrect User found'
    );
  }

  /**
   * @description test update user handler will upsert oauth token.
   *
   * @see CMN_AUTH_PingStaffHandler.updateUser
   */
  @IsTest
  private static void updateUserPositive() {
    User newUser = setup();

    Auth.UserData userData = createUserData(newUser);

    Test.startTest();

    CMN_AUTH_PingStaffHandler handler = new CMN_AUTH_PingStaffHandler();

    handler.updateUser(newUser.Id, null, userData);

    Test.stopTest();

    newUser = CMN_DAL_User.findByUserId(newUser.Id);

    System.assertEquals(
      userData.identifier,
      newUser.EmployeeNumber,
      'Employee number not set correctly'
    );
  }

  /**
   * @description Create a user mock information to test the user in negative test scenarios
   *
   * @return Auth.UserData details
   */
  private static Auth.UserData createRandomUserData() {
    return new Auth.UserData(
      CMN_DAL_SObjectDomain.generateRandomName(), //Identifier
      CMN_DAL_SObjectDomain.generateRandomName(), //FirstName
      CMN_DAL_SObjectDomain.generateRandomName(), //LostName
      CMN_DAL_SObjectDomain.generateRandomName(), //FullName
      CMN_DAL_SObjectDomain.generateRandomEmail(), //Email
      CMN_DAL_SObjectDomain.generateRandomName(), //Link
      CMN_DAL_SObjectDomain.generateRandomEmail(), //UserName
      CMN_DAL_SObjectDomain.generateRandomName(), //Locale
      CMN_DAL_SObjectDomain.generateRandomName(), //Provider
      CMN_DAL_SObjectDomain.generateRandomName(), //SiteLoginUrl
      new Map<String, String>()
    ); //AttributeMap
  }

  /**
   * @description Create a user mock information to test the user in positive test scenarios (based off user record)
   *
   * @param newUser user record used to populate the mock user data
   *
   * @return Auth.UserData details
   */
  private static Auth.UserData createUserData(User newUser) {
    Map<String, String> attributeMap = new Map<String, String>();

    /* attribute map is used to carry auth values across methods */
    attributeMap.put(
      CMN_AUTH_PingStaff.TOKEN_TYPE,
      CMN_AUTH_PingStaff.TOKEN_TYPE_BEARER
    );
    attributeMap.put(
      CMN_AUTH_PingStaff.ACCESS_TOKEN,
      CMN_DAL_SObjectDomain.generateRandomName()
    );
    attributeMap.put(
      CMN_AUTH_PingStaff.REFRESH_TOKEN,
      CMN_DAL_SObjectDomain.generateRandomName()
    );
    attributeMap.put(
      CMN_AUTH_PingStaff.ID_TOKEN,
      CMN_DAL_SObjectDomain.generateRandomName()
    );
    attributeMap.put(
      CMN_AUTH_PingStaff.EXPIRES_IN,
      String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger())
    );

    return new Auth.UserData(
      CMN_DAL_SObjectDomain.generateRandomNumber(), //Identifier
      newUser.FirstName, //FirstName
      newUser.LastName, //LastName
      newUser.Name, //FullName
      newUser.Email, //Email
      CMN_DAL_SObjectDomain.generateRandomName(), //Link
      newUser.Username, //UserName
      newUser.LanguageLocaleKey, //Locale
      CMN_AUTH_PingStaff.PROVIDER_NAME, //Provider
      CMN_DAL_SObjectDomain.generateRandomName(), //SiteLoginUrl
      attributeMap
    ); //AttributeMap
  }
}