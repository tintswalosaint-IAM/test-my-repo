/**
 * @description SFP-32986 Class used as test class for ICS_API_SAPCreateCYT
 * @author Rukesh
 * @date 21/10/2024
 *****************************************************
 * @last modified on  : 21/10/2024
 * @last modified by  : Rukesh
 * @last modified description: updated to align with the latest version of ICS_API_SAPCreateCYT
 * ***************************************************************
 * Last Modified By  Ridhima Saxena
 * Last Modified Date 01/11/2025
 * Last Modified Description: SFP-52878 updated missing CYT fields in JSON
 */
@IsTest
 private class ICS_API_SAPCreateCYT_TEST {

    @TestSetup
    static void createTestData(){
  		Account testAccount=ICS_DAL_TestFactory.createAccount();

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert testOpportunity;

        TaxDetails__c testTaxDetails = new TaxDetails__c(
            Account__c = testAccount.Id,
            TIN_IN_Number__c = '123456789',
            Country__c = 'US'
        );
        insert testTaxDetails;
		 FinServ__FinancialAccount__c accountInfo =new FinServ__FinancialAccount__c();
        accountInfo.FinServ__PrimaryOwner__c = testAccount.Id;
        accountInfo.ExternalCIFId__c = '12345';
        insert accountInfo;
         PartyProfile testProfile = new PartyProfile(
             Name='Test PartyProfile',
            AccountId = testAccount.Id,
            PrimaryIdentifierType = 'Passport Number',
            PrimaryIdentifier = 'PASS123456'
        );
        insert testProfile;
          PartyProfile testProfiletwo = new PartyProfile(
             Name='Test PartyProfile Two',
            AccountId = testAccount.Id,
            PrimaryIdentifierType = 'Identification Number',
            PrimaryIdentifier = 'ID53123456'
        );
        insert testProfiletwo;
    }

    @IsTest
    static void testGenerateJsonRequest() {
        Opportunity testOpp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Test.startTest();
                String jsonResult ;
        try{
        ICS_API_SAPCreateCYT cytInstance = new ICS_API_SAPCreateCYT(testOpp.AccountId,false);
        jsonResult = cytInstance.jsonRequest;
        }catch(exception e){
             Assert.areEqual(true,e.getmessage() !=null,' error message cannot be null');

        }
        Test.stopTest();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        Assert.areEqual(true,resultMap.containsKey('Party'), 'Expected "Party" key in JSON response');
       
		  List<Object> parties = (List<Object>)resultMap.get('Party');
        Map<String, Object> party = (Map<String, Object>)parties[0];
        Assert.areEqual(true,party.containsKey('PartyReference'), 'Expected "PartyReference" key in JSON response');
        Assert.areEqual(true,party.containsKey('Reference'), 'Expected "Reference" key in JSON response');

       
       
    }
       @IsTest
    static void testGenerateJsonRequestJoint() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        PartyProfile testProfile = [SELECT Id FROM PartyProfile WHERE AccountId = :testAccount.Id LIMIT 1];
        ApplicationForm jointAppForm = ICS_DAL_TestFactory.createApplicationForm(testAccount.Id, testOpp.Id);
        ICS_DAL_TestFactory.createApplicant(testAccount.Id, testProfile.Id, jointAppForm.Id);

        Test.startTest();
        String jsonResult;
        try {
            ICS_API_SAPCreateCYT cytInstance = new ICS_API_SAPCreateCYT(testAccount.Id, true);
            jsonResult = cytInstance.jsonRequest;
        } catch (Exception e) {
            Assert.areEqual(true, e.getMessage() != null, 'Error message cannot be null');
        }
        Test.stopTest();

        Assert.isNotNull(jsonResult, 'JSON result should not be null for joint application');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResult);
        Assert.areEqual(true, resultMap.containsKey('Party'), 'Expected "Party" key in JSON response');

        List<Object> parties = (List<Object>) resultMap.get('Party');
        Map<String, Object> party = (Map<String, Object>) parties[0];
        Assert.areEqual(true, party.containsKey('PartyReference'), 'Expected "PartyReference" key for joint application');
        Assert.areEqual(true, party.containsKey('Reference'), 'Expected "Reference" key for joint application');

        Map<String, Object> reference = (Map<String, Object>) party.get('Reference');
        Map<String, Object> partyContactPoint = (Map<String, Object>) reference.get('PartyContactPoint');
        Map<String, Object> contactPoint = (Map<String, Object>) partyContactPoint.get('ContactPoint');
        Assert.isNotNull(contactPoint.get('ContactPointType'), 'ContactPointType should be set for joint application');
    }
       @IsTest
    static void testIsEUCountry() {
        
        Test.startTest();
        
        Boolean isEU_DE = ICS_API_SAPCreateCYT.isEUCountry('DE');
        Boolean isEU_FR = ICS_API_SAPCreateCYT.isEUCountry('FR');
        
        // Test with non-EU country
        Boolean isEU_US = ICS_API_SAPCreateCYT.isEUCountry('US');
        Boolean isEU_IN = ICS_API_SAPCreateCYT.isEUCountry('IN');
        
        // Test with blank/null
        Boolean isEU_Blank = ICS_API_SAPCreateCYT.isEUCountry('');
        Boolean isEU_Null = ICS_API_SAPCreateCYT.isEUCountry(null);
        Boolean isEU_Lowercase = ICS_API_SAPCreateCYT.isEUCountry('de');
        
        Test.stopTest();
        
        Assert.areEqual(true, isEU_DE, 'DE should be an EU country');
        Assert.areEqual(true, isEU_FR, 'FR should be an EU country');
        Assert.areEqual(false, isEU_US, 'US should not be an EU country');
        Assert.areEqual(false, isEU_IN, 'IN should not be an EU country');
        Assert.areEqual(false, isEU_Blank, 'Blank should return false');
        Assert.areEqual(false, isEU_Null, 'Null should return false');
        Assert.areEqual(true, isEU_Lowercase, 'Should handle lowercase country codes');
    }
    
    @IsTest
    static void testGenerateJsonRequestWithEUCountry() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        // Create TaxDetails with EU country
        TaxDetails__c euTaxDetails = new TaxDetails__c(
            Account__c = testAccount.Id,
            TIN_IN_Number__c = '987654321',
            Country__c = 'DE' // Germany - EU country
        );
        insert euTaxDetails;
        
        Test.startTest();
        String jsonResult;
        try{
            ICS_API_SAPCreateCYT cytInstance = new ICS_API_SAPCreateCYT(testAccount.Id, false);
            jsonResult = cytInstance.jsonRequest;
        }catch(exception e){
            Assert.areEqual(true, e.getmessage() != null, 'Error message cannot be null');
        }
        Test.stopTest();
        
        // Add assertions based on expected behavior with EU countries
        Assert.isNotNull(jsonResult, 'JSON result should not be null');
    }
}