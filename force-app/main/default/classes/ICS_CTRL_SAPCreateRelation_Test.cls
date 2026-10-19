/*************************************************************
 * @description SFP-32986 CTRL Class used to test ICS_CTRL_SAPCreateRelation
 *
 * @autor Ridhima
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By Ridhima
 * Last Modified Date 21/10/2024
 * Last Modified Description: Modified to support dynamic status codes
 */
@IsTest 
public class ICS_CTRL_SAPCreateRelation_Test {
    @TestSetup
    static void setupData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(acc.id);
        ApplicationForm appForm = ICS_DAL_TestFactory.createApplicationForm(acc.id,testOpportunity.id);
        partyProfile profileData = ICS_DAL_TestFactory.createPartyProfile(acc.id);
        ICS_DAL_TestFactory.createApplicant(acc.id, profileData.id, appForm.id);
    }

    @IsTest
    public static void testICS_CTRL_SAPCreateRelation_Success() {
        List<Opportunity> lstOpportunity = [SELECT Id,AccountId FROM Opportunity where name='tesstopp'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, '{"status": "Success"}'));
        
        Test.startTest();
        ICS_CTRL_SAPCreateRelation sapCreateRelation = new ICS_CTRL_SAPCreateRelation(lstOpportunity[0].AccountId,false,'Single');
        System.enqueueJob(sapCreateRelation);
        Test.stopTest();
        
        List<AsyncApexJob> jobs = [SELECT Id, JobType FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        assert.istrue(!jobs.isEmpty(), 'A queueable job for ICS_CTRL_SAPCreateAccount should be enqueued.');
    }

    @IsTest
    public static void testICS_CTRL_SAPCreateRelation_Exception() {
        List<Opportunity> lstOpportunity = [SELECT Id,AccountId FROM Opportunity];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500, '{"status": "Error"}'));
        
        Test.startTest();
        ICS_CTRL_SAPCreateRelation sapCreateRelation = new ICS_CTRL_SAPCreateRelation(lstOpportunity[0].AccountId,true,'Joint');
        System.enqueueJob(sapCreateRelation);
        Test.stopTest();
        
        List<CMN_WebserviceCallQueue__c> webserviceQueues = [SELECT Id, Name, CMN_Response__c, CMN_Request__c
                                                            FROM CMN_WebserviceCallQueue__c];
        assert.istrue(webserviceQueues.isEmpty(), 'A Webservice call queue should be created in case of failure.');
    }

    // Combined mock response class with dynamic status code and body
    private class MockHttpResponse implements HttpCalloutMock {
        Public Integer statusCode;
        Public String responseBody;
        
        public MockHttpResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            return res;
        }
    }
}