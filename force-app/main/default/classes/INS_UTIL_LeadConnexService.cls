/**
* @description Connex integration service for insurance leads.
* Handles Connex-specific orchestration including lead eligibility flow,
* processing decisions, lead cloning for resubmission, and batch submission
* to the dialer system.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains Connex-specific processing logic extracted
* from the insurance lead trigger utility to improve maintainability and
* reduce class complexity.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.

public without sharing class INS_UTIL_LeadConnexService {

    private INS_UTIL_LeadConnexService() {
    }

/**
* @description Process leads for Connex integration based on eligibility and change rules.
* Filters valid leads, evaluates whether they should be inserted or updated in Connex,
* and performs the required batch or update actions.
* @param newLeads List of new Lead records
* @param oldLeadMap Map of old Lead records before update
*/
    public static void processLeadsForConnex(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        List<Lead> leadsToProcess = INS_UTIL_LeadConnexSupport.filterEligibleLeads(newLeads);
        if (leadsToProcess.isEmpty()) {
            return;
        }

        ConnexProcessingResult result = processLeadsForConnexEligibility(leadsToProcess, oldLeadMap);
        executeConnexProcessing(result);
    }
    // TODO:Separate product changed Leads from normal Leads
    // Product-change Leads require PUT followed by POST, unlike the normal processing path.
    private class ConnexProcessingResult {
        public List<Lead> qualifiedLeads { get; set; }
        public List<Lead> leadsToUpdate { get; set; }
        public List<Lead> productChangedLeads { get; set; }// new

        public ConnexProcessingResult() {
            this.qualifiedLeads = new List<Lead>();
            this.leadsToUpdate = new List<Lead>();
            this.productChangedLeads = new List<Lead>(); // new
        }
    }
/**
* @description Process leads and build the Connex processing result.
* Evaluates each eligible lead and collects leads that must be sent to Connex
* or updated locally.
* @param leadsToProcess List of leads eligible for Connex processing
* @param oldLeadMap Map of old Lead records before update
* @return ConnexProcessingResult Result containing leads to process and leads to update
*/

    private static ConnexProcessingResult processLeadsForConnexEligibility(
        List<Lead> leadsToProcess,
        Map<Id, Lead> oldLeadMap
    ) {
        ConnexProcessingResult result = new ConnexProcessingResult();
        Map<Id, Leads_ProductQueueAllocation__c> productMap =
            INS_UTIL_LeadConnexSupport.fetchProductAllocations(leadsToProcess);

        for (Lead lead : leadsToProcess) {
            processSingleLeadForConnex(lead, productMap, oldLeadMap, result);
        }

        return result;
    }
/**
* @description Process a single lead for Connex eligibility and change evaluation.
* Validates product rules, determines the Connex action, and updates the result container.
* @param lead Lead record to evaluate
* @param productMap Map of product queue allocations by Id
* @param oldLeadMap Map of old Lead records before update
* @param result Connex processing result container
*/
    private static void processSingleLeadForConnex(
        Lead lead,
        Map<Id, Leads_ProductQueueAllocation__c> productMap,
        Map<Id, Lead> oldLeadMap,
        ConnexProcessingResult result
    ) {
        if (!INS_UTIL_LeadConnexSupport.isValidProductLead(
                lead,
                productMap.get(lead.Expressed_Interest_Product__c)
            )) {
            return;
        }

        LeadProcessingDecision decision = evaluateLeadProcessingDecision(lead, oldLeadMap);
        applyLeadProcessingDecision(lead, decision, result);
    }

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
* @description Evaluate the Connex processing decision for a lead.
* Determines whether the lead is eligible for callout, whether the product changed,
* and whether lead information changed.
* @param lead Lead record to evaluate
* @param oldLeadMap Map of old Lead records before update
* @return LeadProcessingDecision Decision object describing the required action
*/
    private static LeadProcessingDecision evaluateLeadProcessingDecision(
        Lead lead,
        Map<Id, Lead> oldLeadMap
    ) {
        LeadProcessingDecision decision = new LeadProcessingDecision();

        decision.isEligibleForCallout =
            INS_UTIL_LeadConnexDecisionService.eligibleForConnexInsert(lead, oldLeadMap);

        decision.isProductChanged =
            INS_UTIL_LeadConnexDecisionService.hasProductChanged(lead, oldLeadMap);

        if (oldLeadMap != null && oldLeadMap.containsKey(lead.Id)) {
            decision.infoChanged =
                INS_UTIL_LeadConnexDecisionService.leadInfoChanged(lead, oldLeadMap.get(lead.Id));
        }

        return decision;
    }

