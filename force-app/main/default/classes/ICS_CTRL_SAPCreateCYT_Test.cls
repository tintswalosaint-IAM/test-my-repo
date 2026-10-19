/**
 * @description SFP-32986 Class used  to test ICS_CTRL_SAPCreateCYT
 * @author Rukesh
 * @date 21/10/2024 
 *****************************************************
 * @last modified on  : 21/10/2024
 * @last modified by  : Rukesh
 * @last modified description: updated to align with the latest version of ICS_CTRL_SAPCreateCYT_Test
 */
@IsTest
public class ICS_CTRL_SAPCreateCYT_Test {
    @TestSetup
    static void setupData() {
        Account acc=ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity =ICS_DAL_TestFactory.createOpportunity(acc.id);
        Applicationform formdata = ICS_DAL_TestFactory.createApplicationForm(acc.id,testOpportunity.id);
        Product2 prodData = ICS_DAL_TestFactory.createProduct2();
        prodData.Name='Euro Account Currency';
        update prodData;
        ICS_DAL_TestFactory.createApplicationFormProduct(formdata.id,prodData.id);
        FinServ__FinancialAccount__c accountInfo =new FinServ__FinancialAccount__c();
        accountInfo.FinServ__PrimaryOwner__c = acc.Id;
        accountInfo.ExternalCIFId__c = '12345';
        insert accountInfo;
    }
    @IsTest
    public static void testICS_CTRL_SAPCreateCYT_Success() {
        List<Opportunity> opp = [SELECT Id,accountID FROM Opportunity];
        Test.setMock(HttpCalloutMock.class, new MockSuccessHttpResponse());
        Test.startTest();
        ICS_CTRL_SAPCreateCYT sapCreateCYT = new ICS_CTRL_SAPCreateCYT(opp[0].accountID,false,'Single');
        System.enqueueJob(sapCreateCYT);
       
       
       sapCreateCYT.enqueueNextJob();
        Test.stopTest();
        List<AsyncApexJob> jobs = [SELECT Id, JobType FROM AsyncApexJob WHERE JobType = 'Queueable' LIMIT 1];
        assert.istrue(!jobs.isEmpty(), 'A queueable job for ICS_CTRL_SAPCreateAccount should be enqueued.');
    }

    @IsTest
    public static void testICS_CTRL_SAPCreateCYT_Exception() {
        List<Opportunity> opp = [SELECT Id,AccountId FROM Opportunity];
        Test.setMock(HttpCalloutMock.class, new MockFailHttpResponse());
        Test.startTest();
        ICS_CTRL_SAPCreateCYT sapCreateCYT = new ICS_CTRL_SAPCreateCYT(opp[0].accountID,false,'Single');
        System.enqueueJob(sapCreateCYT);
        Test.stopTest();
    List<CMN_WebserviceCallQueue__c> webserviceQueues = [SELECT Id, Name, CMN_Response__c, CMN_Request__c
                                                             FROM CMN_WebserviceCallQueue__c];
         assert.istrue(!webserviceQueues.isEmpty(), 'A Webservice call queue should be created in case of failure.');
    }

    private class MockSuccessHttpResponse implements HttpCalloutMock { 
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status": "Success"}');
            return res;
        }
    }
    private class MockFailHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"status": "Error"}');
            return res;
        }
    }
}