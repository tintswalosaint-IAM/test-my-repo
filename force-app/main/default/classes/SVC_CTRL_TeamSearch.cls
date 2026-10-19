/**
 * @description:        Controller class for CMN Team search and queue mapping
 * @author:            Hlayisani Hlungwane
 * Test Class:    SVC_CTRL_TeamSearch_TEST
 * 25- 09 -10      Hlayisani Hlungwani      SFP-55563 Insurance: Manual case creation 
 *                                                     should reflect status of new
 */
public with sharing class SVC_CTRL_TeamSearch {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CTRL_TeamSearch');

    // Constants
    private static final String CLASS_NAME = 'SVC_CTRL_TeamSearch';
    private static final String METHOD_SEARCH_TEAMS = 'searchTeams';
    private static final String METHOD_GET_QUEUE_NAME = 'getQueueName';
    private static final Integer MAX_RESULTS = 10;

    @TestVisible
    private static Boolean forceException = false;

    /**
     * @description Retrieves CMN Team records filtered by country and search text.
     *              When search text is empty, the first 10 teams are returned.
     * @param searchText The text used to search for matching teams.
     * @param countryCode The country code used to filter the teams.
     * @return List<CMN_Team__c> List of matching teams (up to 10 records).
     */
    @AuraEnabled(cacheable = true)
    public static List<CMN_Team__c> searchTeams(String searchText, String countryCode) {
        List<CMN_Team__c> results = new List<CMN_Team__c>();

        try {
            if (Test.isRunningTest() && forceException) {
                throw new CalloutException('Forced Exception for Test Coverage');
            }

            List<CMN_Team__c> teams = CMN_DAL_Team.findByCountryCode(countryCode);

            if (teams != null && !teams.isEmpty()) {
                String searchValue = String.isNotBlank(searchText) ? searchText.trim().toLowerCase() : null;

                for (CMN_Team__c team : teams) {
                    Boolean matches = (searchValue == null) || 
                        (team.Name != null && team.Name.toLowerCase().contains(searchValue));

                    if (matches) {
                        results.add(team);
                        if (results.size() == MAX_RESULTS) {
                            break;
                        }
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[] { CLASS_NAME, METHOD_SEARCH_TEAMS }, e);
            AuraHandledException auraEx = new AuraHandledException('Unable to retrieve teams at this time.');
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }

        return results;
    }

    /**
     * @description Retrieves the queue name mapped to the selected CMN Team.
     * @param teamId The CMN Team record ID.
     * @return String The mapped queue name, or null if no mapping exists.
     */
    @AuraEnabled(cacheable = true)
    public static String getQueueName(Id teamId) {
        String queueName = null;

        try {
            if (Test.isRunningTest() && forceException) {
                throw new CalloutException('Forced Exception for Test Coverage');
            }

            if (teamId != null) {
                List<CMN_Team__c> teams = CMN_DAL_Team.findById(new Set<String>{ String.valueOf(teamId) });

                if (teams != null && !teams.isEmpty() && String.isNotBlank(teams[0].Name)) {
                    SVC_QueueTeamMappingSelector selector = new SVC_QueueTeamMappingSelector();
                    List<SVC_QueueTeamMapping__mdt> mappings = selector.getQueues(teams[0].Name);

                    if (mappings != null && !mappings.isEmpty()) {
                        queueName = mappings[0].SVC_Queue__c;
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[] { CLASS_NAME, METHOD_GET_QUEUE_NAME }, e);
            AuraHandledException auraEx = new AuraHandledException('Unable to retrieve queue mapping.');
            auraEx.setMessage(e.getMessage());
            throw auraEx;
        }

        return queueName;
    }
}