/**
 * @description       : Batch class to get the NBA conversation responses and reasons and update the local copies
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 18-04-2024
 * @last modified by  : Derek Hughes
**/
@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it used the batch job base class
global without sharing class PER_BATCH_NBA_RefreshResponses extends sbgbase.BatchJobBase 
    implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(PER_BATCH_NBA_RefreshResponses.class.getName());

    private static final Integer BATCH_SIZE = 1;

    private String countryCode;
    private String countryCodes = '';

    private List<PER_API_NBA_GetSingleReasons.DTO> nbaReasonDTOs;
    private List<PER_API_NBA_GetSingleResponses.DTO> nbaResponseDTOs;

    private Map<String, Set<PER_API_NBA_GetSingleReasons.Reason>> nbaReasonsByResponse;
    private Map<String, sbgpers__Recommended_Action_Response__c> newActionResponsesByKey;
    private List<sbgpers__Recommended_Action_Response__c> oldActionResponses;
    private List<sbgpers__Recommended_Action_Response__c> deleteActionResponses;
    private Map<String, sbgpers__Recommended_Action_Response__c> oldActionResponsesByKey;

    /**
    * @description Default constructor 
    **/
    global PER_BATCH_NBA_RefreshResponses() {
        super();
    }

    /**
    * @description Start the batch process for all the countries that use the NBA Data Provider
    * @author Derek Hughes | 04-03-2024 
    * @param bc 
    * @return Iterable 
    **/
    public Iterable<sObject> start(Database.BatchableContext bc) {
      
        super.startJob(bc);

        // Get all the country configs that user the NBA Data Provider so we can get the response for those countryCodes
        // Use inline select as this is only required to initiate the batch process and is not for general use
        List<sbgpers__Personalisation_Country_Config__mdt> configs;
        if (Test.isRunningTest()) {
            configs = [
                SELECT DeveloperName 
                FROM sbgpers__Personalisation_Country_Config__mdt 
                WHERE sbgpers__Data_Source__c = 'Apex Class' AND sbgpers__Apex_Service_Class_Name__c = 'PER_NBA_DataProvider'
                    AND DeveloperName = 'UG'
            ];
        }
        else {
            configs = [
                SELECT DeveloperName 
                FROM sbgpers__Personalisation_Country_Config__mdt 
                WHERE sbgpers__Data_Source__c = 'Apex Class' AND sbgpers__Apex_Service_Class_Name__c = 'PER_NBA_DataProvider'
                    
            ];
        }

        LOGGER.info('Batch process started: Countries to be processed: '+configs.size());

        return configs;

    }

    /**
    * @description process a single batch (which will be 1 config record for 1 country)
    * @author Derek Hughes | 04-03-2024 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<sObject> scope) {

        LOGGER.debug('execute: scope.size='+scope.size());

        try {
            
            // Batch size is always 1 so no loop required
            sbgpers__Personalisation_Country_Config__mdt config = (sbgpers__Personalisation_Country_Config__mdt)scope[0];

            LOGGER.debug('execute: config.DeveloperName='+config.DeveloperName);
            countryCode = config.DeveloperName;
            countryCodes += (String.isNotBlank(countryCodes) ? ', ' : '') + countryCode;

            nbaReasonDTOs = new PER_API_NBA_GetSingleReasons().call(countryCode);
            nbaResponseDTOs = new PER_API_NBA_GetSingleResponses().call(countryCode);

            LOGGER.debug('execute: nbaReasonDTOs.size='+nbaReasonDTOs.size() + ' nbaResponseDTOs.size='+nbaResponseDTOs.size());
            LOGGER.debug('execute: nbaReasonDTOs[0].reasonLookup.size='+nbaReasonDTOs[0].reasonLookup.size());

            // Prepare a map with an entry for each response mapped to a list of reasons for that responses
            prepareReasonsByResponse(nbaReasonDTOs[0].reasonLookup);

            // Prepare a map with an entry for each possible Subcategory, Response and Reason combination mapped to a Action Response
            prepareActionResponsesByKey(nbaResponseDTOs[0].responses);

            // Load the current Action Responsse for the country
            oldActionResponses = new PER_SEL_RecommendedActionResponse().selectByCountryCode(countryCode);
            
            LOGGER.debug('execute: oldActionResponses.size='+oldActionResponses.size());

            // Check each current action response against the new map.  If no longer needed add to delete map. If still current remove from the new list
            determineActionChanges();
            
            LOGGER.debug('execute: newActionResponsesByKey.size='+newActionResponsesByKey.size() + ' deleteActionResponses.size='+deleteActionResponses.size());

            // Delete the current Action Responses that were not found in the new list
            delete deleteActionResponses;

            // Insert any items left in the new list after all the current Action Responses were removed
            insert newActionResponsesByKey.values();

            finishBatch(bc, scope.size(), 0, '');
        }
        catch (Exception ex) {
            LOGGER.fatal('execute: Processing '+countryCodes+' failed.\nUnhandled exception', ex);
            finishBatch(bc, scope.size(), scope.size(),  'Processing '+countryCodes+' failed.\nUnhandled exception:' + ex.getMessage());
        }

    }

    /**
    * @description Prepare a map with an entry for each response mapped to a list of reasons for that responses
    * @author Derek Hughes | 04-03-2024 
    * @param reasonLookup 
    * @return Map<String, Set<PER_API_NBA_GetSingleReasons.Reason>> 
    **/
    private Map<String, Set<PER_API_NBA_GetSingleReasons.Reason>> prepareReasonsByResponse(List<PER_API_NBA_GetSingleReasons.Reason> reasonLookup) {
       nbaReasonsByResponse = new Map<String, Set<PER_API_NBA_GetSingleReasons.Reason>>();

        for (PER_API_NBA_GetSingleReasons.Reason nbaReason : reasonLookup) {
            Set<PER_API_NBA_GetSingleReasons.Reason> nbaReasonsForResponse = nbaReasonsByResponse.get(nbaReason.response);
            if (nbaReasonsForResponse == null) {
                nbaReasonsForResponse = new Set<PER_API_NBA_GetSingleReasons.Reason>();
            }
            nbaReasonsForResponse.add(nbaReason);
            nbaReasonsByResponse.put(nbaReason.response, nbaReasonsForResponse);
        }

        return nbaReasonsByResponse;
    }

    /**
    * @description Prepare a map with an entry for each possible Subcategory, Response and Reason combination mapped to a Action Response
    * @author Derek Hughes | 04-03-2024 
    * @param responses 
    * @return Map<String, sbgpers__Recommended_Action_Response__c> 
    **/
    private Map<String, sbgpers__Recommended_Action_Response__c> prepareActionResponsesByKey (List<PER_API_NBA_GetSingleResponses.Response> responses) {

       newActionResponsesByKey = new Map<String, sbgpers__Recommended_Action_Response__c>();
    
        for (PER_API_NBA_GetSingleResponses.Response nbaResponse: responses) {
            Set<PER_API_NBA_GetSingleReasons.Reason> nbaReasonsForResponse = nbaReasonsByResponse.get(nbaResponse.response);
            
            if (nbaReasonsForResponse != null) {
                for (PER_API_NBA_GetSingleReasons.Reason nbaReason : nbaReasonsForResponse) {
                    sbgpers__Recommended_Action_Response__c newActionResponse = new sbgpers__Recommended_Action_Response__c(
                        sbgpers__Category__c = null, 
                        sbgpers__Country_Code__c = countryCode, 
                        sbgpers__Sub_Category__c = nbaResponse.subCategory,   
                        sbgpers__Response__c = nbaResponse.response, 
                        sbgpers__Reason__c = nbaReason.reason
                    ); 

                    String actionResponseKey = nbaResponse.subCategory+nbaResponse.response+nbaReason.reason;
                    newActionResponsesByKey.put(actionResponseKey, newActionResponse);
                }
            }
        }
        return newActionResponsesByKey;
    }

    /**
    * @description Check each current action response against the new map.  If no longer needed add to delete map. If still current remove from the new list
    * @author Derek Hughes | 04-03-2024 
    **/
    private void determineActionChanges() {
        deleteActionResponses = new List<sbgpers__Recommended_Action_Response__c>();
        oldActionResponsesByKey = new Map<String, sbgpers__Recommended_Action_Response__c>();

        for (sbgpers__Recommended_Action_Response__c oldActionResponse : oldActionResponses) {
            String actionResponseKey = oldActionResponse.sbgpers__Sub_Category__c + oldActionResponse.sbgpers__Response__c + oldActionResponse.sbgpers__Reason__c;
            oldActionResponsesByKey.put(actionResponseKey, oldActionResponse);

            sbgpers__Recommended_Action_Response__c newActionResponseByKey = newActionResponsesByKey.get(actionResponseKey);
            if (newActionResponseByKey == null) {
                deleteActionResponses.add(oldActionResponse);
            }
            else {
                newActionResponsesByKey.remove(actionResponseKey);
            }
        }
    }

    /**
    * @description finish the batch process
    * @author Derek Hughes | 04-03-2024 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        String finalMessage = 'NBA Response processing complete for: '+countryCodes;
        
        LOGGER.info(finalMessage);

        super.finishJob(bc);

    }

    /**
    * @description Executes the batch job immediately
    * @author Derek Hughes | 18-04-2024 
    **/
    public static void run() {
        Database.executeBatch(new PER_BATCH_NBA_RefreshResponses(), BATCH_SIZE);
    }
 
}