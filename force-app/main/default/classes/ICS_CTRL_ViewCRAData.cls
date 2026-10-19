/**
 * @description SFP-32986 Class used to fetch response of Rely comply and display on LWC component
 * @author Ikyatha Naidu, Swapnil Walse
 * @date 22/04/2024
 ***************************************************** 
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: updated to latest version with improved error handling
 */
public with sharing class ICS_CTRL_ViewCRAData {

  
    @AuraEnabled(cacheable=true)
    public static String getJSONString(String recordId) {
        try {
            // Validate input
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('Record ID cannot be blank');
            }
            SEL_PartyProfileRisk partyProfileRiskSelector=new SEL_PartyProfileRisk();
            List<PartyProfileRisk> profileRisks =partyProfileRiskSelector.selectById(recordId);
            // Check if a record was found
            if (profileRisks.isEmpty()) {
                throw new AuraHandledException('No PartyProfileRisk record found with the given ID');
            }

            // Get the Full_CRA_Result__c field value
            String fullCRAResult = profileRisks[0].Full_CRA_Result__c;

            // Check if Full_CRA_Result__c is null or blank
            if (String.isBlank(fullCRAResult)) {
                return '{}'; // Return an empty JSON object if no data is found
            }

            // Unescape and return the JSON string
            return fullCRAResult.unescapeJava();
        } catch (AuraHandledException e) {
            // Re-throw AuraHandledExceptions as they are
           throw new AuraHandledException('An error occurred while retrieving the data');
        
    	}
    }

}