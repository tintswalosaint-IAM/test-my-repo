/**
 * @description  test class for INS_Accept_Quote
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date Nov 07th 2023
 */
@isTest
public class INS_Accept_Quote_Test{
    /**
 * @description  test method for acceptQuote
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @date Nov 07th 2023
 */
	@isTest
    static void acceptQuoteTest(){
        InsurancePolicyParticipant applicant1 = new InsurancePolicyParticipant();
        applicant1.FirstName__c = 'John';
        applicant1.LastName__c = 'Doe';
        applicant1.BirthDate__c = Date.newInstance(1980, 1, 1);
        INS_Accept_Quote.Request req = new INS_Accept_Quote.Request();
        req.applicantDetails = applicant1;
        req.quoteNumber = '1234567';
        List<INS_Accept_Quote.Request> reqList = new List<INS_Accept_Quote.Request> ();
        reqList.add(req);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        INS_Accept_Quote.getPicklistValueLabelMap('Opportunity','Stage');
        List<INS_Accept_Quote.Response> result = INS_Accept_Quote.createQuote(reqList);

        //Verify the result
        Assert.areEqual(1, result.size(), 'Quote created successfully.');
        Assert.areEqual(true, result[0].isSuccess, 'Quote created successfully.');
        Test.stopTest(); 
    }
	 /**
 * @description Mock HTTP response generator for the callout
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
    // Mock HTTP response generator for the callout
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        /**
         * @description Mock HTTP response generator for the callout
         * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
         * @param request
         * @return HTTPResponse
         * @date Nov 07th 2023
        */
        public HTTPResponse respond(HTTPRequest request){
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"quoteHeader": {}, "persons": [{"firstName": "KASSIM", "surname": "SSENDEGE", "identityNumber": "01235764578686","benefits": [{"benefitKey": "1.MAINFUNERAL","benefitId": "a4515b-e98-4137-af6-bcfa84c8","benefitType": "MAINFUNERAL", "benefitAmountValue": 1000,"premium": 22.22}]}],"members":[{"memberId":"347284374762833","memberType":"MAININSURED","personId":{"id":"7824374432837","key":"28743623837233b"}}]}');
            response.setStatusCode(200);
            return response;
        }
    }

}