/**
 * @description Provides Query methods related to the AppLog object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_AppLog {
  private static final String OBJECT_NAME = CMN_AppLog__c.SObjectType.getDescribe()
    .getLocalName();

  private static final String FIELD_ID = CMN_AppLog__c.Id.getDescribe()
    .getLocalName();
  private static final String FIELD_NAME = CMN_AppLog__c.Name.getDescribe()
    .getLocalName();
  private static final String FIELD_CAUSE = CMN_AppLog__c.CMN_Cause__c.getDescribe()
    .getLocalName();
  private static final String FIELD_CLASS_METHOD = CMN_AppLog__c.CMN_ClassMethod__c.getDescribe()
    .getLocalName();
  private static final String FIELD_EXCEPTION_TYPE = CMN_AppLog__c.CMN_ExceptionType__c.getDescribe()
    .getLocalName();
  private static final String FIELD_LIMITS = CMN_AppLog__c.CMN_Limits__c.getDescribe()
    .getLocalName();
  private static final String FIELD_LINE_NUMBER = CMN_AppLog__c.CMN_LineNumber__c.getDescribe()
    .getLocalName();
  private static final String FIELD_LOG_LEVEL = CMN_AppLog__c.CMN_LogLevel__c.getDescribe()
    .getLocalName();
  private static final String FIELD_MESSAGE = CMN_AppLog__c.CMN_Message__c.getDescribe()
    .getLocalName();
  private static final String FIELD_RECORD_ID = CMN_AppLog__c.CMN_RecordId__c.getDescribe()
    .getLocalName();
  private static final String FIELD_SHORT_MESSAGE = CMN_AppLog__c.CMN_ShortMessage__c.getDescribe()
    .getLocalName();
  private static final String FIELD_STACK_TRACE = CMN_AppLog__c.CMN_StackTrace__c.getDescribe()
    .getLocalName();
  private static final String FIELD_USER_ID = CMN_AppLog__c.CMN_UserId__c.getDescribe()
    .getLocalName();

  /**
   * @description Will return base fields to return on a query
   *
   * @return A list of AppLog fields
   */
  @TestVisible
  private static Set<String> getDefaultFields() {
    return new Set<String>{
      FIELD_ID,
      FIELD_NAME,
      FIELD_CAUSE,
      FIELD_CLASS_METHOD,
      FIELD_EXCEPTION_TYPE,
      FIELD_LIMITS,
      FIELD_LINE_NUMBER,
      FIELD_LOG_LEVEL,
      FIELD_MESSAGE,
      FIELD_RECORD_ID,
      FIELD_SHORT_MESSAGE,
      FIELD_STACK_TRACE,
      FIELD_USER_ID
    };
  }

  /**
   * @description Will find all AppLog objects based on method
   *
   * @param classMethod The class method to use in the query
   *
   * @return Either null or a single AppLog Object
   */
  @TestVisible
  private static List<CMN_AppLog__c> findAllByMethod(String classMethod) {
    return CMN_DAL_SObjectSelector.findByField(
      OBJECT_NAME,
      FIELD_CLASS_METHOD,
      new Set<String>{ classMethod },
      getDefaultFields()
    );
  }

  /**
   * @description Will find a Single AppLog object based on method
   *
   * @param classMethod The class method to use in the query
   *
   * @return Either null or a single AppLog Object
   */
  @TestVisible
  private static CMN_AppLog__c findByMethod(String classMethod) {
    List<CMN_AppLog__c> logs = findAllByMethod(classMethod);
    return logs.isEmpty() ? null : logs[0];
  }

  /**
   * @description Will return all the AppLog objects in the system
   *
   * @return A list of AppLog objects
   */
  @TestVisible
  private static List<CMN_AppLog__c> getAll() {
    return CMN_DAL_Search.getAll(CMN_AppLog__c.SObjectType);
  }

  /**
   * @description Will find all AppLog objects based on logging level
   *
   * @param logLevel The level to filter on
   *
   * @return A list of AppLog objects
   */
  @TestVisible
  private static List<CMN_AppLog__c> findByLogLevel(String logLevel) {
    return CMN_DAL_SObjectSelector.findByField(
      OBJECT_NAME,
      FIELD_LOG_LEVEL,
      new Set<String>{ logLevel },
      getDefaultFields()
    );
  }
}