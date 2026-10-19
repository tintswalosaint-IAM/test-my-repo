/**
 * @description       : Controller for the Lead action overrides.  
 * @author            : Derek Hughes
 * @group             : Controller
 * @last modified on  : 27-06-2023
 * @last modified by  : Derek Hughes
**/
public with sharing class CTRL_LeadActionOverride {
   
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CTRL_LeadActionOverride.class.getName());

    /**
    * @description Returns data needed by the Override LWC
    * @author Derek Hughes | 04-05-2023 
    * @param actionName 
    * @param leadId 
    * @param userId 
    * @return ActionOverrideResult 
    **/
    @AuraEnabled(cacheable=true)
    public static ActionOverrideResult getActionOverride (String actionName, Id leadId, Id userId, Id recordTypeId) {

        try {   
            Map<Id, Schema.RecordTypeInfo> recordTypes = Lead.sObjectType.getDescribe().getRecordTypeInfosById();
           
            User user = new SEL_User().selectUsersByIds(new Set<Id> {userId}).get(0);
            
            Relationship_Management_Settings__mdt countrySetting = DMN_RelationshipManagementSettings.getCountrySettings(user.User_Country__c);
            
            if (countrySetting == null) {
                throw new AuraHandledException('SETUP ERROR: Cannot find Relationship Management Settings for user from '+user.User_Country__c);
            }

            ActionOverrideResult result = new ActionOverrideResult();

            result.leadId = leadId;

            result.useNewLeadWizard = false;

            if (recordTypeId != null && String.isNotBlank(countrySetting.Lead_Wizard_Record_Types__c)) {
                result.recordTypeName = recordTypes.get(recordTypeId).getDeveloperName();
                List<String> wizardRecordTypes = countrySetting.Lead_Wizard_Record_Types__c.trim().split('\\s*,\\s*');
                if (wizardRecordTypes?.contains(result.recordTypeName)) {
                    result.useNewLeadWizard = true;
                }
            }

            result.profileName = user.Profile.Name;
            result.userName = user.Name;
            result.userCountry = user.User_Country__c;
            result.overrideUrl = null;  // no force override

            return result;
        } 
        catch (Exception e) {
            LOGGER.fatal('getActionOverride: Unhandled exception', e);
            throw new AuraHandledException(e.getMessage());
        }

    }

    public class ActionOverrideResult {
        @AuraEnabled public Id leadId;
        @AuraEnabled public String profileName;
        @AuraEnabled public String userName;
        @AuraEnabled public String userCountry;
        @AuraEnabled public String overrideUrl;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public Boolean useNewLeadWizard;

    }
    
}