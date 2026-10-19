/**
 * @description       : Test class for SEL_Group
 * @author            : Tushar Walse
 * @last modified on  : 08-04-2025
 * @last modified by  : Tushar Walse
**/

@isTest
private class SEL_Group_Test {
    
    private static Id createTestGroup(String developerName, String groupName) {
        Group testGroup = new Group(
            Name = groupName,
            DeveloperName = developerName,
            Type = 'Queue' 
        );
        insert testGroup;
        return testGroup.Id;
    }

    @isTest
    static void testSelectById() {
        Id testGroupId = createTestGroup('Test_Dev_Name', 'Test Group');
        SEL_Group selector = new SEL_Group();
        Group result = selector.selectById(testGroupId);
        Assert.areNotEqual(null, result, 'Query should return a valid Group record.');
        Assert.areEqual(testGroupId, result.Id, 'The retrieved Group ID should match.');
        Assert.areEqual('Test Group', result.Name, 'The retrieved Group Name should match.');
        Assert.areEqual('Test_Dev_Name', result.DeveloperName, 'The retrieved DeveloperName should match.');
    }

    @isTest
    static void testSelectByDeveloperNameAndType() {
        Id testGroupId = createTestGroup('Test_Dev_Name', 'Test Group');
        SEL_Group selector = new SEL_Group();
        Group result = selector.selectByDeveloperNameAndType('Test_Dev_Name', 'Queue');
        Assert.areNotEqual(null, result, 'Query should return a valid Group record.');
        Assert.areEqual(testGroupId, result.Id, 'The retrieved Group ID should match.');
        Assert.areEqual('Test Group', result.Name, 'The retrieved Group Name should match.');
        Assert.areEqual('Test_Dev_Name', result.DeveloperName, 'The retrieved DeveloperName should match.');
    }

    @isTest
    static void testSelectByIds() {
        Id groupId1 = createTestGroup('Dev_Name_1', 'Group One');
        Id groupId2 = createTestGroup('Dev_Name_2', 'Group Two');
        Set<Id> groupIds = new Set<Id>{groupId1, groupId2};
        SEL_Group selector = new SEL_Group();
        List<Group> results = selector.selectByIds(groupIds);
        Assert.areEqual(2, results.size(), 'Query should return two Group records.');
        Set<Id> retrievedIds = new Set<Id>();
        for (Group g : results) {
            retrievedIds.add(g.Id);
        }
        Assert.areEqual(groupIds, retrievedIds, 'Retrieved Groups should match the inserted Groups.');
    }

    @isTest
    static void testSelectByRelatedIdsAndType() {
        Id groupId1 = createTestGroup('Dev_Name_1', 'Group One');
        Id groupId2 = createTestGroup('Dev_Name_2', 'Group Two');
        Set<Id> groupIds = new Set<Id>{groupId1, groupId2};
        SEL_Group selector = new SEL_Group();
        List<Group> results = selector.selectByRelatedIdsAndType(groupIds, 'Queue');
        Assert.areEqual(0, results.size(), 'Query should return 0 Group records.');
    }
}