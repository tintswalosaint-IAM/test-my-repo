/**
 * @description Trigger Handler framework helper class for Case object
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/07
 */
public with sharing class WI_HLP_Case {
    private static String ERROR_FIELDS_MSG = 'Please ensure that you have entered all required data and completed all required fields assigned to you: ';
    private static String ERROR_TASKS_MSG = 'Please ensure that you have entered all required data and completed all required tasks assigned to you: ';
    private static String ERROR_AUTHOWNER_MSG = 'This user are not allowed to authenticate the identity of this customer. Please ask assign authentication to a different Relationship Manager.';
    private static Set<Id> reassignIds = new Set<Id>();
    private static String SERVICE_TYPE_WEALTH = 'Wealth Management';
    private static Id taskId;

    /**
     * @description Before update handler
     *
     * @param oldCases - Old record map
     * @param newCases - New record map
     */
    public static void isRequiredActionPlansItemsFinishedBulk(Map<Id, Case> oldCases,Map<Id, Case> newCases) {
        Set<Id> queueCscTeamIds = new Set<Id>();
        Set<Id> queueManagerTeamIds = new Set<Id>();
        for (Group item : [
            SELECT Id, DeveloperName 
            FROM Group 
            WHERE (DeveloperName = 'WI_CSCTeam' OR DeveloperName = 'WI_AccountMaintenanceCSC' OR DeveloperName = 'WI_CSCManager')
                AND Type = 'Queue'
        ]) {
            if (item.DeveloperName == 'WI_CSCManager') {
                queueManagerTeamIds.add(item.Id);
            } else {
                queueCscTeamIds.add(item.Id);
            }
        }
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe()
            .get('Case').getDescribe().fields.getMap();
        //get service teams ids
        Set<Id> serviceTeamIds = new Set<Id>();
        for (Case item : newCases.values()) {
            serviceTeamIds.add(item.SVC_ServiceTeam__c);
        }
        List<ServiceTeamActionPlanTemplate__c> links = [
            SELECT Id, ActionPlanTemplate__r.Name, ServiceTeam__c,
                (SELECT Id, FieldApiName__c, Required__c, QueueDevName__c
                FROM FieldSetItems__r
                WHERE ObjectApiName__c = 'Case'
                    AND Required__c = true
                ORDER BY Order__c ASC)
            FROM ServiceTeamActionPlanTemplate__c
            WHERE ServiceTeam__c IN :serviceTeamIds
            ORDER BY ActionPlanTemplate__c
        ];
        List<ActionPlanItem> items = [
            SELECT Name, Item.OwnerId, ActionPlan.TargetId, Item.WI_AgentRequired__c
            FROM ActionPlanItem
            WHERE ActionPlan.TargetId IN :newCases.keySet()
                AND IsRequired = true
                AND ItemState != 'Completed'
                AND ItemId != :taskId
            ORDER BY ActionPlanId
        ];
        for (Case elem : newCases.values()) {
            Case newCase = elem;
            Case oldCase = oldCases.get(elem.Id);
            Boolean isStatusResolved = oldCase.Status != newCase.Status && newCase.Status == 'Resolved';
            Boolean isOwnerCscTeam = oldCase.OwnerId != newCase.OwnerId && queueCscTeamIds.contains(newCase.OwnerId);
            Boolean isOwnerManagerTeam = oldCase.OwnerId != newCase.OwnerId && queueManagerTeamIds.contains(newCase.OwnerId);
            Boolean isOwnerUser = oldCase.OwnerId != newCase.OwnerId && String.valueOf(newCase.OwnerId).startsWith('005') && String.valueOf(oldCase.OwnerId).startsWith('005');
            if (!isStatusResolved && !isOwnerCscTeam && !isOwnerManagerTeam && !isOwnerUser) return;
            //check required fields population
            Set<String> emptyRequiredFields = new Set<String>();
            for (ServiceTeamActionPlanTemplate__c link : links) {
                if (link.ServiceTeam__c != newCase.SVC_ServiceTeam__c) continue;
                for (FieldSetItem__c item : link.FieldSetItems__r) {
                    if (
                        ((isOwnerCscTeam && String.isBlank(item.QueueDevName__c))
                            || isStatusResolved)
                        && newCase.get(item.FieldApiName__c) == null) {
                            emptyRequiredFields.add(item.FieldApiName__c);
                    }
                }
            }
            List<String> emptyRequiredFieldLabels = new List<String>();
            for (String item : emptyRequiredFields) {
                emptyRequiredFieldLabels.add(fields.get(item).getDescribe().getLabel());
            }
            if (!emptyRequiredFieldLabels.isEmpty()) {
                newCase.addError(ERROR_FIELDS_MSG + String.join(emptyRequiredFieldLabels, ', '));
            }
            //check required tasks completion
            List<String> emptyRequiredTasks = new List<String>();
            Boolean isAgentTaskCompleted = true;
            for (ActionPlanItem item : items) {
                if (item.Item.WI_AgentRequired__c) {
                    isAgentTaskCompleted = false;
                }
            }
            for (ActionPlanItem item : items) {
                if (item.ActionPlan.TargetId != newCase.Id) continue;
                if (
                    (((isOwnerCscTeam || isOwnerUser) && String.valueOf(item.Item.OwnerId).startsWith('005') && item.Item.OwnerId == UserInfo.getUserId())
                        || (isOwnerManagerTeam && String.valueOf(item.Item.OwnerId).startsWith('005') && item.Item.WI_AgentRequired__c)
                        || isStatusResolved)) {
                        emptyRequiredTasks.add(item.Name);
                }
            }
            if (!emptyRequiredTasks.isEmpty()) {
                newCase.addError(ERROR_TASKS_MSG + String.join(emptyRequiredTasks, ', '));
            }
        }
    }

    /**
     * @description validate auth task owner
     *
     * @param oldCases - Old record map
     * @param newCases - New record map
     */
    public static void isValidValueTransferManagerBulk(Map<Id, Case> oldCases, Map<Id, Case> newCases) {
        List<Case> cases = [
            SELECT Id, SVC_ServiceType__r.SVC_Category__c, WI_RiskRating__c,
                WI_NumberOfRequests__c, Account.WI_DomesticRM__c, SVC_ServiceType__c,
                Account.WI_InternationalRM__c, SVC_ServiceType__r.Name, WI_AuthManager__c
            FROM Case
            WHERE Id IN :newCases.keySet()
        ];
        for (Case caseRecord : cases) {
            Case newCase = newCases.get(caseRecord.Id);
            Id userId = newCase.WI_AuthManager__c;
            Boolean isValueTransferTask = userId != null && newCase.SVC_ServiceType__c != null
            && (caseRecord.SVC_ServiceType__r.SVC_Category__c == 'Value Transfers' 
                    && (newCase.WI_RiskRating__c == 'High' || newCase.WI_NumberOfRequests__c > 1))
            && newCase.AccountId != null && (caseRecord.Account.WI_DomesticRM__c == userId || caseRecord.Account.WI_InternationalRM__c == userId);
            if (isValueTransferTask) {
                newCase.addError(ERROR_AUTHOWNER_MSG);
            }
        }
    }
}