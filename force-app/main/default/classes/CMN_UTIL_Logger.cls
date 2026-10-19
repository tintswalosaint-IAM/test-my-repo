/**
 * @description Class allow logging at an instance level
 * <p/>
 *
 * @author originally provided by mlockett @ https://github.com/mlockett/ApexLogger
 *
 * @date 2019-01-15
 */
public without sharing class CMN_UTIL_Logger {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_UTIL_Logger');
	/**
	* @description writes log with message data
	*
	* @param message message to be logged
	* @param classMethod <class>.<method> if applicable
	*/
	public static void debug(String message, String classMethod) {
		//CMN_DAL_Logger.log(message, classMethod, LoggingLevel.DEBUG);
		LOGGER.debug(classMethod + '|' + message);
	}

  	/**
   	* @description writes log with message data
   	*
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	* @param affectedId record Id(s) related to log event
   	*/
	public static void debug(String message, String classMethod, String affectedId) {
    	//CMN_DAL_Logger.log(message, classMethod, affectedId, LoggingLevel.DEBUG);
		LOGGER.debug(classMethod + '|' + affectedId + '|' + message);
  	}

  	/**
   	* @description writes log with message data
   	*
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	*/
	public static void info(String message, String classMethod) {
		//CMN_DAL_Logger.log(message, classMethod, LoggingLevel.INFO);
		LOGGER.info(classMethod + '|' + message);
	}

  	/**
   	* @description writes log with message data
   	*
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	*/
	public static void warn(String message, String classMethod) {
    	//CMN_DAL_Logger.log(message, classMethod, LoggingLevel.WARN);
		LOGGER.warn(classMethod + '|' + message);
  	}

  	/**
   	* @description writes log with message data
   	*
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	* @param affectedId record Id(s) related to log event
   	*/
  	public static void warn(String message, String classMethod, String affectedId) {
    	//CMN_DAL_Logger.log(message, classMethod, affectedId, LoggingLevel.WARN);
		LOGGER.warn(classMethod + '|' + affectedId + '|' + message);
  	}

  	/**
   	* @description Write error with exception data
   	*
   	* @param ex exception to log
   	* @param classMethod <class>.<method> if applicable
   	*/
  	public static void error(Exception ex, String classMethod) {
		//CMN_DAL_Logger.log(ex, classMethod, LoggingLevel.ERROR);
		LOGGER.error(classMethod, ex);
  	}

  	/**
   	* @description Write error with exception data
   	*
   	* @param ex exception to log
   	* @param classMethod <class>.<method> if applicable
   	* @param affectedId record Id(s) related to log event
   	*/
  	public static void error(Exception ex, String classMethod, String affectedId) {
		//CMN_DAL_Logger.log(ex, classMethod, affectedId, LoggingLevel.ERROR);
		LOGGER.error(classMethod+'|'+affectedId, ex);
  	}

  	/**
   	* @description writes log with message data
   	*
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	*/
  	public static void error(String message, String classMethod) {
		//CMN_DAL_Logger.log(message, classMethod, LoggingLevel.ERROR);
		LOGGER.error(classMethod+'|'+message);
  	}

  	/**
   	* @description writes log with message data
   	*
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	*/
  	public static void error(String message, String classMethod, String affectedId) {
		//CMN_DAL_Logger.log(message, classMethod, affectedId, LoggingLevel.ERROR);
		LOGGER.error(classMethod+'|'+affectedId+'|'+message);
  	}

  	/**
   	* @description writes log with message
   	*
   	* @param shortMessage title message, short-end or simplified message
   	* @param message message to be logged
   	* @param classMethod <class>.<method> if applicable
   	* @param recordId if applicable
   	* @param ex if applicable
   	*/
  	public static void error(String shortMessage, String message, String classMethod, String recordId, Exception ex) {
		//CMN_DAL_Logger.log(shortMessage, message, classMethod, recordId, ex, LoggingLevel.ERROR);
		LOGGER.error(classMethod + '|' + recordId + '|' + shortMessage + '|' + message, ex);
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
		List<CMN_LogMessageFilter__mdt> messageFilters = null;
		if(messageFilters == null) {
			messageFilters = [
				SELECT CMN_RegexToFind__c, CMN_RegexToReplaceWith__c
				FROM CMN_LogMessageFilter__mdt
				WHERE CMN_Active__c = TRUE
			];
		}
    	return messageFilters;
  	}
}