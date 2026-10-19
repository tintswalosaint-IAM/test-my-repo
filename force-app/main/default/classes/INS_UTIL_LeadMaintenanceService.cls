/**
* @description Maintenance and formatting service for insurance leads.
* Handles mobile number formatting, lead status maintenance,
* and owner reassignment based on dialer agent updates.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains shared maintenance logic extracted from the
* insurance lead trigger utility to improve maintainability and reduce class complexity.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.

public without sharing class INS_UTIL_LeadMaintenanceService {

    private INS_UTIL_LeadMaintenanceService() {
    }

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadMaintenanceService.class.getName());

    private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';

    private static Map<String, INS_Insurance_Lead_Settings__mdt> leadSettingsMap =
        new Map<String, INS_Insurance_Lead_Settings__mdt>();

    private static Map<Id, Leads_ProductQueueAllocation__c> cachedProductMap;

/**
* @description Format mobile numbers for valid insurance product leads.
* Converts various South African number formats to standardized format.
* @param leads List of Lead records to process
*/
    public static void formatNumbers(List<Lead> leads) {
        Map<Id, Leads_ProductQueueAllocation__c> productMap = fetchProductAllocations(leads);

        for (Lead l : leads) {
            if (isValidProductLead(l, productMap.get(l.Expressed_Interest_Product__c))) {
                String normalizedMobile = formatSouthAfricanNumber(l.MobilePhone, true);
                l.MobilePhone = normalizedMobile;
            }
        }
    }
/**
* @description Maintain lead status based on insurance business rules.
* Updates lead status to onboarding when the lead is qualified,
* has a reference number, and has no related account.
* @param leads List of Lead records to evaluate
*/
    public static void maintainLeadStatus(List<Lead> leads) {
        for (Lead lead : leads) {
            if (lead.Referred_System_Reference_Number__c != null &&
                lead.Status == 'Qualified' &&
                lead.FinServ__RelatedAccount__c == null) {
                lead.Status = 'Onboarding';
                lead.Stage__c = 'Onboarding in Progress';
            }
        }
    }

