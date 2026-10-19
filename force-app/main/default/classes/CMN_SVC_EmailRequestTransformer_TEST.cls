/*------------------------------------------------------------
Author:        Raymond Magezi
Description:   Test class for CMN_SVC_EmailRequestTransformer
Test Class:    CMN_SVC_EmailRequestTransformer_TEST

History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------
23-02-2026  Raymond Magezi     Initial creation
------------------------------------------------------------*/
@IsTest
private class CMN_SVC_EmailRequestTransformer_TEST {
    
    private static final String TEST_EMAIL = 'test@example.com';
    
    @IsTest
    private static void testTransform_Valid() {
        Case testCase = new Case(Subject = 'Test');
        insert testCase;
        
        CMN_QUEUE_SendEscalationEmails.EmailRequest req = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
        req.toAddress = TEST_EMAIL;
        req.caseId = testCase.Id;
        req.templateName = 'TestTemplate';
        req.orgWideEmail = 'org@example.com';
        
        Test.startTest();
        List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> result = 
            CMN_SVC_EmailRequestTransformer.transform(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{req});
        Test.stopTest();
        
        Assert.areEqual(1, result.size());
        Assert.areEqual(TEST_EMAIL, result[0].toAddress);
    }
    
    @IsTest
    private static void testTransform_Invalid() {
        CMN_QUEUE_SendEscalationEmails.EmailRequest req = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
        req.toAddress = 'invalid';
        
        Test.startTest();
        List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> result = 
            CMN_SVC_EmailRequestTransformer.transform(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{req});
        Test.stopTest();
        
        Assert.areEqual(0, result.size());
    }
    
    @IsTest
    private static void testIsValid_Valid() {
        Case testCase = new Case(Subject = 'Test');
        insert testCase;
        
        CMN_QUEUE_SendEscalationEmails.EmailRequest req = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
        req.toAddress = TEST_EMAIL;
        req.caseId = testCase.Id;
        req.templateName = 'TestTemplate';
        req.orgWideEmail = 'org@example.com';
        
        Test.startTest();
        Boolean result = CMN_SVC_EmailRequestTransformer.isValid(req);
        Test.stopTest();
        
        Assert.isTrue(result);
    }
    
    @IsTest
    private static void testIsValid_Null() {
        Test.startTest();
        Boolean result = CMN_SVC_EmailRequestTransformer.isValid(null);
        Test.stopTest();
        
        Assert.isFalse(result);
    }
    
    @IsTest
    private static void testIsValidDto_Valid() {
        Case testCase = new Case(Subject = 'Test');
        insert testCase;
        
        CMN_FLOW_SendEmail.DTO_SendEmailRequest req = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
        req.toAddress = TEST_EMAIL;
        req.whatId = testCase.Id;
        req.templateUniqueName = 'TestTemplate';
        
        Test.startTest();
        Boolean result = CMN_SVC_EmailRequestTransformer.isValidDto(req);
        Test.stopTest();
        
        Assert.isTrue(result);
    }
    
    @IsTest
    private static void testIsValidDto_Invalid() {
        CMN_FLOW_SendEmail.DTO_SendEmailRequest req = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
        req.toAddress = 'invalid';
        
        Test.startTest();
        Boolean result = CMN_SVC_EmailRequestTransformer.isValidDto(req);
        Test.stopTest();
        
        Assert.isFalse(result);
    }
}