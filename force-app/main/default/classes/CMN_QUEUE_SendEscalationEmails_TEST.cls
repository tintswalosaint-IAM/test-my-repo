/*
 * @description Test class for CMN_QUEUE_SendEscalationEmails
 *
 * @author Raymond Magezi
 *
 * @date 29-01-2026
 *
 * History
 * 29-01-2026 - Raymond Magezi - Initial creation
 */
@SuppressWarnings('sf:TooManyMethods')
@IsTest(SeeAllData=false)
private class CMN_QUEUE_SendEscalationEmails_TEST {
  
  private static final String TEST_EMAIL = 'test@example.com';
  private static final String EXPECTED_EXCEPTION = 'Expected QueueableException';
  private static final String ERROR_EMPTY_REQUESTS = 'Email requests list is null or empty';
  private static final String ERROR_INVALID_REQUESTS = 'All email requests were invalid';
  
  @TestSetup
  private static void setup() {
    Contact newContact = CMN_DAL_DataFactory.newContact();
    CMN_DAL_SObjectDomain.insertDBObject(newContact);
    
    Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
    CMN_DAL_SObjectDomain.insertDBObject(newCase);
  }
  
  @IsTest
  private static void testQueueEmailsSuccess() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    String orgWideEmail = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
    
    CMN_QUEUE_SendEscalationEmails.EmailRequest request = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
    request.toAddress = TEST_EMAIL;
    request.caseId = testCase.Id;
    request.templateName = templateName;
    request.orgWideEmail = orgWideEmail;
    
