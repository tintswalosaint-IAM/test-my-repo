/**
* @description    :Test Class for INS_CozaLeadAPIErrorHandler, Sends emails and custom notification 
* @author         :Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Oct 2023
**/

@isTest
public class INS_CozaLeadAPIErrorHandlerTest {
    
    /**
* @description    : Test method for data setup
*/
    @testSetup
    static void setupTestData() {
        Lead testLead = new Lead(firstname = 'test', lastname = 'lead', email = 'test@test.com', leadsource='740', Company = 'test Lead');
        insert testLead;
        
        Campaign testCampaign = new Campaign(name = 'test', Campaign_Source_ID__c = '740');
        insert testCampaign;
        
        
        CampaignMember testCampaignMember = new CampaignMember(
            CampaignId = testCampaign.Id,
            LeadId = testLead.Id
        );
        insert testCampaignMember;
    }
    /**
* @description    : Test method for sending email and notification to tech team
*/
    @isTest
    static void testSendErrorEmailToTechTeam() {
        list<string> leadIds = new list<string>();
        List<lead> leads = [select id from lead where email = 'test@test.com'];
        for(lead ld : leads)
        {
            leadIds.add(ld.Id);
        }
        Test.startTest();
        INS_CozaLeadAPIErrorHandler.sendNotificationToTechTeam(leadIds); 
        INS_CozaLeadAPIErrorHandler.sendErrorEmailToTechTeam(leadIds);
        Integer invocations = Limits.getEmailInvocations();	
        Test.stopTest();
        Assert.areEqual(1, invocations, 'An email has been sent');

    }

}