/**
 * @description       : Data factory class for complaints management
 * @author            : Aliaksei Koval
 * @last modified on  : 08-01-2024
 * @last modified by  : Aliaksei Koval
**/
@SuppressWarnings('PMD.ApexCrudViolation, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public without sharing class CMP_DAL_DataFactory {

    private static final Boolean ACTIVE_TRUE = true;
	private static final String APPLICABLE_PRODUCTS = 'Card;Forex;VAF';
	private static final Boolean ENABLED_FOR_COMPLAINTS = true;

    /**
	 * @description Will generate a new Teams
	 *
	 * @param numberOfItems Number of items to generate
	 * @param active
	 *
	 * @return List of Teams
	 */
	@TestVisible
	private static List<CMN_Team__c> generateTeams(Integer numberOfItems, Boolean active)
	{
		List<CMN_Team__c> newTeams = new List<CMN_Team__c>();

		for(Integer i = 0; i < numberOfItems; i++)
		{
			CMN_Team__c team = createNewTeam(active);
			newTeams.add(team);
		}

		insert newTeams;

		return newTeams;
	}

	/**
	 * @description Will creat new team
	 *
	 * @param active
	 *
	 * @return An unsaved team
	 */
	@TestVisible
	private static CMN_Team__c createNewTeam(Boolean active)
	{
		CMN_Team__c team = new CMN_Team__c();

		team.Name = CMN_DAL_SObjectDomain.generateRandomName();
		team.CMN_Active__c = active;
		team.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomEmail();

		return team;
	}

    /**
	 * @description Will generate service team
	 *
	 * @param serviceTypeId The service type id
	 * @param teamId The team Id
	 *
	 * @return An unsaved service team
	 */
	@TestVisible
	private static SVC_ServiceTeam__c newServiceTeam(Id serviceTypeId, Id teamId)
	{
		SVC_ServiceTeam__c newServiceTeam = new SVC_ServiceTeam__c();
		newServiceTeam.SVC_ServiceType__c = serviceTypeId;
		newServiceTeam.CMN_Team__c = teamId;
		newServiceTeam.SVC_Active__c = ACTIVE_TRUE;

		return newServiceTeam;
	}

    /**
	* @description Will generate a complaint service team
	* @param serviceTypeId 
	* @param teamId 
	* @return an unsaved complaint service team
	**/
	@TestVisible 
	private static SVC_ServiceTeam__c newServiceTeamWithApplicableProduct(Id serviceTypeId, Id teamId){
		SVC_ServiceTeam__c newServiceTeam = new SVC_ServiceTeam__c();
		newServiceTeam.SVC_ServiceType__c = serviceTypeId;
		newServiceTeam.CMN_Team__c = teamId;
		newServiceTeam.SVC_Active__c = ACTIVE_TRUE;
		newServiceTeam.SVC_ApplicableProductCategories__c = APPLICABLE_PRODUCTS;
		return newServiceTeam;
	}

	/**
	* @description Will generate a query service team
	* @param serviceTypeId 
	* @param teamId 
	* @return an unsaved query service team
	**/
	@TestVisible 
	private static SVC_ServiceTeam__c newServiceTeamWithQueueBasedRouting(Id serviceTypeId, Id teamId){
		SVC_ServiceTeam__c newServiceTeam = new SVC_ServiceTeam__c();
		newServiceTeam.SVC_ServiceType__c = serviceTypeId;
		newServiceTeam.CMN_Team__c = teamId;
		newServiceTeam.SVC_Active__c = ACTIVE_TRUE;
		newServiceTeam.SVC_QueueBasedRouting__c = true;
		newServiceTeam.SVC_ApplicableProductCategories__c = APPLICABLE_PRODUCTS;
		newServiceTeam.SVC_CaseRoutingQueue__c = 'TestQueue';
		newServiceTeam.SVC_GroupId__c = 'GROUP000';
		return newServiceTeam;
	}

	/**
	 * @description Will creat new complaints team
	 *
	 * @param active
	 *
	 * @return An unsaved complaints team
	 */
	@TestVisible
	private static CMN_Team__c createNewComplaintsTeam(Boolean active)
	{
		CMN_Team__c team = new CMN_Team__c();

		team.Name = CMN_DAL_SObjectDomain.generateRandomName();
		team.CMN_Active__c = active;
		team.CMN_Email__c = CMN_DAL_SObjectDomain.generateRandomEmail();
		team.SVC_EnableComplaintsManagement__c = ENABLED_FOR_COMPLAINTS;
		return team;
	}	

	/**
	 * @description Will creat new team member
	 *
	 * @params userId, teamId
	 *
	 * @return An unsaved team member
	 */
	@TestVisible
	private static CMN_TeamMember__c createNewTeamMember(String userId, String teamId)
	{
		CMN_TeamMember__c testTeamMember = new CMN_TeamMember__c();
		testTeamMember.CMN_Type__c = 'User';
		testTeamMember.CMN_User__c = userId;
		testTeamMember.CMN_Team__c = teamId;
		return testTeamMember;
	}

	/**
	 * @description Will creat new user
	 *
	 * @params profileName
	 *
	 * @return A user
	 */
	@TestVisible
	public static User createUser(String profileName) {
		User result = new User(
		  ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id,
		  LastName = 'LastName',
		  FirstName = 'FirstName',
		  Email = 'aob@sb.com',
		  Username = 'aob@sb.com' + System.currentTimeMillis(),
		  CommunityNickname = 'aob' + System.currentTimeMillis(),
		  CompanyName = 'aob',
		  Title = 'Volunteer',
		  Alias = 'aob',
		  TimeZoneSidKey = 'America/Los_Angeles',
		  EmailEncodingKey = 'UTF-8',
		  LanguageLocaleKey = 'en_US',
		  LocaleSidKey = 'en_US',
		  isActive = true
		);
	 
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert result;
		}
		return result;
	}
}