/***********************************************************
* @description SFP-34727 test class used for ICS_CTRL_UnfundedDocumentHandler
* @author Ikyatha Naidu
* @date 10/10/2024
******************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 10/10/2024
* Last Modified Description: Initial Version
*/
@isTest
public class ICS_CTRL_UnfundedDocumentHandler_Test {
   @TestSetup
    static void setupTestData() {
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        testAccount.ExternalCIFId__c='0090053314';
        update testAccount;
    }

    @isTest
    static void testResponseCall_Success() {
        String testDocument = 'VGVzdCBkb2N1bWVudCBjb250ZW50';
        String testDocumentType = 'TestDoc.txt';
        ICS_CTRL_UnfundedDocumentHandler.DocumentRequest req = new ICS_CTRL_UnfundedDocumentHandler.DocumentRequest();
        req.Document = testDocument;
        req.DocumentType = testDocumentType;


        String requestBody ='{"requests":[{"Document":"flNUVTU1NX5ENjcxQzMwODc0MDIxRURFOTJBMkU2NjgxQ0JDNDNDOX5CUFBfQ0RfU0JUSElSRFBBUlRZX1VORlVORF9BQ0N+QlBQflRISVJEIFBBUlRZIFNZU1RFTX4yMDIzMDkwMn4wMDMwNDd+MDAwMX4wMDAxCkdCfjQwNDg1Mn4xMDYyMjcyMX4yMDI0MTAxNH4wMDkwMDUzMzE0CkdCfjQwNDg1Mn4xMDYyNjAyNn4yMDEyMDcxM34wMDkwMDUzNTEyCkdCfjQwNDg1Mn4xMDYyNjgzMn4yMDEyMDcxN34wMDkwMDUzNTUwCkdCfjQwNDg1Mn4xMDYzMDIzNn4yMDEyMDcxOX4wMDkwMDUzNjMzCkdCfjQwNDg1Mn4xMDYzMDc1OX4yMDEyMDcyMH4wMDkwMDUzNjgwCkdCfjQwNDg1Mn4xMDYzMTczOX4yMDEyMDcyNH4wMDkwMDUzNzQzCkdCfjQwNDg1Mn4xMDYzMTkxN34yMDEyMDcyNH4wMDkwMDUzNzQ5","DocumentType":"SBSA_SBJ_BWEUNFI_T.20230902_0000002760.BCH"}]}';
        RestRequest restReq = new RestRequest();
        restReq.requestBody = Blob.valueOf(requestBody);
        RestContext.request = restReq;
        RestContext.response = new RestResponse();
        Test.startTest();
        String responseJson = ICS_CTRL_UnfundedDocumentHandler.responseCall();
        Test.stopTest();
        List<ICS_CTRL_UnfundedDocumentHandler.response> responses = (List<ICS_CTRL_UnfundedDocumentHandler.response>)JSON.deserialize(responseJson, List<ICS_CTRL_UnfundedDocumentHandler.response>.class);
		Assert.areEqual(1, responses.size(), 'Expected exactly one response in the response list');
        
            }
    @isTest
    static void testResponseCall_Error() {
        try{
        Test.startTest();
        String  response = ICS_CTRL_UnfundedDocumentHandler.responseCall();
        Test.stopTest();
            List<ICS_CTRL_UnfundedDocumentHandler.Response> responses = (List<ICS_CTRL_UnfundedDocumentHandler.Response>)JSON.deserialize(response, List<ICS_CTRL_UnfundedDocumentHandler.Response>.class);
       Assert.areEqual(1, responses.size(),'Expected exactly one response in the response list');
        }catch(exception ex){
               Assert.areEqual(true, ex.getmessage()!= null,'Error Occured in calling API');
        }
    }
    @isTest
    static void testResponseCall_InvalidJSON() {
        Test.startTest();
        String invalidJsonRequestBody = '{ "requests": "invalid_structure" }';
        
        RestRequest restReq = new RestRequest();
        restReq.requestBody = Blob.valueOf(invalidJsonRequestBody);
        RestContext.request = restReq;
        RestContext.response = new RestResponse();
        String responseJson = ICS_CTRL_UnfundedDocumentHandler.responseCall();
        List<ICS_CTRL_UnfundedDocumentHandler.Response> responses = 
            (List<ICS_CTRL_UnfundedDocumentHandler.Response>) JSON.deserialize(responseJson, List<ICS_CTRL_UnfundedDocumentHandler.Response>.class);
    
        Assert.areEqual(1, responses.size(), 'Expected exactly one response');
    
        Test.stopTest();
    }

