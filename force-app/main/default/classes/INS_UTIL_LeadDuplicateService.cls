/**
* @description Duplicate-detection service for insurance leads.
* Handles duplicate identification, intra-batch duplicate checks,
* duplicate rule evaluation, and creation of duplicate tracking tasks.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains duplicate lead processing logic extracted
* from the insurance lead trigger utility to improve maintainability and
* reduce class complexity.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_UTIL_LeadDuplicateService {

    private INS_UTIL_LeadDuplicateService() {
    }

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadDuplicateService.class.getName());

    private static final String DUPLICATE_REF = 'Duplicate';

    private static Set<Id> duplicateLeadIdsToSkip = new Set<Id>();
    private static Boolean stateInitialized = false;

    private static sbgplatform.fflib_SObjectUnitOfWork uow =
        new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Task.SObjectType }
        );
/**
* @description Initialize duplicate-processing state for the current trigger execution.
* Clears duplicate tracking and resets cached data for new processing.
*/
    public static void initializeState() {
        duplicateLeadIdsToSkip.clear();
        stateInitialized = true;
    }
/**
* @description Get leads that should continue through processing.
* Filters out leads already marked as duplicates or with duplicate reference values.
* @param allLeads List of all leads to filter
* @return List<Lead> Non-duplicate leads for further processing
*/
    public static List<Lead> getNonDuplicateLeads(List<Lead> allLeads) {
        if (!stateInitialized) {
            initializeState();
        }

        List<Lead> nonDuplicates = new List<Lead>();
        for (Lead lead : allLeads) {
            if (!duplicateLeadIdsToSkip.contains(lead.Id) &&
                lead.Referred_System_Reference_Number__c != DUPLICATE_REF) {
                nonDuplicates.add(lead);
            }
        }
        return nonDuplicates;
    }

    /**
* @description Check for duplicate leads with state preservation.
* Identifies duplicate leads based on last name, campaign source, and mobile number,
* then marks duplicates and creates tracking tasks.
* @param newLeads List of new Lead records to check for duplicates
*/
    public static void checkForDuplicates(List<Lead> newLeads) {
        if (!stateInitialized) {
            initializeState();
        }

        try {
            Map<Id, Leads_ProductQueueAllocation__c> productMap =
                INS_UTIL_LeadDuplicateSupport.fetchProductAllocations(newLeads);

            Map<String, Lead> leadsToCheckMap =
                getLeadsEligibleForDuplicateCheck(newLeads, productMap);

            if (leadsToCheckMap.isEmpty()) {
                return;
            }

            Map<String, Lead> intraBatchDuplicates = findIntraBatchDuplicates(leadsToCheckMap);
            Map<String, Lead> existingLeadsMap = findExistingDuplicates(leadsToCheckMap.keySet());

            if (existingLeadsMap.isEmpty() && intraBatchDuplicates.isEmpty()) {
                return;
            }

            applyDuplicateRulesAndAddErrors(leadsToCheckMap, existingLeadsMap, intraBatchDuplicates);

        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadDuplicateService | checkForDuplicates | exception | ' + ex);
        }
    }
/**
* @description Find duplicates within the same batch of incoming leads.
* Compares leads in the current transaction and keeps the first occurrence as reference.
* @param leadsToCheckMap Map of duplicate keys to leads
* @return Map<String, Lead> Map of intra-batch duplicate leads keyed by duplicate key
*/
    private static Map<String, Lead> findIntraBatchDuplicates(Map<String, Lead> leadsToCheckMap) {
        Map<String, Lead> intraBatchDuplicates = new Map<String, Lead>();
        Map<String, Lead> firstOccurrenceMap = new Map<String, Lead>();

        for (String key : leadsToCheckMap.keySet()) {
            Lead currentLead = leadsToCheckMap.get(key);

            if (firstOccurrenceMap.containsKey(key)) {
                intraBatchDuplicates.put(key, firstOccurrenceMap.get(key));
            } else {
                firstOccurrenceMap.put(key, currentLead);
            }
        }

        return intraBatchDuplicates;
    }
/**
* @description Apply duplicate rules and mark duplicate leads.
* Updates duplicate reference values, tracks duplicate lead Ids,
* and prepares duplicate-attempt tasks.
* @param leadsToCheckMap Map of incoming leads to evaluate
* @param existingLeadsMap Map of existing leads by duplicate key
* @param intraBatchDuplicates Map of intra-batch duplicate leads by duplicate key
*/
    private static void applyDuplicateRulesAndAddErrors(
        Map<String, Lead> leadsToCheckMap,
        Map<String, Lead> existingLeadsMap,
        Map<String, Lead> intraBatchDuplicates
    ) {
        Set<Id> duplicateLeadIds = new Set<Id>();
        List<Task> tasksToCreate = new List<Task>();

        for (String key : leadsToCheckMap.keySet()) {
            Lead newLead = leadsToCheckMap.get(key);
            Lead existingLead = existingLeadsMap.get(key);

            if (existingLead != null && isDuplicateBasedOnRules(newLead, existingLead)) {
                newLead.Referred_System_Reference_Number__c = DUPLICATE_REF;
                duplicateLeadIds.add(newLead.Id);

                Task duplicateTask = createDuplicateTask(existingLead.Id, newLead);
                tasksToCreate.add(duplicateTask);
            }
        }

        for (String key : intraBatchDuplicates.keySet()) {
            Lead newLead = leadsToCheckMap.get(key);
            Lead firstOccurrenceLead = intraBatchDuplicates.get(key);

            if (!duplicateLeadIds.contains(newLead.Id)) {
                newLead.Referred_System_Reference_Number__c = DUPLICATE_REF;
                duplicateLeadIds.add(newLead.Id);

                Task duplicateTask = createDuplicateTask(firstOccurrenceLead.Id, newLead);
                tasksToCreate.add(duplicateTask);
            }
        }

        if (!duplicateLeadIds.isEmpty()) {
            duplicateLeadIdsToSkip.addAll(duplicateLeadIds);
        }

        if (!tasksToCreate.isEmpty()) {
            for (Task task : tasksToCreate) {
                uow.registerNew(task);
            }
            uow.commitWork();
        }
    }
