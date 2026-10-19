/** 
 * Created by: Irshad as part of US:SFP-51839
 * Purpose: This class is used to test the KYC_SRV_GET_CustomerCompliance_API class.
 * 
 */
@IsTest
public with sharing class KYC_SRV_CustomerCompliance_API_Test {
	
    class InvalidJsonMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(200);
            res.setBody('');
           
        }
    }
    class SuccessMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(200);
            KYC_SRV_CustomerCompliance_Response response = new KYC_SRV_CustomerCompliance_Response();
            KYC_SRV_CustomerCompliance_Response.cls_assessmentResult assessmentResult = new KYC_SRV_CustomerCompliance_Response.cls_assessmentResult();
            
            
            KYC_SRV_CustomerCompliance_Response.cls_screeningResults sresults = new KYC_SRV_CustomerCompliance_Response.cls_screeningResults();
            List<KYC_SRV_CustomerCompliance_Response.cls_screeningResults> Listsresults = new List<KYC_SRV_CustomerCompliance_Response.cls_screeningResults>();
            sresults.screeningId = '123456';
            sresults.result = 'AcceptableRisk';
            sresults.screeningType = 'CRA High Risk Review';
            sresults.screeningName = 'AssessmentType';
            Listsresults.add(sresults);
            
            assessmentResult.assessmentId ='54321';
            assessmentResult.status ='Completed';
            assessmentResult.result ='AcceptableRisk';
            assessmentResult.screeningResults = Listsresults;
            
            
            response.customerId =     'Test 12345';
            response.assessmentResult = assessmentResult;
                    
            res.setBody(JSON.serialize(response));
        
           
        }
    }
    
    class SuccessWith500Mock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(200);
            string resposeNull = null;
                    
            res.setBody(JSON.serialize(resposeNull));
        
           
        }
    }
    
    class ServerErrorMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(502);
            res.setBody('{"message":"Bad gateway"}');
        }
    }
    
    class badRequestMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest req, HttpResponse res) {
            res.setStatusCode(400);
            String jsonResponse = '{ "error": { "errorDescription": "Invalid customer details provided" } }';
            res.setBody(jsonResponse);
        
           
        }
    }


