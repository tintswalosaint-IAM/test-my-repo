/**
* @description Support methods for duplicate insurance lead processing.
* Handles duplicate-key generation, duplicate rule support checks,
* product validation, product allocation lookups, and metadata loading.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains support/helper logic extracted from the
* duplicate service to reduce method count and improve maintainability.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_UTIL_LeadDuplicateSupport {

    private INS_UTIL_LeadDuplicateSupport() {
    }

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadDuplicateSupport.class.getName());

    private static Map<String, INS_Insurance_Lead_Settings__mdt> leadSettingsMap =
        new Map<String, INS_Insurance_Lead_Settings__mdt>();

    private static Map<Id, Leads_ProductQueueAllocation__c> cachedProductMap;

/**
* @description Generate the duplicate key for a lead.
* Builds a lowercase composite key using last name, campaign source, and mobile number.
* @param lead Lead record to convert into a duplicate key
* @return String Duplicate key in lowercase format
*/
    public static String getDuplicateKey(Lead lead) {
        return (lead.LastName + '|' + lead.Campaign_Source_ID__c + '|' + lead.MobilePhone).toLowerCase();
    }

/**
* @description Check whether a lead is active and within 30 days of creation.
* Applies duplicate-rule support logic based on lead status and created date.
* @param lead Lead record to evaluate
* @return Boolean True if the lead is active and within the 30-day window
*/
    public static Boolean isActiveLeadWithin30Days(Lead lead) {
        if (lead == null || lead.CreatedDate == null) {
            return false;
        }

        Boolean isActiveStatus =
            lead.Status == 'New' ||
            lead.Status == 'Working' ||
            lead.Status == 'Waiting for Customer';

        Date today = System.today();
        Date createdDate = lead.CreatedDate.date();
        Integer daysBetween = createdDate.daysBetween(today);
        Boolean isWithin30Days = daysBetween <= 30;

        return isActiveStatus && isWithin30Days;
    }
/**
* @description Check whether a lead is a retro lead.
* @param lead Lead record to evaluate
* @return Boolean True if the lead source is RETRO
*/
    public static Boolean isRetroLead(Lead lead) {
        return lead.LeadSource == 'RETRO';
    }
/**
* @description Check whether a lead is a non-retro lead.
* @param lead Lead record to evaluate
* @return Boolean True if the lead source is NON-RETRO
*/
    public static Boolean isNonRetroLead(Lead lead) {
        return lead.LeadSource == 'NON-RETRO';
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
            LOGGER.error('INS_UTIL_LeadDuplicateSupport | isValidProductLead | exception | ' + ex);
            return false;
        }
    }

    private static void loadProductSettings(String settingName) {
        if (!leadSettingsMap.containsKey(settingName)) {
            try {
                INS_Insurance_Lead_Settings__mdt setting =
                    INS_Insurance_Lead_Settings__mdt.getInstance(settingName);
                leadSettingsMap.put(settingName, setting);
            } catch (Exception ex) {
                LOGGER.error('INS_UTIL_LeadDuplicateSupport | loadProductSettings | exception | ' + ex);
            }
        }
    }
}