/**
 * @description Class has base methods that can be used to test and DAL class of Base Object
 *
 * @author Accenture
 *
 * @date May 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_Team_TEST
{
  private static final Integer NUMBER_OF_ITEMS_TO_GENERATE = 1;
  private static final Boolean ACTIVE = true;
  private static final Boolean INACTIVE = false;

  /**
   * @description To test if teams are available if active or inactive
   */
  @IsTest
  private static void hasTeams()
  {
    SVC_DAL_DataFactory.generateTeams(NUMBER_OF_ITEMS_TO_GENERATE, ACTIVE);
    SVC_DAL_DataFactory.generateTeams(NUMBER_OF_ITEMS_TO_GENERATE, INACTIVE);

    Test.startTest();

    List<CMN_Team__c> teams = CMN_DAL_Team.getAll();

    Test.stopTest();

    // Total teams should match
    Assert.areEqual(2, teams.size(), 'Did not match the expected total teams. Expected 2 but returned ' + teams.size());
  }

  /**
   * @description To test if teams are available if active
   */
  @IsTest
  private static void hasActiveTeams()
  {
    SVC_DAL_DataFactory.generateTeams(NUMBER_OF_ITEMS_TO_GENERATE, ACTIVE);

    Test.startTest();

    List<CMN_Team__c> teams = CMN_DAL_Team.getAllActive();

    Test.stopTest();

    // Total teams should match
    Assert.areEqual(NUMBER_OF_ITEMS_TO_GENERATE, teams.size(), 'Did not match the expected total teams. Expected ' + NUMBER_OF_ITEMS_TO_GENERATE + ' but returned ' + teams.size());
  }

  /**
   * @description To test if teams are available thru IDs
   */
  @IsTest
  private static void hasTeamsById()
  {
    List<CMN_Team__c> newTeams = SVC_DAL_DataFactory.generateTeams(NUMBER_OF_ITEMS_TO_GENERATE, ACTIVE);

    Set<String> teamIds = new Set<String>();
    for(CMN_Team__c team : newTeams)
    {
      teamIds.add(team.Id);
    }

    Test.startTest();

    List<CMN_Team__c> teams = CMN_DAL_Team.findById(teamIds);

    Test.stopTest();

    // Should have active teams
    Assert.isTrue(teams.size() > 0, 'Expected to have a team but none was created');
  }

  /**
   * @description To test if teams are available thru email
   */
  @IsTest
  private static void hasTeamsByEmail()
  {
    List<CMN_Team__c> newTeams = SVC_DAL_DataFactory.generateTeams(NUMBER_OF_ITEMS_TO_GENERATE, ACTIVE);
    CMN_Team__c team = newTeams.iterator().next();

    Test.startTest();

    List<CMN_Team__c> teams = CMN_DAL_Team.getByEmail(team.CMN_Email__c);

    Test.stopTest();

    // Should have teams according to email
    Assert.isTrue(teams.size() > 0, 'Expected to have a team but none was created using email: ' + team.CMN_Email__c);
  }

  /**
   * @description To test if teams are available thru Country Code
   */
  @IsTest
  private static void hasTeamsByCountryCode()
  {
    Test.startTest();

    Boolean hasStateAndCountryPicklists = Schema.SObjectType.CMN_Team__c.fields.getMap().containsKey(CMN_DAL_Team.FIELD_COUNTRY_CODE);

    // State and Country should be enabled
    Assert.areEqual(true, hasStateAndCountryPicklists, 'Expected result is true but returned ' + hasStateAndCountryPicklists);

    List<String> pickvals = CMN_UTIL_System.getPicklistValues(CMN_DAL_Team.OBJECT_NAME, CMN_DAL_Team.FIELD_COUNTRY_CODE);

    String countryCode = pickvals[0];

    CMN_Team__c team = SVC_DAL_DataFactory.createNewTeam(ACTIVE);
    team.CMN_CountryCode__c = countryCode;
    insert team;

    List<CMN_Team__c> teams = CMN_DAL_Team.findByCountryCode(countryCode);

    Test.stopTest();

    // Should have teams according to country code
    Assert.isTrue(teams.size() > 0, 'Expected to have a team but none was created using country code: ' + countryCode);
  }

    @isTest
    static void testGetTeamIdFromName() {
    Test.startTest();
        CMN_Team__c testTeam = CMP_DAL_DataFactory.createNewTeam(ACTIVE);
        insert testTeam;

        CMN_DAL_Team.TeamIdAndNameWrapper result = CMN_DAL_Team.getTeamIdFromName(testTeam.Name);
    Test.stopTest();
        Assert.isNotNull(result.teamName);
        Assert.areEqual(testTeam.Id, result.teamId);
    }

 

    @isTest
    static void testGetTeamsByUserId() {
    Test.startTest();
        User testUser = CMP_DAL_DataFactory.createUser('SVC Agent Banker');


        CMN_Team__c testTeam = CMP_DAL_DataFactory.createNewTeam(ACTIVE);
        insert testTeam;
        CMN_TeamMember__c testTeamMember = CMP_DAL_DataFactory.createNewTeamMember(testUser.Id, testTeam.Id);
        insert testTeamMember;

        List<CMN_TeamMember__c> result = CMN_DAL_Team.getTeamsByUserId(testUser.Id);
    Test.stopTest();
        Assert.areEqual(1, result.size());
        Assert.areEqual(testTeam.Id, result[0].CMN_Team__c);
    }

}