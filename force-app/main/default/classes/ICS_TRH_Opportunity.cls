/*************************************************************
* @description SFP-43424 Class used to test ICS_TRH_Opportunity
*
* @autor Ruchi Agarwal
*
* @date OCT 21 2024
***************************************************************
* Last Modified By  Ikyatha Naidu
* Last Modified Date 23/03/2025
* Last Modified Description: Added functionlaity for Ownership change
*/
public without sharing class ICS_TRH_Opportunity extends CMN_TRH_BaseObject {
    /**
    * @description Service name constant for the class
    */
    public static final String SERVICE_NAME = ICS_TRH_Opportunity.class.getName();
    Public static List<Applicant> applicantList = new List<Applicant>();
    public static Map<String, String> labelInfo = new Map<String, String>();
    Public static Id relatedAccountId;
    Public static Id relatedOppId;
    public override void bulkAfter() {
        if (!Trigger.isUpdate) {
            return;
        }
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>)Trigger.newMap;
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>)Trigger.oldMap;
        
        ProcessingContext context = new ProcessingContext(newMap, oldMap);
        
        // Process owner changes
        processOwnerChanges(context);
        
        // Process customer creation - commented out as per original code
        processCustomerCreation(context);
    }
    
    private class ProcessingContext {
        public final Map<Id, Opportunity> newMap;
        public final Map<Id, Opportunity> oldMap;
        public final Id targetRecordTypeId;
        
        public ProcessingContext(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
            this.newMap = newMap;
            this.oldMap = oldMap;
            this.targetRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(ICS_Constants.ICS_APPLICANT)
                .getRecordTypeId();
        }
    }
    
    private void processCustomerCreation(ProcessingContext context) {
        List<Id> opportunitiesForSAP = getOpportunitiesForSAPCreation(context);
        
        if (!opportunitiesForSAP.isEmpty()) {
            callSapService(opportunitiesForSAP);
        }
    }
    
    private List<Id> getOpportunitiesForSAPCreation(ProcessingContext context) {
        List<Id> oppIds = new List<Id>();
        
        for (Opportunity opp : context.newMap.values()) {
            if (isEligibleForCustomerCreation(opp, context)) {
                oppIds.add(opp.Id);
            }
        }
        
        return oppIds;
    }
    
    private Boolean isEligibleForCustomerCreation(Opportunity opp, ProcessingContext context) {
        Opportunity oldOpp = context.oldMap.get(opp.Id);
        
        return opp.StageName != oldOpp.StageName 
            && opp.StageName == 'Closed Won'
            && opp.RecordTypeId == context.targetRecordTypeId 
            && opp.Account.ExternalCIFId__c == null;
    }
    
    private void processOwnerChanges(ProcessingContext context) {
        Map<Id, Id> ownerChanges = getOwnerChanges(context);
       	List<Opportunity>oppRecordUpdateList = new List<Opportunity>();
        if (!ownerChanges.isEmpty()) {
            ICS_CTRL_PingVerificationEmail.notifyOwner(ownerChanges.keyset());
            // Load related field mappings from custom metadata
            ics_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('OpportunityWithLookup');
            labelInfo = (Map<String, String>)JSON.deserialize(labelData.Description__c, Map<String, String>.class);
            
            // Get opportunity IDs where owner changed
            List<Id> changedOppIds = new List<Id>(ownerChanges.keySet());
            SEL_Sales_Code_Allocation allocationSelector = new SEL_Sales_Code_Allocation();
            List<Sales_Code_Allocation__c> allocationList = allocationSelector.selectByUserIds(ownerChanges.values());
            Map<Id, String> userIdToSalesCodeMap = new Map<Id, String>();
            for(Sales_Code_Allocation__c allocation : allocationList) {
                userIdToSalesCodeMap.put(allocation.User__c, allocation.Sales_Codes__c);
            }

            for(String oppId : ownerChanges.keySet()) {
                Id newOwnerId = ownerChanges.get(oppId);
                
                // Get the Sales Code for the new owner
                String salesCode = userIdToSalesCodeMap.get(newOwnerId);
                
                if(salesCode != null) {
                    Opportunity updateOpp = new Opportunity();
                    updateOpp.Id = oppId;
                    updateOpp.Sales_Code__c = salesCode;
                    oppRecordUpdateList.add(updateOpp);
                }
            }
           if(!oppRecordUpdateList.isEmpty()) {
                update oppRecordUpdateList;
            }
            
            // Update related records
            updateRelatedRecords(changedOppIds, ownerChanges);
        }
    }
    
    private Map<Id, Id> getOwnerChanges(ProcessingContext context) {
        Map<Id, Id> ownerChanges = new Map<Id, Id>();
        
        for (Opportunity opp : context.newMap.values()) {
            // Check if owner has changed
            if (opp.OwnerId != context.oldMap.get(opp.Id).OwnerId && opp.RecordTypeId == context.targetRecordTypeId ) {
                ownerChanges.put(opp.Id, opp.OwnerId);
                
            }
        }
        
        return ownerChanges;
    }
    
    private static void updateRelatedRecords(List<Id> opportunityIds, Map<Id, Id> oppIdToNewOwnerId) {
        // Get all ApplicationForms related to the opportunities
        SEL_ApplicationForm formSelector = new SEL_ApplicationForm();
        List<ApplicationForm> formList = formSelector.selectByOpportunityIds(opportunityIds);
        
        // If no application forms found, nothing to update
        if (formList.isEmpty()) {
            return;
        }
        
        // Map opportunity ids to their new owners for easier lookup
        Map<Id, Id> oppToNewOwnerMap = new Map<Id, Id>(oppIdToNewOwnerId);
        
        // Collect all Account IDs from application forms
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Id> accountToOppMap = new Map<Id, Id>(); // Maps account ID to its related opportunity ID
        
        for (ApplicationForm form : formList) {
            if (form.accountId != null) {
                accountIds.add(form.opportunity.Accountid);
                accountIds.add(form.accountId);
                accountToOppMap.put(form.opportunity.accountId, form.opportunityId);
                accountToOppMap.put(form.accountId, form.opportunityId);
            }
        }
        
        // If no accounts found, nothing to update
        if (accountIds.isEmpty()) {
            return;
        }
        
        // Get all object API names from the field mapping
        Set<String> objList = labelInfo.keySet();
        
        // Process each related object
        for (String objectName : objList) {
            updateObjectRecords(objectName, oppToNewOwnerMap, accountToOppMap, accountIds);
        }
    }
    
    private static void updateObjectRecords(String objectName, Map<Id, Id> oppToNewOwnerMap, 
                                           Map<Id, Id> accountToOppMap, Set<Id> accountIds) {
       
            // Build appropriate query based on object type
            String query = buildQuery(objectName, accountIds);
            
            // If no valid query could be built, exit
            if (String.isBlank(query)) {
                return;
            }
            
            // Query the records to update
            List<SObject> recordsToUpdate = Database.query(query);
            
            // Exit if no records to update
            if (recordsToUpdate.isEmpty()) {
                return;
            }
            
            
          
            
            // Update owner for each record
            for (SObject record : recordsToUpdate) {
                // Get the account ID from the record
               
                
                if (objectName == 'Account') {
                    // For Account object itself
                    relatedAccountId = (Id)record.get('Id');
                } 
                
                // Find the opportunity ID via the account ID
                 relatedOppId = accountToOppMap.get(relatedAccountId);
                
                // Only update if we have the new owner ID
                if (relatedOppId != null && oppToNewOwnerMap.containsKey(relatedOppId)) {
                    record.put('OwnerId', oppToNewOwnerMap.get(relatedOppId));
                }
            }
            
            // Update the records with partial success allowed
            if (!recordsToUpdate.isEmpty()) {
                 Database.update(recordsToUpdate, false);
                
               
            }
       
    }
    
    private static String buildQuery(String objectName, Set<Id> accountIds) {
        if(accountIds.isempty()){
            return null;
        }
        // Get the field that references the Account
        String accountLookupField = labelInfo.get(objectName);
        
        // If no lookup field defined for this object, return empty query
        if (String.isBlank(accountLookupField)) {
            return '';
        }
        
        String query = '';
        
        // Special case for the Account object itself
        if (objectName == 'Account') {
            query = 'SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds';
        } 
        // For objects related to Account
        else {
            query = 'SELECT Id, OwnerId, ' + accountLookupField + ' FROM ' + objectName + 
                   ' WHERE ' + accountLookupField + ' IN :accountIds';
        }
        
        return query;
    }
    
    /**
     * @description Processes application forms and enqueues SAP customer creation jobs
     * For opportunities with multiple application forms, creates joint customers
     * For opportunities with single application form, creates single customers
     * Also processes primary applicants separately
     * @param appFormMap Map of Opportunity Id to list of associated Application Forms
     * @return void
     */
    public static void callSapService(List<Id> opportunityIds) {
        System.enqueueJob(new ICS_CTRL_SAPCreateCustomer(opportunityIds)); 
    }
    
    /**
     * @description Custom exception class for ICS_TRH_Opportunity
     */
    public class SVC_TRH_OpportunityException extends Exception {}
}