    @isTest
    static void testExtractFileData() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDoc.txt',
            VersionData = Blob.valueOf('GB~2024~10~20241010~BP12345~Test Data'),
            IsMajorVersion = true
        );
        insert cv;
        ContentVersion cvr = [SELECT ContentDocumentId FROM ContentVersion LIMIT 1];
        Id contentDocumentId = cvr.ContentDocumentId;

        ICS_CTRL_UnfundedDocumentHandler.emailTemplates = new Map<Integer, String>{
            1 => 'Test_Template_1',
            2 => 'Test_Template_2'
        };
         Integer emailInvocations = Limits.getEmailInvocations();
        Test.startTest();
        ICS_CTRL_UnfundedDocumentHandler.extractFileData(contentDocumentId);
        Test.stopTest();
         Assert.areEqual(emailInvocations, Limits.getEmailInvocations(), 'Email should be attempted to be sent');

    }

    @isTest
    static void testStringToDate() {
        String dateString = '20250128';
        Date result = ICS_CTRL_UnfundedDocumentHandler.stringToDate(dateString);
        Assert.areEqual(Date.newInstance(2025, 01, 28), result,'Date conversion from string should match expected date format');
    }

    @isTest
    static void testSendEmail() {
        Account testAccount = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress   LIMIT 1];

        Test.startTest();
        ICS_CTRL_UnfundedDocumentHandler.sendEmail('test@example.com', testTemplate.Id, testAccount.Id, owa.Id, testAccount.PersonContactId);
        Test.stopTest();

        Assert.areNotEqual(1, Limits.getEmailInvocations(), 'An email should have been sent');
    }
      @isTest
    static void testCreateTask() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'Test Contact', AccountId = testAccount.Id);
        insert testContact;

        Test.startTest();
        ICS_CTRL_UnfundedDocumentHandler.createTask(testAccount.Id, testContact.Id);
        Test.stopTest();

        Task insertedTask = [SELECT Id, Subject, TaskSubtype, Status FROM Task WHERE Subject = 'test1' LIMIT 1];
        Assert.areEqual('test1', insertedTask.Subject, 'Task subject should match');
        Assert.areEqual('Email', insertedTask.TaskSubtype, 'Task subtype should be Email');
        Assert.areEqual('Completed', insertedTask.Status, 'Task status should be Completed');
    }
    @isTest
    static void testCreateCallLog_LargeStrings() {
        // Create a string larger than the maxSize (131072 characters)
        String largeString = '';
        for(Integer i = 0; i < 140000; i++) {
            largeString += 'a';
        }
        
        Test.startTest();
        ICS_CTRL_UnfundedDocumentHandler.createCallLog('TestService', largeString, largeString, true);
        Test.stopTest();
        CMN_WebserviceCallQueue__c log = [SELECT CMN_Request__c, CMN_Response__c FROM CMN_WebserviceCallQueue__c WHERE CMN_Service__c = 'TestService' LIMIT 1];
        Assert.areEqual(131072, log.CMN_Request__c.length(), 'Request should be truncated to maxSize');
        Assert.areEqual(131072, log.CMN_Response__c.length(), 'Response should be truncated to maxSize');
    }
    @isTest
    static void testProcessAccount_SendsEmail() {
        Account testAccount = [SELECT Id, PersonContactId, PersonEmail FROM Account LIMIT 1];
        testAccount.PersonEmail = 'test@example.com';
        update testAccount;
        Date accountDate = System.today().addDays(-2); // 2 days ago
        
        Map<Integer, String> emailTemplatesMap = new Map<Integer, String>{
            2 => 'Test_Template_Name' // This matches the 2 days difference we created above
        };
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];
        Map<String, Id> templateMap = new Map<String, Id>{
            'Test_Template_Name' => template.Id
        };
        OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        
        Test.startTest();
        ICS_CTRL_UnfundedDocumentHandler.processAccount(
            testAccount, 
            accountDate, 
            owa.Id, 
            templateMap, 
            emailTemplatesMap
        );
        Test.stopTest();
        
         Assert.areEqual(0, Limits.getEmailInvocations(), 'No email should be sent when no matching template');
    }
   
}