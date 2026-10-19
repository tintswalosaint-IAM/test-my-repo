/**
 * @description       : Test class for INS_SEL_CampaignMember
 * @author            : Raja Arsalan
**/
@isTest
    private class INS_SEL_CampaignMember_Test {
        @isTest
/**
 * @description       : Test method for INS_SEL_CampaignMember
 * @author            : Raja Arsalan
**/
        static void testSelectCampaignMemberById() {
            // Create test data
            Lead testLead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Lead');
            insert testLead;
            
            Campaign testCampaign = new Campaign(Name = 'Test Campaign', IsActive = true);
            insert testCampaign;
            
            CampaignMember testCampaignMember = new CampaignMember(CampaignId = testCampaign.Id, LeadId = testLead.Id);
            insert testCampaignMember;
            
            // Test the selectCampaignMemberById method
            INS_SEL_CampaignMember campaignMemberSelector = new INS_SEL_CampaignMember();
            List<CampaignMember> campaignMembers = campaignMemberSelector.selectCampaignMemberById(testLead.Id);
            List<Schema.SObjectField> fieldList = campaignMemberSelector.getSObjectFieldList();
            // Assert the results
            
            Assert.areEqual(testCampaignMember.LeadId, campaignMembers[0].LeadId,'Expected to have same Ids');
        }
    }