/**
 * @description       : Test class for Complaints Management Rejection letter
 * User Story		  : SFP-31300
 * @author            : Aliaksei Koval
 * @last modified on  : 09-08-2025
 * @last modified by  : Aliaksei Koval
**/
@isTest
public with sharing class SVC_TemplateService_Test {

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
        insert testCase;
        
    }
    
    @IsTest
    static void testGetTemplateSuccess() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        SVC_TemplateService.TemplateInputs input = new SVC_TemplateService.TemplateInputs();
        input.recordId = testCase.Id;
        input.reason = 'Test reason';
        
        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new TemplateMockResponse());
        List<String> result = SVC_TemplateService.getTemplate(new List<SVC_TemplateService.TemplateInputs>{input});
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return content document ID');
        Assert.areEqual(1, result.size(), 'Should return exactly one ID');
    }

    @IsTest
    static void testGetTemplateFail() {
        String exceptionMessage = '';
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        SVC_TemplateService.TemplateInputs input = new SVC_TemplateService.TemplateInputs();
        input.recordId = testCase.Id;
        input.reason = 'Test reason';
        
        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new TemplateMockResponseError());
        try{
            SVC_TemplateService.getTemplate(new List<SVC_TemplateService.TemplateInputs>{input});
        } catch(SVC_API_GenerateDocument.GenerateDocumentException ex){
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();
        Assert.isTrue(exceptionMessage.contains('Complaints Rejection Letter'));
    }

    @IsTest
    static void testSendMultipleRequests() {
        Integer caughtException = 0;
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        
        SVC_TemplateService.TemplateInputs input = new SVC_TemplateService.TemplateInputs();
        input.recordId = testCase.Id;
        input.reason = 'Test reason';

        SVC_TemplateService.TemplateInputs input2 = new SVC_TemplateService.TemplateInputs();
        input2.recordId = testCase.Id;
        input2.reason = 'Test reason2';
        
        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new TemplateMockResponseError());
        try{
            SVC_TemplateService.getTemplate(new List<SVC_TemplateService.TemplateInputs>{input,input2});
        } catch(InvalidParameterValueException ex){
            caughtException++;
        }
        Test.stopTest();
        
        Assert.areEqual(1, caughtException);
    }

    @IsTest
    static void testCreateClassInstance() {

        Test.startTest();
        SVC_TemplateService instance = new SVC_TemplateService();
        Test.stopTest();
        
        System.assertNotEquals(null, instance, 'Instance should be created');
    }

    private class TemplateMockResponse implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
            response.setBody('{"status": "SUCCESS","template": {"templateName" : "Letter"}, "output_document":{"content_stream": "JVBERi0yLjAKJeTjz9IKMiAwIG9iago8PC9TdW","file_name":"Test File Name"}}');
            return response;
        }
    }

    @testVisible
    private class TemplateMockResponseError implements HttpCalloutMock {
        
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
            response.setBody('{"status": "FAIL"}');
            return response;
        }
    }
}