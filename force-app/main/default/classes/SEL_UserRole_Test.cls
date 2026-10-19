/**
 * @description       : Test class for Sel_UserRole selector class
 * @author            : Tushar Walse
 * @last modified on  : 26-05-2025
 * @last modified by  : Tushar Walse
**/

@isTest
private class SEL_UserRole_Test {

    @isTest
    static void test_selectById() {
        UserRole ur = [SELECT Id FROM UserRole LIMIT 1];

        SEL_UserRole sel = new SEL_UserRole();

        UserRole result = sel.selectById(ur.Id);

        Assert.areNotEqual(null, result, 'UserRole should be returned');
        Assert.areEqual(ur.Id, result.Id, 'Returned Id should match');
    }

    @isTest
    static void test_selectByIds() {

        List<UserRole> roles = [SELECT Id FROM UserRole LIMIT 2];
        Set<Id> ids = new Set<Id>();
        for (UserRole ur : roles) {
            ids.add(ur.Id);
        }

        SEL_UserRole sel = new SEL_UserRole();

        List<UserRole> result = sel.selectByIds(ids);

        Assert.areEqual(ids.size(), result.size(), 'Should return same number of roles');
    }
}