/**
* @description       : Controller Class for handling Connex Failed Leads Report
* @author            : Raja Arsalan
* @date              : June 2025
* @last modified on  : 28-01-2026
* @last modified by  : Raja Arsalan

* Change log
* 2026-01-28   Raja Arsalan    SFP-52529 - Modified the logic in selectConnexLeads method and added a new parameter.

**/

// This class runs **without sharing** to allow full access to records, ignoring the user's sharing rules.
public without sharing class INS_CTRL_FailedConnexLeads {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_FailedConnexLeads');
    
    /**
* @description
*    This method retrieves a filtered list of Lead records based on the given search key,
*    date range, and lead configuration stored in custom metadata (Dialer_Leads).
*    It is exposed to Lightning components and is cacheable.
*
* @param searchKey
* @param startDate
* @param endDate
* @param campaignSearch
* @return List<Lead>
*/
    @AuraEnabled(cacheable=true)
    public static List<Lead> selectConnexLeads(String searchKey, Datetime startDate, Datetime endDate, String campaignSearch) {
        try {
            
                INS_Insurance_Lead_Settings__mdt leadSetting =
                INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');

                INS_DTO_LeadSearchCriteria c = new INS_DTO_LeadSearchCriteria();
                c.leadType = leadSetting.INS_LeadType__c;
                c.connexDate = leadSetting.INS_LeadDate__c;
                c.productFamily = leadSetting.INS_ProductFamily__c;
                c.searchKey = searchKey;
                c.startDate = startDate;
                c.endDate = endDate;
                c.isReport = true;
				
                if (String.isNotBlank(campaignSearch)) {
                    String t = campaignSearch.trim();
                    if (t.length() == 3 && t.isNumeric()) {
                        c.campaignSourceId = t;
                    } else {
                        c.campaignName = t;
                    }
                }

                return new SEL_Lead().selectLeadsByDtoSearchCriteria(c);

        } catch (Exception ex) {
            LOGGER.error('INS_CTRL_FailedConnexLeads | selectConnexLeads', ex);           
            throw new AuraHandledException('Failed to fetch lead records. Please contact your administrator.');
        }
    }
    
    
    
    /**
* @description: Retrieves the maximum lead date from the custom metadata type 'INS_Insurance_Lead_Settings__mdt'
*    for the record named 'Dialer_Leads'. This is typically used for filtering lead records.
*
* @return String - The date portion of INS_LeadDate__c as a string, or null if not found.
*/
    @AuraEnabled(cacheable=true)
    public static String getMaxDate() {
        try {
            INS_Insurance_Lead_Settings__mdt leadSetting = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
            string leadDate = null;
            if (leadSetting != null && leadSetting.INS_LeadDate__c != null) { 
                leadDate =  String.valueOf(leadSetting.INS_LeadDate__c.date());               
            }
            
            return leadDate;
        } catch (Exception ex) {
            
            LOGGER.error('INS_CTRL_FailedConnexLeads | getMaxDate ', ex);
            throw new AuraHandledException('Failed to retrieve lead max date. Please contact your administrator.');
        }
    }
    
    /**
* @description
*    Submits a list of selected Lead records to the batch class INS_BATCH_ConnexLead for further processing.
*    Typically used to push lead data to an external system.
*
* @param leadRecords List of Lead records selected by the user for processing.
*/
    @AuraEnabled
    public static void submitSelectedLeads(List<Lead> leadRecords) {
        try {
            if (leadRecords == null || leadRecords.isEmpty()) {
                throw new AuraHandledException('No leads were provided for submission.');
            } else {
                INS_Insurance_Lead_Settings__mdt leadSetting = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');
                List<Id> leadIds = new List<Id>();
                for (Lead l : leadRecords) {
                    leadIds.add(l.Id);
                }
                
                INS_BATCH_ConnexLead batch = new INS_BATCH_ConnexLead(
                    false, 
                    null, 
                    leadSetting.INS_LeadType__c, 
                    leadSetting.INS_ProductFamily__c, 
                    leadSetting.INS_LeadDate__c, 
                    leadIds
                );
                
                Database.executeBatch(batch, 10);
                
            }
        } catch (Exception ex) {
            LOGGER.error('INS_CTRL_FailedConnexLeads | submitSelectedLeads ', ex);
            throw new AuraHandledException('Failed to submit selected leads. Please contact your administrator.');
        }
    }
    
    /**
* @description
*    Checks whether the current user is a member of the 'INS_Dialer_Leads_Managers_PG' public group.
*    Returns true if running in test context or if user is part of the group.
*
* @return Boolean - True if user is in the group or if test is running, else false.
*/
    @AuraEnabled(cacheable=true)
    public static Boolean isUserInDialerLeadsManagersGroup() {
        try {
            Id currentUserId = UserInfo.getUserId();  
            SEL_GroupMember GpMember = new SEL_GroupMember();
            Boolean isMember = GpMember.isUserInGroupByName('INS_Dialer_Leads_Managers_PG', currentUserId);            
            return isMember;
            
        } catch (Exception ex) {
            LOGGER.error('INS_CTRL_FailedConnexLeads | isUserInDialerLeadsManagersGroup | exception | ', ex);
            throw new AuraHandledException('Failed to check group membership. Please contact your administrator.');
        }
    } 
    
    
    
    
    
}