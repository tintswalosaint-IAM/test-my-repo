/**
 * @description Validates case status changes and prevents unauthorized manual closure.
 *              Blocks users who have the SVC_CannotManuallyCloseCases custom permission from
 *              manually setting UG case status to Closed or editing already-closed cases.
 *              Enforces the 48-hour cool-down period by ensuring only automated processes
 *              (SVC_Set_Case_Status_Closed_After_48_Hours flow) can close cases.
 *              Bypass is controlled by SVC_TRH_Case.bypassClosedValidation.
 *              Configuration is driven by SVC_UGCaseSetting__mdt (SVC_CaseClosureValidator record).
 *              <br/>SFP-58840
 *
 * @see SVC_TRH_Case Trigger handler that invokes this validator in beforeUpdate
 * @see SVC_Set_Case_Status_Closed_After_48_Hours Flow that auto-closes cases after 48hr cool-down
 *
 * @author Raymond Magezi
 * @date February 2026
 */
public inherited sharing class SVC_CaseStatusValidator
{
	private static final sbgplatform.rflib_Logger LOGGER =
		sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CaseStatusValidator');

	private static final String CLOSED = 'Closed';

	@TestVisible
	private static final String CUSTOM_PERMISSION = 'SVC_CannotManuallyCloseCases';

	private static final SVC_UGCaseSetting__mdt SETTINGS {
		get {
			if (SETTINGS == null) {
				SETTINGS = SVC_UGCaseSetting__mdt.getInstance('SVC_CaseClosureValidator');
			}
			return SETTINGS;
		}
		set;
	}

	@TestVisible
	private static String errorManualClose {
		get {
			return SETTINGS?.SVC_ErrorManualClose__c ?? 'Cases cannot be manually closed. Please use the automated process.';
		}
	}

	@TestVisible
	private static String errorEditClosed {
		get {
			return SETTINGS?.SVC_ErrorEditClosed__c ?? 'Closed cases cannot be edited.';
		}
	}

	private SVC_CaseStatusValidator() {}

	/**
	 * @description Prevents users from manually changing case status to Closed.
	 *              Only applies to users with the SVC_CannotManuallyCloseCases custom permission
	 *              on UG cases. Allows automated processes (flows, batch jobs) to close cases.
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	public static void preventManualCaseClose(Case oldCase, Case newCase)
	{
		if(SETTINGS == null || oldCase.Status == newCase.Status || newCase.Status != CLOSED || newCase.Case_Owner_Country__c != SETTINGS.SVC_CaseOwnerCountry__c || SVC_TRH_Case.bypassClosedValidation)
		{
			return;
		}

		if(isAutomatedContext())
		{
			return;
		}

		if(isRestricted())
		{
			LOGGER.warn('preventManualCaseClose: Blocked manual close attempt on Case {0} by user {1}',
				new Object[]{ newCase.Id, UserInfo.getUserId() });
			newCase.addError(errorManualClose);
		}
	}

	/**
	 * @description Prevents users from editing closed cases.
	 *              Only applies to users with the SVC_CannotManuallyCloseCases custom permission
	 *              on UG cases. Allows automated processes to edit closed cases.
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	public static void preventClosedCaseEdit(Case oldCase, Case newCase)
	{
		if(SETTINGS == null || oldCase.Status != CLOSED || newCase.Case_Owner_Country__c != SETTINGS.SVC_CaseOwnerCountry__c || SVC_TRH_Case.bypassClosedValidation)
		{
			return;
		}

		if(isAutomatedContext())
		{
			return;
		}

		if(isRestricted())
		{
			LOGGER.warn('preventClosedCaseEdit: Blocked edit on closed Case {0} by user {1}',
				new Object[]{ newCase.Id, UserInfo.getUserId() });
			newCase.addError(errorEditClosed);
		}
	}

	/**
	 * @description Checks if current execution context is automated.
	 *              Returns true when running user is 'Automated Process'
	 *              or when the bypass flag has been set by an invocable action.
	 *
	 * @return Boolean true if running in automated context
	 */
	private static Boolean isAutomatedContext()
	{
		return UserInfo.getName() == 'Automated Process';
	}

	/**
	 * @description Invocable method to set the bypass flag from flows.
	 *              Called by SVC_Set_Case_Status_Closed_After_48_Hours before DML.
	 */
	@InvocableMethod(label='Bypass Case Closure Validation' description='Sets bypass flag to allow automated case closure')
	public static void bypassValidation()
	{
		SVC_TRH_Case.bypassClosedValidation = true;
	}

	/**
	 * @description Checks if current user has the SVC_CannotManuallyCloseCases custom permission.
	 *              Uses FeatureManagement.checkPermission — no SOQL required.
	 *
	 * @return Boolean true if user has the custom permission (i.e. is restricted)
	 */
	@TestVisible
	private static Boolean isRestricted()
	{
		return FeatureManagement.checkPermission(CUSTOM_PERMISSION);
	}
}