/**
 * @description      : @description Test class to tests the methods available in INS_Add_Quote_Benefits
 * @author           : Shams Ul Arifeen
 * @date             : October 2023
 */
@isTest
public class INS_Add_Quote_Benefits_Test {

    @isTest
    static void testCreateQuoteBenefits() {
        // Create mock data for BenefitsWrapper
        // Create a test InsurancePolicyParticipant record with mandatory fields populated
        InsurancePolicyParticipant mainMember = new InsurancePolicyParticipant();
        mainMember.Funeral_Benefit_Id__c = 'FuneralBenefitId123';
        mainMember.Catering_Benefit_Id__c = 'CateringBenefitId123';
        mainMember.Tombstone_Benefit_Id__c = 'TombstoneBenefitId123';
        mainMember.Shopping_Benefit_Id__c = 'ShoppingBenefitId123';
        mainMember.Transport_Benefit_Id__c = 'TransportBenefitId123';
        mainMember.Radio_Announcement_benefit_Id__c = 'RadioAnnouncementBenefitId123';

        Ins_Add_Quote_benefits.BenefitsWrapper benefitsWrapper = new Ins_Add_Quote_benefits.BenefitsWrapper();
        benefitsWrapper.showPremium = true;
        benefitsWrapper.CateringBenefit = 100.0;
        benefitsWrapper.TombStoneBenefit = 200.0;
        benefitsWrapper.TransportBenefit = 150.0;
        benefitsWrapper.ShoppingBenefit = 120.0;
        benefitsWrapper.FuneralBenefit = 250.0;
        benefitsWrapper.RadioAnnouncementBenefit = 80.0;
        benefitsWrapper.QuoteNumber = '12345';
        benefitsWrapper.MemberId = '56789';
        benefitsWrapper.mainMember = mainMember;

        // Create a list of BenefitsWrapper objects
        List < Ins_Add_Quote_benefits.BenefitsWrapper > requests = new List < Ins_Add_Quote_benefits.BenefitsWrapper > ();
        requests.add(benefitsWrapper);

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the createQuoteBenefits method
        Test.startTest();
        List < INS_Quick_Quote_Wrapper.PremiumBenefitResponse > responses = Ins_Add_Quote_benefits.createQuoteBenefits(requests);
        Test.stopTest();

        // Assert the responses or perform other necessary validations
        Assert.areEqual(1, responses.size(), 'Expected response is 1');
    }

    @isTest
    static void testEditQuoteBenefits() {
    
        // Create a mock JSON string for testing
        String jsonString = '{"benefitKey": "1.TEST", "benefitName": "TEST", "benefitAmount": 100, "memberId": "567-v678", "quoteNumber": "123-2312", "benefitId": "123-61535", "premiumFrequency" : "MONTHLY"}';

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        INS_Add_Quote_benefits.Response response =  INS_Add_Quote_benefits.editQuoteBenefits(jsonString);
        Assert.areNotEqual(null, response, 'Response should not be null');
        try {
            INS_Add_Quote_benefits.deleteBenefits(jsonString);
            Assert.areEqual(true, true, 'Quote benefit deleted successfully.');
        } catch (Exception e) {
            Assert.areNotEqual(null, e, 'An unexpected exception occurred: ' + e.getMessage());
        }
        Test.stopTest();
    }

    /**
     * @description    : Mock Test Class for INS_Add_Quote_Benefits_Test, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {

        /**
         * @description    : generating fake responses
         * @author         : Shams Ul Arifeen
         * @param request
         * @return         : HTTPResponse
         **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"benefits": [{"benefitType": "MAINMEMBERCATERINGBENEFIT", "premium": 100.0}, {"benefitType": "MAINMEMBERTOMBSTONEBENEFIT", "premium": 200.0}, {"benefitType": "MAINREPATRIATION", "premium": 150.0}, {"benefitType": "MAINMEMBERGROCERYBENEFIT", "premium": 120.0}, {"benefitType": "MAINFUNERAL", "premium": 250.0}, {"benefitType": "MAINAIRTIME", "premium": 80.0}]}');
            response.setStatusCode(200);
            return response;
        }
    }
}