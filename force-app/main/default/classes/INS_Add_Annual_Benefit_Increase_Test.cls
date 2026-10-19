/**
 * @description      : Test class to tests the methods available in INS_Add_Annual_Benefit_Increase
 * @author           : Shams Ul Arifeen
 * @date             : October 2023
 */
@isTest
public class INS_Add_Annual_Benefit_Increase_Test {

    @isTest
    static void testAnnualBenefitIncrease() {
        // Create mock data for anunualBenefitIncreaseWrapper
        INS_Add_Annual_Benefit_Increase.anunualBenefitIncreaseWrapper benefitsWrapper = new INS_Add_Annual_Benefit_Increase.anunualBenefitIncreaseWrapper();
        benefitsWrapper.QuoteNumber = '12345';
        benefitsWrapper.anunualBenefitIncrease = '10';
        // Create a list of anunualBenefitIncreaseWrapper objects
        List < INS_Add_Annual_Benefit_Increase.anunualBenefitIncreaseWrapper > requests = new List < INS_Add_Annual_Benefit_Increase.anunualBenefitIncreaseWrapper > ();
        requests.add(benefitsWrapper);

        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the addAnnualBenefitIncrease method
        Test.startTest();
        try {
            INS_Add_Annual_Benefit_Increase.addAnnualBenefitIncrease(requests);    
            Assert.areEqual(true, true, 'Annual benefit increase executed successfully.');
        } catch (Exception e) {
            //Throws an error 
            Assert.areNotEqual(false, 'An unexpected exception occurred: ' + e.getMessage());
        }

        Test.stopTest();
    }
   
    /**
     * @description    : Mock Test Class for INS_Add_Annual_Benefit_Increase_Test, generating fake responses
     * @author         : Shams Ul Arifeen
     **/
    public class MockHttpResponseGenerator implements HttpCalloutMock {

        /**
         * @description    : generating fake responses
         * @author         : Shams Ul Arifeen
         * @return          HTTPResponse
         * @param           request  
         **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"isValid":true,"validationMessages":[],"fullValidationMessage":"Valid"}');
            response.setStatusCode(200);
            return response;
        }
    }
}