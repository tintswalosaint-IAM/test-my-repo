/**
 * @description class used as controller for  Opportunity Sales Path
 *
 * Story : * SFP-31898
 *
 * @author Ikyatha Naidu 
 * @date Jan 2023
 * @last modified on  : 06-30-2025
 * @last modified by  : Ramya Gurram
 * @Modification Description : Initial Version
 */
public without sharing class ICS_CTRL_OpportunitySalesPath {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_OpportunitySalesPath');
    /**
     * @description get opportunity stafe
     * @param oppId
     * @return string 
     */
    @AuraEnabled
    Public static string fetchOpportunityStage(string oppId) {
        try{
            SEL_Opportunity selectOpportunityData = new SEL_Opportunity();
            Opportunity opp = selectOpportunityData.selectById(oppId);
            string stageName = '';
            if (opp != null) {
                stageName = opp.stageName;
            }
         return stageName;
        }catch(Exception e){
            LOGGER.error('Error in fetching stage: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description method to display Opportunity Stage Values
     * @return stageList
     */
    @AuraEnabled(cacheable = true)
    public static List < string > returnOppStageValues() {
        try{
        List < string > stageList = new List < string > ();
        ics_customlabel__mdt metaDataInfo =ICS_CTRL_PreAppFormCreator.getLandingPageJSON('SBO_Direct_SalesPathStages');
        string jsonString = metaDataInfo.description__c;
        Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        List<Object> stages = (List<Object>) parsedData.get('stages');
        Map<Integer, String> stageOrderMap = new Map<Integer, String>();
        // Iterate through the stages and populate the map
        for (Object stageObj : stages) {
            Map<String, Object> stage = (Map<String, Object>) stageObj;
            Integer order = Integer.valueOf(stage.get('order'));
            String label = (String) stage.get('label');
            stageOrderMap.put(order, label);
        }
        List < integer > sortedKeys = new List < integer > (stageOrderMap.keySet());
        sortedKeys.sort();
        for (integer key: sortedKeys) {
            stageList.add(stageOrderMap.get(key));
        }
        return stageList;
        }catch(Exception e){
            LOGGER.error('Error in fetching stage: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    /**
     * @description method to get declined stage value
     * @param accId
     * @return string Declined stage
     */
    @AuraEnabled
    public static string getDeclinedStageValue(string accId) {
    try {
        return JSON.serialize(new SEL_Opportunity().selectByAccountId(accId)); 
    } catch (Exception e) {
        LOGGER.error('Error in fetching stage: ' + e.getMessage());
        throw new AuraHandledException(e.getMessage());
    }
}
    /**
     * @description method to get declined stage value
     * @param accId
     * @return string Declined stage
     */
    @AuraEnabled
    public static string checkApplicationFormStageValue(string accId) {
    try {     
            ApplicationForm[] applicationForms = new SEL_ApplicationForm().selectByAccountId(accId);
            Opportunity opportunity = new SEL_Opportunity().selectById(applicationForms[0].OpportunityId);
            if(opportunity == null) {
                return '';
            }
        return JSON.serialize(opportunity); 
    } catch (Exception e) {
        LOGGER.error('Error in fetching stage: ' + e.getMessage());
        throw new AuraHandledException(e.getMessage());
    }
}
}