/**
* @description Assign owner from dialer agent ID when the agent ID changes.
* Updates lead owner using the mapped user employee number.
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
            Map<String, User> agentIdToUserMap = new SEL_User().selectUserByEmployeeNumber(changedAgentIds);
            updateLeadOwners(newLeads, leadIdToChangedAgentId, agentIdToUserMap);

        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadMaintenanceService | assignOwnerFromDialerAgentId | exception | ' + ex);
        }
    }
/**
* @description Identify leads whose dialer agent Id changed.
* Builds a map of lead Id to dialer agent employee number for leads where the agent Id changed.
* @param newLeads List of new Lead records
* @param oldLeadMap Map of old Lead records before update
* @return Map<Id, String> Map of lead Id to changed dialer agent Id
*/
    private static Map<Id, String> identifyChangedAgentLeads(List<Lead> newLeads, Map<Id, Lead> oldLeadMap) {
        Map<Id, String> changedMap = new Map<Id, String>();

        try {
            for (Lead l : newLeads) {
                if (oldLeadMap == null || !oldLeadMap.containsKey(l.Id)) {
                    continue;
                }

                Lead oldLead = oldLeadMap.get(l.Id);
                if (oldLead != null &&
                    l.Dialer_Agent_Id__c != oldLead.Dialer_Agent_Id__c &&
                    !String.isBlank(l.Dialer_Agent_Id__c)) {
                    changedMap.put(l.Id, l.Dialer_Agent_Id__c);
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadMaintenanceService | identifyChangedAgentLeads | exception | ' + ex);
        }

        return changedMap;
    }

/**
* @description Update lead owners based on mapped dialer agent users.
* Applies owner reassignment only to eligible lead statuses with a reference number.
* @param leads List of Lead records to update
* @param changedMap Map of lead Id to changed dialer agent Id
* @param userMap Map of employee number to User
*/
    private static void updateLeadOwners(List<Lead> leads, Map<Id, String> changedMap, Map<String, User> userMap) {
        try {
            for (Lead l : leads) {
                if (l.Status != 'Qualified' &&
                    l.Status != LEAD_STATUS_UNQUALIFIED &&
                    l.Status != 'Onboarding') {
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
            LOGGER.error('INS_UTIL_LeadMaintenanceService | updateLeadOwners | exception | ' + ex);
        }
    }
/**
* @description Fetch product queue allocations for the supplied leads.
* Uses caching to avoid repeated product-allocation lookups within the same transaction.
* @param leads List of Lead records to evaluate
* @return Map<Id, Leads_ProductQueueAllocation__c> Product allocations keyed by product queue Id
*/
    private static Map<Id, Leads_ProductQueueAllocation__c> fetchProductAllocations(List<Lead> leads) {
        if (cachedProductMap != null) {
            return cachedProductMap;
        }

        Set<Id> productQueueIds = new Set<Id>();
        for (Lead lead : leads) {
            if (lead.Expressed_Interest_Product__c != null) {
                productQueueIds.add(lead.Expressed_Interest_Product__c);
            }
        }

        if (productQueueIds.isEmpty()) {
            cachedProductMap = new Map<Id, Leads_ProductQueueAllocation__c>();
            return cachedProductMap;
        }

        List<Leads_ProductQueueAllocation__c> queueList =
            new INS_SEL_Leads_ProductQueueAllocation().selectProductQueueByIds(productQueueIds);

        Map<Id, Leads_ProductQueueAllocation__c> result =
            new Map<Id, Leads_ProductQueueAllocation__c>();

        for (Leads_ProductQueueAllocation__c record : queueList) {
            result.put(record.Id, record);
        }

        cachedProductMap = result;
        return cachedProductMap;
    }
/**
* @description Check whether a lead is valid for insurance product processing.
* Validates the lead's expressed-interest product against Dialer Leads metadata rules.
* @param lead Lead record to validate
* @param relatedProduct Related product queue allocation
* @return Boolean True if the lead is valid for insurance product processing
*/
    private static Boolean isValidProductLead(Lead lead, Leads_ProductQueueAllocation__c relatedProduct) {
        if (lead.Expressed_Interest_Product__c == null) {
            return false;
        }

        loadProductSettings('Dialer_Leads');
        INS_Insurance_Lead_Settings__mdt leadSetting = leadSettingsMap.get('Dialer_Leads');

        try {
            return leadSetting != null &&
                relatedProduct.Leads_Product_Family__c == leadSetting.INS_ProductFamily__c &&
                relatedProduct.Lead_Type__c == leadSetting.INS_LeadType__c &&
                (lead.CreatedDate == null || lead.CreatedDate >= leadSetting.INS_LeadDate__c);
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadMaintenanceService | isValidProductLead | exception | ' + ex);
            return false;
        }
    }
/**
* @description Format a South African mobile number into standardized format.
* Normalizes the number by removing prefixes and applying either +27 or 27.
* @param mobileNumber Mobile number to format
* @param includePlus Boolean indicating whether the formatted value should include the plus sign
* @return String Standardized South African mobile number
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
* @description Load product settings from custom metadata with caching.
* Retrieves and stores the requested metadata setting only when it is not already cached.
* @param settingName Name of the custom metadata setting to load
*/
    private static void loadProductSettings(String settingName) {
        if (!leadSettingsMap.containsKey(settingName)) {
            try {
                INS_Insurance_Lead_Settings__mdt setting =
                    INS_Insurance_Lead_Settings__mdt.getInstance(settingName);
                leadSettingsMap.put(settingName, setting);
            } catch (Exception ex) {
                LOGGER.error('INS_UTIL_LeadMaintenanceService | loadProductSettings | exception | ' + ex);
            }
        }
    }
}