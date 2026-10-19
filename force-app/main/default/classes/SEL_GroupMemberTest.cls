/**
 * @Name of the Class: SEL_GroupMemberTest
 * @description class Application Approval flow, Queues and Sign off
 *
 * Story:SFP-34698 
 *
 * @author Shravani Ganta
 *
 * @date Mar 04 2025
 * @last modified on  : 04-03-2025
 * @last modified by  : Shravani Ganta
 * @Modification Description :SFP-34698 Application Approval flow, Queues and Sign off
 * 
 * @last modified on            : 12-03-2026
 * @last modified by            : Vikash Beersye
 * @modification description    : [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
 */
@isTest
private class SEL_GroupMemberTest {
    
    /**
     * @description Setup test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Group testGroup = new Group(
            Name = 'Test_Group',
            DeveloperName = 'Test_Group',
            Type = 'Regular'
        );
        insert testGroup;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@testorg.com'
        );
        insert testUser;
        
        GroupMember gm = new GroupMember(
            GroupId = testGroup.Id,
            UserOrGroupId = testUser.Id
        );
        insert gm;
    }
    
    /**
     * @description Test method for getSObjectType and getSObjectFieldList methods
     */
    @isTest
    static void testGetSObjectMethods() {
        SEL_GroupMember selector = new SEL_GroupMember();
        Assert.areEqual(GroupMember.SObjectType, selector.getSObjectType(), 
            'getSObjectType should return GroupMember SObjectType');
        
        List<Schema.SObjectField> expectedFields = new List<Schema.SObjectField> {
            GroupMember.Id,
            GroupMember.GroupId,
            GroupMember.UserOrGroupId
        };
        
        List<Schema.SObjectField> actualFields = selector.getSObjectFieldList();
        
        Assert.areEqual(expectedFields.size(), actualFields.size(), 
                       'Number of fields in getSObjectFieldList should match the expected count');
        
        for (Integer i = 0; i < expectedFields.size(); i++) {
            Assert.areEqual(expectedFields[i], actualFields[i], 
                           'Field at index ' + i + ' should match the expected field');
        }
    }
    
    /**
     * @description Test method for selectByIds method
     */
    @isTest
    static void testSelectByIds() {
        GroupMember gm = [SELECT Id FROM GroupMember LIMIT 1];
        Set<Id> groupMemberIds = new Set<Id>{ gm.Id };
        
        Test.startTest();
        
        SEL_GroupMember selector = new SEL_GroupMember();
        List<GroupMember> results = selector.selectByIds(groupMemberIds);
        
        Test.stopTest();
        
        Assert.areEqual(1, results.size(), 'selectByIds should return one record');
        Assert.areEqual(gm.Id, results[0].Id, 'The returned GroupMember Id should match the queried Id');
    }
    
    /**
     * @description Test method for selectByUserOrGroupIds method
     */
    @isTest
    static void testSelectByUserOrGroupIds() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
        Set<Id> userIds = new Set<Id>{ testUser.Id };
        
        Test.startTest();
        SEL_GroupMember selector = new SEL_GroupMember();
        List<GroupMember> results = selector.selectByUserOrGroupIds(userIds);
        
        Test.stopTest();
        
        Assert.areEqual(1, results.size(), 'selectByUserOrGroupIds should return one record');
        Assert.areEqual(testUser.Id, results[0].UserOrGroupId, 'The UserOrGroupId should match the user Id');
    }
    
    @isTest
    static void testSelectByGroupId() {
        Group gm = [SELECT Id FROM Group WHERE developerName = 'Test_Group' LIMIT 1];
        Set<Id> groupIds = new Set<Id>{ gm.id };
        
        Test.startTest();
        SEL_GroupMember selector = new SEL_GroupMember();
        List<GroupMember> results = selector.selectByGroupId(groupIds);
        Test.stopTest();
        
        Assert.areEqual(1, results.size(), 'selectByIds should return one record');
        Assert.areEqual(gm.Id, results[0].GroupId, 'The returned GroupMember Id should match the queried Id');
    }
    
    @isTest
    static void testisUserInGroupByName() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@testorg.com' LIMIT 1];
       	Group gp = [SELECT Id,Name FROM Group WHERE developerName = 'Test_Group' LIMIT 1];
        
        Test.startTest();
        
        SEL_GroupMember selector = new SEL_GroupMember();
        Boolean isMember = selector.isUserInGroupByName(gp.Name, testUser.Id);
        Test.stopTest();
        
        Assert.areEqual(true, isMember, 'Member Exists');
    }
    
    /**
     * @description Test method for the case where no records match the criteria
     */
    @isTest
    static void testNoMatchingRecords() {
        Set<Id> nonExistentIds = new Set<Id>{ 
            '005000000000000AJK'  
        };
        
        Test.startTest();
        
        SEL_GroupMember selector = new SEL_GroupMember();
        List<GroupMember> resultsByIds = selector.selectByIds(nonExistentIds);
        List<GroupMember> resultsByUserIds = selector.selectByUserOrGroupIds(nonExistentIds);
        
        Test.stopTest();
        
        Assert.areEqual(0, resultsByIds.size(), 'selectByIds should return no records for non-existent IDs');
        Assert.areEqual(0, resultsByUserIds.size(), 'selectByUserOrGroupIds should return no records for non-existent IDs');
    }
    
    /**
     * @description Test method for edge cases like null or empty sets
     */
    @isTest
    static void testEdgeCases() {
        SEL_GroupMember selector = new SEL_GroupMember();
        
        Test.startTest();
        
        Set<Id> emptySet = new Set<Id>();
        List<GroupMember> resultsByIdsEmpty = selector.selectByIds(emptySet);
        List<GroupMember> resultsByUserIdsEmpty = selector.selectByUserOrGroupIds(emptySet);
        
        Test.stopTest();
        
        Assert.areEqual(0, resultsByIdsEmpty.size(), 'selectByIds should return empty list for empty set');
        Assert.areEqual(0, resultsByUserIdsEmpty.size(), 'selectByUserOrGroupIds should return empty list for empty set');
    }
}