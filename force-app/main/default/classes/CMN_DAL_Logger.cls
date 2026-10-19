/**
 * @description For writing persistent logs using platform events
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author originally provided by mlockett @ https://github.com/mlockett/ApexLogger
Accenture
 *
 * @date 2018-06-16
 */
global without sharing class CMN_DAL_Logger {
  private static final String LINE_SEPARATOR = '\n';
  private static final String MESSAGE_DELIMITER = ';' + LINE_SEPARATOR;
  private static final String INVOCABLE_METHOD = 'Invocable';

  @TestVisible
  private static final String TYPE_ALL_USERS = 'All';
  @TestVisible
  private static final String TYPE_USER_ID = 'UserId';
  @TestVisible
  private static final String TYPE_USERNAME = 'Username';
  @TestVisible
  private static final String TYPE_EMAIL = 'Email';
  @TestVisible
  private static final String ALL_USERS = '*';
  @TestVisible
  private static final String LEVEL_WARN = LoggingLevel.WARN.name();
  @TestVisible
  private static final String LEVEL_DEBUG = LoggingLevel.DEBUG.name();
  @TestVisible
  private static final String LEVEL_ERROR = LoggingLevel.ERROR.name();
  @TestVisible
  private static final String LEVEL_INFO = LoggingLevel.INFO.name();
  @TestVisible
  private static final String ALL_LOG_LEVELS =
    LEVEL_INFO +
    ',' +
    LEVEL_DEBUG +
    ',' +
    LEVEL_WARN +
    ',' +
    LEVEL_ERROR;
  @TestVisible
  private static final Map<Id, List<CMN_LogUserFilter__mdt>> userIdLogUserFilterMap = new Map<Id, List<CMN_LogUserFilter__mdt>>();

  /**
   * @description When test is running, event will not be published unless ignoreTestMode is set to true
   */
  @TestVisible
  private static Boolean ignoreTestMode { get; set; }
  static {
    ignoreTestMode = false;
  }

  // note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow testing
  // different metadata
  @TestVisible
  private static List<CMN_LogMessageFilter__mdt> messageFilters = null;

  // note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow testing
  // different metadata
  @TestVisible
  private static List<CMN_LogUserFilter__mdt> testUserFilters = null;

  /**
   * @description Enables logging to be called from Process Builder
   *
   * @param messages because PB can insert/update multiple records, method takes a list which is concatenated
   */
  @InvocableMethod(
    Label='Write Log'
    Description='Writes desired data to the Application Log'
  )
  global static void info(List<String> messages) {
    String messageString = CMN_UTIL_String.EMPTY;

    for (String message : messages) {
      messageString += message + MESSAGE_DELIMITER;
    }

    CMN_DAL_Logger.log(messageString, INVOCABLE_METHOD, LoggingLevel.INFO);
  }

  /**
   * @description simplest info logging interface
   *
   * @param message as input
   * @param classMethod as input (where logging occurred)
   */
  global static void info(String message, String classMethod) {
    CMN_DAL_Logger.log(message, classMethod, LoggingLevel.INFO);
  }

  /**
   * @description writes log with message data
   *
   * @param message message to be logged
   * @param classMethod <class>.<method> if applicable
   */
  global static void debug(String message, String classMethod) {
    CMN_DAL_Logger.log(message, classMethod, LoggingLevel.DEBUG);
  }

  /**
   * @description writes log with message data
   *
   * @param message message to be logged
   * @param classMethod <class>.<method> if applicable
   */
  global static void warn(String message, String classMethod) {
    CMN_DAL_Logger.log(message, classMethod, LoggingLevel.WARN);
  }

  /**
   * @description Write error with exception data
   *
   * @param ex Exception to log
   * @param classMethod <class>.<method> if applicable
   */
  global static void error(Exception ex, String classMethod) {
    CMN_DAL_Logger.log(ex, classMethod, LoggingLevel.ERROR);
  }

  /**
   * @description Write error with exception data
   *
   * @param ex Exception to log
   * @param classMethod <class>.<method> if applicable
   * @param recordId record Id(s) related to log event
   */
  global static void error(Exception ex, String classMethod, String recordId) {
    CMN_DAL_Logger.log(ex, classMethod, recordId, LoggingLevel.ERROR);
  }

  /**
   * @description writes log with message data
   *
   * @param message message to be logged
   * @param classMethod <class>.<method> if applicable
   */
  global static void error(String message, String classMethod) {
    CMN_DAL_Logger.log(message, classMethod, LoggingLevel.ERROR);
  }

  /**
   * @description Returns consistent string for exception message
   *
   * @param ex the exception to retrieve text for
   *
   * @return desired text from exception
   */
  @TestVisible
  private static String getExceptionString(Exception ex) {
    return ex == null
      ? null
      : 'Exception - Type: ' +
        ex.getTypeName() +
        '; Line: ' +
        ex.getLineNumber() +
        '; Message: ' +
        ex.getMessage() +
        '; Stacktrace: ' +
        ex.getStackTraceString();
  }

  /**
   * @description publishes event... optionally suppresses when in test... deals with errors
   *
   * @param event CMN_AppLogEvent__e event to be published
   *
   * @return A List of database errors
   */
  @TestVisible
  private static List<Database.Error> publishEvent(CMN_AppLogEvent__e event) {
    // don't publish event during unit tests unless ignoreTestMode is true
    if (!ignoreTestMode && Test.isRunningTest()) {
      return null;
    }

    Database.SaveResult saveResult = EventBus.publish(event);

    // Inspect publishing result
    if (saveResult.isSuccess()) {
      System.debug(
        LoggingLevel.DEBUG,
        'Successfully published event: ' + event
      );
    } else {
      for (Database.Error err : saveResult.getErrors()) {
        System.debug(
          LoggingLevel.ERROR,
          'Error returned: ' +
          err.getStatusCode() +
          ' - ' +
          err.getMessage()
        );
      }

      return saveResult.getErrors();
    }

    return null;
  }

  /**
   * @description writes log with message
   *
   * @param message message to be logged
   * @param classMethod <class>.<method> if applicable
   * @param logLevel the System.LoggingLevel to log as
   */
  public static void log(
    String message,
    String classMethod,
    System.LoggingLevel logLevel
  ) {
    log(message, classMethod, null, logLevel);
  }

  /**
   * @description writes log with message
   *
   * @param message message to be logged
   * @param classMethod <class>.<method> if applicable
   * @param recordId record Id(s) related to log event
   * @param logLevel the System.LoggingLevel to log as
   */
  public static void log(
    String message,
    String classMethod,
    String recordId,
    System.LoggingLevel logLevel
  ) {
    log(null, message, classMethod, recordId, null, logLevel);
  }

  /**
   * @description writes log with message
   *
   * @param shortMessage title message, short-end or simplified message
   * @param message message to be logged
   * @param classMethod <class>.<method> if applicable
   * @param recordId if applicable
   * @param ex if applicable
   * @param logLevel the System.LoggingLevel to log as
   */
  public static void log(
    String shortMessage,
    String message,
    String classMethod,
    String recordId,
    Exception ex,
    System.LoggingLevel logLevel
  ) {
    Id userId = UserInfo.getUserId();

    // check if entry should be logged for current user
    if (!isLoggable(logLevel)) {
      return;
    }

    CMN_AppLogEvent__e event = new CMN_AppLogEvent__e();

    event.CMN_ClassMethod__c = classMethod;
    event.CMN_Cause__c = ex != null ? getExceptionString(ex.getCause()) : null;
    event.CMN_ExceptionType__c = ex != null ? ex.getTypeName() : null;
    event.CMN_LineNumber__c = ex != null ? ex.getLineNumber() : null;
    event.CMN_LogLevel__c = logLevel.name();
    event.CMN_Limits__c = ((logLevel == LoggingLevel.DEBUG ||
      ex != null)
      ? getDebugLimits()
      : null);
    event.CMN_Message__c = message != null
      ? message
      : (ex != null ? ex.getMessage() : null);
    event.CMN_RecordId__c = recordId;
    event.CMN_ShortMessage__c = shortMessage;
    event.CMN_StackTrace__c = ex != null ? ex.getStackTraceString() : null;
    event.CMN_UserId__c = userId;

    publishEvent(event);
  }

  /**
   * @description writes log with exception data
   *
   * @param ex the exception to be logged
   * @param classMethod <class>.<method> if applicable
   * @param logLevel the System.LoggingLevel to log as
   */
  public static void log(
    Exception ex,
    String classMethod,
    System.LoggingLevel logLevel
  ) {
    CMN_DAL_Logger.log(ex, classMethod, null, logLevel);
  }

  /**
   * @description writes log with exception data
   *
   * @param ex the exception to be logged
   * @param classMethod <class>.<method> if applicable
   * @param recordId record Id(s) related to log event
   * @param logLevel the System.LoggingLevel to log as
   */
  public static void log(
    Exception ex,
    String classMethod,
    String recordId,
    System.LoggingLevel logLevel
  ) {
    CMN_DAL_Logger.log(null, null, classMethod, recordId, ex, logLevel);
  }

  /**
   * @description Filters string based on CMN_LogFilter__mdt or optionally testFilters
   *
   * @param inputString The string to search and replace against
   *
   * @return string with replacements made for all active filters
   */
  public static String filterString(String inputString) {
    List<CMN_LogMessageFilter__mdt> filters = getMessageFilters();

    for (CMN_LogMessageFilter__mdt filter : filters) {
      inputString = inputString.replaceAll(
        filter.CMN_RegexToFind__c,
        filter.CMN_RegexToReplaceWith__c
      );
    }

    return inputString;
  }

  /**
   * @description retrieve the message filters
   *
   * @return list of message filters
   */
  private static List<CMN_LogMessageFilter__mdt> getMessageFilters() {
    // note: because Salesforce doesn't allow creating custom metadata in tests,
    // we're doing a workaround to allow test to set expected metadata
    if (messageFilters == null) {
      messageFilters = [
        SELECT CMN_RegexToFind__c, CMN_RegexToReplaceWith__c
        FROM CMN_LogMessageFilter__mdt
        WHERE CMN_Active__c = TRUE
      ];
    }

    return messageFilters;
  }

  /**
   * @description determines whether entry should be logged based on user and log level using CMN_LogUserFilter__mdt
   *
   * @param logLevel The logging level for the log
   *
   * @return Whether the entry should be logged
   */
  public static Boolean isLoggable(LoggingLevel logLevel) {
    List<CMN_LogUserFilter__mdt> userFilters = getLogUserFilters();

    String strLogLevel = logLevel.name();

    for (CMN_LogUserFilter__mdt filter : userFilters) {
      if (filter.CMN_LogLevel__c == null) {
        continue;
      }

      // splits on comma space or comma
      List<String> logLevels = filter.CMN_LogLevel__c.split(', |,');

      // check if user log should be recorded
      if (
        logLevels.contains(strLogLevel) &&
        (filter.CMN_UserType__c.equals(TYPE_ALL_USERS) ||
        filter.CMN_LogUser__c.equals(ALL_USERS) ||
        (filter.CMN_UserType__c.equals(TYPE_USER_ID) &&
        filter.CMN_LogUser__c.equals(UserInfo.getUserId())) ||
        (filter.CMN_UserType__c.equals(TYPE_USERNAME) &&
        filter.CMN_LogUser__c.equalsIgnoreCase(UserInfo.getUserName()) ||
        filter.CMN_UserType__c.equals(TYPE_EMAIL) &&
        filter.CMN_LogUser__c.equalsIgnoreCase(UserInfo.getUserEmail())))
      ) {
        return true;
      }
    }

    return false;
  }

  /**
   * @description gets CMN_LogUserFilter__mdt for current user and for * (all users)
   *
   * @return A list of record filters
   */
  private static List<CMN_LogUserFilter__mdt> getLogUserFilters() {
    if (testUserFilters != null) {
      return testUserFilters;
    }

    final Id userId = UserInfo.getUserId();
    final String username = UserInfo.getUserName();
    final String email = UserInfo.getUserEmail();

    /* check if resolved for user before access temporary in memory cache */
    List<CMN_LogUserFilter__mdt> userFilters = userIdLogUserFilterMap.get(
      userId
    );

    if (userFilters == null) {
      // mdt doesn't support disjunction OR queries so retrieve potential matches and filter
      userFilters = [
        SELECT
          Id,
          CMN_LogLevel__c,
          CMN_UserType__c,
          CMN_LogUser__c,
          CMN_Active__c
        FROM CMN_LogUserFilter__mdt
        WHERE
          CMN_LogUser__c IN (:ALL_USERS, :userId, :username, :email)
          AND CMN_Active__c = TRUE
        ORDER BY CMN_LogUser__c
      ];

      /* update in memory cache for user */
      userIdLogUserFilterMap.put(userId, userFilters);
    }

    return userFilters;
  }

  /**
   * @description returns limits for debugging and error tracing purposes
   *
   * @return debug limits
   */
  private static String getDebugLimits() {
    return (LINE_SEPARATOR +
    'AggregateQueries: ' +
    Limits.getAggregateQueries() +
    ' of ' +
    Limits.getLimitAggregateQueries() +
    LINE_SEPARATOR +
    'Callouts: ' +
    Limits.getCallouts() +
    ' of ' +
    Limits.getLimitCallouts() +
    LINE_SEPARATOR +
    'CPU Time: ' +
    Limits.getCpuTime() +
    ' of ' +
    Limits.getLimitCpuTime() +
    LINE_SEPARATOR +
    'Database Time: ' +
    Limits.getDatabaseTime() +
    ' of ' +
    Limits.getLimitDatabaseTime() +
    LINE_SEPARATOR +
    'DMLRows: ' +
    Limits.getDmlRows() +
    ' of ' +
    Limits.getLimitDmlRows() +
    LINE_SEPARATOR +
    'DMLStatements: ' +
    Limits.getDmlStatements() +
    ' of ' +
    Limits.getLimitDmlStatements() +
    LINE_SEPARATOR +
    'EmailInvocations: ' +
    Limits.getEmailInvocations() +
    ' of ' +
    Limits.getLimitEmailInvocations() +
    LINE_SEPARATOR +
    'FindSimilarCalls: ' +
    Limits.getFindSimilarCalls() +
    ' of ' +
    Limits.getLimitFindSimilarCalls() +
    LINE_SEPARATOR +
    'FutureCalls: ' +
    Limits.getFutureCalls() +
    ' of ' +
    Limits.getLimitFutureCalls() +
    LINE_SEPARATOR +
    'HeapSize: ' +
    Limits.getHeapSize() +
    ' of ' +
    Limits.getLimitHeapSize() +
    LINE_SEPARATOR +
    'MobilePushApexCalls: ' +
    Limits.getMobilePushApexCalls() +
    ' of ' +
    Limits.getLimitMobilePushApexCalls() +
    LINE_SEPARATOR +
    'PublishImmediateDML: ' +
    Limits.getPublishImmediateDML() +
    ' of ' +
    Limits.getLimitPublishImmediateDML() +
    LINE_SEPARATOR +
    'Queries: ' +
    Limits.getQueries() +
    ' of ' +
    Limits.getLimitQueries() +
    LINE_SEPARATOR +
    'QueryLocatorRows: ' +
    Limits.getQueryLocatorRows() +
    ' of ' +
    Limits.getLimitQueryLocatorRows() +
    LINE_SEPARATOR +
    'QueryRows: ' +
    Limits.getQueryRows() +
    ' of ' +
    Limits.getLimitQueryRows() +
    LINE_SEPARATOR +
    'QueueableJobs: ' +
    Limits.getQueueableJobs() +
    ' of ' +
    Limits.getLimitQueueableJobs() +
    LINE_SEPARATOR +
    'RunAs: ' +
    Limits.getRunAs() +
    ' of ' +
    Limits.getLimitRunAs() +
    LINE_SEPARATOR +
    'SavepointRollbacks: ' +
    Limits.getSavepointRollbacks() +
    ' of ' +
    Limits.getLimitSavepointRollbacks() +
    LINE_SEPARATOR +
    'Savepoints: ' +
    Limits.getSavepoints() +
    ' of ' +
    Limits.getLimitSavepoints() +
    LINE_SEPARATOR +
    'SoslQueries: ' +
    Limits.getSoslQueries() +
    ' of ' +
    Limits.getLimitSoslQueries());
  }
}