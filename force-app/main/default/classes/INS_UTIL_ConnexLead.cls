/**
* @description
* Utility class responsible for processing Leads for Connex integration.
*
* This class handles:
* 1. Connex lead eligibility
* 2. Connex product validation
* 3. Connex processing decisions
* 4. Lead cloning when product changes
* 5. Connex batch submission
* 6. Updating leads after cloning
*
* It does NOT handle:
* - Duplicate management
* - Campaign processing
* - Lead owner assignment
* - Generic Lead trigger processing
*/
public without sharing class INS_UTIL_ConnexLead {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
        .createLogger(INS_UTIL_ConnexLead.class.getName());

    
    /**
* @description
* Process leads for Connex integration based on eligibility and changes.
*
* @param newLeads List of new Lead records
* @param oldLeadMap Map of old Lead records before update
*/
    public static void processLeadsForConnex(List<Lead> newLeads,Map<Id, Lead> oldLeadMap)
    {
        List<Lead> leadsToProcess = filterEligibleLeads(newLeads);
        if (leadsToProcess.isEmpty()) {
            return;
        }
        
        ConnexProcessingResult result = processLeadsForConnexEligibility(leadsToProcess, oldLeadMap);
        executeConnexProcessing(result);
    }
    
    /**
* @description
* Filter leads that are eligible for Connex processing.
*
* @param newLeads List of all new leads
* @return List<Lead> Leads eligible for Connex processing
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
* @description
* Check whether a Lead is eligible for Connex processing.
*
* @param lead Lead to check
* @return Boolean True if Lead is eligible
*/
    private static Boolean isLeadEligibleForConnex(Lead lead) {
        return lead.Id != null &&
            lead.Referred_System_Reference_Number__c != 'Duplicate';
    }
    
    /**
* @description
* Container for Connex processing results.
*/
    private class ConnexProcessingResult {
        public List<Lead> qualifiedLeads { get; set; }
        
        public List<Lead> leadsToUpdate { get; set; }
        
        public ConnexProcessingResult() {
            this.qualifiedLeads = new List<Lead>();
            this.leadsToUpdate = new List<Lead>();
        }
    }
    
    /**
* @description
* Process Leads to determine Connex eligibility.
*
* @param leadsToProcess Leads to evaluate
* @param oldLeadMap Old Lead values
* @return ConnexProcessingResult Processing result
*/
    private static ConnexProcessingResult processLeadsForConnexEligibility(List<Lead> leadsToProcess, Map<Id, Lead> oldLeadMap)
    {
        ConnexProcessingResult result = new ConnexProcessingResult();      
        Map<Id, Leads_ProductQueueAllocation__c> productMap = INS_UTIL_LeadTrigger.fetchProductAllocations(leadsToProcess);
        
        for (Lead lead : leadsToProcess) {
            processSingleLeadForConnex(lead, productMap, oldLeadMap, result);
        }
        
        return result;
    }
    
    /**
* @description
* Process a single Lead for Connex eligibility.
*/
    private static void processSingleLeadForConnex(Lead lead, Map<Id, Leads_ProductQueueAllocation__c> productMap, Map<Id, Lead> oldLeadMap, ConnexProcessingResult result) {
        if (!INS_UTIL_LeadTrigger.isValidProductLead(lead,productMap.get(lead.Expressed_Interest_Product__c),'Dialer_Leads'))
        {
            return;
        }
        
        LeadProcessingDecision decision = evaluateLeadProcessingDecision(lead, oldLeadMap);       
        applyLeadProcessingDecision(lead, decision, result);
    }
    
    /**
* @description
* Container for Lead processing decision.
*/
    private class LeadProcessingDecision {
        public Boolean isEligibleForCallout { get; set; }        
        public Boolean isProductChanged { get; set; }       
        public Boolean infoChanged { get; set; }
        
        public LeadProcessingDecision() {
            this.isEligibleForCallout = false;           
            this.isProductChanged = false;           
            this.infoChanged = false;
        }
    }
    
    /**
* @description
* Evaluate how a Lead should be processed for Connex.
*/
    private static LeadProcessingDecision evaluateLeadProcessingDecision(Lead lead, Map<Id, Lead> oldLeadMap)
    {
        LeadProcessingDecision decision = new LeadProcessingDecision();     
        
        decision.isEligibleForCallout = eligibleForConnexInsert(lead, oldLeadMap);       
        decision.isProductChanged = hasProductChanged(lead, oldLeadMap);  
        
        if (oldLeadMap != null && oldLeadMap.containsKey(lead.Id)) {
            decision.infoChanged = leadInfoChanged(lead, oldLeadMap.get(lead.Id));
        }
        
        return decision;
    }
    
    /**
* @description
* Apply Connex processing decision.
*/
    private static void applyLeadProcessingDecision(Lead lead, LeadProcessingDecision decision, ConnexProcessingResult result) {
        if (decision.isEligibleForCallout) {
            result.qualifiedLeads.add(lead);
        }
        else if (decision.isProductChanged) {
            Lead cloned = cloneLeadForConnex(lead);           
            result.qualifiedLeads.add(cloned);            
            result.leadsToUpdate.add(cloned);
        }
        else if (decision.infoChanged) {
            result.qualifiedLeads.add(lead);
        System.debug(
    'Product Changed Path'
);
        }
    }
    
    /**
* @description
* Execute final Connex processing.
*/
    private static void executeConnexProcessing(ConnexProcessingResult result) {
        if (!result.qualifiedLeads.isEmpty()) {
            submitConnexBatch(result.qualifiedLeads);
        }
        
        if (!result.leadsToUpdate.isEmpty()) {
            updateClonedLeads(result.leadsToUpdate);
        }
    }

    
    /**
* @description
* Check if Lead is eligible for Connex insertion.
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
* @description
* Check whether Lead product has changed.
*/
    private static Boolean hasProductChanged(Lead lead, Map<Id, Lead> oldLeadMap) {
        try {
            if (Trigger.isInsert || oldLeadMap == null) {
                return false;
            }
            
            Lead oldLead = oldLeadMap.get(lead.Id);
            if (oldLead == null || lead.Status == 'Unqualified' || oldLead.Status == 'Unqualified') {
                return false;
            }
            
            if (lead.Expressed_Interest_Product__c != oldLead.Expressed_Interest_Product__c) {
                if (lead.Referred_System_Reference_Number__c != null) {
                    return true;
                } else {
                    return isPreferredContactTimeNullOrPast(lead);  
                }
            }
            return false;
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadTrigger | hasProductChanged | exception | ' + ex);
            return false;
        }
    }
    
    /**
* @description
* Check whether Lead information has changed requiring Connex update.
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
* @description
* Check if preferred contact time is null or in the past.
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
* @description
* Clone Lead for Connex processing with reset reference number.
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
* @description
* Submit batch job for Connex Lead processing.
*
* Batch size is intentionally 10 based on the current Connex
* integration requirement/hotfix.
*/
    private static void submitConnexBatch(List<Lead> qualifiedLeads) {
        if (!qualifiedLeads.isEmpty()) {
            INS_Insurance_Lead_Settings__mdt settings = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
            
            List<Id> leadIds = new List<Id>();
            for (Lead l : qualifiedLeads) {
                leadIds.add(l.Id);
            }
            
            INS_BATCH_ConnexLead batchJob = new INS_BATCH_ConnexLead(
                false,
                null,
                settings.INS_LeadType__c,
                settings.INS_ProductFamily__c,
                settings.INS_LeadDate__c != null ? settings.INS_LeadDate__c.date() : null,
                leadIds
            );
            
            Database.executeBatch(batchJob, 10);
        } 
    }    
    /**
* @description
* Update cloned Leads in database.
*/
    private static void updateClonedLeads(List<Lead> leadsToUpdate) {
        if (!leadsToUpdate.isEmpty()) {
            if (Schema.sObjectType.Lead.isUpdateable()) {
                update leadsToUpdate;
            }
        }
        
    }
    
    
}