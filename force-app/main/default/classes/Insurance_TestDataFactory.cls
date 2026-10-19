/**
 * @description : Used to create Data for Insurance unit tests
 * @author      : Raja Arsalan
 * @date        : 2024
 */

public class Insurance_TestDataFactory {
    /**
* @description Method takes the recordTypeName as a parameter and generate lead record data
* @return Lead
*/
    public static Lead createLead(String recordTypeName) {
        String recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Lead ld = new Lead();
        ld.FirstName = 'testConnex';
        ld.LastName = 'Lead';
        ld.Email = 'test_connex@gmail.com';
        ld.Status = 'New';
        ld.Company = 'testLead';
        ld.Phone = '0720000000';
        ld.MobilePhone = '0720000000';
        ld.Country = 'South Africa';
        ld.recordTypeId = recordTypeId;
        ld.LeadSource = 'Website';
        ld.Dialler_Queue_ID__c = 'Queue1';
        ld.Campaign_Name__c = 'Test Campaign';
        ld.Campaign_Source_ID__c = '907';
        
        return ld;
    }
    
    public static List<Leads_ProductQueueAllocation__c> createExpressInterest() {
        List<Map<String, String>> variations = new List<Map<String, String>>{
            new Map<String, String>{ 'Name' => 'FlexiFuneral Queue 1', 'CampaignId' => '907' },
                new Map<String, String>{ 'Name' => 'FlexiFuneral Queue 2', 'CampaignId' => '908' }
        };
            
            List<Leads_ProductQueueAllocation__c> queueList = new List<Leads_ProductQueueAllocation__c>();
        
        for (Map<String, String> entry : variations) {
            queueList.add(new Leads_ProductQueueAllocation__c(
                Lead_Management_System_Code__c = '001',
                Lead_Management_System_Name__c = 'Salesforce Test',
                Lead_Type__c = 'SBIB Dialler',
                Leads_Product_Family__c = 'Insurance',
                Leads_Product_Group__c = 'Funeral',
                Leads_Product_House__c = 'Standard Bank Insurance Brokers (SBIB)',
                Leads_Product_Name__c = entry.get('Name'),
                Leads_ProductSubFamily__c = 'Life Products',
                Leads_SalesForceOrg__c = 'Universal',
                Default_Campaign_Source_ID__c = entry.get('CampaignId')
            ));
        }
        
        return queueList;
    }
    
    
    public static List<Campaign> createCampaigns() {
        List<Map<String, String>> variations = new List<Map<String, String>>{
            new Map<String, String>{ 'Name' => 'Car and Home Test 1', 'CampaignId' => '907' },
                new Map<String, String>{ 'Name' => 'Car and Home Test 2', 'CampaignId' => '908' },
                    new Map<String, String>{ 'Name' => 'INS_CRTSY_BUSHR_SMS', 'CampaignId' => '909' },
                        new Map<String, String>{ 'Name' => 'INS_CRTSY_NONBUSHR_SMS', 'CampaignId' => '910' }
        };
            
            List<Campaign> campaigns = new List<Campaign>();
        
        for (Map<String, String> entry : variations) {
            Campaign campaign = new Campaign();
            campaign.Name = entry.get('Name');
            campaign.Campaign_Source_ID__c = entry.get('CampaignId');
            campaign.IsActive = true;
            campaign.Description = 'test';
            campaign.Dialler_System_Code__c = '12345';
            
            campaigns.add(campaign);
        }
        
        return campaigns;
    }
    
    
    public static INS_Insurance_Lead_Settings__mdt createMockLeadSettings() {
        return new INS_Insurance_Lead_Settings__mdt(
            MasterLabel = 'Dialer_Leads',
            INS_LeadType__c = 'SBIB Dialler',
            INS_ProductFamily__c = 'Insurance',
            INS_LeadDate__c = Date.today().addDays(-30)
        );
    }
    
    public static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        return new User(
            Username = 'connexuser_' + System.currentTimeMillis() + '@example.com',
            Email = 'connexuser_' + System.currentTimeMillis() + '@example.com',
            Alias = 'tuser',
            ProfileId = p.Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'User',
            EmployeeNumber = 'test1234',
            CommunityNickname = 'testnick' + System.currentTimeMillis()
        );
    }
    
    public static INS_Insurance_Lead_Settings__mdt createMockPublicHolidaySettings() {
        INS_Insurance_Lead_Settings__mdt mockSetting = new INS_Insurance_Lead_Settings__mdt(
            MasterLabel = 'Public_Holidays',
            INS_HolidayDates__c = '01-01;03-21;04-27;05-01;06-16;08-09;09-24;12-16;12-25;12-26'
        );
        return mockSetting;
    }
    
    
    /**
* @description Dotsure Lead Settings metadata mock
* @return INS_Insurance_Lead_Settings__mdt
**/
    public static INS_Insurance_Lead_Settings__mdt createMockDotsureSettings() {
        return new INS_Insurance_Lead_Settings__mdt(
            MasterLabel = 'DOTSURE',
            DeveloperName = 'DOTSURE',
            INS_Agentkey__c = 213139,
            INS_PreferredProduct__c = 356,
            INS_TargetSystemCode__c = 109
        );
    }
    
    
    
}