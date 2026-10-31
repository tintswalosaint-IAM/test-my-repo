/*
* @description Insurance-specific lead processing methods with static state management
* Handles lead processing for insurance products including:
* 1. Mobile number formatting for South African numbers
* 2. Duplicate lead detection and management
* 3. Campaign synchronization and member creation
* 4. Connex integration for dialer system
* 5. Lead status maintenance and owner assignment
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class was created as part of user story SFP-44418 to implement
* comprehensive lead processing functionality for insurance products, including
* Connex integration, duplicate management, and campaign synchronization.

* @LastModifiedReason  : SFP-58785 Updated the logic to mark leads as duplicates
                         when they have the same Last Name, Mobile Number,
                         and Campaign Source ID.
* @Last modified on    : 03-08-2026
* @Last modified by    : Raja Arsalan

*changelog:

*2026-08-04    Raja Arsalan        SFP-59623 -  Modified the submitConnexBatch 
								   method to process maximum of 10 leads per batch.
*/

// This class runs **without sharing** to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_UTIL_LeadTrigger {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadTrigger.class.getName());
    public static Boolean skipConnexCallout = false;
    private static Map<String, INS_Insurance_Lead_Settings__mdt> LeadSettingsMap = new Map<String, INS_Insurance_Lead_Settings__mdt>();
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> {CampaignMember.SObjectType, Task.SObjectType});
    
    // Static state management to replace instance variables
    private static Set<Id> duplicateLeadIdsToSkip = new Set<Id>();
    private static Boolean stateInitialized = false;
    private static Map<Id, Leads_ProductQueueAllocation__c> cachedProductMap;
    private static Map<String, Lead> originalBatchLeadByDuplicateKey = new Map<String, Lead>();
    private static Map<String, Id> primaryLeadByDuplicateKey = new Map<String, Id>();
    private static List<Task> duplicateTasksToInsert = new List<Task>();
    
    
    
    /**
* @description Initialize state for trigger processing
* Clears duplicate tracking and resets cached data for new trigger execution
*/
    public static void initializeState() {
        duplicateLeadIdsToSkip.clear();
        cachedProductMap = null;
        originalBatchLeadByDuplicateKey.clear();
        primaryLeadByDuplicateKey.clear();
        stateInitialized = true;
    }
    
    /**
* @description Get leads that should be skipped (non-duplicates)
* Filters out leads marked as duplicates or with duplicate reference numbers
* @param allLeads List of all leads to filter
* @return List<Lead> Non-duplicate leads for processing
*/
    public static List<Lead> getNonDuplicateLeads(List<Lead> allLeads) {
        if (!stateInitialized) initializeState();
        
        List<Lead> nonDuplicates = new List<Lead>();
        for (Lead lead : allLeads) {
            if (!duplicateLeadIdsToSkip.contains(lead.Id) && 
                lead.Referred_System_Reference_Number__c != 'Duplicate') {
                    nonDuplicates.add(lead);
                }
        }
        return nonDuplicates;
    }
    
    
    /**
* @description Format mobile numbers for SBIB leads by normalizing South African numbers
* Converts various South African number formats to standardized +27 format
* @param leads List of Lead records to process
*/
    public static void formatNumbers(List<Lead> leads) {
        Map<Id, Leads_ProductQueueAllocation__c> productMap = fetchProductAllocations(leads);
        for(Lead l : leads) {
            if (isValidProductLead(l, productMap.get(l.Expressed_Interest_Product__c),'Dialer_Leads')) {
                String normalizedMobile = formatSouthAfricanNumber(l.MobilePhone, true);
                l.MobilePhone = normalizedMobile;
            }
        }
    }
    
    /**
* @description Check for duplicate leads with state preservation
* Identifies duplicate leads based on last name, campaign source, and mobile number
* Marks duplicates and creates tracking tasks
* @param newLeads List of new Lead records to check for duplicates
*/
    public static void checkForDuplicates(List<Lead> newLeads) {
        if (!stateInitialized) initializeState();
        
        try {
            Map<Id, Leads_ProductQueueAllocation__c> productMap = fetchProductAllocations(newLeads);
            Map<String, List<Lead>> leadsToCheckMap = getLeadsEligibleForDuplicateCheck(newLeads, productMap);
            if (leadsToCheckMap.isEmpty()) {
                return;
            }
            
            //NewLeads: Check for duplicates within the same batch first
            Map<String, List<Lead>> intraBatchDuplicates = findIntraBatchDuplicates(leadsToCheckMap);
            
            // EXISTINGLeads: Check for duplicates in the database
            Map<String, Lead> existingLeadsMap = findExistingDuplicates(leadsToCheckMap.keySet());
            
            
            if (existingLeadsMap.isEmpty() && intraBatchDuplicates.isEmpty()) {
                return;
            }
            
            // Process both intra-batch and existing duplicates
            applyDuplicateRulesAndAddErrors(leadsToCheckMap, existingLeadsMap, intraBatchDuplicates);
            
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | checkForDuplicates | exception | ' + ex);
        }
    }
    
    
    /**
* @description NEW: Find duplicates within the same batch of incoming leads
* Compares leads against each other in the current transaction to identify intra-batch duplicates
* @param leadsToCheckMap Map of leads eligible for duplicate checking
* @return Map<String, List<Lead>> Map of intra-batch duplicate leads (all duplicate occurrences)
*/
    private static Map<String, List<Lead>> findIntraBatchDuplicates(Map<String, List<Lead>> leadsToCheckMap) {
        Map<String, List<Lead>> intraBatchDuplicates = new Map<String, List<Lead>>();
        
        for (String key : leadsToCheckMap.keySet()) {
            List<Lead> leadsForKey = leadsToCheckMap.get(key);
            if (leadsForKey.size() > 1) {
                List<Lead> duplicates = new List<Lead>();
                for (Integer i = 1; i < leadsForKey.size(); i++) {
                    duplicates.add(leadsForKey[i]);
                }
                intraBatchDuplicates.put(key, duplicates);
            }
        }
        
        return intraBatchDuplicates;
    }
    
    /**
* @description Sync leads with campaigns based on campaign source and update campaign names
* Updates lead campaign names and dialer queue IDs based on campaign source
* @param leads List of Lead records to sync with campaigns
* @param oldMap Map of old Lead records before update
*/
    public static void syncLeadsWithCampaigns(List<Lead> leads, Map<Id, Lead> oldMap) {
        try{
            Set<String> campaignSourceIds = getUpdatedCampaignSourceIds(leads, oldMap);
            if (!campaignSourceIds.isEmpty()) {
                Map<String, Campaign> campaignMap = fetchCampaignsBySourceIds(campaignSourceIds);
                updateLeadsWithCampaignNames(leads, campaignMap);
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | syncLeadsWithCampaigns | exception | ' + ex);
        }
    }
    
    /**
* @description Create campaign members for leads based on campaign source and business hours
* Creates campaign members for both source campaigns and courtesy SMS campaigns
* @param triggerLeads List of Lead records from trigger
* @param oldMap Map of old Lead records before update
* @param isInsert Boolean indicating if this is an insert operation
*/
    public static void createCampaignMembers(List<Lead> triggerLeads, Map<Id, Lead> oldMap, Boolean isInsert) {
        try {
            List<Lead> successfulLeads = getSuccessfulLeads(triggerLeads);
            if (successfulLeads.isEmpty()) return;
            
            Map<String, Campaign> campaignMap = getRelevantCampaigns(successfulLeads, oldMap);
            
            CampaignMemberPreparationData preparationData = prepareCampaignMemberData(successfulLeads, campaignMap);
            Map<String, CampaignMember> existingCMMap = getExistingCampaignMembers(preparationData.leadIds, preparationData.campaignIds);         
            Set<Id> eligibleCourtesyLeads = getEligibleCourtesyLeads(successfulLeads);
            
            List<CampaignMember> members = prepareCampaignMembers(
                successfulLeads, 
                campaignMap, 
                existingCMMap, 
                isInsert, 
                eligibleCourtesyLeads
            );
            
            registerCampaignMembers(members);
            
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | createCampaignMembers | exception | ' + ex);
        }
    }
    
    /**
* @description Filter leads that have been successfully saved (have IDs)
* @param triggerLeads List of leads from trigger
* @return List<Lead> Leads with non-null IDs
*/
    private static List<Lead> getSuccessfulLeads(List<Lead> triggerLeads) {
        List<Lead> successfulLeads = new List<Lead>();
        for (Lead l : triggerLeads) {
            if (l.Id != null) successfulLeads.add(l);
        }
        return successfulLeads;
    }
    
    /**
* @description Get relevant campaigns based on updated campaign sources
* @param successfulLeads Leads to process
* @param oldMap Map of old lead values
* @return Map<String, Campaign> Campaigns mapped by source ID
*/
    private static Map<String, Campaign> getRelevantCampaigns(List<Lead> successfulLeads, Map<Id, Lead> oldMap) {
        Set<String> campaignSourceIds = getUpdatedCampaignSourceIds(successfulLeads, oldMap);
        if (campaignSourceIds.isEmpty()) {
            return new Map<String, Campaign>();
        }
        return fetchCampaignsBySourceIds(campaignSourceIds);
    }
    
    /**
* @description Data container for campaign member preparation
*/
    private class CampaignMemberPreparationData {
        public Set<Id> leadIds { get; set; }
        public Set<Id> campaignIds { get; set; }
        public Set<Id> courtesyLeadIds { get; set; }
        
        public CampaignMemberPreparationData() {
            this.leadIds = new Set<Id>();
            this.campaignIds = new Set<Id>();
            this.courtesyLeadIds = new Set<Id>();
        }
    }
    
    /**
* @description Prepare campaign member data by collecting relevant IDs
* @param successfulLeads Leads to process
* @param campaignMap Map of campaigns by source ID
* @return CampaignMemberPreparationData Collected IDs for processing
*/
    private static CampaignMemberPreparationData prepareCampaignMemberData(List<Lead> successfulLeads, Map<String, Campaign> campaignMap) {
        CampaignMemberPreparationData data = new CampaignMemberPreparationData();
        
        for (Lead l : successfulLeads) {
            data.courtesyLeadIds.add(l.Id);
            if (l.Campaign_Source_ID__c != null && campaignMap.containsKey(l.Campaign_Source_ID__c)) {
                data.leadIds.add(l.Id);
                Campaign campaign = campaignMap.get(l.Campaign_Source_ID__c);
                if (campaign != null) {
                    data.campaignIds.add(campaign.Id);
                }
            }
        }
        
        return data;
    }
    
    /**
* @description Get existing campaign members to avoid duplicates
* @param leadIds Set of lead IDs to check
* @param campaignIds Set of campaign IDs to check
* @return Map<String, CampaignMember> Existing campaign members mapped by composite key
*/
    private static Map<String, CampaignMember> getExistingCampaignMembers(Set<Id> leadIds, Set<Id> campaignIds) {
        if (leadIds.isEmpty() || campaignIds.isEmpty()) {
            return new Map<String, CampaignMember>();
        }
        
        List<CampaignMember> existingCMList = new SEL_CampaignMember().selectCampaignMembersByLeadAndCampaignIds(leadIds, campaignIds);
        Map<String, CampaignMember> existingCMMap = new Map<String, CampaignMember>();
        
        for (CampaignMember cm : existingCMList) {
            String key = cm.LeadId + '-' + cm.CampaignId;
            existingCMMap.put(key, cm);
        }
        
        return existingCMMap;
    }
    
    /**
* @description Get leads eligible for courtesy SMS campaigns
* @param courtesyLeadIds Set of lead IDs to check for courtesy eligibility
* @return Set<Id> Set of lead IDs eligible for courtesy SMS
*/
    private static Set<Id> getEligibleCourtesyLeads(Set<Id> courtesyLeadIds) {
        return new Set<Id>(new SEL_Lead().selectLeadsEligibleForCourtesySMS(courtesyLeadIds).keySet());
    }
    
    /**
* @description Overloaded method for courtesy lead eligibility
* @param successfulLeads List of leads to check for courtesy eligibility
* @return Set<Id> Set of lead IDs eligible for courtesy SMS
*/
    private static Set<Id> getEligibleCourtesyLeads(List<Lead> successfulLeads) {
        Set<Id> courtesyLeadIds = new Set<Id>();
        for (Lead l : successfulLeads) {
            courtesyLeadIds.add(l.Id);
        }
        return getEligibleCourtesyLeads(courtesyLeadIds);
    }
    
    
    /**
* @description Register campaign members with Unit of Work
* @param members
*/
    private static void registerCampaignMembers(List<CampaignMember> members) {
        if (members.isEmpty()) {
            return;
        }
        for (CampaignMember member : members) {
            uow.registerNew(member);
        }
        uow.commitWork();
    }
    
    /**
* @description Maintain lead status based on business rules when lead is qualified and has reference number
* Updates lead status to 'Onboarding' when qualified with reference number but no related account
* @param leads List of Lead records to update status
*/
    public static void maintainLeadStatus(List<Lead> leads) {
        for (Lead lead : leads) {
            if (lead.Referred_System_Reference_Number__c != null && lead.Status == 'Qualified' && lead.FinServ__RelatedAccount__c == null) {
                lead.Status = 'Onboarding';
                lead.Stage__c = 'Onboarding in Progress';
            }
        }
    }
    
    /**
* @description Assign owner from dialer agent ID when agent ID changes
* Updates lead owner based on changed dialer agent employee number
* @param newLeads List of new Lead records
* @param oldLeadMap Map of old Lead records before update
*/
    public static void assignOwnerFromDialerAgentId(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        try {
            Map<Id, String> leadIdToChangedAgentId = identifyChangedAgentLeads(newLeads, oldLeadMap);
            if (leadIdToChangedAgentId.isEmpty()) {
                return;
            }
            
            Set<String> changedAgentIds = new Set<String>(leadIdToChangedAgentId.values());
            Map<String, User> agentIdToUserMap = new SEL_User().selectByUserEmail(changedAgentIds);
            updateLeadOwners(newLeads, leadIdToChangedAgentId, agentIdToUserMap);
            
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | assignOwnerFromDialerAgentId | exception | ' + ex);
        }
    }
    
    /**
* @description Process leads for Connex integration based on eligibility and changes.
*
* ── WHERE THIS FITS IN THE FLOW ──────────────────────────────────────────────
* Called from CMN_TRH_Lead.bulkAfter() on every Lead insert or update.
* Guard in CMN_TRH_Lead: only runs when skipConnexCallout=false and not in a batch context.
*
* This method categorises each lead into one of three buckets:
*
*   1. expressedInterestChangedLeads
*      Expressed_Interest_Product__c changed AND lead already exists in the dialler
*      (has a non-blank, non-Duplicate Referred_System_Reference_Number__c).
*      Must expire the old dialler record (PUT) then re-create under the new queue (POST).
*      → submitConnexBatch(leads, isExpressedInterestChanged=true)
*      → INS_BATCH_DiallerLead branches to processExpressedInterestChangedLeads()
*
*   2. qualifiedLeads
*      Brand new lead (no ref#) OR lead info changed (name/phone/etc.) on an existing record.
*      Normal POST for new leads; normal PUT for info updates.
*      → submitConnexBatch(leads, isExpressedInterestChanged=false)
*      → INS_BATCH_DiallerLead routes to processLeadscallout()
*
*   3. ignored
*      Unqualified leads, leads with future preferred contact times, duplicates.
*
* ─────────────────────────────────────────────────────────────────────────────
* @param newLeads List of new Lead records
* @param oldLeadMap Map of old Lead records before update
*/
    public static void processLeadsForConnex(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        System.debug('>>> processLeadsForConnex | ENTERED | total leads=' + newLeads.size());
        List<Lead> leadsToProcess = filterEligibleLeads(newLeads);
        System.debug('>>> processLeadsForConnex | after filterEligibleLeads=' + leadsToProcess.size());
        if (leadsToProcess.isEmpty()) {
            System.debug('>>> processLeadsForConnex | EXITING — no eligible leads after filter');
            return;
        }
        
        ConnexProcessingResult result = processLeadsForConnexEligibility(leadsToProcess, oldLeadMap);
        executeConnexProcessing(result);
    }
    
    /**
* @description Filter leads that are eligible for Connex processing
* @param newLeads List of all new leads
* @return List<Lead> Filtered leads eligible for processing
*/
    private static List<Lead> filterEligibleLeads(List<Lead> newLeads) {
        List<Lead> eligibleLeads = new List<Lead>();
        for (Lead lead : newLeads) {
            if (isLeadEligibleForConnex(lead)) {
                eligibleLeads.add(lead);
            }
        }
        return eligibleLeads;
    }
    
    /**
* @description Check if a lead is eligible for Connex processing
* @param lead Lead to check
* @return Boolean True if lead is eligible
*/
    private static Boolean isLeadEligibleForConnex(Lead lead) {
        return lead.Id != null && lead.Referred_System_Reference_Number__c != 'Duplicate';
    }
    
    /**
* @description Container for Connex processing results.
*
* qualifiedLeads             → normal POST (new) or PUT (info changed) path
* expressedInterestChangedLeads → two-step PUT-expire + POST-recreate path
* leadsToUpdate              → legacy clone path (not used in current flow)
*/
    private class ConnexProcessingResult {
        public List<Lead> qualifiedLeads { get; set; }
        public List<Lead> leadsToUpdate { get; set; }
        public List<Lead> expressedInterestChangedLeads { get; set; }
        
        public ConnexProcessingResult() {
            this.qualifiedLeads = new List<Lead>();
            this.leadsToUpdate = new List<Lead>();
            this.expressedInterestChangedLeads = new List<Lead>();
        }
    }
    
    /**
* @description Process leads to determine Connex eligibility
* @param leadsToProcess List of leads to evaluate
* @param oldLeadMap Map of old lead values
* @return ConnexProcessingResult Result containing qualified leads and leads to update
*/

    private static ConnexProcessingResult processLeadsForConnexEligibility(List<Lead> leadsToProcess, Map<Id, Lead> oldLeadMap) {
        ConnexProcessingResult result = new ConnexProcessingResult();
        Map<Id, Leads_ProductQueueAllocation__c> productMap = fetchProductAllocations(leadsToProcess);
        
        for (Lead lead : leadsToProcess) {
            processSingleLeadForConnex(lead, productMap, oldLeadMap, result);
        }
        
        return result;
    }
    
    /**
* @description Process a single lead for Connex eligibility
* @param lead Lead to process
* @param productMap Map of product allocations
* @param oldLeadMap Map of old lead values
* @param result ConnexProcessingResult to update with results
*/

    private static void processSingleLeadForConnex(Lead lead, Map<Id, Leads_ProductQueueAllocation__c> productMap,Map<Id, Lead> oldLeadMap, ConnexProcessingResult result) {
        Boolean isValid = isValidProductLead(lead, productMap.get(lead.Expressed_Interest_Product__c),'Dialer_Leads');
        System.debug('>>> processSingleLeadForConnex | leadId=' + lead.Id
            + ' | isValidProductLead=' + isValid
            + ' | Expressed_Interest_Product__c=' + lead.Expressed_Interest_Product__c);
        if (!isValid) {
            System.debug('>>> processSingleLeadForConnex | leadId=' + lead.Id + ' DROPPED — did not pass isValidProductLead');
            return;
        }
        
        LeadProcessingDecision decision = evaluateLeadProcessingDecision(lead, oldLeadMap);
        applyLeadProcessingDecision(lead, decision, result);
    }
    
    /**
* @description Container for lead processing decision
*/
    private class LeadProcessingDecision {
        public Boolean isEligibleForCallout { get; set; }
        public Boolean isExpressedInterestChanged { get; set; }
        public Boolean infoChanged { get; set; }
        
        public LeadProcessingDecision() {
            this.isEligibleForCallout = false;
            this.isExpressedInterestChanged = false;
            this.infoChanged = false;
        }
    }
    
    /**
* @description Evaluate how a lead should be processed for Connex
* @param lead Lead to evaluate
* @param oldLeadMap Map of old lead values
* @return LeadProcessingDecision Decision on how to process the lead
*/

    private static LeadProcessingDecision evaluateLeadProcessingDecision(Lead lead, Map<Id, Lead> oldLeadMap) {
        LeadProcessingDecision decision = new LeadProcessingDecision();
        
        decision.isEligibleForCallout = eligibleForConnexInsert(lead, oldLeadMap);
        // Check whether Expressed_Interest_Product__c changed from the old value.
        // A non-blank, non-Duplicate reference number means the lead already exists in the
        // dialler — it needs to be expired first, then re-created under the new queue.
        decision.isExpressedInterestChanged = hasExpressedInterestChanged(lead, oldLeadMap);
        
        if (oldLeadMap != null && oldLeadMap.containsKey(lead.Id)) {
            decision.infoChanged = leadInfoChanged(lead, oldLeadMap.get(lead.Id));
        }

        // DEBUG: See exactly what decision was made for this lead
        System.debug('>>> evaluateLeadProcessingDecision | leadId=' + lead.Id
            + ' | isExpressedInterestChanged=' + decision.isExpressedInterestChanged
            + ' | isEligibleForCallout=' + decision.isEligibleForCallout
            + ' | infoChanged=' + decision.infoChanged
            + ' | ref#=' + lead.Referred_System_Reference_Number__c
            + ' | product=' + lead.Expressed_Interest_Product__c);
        
        return decision;
    }
    
    /**
* @description Apply the processing decision to the correct result bucket.
*
* Priority order matters:
*   isExpressedInterestChanged is checked FIRST because it requires a non-blank
*   reference number, making it mutually exclusive with isEligibleForCallout
*   (which requires a null reference number). Checking expressed-interest first
*   is defensive — if logic ever changes and both become true simultaneously,
*   the two-step flow (expire + recreate) is the safer choice over a plain POST.
*/
    private static void applyLeadProcessingDecision(Lead lead, LeadProcessingDecision decision, ConnexProcessingResult result) {
        if (decision.isExpressedInterestChanged) {
            // Lead exists in dialler under wrong queue — must expire it first, then recreate.
            System.debug('>>> applyLeadProcessingDecision | leadId=' + lead.Id + ' → expressedInterestChangedLeads bucket');
            result.expressedInterestChangedLeads.add(lead);
        } else if (decision.isEligibleForCallout) {
            // New lead or retry (no ref#) — goes to normal POST path.
            System.debug('>>> applyLeadProcessingDecision | leadId=' + lead.Id + ' → qualifiedLeads bucket (new/retry POST)');
            result.qualifiedLeads.add(lead);
        } else if (decision.infoChanged) {
            // Lead info (name/phone/etc.) changed on an existing dialler record — normal PUT.
            System.debug('>>> applyLeadProcessingDecision | leadId=' + lead.Id + ' → qualifiedLeads bucket (info changed PUT)');
            result.qualifiedLeads.add(lead);
        } else {
            System.debug('>>> applyLeadProcessingDecision | leadId=' + lead.Id + ' → IGNORED (no matching condition)');
        }
    }
    
    /**
* @description Execute the final Connex processing based on results.
* Each bucket fires a separate async batch so the two flows never share
* a batch scope and cannot interfere with each other's classification logic.
*/
    private static void executeConnexProcessing(ConnexProcessingResult result) {
        // DEBUG: See the final counts before firing the batches
        System.debug('>>> executeConnexProcessing | qualifiedLeads=' + result.qualifiedLeads.size()
            + ' | expressedInterestChangedLeads=' + result.expressedInterestChangedLeads.size());

        // Normal path: new leads (POST) and info-changed leads (PUT) go here.
        if (!result.qualifiedLeads.isEmpty()) {
            System.debug('>>> executeConnexProcessing | firing NORMAL batch for ' + result.qualifiedLeads.size() + ' leads');
            submitConnexBatch(result.qualifiedLeads, false);
        }
        // Expressed-interest-changed path: separate batch with isExpressedInterestChanged=true.
        // INS_BATCH_DiallerLead.execute() will branch to processExpressedInterestChangedLeads().
        if (!result.expressedInterestChangedLeads.isEmpty()) {
            System.debug('>>> executeConnexProcessing | firing EXPRESSED INTEREST batch for ' + result.expressedInterestChangedLeads.size() + ' leads');
            submitConnexBatch(result.expressedInterestChangedLeads, true);
        }
    }
    
    
    /**
* @description UPDATED: Apply duplicate rules and add errors to duplicate leads with state tracking
* Marks duplicate leads and creates tracking tasks for both existing and intra-batch duplicates
* @param leadsToCheckMap Map of leads to check for duplicates
* @param existingLeadsMap Map of existing duplicate leads from database
* @param intraBatchDuplicates Map of intra-batch duplicate leads
*/
    private static void applyDuplicateRulesAndAddErrors(Map<String, List<Lead>> leadsToCheckMap, Map<String, Lead> existingLeadsMap, Map<String, List<Lead>> intraBatchDuplicates) {
        Set<Id> duplicateLeadIds = new Set<Id>();
        
        for (String key : leadsToCheckMap.keySet()) {
            List<Lead> leadGroup = leadsToCheckMap.get(key);
            Lead existingLead = existingLeadsMap.get(key);
            if (existingLead != null) {
                for (Lead newLead : leadGroup) {
                    if (isDuplicateBasedOnRules(newLead, existingLead)) {
                        newLead.Referred_System_Reference_Number__c = 'Duplicate';
                        prepareDuplicateTask(existingLead, newLead);
                        if (newLead.Id != null) {
                            duplicateLeadIds.add(newLead.Id);
                        }
                    }
                }
                continue;
            }
            
            List<Lead> duplicatesInBatch = intraBatchDuplicates.get(key);
            if (duplicatesInBatch != null && !duplicatesInBatch.isEmpty()) {
                Lead originalLead = leadGroup[0];
                if (originalLead.Referred_System_Reference_Number__c == 'Duplicate') {
                    for (Lead lead : leadGroup) {
                        if (lead.Referred_System_Reference_Number__c != 'Duplicate') {
                            originalLead = lead;
                            break;
                        }
                    }
                }
                if (originalLead != null) {
                    originalBatchLeadByDuplicateKey.put(key, originalLead);
                }
                for (Lead duplicateLead : duplicatesInBatch) {
                    duplicateLead.Referred_System_Reference_Number__c = 'Duplicate';
                    if (duplicateLead.Id != null) {
                        duplicateLeadIds.add(duplicateLead.Id);
                    }
                }
            }
        }
        
        if (!duplicateLeadIds.isEmpty()) {
            duplicateLeadIdsToSkip.addAll(duplicateLeadIds);
        }
        
        // Store actual primary lead object (NOT ID)
        // because before insert IDs are still null
        
        for (String key : leadsToCheckMap.keySet()) {
            
            List<Lead> leadGroup = leadsToCheckMap.get(key);
            
            for (Lead l : leadGroup) {
                
                if (l.Referred_System_Reference_Number__c != 'Duplicate') {                    
                    originalBatchLeadByDuplicateKey.put(key, l);
                    break;
                }
            }
        }
    }
    
    
    /**
* @description Fetch product queue allocations for leads with caching for performance
* @param leads List of leads to get product allocations for
* @return Map<Id, Leads_ProductQueueAllocation__c> Product allocations by product queue ID
*/
    public static Map<Id, Leads_ProductQueueAllocation__c> fetchProductAllocations(List<Lead> leads) {
        // Cache product map for performance
        if (cachedProductMap != null) {
            return cachedProductMap;
        }
        
        Set<Id> productQueueIds = new Set<Id>();
        for (Lead lead : leads) {
            if (lead.Expressed_Interest_Product__c != null) {
                productQueueIds.add(lead.Expressed_Interest_Product__c);
            }
        }
        
        if (productQueueIds.isEmpty()){
            cachedProductMap = new Map<Id, Leads_ProductQueueAllocation__c>();
            return cachedProductMap;
        }
        
        List<Leads_ProductQueueAllocation__c> queueList = new INS_SEL_Leads_ProductQueueAllocation().selectProductQueueByIds(productQueueIds);
        
        Map<Id, Leads_ProductQueueAllocation__c> result = new Map<Id, Leads_ProductQueueAllocation__c>();
        for (Leads_ProductQueueAllocation__c record : queueList) {
            result.put(record.Id, record);
        }
        
        cachedProductMap = result;
        return cachedProductMap;
    }
    
    /**
* @description Check if lead is valid for insurance product processing
* @param lead Lead record to validate
* @param relatedProduct Related product queue allocation
* @return Boolean True if lead is valid for insurance processing
*/
    public static Boolean isValidProductLead(Lead lead, Leads_ProductQueueAllocation__c relatedProduct, String LeadsSetting) {
        if (lead.Expressed_Interest_Product__c == null) {
            return false;
        }
        
        loadProductSettings(LeadsSetting);
        INS_Insurance_Lead_Settings__mdt leadSetting = LeadSettingsMap.get(LeadsSetting);
        
        try {
            Date leadDate = Trigger.isInsert
                ? Date.today()
                : (lead.CreatedDate == null ? null : lead.CreatedDate.date());
                    
                    return leadSetting != null &&
                    relatedProduct.Leads_Product_Family__c == leadSetting.INS_ProductFamily__c &&
                    relatedProduct.Lead_Type__c == leadSetting.INS_LeadType__c &&
                    (leadDate == null || leadDate >= leadSetting.INS_LeadDate__c);
            
        } catch (Exception ex) {
            LOGGER.error(
                'INS_UTIL_LeadTrigger | isValidProductLead | exception | ' + ex
            );
            return false;
        }
    }
    
    /**
* @description Format South African mobile numbers to standardized format
* @param mobileNumber Mobile number to format
* @param includePlus Whether to include + prefix
* @return String Formatted mobile number
*/
    private static String formatSouthAfricanNumber(String mobileNumber, Boolean includePlus) {
        if (String.isBlank(mobileNumber)) {
            return mobileNumber;
        }
        
        String cleaned = mobileNumber.replaceAll('[\\s\\-()]+', '');
        
        if (cleaned.startsWith('0027')) {
            cleaned = cleaned.substring(4);
        } else if (cleaned.startsWith('+27')) {
            cleaned = cleaned.substring(3);
        } else if (cleaned.startsWith('27')) {
            cleaned = cleaned.substring(2);
        } else if (cleaned.startsWith('0')) {
            cleaned = cleaned.substring(1);
        }
        
        return (includePlus ? '+27' : '27') + cleaned;
    }
    
    /**
* @description Get campaign source IDs that have been updated in current transaction
* @param leads List of leads to check for campaign source changes
* @param oldMap Map of old lead values
* @return Set<String> Set of updated campaign source IDs
*/
    private static Set<String> getUpdatedCampaignSourceIds(List<Lead> leads, Map<Id, Lead> oldMap) {
        Set<String> campaignSourceIds = new Set<String>();
        try {
            for (Lead lead : leads) {
                if (lead.Campaign_Source_ID__c != null) {
                    if (oldMap == null || oldMap.get(lead.Id)?.Campaign_Source_ID__c != lead.Campaign_Source_ID__c) {
                        campaignSourceIds.add(lead.Campaign_Source_ID__c);
                    }
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | getUpdatedCampaignSourceIds | exception | ' + ex);
        }
        return campaignSourceIds;
    }
    
    /**
* @description Fetch campaigns by their source IDs
* @param campaignSourceIds Set of campaign source IDs to fetch
* @return Map<String, Campaign> Campaigns mapped by source ID
*/
    private static Map<String, Campaign> fetchCampaignsBySourceIds(Set<String> campaignSourceIds) {
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        try {
            for (Campaign campaign : new SEL_Campaign().selectByCampaignSourceIds(campaignSourceIds)) {
                campaignMap.put(campaign.Campaign_Source_ID__c, campaign);
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | getUpdatedCampaignSourceIds | exception | ' + ex);
        }
        return campaignMap;
    }
    
    /**
* @description Update leads with campaign names from campaign map
* @param leads List of leads to update
* @param campaignMap Map of campaigns by source ID
*/
    private static void updateLeadsWithCampaignNames(List<Lead> leads, Map<String, Campaign> campaignMap) {
        try {
            for (Lead lead : leads) {
                if (lead.Campaign_Source_ID__c != null) {
                    Campaign relatedCampaign = campaignMap.get(lead.Campaign_Source_ID__c);
                    if (relatedCampaign != null) {
                       // Check SBIB 
                        System.debug('Express Interest Lead Type: ' + lead.Expressed_Interest_Product__r.Lead_Type__c);
                        lead.Campaign_Name__c = relatedCampaign.Name;
                        lead.Dialler_Queue_ID__c = relatedCampaign.Dialler_System_Code__c;
                    }
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | updateLeadsWithCampaignNames | exception | ' + ex);
        }
    }
    
    /**
* @description Identify leads with changed dialer agent IDs
* @param newLeads List of new lead records
* @param oldLeadMap Map of old lead records
* @return Map<Id, String> Map of lead IDs to changed agent IDs
*/
    private static Map<Id, String> identifyChangedAgentLeads(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        Map<Id, String> changedMap = new Map<Id, String>();
        
        try {
            for (Lead l : newLeads) {
                if (oldLeadMap == null || !oldLeadMap.containsKey(l.Id)) {
                    continue;
                }
                
                Lead oldLead = oldLeadMap.get(l.Id);
                if (oldLead != null && l.Dialer_Agent_Id__c != oldLead.Dialer_Agent_Id__c && !String.isBlank(l.Dialer_Agent_Id__c)) {
                    changedMap.put(l.Id, l.Dialer_Agent_Id__c);
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | identifyChangedAgentLeads | exception | ' + ex);
        }
        
        return changedMap;
    }
    
    /**
* @description Update lead owners based on changed agent IDs
* @param leads List of leads to update owners for
* @param changedMap Map of lead IDs to changed agent IDs
* @param userMap Map of users by employee number
*/
    private static void updateLeadOwners(List<Lead> leads, Map<Id, String> changedMap, Map<String, User> userMap) {
        try {
            for (Lead l : leads) {
                if (l.Status != 'Qualified' && l.Status != 'Unqualified' && l.Status != 'Onboarding') {
                    continue;
                }
                
                if (l.Referred_System_Reference_Number__c == null) {
                    continue;
                }
                
                String agentId = changedMap.get(l.Id);
                if (agentId != null && userMap.containsKey(agentId)) {
                    l.OwnerId = userMap.get(agentId).Id;
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | updateLeadOwners | exception | ' + ex);
        }
    }
    
    /**
* @description Prepare campaign members for insertion based on business rules
* @param leads List of leads to create campaign members for
* @param campaignMap Map of campaigns by source ID
* @param existingCMMap Map of existing campaign members
* @param isInsert Whether this is an insert operation
* @param leadsEligibleForCourtesyCM Leads eligible for courtesy campaign members
* @return List<CampaignMember> List of campaign members to insert
*/
    private static List<CampaignMember> prepareCampaignMembers(List<Lead> leads, Map<String, Campaign> campaignMap, Map<String, CampaignMember> existingCMMap, Boolean isInsert, Set<Id> leadsEligibleForCourtesyCM) {
        List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();
        
        try {
            Set<String> holidays = loadPublicHolidays();
            List<Campaign> courtesyCampaigns = loadCourtesyCampaigns();
            
            for (Lead lead : leads) {
                handleCampaignSource(lead, campaignMap, existingCMMap, campaignMembersToInsert);
                handleCourtesyCampaign(lead, isInsert, courtesyCampaigns, leadsEligibleForCourtesyCM, holidays, existingCMMap, campaignMembersToInsert);
            }
            
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | prepareCampaignMembers | exception | ' + ex);
        }
        
        return campaignMembersToInsert;
    }
    
    /**
* @description Load public holidays from custom metadata
* @return Set<String> Set of holiday dates in MM-dd format
*/
    private static Set<String> loadPublicHolidays() {
        Set<String> holidays = new Set<String>();
        loadProductSettings('Public_Holidays');
        INS_Insurance_Lead_Settings__mdt holidaySetting = LeadSettingsMap.get('Public_Holidays');
        
        if (holidaySetting != null && String.isNotBlank(holidaySetting.INS_HolidayDates__c)) {
            holidays.addAll(holidaySetting.INS_HolidayDates__c.split(';'));
        }
        
        return holidays;
    }
    
    /**
* @description Load courtesy campaign records
* @return List<Campaign> List of courtesy campaigns
*/
    private static List<Campaign> loadCourtesyCampaigns() {
        List<String> courtesyCampsList = new List<String>{'INS_CRTSY_BUSHR_SMS','INS_CRTSY_NONBUSHR_SMS'};
            return new SEL_Campaign().selectCampaignsByName(courtesyCampsList);
    }
    
    /**
* @description Handle campaign source membership creation
* @param lead Lead record to process
* @param campaignMap Map of campaigns by source ID
* @param existingCMMap Map of existing campaign members
* @param campaignMembersToInsert List to add new campaign members to
*/
    private static void handleCampaignSource(Lead lead, Map<String, Campaign> campaignMap, Map<String, CampaignMember> existingCMMap, List<CampaignMember> campaignMembersToInsert) {
        if (lead.Campaign_Source_ID__c != null) {
            Campaign relatedCampaign = campaignMap.get(lead.Campaign_Source_ID__c);
            if (relatedCampaign != null) {
                String key = lead.Id + '-' + relatedCampaign.Id;
                if (!existingCMMap.containsKey(key)) {
                    campaignMembersToInsert.add(new CampaignMember(
                        LeadId = lead.Id,
                        CampaignId = relatedCampaign.Id,
                        Status = lead.Status
                    ));
                }
            }
        }
    }
    
    /**
* @description Handle courtesy campaign member creation based on business hours
* @param lead Lead record to process
* @param isInsert Whether this is an insert operation
* @param courtesyCampaigns List of courtesy campaigns
* @param eligibleLeads Set of leads eligible for courtesy campaigns
* @param holidays Set of public holidays
* @param existingCMMap Map of existing campaign members
* @param campaignMembersToInsert List to add new campaign members to
*/
    private static void handleCourtesyCampaign(Lead lead, Boolean isInsert, List<Campaign> courtesyCampaigns, Set<Id> eligibleLeads, Set<String> holidays, Map<String, CampaignMember> existingCMMap, List<CampaignMember> campaignMembersToInsert) {
        if (isInsert && courtesyCampaigns != null && eligibleLeads.contains(lead.Id)) {
            CampaignMember cm = createCampaignMemberBasedOnBusinessHours(lead, courtesyCampaigns, holidays);
            if (cm != null) {
                String cmKey = cm.LeadId + '-' + cm.CampaignId;
                if (!existingCMMap.containsKey(cmKey)) {
                    campaignMembersToInsert.add(cm);
                }
            }
        }
    }
    
    /**
* @description Create campaign member based on business hours and holidays
* @param lead Lead record to create campaign member for
* @param campaigns List of courtesy campaigns
* @param holidays Set of public holidays
* @return CampaignMember Campaign member to create, or null if not applicable
*/
    @TestVisible
    private static CampaignMember createCampaignMemberBasedOnBusinessHours(Lead lead, List<Campaign> campaigns, Set<String> holidays) {
        try {
            if (!isValidLeadAndCampaigns(lead, campaigns)){
                return null;
            } 
            
            Datetime saDateTime = getSouthAfricaDateTime(lead.CreatedDate);
            if (saDateTime == null){
                return null;
            }
            
            Boolean isWeekday = isWeekday(saDateTime);
            Boolean isBusinessHours = isWithinBusinessHours(saDateTime.time());
            Boolean isHoliday = holidays.contains(saDateTime.format('MM-dd'));
            
            Id campaignId = getCampaignId(campaigns, isWeekday, isBusinessHours, isHoliday);
            if (campaignId == null){
                return null;
            } 
            
            return buildCampaignMember(lead, campaignId);
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | createCampaignMemberBasedOnBusinessHours | exception | ' + ex);
            return null;
        }
    }
    
    /**
* @description Validate lead and campaigns for courtesy campaign processing
* @param lead Lead record to validate
* @param campaigns List of campaigns to validate
* @return Boolean True if valid for processing
*/
    private static Boolean isValidLeadAndCampaigns(Lead lead, List<Campaign> campaigns) {
        return lead != null && lead.Id != null && lead.CreatedDate != null && campaigns != null && !campaigns.isEmpty();
    }
    
    /**
* @description Convert UTC datetime to South Africa timezone
* @param utcDateTime UTC datetime to convert
* @return Datetime Datetime in South Africa timezone
*/
    private static Datetime getSouthAfricaDateTime(Datetime utcDateTime) {
        TimeZone saTimeZone = TimeZone.getTimeZone('Africa/Johannesburg');
        return utcDateTime != null ? utcDateTime.addSeconds(saTimeZone.getOffset(utcDateTime) / 1000) : null;
    }
    
    /**
* @description Check if datetime is a weekday
* @param dt Datetime to check
* @return Boolean True if weekday
*/
    private static Boolean isWeekday(Datetime dt) {
        String day = dt.format('E', 'en_ZA');
        return day != 'Sat' && day != 'Sun';
    }
    
    /**
* @description Check if time is within business hours (7:00-16:30)
* @param businessTime Time to check
* @return Boolean True if within business hours
*/
    private static Boolean isWithinBusinessHours(Time businessTime) {
        Time startTime = Time.newInstance(7, 0, 0, 0);
        Time endTime = Time.newInstance(16, 30, 0, 0);
        return businessTime >= startTime && businessTime <= endTime;
    }
    
    /**
* @description Get appropriate campaign ID based on business rules
* @param campaigns List of courtesy campaigns
* @param isWeekday Whether it's a weekday
* @param isBusinessHours Whether it's within business hours
* @param isHoliday Whether it's a holiday
* @return Id Campaign ID to use
*/
    private static Id getCampaignId(List<Campaign> campaigns, Boolean isWeekday, Boolean isBusinessHours, Boolean isHoliday) {
        Id businessCampaignId, nonBusinessCampaignId;
        for (Campaign c : campaigns) {
            if (c.Name == 'INS_CRTSY_BUSHR_SMS') {
                businessCampaignId = c.Id;
            }
            else if (c.Name == 'INS_CRTSY_NONBUSHR_SMS') {
                nonBusinessCampaignId = c.Id;
            }
        }
        
        return (isWeekday && isBusinessHours && !isHoliday) ? businessCampaignId : nonBusinessCampaignId;
    }
    
    /**
* @description Build campaign member record with formatted mobile number
* @param lead Lead record for campaign member
* @param campaignId Campaign ID to associate with
* @return CampaignMember Configured campaign member
*/
    private static CampaignMember buildCampaignMember(Lead lead, Id campaignId) {
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.LeadId = lead.Id;
        cm.Status = 'Sent';
        
        if(lead.MobilePhone != null){
            String normalizedMobile = formatSouthAfricanNumber(lead.MobilePhone, false);
            cm.Formatted_Mobile_Number__c = normalizedMobile;
        }             
        return cm;
    }
    
    /**
* @description Clone lead for Connex processing with reset reference number
* @param lead Lead to clone
* @return Lead Cloned lead with reset reference number
*/
    @testVisible
    private static Lead cloneLeadForConnex(Lead lead) {
        Lead cloned = lead.clone(true, true, true, true);
        cloned.Id = lead.Id;
        cloned.OwnerId = lead.OwnerId;
        cloned.Referred_System_Reference_Number__c = null;
        return cloned;
    }
    
    /**
* @description Submit batch job for Connex lead processing
* @param qualifiedLeads List of qualified leads to process
* @param isExpressedInterestChanged Boolean indicating if the expressed interest has changed
*/
    private static void submitConnexBatch(List<Lead> qualifiedLeads,Boolean isExpressedInterestChanged) {
        if (!qualifiedLeads.isEmpty()) {
            INS_Insurance_Lead_Settings__mdt settings = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
            
            List<Id> leadIds = new List<Id>();
            for (Lead l : qualifiedLeads) {
                leadIds.add(l.Id);
            }
            
            // Batch constructor receives the flag so execute() can branch to the
            // correct processing path without re-evaluating lead fields.
            INS_BATCH_DiallerLead batchJob = new INS_BATCH_DiallerLead(
                false,
                null,
                settings.INS_LeadType__c,
                settings.INS_ProductFamily__c,
                settings.INS_LeadDate__c != null ? settings.INS_LeadDate__c.date() : null,
                leadIds,
                isExpressedInterestChanged
            );
            
            Database.executeBatch(batchJob, 10);
        } 
    }
    
    /**
* @description Update cloned leads in database
* @param leadsToUpdate List of cloned leads to update
*/
    private static void updateClonedLeads(List<Lead> leadsToUpdate) {
        if (!leadsToUpdate.isEmpty()) {
            if (Schema.sObjectType.Lead.isUpdateable()) {
                update leadsToUpdate;
            }
        }
        
    }
    
    /**
* @description Check if lead is eligible for Connex insertion
* @param lead Lead to check eligibility for
* @param oldLeadMap Map of old lead values
* @return Boolean True if eligible for Connex processing
*/
    private static Boolean eligibleForConnexInsert(Lead lead, Map<Id, Lead> oldLeadMap) {
        Boolean eligibleForInsert = false;
        try {
            if (Trigger.isInsert) {
                eligibleForInsert = true;
            } else if (lead.Referred_System_Reference_Number__c == null && lead.Status != 'Unqualified' && oldLeadMap != null && oldLeadMap.get(lead.Id) != null && oldLeadMap.get(lead.Id).Status != 'Unqualified') {
                eligibleForInsert = true;
            }
            
            if (!eligibleForInsert) {
                return eligibleForInsert;
            }
            
            eligibleForInsert = isPreferredContactTimeNullOrPast(lead);
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | eligibleForConnexInsert | exception | ' + ex);
            eligibleForInsert = false;
        }
        return eligibleForInsert;
    }
    
    /**
* @description Check if the lead's expressed interest product changed and requires dialler reprocessing.
* When it has, the existing dialler record must be expired (PUT) and the lead re-created under
* the new queue (POST). Only triggers the two-step flow if a reference number already exists —
* a lead without one has never been sent to the dialler and goes through the normal POST path.
* @param lead Lead to check
* @param oldLeadMap Map of old lead values
* @return Boolean True if expressed interest changed and the lead has an existing dialler record
*/
    private static Boolean hasExpressedInterestChanged(Lead lead, Map<Id, Lead> oldLeadMap) {
        try {
            if (Trigger.isInsert || oldLeadMap == null || lead == null) {
                return false;
            }
            
            Lead oldLead = oldLeadMap.get(lead.Id);
            if (oldLead == null || lead.Status == 'Unqualified' || oldLead.Status == 'Unqualified') {
                return false;
            }
            
            /*if (lead.Expressed_Interest_Product__c != oldLead.Expressed_Interest_Product__c) {
                if (lead.Referred_System_Reference_Number__c != null) {
                    return true;
                } else {
                    return isPreferredContactTimeNullOrPast(lead);  
                }
            }*/
            if (lead.Expressed_Interest_Product__c != oldLead.Expressed_Interest_Product__c) {
    // DEBUG: Product changed — show what it changed from and to
    System.debug('>>> hasExpressedInterestChanged | product CHANGED'
        + ' | leadId=' + lead.Id
        + ' | old=' + oldLead.Expressed_Interest_Product__c
        + ' | new=' + lead.Expressed_Interest_Product__c
        + ' | ref#=' + lead.Referred_System_Reference_Number__c);

    // Only route to the expressed interest flow if there's an existing
    // dialler record to expire. Without a reference number, treat it as a
    // fresh new lead — it goes through the normal POST path instead.
    if (String.isNotBlank(lead.Referred_System_Reference_Number__c)
        && lead.Referred_System_Reference_Number__c != 'Duplicate') {
        System.debug('>>> hasExpressedInterestChanged | returning TRUE — lead has ref# and product changed');
        return true;
    }
    // No reference number — fall through, eligibleForConnexInsert() will handle it
    System.debug('>>> hasExpressedInterestChanged | product changed but no ref# — returning FALSE, normal POST will handle it');
}
return false;
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | hasExpressedInterestChanged | exception | ' + ex);
            return false;
        }
    }
    
    /**
* @description Check if lead information has changed requiring Connex update
* @param newLead New version of lead
* @param oldLead Old version of lead
* @return Boolean True if lead information changed
*/
    @TestVisible
    private static Boolean leadInfoChanged(Lead newLead, Lead oldLead) {
        try {
            if (oldLead == null || oldLead.Status == 'Unqualified' || String.isBlank(oldLead.Referred_System_Reference_Number__c)) {
                return false;
            }
            
            return newLead.FirstName != oldLead.FirstName ||
                newLead.LastName != oldLead.LastName ||
                newLead.Title != oldLead.Title ||
                newLead.MobilePhone != oldLead.MobilePhone ||
                newLead.Phone != oldLead.Phone ||
                newLead.Email != oldLead.Email ||
                newLead.Loan_Account_Number__c != oldLead.Loan_Account_Number__c ||
                newLead.Description != oldLead.Description ||
                newLead.Preferred_Contact_Date_Time__c != oldLead.Preferred_Contact_Date_Time__c ||
                newLead.Preferred_Contact_Date_Time_End__c != oldLead.Preferred_Contact_Date_Time_End__c ||
                newLead.SA_ID_or_Passport__c != oldLead.SA_ID_or_Passport__c ||
                newLead.Status == 'Unqualified';
            
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | leadInfoChanged | exception | ' + ex);
            return false;
        }
    }
    
    /**
* @description Check if preferred contact time is null or in the past
* @param lead Lead to check preferred contact time for
* @return Boolean True if preferred contact time is null or past
*/
    private static Boolean isPreferredContactTimeNullOrPast(Lead lead) {
        try {
            DateTime preferredStart = lead.Preferred_Contact_Date_Time__c;
            DateTime preferredEnd   = lead.Preferred_Contact_Date_Time_End__c;
            
            TimeZone saTimeZone = TimeZone.getTimeZone('Africa/Johannesburg');
            DateTime nowInSA = System.now().addSeconds(saTimeZone.getOffset(System.now()) / 1000);
            if (preferredStart == null && preferredEnd == null) {
                return true;
            }
            
            if ((preferredStart != null && preferredStart <= nowInSA) || (preferredEnd != null && preferredEnd <= nowInSA)) {
                return true;
            }
            
            return false;
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | isPreferredContactTimeNullOrPast | exception | ' + ex);
            
            return true;
        }
    }
    
    /**
* @description Load product settings from custom metadata with caching
* @param settingName Name of the custom metadata setting to load
*/
    private static void loadProductSettings(String settingName) {
        if (!LeadSettingsMap.containsKey(settingName)) {
            try {
                INS_Insurance_Lead_Settings__mdt setting = INS_Insurance_Lead_Settings__mdt.getInstance(settingName);
                LeadSettingsMap.put(settingName, setting);
            } catch (Exception ex) {
                LOGGER.error('INS_UTIL_LeadTrigger | loadProductSettings | exception | ' + ex);
            }
        }
    }
    
    // Duplicate checking helper methods
    
    /**
* @description Get leads eligible for duplicate checking based on product validation
* @param newLeads List of new leads to check
* @param productMap Map of product allocations
* @return Map<String, Lead> Map of duplicate keys to leads for checking
*/
    private static Map<String, List<Lead>> getLeadsEligibleForDuplicateCheck(List<Lead> newLeads, Map<Id, Leads_ProductQueueAllocation__c> productMap) {
        Map<String, List<Lead>> leadsToCheckMap = new Map<String, List<Lead>>();
        productMap = fetchProductAllocations(newLeads);
        for (Lead lead : newLeads) {
            if (isValidProductLead(lead, productMap.get(lead.Expressed_Interest_Product__c),'Dialer_Leads')) {  
                if (String.isNotBlank(lead.LastName) && 
                    String.isNotBlank(lead.Campaign_Source_ID__c) && 
                    String.isNotBlank(lead.MobilePhone)) {
                        String key = getDuplicateKey(lead);
                        if (!leadsToCheckMap.containsKey(key)) {
                            leadsToCheckMap.put(key, new List<Lead>());
                        }
                        leadsToCheckMap.get(key).add(lead);
                    }
            }
        }
        return leadsToCheckMap;
    }
    
    /**
* @description Find existing duplicate leads in the system
* @param duplicateKeys Set of duplicate keys to search for
* @return Map<String, Lead> Map of existing duplicate leads by key
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
        
        List<Lead> existingLeads = new SEL_Lead().selectByBulkDuplicateCriteria(lastNames, campaignSourceIds, mobilePhones);
        
        Map<String, Lead> existingLeadsMap = new Map<String, Lead>();
        for (Lead existingLead : existingLeads) {
            String key = getDuplicateKey(existingLead);
            existingLeadsMap.put(key, existingLead);
            
        }
        
        return existingLeadsMap;
    }
    
    /**
* @description Generate duplicate key for lead based on last name, campaign source, and mobile
* @param lead Lead to generate key for
* @return String Duplicate key in lowercase
*/
    private static String getDuplicateKey(Lead lead) {
        return (lead.LastName + '|' + lead.Campaign_Source_ID__c + '|' + lead.MobilePhone).toLowerCase();
    }
    
    /**
* @description Check if lead is active and within 30 days of creation
* @param lead Lead to check activity for
* @return Boolean True if lead is active within 30 days
*/
    private static Boolean isActiveLeadWithin30Days(Lead lead) {
        if (lead == null || lead.CreatedDate == null) {
            return false;
        }
        
        Boolean isActiveStatus = lead.Status == 'New' || 
            lead.Status == 'Working' || 
            lead.Status == 'Waiting for Customer';
        
        Date today = System.today();
        Date createdDate = lead.CreatedDate.date();
        Integer daysBetween = createdDate.daysBetween(today);
        Boolean isWithin30Days = daysBetween <= 30;
        return isActiveStatus && isWithin30Days;
    }
    
    /**
* @description Determine if leads are duplicates based on business rules
* @param newLead New lead to check
* @param existingLead Existing lead to compare with
* @return Boolean True if leads are duplicates based on rules
*/
    private static Boolean isDuplicateBasedOnRules(Lead newLead, Lead existingLead) {

        
        if (newLead.LeadSource != existingLead.LeadSource) {
            return false;
        }
        
        if (isActiveLeadWithin30Days(existingLead)) {
            return true;
        }
        
        if (isRetroLead(newLead) && isRetroLead(existingLead)) {
            return true;
        }
        
        if (isNonRetroLead(newLead) && isNonRetroLead(existingLead)) {

            if (!isActiveLeadWithin30Days(existingLead)) {
                return (existingLead.Status != 'New');
            }
        }
        
        return false;
    }
    
    /**
* @description Check if lead is a retro lead
* @param lead Lead to check
* @return Boolean True if lead source is RETRO
*/
    private static Boolean isRetroLead(Lead lead) {
        return lead.LeadSource == 'RETRO';
    }
    
    /**
* @description Check if lead is a non-retro lead
* @param lead Lead to check
* @return Boolean True if lead source is NON-RETRO
*/
    private static Boolean isNonRetroLead(Lead lead) {
        return lead.LeadSource == 'NON-RETRO';
    } 
    
    
    /**
* @description Checks if lead already exists in database, if so then calls a method to create a task.
* @param existingLead
* @param duplicateLead
*/    
    
    private static void prepareDuplicateTask( Lead existingLead, Lead duplicateLead) {
        
        if (existingLead == null || existingLead.Id == null) {
            return;
        }
        Task t = preparaTask(duplicateLead, existingLead);
        duplicateTasksToInsert.add(t);
    }
    
    
    /**
* @description Checks if lead is a duplicate within the same insert batch, if so then calls a method to create a task.
* @param newLeads
*/       
    
    public static void createIntraBatchDuplicateTasks(List<Lead> newLeads) {
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { Task.SObjectType });
        boolean hasWork = false;
        Map<Id, Leads_ProductQueueAllocation__c> productMap = fetchProductAllocations(newleads);
        for (Lead duplicateLead : newLeads) {
            if (isValidProductLead(duplicateLead, productMap.get(duplicateLead.Expressed_Interest_Product__c),'Dialer_Leads')) {  
                if (duplicateLead.Referred_System_Reference_Number__c != 'Duplicate') {
                    continue;
                }            
                String key = getDuplicateKey(duplicateLead);
                
                Lead primaryLead = originalBatchLeadByDuplicateKey.get(key);
                
                if (primaryLead == null || primaryLead.Id == null) {
                    continue;
                }
                
                if (primaryLead.Id == duplicateLead.Id) {
                    continue;
                }
                
                Task t = preparaTask(duplicateLead, primaryLead);
                unitOfWork.registerNew(t);
                hasWork = true;
            }
        }
        if(hasWork){
            unitOfWork.commitWork();
        }
        
        
    }    
    
    /**
* @description Creates a task for the duplicate leads
* @param Id
* @param primaryLead
*/   
    private static Task preparaTask(Lead ld, Lead primaryLead){
        Task t = new Task();
        
        t.Subject = 'Duplicate Lead Attempt';
        t.ActivityDate = Date.today();
        
        t.WhoId = primaryLead.Id;
        
        t.Description =
            'Duplicate Lead Created\n' +
            'Lead Name: ' + ld.Name + '\n' +
            'Mobile: ' + ld.MobilePhone + '\n' +
            'Campaign Source: ' + ld.Campaign_Source_ID__c;
        
        return t;
    }
    
    
    /**
* @description Inserts all the duplicate tasks in salesforce.
*/   
    
    public static void insertPreparedDuplicateTasks() {
        
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork = new sbgplatform.fflib_SObjectUnitOfWork(new Schema.SObjectType[] { Task.SObjectType });
        if (!duplicateTasksToInsert.isEmpty()) {
            for( Task t : duplicateTasksToInsert){
                unitOfWork.registerNew(t);
            }
            unitOfWork.commitWork();
            duplicateTasksToInsert.clear();
        }  
        
    } 
}