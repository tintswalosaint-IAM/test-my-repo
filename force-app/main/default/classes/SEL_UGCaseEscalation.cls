/**
 * @description Selector for UG Case Escalation batch. Provides methods to query
 *              cases, users, and custom metadata for escalation processing.
 *
 * @author Raymond Magezi
 *
 * @date February 2026
 *
 * @see SEL_UGCaseEscalation_TEST
 *
 * @history 09-02-2026  Raymond Magezi  Initial creation - extracted from CMN_BATCH_UG_CaseEscalation
 * @history 16-04-2026  Raymond Magezi  Hotfix: Added LastModifiedById and LastModifiedDate to
 *                                      escalation candidates query, converted documentation to
 *                                      Javadoc standard - SFP-55654
 * @history 20-05-2026  Raymond Magezi  Multi-team support: added selectAllActiveSettings() and
 *                                      updated getEscalationCandidatesQueryLocator() to use
 *                                      country-based scoping - SFP-58532
 */
public with sharing class SEL_UGCaseEscalation {
    
    @TestVisible
    private static List<UG_PB_Escalation_Setting__mdt> mockActiveSettings = null;
    
    private SEL_UGCaseEscalation() {
    }
    
    /**
     * @description Queries escalation settings from custom metadata by developer name
     *
     * @param developerName Developer name of the setting
     *
     * @return UG_PB_Escalation_Setting__mdt
     */
    public static UG_PB_Escalation_Setting__mdt selectEscalationSetting(String developerName) {
        return UG_PB_Escalation_Setting__mdt.getInstance(developerName);
    }

    /**
     * @description Returns all active escalation settings from custom metadata
     *
     * @return List of UG_PB_Escalation_Setting__mdt records where IsActive__c = true
     */
    public static List<UG_PB_Escalation_Setting__mdt> selectAllActiveSettings() {
        if (mockActiveSettings != null) {
            return mockActiveSettings;
        }
        return [
            SELECT DeveloperName, TeamDeveloperName__c, CaseOwnerCountry__c,
                   MaxEscalationLevel__c, EmailTemplateApiName__c,
                   OrgWideEmailAddress__c, AutomatedUserName__c
            FROM UG_PB_Escalation_Setting__mdt
            WHERE IsActive__c = true
            WITH USER_MODE
        ];
    }

    /**
     * @description Builds query locator for escalation candidates scoped by country.
     *              Processes all cases in the given country regardless of team.
     *
     * @param countryCode Country code matching Case_Owner_Country__c on Case (e.g. 'UG')
     * @param maxLevel    Maximum escalation level
     * @param resolvedStatus Resolved status value to exclude
     *
     * @return Database.QueryLocator with cases to process
     */
    public static Database.QueryLocator getEscalationCandidatesQueryLocator(
        String countryCode,
        Decimal maxLevel,
        String resolvedStatus
    ) {
        String safeCountryCode = String.escapeSingleQuotes(countryCode);
        String safeResolvedStatus = String.escapeSingleQuotes(resolvedStatus);
        String query = 'SELECT Id, ' +
                       '       SVC_Escalation_Level__c, ' +
                       '       OwnerId, ' +
                       '       SVC_Escalate_to__c, ' +
                       '       CaseNumber, ' +
                       '       Status, ' +
                       '       LastModifiedById, ' +
                       '       LastModifiedDate ' +
                       'FROM Case ' +
                       'WHERE Case_Owner_Country__c = :safeCountryCode ' +
                       'AND IsClosed = false ' +
                       'AND SVC_Escalation_Level__c < :maxLevel ' +
                       'AND IsEscalated = true ' +
                       'AND Status != :safeResolvedStatus ' +
                       'AND Owner.Type = \'User\' ' +
                       'ORDER BY CreatedDate ASC';

        return Database.getQueryLocator(query, AccessLevel.USER_MODE);
    }
    
    /**
     * @description Checks if a CMN_BATCH_UG_CaseEscalation batch job is currently running
     *
     * @return Boolean true if a batch is already running
     */
    public static Boolean isEscalationBatchRunning() {
        List<AsyncApexJob> runningJobs = [
            SELECT Id FROM AsyncApexJob 
            WHERE ApexClass.Name = 'CMN_BATCH_UG_CaseEscalation' 
            AND (Status IN ('Holding','Queued','Preparing','Processing')
                 OR (Status = 'Completed' AND CreatedDate = TODAY))
            WITH USER_MODE
            LIMIT 1
        ];
        return !runningJobs.isEmpty();
    }
}