@IsTest
    static void testGET_KYCStatus() {

        // Create Account
        Account acc = KYC_TestDataFactory.createAccount();

        // create opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quoting',
            Quote_Id__c = '1234567890',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;


        // Create a test PartyProfile record
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');  
        PartyProfile testPartyProfile = [SELECT Id,CMN_DocTypesReqd__c FROM PartyProfile WHERE Id = :profileProfileId LIMIT 1];
        // link opportunity
        testPartyProfile.Opportunity__c = opp.Id;
        update testPartyProfile;


        // Create a test PartyScreeningSummary record
        Id PartyScreeningSummaryId  = KYC_TestDataFactory.createPartyScreening(profileProfileId);  
        PartyScreeningSummary testPartyScreeningSummary = [SELECT Id, PartyProfileId, ScreeningDecision FROM PartyScreeningSummary WHERE Id = :PartyScreeningSummaryId LIMIT 1];    
		
        // Create createPartyPartyIdentityVerification
        Id pivId = KYC_TestDataFactory.createPartyPartyIdentityVerification(profileProfileId,'Initiated','Accepted'); 
        
        // createPartyScreeningStep
        Id pssId = KYC_TestDataFactory.createPartyScreeningStep(PartyScreeningSummaryId,'Initiated');
        PartyScreeningStep pssObj = [Select Id, Name,Type from PartyScreeningStep where Id=:pssId ];
        pssObj.Name ='Customer Risk Assessment';
        pssObj.Type= 'Credit Risk Assessment';
        update pssObj;

        // Create a test Input record
        KYC_SRV_CustomerCompliance_API.Input testInput = new KYC_SRV_CustomerCompliance_API.Input();
        testInput.partyScreeningSummaryId = testPartyScreeningSummary.Id;

        // Create a list of test Input records
        List<KYC_SRV_CustomerCompliance_API.Input> testInputs = new List<KYC_SRV_CustomerCompliance_API.Input>();
        testInputs.add(testInput);

        // Create a mock HTTP response for the web service call
        KYC_SRV_GET_CustomerCompliance_API.injectedMock = new SuccessMock();
       

        // Call the GET_KYCStatus method
        Test.startTest();
        List<KYC_SRV_CustomerCompliance_API.Output> outputs = KYC_SRV_CustomerCompliance_API.GET_KYCStatus(testInputs);
        Test.stopTest();
        

        // Verify the results
        System.assertEquals(1, outputs.size());
        KYC_SRV_CustomerCompliance_API.Output output = outputs[0];
        
        Assert.areEqual('AcceptableRisk', output.screeningDecision);
        Assert.areEqual(false, output.isError);
    }
    
    @IsTest
    static void NegativeGET_KYCStatus() {

        // Create Account
        Account acc = KYC_TestDataFactory.createAccount();

        // create opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quoting',
            Quote_Id__c = '1234567890',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;


        // Create a test PartyProfile record
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');  
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE Id = :profileProfileId LIMIT 1];
        // link opportunity
        testPartyProfile.Opportunity__c = opp.Id;
        update testPartyProfile;


        // Create a test PartyScreeningSummary record
        Id PartyScreeningSummaryId  = KYC_TestDataFactory.createPartyScreening(profileProfileId);  
        PartyScreeningSummary testPartyScreeningSummary = [SELECT Id, PartyProfileId, ScreeningDecision FROM PartyScreeningSummary WHERE Id = :PartyScreeningSummaryId LIMIT 1];    


        // Create a test Input record
        KYC_SRV_CustomerCompliance_API.Input testInput = new KYC_SRV_CustomerCompliance_API.Input();
        testInput.partyScreeningSummaryId = testPartyScreeningSummary.Id;

        // Create a list of test Input records
        List<KYC_SRV_CustomerCompliance_API.Input> testInputs = new List<KYC_SRV_CustomerCompliance_API.Input>();
        testInputs.add(testInput);

        // Create a mock HTTP response for the web service call
        KYC_SRV_GET_CustomerCompliance_API.injectedMock = new badRequestMock();
       

        // Call the GET_KYCStatus method
        Test.startTest();
        List<KYC_SRV_CustomerCompliance_API.Output> outputs = KYC_SRV_CustomerCompliance_API.GET_KYCStatus(testInputs);
        Test.stopTest();
        

        // Verify the results
        System.assertEquals(1, outputs.size());
        KYC_SRV_CustomerCompliance_API.Output output = outputs[0];
        Assert.areEqual(false, output.isError);
    }
    
    // error scenario for no party profile
    @IsTest
    static void NoPP_GET_KYCStatus() {
      // Create Account
        Account acc = KYC_TestDataFactory.createAccount();

        // create opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quoting',
            Quote_Id__c = '1234567890',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;


        // Create a test PartyProfile record
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');  
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE Id = :profileProfileId LIMIT 1];
        // link opportunity
        testPartyProfile.Opportunity__c = opp.Id;
        
        update testPartyProfile;


        // Create a test PartyScreeningSummary record
        Id PartyScreeningSummaryId  = KYC_TestDataFactory.createPartyScreening(profileProfileId);  
        PartyScreeningSummary testPartyScreeningSummary = [SELECT Id, PartyProfileId, ScreeningDecision, status FROM PartyScreeningSummary WHERE Id = :PartyScreeningSummaryId LIMIT 1];    
		testPartyScreeningSummary.status = 'Initiated';
        update testPartyScreeningSummary;

        // Create a test Input record
        KYC_SRV_CustomerCompliance_API.Input testInput = new KYC_SRV_CustomerCompliance_API.Input();
        testInput.partyScreeningSummaryId = testPartyScreeningSummary.Id;

        // Create a list of test Input records
        List<KYC_SRV_CustomerCompliance_API.Input> testInputs = new List<KYC_SRV_CustomerCompliance_API.Input>();
        testInputs.add(testInput);

        // Create a mock HTTP response for the web service call
        KYC_SRV_GET_CustomerCompliance_API.injectedMock = new SuccessWith500Mock();
       

        // Call the GET_KYCStatus method
        Test.startTest();
        List<KYC_SRV_CustomerCompliance_API.Output> outputs = KYC_SRV_CustomerCompliance_API.GET_KYCStatus(testInputs);
        Test.stopTest();


        // Verify the results
        System.assertEquals(1, outputs.size());
        KYC_SRV_CustomerCompliance_API.Output output = outputs[0];
        Assert.areEqual(true, output.isError);  
        
         
        
    }
    
     @IsTest
    static void NoResponse_GET_KYCStatus() {
      // Create Account
        Account acc = KYC_TestDataFactory.createAccount();

        // create opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quoting',
            Quote_Id__c = '1234567890',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;


        // Create a test PartyProfile record
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');  
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE Id = :profileProfileId LIMIT 1];
        // link opportunity
        testPartyProfile.Opportunity__c = opp.Id;
        
        update testPartyProfile;


        // Create a test PartyScreeningSummary record
        Id PartyScreeningSummaryId  = KYC_TestDataFactory.createPartyScreening(profileProfileId);  
        PartyScreeningSummary testPartyScreeningSummary = [SELECT Id, PartyProfileId, ScreeningDecision, status FROM PartyScreeningSummary WHERE Id = :PartyScreeningSummaryId LIMIT 1];    
		

        // Create a test Input record
        KYC_SRV_CustomerCompliance_API.Input testInput = new KYC_SRV_CustomerCompliance_API.Input();
        testInput.partyScreeningSummaryId = testPartyScreeningSummary.Id;

        // Create a list of test Input records
        List<KYC_SRV_CustomerCompliance_API.Input> testInputs = new List<KYC_SRV_CustomerCompliance_API.Input>();
        testInputs.add(testInput);

        // Create a mock HTTP response for the web service call
        KYC_SRV_GET_CustomerCompliance_API.injectedMock = new SuccessWith500Mock();
       

        // Call the GET_KYCStatus method
        Test.startTest();
        List<KYC_SRV_CustomerCompliance_API.Output> outputs = KYC_SRV_CustomerCompliance_API.GET_KYCStatus(testInputs);
        Test.stopTest();


        // Verify the results
        System.assertEquals(1, outputs.size());
        KYC_SRV_CustomerCompliance_API.Output output = outputs[0];
        Assert.areEqual(true, output.isError);  
        
         
        
    }
    
    @IsTest
	static void ServerError_GET_KYCStatus() {
        // Create Account
        Account acc = KYC_TestDataFactory.createAccount();

        // create opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quoting',
            Quote_Id__c = '1234567890',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;


        // Create a test PartyProfile record
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('KE');  
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE Id = :profileProfileId LIMIT 1];
        // link opportunity
        testPartyProfile.Opportunity__c = opp.Id;
        
        update testPartyProfile;


        // Create a test PartyScreeningSummary record
        Id PartyScreeningSummaryId  = KYC_TestDataFactory.createPartyScreening(profileProfileId);  
        PartyScreeningSummary testPartyScreeningSummary = [SELECT Id, PartyProfileId, ScreeningDecision, status FROM PartyScreeningSummary WHERE Id = :PartyScreeningSummaryId LIMIT 1];    
		

        // Create a test Input record
        KYC_SRV_CustomerCompliance_API.Input testInput = new KYC_SRV_CustomerCompliance_API.Input();
        testInput.partyScreeningSummaryId = testPartyScreeningSummary.Id;

        // Create a list of test Input records
        List<KYC_SRV_CustomerCompliance_API.Input> testInputs = new List<KYC_SRV_CustomerCompliance_API.Input>();
        testInputs.add(testInput);
        
        KYC_SRV_GET_CustomerCompliance_API.injectedMock = new ServerErrorMock();
    
        Test.startTest();
        List<KYC_SRV_CustomerCompliance_API.Output> outputs = KYC_SRV_CustomerCompliance_API.GET_KYCStatus(new List<KYC_SRV_CustomerCompliance_API.Input>{ testInput });
        Test.stopTest();
    
        Assert.areEqual(1, outputs.size());
      
       
    }
    
    @IsTest
	static void ParseFailure_GET_KYCStatus() {
        // Create Account
        Account acc = KYC_TestDataFactory.createAccount();
    
        // Create opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Quoting',
            Quote_Id__c = '1234567890',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;
    
        // Create PartyProfile
        Id profileProfileId = KYC_TestDataFactory.createPartyProfile('KE');  
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE Id = :profileProfileId LIMIT 1];
        testPartyProfile.Opportunity__c = opp.Id;
        update testPartyProfile;
    
        // Create PartyScreeningSummary
        Id PartyScreeningSummaryId  = KYC_TestDataFactory.createPartyScreening(profileProfileId);  
        PartyScreeningSummary testPartyScreeningSummary = [
            SELECT Id, PartyProfileId, ScreeningDecision, Status 
            FROM PartyScreeningSummary 
            WHERE Id = :PartyScreeningSummaryId 
            LIMIT 1
        ];
        testPartyScreeningSummary.Status = 'In Progress';
        update testPartyScreeningSummary;
    
        // Prepare input
        KYC_SRV_CustomerCompliance_API.Input testInput = new KYC_SRV_CustomerCompliance_API.Input();
        testInput.partyScreeningSummaryId = testPartyScreeningSummary.Id;
        List<KYC_SRV_CustomerCompliance_API.Input> testInputs = new List<KYC_SRV_CustomerCompliance_API.Input>{ testInput };
    
        // Inject mock that returns invalid JSON
        KYC_SRV_GET_CustomerCompliance_API.injectedMock = new InvalidJsonMock();
    
        Test.startTest();
        List<KYC_SRV_CustomerCompliance_API.Output> outputs = KYC_SRV_CustomerCompliance_API.GET_KYCStatus(testInputs);
        Test.stopTest();
    
        System.assertEquals(1, outputs.size());
        KYC_SRV_CustomerCompliance_API.Output output = outputs[0];
    
        Assert.areEqual(true, output.isError);
        Assert.areEqual('Failed to parse KYC response', output.message);
	}

    
}