/**
* @Name of the Class : ICS_CTRL_Fetch_TaxDetails_Test
* @description: Contoller used as test class  for ICS_CTRL_Fetch_TaxDetails.cls
* @author: IKYATHA NAIDU
* @date: 24/07/2024
* @last modified on  : 24/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest verion
*
*/
@isTest
private class ICS_CTRL_Fetch_TaxDetails_Test {
      @isTest
    static void testFetchTaxDetails() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
        pData.Country_of_Residence__c = 'UA'; 
        update pData;
    
        TaxDetails__c usTax = new TaxDetails__c(
            Account__c = commUser.Contact.AccountId,
            Country__c = 'US',
            TIN_IN_Number__c = 'US123456789',
            TaxExemptReason__c = 'Not Required'
        );
        insert usTax;
        TaxDetails__c mainTax = new TaxDetails__c(
            Account__c = commUser.Contact.AccountId,
            Country__c = 'UA',
            TIN_IN_Number__c = 'UA987654321',
            TaxExemptReason__c = 'Main Exempt',
            Reason_for_No_TIN__c = 'Main Reason'
        );
        insert mainTax;
        
        Test.startTest();
        String result = ICS_CTRL_Fetch_TaxDetails.fetchTaxDetails(commUser.Contact.accountId);
        Test.stopTest();
        
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result.substring(1, result.length()-1));
        Assert.areEqual('US123456789', resultMap.get('US specific Tax Identification Number (TIN)'));
        Assert.areEqual('UA987654321', resultMap.get('TIN'));
        Assert.areEqual('Main Exempt', resultMap.get('Please select reason for not having a TIN number'));
        Assert.areEqual('Main Reason', resultMap.get('Please explain the reason for not obtaining TIN or equivalent numberG'));
    }
    
    @isTest
    static void testGetApplicationFormStageName() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = commUser.Contact.AccountId,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30)
        );
        insert opp;
        
        ApplicationForm testApp = new ApplicationForm(
            AccountId = commUser.Contact.AccountId,
            OpportunityId = opp.Id,
            Section_Name__c = 'ICS UK Personal Info;Other Section',
            UsageType = 'Onboarding'
        );
        insert testApp;
        
        System.runAs(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_Fetch_TaxDetails.getApplicationFormStageName();
            Test.stopTest();
            Assert.areEqual('ICS UK Personal Info', result[0]);
        }
    }
    
    @isTest
    static void testFetchCountryTaxDetails() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        List<String> countries = new List<String>{'US', 'GB'};
            
        TaxDetails__c tax1 = new TaxDetails__c(
            Account__c = commUser.Contact.AccountId,
            Country__c = 'US'
        );
        insert tax1;

        Test.startTest();
        Map<String, List<Map<String, Object>>> result = ICS_CTRL_Fetch_TaxDetails.fetchCountryTaxDetails(commUser.Contact.AccountId, countries);
        Test.stopTest();
        
        Assert.isTrue(result.containsKey('US'), 'Should contain US tax details');
    }
}