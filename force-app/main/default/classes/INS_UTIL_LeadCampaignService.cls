/**
* @description Campaign processing service for insurance leads.
* Handles campaign synchronization, campaign member creation,
* courtesy SMS campaign selection, and campaign assignment based on business hours.
* @author Raja Arsalan
* @group Lead
* @date 09-10-2025
*
* @userstory SFP-44418
* @description This class contains campaign-related insurance lead processing logic
* extracted from the insurance lead trigger utility to improve maintainability.
*/
// This class runs without sharing to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_UTIL_LeadCampaignService {

    /**
    * @description Private constructor to prevent instantiation of this utility class.
    */
    private INS_UTIL_LeadCampaignService() {
    }

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_UTIL_LeadCampaignService.class.getName());

    private static final String LEAD_STATUS_SENT = 'Sent';

    private static Map<String, INS_Insurance_Lead_Settings__mdt> leadSettingsMap =
        new Map<String, INS_Insurance_Lead_Settings__mdt>();

    private static sbgplatform.fflib_SObjectUnitOfWork uow =
        new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{ CampaignMember.SObjectType }
        );

    /**
    * @description Sync leads with campaigns based on campaign source and update campaign fields.
    * Updates lead campaign name and dialer queue Id using campaign source mappings.
    * @param leads List of Lead records to sync with campaigns
    * @param oldMap Map of old Lead records before update
    */
    public static void syncLeadsWithCampaigns(List<Lead> leads, Map<Id, Lead> oldMap) {
        try {
            Set<String> campaignSourceIds = getUpdatedCampaignSourceIds(leads, oldMap);
            if (!campaignSourceIds.isEmpty()) {
                Map<String, Campaign> campaignMap = fetchCampaignsBySourceIds(campaignSourceIds);
                updateLeadsWithCampaignNames(leads, campaignMap);
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadCampaignService | syncLeadsWithCampaigns | exception | ' + ex);
        }
    }

    /**
    * @description Create campaign members for insurance leads based on campaign source and business hours.
    * Creates campaign members for both source campaigns and courtesy SMS campaigns.
    * @param triggerLeads List of Lead records from trigger
    * @param oldMap Map of old Lead records before update
    * @param isInsert Boolean indicating if this is an insert operation
    */
    public static void createCampaignMembers(List<Lead> triggerLeads, Map<Id, Lead> oldMap, Boolean isInsert) {
        try {
            List<Lead> successfulLeads = getSuccessfulLeads(triggerLeads);
            if (successfulLeads.isEmpty()) {
                return;
            }

            Map<String, Campaign> campaignMap = getRelevantCampaigns(successfulLeads, oldMap);

            CampaignMemberPreparationData preparationData =
                prepareCampaignMemberData(successfulLeads, campaignMap);

            Map<String, CampaignMember> existingCMMap =
                getExistingCampaignMembers(preparationData.leadIds, preparationData.campaignIds);

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
            LOGGER.error('INS_UTIL_LeadCampaignService | createCampaignMembers | exception | ' + ex);
        }
    }

    /**
    * @description Create a courtesy campaign member based on business hours and holidays.
    * Selects either business-hours or non-business-hours courtesy campaign for the lead.
    * @param lead Lead record to evaluate
    * @param campaigns List of courtesy campaigns
    * @param holidays Set of holiday dates in MM-dd format
    * @return CampaignMember Campaign member to create, or null if not applicable
    */
    @TestVisible
    public static CampaignMember createCampaignMemberBasedOnBusinessHours(
        Lead lead,
        List<Campaign> campaigns,
        Set<String> holidays
    ) {
        try {
            if (!isValidLeadAndCampaigns(lead, campaigns)) {
                return null;
            }

            Datetime saDateTime = getSouthAfricaDateTime(lead.CreatedDate);
            if (saDateTime == null) {
                return null;
            }

            Boolean isWeekday = isWeekday(saDateTime);
            Boolean isBusinessHours = isWithinBusinessHours(saDateTime.time());
            Boolean isHoliday = holidays.contains(saDateTime.format('MM-dd'));

            Id campaignId = getCampaignId(campaigns, isWeekday, isBusinessHours, isHoliday);
            if (campaignId == null) {
                return null;
            }

            return buildCampaignMember(lead, campaignId);

        } catch (Exception ex) {
            LOGGER.error(
                'INS_UTIL_LeadCampaignService | createCampaignMemberBasedOnBusinessHours | exception | ' + ex
            );
            return null;
        }
    }

    /**
    * @description Container for campaign member preparation data.
    * Holds lead Ids, campaign Ids, and courtesy lead Ids collected for campaign member processing.
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
    * @description Get leads that were successfully saved and have record Ids.
    * @param triggerLeads List of leads from the trigger context
    * @return List<Lead> Leads with non-null Ids
    */
    private static List<Lead> getSuccessfulLeads(List<Lead> triggerLeads) {
        List<Lead> successfulLeads = new List<Lead>();
        for (Lead l : triggerLeads) {
            if (l.Id != null) {
                successfulLeads.add(l);
            }
        }
        return successfulLeads;
    }

    /**
    * @description Get relevant campaigns based on updated campaign source values.
    * @param successfulLeads Leads to process
    * @param oldMap Map of old Lead records before update
    * @return Map<String, Campaign> Campaigns keyed by campaign source Id
    */
    private static Map<String, Campaign> getRelevantCampaigns(List<Lead> successfulLeads, Map<Id, Lead> oldMap) {
        Set<String> campaignSourceIds = getUpdatedCampaignSourceIds(successfulLeads, oldMap);
        if (campaignSourceIds.isEmpty()) {
            return new Map<String, Campaign>();
        }
        return fetchCampaignsBySourceIds(campaignSourceIds);
    }

    /**
    * @description Prepare campaign member processing data by collecting relevant lead and campaign Ids.
    * @param successfulLeads Leads to process
    * @param campaignMap Map of campaigns keyed by campaign source Id
    * @return CampaignMemberPreparationData Collected campaign member preparation data
    */
    private static CampaignMemberPreparationData prepareCampaignMemberData(
        List<Lead> successfulLeads,
        Map<String, Campaign> campaignMap
    ) {
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
    * @description Get existing campaign members to avoid duplicate creation.
    * @param leadIds Set of lead Ids to check
    * @param campaignIds Set of campaign Ids to check
    * @return Map<String, CampaignMember> Existing campaign members keyed by LeadId-CampaignId
    */
    private static Map<String, CampaignMember> getExistingCampaignMembers(Set<Id> leadIds, Set<Id> campaignIds) {
        if (leadIds.isEmpty() || campaignIds.isEmpty()) {
            return new Map<String, CampaignMember>();
        }

        List<CampaignMember> existingCMList =
            new SEL_CampaignMember().selectCampaignMembersByLeadAndCampaignIds(leadIds, campaignIds);

        Map<String, CampaignMember> existingCMMap = new Map<String, CampaignMember>();
        for (CampaignMember cm : existingCMList) {
            String key = cm.LeadId + '-' + cm.CampaignId;
            existingCMMap.put(key, cm);
        }

        return existingCMMap;
    }

    /**
    * @description Get leads eligible for courtesy SMS campaign processing.
    * @param courtesyLeadIds Set of lead Ids to evaluate
    * @return Set<Id> Lead Ids eligible for courtesy SMS campaigns
    */
    private static Set<Id> getEligibleCourtesyLeads(Set<Id> courtesyLeadIds) {
        return new Set<Id>(new SEL_Lead().selectLeadsEligibleForCourtesySMS(courtesyLeadIds).keySet());
    }

    /**
    * @description Get leads eligible for courtesy SMS campaign processing.
    * Converts the supplied lead list to lead Ids and evaluates courtesy eligibility.
    * @param successfulLeads List of leads to evaluate
    * @return Set<Id> Lead Ids eligible for courtesy SMS campaigns
    */
    private static Set<Id> getEligibleCourtesyLeads(List<Lead> successfulLeads) {
        Set<Id> courtesyLeadIds = new Set<Id>();
        for (Lead l : successfulLeads) {
            courtesyLeadIds.add(l.Id);
        }
        return getEligibleCourtesyLeads(courtesyLeadIds);
    }

    /**
    * @description Register campaign members using Unit of Work.
    * Inserts new campaign members only when the collection is not empty.
    * @param members List of campaign members to register
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
    * @description Get campaign source Ids that were added or changed in the current transaction.
    * @param leads List of leads to inspect
    * @param oldMap Map of old Lead records before update
    * @return Set<String> Updated campaign source Id values
    */
    private static Set<String> getUpdatedCampaignSourceIds(List<Lead> leads, Map<Id, Lead> oldMap) {
        Set<String> campaignSourceIds = new Set<String>();
        try {
            for (Lead lead : leads) {
                if (lead.Campaign_Source_ID__c != null &&
                    (oldMap == null || oldMap.get(lead.Id)?.Campaign_Source_ID__c != lead.Campaign_Source_ID__c)) {
                    campaignSourceIds.add(lead.Campaign_Source_ID__c);
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadCampaignService | getUpdatedCampaignSourceIds | exception | ' + ex);
        }
        return campaignSourceIds;
    }

    /**
    * @description Fetch campaigns by campaign source Id.
    * @param campaignSourceIds Set of campaign source Id values to query
    * @return Map<String, Campaign> Campaigns keyed by campaign source Id
    */
    private static Map<String, Campaign> fetchCampaignsBySourceIds(Set<String> campaignSourceIds) {
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        try {
            for (Campaign campaign : new SEL_Campaign().selectByCampaignSourceIds(campaignSourceIds)) {
                campaignMap.put(campaign.Campaign_Source_ID__c, campaign);
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadCampaignService | fetchCampaignsBySourceIds | exception | ' + ex);
        }
        return campaignMap;
    }

    /**
    * @description Update lead campaign fields using the supplied campaign map.
    * Sets campaign name and dialer queue Id where matching campaigns exist.
    * @param leads List of leads to update
    * @param campaignMap Map of campaigns keyed by campaign source Id
    */
    private static void updateLeadsWithCampaignNames(List<Lead> leads, Map<String, Campaign> campaignMap) {
        try {
            for (Lead lead : leads) {
                if (lead.Campaign_Source_ID__c != null) {
                    Campaign relatedCampaign = campaignMap.get(lead.Campaign_Source_ID__c);
                    if (relatedCampaign != null) {
                        lead.Campaign_Name__c = relatedCampaign.Name;
                        lead.Dialler_Queue_ID__c = relatedCampaign.Dialler_System_Code__c;
                    }
                }
            }
        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadCampaignService | updateLeadsWithCampaignNames | exception | ' + ex);
        }
    }

    /**
    * @description Prepare campaign members for insertion based on source and courtesy campaign rules.
    * Builds the final list of campaign members to create.
    * @param leads List of leads to process
    * @param campaignMap Map of campaigns keyed by campaign source Id
    * @param existingCMMap Map of existing campaign members keyed by LeadId-CampaignId
    * @param isInsert Boolean indicating if this is an insert operation
    * @param leadsEligibleForCourtesyCM Set of lead Ids eligible for courtesy campaigns
    * @return List<CampaignMember> Campaign members to insert
    */
    private static List<CampaignMember> prepareCampaignMembers(
        List<Lead> leads,
        Map<String, Campaign> campaignMap,
        Map<String, CampaignMember> existingCMMap,
        Boolean isInsert,
        Set<Id> leadsEligibleForCourtesyCM
    ) {
        List<CampaignMember> campaignMembersToInsert = new List<CampaignMember>();

        try {
            Set<String> holidays = loadPublicHolidays();
            List<Campaign> courtesyCampaigns = loadCourtesyCampaigns();

            for (Lead lead : leads) {
                handleCampaignSource(lead, campaignMap, existingCMMap, campaignMembersToInsert);
                handleCourtesyCampaign(
                    lead,
                    isInsert,
                    courtesyCampaigns,
                    leadsEligibleForCourtesyCM,
                    holidays,
                    existingCMMap,
                    campaignMembersToInsert
                );
            }

        } catch (Exception ex) {
            LOGGER.error('INS_UTIL_LeadCampaignService | prepareCampaignMembers | exception | ' + ex);
        }

        return campaignMembersToInsert;
    }

    /**
    * @description Load public holidays from custom metadata.
    * @return Set<String> Holiday dates in MM-dd format
    */
    private static Set<String> loadPublicHolidays() {
        Set<String> holidays = new Set<String>();
        loadProductSettings('Public_Holidays');
        INS_Insurance_Lead_Settings__mdt holidaySetting = leadSettingsMap.get('Public_Holidays');

        if (holidaySetting != null && String.isNotBlank(holidaySetting.INS_HolidayDates__c)) {
            holidays.addAll(holidaySetting.INS_HolidayDates__c.split(';'));
        }

        return holidays;
    }

    /**
    * @description Load courtesy campaign records used for business-hours and non-business-hours SMS logic.
    * @return List<Campaign> Courtesy campaign records
    */
    private static List<Campaign> loadCourtesyCampaigns() {
        List<String> courtesyCampsList = new List<String>{ 'INS_CRTSY_BUSHR_SMS', 'INS_CRTSY_NONBUSHR_SMS' };
        return new SEL_Campaign().selectCampaignsByName(courtesyCampsList);
    }

    /**
    * @description Handle campaign member creation for the lead's source campaign.
    * Adds a campaign member when a matching campaign exists and no existing membership is found.
    * @param lead Lead record to process
    * @param campaignMap Map of campaigns keyed by campaign source Id
    * @param existingCMMap Map of existing campaign members keyed by LeadId-CampaignId
    * @param campaignMembersToInsert List collecting campaign members to insert
    */
    private static void handleCampaignSource(
        Lead lead,
        Map<String, Campaign> campaignMap,
        Map<String, CampaignMember> existingCMMap,
        List<CampaignMember> campaignMembersToInsert
    ) {
        if (lead.Campaign_Source_ID__c == null) {
            return;
        }

        Campaign relatedCampaign = campaignMap.get(lead.Campaign_Source_ID__c);
        if (relatedCampaign == null) {
            return;
        }

        String key = lead.Id + '-' + relatedCampaign.Id;
        if (existingCMMap.containsKey(key)) {
            return;
        }

        campaignMembersToInsert.add(new CampaignMember(
            LeadId = lead.Id,
            CampaignId = relatedCampaign.Id,
            Status = lead.Status
        ));
    }

    /**
    * @description Handle courtesy campaign member creation based on business hours and eligibility rules.
    * Adds a courtesy campaign member when the lead is eligible and no existing membership is found.
    * @param lead Lead record to process
    * @param isInsert Boolean indicating if this is an insert operation
    * @param courtesyCampaigns List of courtesy campaigns
    * @param eligibleLeads Set of eligible lead Ids
    * @param holidays Set of holiday dates in MM-dd format
    * @param existingCMMap Map of existing campaign members keyed by LeadId-CampaignId
    * @param campaignMembersToInsert List collecting campaign members to insert
    */
    private static void handleCourtesyCampaign(
        Lead lead,
        Boolean isInsert,
        List<Campaign> courtesyCampaigns,
        Set<Id> eligibleLeads,
        Set<String> holidays,
        Map<String, CampaignMember> existingCMMap,
        List<CampaignMember> campaignMembersToInsert
    ) {
        if (!isInsert || courtesyCampaigns == null || !eligibleLeads.contains(lead.Id)) {
            return;
        }

        CampaignMember cm = createCampaignMemberBasedOnBusinessHours(lead, courtesyCampaigns, holidays);
        if (cm == null) {
            return;
        }

        String cmKey = cm.LeadId + '-' + cm.CampaignId;
        if (existingCMMap.containsKey(cmKey)) {
            return;
        }

        campaignMembersToInsert.add(cm);
    }

    /**
    * @description Validate whether the lead and campaign inputs are sufficient for courtesy campaign processing.
    * @param lead Lead record to validate
    * @param campaigns List of campaigns to validate
    * @return Boolean True if the inputs are valid for processing
    */
    private static Boolean isValidLeadAndCampaigns(Lead lead, List<Campaign> campaigns) {
        return lead != null && lead.Id != null && lead.CreatedDate != null && campaigns != null && !campaigns.isEmpty();
    }

    /**
    * @description Convert a UTC datetime to South Africa time.
    * @param utcDateTime UTC datetime to convert
    * @return Datetime Datetime adjusted to South Africa time, or null when input is null
    */
    private static Datetime getSouthAfricaDateTime(Datetime utcDateTime) {
        if (utcDateTime == null) {
            return null;
        }

        TimeZone saTimeZone = TimeZone.getTimeZone('Africa/Johannesburg');
        Integer offsetSeconds = saTimeZone.getOffset(utcDateTime) / 1000;
        return utcDateTime.addSeconds(offsetSeconds);
    }

    /**
    * @description Check whether a datetime falls on a weekday.
    * @param dt Datetime to evaluate
    * @return Boolean True if the date is not Saturday or Sunday
    */
    private static Boolean isWeekday(Datetime dt) {
        String day = dt.format('E', 'en_ZA');
        return day != 'Sat' && day != 'Sun';
    }

    /**
    * @description Check whether a time falls within business hours.
    * Business hours are 07:00 to 16:30.
    * @param businessTime Time to evaluate
    * @return Boolean True if the time falls within business hours
    */
    private static Boolean isWithinBusinessHours(Time businessTime) {
        Time startTime = Time.newInstance(7, 0, 0, 0);
        Time endTime = Time.newInstance(16, 30, 0, 0);
        return businessTime >= startTime && businessTime <= endTime;
    }

    /**
    * @description Get the appropriate courtesy campaign Id based on day, time, and holiday rules.
    * @param campaigns List of courtesy campaigns
    * @param isWeekday Boolean indicating whether the date is a weekday
    * @param isBusinessHours Boolean indicating whether the time is within business hours
    * @param isHoliday Boolean indicating whether the date is a holiday
    * @return Id Selected courtesy campaign Id
    */
    private static Id getCampaignId(List<Campaign> campaigns, Boolean isWeekday, Boolean isBusinessHours, Boolean isHoliday) {
        Id businessCampaignId, nonBusinessCampaignId;

        for (Campaign c : campaigns) {
            if (c.Name == 'INS_CRTSY_BUSHR_SMS') {
                businessCampaignId = c.Id;
            } else if (c.Name == 'INS_CRTSY_NONBUSHR_SMS') {
                nonBusinessCampaignId = c.Id;
            }
        }

        return (isWeekday && isBusinessHours && !isHoliday) ? businessCampaignId : nonBusinessCampaignId;
    }

    /**
    * @description Build a campaign member record with formatted mobile number.
    * @param lead Lead record to associate with the campaign member
    * @param campaignId Campaign Id to assign
    * @return CampaignMember Configured campaign member record
    */
    private static CampaignMember buildCampaignMember(Lead lead, Id campaignId) {
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.LeadId = lead.Id;
        cm.Status = LEAD_STATUS_SENT;

        if (lead.MobilePhone != null) {
            String normalizedMobile = formatSouthAfricanNumber(lead.MobilePhone, false);
            cm.Formatted_Mobile_Number__c = normalizedMobile;
        }
        return cm;
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
                INS_Insurance_Lead_Settings__mdt setting = INS_Insurance_Lead_Settings__mdt.getInstance(settingName);
                leadSettingsMap.put(settingName, setting);
            } catch (Exception ex) {
                LOGGER.error('INS_UTIL_LeadCampaignService | loadProductSettings | exception | ' + ex);
            }
        }
    }
}