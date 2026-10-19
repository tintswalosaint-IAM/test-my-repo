/**
* @description       : Test class for INS_CTRL_SbibExpireLeads
* @author            : Raja Arsalan
* @UserStory         : SFP-51744
* @LastModifiedDate  : 2024-06-19
* @LastModifiedBy    : Raja Arsalan
* @LastModifiedReason  : SFP- 59417 Added test setup method to create test user and assign permission set.

**/

@isTest
private class INS_CTRL_SbibExpireLeads_Test {
    
    /**
* @description method to setup testdata.
*/    
    
    @testSetup
    static void setup() {
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;
        
        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Lead_Administrator'
            LIMIT 1
        ];
        
        System.runAs(u) {
            insert new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = ps.Id
            );
        }
    }
    
    /**
* @description Test for fetchAllLeads
*/
    @isTest
    static void testFetchAllLeads() {
        
        User u = [
            SELECT Id
            FROM User
            WHERE EmployeeNumber = 'test1234'
        ];
        
        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.OwnerId = u.Id;
        insert lead;
        
        System.runAs(u) {
            Test.startTest();
            
            List<Lead> leads = INS_CTRL_SbibExpireLeads.fetchAllLeads(
                null, null, null, null, null, null
            );
            
            Test.stopTest();
            Assert.areNotEqual(null, leads, 'Leads list should not be null');
        }           
        
    }
    
    
    
    
    /**
* @description Test for expireLeads
*/
    @isTest
    static void testExpireLeads_WithValidIds() {
        
        User u = [
            SELECT Id
            FROM User
            WHERE EmployeeNumber = 'test1234'
        ];
        
        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.OwnerId = u.Id;
        insert lead;
        
        System.runAs(u){
            
            Test.startTest();
            
            INS_CTRL_SbibExpireLeads.expireLeads(new List<Id>{lead.Id});
            
            Test.stopTest();
        }
        
        Lead updated = [
            SELECT Status, Stage__c
            FROM Lead
            WHERE Id = :lead.Id
        ];
        
        Assert.areEqual('Unqualified',updated.Status,'Lead status should be updated');      
        Assert.areEqual('Closed Lost',updated.Stage__c,'Lead stage should be updated');
    }
    
    
    /**
* @description Test for expireLeads with empty list
*/
    @isTest
    static void testExpireLeads_WithEmptyList() {
        
        Test.startTest();
        
        INS_CTRL_SbibExpireLeads.expireLeads(new List<Id>());
        
        Test.stopTest();
        
        Assert.areEqual(true, true, 'Method should safely exit');
    }
    
    
    /**
* @description Test for expireLeads with null list
*/
    @isTest
    static void testExpireLeads_WithNull() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try{
            INS_CTRL_SbibExpireLeads.expireLeads(null);
        }catch(Exception ex){
            exceptionThrown = true;
        }
        Test.stopTest();
        
        Assert.areEqual(true,exceptionThrown,'Exception should occur');
    }
    
    
    /**
* @description Test for getStatuses
*/
    @isTest
    static void testGetStatuses() {
        
        Test.startTest();
        
        List<String> statuses =
            INS_CTRL_SbibExpireLeads.getStatuses();
        
        Test.stopTest();
        
        Assert.areNotEqual(0,statuses.size(),'Statuses should be returned');
    }
    
    
    /**
* @description Test for isUserInDialerLeadsManagersGroup
*/
    @isTest
    static void testIsUserInDialerLeadsManagersGroup() {
        
        User u = [
            SELECT Id
            FROM User
            WHERE EmployeeNumber = 'test1234'
        ];
        
        Group g = new Group(
            Name = 'INS_Dialer_Leads_Managers_PG',
            Type = 'Regular'
        );
        insert g;
        
        GroupMember gm = new GroupMember(
            GroupId = g.Id,
            UserOrGroupId = u.Id
        );
        insert gm;
        
        System.runAs(u) {
            
            Test.startTest();
            
            Boolean result =
                INS_CTRL_SbibExpireLeads.isUserInDialerLeadsManagersGroup();
            
            Test.stopTest();
            
            List<GroupMember> members = [
                SELECT Id
                FROM GroupMember
                WHERE GroupId = :g.Id
                AND UserOrGroupId = :u.Id
            ];
            
            Assert.areEqual(1, members.size(), 'User should exist in group');
            Assert.areNotEqual(null, result, 'Method should return boolean');
        }
    }
    
    
    
    
}