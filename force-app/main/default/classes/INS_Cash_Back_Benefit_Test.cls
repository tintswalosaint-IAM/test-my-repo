/**
 * @description      : Test class to tests the methods available in INS_Cash_Back_Benefit
 * @author           : Shams Arifeen
 * @date             : April 2025
 */
@isTest
public class INS_Cash_Back_Benefit_Test {

    @isTest
    static void testAddCashBackBenefitIncrease() {
        // Create mock data for CashBackBenefitWrapper
        INS_Cash_Back_Benefit.CashBackBenefitWrapper benefitsWrapper = new INS_Cash_Back_Benefit.CashBackBenefitWrapper();
        benefitsWrapper.referenceNumber = 'Test-86bb-4ccb-8137-04280d48';
        benefitsWrapper.cashBackBenefit = true;
        // Create a list of CashBackBenefitWrapper objects
        List < INS_Cash_Back_Benefit.CashBackBenefitWrapper > requests = new List < INS_Cash_Back_Benefit.CashBackBenefitWrapper > ();
        requests.add(benefitsWrapper);

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the addCashBackBenefit method
        Test.startTest();
        List<Decimal> cashBackBenefits = INS_Cash_Back_Benefit.addCashBackBenefit(requests); 
        Assert.areNotEqual(0, cashBackBenefits.size(), 'CashBackBenefits list should not be empty');
        Assert.areEqual(17.78, cashBackBenefits[0], 'Expected cashback benefit value should be 17.78');
        Test.stopTest();
    }

    @isTest
    static void testAddCashBackBenefitFailure() {
        // Create mock data
        INS_Cash_Back_Benefit.CashBackBenefitWrapper benefitsWrapper = new INS_Cash_Back_Benefit.CashBackBenefitWrapper();
        benefitsWrapper.referenceNumber = 'Test-Failure-86bb-4ccb-8137-0428';
        benefitsWrapper.cashBackBenefit = true;
        
        List<INS_Cash_Back_Benefit.CashBackBenefitWrapper> requests = new List<INS_Cash_Back_Benefit.CashBackBenefitWrapper>();
        requests.add(benefitsWrapper);

        // Mock a validation failure response
        Test.setMock(HttpCalloutMock.class, new MockInvalidHttpResponseGenerator());

        Test.startTest();
        try {
            INS_Cash_Back_Benefit.addCashBackBenefit(requests);
        } catch (Exception ex) {
            Assert.areEqual('Error: {Internal Server Error!}', ex.getMessage(), 'Expected Internal Server Error');
        }
        Test.stopTest();
    }

   
    /**
     * @description    : Mock Test Class for INS_Cash_Back_Benefit_Test, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {

        /**
         * @description    : generating fake responses
         * @author         : Shams Arifeen
         * @return          HTTPResponse
         * @param           request  
         **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"quoteHeader":{"quoteId":"Test-86bb-4ccb-8137-04280d48","channel":"Salesforce","annualBenefitIncrease":0,"waiveWaitingPeriod":false,"requestId":"","quoteNumber":"2d633620-86bb-4ccb-8137-04280d484075","productId":"34ce5098-b41b-4673-a56a-d19f2c0b0aeb","cashBackOption":true,"cashBackPremium":17.78},"validationResult":{"isValid":true,"validationMessages":[],"fullValidationMessage":null}}');
            response.setStatusCode(200);
            return response;
        }
    }

    /**
     * @description    : Mock Test Class for INS_Cash_Back_Benefit_Test, generating invalid responses 
     * @author         : Shams Ul Arifeen
     **/
    public class MockInvalidHttpResponseGenerator implements HttpCalloutMock {

        /**
         * @description    : generating fake responses
         * @author         : Shams Arifeen
         * @return          HTTPResponse
         * @param           request  
         **/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{Internal Server Error!}');
            response.setStatusCode(500);
            return response;
        }
    }
}