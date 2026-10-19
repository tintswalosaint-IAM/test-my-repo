/**
 * @description       : Test for SEL_CampaignMember
 * @author            : Arsalan Mehfooz
 * @group             : Tests
 * @last modified on  : 07-07-2025
 * @last modified by  : Arsalan Mehfooz
**/
@IsTest
public with sharing class SEL_CampaignMember_Test {
    
        @IsTest
    public static void testGetters() {

        Test.startTest();
            SEL_CampaignMember selector = new SEL_CampaignMember();
            Schema.SObjectType sObjectType = selector.getSObjectType();
            List<Schema.SObjectField> sObjectFieldList = selector.getSObjectFieldList();
        Test.stopTest();
        
        Assert.areEqual(CampaignMember.SObjectType, sObjectType, 'Unexpected SObjectType');
        Assert.areEqual(3, sObjectFieldList.size(), 'Unexpected number of fields');
    }

    /**
* @description Test for SelectCampaignMembersByLeadAndCampaignIds
* @author Raja Arsalan | 15-10-2025 
**/     
    @IsTest
    public static void testSelectCampaignMembersByLeadAndCampaignIds() {
        // Create test Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open - Not Contacted'
        );
        insert testLead;

        Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            IsActive = true
        );
        insert testCampaign;

        CampaignMember cm = new CampaignMember(
            LeadId = testLead.Id,
            CampaignId = testCampaign.Id,
            Status = 'Planned'
        );
        insert cm;

        Test.startTest();
            SEL_CampaignMember selector = new SEL_CampaignMember();
            List<CampaignMember> results = selector.selectCampaignMembersByLeadAndCampaignIds(
                new Set<Id>{testLead.Id},
                new Set<Id>{testCampaign.Id}
            );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Expected one CampaignMember record');
        Assert.areEqual(testLead.Id, results[0].LeadId, 'LeadId mismatch');
        Assert.areEqual(testCampaign.Id, results[0].CampaignId, 'CampaignId mismatch');
    }

    /**
* @description Test for EmptyInputReturnsEmptyList
* @author Raja Arsalan | 15-10-2025 
**/     
    
    @IsTest
    public static void testEmptyInputReturnsEmptyList() {
        Test.startTest();
            SEL_CampaignMember selector = new SEL_CampaignMember();
            List<CampaignMember> results = selector.selectCampaignMembersByLeadAndCampaignIds(
                new Set<Id>(), new Set<Id>()
            );
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Expected no results for empty input');
    }
}