/***************************************************************************************
@ Author            : jyothsna.datla@standardbank.co.za
@ Date              : 18-02-2026
@ Name of the Class : CMN_FHQInformation
@ Description       : This class retrieves Financial Health Questionnaire (FHQ) responses
                      and related metadata for a Lead record.
@ Last Modified By  : jyothsna.datla@standardbank.co.za
@ Last Modified On  : 25-02-2026
 Ver       Date         Author                              Modification       
1.0      Feb 2026   jyothsna.datla@standardbank.co.za      Sync FHQ information to the new standrd alone FHQ App(PPBSF-291) 
***************************************************************************************/
public with sharing class CMN_FHQInformation {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_FHQInformation');

    // ── Test hooks ──────────────────────────────────────────────────────────
    @TestVisible private static Boolean simulateNoPermission   = false;
    @TestVisible private static Boolean simulateFHQDataError   = false;
    @TestVisible private static Boolean simulateMetadataError  = false;
    // ────────────────────────────────────────────────────────────────────────

    /**
     * @description Returns a map of FHQ question responses keyed by question
     *              text for the given Lead record Id.
     * @param recordId The Lead record Id.
     * @return Map of question text to CMN_Question_Response__c, or empty map.
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, CMN_Question_Response__c> FHQData(String recordId) {
        try {
            if (simulateFHQDataError) {
                throw new AuraHandledException('Forced test exception');
            }

            Map<String, CMN_Question_Response__c> responseMap =
                new Map<String, CMN_Question_Response__c>();

            if (String.isBlank(recordId)) {
                return responseMap;
            }

            if (!hasLeadReadPermission()) {
                return responseMap;
            }
            Lead leadRecord = [SELECT Id, Source_System_Reference__c, Was_FHQ_Completed__c, ID_Number__c
                               FROM Lead
                               WHERE Id = :recordId
                               LIMIT 1];

            if (leadRecord == Null) {
                return responseMap;
            }


            if (String.isBlank(leadRecord.Source_System_Reference__c) && String.isNotBlank(leadRecord.ID_Number__c)) {
               SEL_CMNQuestionResponse selector = new SEL_CMNQuestionResponse();
            List<CMN_Question_Response__c> guestresponses =
                selector.selectByIdNumber(leadRecord.ID_Number__c);

            for (CMN_Question_Response__c resp : guestresponses) {
                if (!String.isBlank(resp.CMN_Question_Text__c)) {
                    responseMap.put(resp.CMN_Question_Text__c, resp);
                }
            }
               
      }
           else if (String.isNotBlank(leadRecord.Source_System_Reference__c)){
            SEL_CMNQuestionResponse selector = new SEL_CMNQuestionResponse();
            List<CMN_Question_Response__c> responses =
                selector.selectByUserId(leadRecord.Source_System_Reference__c);

            for (CMN_Question_Response__c resp : responses) {
                if (!String.isBlank(resp.CMN_Question_Text__c)) {
                    responseMap.put(resp.CMN_Question_Text__c, resp);
                }
            }
           }
           
            return responseMap;

        } catch (Exception ex) {
            LOGGER.error('FHQData Error: ' + ex.getMessage());
            throw new AuraHandledException('Unable to retrieve FHQ data.');
        }
    }

    /**
     * @description Returns true if the current user has read access to the
     *              Lead object and Source_System_Reference__c field.
     */
    public static Boolean hasLeadReadPermission() {
        if (simulateNoPermission) {
            return false;
        }
        return Schema.sObjectType.Lead.isAccessible() &&
               Schema.sObjectType.Lead.fields.Source_System_Reference__c.isAccessible();
    }

    /**
     * @description Returns all FHQ Question Configuration custom metadata records.
     */
    @AuraEnabled(cacheable=true)
    public static List<FHQ_Question_Configuration__mdt> getFHQMetadata() {
        try {
            if (simulateMetadataError) {
                throw new AuraHandledException('Forced test exception');
            }

            return new SEL_FHQ_Question_Configuration().selectAll();

        } catch (Exception ex) {
            LOGGER.error('FHQMetadata Error: ' + ex.getMessage());
            throw new AuraHandledException('Unable to retrieve FHQ metadata.');
        }
    }
}