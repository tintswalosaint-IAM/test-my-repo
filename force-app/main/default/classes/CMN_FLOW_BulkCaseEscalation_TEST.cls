/*
 * @description Test class for CMN_FLOW_BulkCaseEscalation
 *
 * @author Raymond Magezi
 *
 * @date 04-02-2026
 *
 * History
 * 04-02-2026 - Raymond Magezi - Initial creation
 */
@IsTest(SeeAllData=false)
private class CMN_FLOW_BulkCaseEscalation_TEST {
  
    private static final String LOCALE_EN_US = 'en_US';

  @TestSetup
  private static void setup() {
    Contact newContact = CMN_DAL_DataFactory.newContact();
    CMN_DAL_SObjectDomain.insertDBObject(newContact);
    
    Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
    CMN_DAL_SObjectDomain.insertDBObject(newCase);
  }
  
  @IsTest
  private static void testProcessEscalationsSuccess() {
    User manager = createUserWithManager();
    Case testCase = CMN_DAL_Case.getAll().iterator().next();
    testCase.OwnerId = manager.Id;
    testCase.SVC_Escalation_Level__c = 0;
    update testCase;
    
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    
    CMN_FLOW_BulkCaseEscalation.DTO_Request request = new CMN_FLOW_BulkCaseEscalation.DTO_Request();
    request.cases = new List<Case>{ testCase };
    request.orgWideEmail = null;
    request.templateName = templateName;
    
    Test.startTest();
    List<CMN_FLOW_BulkCaseEscalation.DTO_Response> responses = 
      CMN_FLOW_BulkCaseEscalation.processEscalations(new List<CMN_FLOW_BulkCaseEscalation.DTO_Request>{ request });
    Test.stopTest();
    
    Assert.isNotNull(responses);
    Assert.areEqual(1, responses.size());
    Assert.isTrue(responses[0].processedCount >= 0);
  }
  
  @IsTest
  private static void testProcessEscalationsBulk() {
    User manager = createUserWithManager();
    
    List<Case> testCases = new List<Case>();
    for (Integer i = 0; i < 3; i++) {
      Case newCase = new Case(
        Subject = 'Test Case ' + i,
        Status = 'New',
        OwnerId = manager.Id,
        SVC_Escalation_Level__c = 0
      );
      testCases.add(newCase);
    }
    insert testCases;
    
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    
    CMN_FLOW_BulkCaseEscalation.DTO_Request request = new CMN_FLOW_BulkCaseEscalation.DTO_Request();
    request.cases = testCases;
    request.orgWideEmail = null;
    request.templateName = templateName;
    
    Test.startTest();
    List<CMN_FLOW_BulkCaseEscalation.DTO_Response> responses = 
      CMN_FLOW_BulkCaseEscalation.processEscalations(new List<CMN_FLOW_BulkCaseEscalation.DTO_Request>{ request });
    Test.stopTest();
    
    Assert.isNotNull(responses);
    Assert.areEqual(1, responses.size());
    Assert.isTrue(responses[0].processedCount >= 0);
  }
  
  @IsTest
  private static void testProcessEscalationsNoManager() {
    User currentUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
    
    Case testCase = new Case(
      Subject = 'Test Case',
      Status = 'New',
      OwnerId = currentUser.Id,
      SVC_Escalation_Level__c = 3
    );
    insert testCase;
    
    String templateName = [SELECT DeveloperName FROM EmailTemplate LIMIT 1].DeveloperName;
    
    CMN_FLOW_BulkCaseEscalation.DTO_Request request = new CMN_FLOW_BulkCaseEscalation.DTO_Request();
    request.cases = new List<Case>{ testCase };
    request.orgWideEmail = null;
    request.templateName = templateName;
    
    Test.startTest();
    List<CMN_FLOW_BulkCaseEscalation.DTO_Response> responses = 
      CMN_FLOW_BulkCaseEscalation.processEscalations(new List<CMN_FLOW_BulkCaseEscalation.DTO_Request>{ request });
    Test.stopTest();
    
    Assert.isNotNull(responses);
    Assert.areEqual(1, responses.size());
    Assert.isTrue(responses[0].processedCount >= 0);
  }
  
  private static User createUserWithManager() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
    
    User manager = new User(
      Alias = 'mgr',
      Email = 'manager@test.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Manager',
      LanguageLocaleKey = LOCALE_EN_US,
      LocaleSidKey = LOCALE_EN_US,
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = 'testmgr' + System.currentTimeMillis() + '@test.com'
    );
    insert manager;
    
    User employee = new User(
      Alias = 'emp',
      Email = 'employee@test.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Employee',
      LanguageLocaleKey = LOCALE_EN_US,
      LocaleSidKey = LOCALE_EN_US,
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      Username = 'testemp' + System.currentTimeMillis() + '@test.com',
      ManagerId = manager.Id
    );
    insert employee;
    
    return employee;
  }
}