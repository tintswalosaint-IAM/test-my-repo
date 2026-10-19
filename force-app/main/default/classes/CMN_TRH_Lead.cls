/**
* @description 
*  Triggger Handler for Lead
*  NOTE: This is another non-compliant handler for lead called INVM_TRH_Lead that is technical debt and will be deprecated
*  1. It connects leads to campaigns based on the campagn code (when a code is added or changed).
*      - currently it will not remove a lead from a campaign when its code changes as this is a fringe case
*  2. It connects leads to accounts based ont he External Identifier of the client
*      - it will disconnect the lead from the client when this changes to NULL or invalid       


* @author            : Derek Hughes
* @group             : Lead
* @last modified on  : 15-10-2025
* @last modified by  : Raja Arsalan
* Modifications Log
* Date         Author          Modification
* 19-04-2024   Derek Hughes    Initial Version
* 2024-10-12   Derek Hughes    Convert inline SELECT to use Selector class
* 08-05-2024   Kendra Riddle   New custom milestone tracking functionality added to org.
*                              Update trigger to call Milestone Trigger Handler for managing milestones on Leads.
* 2024-06-25	Derek Hughes	HOTFIX: Restrict campaign and account linking to Insert and Update trigger contexts 
* 2025-10-15	Raja Arsalan	Updated to invoke lead processing methods from INS_UTIL_LeadTrigger.
* 2026-06-10	Raja Arsalan	SFP-58785 - HOTFIX: Updated the BulkAfter method to insert the task for duplicate leads.
**/
public without sharing class CMN_TRH_Lead extends CMN_TRH_BaseObject {
    
    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_TRH_Lead.class.getName());
    
    public static Boolean skipConnexCallout = false;
    
    private Map<String, Account> accountsByExternalId = new Map<String, Account>();
    private Map<String, Campaign> campaignsByCode = new Map<String, Campaign>();
    private Set<Id> oldLeadIds = new Set<Id>();
    private Map<String, CampaignMember> membersByCodeAndId = new Map<String, CampaignMember>();
    private List<CampaignMember> newMembers = new List<CampaignMember>();
    
    private static final Lead EMPTY_LEAD = new Lead();
    sbgbase.MilestoneTriggerHandler milestoneHandler;
    
    /**
* @description This method is called prior to execution of a BEFORE Trigger. Use this to cache
* any data required into maps prior execution of the Trigger.
* @author Derek Hughes | 14-02-2024 
**/
    public override void bulkBefore() {
        LOGGER.debug('bulkBefore : Start');        
        milestoneHandler = new sbgbase.MilestoneTriggerHandler('Lead');
        super.bulkBefore();
        
        List<Lead> leads = (List<Lead>) Trigger.new;
        Map<Id, Lead> oldLeadMap = (Map<Id, Lead>) Trigger.OldMap;
        
        INS_UTIL_LeadTrigger.initializeState();
        
        if (Trigger.isInsert) {
            
            INS_UTIL_LeadTrigger.formatNumbers(leads);
            INS_UTIL_LeadTrigger.checkForDuplicates(leads);
            
        }
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            
            if (Trigger.old != null) {
                for (Lead l : (List<Lead>)Trigger.old) {
                    oldLeadIds.add(l.Id);
                }
            }
            
            loadAccountsByExternalId();
            loadCampaignsByCode();
            
            INS_UTIL_LeadTrigger.syncLeadsWithCampaigns(leads, oldLeadMap);
        }
        
        if (Trigger.isUpdate) {
            INS_UTIL_LeadTrigger.maintainLeadStatus(leads);
            INS_UTIL_LeadTrigger.assignOwnerFromDialerAgentId(leads, oldLeadMap);
        }
    }
    
    /**
* @description This method is called prior to execution of an AFTER Trigger. Use this to cache
* any data required into maps prior execution of the Trigger.
*/
    public override void bulkAfter() {
        LOGGER.debug('bulkAfter : Start');  
        if (Trigger.isInsert || Trigger.isUpdate) {
            
            List<Lead> leads = (List<Lead>) Trigger.new;
            Map<Id, Lead> oldLeadMap = (Map<Id, Lead>) Trigger.OldMap;
            
            super.bulkAfter();
            
            List<Lead> leadsToProcess =
                INS_UTIL_LeadTrigger.getNonDuplicateLeads(leads);
            
            if (!leadsToProcess.isEmpty()) {
                LOGGER.debug('New leads to be processed for dialer : ' + leadsToProcess.size());
                loadAccountsByExternalId();
                loadCampaignsByCode();
                INS_UTIL_LeadTrigger.createCampaignMembers(
                    leadsToProcess,
                    oldLeadMap,
                    Trigger.isInsert
                );
                
                if (!skipConnexCallout && !System.isBatch()) {
                    skipConnexCallout = true;
                    INS_UTIL_LeadTrigger.processLeadsForConnex(leads, oldLeadMap);
                }
            }

            if (Trigger.isInsert){ 
                INS_UTIL_DotsureLeads.processLeadsForDotsure(leads);
            }
            
            if (Trigger.isInsert && Trigger.isAfter) {
                
                INS_UTIL_LeadTrigger.createIntraBatchDuplicateTasks(Trigger.new);
                INS_UTIL_LeadTrigger.insertPreparedDuplicateTasks();
            }                      
            
        }
    }
    
    /**
* @description This method is called iteratively for each record to be inserted during a BEFORE
* Trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
*
* @author Derek Hughes | 14-02-2024 
* @param so 
**/
    public override void beforeInsert (SObject so) {
        super.beforeInsert(so);
        relateToAccount(EMPTY_LEAD, (Lead)so);
        
        // Update milestones for new record
        milestoneHandler.updateMilestones(null, so, false);
    }
    
    /**
* @description This method is called iteratively for each record inserted during an AFTER
* 				Trigger. Always put field validation in the 'After' methods in case another trigger
* 				has modified any values. The record is 'read only' by this point.
*
* @param so as input
**/
    public override void afterInsert(SObject so) {
        validateRelatedAccount((Lead)so);
        relateToCampaign(EMPTY_LEAD, (Lead)so);
    }
    
    /**
* @description This method is called iteratively for each record to be updated during a BEFORE
* Trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
*
* @author Derek Hughes | 14-02-2024 
* @param oldSo 
* @param so 
**/
    public override void beforeUpdate(SObject oldSo, SObject so) {
        super.afterUpdate(oldSo, so);
        Lead oldLead = (Lead)oldSo;
        Lead newLead = (Lead)so;
        relateToAccount(oldLead, newLead);
        
        // Update milestones for updated record
        milestoneHandler.updateMilestones(oldSo, so, false);
    } 
    
    /**
* @description This method is called iteratively for each record updated during an AFTER Trigger.
*
* @param oldSo as input
* @param so as input
**/
    public override void afterUpdate(SObject oldSo, SObject so) {
        validateRelatedAccount((Lead)so);
        relateToCampaign((Lead)oldSo, (Lead)so);
    }
    
    
    /**
* @description This method is called once all records have been processed by the Trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public override void andFinally() {
        LOGGER.info('andFinally: Start');
        try{
            
            
            // only required for Insert and Update contexts
            if (Trigger.isInsert || Trigger.isUpdate) {
                try {
                    insert newMembers;
                }
                catch (Exception ex) {
                    LOGGER.error('andFinally: Unhandled Exception', ex);
                    throw ex;
                }
            }
        }
        catch (Exception Ex) {
            LOGGER.error('CRITICAL FAILURE in andFinally. Transaction will be rolled back.', Ex);
        }
        
        
        
    }
    
    /**
* @description Loads the account for the external ids into a map for use in trigger
* @author Derek Hughes | 14-02-2024 
**/
    private void loadAccountsByExternalId() {
        
        final Set<String> externalIds = new Set<String>();
        final List<Lead> leadsNew = (List<Lead>)Trigger.new;
        
        // Create a set of all the Client External Identifiers for the leads in trigger new
        for (Lead lead : leadsNew) {
            if (String.IsNotBlank(lead.External_Client_Identifier__c)) {
                externalIds.add(lead.External_Client_Identifier__c);
            }
        }
        
        // Get all the accounts for those External Identifiers and create a map of Accounts by External Identifier
        final List<Account> accounts = new CMN_SEL_Account().selectByExternalIds(externalIds);
        
        for (Account account : accounts) {
            accountsByExternalId.put(account.ExternalIdentifier__c, account);
        }
    }
    
    /**
* @description Loads the Campaignsc and Campaign Members referred to by any campaign code from leads in the trigger
* @author Derek Hughes | 14-02-2024 
**/
    private void loadCampaignsByCode() {
        
        final Set<String> campaignCodes = new Set<String>();
        final List<Lead> leadsNew = (List<Lead>)Trigger.new;
        
        // Create a set of all the Client External Identifiers for the leads in trigger new
        for (Lead lead : leadsNew) {
            if (String.IsNotBlank(lead.Campaign_Code__c)) {
                campaignCodes.add(lead.Campaign_Code__c);
            }
        }
        
        // Get all the campaigns for those campaign codes with any members for the leads 
        final List<Campaign> campaigns = new SEL_Campaign().selectWithMembersByCampaignCodes(campaignCodes, oldLeadIds);
        
        // create a map of Campaigns by campaign code and Members by code and lead id
        for (Campaign campaign : campaigns) {
            campaignsByCode.put(campaign.Campaign_Code__c, campaign);
            for (CampaignMember member : campaign.CampaignMembers) {
                membersByCodeAndId.put(campaign.Campaign_Code__c+member.LeadId, member);
            }
        }
    }
    
    /**
* @description Links a lead to an account based on the External Client Identfier
* @author Derek Hughes | 14-02-2024 
* @param oldLead
* @param lead 
**/
    private void relateToAccount(Lead oldLead, Lead lead) {
        // has there been a change to the related client identifier?
        if (lead.External_Client_Identifier__c != oldLead.External_Client_Identifier__c) {
            //remove the current related record
            lead.FinServ__RelatedAccount__c = null;
            
            // if there is a Client External Identified link it if possible
            if (String.IsNotBlank(lead.External_Client_Identifier__c)) { 
                //try and find a related record and if found update the lead
                final Account account = accountsByExternalId.get(lead.External_Client_Identifier__c);
                if (account != null) {
                    lead.FinServ__RelatedAccount__c = account.Id;
                }
            }
        }
    }
    
    /**
* @description Links a lead to an Campaign based on the Campaign Code
* @author Derek Hughes | 14-02-2024 
* @param oldLead
* @param lead 
**/
    private void relateToCampaign(Lead oldLead, Lead lead) {
        // is there a campaign code that has changed?
        if (String.IsNotBlank(lead.Campaign_Code__c) && lead.Campaign_Code__c != oldLead.Campaign_Code__c) {
            // if there is a campaign code then link it if not aleady linked
            final Campaign campaign = campaignsByCode.get(lead.Campaign_Code__c);
            if (campaign != null) {
                
                //create new campaign member
                final CampaignMember member = membersByCodeAndId.get(campaign.Campaign_Code__c+lead.Id);
                
                if (member==null) {
                    final CampaignMember newMember = new CampaignMember(
                        CampaignId = campaign.Id,
                        LeadId = lead.Id
                    );
                    newMembers.add(newMember);
                }
            }
        }
    }
    
    
    /**
* @description Validates that the Related Account matches the External Client Identifier
* @author Derek Hughes | 14-02-2024 
* @param lead 
**/
    private void validateRelatedAccount(Lead lead) {
        // if there is a Client External Identified and the lead is related to an account, check that its valid 
        if (String.IsNotBlank(lead.External_Client_Identifier__c) && String.IsNotBlank(lead.FinServ__RelatedAccount__c)) {
            final Account account = accountsByExternalId.get(lead.External_Client_Identifier__c);
            if (account == null || lead.FinServ__RelatedAccount__c != account.id) {
                lead.FinServ__RelatedAccount__c.addError('The selected Related Account does not match the Client External Identifier');
            }
        }
    } 
    
    
    
    
    
}