/**
* @description Create a task to track a duplicate lead attempt.
* Associates the task to the related lead and stores duplicate details in the description.
* @param relatedLeadId Lead Id to associate the task to
* @param duplicateLead Duplicate lead that triggered the task
* @return Task Configured duplicate-attempt task
*/
    private static Task createDuplicateTask(Id relatedLeadId, Lead duplicateLead) {
        Task duplicateTask = new Task();
        duplicateTask.Subject = 'Duplicate Lead Attempt';
        duplicateTask.ActivityDate = Date.today();
        duplicateTask.WhoId = relatedLeadId;
        duplicateTask.Description =
            'DuplicateLead: ' +
            duplicateLead.LastName + '|' +
            duplicateLead.MobilePhone + '|' +
            duplicateLead.Campaign_Source_ID__c;

        return duplicateTask;
    }
/**
* @description Get leads eligible for duplicate checking.
* Filters leads using product validation and required duplicate fields.
* @param newLeads List of incoming leads
* @param productMap Map of product queue allocations by Id
* @return Map<String, Lead> Map of duplicate keys to eligible leads
*/
    private static Map<String, Lead> getLeadsEligibleForDuplicateCheck(
        List<Lead> newLeads,
        Map<Id, Leads_ProductQueueAllocation__c> productMap
    ) {
        Map<String, Lead> leadsToCheckMap = new Map<String, Lead>();

        for (Lead lead : newLeads) {
            if (INS_UTIL_LeadDuplicateSupport.isValidProductLead(
                    lead,
                    productMap.get(lead.Expressed_Interest_Product__c)
                ) &&
                String.isNotBlank(lead.LastName) &&
                String.isNotBlank(lead.Campaign_Source_ID__c) &&
                String.isNotBlank(lead.MobilePhone)) {

                String key = INS_UTIL_LeadDuplicateSupport.getDuplicateKey(lead);
                leadsToCheckMap.put(key, lead);
            }
        }
        return leadsToCheckMap;
    }
/**
* @description Find existing duplicate leads in the database.
* Splits duplicate keys into search criteria and queries matching leads.
* @param duplicateKeys Set of duplicate keys to search for
* @return Map<String, Lead> Map of existing leads by duplicate key
*/

    private static Map<String, Lead> findExistingDuplicates(Set<String> duplicateKeys) {
        Set<String> lastNames = new Set<String>();
        Set<String> campaignSourceIds = new Set<String>();
        Set<String> mobilePhones = new Set<String>();

        for (String key : duplicateKeys) {
            List<String> keyParts = key.split('\\|');
            if (keyParts.size() == 3) {
                lastNames.add(keyParts[0]);
                campaignSourceIds.add(keyParts[1]);
                mobilePhones.add(keyParts[2]);
            }
        }

        if (lastNames.isEmpty() || campaignSourceIds.isEmpty() || mobilePhones.isEmpty()) {
            return new Map<String, Lead>();
        }

        List<Lead> existingLeads =
            new SEL_Lead().selectByBulkDuplicateCriteria(lastNames, campaignSourceIds, mobilePhones);

        Map<String, Lead> existingLeadsMap = new Map<String, Lead>();
        for (Lead existingLead : existingLeads) {
            String key = INS_UTIL_LeadDuplicateSupport.getDuplicateKey(existingLead);
            existingLeadsMap.put(key, existingLead);
        }

        return existingLeadsMap;
    }
/**
* @description Evaluate whether two leads are duplicates based on insurance business rules.
* Checks lead source alignment, active lead window, and retro/non-retro rules.
* @param newLead Incoming lead being evaluated
* @param existingLead Existing lead from the database
* @return Boolean True if the leads should be treated as duplicates
*/
    private static Boolean isDuplicateBasedOnRules(Lead newLead, Lead existingLead) {
        if (newLead.LeadSource != existingLead.LeadSource) {
            return false;
        }

        if (INS_UTIL_LeadDuplicateSupport.isActiveLeadWithin30Days(existingLead)) {
            return true;
        }

        if (INS_UTIL_LeadDuplicateSupport.isRetroLead(newLead) &&
            INS_UTIL_LeadDuplicateSupport.isRetroLead(existingLead)) {
            return true;
        }

        if (INS_UTIL_LeadDuplicateSupport.isNonRetroLead(newLead) &&
            INS_UTIL_LeadDuplicateSupport.isNonRetroLead(existingLead)) {
            return existingLead.Status != 'New';
        }

        return false;
    }
}