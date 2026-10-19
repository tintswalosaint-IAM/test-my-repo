/**
 * @description Batch class to process UG Private Banking case escalations daily.
 *              Queries escalated cases, increments escalation level, assigns to
 *              appropriate manager, and dispatches email notifications asynchronously
 *              via a single queueable job enqueued in finish() after all chunks complete.
 *
 * @author Raymond Magezi
 *
 * @date January 2025
 *
 * @see CMN_BATCH_UG_CaseEscalation_TEST
 * @see CMN_CFG_UGEscalationSettings
 * @see CMN_SVC_UGEscalationEmail
 * @see SEL_UGCaseEscalation
 * @see SEL_User
 * @see CMN_DAL_User
 * @see CMN_DAL_UserManagerHierarchy
 * @see SVC_TRH_Case
 *
 * @userStory SFP-58532
 *
 * @history 28-01-2025  Raymond Magezi  Initial version
 * @history 29-01-2026  Raymond Magezi  Refactored: Moved SOQL from constructor, added null safety,
 *                                      circuit breaker, enhanced logging, and improved error handling
 * @history 23-02-2026  Raymond Magezi  Moved SOQL queries to SEL_UGCaseEscalation selector
 * @history 16-04-2026  Raymond Magezi  Hotfix: Added automated user timing condition for level 2+
 *                                      escalations, reordered case updates before email queueing,
 *                                      wrapped email failures in try-catch to preserve case updates,
 *                                      filtered .invalid sandbox emails from CC addresses,
 *                                      added LastModifiedById/LastModifiedDate to query,
 *                                      converted documentation to Javadoc standard - SFP-55654
 * @history 20-05-2026  Raymond Magezi  Simplified to country-based scoping: replaced single-team
 *                                      settings with activeSetting per country, loadSettings() loads
 *                                      active record by CaseOwnerCountry__c, query driven by
 *                                      Case_Owner_Country__c covering all Uganda teams - SFP-58532
 * @history 23-07-2026  Raymond Magezi  Tech debt: Reduced cyclomatic complexity, removed redundant guards,
 *                                      added try/catch in queueEmails, added full Javadoc - SFP-58853
 */
