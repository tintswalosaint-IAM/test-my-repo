/**
* @description       : Test for SEL_Campaign
* @author            : Derek Hughes
* @group             : Tests
* @last modified on  : 07-07-2025
* @last modified by  : Raja Arsalan
**/
@IsTest
public with sharing class SEL_Campaign_Test {
    @IsTest
    public static void testGetters() {
        
        Test.startTest();
        SEL_Campaign selector = new SEL_Campaign();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        List<Schema.SObjectField> sObjectFieldList = selector.getSObjectFieldList();
        Test.stopTest();
        
        Assert.areEqual(Campaign.SObjectType, sObjectType, 'Unexpected SObjectType');
        Assert.areEqual(2, sObjectFieldList.size(), 'Unexpected number of fields');
    }
    
    
    @IsTest
    public static void testSelectWithMembersByCampaignCodes() {
        
        final Campaign testCampaign = new Campaign(
            Name = 'Test Campaign',
            Campaign_Code__c = 'ABC123'
        );
        
        insert testCampaign;
        
        Test.startTest();
        SEL_Campaign selector = new SEL_Campaign();
        final List<Campaign> campaigns = selector.selectWithMembersByCampaignCodes(
            new Set<String>{'ABC123'}, new Set<Id>());
        Test.stopTest();
        
        Assert.areEqual(1, campaigns.size(), 'Unexpected number of campaigns');
    }
    
    @IsTest
    public static void testSelectByCampaignSourceIds() {
        Campaign c1 = new Campaign(
            Name = 'Campaign A',
            Campaign_Source_ID__c = 'SRC001',
            Dialler_System_Code__c = 'DIAL001',
            IsActive = true
        );      
        insert new List<Campaign>{ c1};
            
            Test.startTest();
        SEL_Campaign selector = new SEL_Campaign();
        List<Campaign> results = selector.selectByCampaignSourceIds(new Set<String>{'SRC001'});
        Test.stopTest();
        
        Assert.areEqual(1, results.size(), 'Expected a campaigns to be returned');
    }

    /**
* @description Test for SelectCampaignsByName
* @author Raja Arsalan | 15-10-2025 
**/     
    
    @IsTest
    public static void testSelectCampaignsByName() {
        
        Campaign c1 = new Campaign(Name = 'INS_CRTSY_BUSHR_SMS', IsActive = true);
        Campaign c2 = new Campaign(Name = 'INS_CRTSY_NONBUSHR_SMS', IsActive = true);
        Campaign c3 = new Campaign(Name = 'OTHER_CAMPAIGN', IsActive = true);
        insert new List<Campaign>{ c1, c2, c3 };
            List<String> campaignNames = new List<String>{'INS_CRTSY_BUSHR_SMS', 'INS_CRTSY_NONBUSHR_SMS'};
                Test.startTest();
        List<Campaign> result = new SEL_Campaign().selectCampaignsByName(campaignNames);
        Test.stopTest();
        Assert.areEqual(2, result.size(), 'Expected 2 courtesy campaigns to be returned');
    }
    
}