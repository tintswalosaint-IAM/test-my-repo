/**
* @description Support methods for Connex insurance lead processing.
* Handles lead filtering, preferred contact time checks, product validation,
* product allocation lookups, and metadata loading used by Connex processing.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains support/helper logic extracted from the
* Connex service to reduce method count and improve maintainability.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_UTIL_LeadConnexSupport {

    private INS_UTIL_LeadConnexSupport() {
    }

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadConnexSupport.class.getName());

    private static final String DUPLICATE_REF = 'Duplicate';

    private static Map<String, INS_Insurance_Lead_Settings__mdt> leadSettingsMap =
        new Map<String, INS_Insurance_Lead_Settings__mdt>();

    private static Map<Id, Leads_ProductQueueAllocation__c> cachedProductMap;

    /**
* @description Filter leads that are eligible for Connex processing.
* Excludes leads without an Id and leads already marked as duplicates.
* @param newLeads List of Lead records to evaluate
* @return List<Lead> Leads eligible for Connex processing
*/

    public static List<Lead> filterEligibleLeads(List<Lead> newLeads) {
        List<Lead> eligibleLeads = new List<Lead>();
        for (Lead lead : newLeads) {
            if (isLeadEligibleForConnex(lead)) {
                eligibleLeads.add(lead);
            }
        }
        return eligibleLeads;
    }

/**
* @description Check whether a lead's preferred contact time is null or already in the past.
* Converts the current system time to South Africa time before evaluating the lead's
* preferred contact window.
* @param lead Lead record to evaluate
* @return Boolean True if the preferred contact time is null or has already passed
*/
    public static Boolean isPreferredContactTimeNullOrPast(Lead lead) {
        try {
            Datetime preferredStart = lead.Preferred_Contact_Date_Time__c;
            Datetime preferredEnd = lead.Preferred_Contact_Date_Time_End__c;

            TimeZone saTimeZone = TimeZone.getTimeZone('Africa/Johannesburg');
            Datetime nowInSA = System.now().addSeconds(saTimeZone.getOffset(System.now()) / 1000);

            if (preferredStart == null && preferredEnd == null) {
                return true;
            }

            return (preferredStart != null && preferredStart <= nowInSA) ||
                   (preferredEnd != null && preferredEnd <= nowInSA);
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadConnexSupport | isPreferredContactTimeNullOrPast | exception | ' + ex);
            return true;
        }
    }

    /**
* @description Fetch product queue allocations for the supplied leads.
* Uses caching to avoid repeated product-allocation lookups within the same transaction.
* @param leads List of Lead records to evaluate
* @return Map<Id, Leads_ProductQueueAllocation__c> Product allocations keyed by product queue Id
*/

    public static Map<Id, Leads_ProductQueueAllocation__c> fetchProductAllocations(List<Lead> leads) {
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
    public static Boolean isValidProductLead(Lead lead, Leads_ProductQueueAllocation__c relatedProduct) {
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
            LOGGER.error('INS_UTIL_LeadConnexSupport | isValidProductLead | exception | ' + ex);
            return false;
        }
    }
    /**
* @description Check whether a lead is eligible for Connex processing.
* Filters out leads without an Id and leads already marked as duplicates.
* @param lead Lead record to evaluate
* @return Boolean True if the lead is eligible for Connex processing
*/

    private static Boolean isLeadEligibleForConnex(Lead lead) {
        return lead.Id != null && lead.Referred_System_Reference_Number__c != DUPLICATE_REF;
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
                LOGGER.error('INS_UTIL_LeadConnexSupport | loadProductSettings | exception | ' + ex);
            }
        }
    }
}