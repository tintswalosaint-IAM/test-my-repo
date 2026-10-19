/**
* @description    :Test Class for ExperienceLeadAPICallout generating access tokens and calling Experience Lead Api
* @author         :Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Oct 2023
*/
@isTest
public class INS_CozaLeadAPICalloutTest {
    /**
* @description    : Test method for data setup
**/
    @testSetup
    public static void setupTestData() {
        
        Leads_ProductQueueAllocation__c productQueue = new Leads_ProductQueueAllocation__c(
        	Lead_Management_System_Code__c = '001',
            Lead_Management_System_Name__c = 'Salesforce Test',
            Lead_Type__c = 'Dailer',
            Leads_Product_Family__c = 'Insurance',
            Leads_Product_Group__c = 'Funeral',
            Leads_Product_House__c = 'Standard Bank Insurance Brokers (SBIB)',
            Leads_Product_Name__c = 'FlexiFuneral',
            Leads_ProductSubFamily__c = 'Life Products',
            Leads_SalesForceOrg__c = 'Universal'
        );
        
        Insert productQueue;
        
        Lead testLead = new Lead(firstname = 'test', lastname = 'lead', email = 'test@test.com', leadsource='740', Company = 'test Lead' , Expressed_Interest_Product__c = productQueue.Id);
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
* @description    : Test method for sending lead data to SAP
**/
    
    @isTest
    static void testSendLeadToSAP() {
        
        list<string> leadIds = new list<string>();
        List<lead> leads = [select id from lead where email = 'test@test.com'];
        for(lead ld : leads)
        {
            leadIds.add(ld.Id);
        }
         Map<String, Integer> expectedStatusCodes = new Map<String, Integer>();

        Test.startTest();
        expectedStatusCodes.put(leadIds[0], 200);
        HttpCalloutMock mock = new MyHttpCalloutMock(200);
        Test.setMock(HttpCalloutMock.class, mock);
        INS_CozaLeadAPICallout.sendLeadToSAP(leadIds);
        
        Test.stopTest();
        Assert.areNotEqual(null,INS_CozaLeadAPICallout.accessToken,'Access token is not null. Callout ran sucessfully.');


    } 
    
    
    


    
    /**
* @description    : Mock Test Class for INS_CozaLeadAPICalloutTest, generating fake responses
* @author         :Raja Arsalan (raja.arsalan@standardbank.co.za)

**/    
    public class MyHttpCalloutMock implements HttpCalloutMock {
        public Integer statusCode;
        MyHttpCalloutMock(Integer statusCode) 
        {
            this.statusCode = statusCode;
        }
           /**
* @description    : fake response
**/
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            if(req.getBody().Contains('grant_type'))
            {
                res.setBody('{"access_token":"TEST_ACCESS_TOKEN"}');
            }
            else if(this.statusCode == 200){
                res.setBody('{"LeadGenerationResponse": {"message": "Lead successfully created on SAP CRM","id": "0000000000"},"httpCode": "200", "httpMessage": "Success","moreInformation":"Created"}');
            }
            else if(req.getBody().Contains('grant_type') == false && this.statusCode == 400){
                 res.setBody('{"httpCode": "400", "httpMessage": "UnAuth","moreInformation":"Not Created"}');
            }
            else{
                res.setBody('{ "error_description": "Unsupported Client Authentication type.", "error": "invalid_request"}');
            }
            return res;
        }
        
   
        
    }



    
    
}