public without sharing class CMN_BATCH_UG_CaseEscalation extends sbgbase.BatchJobBase 
    implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_BATCH_UG_CaseEscalation.class.getName());
    
    @TestVisible
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    
    @TestVisible
    private static final Integer MAX_ERRORS_THRESHOLD = 50;
    
    @TestVisible
    private static final String COUNTRY_CODE_UGANDA = 'UG';
    
    // Use enum for statuses to avoid magic strings
    private enum CaseStatus { RESOLVED }

    // Active setting for the target country — loaded once in start()
    @TestVisible
    private UG_PB_Escalation_Setting__mdt activeSetting;
    private Id automatedUserId;

    @TestVisible
    private Decimal globalMaxLevel;
    
    @TestVisible
    private Integer totalBatches = 0;
    @TestVisible
    private Integer totalRecords = 0;
    @TestVisible
    private Integer errorCount = 0;
    @TestVisible
    private Integer skippedCount = 0;
    @TestVisible
    private Integer successCount = 0;
    private final List<CMN_QUEUE_SendEscalationEmails.EmailRequest> allEmailRequests = new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>();
    

    
    /**
     * @description Loads the active escalation setting for Uganda from custom metadata.
     */
    @TestVisible
    private void loadSettings() {
        CMN_CFG_UGEscalationSettings.Config config = CMN_CFG_UGEscalationSettings.loadForCountry(COUNTRY_CODE_UGANDA);
        this.activeSetting = config.setting;
        this.automatedUserId = config.automatedUserId;
        this.globalMaxLevel = config.maxLevel;
    }
    
    /**
     * @description Queries cases that need escalation processing
     *
     * @param bc BatchableContext
     *
     * @return Database.QueryLocator with cases to process
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        loadSettings();
        return SEL_UGCaseEscalation.getEscalationCandidatesQueryLocator(
            COUNTRY_CODE_UGANDA, globalMaxLevel, String.valueOf(CaseStatus.RESOLVED)
        );
    }
    
    /**
     * @description Processes batch of cases for escalation
     *
     * @param bc BatchableContext
     * @param scope List of cases to process in this batch
     */
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        if (errorCount >= MAX_ERRORS_THRESHOLD) {
            throw new BatchableException('Circuit breaker triggered: Error count exceeded threshold.');
        }

        totalBatches++;
        totalRecords += scope.size();

        try {
            Set<Id> ownerIds = new Set<Id>();
            Map<Id, Integer> caseToNewLevel = new Map<Id, Integer>();
            List<CMN_DAL_User.ManagerRequest> managerRequests = new List<CMN_DAL_User.ManagerRequest>();
            for (Case c : scope) {
                ownerIds.add(c.OwnerId);
                caseToNewLevel.put(c.Id, Integer.valueOf(c.SVC_Escalation_Level__c + 1));
                CMN_DAL_User.ManagerRequest managerReq = new CMN_DAL_User.ManagerRequest();
                managerReq.ownerId = c.OwnerId;
                managerReq.escalationLevel = caseToNewLevel.get(c.Id);
                managerRequests.add(managerReq);
            }
            List<CMN_DAL_User.ManagerResult> managerResults = CMN_DAL_User.getManagerByLevel(managerRequests);
            Map<Id, User> owners = new Map<Id, User>(SEL_User.newInstance().selectUsersByIds(ownerIds));
            Map<Id, User> previousManagers = loadPreviousManagers(scope);

            List<CMN_QUEUE_SendEscalationEmails.EmailRequest> emailRequests = new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>();
            List<Case> casesToUpdate = new List<Case>();
            Datetime todayMidnight = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
            for (Integer i = 0; i < scope.size(); i++) {
                processSingleCase(scope[i], managerResults[i], caseToNewLevel, owners, previousManagers, emailRequests, casesToUpdate, todayMidnight);
            }

            Integer batchErrors = updateCases(casesToUpdate);
            if (!emailRequests.isEmpty()) {
                CMN_QUEUE_SendEscalationEmails.queueEmails(emailRequests);
            }

            finishBatch(bc, scope.size(), batchErrors, batchErrors > 0 ? batchErrors + ' error(s)' : 'Success');
        } catch (Exception ex) {
            LOGGER.fatal('execute: Unhandled exception in batch #{0}', new Object[]{totalBatches}, ex);
            finishBatch(bc, scope.size(), scope.size(), 'Unhandled exception: ' + ex.getMessage());
            throw ex;
        }
    }
    
    /**
     * @description Finalizes batch job and logs comprehensive summary
     *
     * @param bc BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        Decimal successRate = totalRecords > 0 ? 
            (successCount * 100.0 / totalRecords).setScale(2) : 100.00;
        
        String finalMessage = String.format(
            'UG Case Escalation Complete | Country: {6} | Total: {0} | Successful: {1} ({2}%) | Errors: {3} | Skipped: {4} | Batches: {5} | Emails: {7}',
            new Object[]{totalRecords, successCount, successRate, errorCount, skippedCount, totalBatches,
                         activeSetting.CaseOwnerCountry__c, allEmailRequests.size()}
        );
        
            LOGGER.info('finish: {0}', new Object[]{finalMessage});
            super.finishJob(bc, finalMessage);
        }
        
    /**
     * @description Schedulable execute method to run batch job
     *
     * @param sc SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CMN_BATCH_UG_CaseEscalation(), DEFAULT_BATCH_SIZE);
    }
    


    /**
     * @description Loads previous escalation managers (SVC_Escalate_to__c) for CC addresses.
     *
     * @param scope Cases in this batch chunk
     * @return Map of User Id to User record for previous managers
     */
    @TestVisible
    private Map<Id, User> loadPreviousManagers(List<Case> scope) {
        Set<Id> prevManagerIds = new Set<Id>();
        for (Case c : scope) {
            if (c.SVC_Escalate_to__c != null) {
                prevManagerIds.add(c.SVC_Escalate_to__c);
            }
        }
        if (prevManagerIds.isEmpty()) {
            return new Map<Id, User>();
        }
        return new Map<Id, User>(SEL_User.newInstance().selectUsersByIds(prevManagerIds));
    }



    /**
     * @description Processes a single case: checks timing, resolves manager, prepares
     *              email request, and updates escalation level/escalate-to fields.
     *              Skips if timing guard fails or no manager found at target level.
     */
    @TestVisible
    private void processSingleCase(
        Case c,
        CMN_DAL_User.ManagerResult managerResult,
        Map<Id, Integer> caseToNewLevel,
        Map<Id, User> owners,
        Map<Id, User> previousManagers,
        List<CMN_QUEUE_SendEscalationEmails.EmailRequest> emailRequests,
        List<Case> casesToUpdate,
        Datetime todayMidnight
    ) {
        Integer newLevel = caseToNewLevel.get(c.Id);

        if (shouldSkipForTiming(c, todayMidnight)) {
            skippedCount++;
            return;
        }

        if (managerResult.managerId == null) {
            c.SVC_Escalation_Level__c = activeSetting.MaxEscalationLevel__c;
            casesToUpdate.add(c);
            skippedCount++;
            return;
        }

        CMN_SVC_UGEscalationEmail.addEmailRequest(c, managerResult,
            CMN_SVC_UGEscalationEmail.buildCcAddresses(c, newLevel, owners, previousManagers),
            activeSetting.EmailTemplateApiName__c, activeSetting.OrgWideEmailAddress__c, emailRequests);
        c.SVC_Escalation_Level__c = newLevel;
        c.SVC_Escalate_to__c = managerResult.managerId;
        casesToUpdate.add(c);
    }
    
    /**
     * @description Determines if a case should be skipped based on timing rules.
     *              Level 0 cases always escalate. Level 1+ only escalate if the
     *              automated user (SBG Data User) was the last modifier AND that
     *              modification was before today midnight (ensuring 24hr gap).
     *
     * @param c Case record
     * @param todayMidnight Start of today used as the timing threshold
     * @return true if the case should be skipped (timing not met)
     */
    @TestVisible
    private Boolean shouldSkipForTiming(Case c, Datetime todayMidnight) {
        if (c.SVC_Escalation_Level__c == null || c.SVC_Escalation_Level__c == 0) {
            return false;
        }
        return !(automatedUserId != null && c.LastModifiedById == automatedUserId && c.LastModifiedDate < todayMidnight);
    }

    /**
     * @description Commits case field updates (SVC_Escalation_Level__c, SVC_Escalate_to__c)
     *              via Unit of Work. Sets escalationInProgress flag to bypass trigger
     *              handler flows during DML.
     *
     * @param casesToUpdate Cases with updated escalation fields
     * @return Number of errors (0 on success, casesToUpdate.size() on failure)
     */
    @TestVisible
    private Integer updateCases(List<Case> casesToUpdate) {
        if (casesToUpdate.isEmpty()) {
            return 0;
        }
        sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Schema.SObjectField> dirtyFields = new List<Schema.SObjectField>{
            Case.SVC_Escalation_Level__c,
            Case.SVC_Escalate_to__c
        };
        for (Case c : casesToUpdate) {
            uow.registerDirty(c, dirtyFields);
        }
        try {
            SVC_TRH_Case.escalationInProgress = true;
            uow.commitWork();
            successCount += casesToUpdate.size();
            return 0;
        } catch (Exception ex) {
            errorCount += casesToUpdate.size();
            LOGGER.error('execute: Failed to update cases - {0}', new Object[]{ex.getMessage()});
            return casesToUpdate.size();
        } finally {
            SVC_TRH_Case.escalationInProgress = false;
        }
    }



    public class BatchableException extends Exception {}
}