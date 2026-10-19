/**
 * @description       : Test class for SA Complaints SMS Communication
 * @User Story:       : SFP-35988
 * @author            : Aliaksei Koval
 * 
 * @description       : Updates to Test Class to move to DTO Class
 * @author            : Aliaksei Koval
 * @last modified on  : 08-12-2025
 * @last modified by  : Aliaksei Koval
**/
@isTest
public with sharing class SVC_SMSService_Test {

    @TestSetup
    static void setupTestData() {
        // Create test Account
        List<Account> testAccounts = SVC_DAL_DataFactory.generateAccounts(1, true);
        insert testAccounts;

        Contact c = SVC_DAL_DataFactory.newContact();
        insert c;
        
        // Create test Case
        Case testCase = SVC_DAL_DataFactory.newCase(c.Id);
        testCase.AccountId = testAccounts[0].Id;
        testCase.Subject = 'Test Case';
        testCase.Status = 'In Progress';
        insert testCase;
        List<QuickText> qtList = new List<QuickText>();
        QuickText qt1 = new QuickText(
            Name = 'SMS Complaints Case Acknowledgement',
            Message = 'Test message',
            Channel = 'Messaging',
            IsInsertable = true
        );
        qtList.add(qt1);

        QuickText qt2 = qt1.clone();
        qt2.Name = 'SMS Complaints Case Resolved';
        qt2.Message = 'Test message2';
        qtList.add(qt2);

        insert qtList;
        
    }

    @IsTest
    static void testSendSMSSuccess() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        SVC_SMSService.MessageInputs input = new SVC_SMSService.MessageInputs();
        input.recordId = testCase.Id;
        
        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new SMSMockResponse());
        SVC_SMSService.sendMessage(new List<SVC_SMSService.MessageInputs>{input});
        Test.stopTest();
        
        FeedItem fi = [SELECT Body FROM FeedItem WHERE ParentId = :testCase.Id];
        Assert.isTrue(fi.Body.contains('SMS Message was sent'));
    }

    @IsTest
    static void testSendSMSFail() {
        Case testCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        SVC_SMSService.MessageInputs input = new SVC_SMSService.MessageInputs();
        input.recordId = testCase.Id;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SMSMockResponseError());
        SVC_SMSService.sendMessage(new List<SVC_SMSService.MessageInputs>{input});
        Test.stopTest();
        
        FeedItem fi = [SELECT Body FROM FeedItem WHERE ParentId = :testCase.Id];
        Assert.isTrue(fi.Body.contains('Failed to send SMS'));
    }

    @IsTest
    static void testSendSMSMultipleRequests() {
        Integer caughtException = 0;
        Case testCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        SVC_SMSService.MessageInputs input = new SVC_SMSService.MessageInputs();
        input.recordId = testCase.Id;
        SVC_SMSService.MessageInputs input2 = new SVC_SMSService.MessageInputs();
        input2.recordId = testCase.Id;


        Test.startTest();
        try{
            SVC_SMSService.sendMessage(new List<SVC_SMSService.MessageInputs>{input, input2});
        } catch(InvalidParameterValueException ex){
            caughtException++;
        }
        Test.stopTest();

        Assert.areEqual(1, caughtException);
    }

    @IsTest
    static void testFindLatestByAccountId(){
        Case testCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Test.startTest();
        Case foundCase = SVC_DAL_Case.findLatestByAccountId(testCase.AccountId);
        Test.stopTest();

        Assert.areEqual(testCase.Id, foundCase.Id);
    }

    @IsTest
    static void testfindByAccountId(){
        Case testCase = [SELECT Id, AccountId FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Test.startTest();
        List<Case> foundCases = SVC_DAL_Case.findByAccountId(testCase.AccountId);
        Test.stopTest();

        Assert.areEqual(1, foundCases.size());
    }

    @testVisible
    private class SMSMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            SVC_DTO_SMSRestResponse responseObj = new SVC_DTO_SMSRestResponse();
            responseObj.requestStatus = 'SUCCESS';
            responseObj.externalReference = '123456789';
            SVC_DTO_SMSRestResponse.Message msg = new SVC_DTO_SMSRestResponse.Message();
            msg.messageBody = 'Test messageBody';
            responseObj.messages = new List<SVC_DTO_SMSRestResponse.Message>{msg};

            response.setBody(JSON.serialize(responseObj));
            return response;
        }
    }

    @testVisible
    private class SMSMockResponseError implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
            response.setBody('{"requestStatus": "FAIL"}');
            return response;
        }
    }
}