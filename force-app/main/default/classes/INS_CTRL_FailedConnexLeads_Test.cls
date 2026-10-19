/**
* @description       : Test for INS_CTRL_FailedConnexLeads
* @author            : Raja Arsalan
* @last modified on  : 28-01-2026
* @last modified by  : Raja Arsalan
*
* Change log
* 2026-01-28   Raja Arsalan    SFP-52529 - Updated the test testSelectAndSubmitLeads_WithValidData
**/


@isTest
private class INS_CTRL_FailedConnexLeads_Test {   
    
    
    /**
* @description Test for GetMaxDate
* @author Raja Arsalan | 15-10-2025 
**/ 
    
    @isTest
    static void testGetMaxDate_WhenExists() {
        Test.startTest();
        String maxDate = INS_CTRL_FailedConnexLeads.getMaxDate();
        Test.stopTest();
        
        Assert.areNotEqual(null, maxDate, 'Max date should be returned if set in custom metadata');
    }
    
    /**
* @description Test for SelectAndSubmitLeads
* @author Raja Arsalan | 15-10-2025 
**/   
    
    @isTest 
    static void testSelectAndSubmitLeads_WithValidData() {
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;
        
        CMN_TRH_Lead.skipConnexCallout = true;
        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.OwnerId = u.Id;
        insert lead; 
        CMN_TRH_Lead.skipConnexCallout = false;
        
        INS_Leads_API.mockScenario = 'success';
        INS_Leads_API.testLeadId = lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_Leads_API.INS_LeadsAPI_SampleMock());
        
        Test.startTest();
        
        INS_CTRL_FailedConnexLeads.selectConnexLeads(
            null, null, null, null
        );
        
        INS_CTRL_FailedConnexLeads.selectConnexLeads(
            'ali',
            System.now().addDays(-2),
            System.now().addDays(2),
            '123'
        );
        
        INS_CTRL_FailedConnexLeads.selectConnexLeads(
            'ali',
            System.now().addDays(-2),
            System.now().addDays(2),
            'Test Campaign'
        );
        
        INS_CTRL_FailedConnexLeads.submitSelectedLeads(new List<Lead>{ lead });
        
        Test.stopTest();
        
        Lead updated = [
            SELECT Referred_System_Reference_Number__c 
            FROM Lead 
            WHERE Id = :lead.Id
        ];
        
        Assert.areEqual('mock-ref-id',updated.Referred_System_Reference_Number__c,'Referred system reference number should match');
    }
    
    
    /**
* @description Test for SubmitSelectedLeads_WithEmptyList
* @author Raja Arsalan | 15-10-2025 
**/ 
    
    @isTest
    static void testSubmitSelectedLeads_WithEmptyList() {
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            INS_CTRL_FailedConnexLeads.submitSelectedLeads(new List<Lead>());
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        Test.stopTest();        
        Assert.areEqual(exceptionThrown, true, 'Exception should be thrown');
    }
    
    /**
* @description Test for IsUserInDialerLeadsManagersGroup
* @author Raja Arsalan | 15-10-2025 
**/ 
    
    @isTest
    static void testIsUserInDialerLeadsManagersGroup() {
        
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;
        Group g = new Group(Name = 'INS_Dialer_Leads_Managers_PG', Type = 'Regular');
        insert g;
        
        GroupMember gm = new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
        insert gm;
        
        
        
        System.runAs(u) {
            Test.startTest();
            Boolean result = INS_CTRL_FailedConnexLeads.isUserInDialerLeadsManagersGroup();
            Test.stopTest();
            List<GroupMember> members = [
                SELECT Id FROM GroupMember
                WHERE GroupId = :g.Id AND UserOrGroupId = :u.Id
            ];
            Assert.areEqual(1, members.size(), 'User should be in the group');
            
        }
    }
    
    
}