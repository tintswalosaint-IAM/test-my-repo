/**
 * @description Test class for User_PermissionSet_UTIL
 *
 * @author Milica Milicevic(Milica.Milicevic@standardbank.co.za)
 * @description Test class for User_PermissionSet_UTIL
 * @UserStory  SFP-50927 
 * @date July 2025
 *
 */
@isTest
private class User_PermissionSet_UTIL_Test {

    private static final String PERMISSION_SET = 'API_Credentials_Management';
    private static final String FAKE_PERMISSION_SET = 'Fake_API_Credentials_Management';


    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name ='Standard User' LIMIT 1];
        User userTest = new User(
            Alias = 'tuser',
            Email = 'unit.tester@test.com',
            ProfileId = p.Id,
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'Europe/Berlin',
            Username = 'unit.tester' + System.currentTimeMillis() + '@test.com'
        );
        insert userTest;
        return userTest;
    }

    @IsTest
    static void testUserWithoutPermissionSet() {
        User userTest = createTestUser();
        System.runAs(userTest) {
            Boolean result = User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET);
            Assert.areEqual(false, result, 'User doesnt contain permission set.');
        }
    }

    @IsTest
    static void testUserWithPermissionSet() {
        User userTest = createTestUser();

        PermissionSet ps = [
            SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_SET LIMIT 1
        ];

        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userTest.Id,
            PermissionSetId = ps.Id
        );
        insert psa;

        System.runAs(userTest) {
            Boolean result = User_PermissionSet_UTIL.userHasPermissionSet(PERMISSION_SET);
            Assert.areEqual(true, result, 'User contains permission set.');
        }
    }
}