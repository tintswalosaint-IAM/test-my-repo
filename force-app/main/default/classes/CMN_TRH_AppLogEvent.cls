/**
 * @description Trigger handler on the App Log Platform Event
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_TRH_AppLogEvent extends CMN_TRH_BaseObject {

  	private final static Integer SHORT_MESSAGE_LEN = CMN_AppLogEvent__e.CMN_ShortMessage__c.getDescribe().length;
  	private List<CMN_AppLog__c> entriesToInsert = new List<CMN_AppLog__c>();

	/**
	* @description Will ensure that the event raised is logged to appropriate object
	*
	* @param so The platform event insert
	*/
  	public override void afterInsert(SObject so) {
    	super.afterInsert(so);
    	CMN_AppLogEvent__e event = (CMN_AppLogEvent__e) so;
		String message = event.CMN_Message__c;
		//message = CMN_DAL_Logger.filterString(message);
    	message = CMN_UTIL_Logger.filterString(message);

    	CMN_AppLog__c logEntry = new CMN_AppLog__c();

		logEntry.CMN_ClassMethod__c = event.CMN_ClassMethod__c;
		logEntry.CMN_Cause__c = event.CMN_Cause__c;
		logEntry.CMN_ExceptionType__c = event.CMN_ExceptionType__c;
		logEntry.CMN_Limits__c = event.CMN_Limits__c;
		logEntry.CMN_LineNumber__c = event.CMN_LineNumber__c;
		logEntry.CMN_LogLevel__c = event.CMN_LogLevel__c;
		logEntry.CMN_Message__c = message;
		logEntry.CMN_RecordId__c = event.CMN_RecordId__c;
		logEntry.CMN_ShortMessage__c = event.CMN_ShortMessage__c == null
		? CMN_UTIL_String.abbreviate(message, SHORT_MESSAGE_LEN)
		: event.CMN_ShortMessage__c;
		logEntry.CMN_StackTrace__c = event.CMN_StackTrace__c;
		logEntry.CMN_UserId__c = event.CMN_UserId__c;

		entriesToInsert.add(logEntry);
  	}

	/**
	* @description Executes after all other handling; will ensure Logs are inserted
	*/
	public override void andFinally() {
		super.andFinally();
		CMN_DAL_SObjectDomain.insertDBObjects(entriesToInsert);
	}
}