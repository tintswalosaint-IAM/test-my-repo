/**
 * @description After update of case trigger handler
 *
 * @author Accenture
 *
 * @date August 2021
 *
 * Lastmodified: 18 Nov 2025 : SFP-54449 Removed references to  code that was causing production incident where
 * Users of SA Private Banking Complaints team are experiencing an issue with their manually created cases
 * where they expect a case to be routed to a queue based on the Service Team setting but the cases are staying
 *
 * Lastmodified: February 2026 : SFP-56268
 * @lastModified Raymond Magezi - Added resolution comments validation for UG cases
 *
 * Lastmodified: June 2026 : SFP-58600
 * @lastModified Raymond Magezi - Added UG CCC unresolved comments enforcement and UNRESOLVED_SETTINGS
 * 
 * * Lastmodified: July 2026 : SFP-55625
 * @lastModified Given Khupai - Added Case Milestone Metrics method to insert case lifecycle TAT calucations in business hours.
 *
 * Lastmodified: September 2026 : SFP-51816
 * @lastModified Given Khupai - Added Case Transfer History buffering to record owner/team transfers on CMN_History_Tracker__c
 */
public inherited sharing class SVC_TRH_Case extends CMN_TRH_BaseObject
{
    private static Set<Id> caseIds = new Set<Id>();
	private static Set<Id> processedCaseIds = new Set<Id>();
	private static Boolean flowInProgress = false;
	@TestVisible
	public static Boolean escalationInProgress = false;
	/**
	 * @description Getter & Setter
	 * @comment  caseDefaultsFlowInProgress
	 */
	public static Flow.Interview.SVC_CaseDefaults_SetInProgress caseDefaultsFlowInProgress { get; set; }

	/**
	 * @description Getter & Setter
	 * @comment caseDefaultsFlowInProgress
	 */
	public static Flow.Interview.SVC_CaseDefaults_SetisClosed caseDefaultsSetIsClosed { get; set; }

	private static final String INPROGRESS = 'In Progress';
	private static final String RESOLVED = 'Resolved';
	private static final String UNRESOLVED = 'Unresolved';
	private static final Set<String> BLOCKED_PROFILES = new Set<String>{'SVC Agent Banker', 'Relationship Manager'};

	@TestVisible
	public static Boolean bypassClosedValidation = false;

	/**
	 * @description Per-invocation buffer of updated Cases awaiting Case Milestone Metrics
	 *              processing. Deliberately an instance field (not static) so that a fresh
	 *              buffer is created for each trigger handler instance - see andFinally().
	 */
	@TestVisible
	private final List<Case> caseMetricsBuffer = new List<Case>();

	/**
	 * @description Per-invocation buffers of updated Cases (and their pre-update
	 *              state) awaiting Case Transfer History processing - SFP-51816.
	 *              Instance fields for the same reason as caseMetricsBuffer above:
	 *              a fresh buffer per trigger handler instance, flushed in
	 *              andFinally() as a single bulk call rather than a per-record Flow.
	 */
	@TestVisible
	private final List<Case> transferHistoryNewCaseBuffer = new List<Case>();
	@TestVisible
	private final Map<Id, Case> transferHistoryOldCaseById = new Map<Id, Case>();

	private static final SVC_UGCaseSetting__mdt SETTINGS {
		get {
			if (SETTINGS == null) {
				SETTINGS = SVC_UGCaseSetting__mdt.getInstance('SVC_CaseResolutionValidator');
			}
			return SETTINGS;
		}
		set;
	}

	private static final SVC_UGCaseSetting__mdt UNRESOLVED_SETTINGS {
		get {
			if (UNRESOLVED_SETTINGS == null) {
				UNRESOLVED_SETTINGS = SVC_UGCaseSetting__mdt.getInstance('SVC_CaseUnresolvedValidator');
			}
			return UNRESOLVED_SETTINGS;
		}
		set;
	}

    /**
     * @description This method is called prior to execution of a BEFORE Trigger. 
     * Use this to cache any data required into maps prior execution of the Trigger.
     */
    public override void bulkBefore() {
        if (Trigger.isUpdate) {
            Map<Id, Case> caseRecords = new Map<Id, Case>();
            for (Id key : Trigger.newMap.keySet()) {
                if (caseIds.contains(key)) {
                    continue;
                }
                caseRecords.put(key, (Case)Trigger.newMap.get(key));
            }
            if (!caseRecords.isEmpty()) {
                WI_HLP_Case.isRequiredActionPlansItemsFinishedBulk((Map<Id, Case>)Trigger.oldMap, caseRecords);
                WI_HLP_Case.isValidValueTransferManagerBulk((Map<Id, Case>)Trigger.oldMap, caseRecords);
            }
        }
        
    }

	/**
	 * @description Before update handler
	 *
	 * @param oldSo Old Case record
	 * @param so New (Updated) Case record
	 */
	public override void beforeUpdate(SObject oldSo, SObject so)
	{
		super.beforeUpdate(oldSo, so);
		SVC_CaseStatusValidator.preventManualCaseClose((Case)oldSo, (Case)so);
		SVC_CaseStatusValidator.preventClosedCaseEdit((Case)oldSo, (Case)so);
		enforceResolutionComments((Case)oldSo, (Case)so);
		enforceUnresolvedComments((Case)oldSo, (Case)so);
		SVC_AwaitingFeedbackValidator.validate((Case)oldSo, (Case)so);
	}

	/**
	 * @description Enforces Resolution Comments to Client for UG cases.
	 *              Blocks blank values and generic phrases.
	 *              Only applies to blocked profile users with UG cases.
	 *              Allows automated processes to bypass.
	 *              Only validates when case status is changing to Resolved.
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	private void enforceResolutionComments(Case oldCase, Case newCase)
	{
		if(!shouldEnforceResolutionComments(oldCase, newCase))
		{
			return;
		}
		
		SVC_CaseResolutionValidator.validate(newCase);
	}

	/**
	 * @description Checks if resolution comments validation should be enforced
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 *
	 * @return Boolean true if validation should be enforced
	 */
	private Boolean shouldEnforceResolutionComments(Case oldCase, Case newCase)
	{
		if(newCase.Case_Owner_Country__c != SETTINGS.SVC_CaseOwnerCountry__c || bypassClosedValidation)
		{
			return false;
		}
		
		if(oldCase.Status == newCase.Status || newCase.Status != RESOLVED)
		{
			return false;
		}
		
		if(isAutomatedContext())
		{
			return false;
		}
		
		return isBlockedProfile();
	}

	/**
	 * @description Checks if current execution context is automated
	 *
	 * @return Boolean true if running in automated context
	 */
	private Boolean isAutomatedContext()
	{
		String userName = UserInfo.getName();
		return userName == 'Automated Process';
	}

	/**
	 * @description Checks if current user has a blocked profile
	 *
	 * @return Boolean true if user has a blocked profile
	 */
	private Boolean isBlockedProfile()
	{
		try
		{
			List<User> users = SEL_User.newInstance().selectUsersByIds(new Set<Id>{ UserInfo.getUserId() });
			return !users.isEmpty() && BLOCKED_PROFILES.contains(users[0].Profile.Name);
		}
		catch(Exception e)
		{
			return true;
		}
	}

	/**
	 * @description Validates Reason for Unresolved is populated for UG cases being set to Unresolved.
	 *              Does NOT enforce Resolution_Comments_to_Client__c for Unresolved cases
	 *              as the SVC_UnresolvedCase screen flow collects the reason separately.
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	private void enforceUnresolvedComments(Case oldCase, Case newCase)
	{
		if(!shouldEnforceUnresolvedComments(oldCase, newCase))
		{
			return;
		}
		if(String.isBlank(newCase.SVC_ReasonForUnresolved__c))
		{
			newCase.addError('Reason for Unresolved is required when unresolving a Uganda case');
		}
	}

	/**
	 * @description Checks if unresolved comments validation should be enforced
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 *
	 * @return Boolean true if validation should be enforced
	 */
	private Boolean shouldEnforceUnresolvedComments(Case oldCase, Case newCase)
	{
		if(UNRESOLVED_SETTINGS == null || newCase.Case_Owner_Country__c != UNRESOLVED_SETTINGS.SVC_CaseOwnerCountry__c || bypassClosedValidation)
		{
			return false;
		}
		if(oldCase.Status == newCase.Status || newCase.Status != UNRESOLVED)
		{
			return false;
		}
		if(isAutomatedContext())
		{
			return false;
		}
		return isBlockedProfile();
	}

    /**
     * @description This method is called prior to execution of a AFTER Trigger. 
     * Use this to cache any data required into maps prior execution of the Trigger.
     */
    public override void bulkAfter() {
        if (Trigger.isUpdate) {
            caseIds.addAll(((Map<Id, Case>)Trigger.newMap).keySet());
        }
    }

    /**
     * @description This method is called at the end of a AFTER Trigger execution.
     */
    public override void andFinally() {
        if (!caseMetricsBuffer.isEmpty()) {
            INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetailsForCases(caseMetricsBuffer);
        }
        if (!transferHistoryNewCaseBuffer.isEmpty()) {
            INS_SRV_CaseTransferHistory.recordTransfers(transferHistoryNewCaseBuffer, transferHistoryOldCaseById);
        }
    }

	/**
	 * @description After insert handler
	 *
	 * @param so - New Case
	 */
	public override void afterInsert(SObject so)
	{
		super.afterInsert(so);
	}

	/**
	 * @description After update handler
	 *
	 * @param oldSo - Old Case
	 * @param so - New (Updated) Case
	 */
	public override void afterUpdate(SObject oldSo, SObject so)
	{
		super.afterUpdate(oldSo, so);
		onChangeCaseStatus((Case)oldSo, (Case)so);
		publishPlatformEvent((Case)oldSo, (Case)so);
        caseMetricsBuffer.add((Case)so);
        transferHistoryNewCaseBuffer.add((Case)so);
        transferHistoryOldCaseById.put(((Case)oldSo).Id, (Case)oldSo);

	}

	/**
	 * @description Handles case status changes and launches appropriate flows
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	private void onChangeCaseStatus(Case oldCase, Case newCase)
	{
		if(processedCaseIds.contains(newCase.Id) || escalationInProgress)
		{
			return;
		}
		handleInProgressChange(oldCase, newCase);
		handleStatusChange(oldCase, newCase, RESOLVED);
		handleStatusChange(oldCase, newCase, UNRESOLVED);
	}

	/**
	 * @description Handles sub-status change for In Progress cases
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	private void handleInProgressChange(Case oldCase, Case newCase)
	{
		if(oldCase.SVC_SubStatus__c == newCase.SVC_SubStatus__c) { return; }
		if(CMN_UTIL_String.isBlank(newCase.SVC_ServiceTeam__c)) { return; }
		if(newCase.Status != INPROGRESS) { return; }
		processedCaseIds.add(newCase.Id);
		launchCaseDefaultsFlow(newCase, INPROGRESS);
	}

	/**
	 * @description Handles status change to Resolved or Unresolved
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 * @param targetStatus The status to check for (Resolved or Unresolved)
	 */
	private void handleStatusChange(Case oldCase, Case newCase, String targetStatus)
	{
		if(oldCase.Status == newCase.Status) { return; }
		if(newCase.Status != targetStatus) { return; }
		processedCaseIds.add(newCase.Id);
		launchCaseDefaultsFlow(newCase, targetStatus);
	}

	/**
	 * @description Launches a lightning flow with parameters based on case status
	 *
	 * @param newCase Case record to process
	 * @param caseStatus Status value to determine which flow to launch
	 */
	public static void launchCaseDefaultsFlow(Case newCase, String caseStatus)
	{
		if(flowInProgress) { return; }
		flowInProgress = true;
		try
		{
			Map<String, Object> parameterMap = new Map<String, Object>();

			if(caseStatus == INPROGRESS)
			{
				parameterMap.put('SVC_CaseId', newCase.Id);
				parameterMap.put('SVC_isEscalated', newCase.IsEscalated);
				parameterMap.put('SVC_CaseSubStatus', newCase.SVC_SubStatus__c);
				caseDefaultsFlowInProgress = new Flow.Interview.SVC_CaseDefaults_SetInProgress(parameterMap);
				caseDefaultsFlowInProgress.start();
			}
			if(caseStatus == RESOLVED || caseStatus == UNRESOLVED)
			{
				parameterMap.put('SVC_CaseId', newCase.Id);
				parameterMap.put('SVC_isEscalated', newCase.IsEscalated);
				parameterMap.put('SVC_ServiceTeamId', newCase.SVC_ServiceTeam__c);
				parameterMap.put('SVC_CaseStatus', newCase.Status);
				caseDefaultsSetIsClosed = new Flow.Interview.SVC_CaseDefaults_SetisClosed(parameterMap);
				caseDefaultsSetIsClosed.start();
			}
		}
		catch(Exception ex)
		{
			CMN_UTIL_Logger.error(ex, 'SVC_TRH_Case.launchCaseDefaultsFlow');
		}
		finally
		{
			flowInProgress = false;
		}
	}
	/**
	 * @description Publishes platform event to refresh authentication toggle component on Case layout
	 *
	 * @param oldCase Old Case record
	 * @param newCase New Case record
	 */
	public static void publishPlatformEvent(Case oldCase, Case newCase)
	{
		List<SVC_Case_Refresh__e> refreshEvents = new List<SVC_Case_Refresh__e>();
		refreshEvents.add(new SVC_Case_Refresh__e(Record_Id__c = newCase.Id));
		if (oldCase.SVC_IsAuthenticated__c != newCase.SVC_IsAuthenticated__c || oldCase.Origin != newCase.Origin || oldCase.SVC_AuthenticationMethod__c != newCase.SVC_AuthenticationMethod__c
				|| oldCase.SVC_ServiceType__c != newCase.SVC_ServiceType__c){
			List<Database.SaveResult> results = EventBus.publish(refreshEvents);
			for (Database.SaveResult sr : results) {
				if (!sr.isSuccess()) {
					for (Database.Error err : sr.getErrors()) {
						CMN_UTIL_Logger.debug(err.getMessage(), 'SVC_TRH_Case/publishPlatformEvent');
					}
				}
			}
		}
	}
	
}