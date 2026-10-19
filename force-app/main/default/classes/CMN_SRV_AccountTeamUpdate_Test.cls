/**
* @description Unit test class for CMN_SRV_AccountTeamUpdate
*
* @author Karabo Machubeni
*
* @date August 2023
*/
@isTest
private class CMN_SRV_AccountTeamUpdate_Test{

    private static final String SOUTH_AFRICA = 'ZA';
    private static final Id ACCOUNT_RECORDTYPE_PERSON =
    Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();


    @isTest
    private static void processAccountsTest() {
        List<Account> testAccounts = new CMN_AccountMaintenance_TestDataFactory(true).createPersonAccounts(
            5, ACCOUNT_RECORDTYPE_PERSON
        );
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User testUser = new CMN_AccountMaintenance_TestDataFactory().createUsers(
            1, profileId, 'XBWER0', 'XBWER', 'RM Assistant'
        ).get(0);

        CMN_SRV_AccountTeamUpdate.Result result;
        Test.startTest();
        System.runAs(testUser) {
            DMN_User userDomain = new DMN_User();
            SEL_User userSelector = new SEL_User();
            CMN_SRV_AccountTeamUpdate cmnAccountUpdate = new CMN_SRV_AccountTeamUpdate();
            cmnAccountUpdate.setUsers(
                userDomain.getCodeToUserIds(userSelector.selectActiveWithPortfoliosByCountry(new Set<String>{'ZA', 'GH'}))
            );
            result = cmnAccountUpdate.process(testAccounts);
        }
        Test.stopTest();


        List<AccountTeamMember> members = [SELECT Id FROM AccountTeamMember];
        Assert.areEqual(1, members.size(), '1 member should have been added');
        Assert.areEqual(1, result.teamMembersAdded, 'Result should show 1 team member added');

    }

    @isTest
    private static void testProcess() {
        String TEST_CODE = 'testCode';
        List<Account> testAccounts = new CMN_AccountMaintenance_TestDataFactory(true).createPersonAccounts(
            5, ACCOUNT_RECORDTYPE_PERSON
        );
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User testUser = new CMN_AccountMaintenance_TestDataFactory(true).createUsers(
            1, profileId, TEST_CODE, 'XBWER', 'RM Assistant'
        ).get(0);

        new CMN_AccountMaintenance_TestDataFactory(true).createAccountTeamMembers(testUser.Id, 'RM Assistant', testAccounts);

        Test.startTest();
        System.runAs(testUser) {
            DMN_User userDomain = new DMN_User();
            SEL_User userSelector = new SEL_User();
            CMN_SRV_AccountTeamUpdate cmnAccountUpdate = new CMN_SRV_AccountTeamUpdate();
            cmnAccountUpdate.setUsers(
                userDomain.getCodeToUserIds(userSelector.selectActiveWithPortfoliosByCountry(new Set<String>{'ZA', 'GH'}))
            );
            cmnAccountUpdate.process(testAccounts);
            cmnAccountUpdate.logError(UserInfo.getUserId(), new List<Database.Error>());
        }
        Test.stopTest();
        List<AccountTeamMember> members = [SELECT Id FROM AccountTeamMember];
        Assert.areEqual(1, members.size(), 'No members created');
    }

}