    Test.startTest();
    Id jobId = CMN_QUEUE_SendEscalationEmails.queueEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{ request });
    Test.stopTest();
    
    Assert.isNotNull(jobId);
  }
  
  @IsTest
  private static void testQueueEmailsWithCc() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    String orgWideEmail = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
    
    CMN_QUEUE_SendEscalationEmails.EmailRequest request = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
    request.toAddress = TEST_EMAIL;
    request.caseId = testCase.Id;
    request.ccAddresses = new List<String>{ 'cc@example.com' };
    request.templateName = templateName;
    request.orgWideEmail = orgWideEmail;
    
    Test.startTest();
    Id jobId = CMN_QUEUE_SendEscalationEmails.queueEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{ request });
    Test.stopTest();
    
    Assert.isNotNull(jobId);
  }
  
  @IsTest
  private static void testQueueEmailsNullRequest() {
    Test.startTest();
    try {
      CMN_QUEUE_SendEscalationEmails.queueEmails(null);
      Assert.fail(EXPECTED_EXCEPTION);
    } catch (CMN_QUEUE_SendEscalationEmails.QueueableException e) {
      Assert.isTrue(e.getMessage().contains(ERROR_EMPTY_REQUESTS));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testQueueEmailsEmptyList() {
    Test.startTest();
    try {
      CMN_QUEUE_SendEscalationEmails.queueEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>());
      Assert.fail(EXPECTED_EXCEPTION);
    } catch (CMN_QUEUE_SendEscalationEmails.QueueableException e) {
      Assert.isTrue(e.getMessage().contains(ERROR_EMPTY_REQUESTS));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testQueueEmailsInvalidEmail() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    String orgWideEmail = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
    
    CMN_QUEUE_SendEscalationEmails.EmailRequest request = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
    request.toAddress = 'invalid-email';
    request.caseId = testCase.Id;
    request.templateName = templateName;
    request.orgWideEmail = orgWideEmail;
    
    Test.startTest();
    try {
      CMN_QUEUE_SendEscalationEmails.queueEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{ request });
      Assert.fail(EXPECTED_EXCEPTION);
    } catch (CMN_QUEUE_SendEscalationEmails.QueueableException e) {
      Assert.isTrue(e.getMessage().contains(ERROR_INVALID_REQUESTS));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testQueueEmailsMissingRequiredFields() {
    CMN_QUEUE_SendEscalationEmails.EmailRequest request = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
    request.toAddress = TEST_EMAIL;
    
    Test.startTest();
    try {
      CMN_QUEUE_SendEscalationEmails.queueEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{ request });
      Assert.fail(EXPECTED_EXCEPTION);
    } catch (CMN_QUEUE_SendEscalationEmails.QueueableException e) {
      Assert.isTrue(e.getMessage().contains(ERROR_INVALID_REQUESTS));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testIsValidEmail() {
    Test.startTest();
    Boolean validEmail = CMN_UTIL_EmailValidator.isValidEmail(TEST_EMAIL);
    Boolean invalidEmail = CMN_UTIL_EmailValidator.isValidEmail('invalid-email');
    Boolean blankEmail = CMN_UTIL_EmailValidator.isValidEmail('');
    Test.stopTest();
    
    Assert.isTrue(validEmail);
    Assert.isFalse(invalidEmail);
    Assert.isFalse(blankEmail);
  }
  
  @IsTest
  private static void testExecuteWithValidRequests() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    String orgWideEmail = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
    
    CMN_FLOW_SendEmail.DTO_SendEmailRequest emailReq = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
    emailReq.toAddress = TEST_EMAIL;
    emailReq.whatId = testCase.Id;
    emailReq.templateUniqueName = templateName;
    emailReq.orgWideEmailAddress = orgWideEmail;
    
    CMN_QUEUE_SendEscalationEmails queueable = new CMN_QUEUE_SendEscalationEmails(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>{ emailReq });
    
    Test.startTest();
    Id jobId = System.enqueueJob(queueable);
    Test.stopTest();
    
    Assert.isNotNull(jobId);
  }
  
  @IsTest
  private static void testExecuteWithInvalidRequests() {
    CMN_FLOW_SendEmail.DTO_SendEmailRequest emailReq = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
    emailReq.toAddress = 'invalid';
    emailReq.whatId = null;
    
    CMN_QUEUE_SendEscalationEmails queueable = new CMN_QUEUE_SendEscalationEmails(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>{ emailReq });
    
    Test.startTest();
    Id jobId = System.enqueueJob(queueable);
    Test.stopTest();
    
    Assert.isNotNull(jobId);
  }
  
  @IsTest
  private static void testConstructorWithNullRequests() {
    Test.startTest();
    try {
      new CMN_QUEUE_SendEscalationEmails(null);
      Assert.fail(EXPECTED_EXCEPTION);
    } catch (CMN_QUEUE_SendEscalationEmails.QueueableException e) {
      Assert.isTrue(e.getMessage().contains(ERROR_EMPTY_REQUESTS));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testConstructorWithEmptyRequests() {
    Test.startTest();
    try {
      new CMN_QUEUE_SendEscalationEmails(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>());
      Assert.fail(EXPECTED_EXCEPTION);
    } catch (CMN_QUEUE_SendEscalationEmails.QueueableException e) {
      Assert.isTrue(e.getMessage().contains(ERROR_EMPTY_REQUESTS));
    }
    Test.stopTest();
  }
  
  @IsTest
  private static void testQueueEmailsWithInvalidCcAddress() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    String orgWideEmail = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
    
    CMN_QUEUE_SendEscalationEmails.EmailRequest request = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
    request.toAddress = TEST_EMAIL;
    request.caseId = testCase.Id;
    request.ccAddresses = new List<String>{ 'invalid-cc' };
    request.templateName = templateName;
    request.orgWideEmail = orgWideEmail;
    
    Test.startTest();
    Id jobId = CMN_QUEUE_SendEscalationEmails.queueEmails(new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>{ request });
    Test.stopTest();
    
    Assert.isNotNull(jobId, 'Invalid CC should be filtered, not rejected');
  }
  
  @IsTest
  private static void testIsValidInputRequest() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    String orgWideEmail = null;
    
    CMN_QUEUE_SendEscalationEmails.EmailRequest validRequest = new CMN_QUEUE_SendEscalationEmails.EmailRequest();
    validRequest.toAddress = TEST_EMAIL;
    validRequest.caseId = testCase.Id;
    validRequest.templateName = templateName;
    validRequest.orgWideEmail = orgWideEmail;
    
    Test.startTest();
    Boolean isValid = CMN_SVC_EmailRequestTransformer.isValid(validRequest);
    Boolean isNullValid = CMN_SVC_EmailRequestTransformer.isValid(null);
    Test.stopTest();
    
    Assert.isTrue(isValid);
    Assert.isFalse(isNullValid);
  }
  
  @IsTest
  private static void testIsValidEmailRequest() {
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    
    CMN_FLOW_SendEmail.DTO_SendEmailRequest validReq = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
    validReq.toAddress = TEST_EMAIL;
    validReq.whatId = testCase.Id;
    validReq.templateUniqueName = templateName;
    
    CMN_FLOW_SendEmail.DTO_SendEmailRequest invalidReq = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
    invalidReq.toAddress = 'invalid';
    
    Test.startTest();
    Boolean isValid = CMN_SVC_EmailRequestTransformer.isValidDto(validReq);
    Boolean isInvalid = CMN_SVC_EmailRequestTransformer.isValidDto(invalidReq);
    Boolean isNull = CMN_SVC_EmailRequestTransformer.isValidDto(null);
    Test.stopTest();
    
    Assert.isTrue(isValid);
    Assert.isFalse(isInvalid);
    Assert.isFalse(isNull);
  }
}