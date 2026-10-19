/***************************************************************************************
@Name of the Component : SEL_ServiceTeam_TEST
@Description : Test class for SEL_ServiceTeam
@Author : Raymond Magezi
@Created Date : 15 October 2025
User Story: SFP-53311
@Modification description: Test class created for technical review - replace inline SOQL with selector pattern
***************************************************************************************/
@IsTest(SeeAllData=false)
private class SEL_ServiceTeam_TEST {

	//variable for keeping service type name for test cases
	private static final String SERVICE_TYPE_NAME = 'Test Service Type';
	//variable for keeping team name for test cases
	private static final String TEAM_NAME = 'Test Team';
	//variable for keeping assert error message
	private static final String SERVICE_TEAM_ERROR_MSG = 'Service team was not found';

	/**
    * @description Test method for SEL_ServiceTeam.selectServiceTeamsByTeamId
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTeamsByTeamId() {
		// Create test data
		CMN_Team__c testTeam = new CMN_Team__c(
				Name = TEAM_NAME,
				CMN_Active__c = true
		);
		insert testTeam;

		SVC_ServiceType__c testServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_Active__c = true
		);
		insert testServiceType;

		SVC_ServiceTeam__c testServiceTeam = new SVC_ServiceTeam__c(
				CMN_Team__c = testTeam.Id,
				SVC_ServiceType__c = testServiceType.Id,
				SVC_Active__c = true
		);
		insert testServiceTeam;

		Test.startTest();
		List<SVC_ServiceTeam__c> serviceTeams = SEL_ServiceTeam.newInstance().selectServiceTeamsByTeamId(testTeam.Id);
		Test.stopTest();
		
		Assert.areEqual(1, serviceTeams.size(), SERVICE_TEAM_ERROR_MSG);
		Assert.areEqual(testTeam.Id, serviceTeams[0].CMN_Team__c, 'Team ID does not match');
	}

	/**
    * @description Test method for SEL_ServiceTeam.selectServiceTeamsByTeamAndServiceTypePicklist
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTeamsByTeamAndServiceTypePicklist() {
		// Create test data
		CMN_Team__c testTeam = new CMN_Team__c(
				Name = TEAM_NAME,
				CMN_Active__c = true
		);
		insert testTeam;

		SVC_ServiceType__c testServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_ServiceType__c = 'SVC_Complaint',
				SVC_Active__c = true
		);
		insert testServiceType;

		SVC_ServiceTeam__c testServiceTeam = new SVC_ServiceTeam__c(
				CMN_Team__c = testTeam.Id,
				SVC_ServiceType__c = testServiceType.Id,
				SVC_Active__c = true
		);
		insert testServiceTeam;

		Test.startTest();
		List<SVC_ServiceTeam__c> serviceTeams = SEL_ServiceTeam.newInstance()
			.selectServiceTeamsByTeamAndServiceTypePicklist(testTeam.Id, 'SVC_Complaint');
		Test.stopTest();
		
		Assert.areEqual(1, serviceTeams.size(), SERVICE_TEAM_ERROR_MSG);
		Assert.areEqual(testTeam.Id, serviceTeams[0].CMN_Team__c, 'Team ID does not match');
	}

	/**
    * @description Test method for SEL_ServiceTeam.selectServiceTeamsByTeamId with inactive service team
    * @author Raymond Magezi
    * @created Date 15 October 2025
    * @user Story SFP-53311
    */
	@isTest
	private static void testSelectServiceTeamsByTeamIdInactive() {
		// Create test data
		CMN_Team__c testTeam = new CMN_Team__c(
				Name = TEAM_NAME,
				CMN_Active__c = true
		);
		insert testTeam;

		SVC_ServiceType__c testServiceType = new SVC_ServiceType__c(
				Name = SERVICE_TYPE_NAME,
				SVC_Active__c = true
		);
		insert testServiceType;

		SVC_ServiceTeam__c testServiceTeam = new SVC_ServiceTeam__c(
				CMN_Team__c = testTeam.Id,
				SVC_ServiceType__c = testServiceType.Id,
				SVC_Active__c = false // Inactive
		);
		insert testServiceTeam;

		Test.startTest();
		List<SVC_ServiceTeam__c> serviceTeams = SEL_ServiceTeam.newInstance().selectServiceTeamsByTeamId(testTeam.Id);
		Test.stopTest();
		
		Assert.areEqual(0, serviceTeams.size(), 'Should not return inactive service teams');
	}
}