/***************************************************************************************
@Name of the Class :ICS_SRV_WebserviceQueue
@Description : Class used to store webservice call
@Author :Dayakar
@Created Date :oct 22 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class ICS_SRV_WebserviceQueue_Test {
  @TestSetup
    static void setupData() {
        Account acc=ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity =ICS_DAL_TestFactory.createOpportunity(acc.id);
        ICS_DAL_TestFactory.createApplicationForm(acc.id,testOpportunity.id);
    }
    @IsTest 
    public static void testICS_CTRL_SAPCreateCYT_Success() {
        List<Opportunity> opp = [SELECT Id,AccountId FROM Opportunity where name='tesstopp'];
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());
        Test.startTest();
        ICS_CTRL_SAPCreateCYT sapCreateCYT = new ICS_CTRL_SAPCreateCYT(opp[0].AccountId,false);
        System.enqueueJob(sapCreateCYT);
        Test.stopTest();
        List<AsyncApexJob> jobs = [SELECT Id, JobType FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        assert.istrue(!jobs.isEmpty(), 'A queueable job for ICS_CTRL_SAPCreateAccount should be enqueued.');
    }

   
    private class MockSuccessHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "Success"}');
            return res;
        }
    }
   
}