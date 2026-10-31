/**
 * @description Controller class for CMN Team search and queue mapping.
 * @see SVC_CTRL_TeamSearch_TEST
 * @author Hlayisani Hlungwani
 * @date August 2026
 * @User Story SFP-55563 Insurance: Manual case creation should reflect status of new
 */
public inherited sharing class SVC_CTRL_TeamSearch
{
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_CTRL_TeamSearch');

	// Constants
	public static final String CLASS_NAME = 'Class: SVC_CTRL_TeamSearch';
	private static final String METHOD_SEARCH_TEAMS = 'Method: searchTeams';
	private static final String METHOD_GET_QUEUE_NAME = 'Method: getQueueName';
	private static final String ERR_SEARCH_TEAMS = 'Unable to retrieve teams. Please try again.';
	private static final String ERR_QUEUE_MAPPING = 'Unable to retrieve queue mapping. Please try again.';
	private static final String FORCED_EXCEPTION_MESSAGE = 'Test Exception';

	// Test exception flag
	@TestVisible
	private static Boolean mockForceException = false;

	/**
	 * @description Retrieves active teams for the logged-in user's country
	 * @param searchText Optional text used to search team names
	 * @return List<CMN_Team__c> Matching active teams, up to 10 records
	 * @throws AuraHandledException If an error occurs during team retrieval
	 * @see SVC_SEL_Team.selectByCountry
	 */
	@AuraEnabled(Cacheable = true)
	public static List<CMN_Team__c> searchTeams(String searchText)
	{
		try
		{
			throwAuraExceptionIfForced();

			User currentUser = [
				SELECT User_Country__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
				WITH USER_MODE
				LIMIT 1
			];

			String country = currentUser.User_Country__c;

			if(String.isBlank(country))
			{
				return new List<CMN_Team__c>();
			}

			return SVC_SEL_Team.newInstance().selectByCountry(country, searchText);
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, METHOD_SEARCH_TEAMS}, e);
			throw buildAuraException(ERR_SEARCH_TEAMS);
		}
	}

	/**
	 * @description Retrieves the queue mapped to the selected team
	 * @param teamId The CMN Team record ID
	 * @return String Mapped queue name, or null if no mapping exists
	 * @throws AuraHandledException If an error occurs during queue lookup
	 * @see SVC_SEL_Team.selectById
	 * @see SVC_QueueTeamMappingSelector.getQueues
	 */
	@AuraEnabled(Cacheable = true)
	public static String getQueueName(Id teamId)
	{
		try
		{
			throwAuraExceptionIfForced();

			if(teamId == null)
			{
				return null;
			}

			List<CMN_Team__c> teams = SVC_SEL_Team.newInstance().selectById(new Set<Id> {teamId});

			if(teams.isEmpty() || String.isBlank(teams.iterator().next().Name))
			{
				return null;
			}

			List<SVC_QueueTeamMapping__mdt> mappings =
				SVC_QueueTeamMappingSelector.newInstance().getQueues(teams.iterator().next().Name);

			return mappings.isEmpty() ? null : mappings.iterator().next().SVC_Queue__c;
		}
		catch(Exception e)
		{
			LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, METHOD_GET_QUEUE_NAME}, e);
			throw buildAuraException(ERR_QUEUE_MAPPING);
		}
	}

	/**
	 * @description Helper method for test purposes to throw exception if forced
	 */
	private static void throwAuraExceptionIfForced()
	{
		if(Test.isRunningTest() && mockForceException)
		{
			throw new AuraHandledException(FORCED_EXCEPTION_MESSAGE);
		}
	}

	/**
	 * @description Builds an AuraHandledException whose getMessage() returns the given text.
	 *              Without setMessage(), getMessage() returns "Script-thrown exception".
	 * @param message The agent-facing message
	 * @return AuraHandledException
	 */
	private static AuraHandledException buildAuraException(String message)
	{
		AuraHandledException auraException = new AuraHandledException(message);
		auraException.setMessage(message);
		return auraException;
	}
}