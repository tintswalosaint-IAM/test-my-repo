/**
 * @description Tests the behaviour of the logger
 * <p/>
 * <p>VCCC-378</p>
 *
 * @see CMN_DAL_Logger
 *
 * @author Accenture
originally provided by mlockett @ https://github.com/mlockett/ApexLogger
 */
@IsTest(SeeAllData=false)
private class CMN_DAL_Logger_TEST {
  private static final String RECORD_ID = CMN_UTIL_Random.randomSObjectId(
    CMN_Foobar__c.SObjectType
  );
  private static final String MESSAGE = CMN_DAL_SObjectDomain.generateRandomName();
  private static final String CLASS_METHOD = 'CMN_Foobar.method';

  private static void testSetup() {
    CMN_DAL_Logger.testUserFilters = new List<CMN_LogUserFilter__mdt>();

    CMN_LogUserFilter__mdt filter = new CMN_LogUserFilter__mdt();

    filter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
    filter.CMN_UserType__c = CMN_DAL_Logger.TYPE_ALL_USERS;
    filter.CMN_LogUser__c = CMN_DAL_Logger.ALL_USERS;
    filter.CMN_Active__c = true;

    CMN_DAL_Logger.testUserFilters.add(filter);
  }

  /**
   * @description verifies that determining ability to log does not throw when test recordFilters are not supplied
   */
  @IsTest
  private static void canQueryForLoggable() {
    // clear test values
    CMN_DAL_Logger.testUserFilters = null;
    CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG);
  }

  @IsTest
  private static void filtersLogRecordCorrectly() {
    testSetup();

    CMN_DAL_Logger.testUserFilters[0].CMN_LogLevel__c =
      CMN_DAL_Logger.LEVEL_INFO +
      ',' +
      CMN_DAL_Logger.LEVEL_WARN;

    Test.startTest();

    CMN_DAL_Logger.debug(MESSAGE, CLASS_METHOD);

    Test.stopTest();

    List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.getAll();

    System.assertEquals(0, appLogs.size());
  }

  @IsTest
  private static void filtersLogRecordCorrectlyWithNullFilter() {
    testSetup();

    CMN_DAL_Logger.testUserFilters[0].CMN_LogLevel__c = null;

    Test.startTest();

    CMN_DAL_Logger.debug(MESSAGE, CLASS_METHOD);

    Test.stopTest();

    List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.getAll();

    System.assertEquals(0, appLogs.size());
  }

  @IsTest
  private static void verifyFilter() {
    testSetup();

    CMN_LogMessageFilter__mdt filter = new CMN_LogMessageFilter__mdt();

    filter.CMN_RegexToReplaceWith__c = '***-**-$3';
    filter.CMN_RegexToFind__c = '(\\d{3})-(\\d{2})-(\\d{4})';

    CMN_DAL_Logger.messageFilters = new List<CMN_LogMessageFilter__mdt>(); //[filter1];
    CMN_DAL_Logger.messageFilters.add(filter);

    String textToObscure = 'Hide the 123-12-1234 SSN.';
    String expectedText = 'Hide the ***-**-1234 SSN.';

    System.assertEquals(
      expectedText,
      CMN_DAL_Logger.filterString(textToObscure)
    );
  }

  @IsTest
  private static void logWritesCorrectValues() {
    testSetup();

    CMN_DAL_Logger.ignoreTestMode = true;
    Test.startTest();
    CMN_DAL_Logger.log(MESSAGE, CLASS_METHOD, LoggingLevel.WARN);
    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assertEquals(MESSAGE, appLog.CMN_Message__c);
    System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void invocableInfoWritesCorrectValues() {
    testSetup();

    List<String> messages = new List<String>{ 'a', 'b', 'c' };
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();

    CMN_DAL_Logger.info(messages);

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.getAll()[0];

    // for reasons currently unclear, Salesforce seems to truncate the final \n :-(
    String expected = 'a;\nb;\nc;';

    System.assertEquals(expected, appLog.CMN_Message__c);
    System.assertEquals(CMN_DAL_Logger.LEVEL_INFO, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void infoWritesCorrectValues() {
    testSetup();
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();

    CMN_DAL_Logger.info(MESSAGE, CLASS_METHOD);

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assertEquals(MESSAGE, appLog.CMN_Message__c);
    System.assertEquals(CMN_DAL_Logger.LEVEL_INFO, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void debugWritesCorrectValues() {
    testSetup();

    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();

    CMN_DAL_Logger.debug(MESSAGE, CLASS_METHOD);

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assertEquals(MESSAGE, appLog.CMN_Message__c);
    System.assertEquals(CMN_DAL_Logger.LEVEL_DEBUG, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void warnWritesCorrectValues() {
    testSetup();
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();

    CMN_DAL_Logger.warn(MESSAGE, CLASS_METHOD);

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assertEquals(MESSAGE, appLog.CMN_Message__c);
    System.assertEquals(CMN_DAL_Logger.LEVEL_WARN, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void errorWritesCorrectValues() {
    testSetup();
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();

    CMN_DAL_Logger.error(MESSAGE, CLASS_METHOD);

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assertEquals(MESSAGE, appLog.CMN_Message__c);
    System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void errorWritesCorrectValuesForException() {
    testSetup();
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();
    try {
      //noinspection ApexUnusedDeclaration
      Double badNumber = 1 / 0; // force MathException
    } catch (Exception ex) {
      System.assert(CMN_DAL_Logger.getExceptionString(ex) != null);
      CMN_DAL_Logger.error(ex, CLASS_METHOD);
    }

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assert(appLog.CMN_ExceptionType__c.equals('System.MathException'));
    System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void errorWithIdWritesCorrectValuesForException() {
    testSetup();
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();
    try {
      //noinspection ApexUnusedDeclaration
      Double badNumber = 1 / 0; // force MathException
    } catch (Exception ex) {
      CMN_DAL_Logger.error(ex, CLASS_METHOD, RECORD_ID);
    }

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assert(appLog.CMN_ExceptionType__c.equals('System.MathException'));
    System.assertEquals(CMN_DAL_Logger.LEVEL_ERROR, appLog.CMN_LogLevel__c);
    System.assertEquals(RECORD_ID, appLog.CMN_RecordId__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void logWritesCorrectValuesForException() {
    testSetup();
    CMN_DAL_Logger.ignoreTestMode = true;

    Test.startTest();
    try {
      //noinspection ApexUnusedDeclaration
      Double badNumber = 1 / 0; // force MathException
    } catch (Exception ex) {
      CMN_DAL_Logger.log(ex, CLASS_METHOD, LoggingLevel.DEBUG);
    }

    Test.stopTest();

    CMN_AppLog__c appLog = CMN_DAL_AppLog.findByMethod(CLASS_METHOD);

    System.assert(appLog.CMN_ExceptionType__c.equals('System.MathException'));
    System.assertEquals(CMN_DAL_Logger.LEVEL_DEBUG, appLog.CMN_LogLevel__c);
    System.assertEquals(UserInfo.getUserId(), appLog.CMN_UserId__c);
  }

  @IsTest
  private static void errorDoesNotThrow() {
    testSetup();
    String tooLong =
      '12345678901234567890123456789012345678901234567890' +
      '12345678901234567890123456789012345678901234567890' +
      '12345678901234567890123456789012345678901234567890' +
      '12345678901234567890123456789012345678901234567890';

    Test.startTest();

    CMN_DAL_Logger.warn('errorDoesNotThrow_message', tooLong);

    Test.stopTest();

    List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findByLogLevel(
      CMN_DAL_Logger.LEVEL_WARN
    );

    System.assertEquals(0, appLogs.size());
  }

  @IsTest
  private static void logFailsSansIgnoreTestMode() {
    testSetup();

    Test.startTest();

    CMN_DAL_Logger.log(MESSAGE, CLASS_METHOD, LoggingLevel.DEBUG);

    Test.stopTest();

    List<CMN_AppLog__c> appLogs = CMN_DAL_AppLog.findAllByMethod(CLASS_METHOD);

    System.assertEquals(0, appLogs.size());
  }

  @IsTest
  private static void badEventGeneratesError() {
    testSetup();

    CMN_DAL_Logger.ignoreTestMode = true;

    String tooLong =
      '12345678901234567890123456789012345678901234567890' +
      '12345678901234567890123456789012345678901234567890' +
      '12345678901234567890123456789012345678901234567890' +
      '12345678901234567890123456789012345678901234567890';

    CMN_AppLogEvent__e event = new CMN_AppLogEvent__e();
    event.CMN_ClassMethod__c = tooLong;

    Test.startTest();

    List<Database.Error> errors = CMN_DAL_Logger.publishEvent(event);

    Test.stopTest();

    System.assertEquals(1, errors.size());
  }

  @IsTest
  private static void isLoggable() {
    CMN_DAL_Logger.testUserFilters = new List<CMN_LogUserFilter__mdt>();

    CMN_LogUserFilter__mdt userIdFilter = new CMN_LogUserFilter__mdt();
    CMN_LogUserFilter__mdt emailFilter = new CMN_LogUserFilter__mdt();
    CMN_LogUserFilter__mdt usernameFilter = new CMN_LogUserFilter__mdt();

    // userId filter
    userIdFilter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
    userIdFilter.CMN_UserType__c = CMN_DAL_Logger.TYPE_USER_ID;
    userIdFilter.CMN_LogUser__c = UserInfo.getUserId();
    userIdFilter.CMN_Active__c = true;

    // email filter
    emailFilter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
    emailFilter.CMN_UserType__c = CMN_DAL_Logger.TYPE_EMAIL;
    emailFilter.CMN_LogUser__c = UserInfo.getUserEmail();
    emailFilter.CMN_Active__c = true;

    // username filter
    usernameFilter.CMN_LogLevel__c = CMN_DAL_Logger.ALL_LOG_LEVELS;
    usernameFilter.CMN_UserType__c = CMN_DAL_Logger.TYPE_USERNAME;
    usernameFilter.CMN_LogUser__c = UserInfo.getUserName();
    usernameFilter.CMN_Active__c = true;

    Test.startTest();

    // test user id scenarios
    CMN_DAL_Logger.testUserFilters.add(userIdFilter);

    System.assert(CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

    userIdFilter.CMN_LogUser__c = CMN_DAL_SObjectDomain.generateRandomSObjectId(
      User.SObjectType
    );

    System.assert(!CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

    // test user email scenarios
    CMN_DAL_Logger.testUserFilters.clear();
    CMN_DAL_Logger.testUserFilters.add(emailFilter);

    System.assert(CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

    emailFilter.CMN_LogUser__c = CMN_DAL_SObjectDomain.generateRandomEmail();

    System.assert(!CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

    // test user email scenarios
    CMN_DAL_Logger.testUserFilters.clear();
    CMN_DAL_Logger.testUserFilters.add(usernameFilter);

    System.assert(CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

    usernameFilter.CMN_LogUser__c = CMN_DAL_SObjectDomain.generateRandomName();

    System.assert(!CMN_DAL_Logger.isLoggable(LoggingLevel.DEBUG));

    Test.stopTest();
  }
}