/**
* @description Apply the evaluated Connex processing decision to the result set.
* Adds the lead or cloned lead to the correct processing collection.
* @param lead Lead record being processed
* @param decision Evaluated Connex processing decision
* @param result Connex processing result container
*/

     /*
    private static void applyLeadProcessingDecision(
        Lead lead,
        LeadProcessingDecision decision,
        ConnexProcessingResult result
    ) {
      
        // This clones the lead 
        if (decision.isEligibleForCallout) {
            result.qualifiedLeads.add(lead);
        } else if (decision.isProductChanged) {
            Lead cloned = cloneLeadForConnex(lead);
            result.qualifiedLeads.add(cloned);
            result.leadsToUpdate.add(cloned);
        } else if (decision.infoChanged) {
            result.qualifiedLeads.add(lead);
    }
}
     */
 // Your existing cloneLeadForConnex() clears Referred_System_Reference_Number__c. 
 //The new flow needs that reference to expire the existing Dialler Lead.
       private static void applyLeadProcessingDecision(
       Lead lead,
       LeadProcessingDecision decision,
       ConnexProcessingResult result
      ) {
        if (decision.isEligibleForCallout) {
        result.qualifiedLeads.add(lead);
       } else if (decision.isProductChanged) {
        result.productChangedLeads.add(lead);
       } else if (decision.infoChanged) {
        result.qualifiedLeads.add(lead);
    }
}


    /**
* @description Execute final Connex actions for the evaluated result.
* Submits leads to Connex in batch and updates cloned leads when required.
* @param result Connex processing result container
*/ 

/*
    private static void executeConnexProcessing(ConnexProcessingResult result) {
        if (!result.qualifiedLeads.isEmpty()) {
            submitConnexBatch(result.qualifiedLeads);
        }

        if (!result.leadsToUpdate.isEmpty()) {
            updateClonedLeads(result.leadsToUpdate);
        }
    }
*/

    private static void executeConnexProcessing(
    ConnexProcessingResult result
) {
    if (!result.qualifiedLeads.isEmpty()) {
        submitConnexBatch(result.qualifiedLeads, false);
    }

    if (!result.productChangedLeads.isEmpty()) {
        submitConnexBatch(result.productChangedLeads, true);
    }

    if (!result.leadsToUpdate.isEmpty()) {
        updateClonedLeads(result.leadsToUpdate);
    }
}


    /**
* @description Clone a lead for Connex processing when product changes require resubmission.
* Preserves key lead values while resetting the external reference number.
* @param lead Lead to clone
* @return Lead Cloned lead prepared for Connex processing
*/

    @TestVisible
    public static Lead cloneLeadForConnex(Lead lead) {
        Lead cloned = lead.clone(true, true, true, true);
        cloned.Id = lead.Id;
        cloned.OwnerId = lead.OwnerId;
        cloned.Referred_System_Reference_Number__c = null;
        return cloned;
    }
/**
* @description Submit qualified leads to the Connex batch process.
* Builds the batch input and executes the Connex batch job for valid leads.
* @param qualifiedLeads List of leads to submit to Connex
*/
    //private static void submitConnexBatch(List<Lead> qualifiedLeads) {
    private static void submitConnexBatch( List<Lead> qualifiedLeads, Boolean isProductChanged){
        if (qualifiedLeads.isEmpty()) {
            return;
        }

        INS_Insurance_Lead_Settings__mdt settings =
            INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');

        if (settings == null) {
            return;
        }

        List<Id> leadIds = new List<Id>();
        for (Lead l : qualifiedLeads) {
            leadIds.add(l.Id);
        }

        Date leadDate = null;
        if (settings.INS_LeadDate__c != null) {
            leadDate = settings.INS_LeadDate__c.date();
        }

        INS_BATCH_ConnexLead batchJob = new INS_BATCH_ConnexLead(
            false,
            null,
            settings.INS_LeadType__c,
            settings.INS_ProductFamily__c,
            leadDate,
            leadIds,
            isProductChanged
        );

        Database.executeBatch(batchJob, 15);
    }
    /**
* @description Update cloned leads after Connex product-change handling.
* Performs a lead update only when the current user has update access.
* @param leadsToUpdate List of cloned leads to update
*/
    private static void updateClonedLeads(List<Lead> leadsToUpdate) {
        if (!leadsToUpdate.isEmpty() && Schema.sObjectType.Lead.isUpdateable()) {
            update leadsToUpdate;
        }
    }
}