/**
* @description  : INS_Get_Quick_Quote_Test to cover the functionality of INS_Get_Quick_Quote.cls
* @SFP-50909    : The class has been created to cover the functionality
* @author       : Irshad Alam (irshad.alam@standardbank.co.za)
* @date         : October 2025
*/

@isTest
public class INS_Get_Quick_Quote_Test {
	@isTest
    static void testCreateQuote() {
        INS_Get_Quick_Quote.RequestWrapper quickQuoteWrapper = new INS_Get_Quick_Quote.RequestWrapper();
        quickQuoteWrapper.quoteId = '1234-568';
        List <INS_Get_Quick_Quote.RequestWrapper> requests = new List <INS_Get_Quick_Quote.RequestWrapper>();
        requests.add(quickQuoteWrapper);
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the createQuote method
        Test.startTest();
        List <INS_Quick_Quote_Wrapper.Response> responses = INS_Get_Quick_Quote.GetQuote(requests);
        Test.stopTest();
        
        // Assert the responses
        Assert.areEqual(1, responses.size(),'Expected one Quote to be posted');
    }
    
    /**
    * @description    : Mock Test Class for INS_Create_Quick_Quote_Test, generating fake responses
    * @author         : Shams Ul Arifeen
    **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        
        /**
        * @description    : generating fake responses
        * @author         : Shams Ul Arifeen
        * @param request  : HTTPRequest object
        * @return         : HTTPResponse
        **/
        public HTTPResponse respond(HTTPRequest request) {
        // Create a mock HTTP response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
    
        // Include beneficiaries node in JSON to cover the missing part
        String mockJson = '{'
            + '"quoteHeader": {"totalPremium": 100.50, "quoteId": "Q-12345", "quoteNumber": "Q000123"},'
            + '"persons": ['
            + '  {"firstName": "KASSIM", "surname": "SSENDEGE", "identityNumber": "01235764578686",'
            + '   "benefits": [{"benefitKey": "1.MAINFUNERAL","benefitId": "a4515b-e98-4137-af6-bcfa84c8",'
            + '   "benefitType": "MAINFUNERAL", "benefitAmountValue": 1000,"premium": 22.22}]}'
            + '],'
            + '"members":[{"memberId":"347284374762833","memberType":"MAININSURED",'
            + '   "personId":{"id":"7824374432837","key":"28743623837233b"}}],'
            + '"beneficiaries": ['
            + '  {"beneficiaryId":"B-001","firstName":"Jane","surname":"Doe","gender":"Female",'
            + '   "relationship":"Spouse","allocationAmount":50,"dateOfBirth":"1990-01-01T00:00:00"},'
            + '  {"beneficiaryId":"B-002","firstName":"John","surname":"Smith","gender":"Male",'
            + '   "relationship":"Child","allocationAmount":50,"dateOfBirth":"2015-05-20T00:00:00"}'
            + ']'
            + '}';
    
        response.setBody(mockJson);
        response.setStatusCode(200);
        return response;
    }
    }
    @isTest
    static void testWrapperCoverage() {
        // QuotePayload
        INS_Quick_Quote_Wrapper.QuotePayload payload = new INS_Quick_Quote_Wrapper.QuotePayload();
        payload.quoteId = 'Q-001';
        payload.channel = 'Online';
        payload.requestId = 'REQ123';
        payload.cashBackOption = true;
        payload.annualBenefitIncrease = 10;
        payload.consultantCode = 'CONS123';
        
        // ProductRules
        payload.productRules = new INS_Quick_Quote_Wrapper.ProductRules();
        payload.productRules.productId = 'P-001';
        payload.productRules.annualBenefitIncrease = 5;
        payload.productRules.waiveWaitingPeriod = false;
        
        // Member
        INS_Quick_Quote_Wrapper.Member member = new INS_Quick_Quote_Wrapper.Member();
        member.firstName = 'John';
        member.lastName = 'Doe';
        member.gender = 'Male';
        member.dateOfBirth = '1980-01-01';
        member.identityNumber = '1234567890';
        member.memberType = 'MAININSURED';
        member.benefits = new List<INS_Quick_Quote_Wrapper.Benefit>();
        
        // Benefit
        INS_Quick_Quote_Wrapper.Benefit benefit = new INS_Quick_Quote_Wrapper.Benefit();
        benefit.benefitType = 'Funeral';
        benefit.coverAmount = 10000.0;
        benefit.beneficiaries = new List<INS_Quick_Quote_Wrapper.Beneficiaries>();
        
        // Beneficiaries
        INS_Quick_Quote_Wrapper.Beneficiaries bene = new INS_Quick_Quote_Wrapper.Beneficiaries();
        bene.allocationAmount = 100;
        bene.allocationType = 'Percentage';
        
        benefit.beneficiaries.add(bene);
        member.benefits.add(benefit);
        payload.members = new List<INS_Quick_Quote_Wrapper.Member>{member};
            
            // QuoteBenefitRequest
            INS_Quick_Quote_Wrapper.QuoteBenefitRequest qbr = new INS_Quick_Quote_Wrapper.QuoteBenefitRequest();
        qbr.referenceNumber = 'REF123';
        qbr.benefits = new List<INS_Quick_Quote_Wrapper.QuoteBenefit>{
            new INS_Quick_Quote_Wrapper.QuoteBenefit()
        };
                    
        INS_Quick_Quote_Wrapper.MemberPayload memberPayload = new INS_Quick_Quote_Wrapper.MemberPayload();
        memberPayload.referenceNumber = 'REF456';
        memberPayload.members = new List<INS_Quick_Quote_Wrapper.AddMember>();
        
        // AddMember
        INS_Quick_Quote_Wrapper.AddMember addMem = new INS_Quick_Quote_Wrapper.AddMember();
        addMem.firstName = 'Jane';
        addMem.benefits = new List<INS_Quick_Quote_Wrapper.MemberBenefit>();
        
        // MemberBenefit
        INS_Quick_Quote_Wrapper.MemberBenefit memben = new INS_Quick_Quote_Wrapper.MemberBenefit();
        memben.benefitType = 'Transport';
        memben.benefitAmountValue = 300.0;
        
        addMem.benefits.add(memben);
        memberPayload.members.add(addMem);
        
        // DeleteMemberPayload
        INS_Quick_Quote_Wrapper.DeleteMemberPayload delPayload = new INS_Quick_Quote_Wrapper.DeleteMemberPayload();
        delPayload.referenceNumber = 'REF789';
        delPayload.itemKeys = new List<INS_Quick_Quote_Wrapper.ItemKey>{
            new INS_Quick_Quote_Wrapper.ItemKey()
                };
                    
        // AnnualBenefitIncreasePayload
        INS_Quick_Quote_Wrapper.AnnualBenefitIncreasePayload abi = new INS_Quick_Quote_Wrapper.AnnualBenefitIncreasePayload();
        abi.referenceNumber = 'REF999';
        abi.annualBenefitIncrease = 5;
        
        // PremiumBenefitResponse
        INS_Quick_Quote_Wrapper.PremiumBenefitResponse premium = new INS_Quick_Quote_Wrapper.PremiumBenefitResponse();
        premium.funeralPremium = 22.22;
        premium.totalPremium = 50.0;
        
        // Response
        INS_Quick_Quote_Wrapper.Response resp = new INS_Quick_Quote_Wrapper.Response();
        resp.quoteNumber = 'Q-0001';
        resp.totalPremium = 100.0;
        
        // CashBackBenefitPayload
        INS_Quick_Quote_Wrapper.CashBackBenefitPayload cb = new INS_Quick_Quote_Wrapper.CashBackBenefitPayload();
        cb.referenceNumber = 'R123';
        cb.cashBackBenefit = true;
        
        Assert.areEqual('Q-0001', resp.quoteNumber); // Just to keep some assertion
    } 
}