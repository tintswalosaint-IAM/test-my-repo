/**
 * @description                 : Test class for ICS_CTRL_ApprovalFlow
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 23-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Updated
 * @last modified by            : Ridhima Saxena
 * @last modified on            : 19-05-2026
 * @modification description    : SFP-57688
 */

 @isTest
 private class ICS_CTRL_ApprovalFlow_Test {
    /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createDirectOpportunity(testAccount.Id);
        ApplicationForm testApplicationForm = ICS_DAL_TestFactory.createApplicationForm(testAccount.Id, testOpportunity);
        Product2 testProduct2 = ICS_DAL_TestFactory.createProduct2();
        ICS_DAL_TestFactory.createApplicationFormProduct(testApplicationForm.Id, testProduct2.Id);
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(testAccount.Id);
        ICS_DAL_TestFactory.createPartyProfileRisk(testPartyProfile.Id);
        ICS_DAL_TestFactory.createPartyAssetFunds(testPartyProfile.Id);
        ICS_DAL_TestFactory.createPartyScreeningSummary(testPartyProfile.Id);
        ICS_DAL_TestFactory.createApplicant(testAccount.Id, testPartyProfile.Id, testApplicationForm.Id);
        ICS_DAL_TestFactory.createProcessInstance(testOpportunity);
        ICS_DAL_TestFactory.createAssessmentQuestionVersions();
    }

    @isTest
    static void testApprovalRequest() {

        Test.startTest();
        Id processInstanceId = [select id from ProcessInstance limit 1].Id;
        Assert.areNotEqual(null, processInstanceId, 'ProcessInstance should not be null');

        Account testAccount = [select id from Account limit 1];
        Opportunity testOpportunity = [select id from Opportunity limit 1];

        ICS_CTRL_ApprovalFlow.updateOpportunity((Id)null, (String)null);
        ICS_CTRL_ApprovalFlow.updateOpportunity((Id)null, 'xyz');
        ICS_CTRL_ApprovalFlow.updateOpportunity(testOpportunity.Id, '');

        String jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false","name":"ICS UK Full Onboarding Component","pId":"' + testAccount.Id + '","OpportunityId":"' + testOpportunity.Id + '"}';
        Boolean result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
        Assert.areEqual(true, result, 'Assessment data could not be saved');
        
        jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","On hold":"true","On hold reason":"Application Issues (RFT)","Account locks required?4":"false","name":"ICS UK Full Onboarding Component","pId":"' + testAccount.Id + '","OpportunityId":"' + testOpportunity.Id + '"}';
        result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
        Assert.areEqual(true, result, 'Assessment data could not be saved');
        
        jsonString = ICS_CTRL_ApprovalFlow.getDetails(processInstanceId);
        String commonQueryPart = ICS_CTRL_ApprovalFlow.getConfig('Common') + '\n\n';
        result =  ICS_CTRL_ApprovalFlow.checkAllCriteria(commonQueryPart + ICS_CTRL_ApprovalFlow.getConfig('QC 01 FR'));

        ICS_CTRL_ApprovalFlow.getApprovalHistory(processInstanceId);

        ICS_CTRL_ApprovalFlow.updateOpportunity(testOpportunity.Id, 'Closed Lost');
        
        Test.stopTest();
        Assert.areEqual(true, result, 'output must be true');

    }

    @isTest
    @SuppressWarnings('PMD.NcssMethodCount')
    static void testMethods() {
        Opportunity opportunity = [select id from opportunity limit 1];
        Account account = [select id from account limit 1];

        Test.startTest();

        ICS_CTRL_ApprovalFlow.getConditions('xyz');

        ICS_CTRL_ApprovalFlow.Input[] inputs = new ICS_CTRL_ApprovalFlow.Input[]{};
        ICS_CTRL_ApprovalFlow.Input input = new ICS_CTRL_ApprovalFlow.Input();
        input.opportunityId = opportunity.Id;
        inputs.add(input);
        
        String jSONString = '{"GSD Outcome":"GSD Outcome - Declined", "Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false","name":"ICS UK Full Onboarding Component","pId":"' + account.id + '","opportunityId":"' + opportunity.Id + '"}';
        Boolean result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jSONString);
        Assert.areEqual(true, result, 'Assessment data could not be saved');
        
        String resultString = ICS_CTRL_ApprovalFlow.getDeveloperName((String)null);
        Assert.areEqual(null, resultString, 'ICS_CTRL_ApprovalFlow.getDeveloperName: not null output not expected');
        resultString = ICS_CTRL_ApprovalFlow.loadAssessmentData((Id)null, (String)null);
        Assert.areNotEqual(null, resultString, 'ICS_CTRL_ApprovalFlow.loadAssessmentData: null output not expected');
        resultString = ICS_CTRL_ApprovalFlow.loadAssessmentData(account.Id, 'xyz');
        Assert.areNotEqual(null, resultString, 'ICS_CTRL_ApprovalFlow.loadAssessmentData: null output not expected');
        resultString = ICS_CTRL_ApprovalFlow.loadAssessmentData(account.Id, 'ICS UK Full Onboarding Component');
        Assert.areNotEqual(null, resultString, 'ICS_CTRL_ApprovalFlow.loadAssessmentData: null output not expected');
        Set<Id> ids = ICS_CTRL_ApprovalFlow.getIdsSet((ICS_CTRL_ApprovalFlow.Input[])null);
        Assert.areEqual(null, ids, 'ICS_CTRL_ApprovalFlow.getIdsSet: null was expected here');

        resultString = ICS_CTRL_ApprovalFlow.getConfig((String)null);
        Assert.areEqual(null, resultString, 'ICS_CTRL_ApprovalFlow.getConfig: null was expected here');
        List<Map<String, String>> mapResult = ICS_CTRL_ApprovalFlow.getConditions((String)null);
        Assert.areEqual(null, mapResult, 'ICS_CTRL_ApprovalFlow.getConditions: null was expected here');
        mapResult = ICS_CTRL_ApprovalFlow.getConditions('Common');
        Assert.areNotEqual(null, mapResult, 'ICS_CTRL_ApprovalFlow.getConditions: null was not expected here');
        String[] resultList = ICS_CTRL_ApprovalFlow.evalQueueCode((ICS_CTRL_ApprovalFlow.Input[])null, (String)null);
        Assert.areEqual(null, resultList, 'ICS_CTRL_ApprovalFlow.evalQueueCode: null was expected here');
        resultList = ICS_CTRL_ApprovalFlow.evalQueueCode((ICS_CTRL_ApprovalFlow.Input[])null, 'FR.NCA$');
        Assert.areEqual(null, resultList, 'ICS_CTRL_ApprovalFlow.evalQueueCode: null was expected here');
        List<String> listResult = ICS_CTRL_ApprovalFlow.processFlowRequests((ICS_CTRL_ApprovalFlow.Input[])null);
        Assert.areEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'Check Additional Risk Factors';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'saveAssessmentData';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        inputs[0].str = 'Load GSD Comment';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        inputs[0].str = 'Load Ukraine Exception Comment';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        inputs[0].str = 'Update Required Approval Process(Set)';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        inputs[0].str = 'Update Required Approval Process(Unset)';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        inputs[0].str = 'Get Queue Code';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        inputs[0].str = 'Check Queue Conditions';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'Check Motivation Required';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'Group Sanctions Desk';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'Get Party Profile IDs for GSD';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'All Applicants Assessed';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
		
        User testUser = [select id from user where UserRole.Name like '%New Client Manager%' limit 1];
        
        System.runAs (testUser) {
            inputs[0].str = 'Last approver not a Client Manager';
            listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        }

        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was expected here');
        inputs[0].str = 'xyz';
        listResult = ICS_CTRL_ApprovalFlow.processFlowRequests(inputs);
        Assert.areNotEqual(null, listResult, 'ICS_CTRL_ApprovalFlow.processFlowRequests: null was not expected here');
        Boolean resultBoolean = ICS_CTRL_ApprovalFlow.checkAllCriteria((String)null);
        Assert.areNotEqual(null, resultBoolean, 'ICS_CTRL_ApprovalFlow.checkAllCriteria: null was expected here');
        opportunity.Required_Approval_Processes__c = null;
        ICS_CTRL_ApprovalFlow.addRequiredApproval(new Id[]{null}, (String) null);
        ICS_CTRL_ApprovalFlow.addRequiredApproval(new Id[]{opportunity.Id}, (String) null);
        ICS_CTRL_ApprovalFlow.removeRequiredApproval(new Id[]{null}, (String) null);
        ICS_CTRL_ApprovalFlow.removeRequiredApproval(new Id[]{opportunity.Id}, (String) null);
		Map<String,List<Object>> resultMap = ICS_CTRL_ApprovalFlow.getStringMap((SObject[]) null, (SObjectField) null);
        Assert.areNotEqual(null, resultMap, 'ICS_CTRL_ApprovalFlow.getStringMap: null was not expected here');
        resultMap = ICS_CTRL_ApprovalFlow.getStringMap((SObject[]) new SObject[]{opportunity}, (SObjectField) AssessmentQuestion.DeveloperName);
        Assert.areNotEqual(null, resultMap, 'ICS_CTRL_ApprovalFlow.getStringMap: null was not expected here');
        resultList = ICS_CTRL_ApprovalFlow.getFieldValues((SObject[]) new SObject[]{opportunity}, (SObjectField) AssessmentQuestion.DeveloperName);
        Assert.areNotEqual(null, resultList, 'ICS_CTRL_ApprovalFlow.getFieldValues: null was not expected here');
        input.value = 'xyz';
        resultList = ICS_CTRL_ApprovalFlow.evalQueueCode(inputs, 'FR.NCA$');    
        Assert.areNotEqual(null, resultList, 'ICS_CTRL_ApprovalFlow.evalQueueCode: null was expected here');
    }
      @isTest
    static void testAddPartyProfileId() {
        Test.startTest();
        String approvalProcess = 'Need GSD Approval';
        String result = ICS_CTRL_ApprovalFlow.addPartyProfileId(approvalProcess);
        Assert.areEqual('Need GSD Approval', result, 'Expected approval process to be modified');
    
        approvalProcess = 'Some Other Approval';
        result = ICS_CTRL_ApprovalFlow.addPartyProfileId(approvalProcess);
        Assert.areEqual('Some Other Approval', result, 'Approval process should remain unchanged');
    
        Test.stopTest();
    }
     @isTest
    static void testAddRequiredApproval() {
        Test.startTest();
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createDirectOpportunity(testAccount.Id);
        ICS_CTRL_ApprovalFlow.addRequiredApproval(new Id[]{testOpportunity.Id}, 'Need GSD Approval');
        Opportunity updatedOpportunity = [SELECT Required_Approval_Processes__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        ICS_CTRL_ApprovalFlow.addRequiredApproval(new Id[]{testOpportunity.Id}, 'Need GSD Approval');
        updatedOpportunity = [SELECT Required_Approval_Processes__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        Integer occurrences = updatedOpportunity.Required_Approval_Processes__c.split('Need GSD Approval').size() - 1;
        Assert.areEqual(1, occurrences, 'Approval process should not be duplicated');
    
        Test.stopTest();
    }
    @isTest
    static void testRemoveRequiredApproval() {
        Test.startTest();
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createDirectOpportunity(testAccount.Id);
        
        ICS_CTRL_ApprovalFlow.addRequiredApproval(new Id[]{testOpportunity.Id}, 'Need GSD Approval');
        Opportunity opportunityWithApproval = [SELECT Required_Approval_Processes__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        Assert.isTrue(opportunityWithApproval.Required_Approval_Processes__c.contains('Need GSD Approval'), 
                      'Approval process should be present after adding');
        
        ICS_CTRL_ApprovalFlow.removeRequiredApproval(new Id[]{testOpportunity.Id}, 'Need GSD Approval');
        
        Opportunity updatedOpportunity = [SELECT Required_Approval_Processes__c FROM Opportunity WHERE Id = :testOpportunity.Id];
        
        Test.stopTest();
        if (updatedOpportunity.Required_Approval_Processes__c == null) {
            Assert.isNull(updatedOpportunity.Required_Approval_Processes__c, 
                         'Required_Approval_Processes__c should be null after removal');
        } else {
            Assert.isFalse(updatedOpportunity.Required_Approval_Processes__c.contains('Need GSD Approval'), 
                          'Approval process should not be present after removal');
        }
    }
    @isTest
    static void testAssignRequest() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        ProcessInstanceWorkItem workItem = [SELECT Id, ActorId 
                                            FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :testOpportunity.Id 
                                            LIMIT 1];
        
        Test.startTest();
        Boolean assignResult = ICS_CTRL_ApprovalFlow.assignRequest(workItem.Id);
        ProcessInstanceWorkItem updatedWorkItem = [SELECT ActorId 
                                                   FROM ProcessInstanceWorkItem 
                                                   WHERE Id = :workItem.Id];
        Assert.areEqual(UserInfo.getUserId(), updatedWorkItem.ActorId, 
                        'ActorId should be assigned to the current user');
        Assert.areEqual(true, assignResult, 'Method should return true');
        Test.stopTest();
    }

  @isTest
    static void testGetRequiredApprovalProcessesValue() {
        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Form',
            CloseDate = Date.today(),
            AccountId = testAccount.Id, 
            Required_Approval_Processes__c = 'Approval1;Approval2;'
        );
        insert testOpportunity;
        String approvalProcesses = ICS_CTRL_ApprovalFlow.getRequiredApprovalProcessesValue(testOpportunity.Id);
        Assert.areEqual('Approval1;Approval2;', approvalProcesses, 'Approval process values should match');
        Test.stopTest();
    }
    
    @isTest
    static void testGetAssignedTo() {
        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Form',
            CloseDate = Date.today(),
            Required_Approval_Processes__c = ';FR.NC$',
            AccountId = testAccount.Id 
        );
        insert testOpportunity;
        User approverUser = [SELECT Id, Name FROM User WHERE IsActive = TRUE LIMIT 1];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(testOpportunity.Id);
        req.setNextApproverIds(new List<Id>{approverUser.Id}); 
        req.setComments('Submitting for approval');

        Approval.process(req);
        ProcessInstanceWorkItem testWorkItem = [
            SELECT Id, ActorId 
            FROM ProcessInstanceWorkItem 
            WHERE ProcessInstance.TargetObjectId = :testOpportunity.Id 
            LIMIT 1
        ];
        String[] assignedName = ICS_CTRL_ApprovalFlow.getAssignedTo(testWorkItem.Id);
        Assert.areEqual(approverUser.Name, assignedName[0], 'Assigned name should match the approver');
        Test.stopTest();
    }
   @isTest
    static void testApproveRequest() {
        Test.startTest();
        User approver = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Form',
            CloseDate = Date.today(),
            Required_Approval_Processes__c = ';FR.NC$',
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(testOpportunity.Id);
        req.setComments('Submitting for approval');
        req.setNextApproverIds(new Id[]{approver.Id});
        Approval.process(req);
        ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :testOpportunity.Id LIMIT 1];
        Boolean approveResult = ICS_CTRL_ApprovalFlow.approveRequest(workItem.Id, 'Approve', 'Approval granted');
        ProcessInstance updatedInstance = [SELECT Status FROM ProcessInstance 
                                           WHERE TargetObjectId = :testOpportunity.Id LIMIT 1];
        
        List<Map<String, Object>> approvalHistory = ICS_CTRL_ApprovalFlow.getApprovalHistory(testOpportunity.Id);

        Assert.areEqual(true, approveResult, 'Method should return true');
        Assert.areEqual('Approved', updatedInstance.Status, 'ProcessInstance should be approved');
        Assert.areNotEqual(null, approvalHistory, 'Method should not return null');
        
        Test.stopTest();
    }

  @isTest
    static void testRejectRequest() {
        Test.startTest();
        User approver = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Form',
            CloseDate = Date.today(),
            Required_Approval_Processes__c = ';FR.NC$',
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(testOpportunity.Id);
        req.setComments('Submitting for approval');
        req.setNextApproverIds(new Id[]{approver.Id});
        Approval.process(req);
        ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :testOpportunity.Id LIMIT 1];
        Boolean approveResult = ICS_CTRL_ApprovalFlow.approveRequest(workItem.Id, 'Reject;', 'Rejected');
        ProcessInstance updatedInstance = [SELECT Status FROM ProcessInstance 
                                           WHERE TargetObjectId = :testOpportunity.Id LIMIT 1];
        
        List<Map<String, Object>> approvalHistory = ICS_CTRL_ApprovalFlow.getApprovalHistory(testOpportunity.Id);

        Assert.areEqual(true, approveResult, 'Method should return true');
        Assert.areEqual('Rejected', updatedInstance.Status, 'ProcessInstance should be Rejected');
        Assert.areNotEqual(null, approvalHistory, 'Method should not return null');
        
        Test.stopTest();
    }

    @isTest
    static void testSendBackRequest() {
        Test.startTest();
        User approver = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Form',
            CloseDate = Date.today(),
            Required_Approval_Processes__c = ';FR.NCA.CM$',
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(testOpportunity.Id);
        req.setComments('Submitting for approval');
        req.setNextApproverIds(new Id[]{approver.Id});
        Approval.process(req);
        ProcessInstanceWorkItem workItem = [SELECT Id FROM ProcessInstanceWorkItem 
                                            WHERE ProcessInstance.TargetObjectId = :testOpportunity.Id LIMIT 1];
        Boolean approveResult = ICS_CTRL_ApprovalFlow.approveRequest(workItem.Id, 'Send Back', 'Recheck');
        ProcessInstance updatedInstance = [SELECT Status FROM ProcessInstance 
                                           WHERE TargetObjectId = :testOpportunity.Id LIMIT 1];
        
        List<Map<String, Object>> approvalHistory = ICS_CTRL_ApprovalFlow.getApprovalHistory(testOpportunity.Id);

        Assert.areEqual(true, approveResult, 'Method should return true');
        Assert.areEqual('Rejected', updatedInstance.Status, 'ProcessInstance should be Rejected');
        Assert.areNotEqual(null, approvalHistory, 'Method should not return null');
        
        Test.stopTest();
    }

    @isTest
    static void testProcessRequestsMethod() {
        Test.startTest();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Application Form',
            CloseDate = Date.today(),
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        String testStr = 'Test String';
        String testValue = 'Test Value';

        String result = ICS_CTRL_ApprovalFlow.processRequestsMethod(testOpportunity.Id, testStr, testValue);
        Assert.areNotEqual(null, result, 'Returned value should not be null');
        Test.stopTest();
    }
  @isTest
    static void testCheckAndGetIds() {
        Test.startTest();
        Applicant testApplicant = [SELECT Id, PartyProfileId, ApplicationFormId FROM Applicant LIMIT 1];
        Assert.areNotEqual(null, testApplicant, 'Test Applicant should exist');
        Assert.areNotEqual(null, testApplicant.PartyProfileId, 'PartyProfileId should not be null');
        Assert.areNotEqual(null, testApplicant.ApplicationFormId, 'ApplicationFormId should not be null');
        String testQuery = 'SELECT Id FROM Applicant WHERE PartyProfileId != NULL';
        ICS_CTRL_ApprovalFlow.checkAndGetIds(testQuery);

        Test.stopTest();
    }
	  
    @isTest
    static void testUploadFileSuccess() {
        String validJson = '{"files":[{"name":"test.pdf","content":"base64content"}]}';
        Boolean result = ICS_CTRL_ApprovalFlow.uploadFile(validJson);
        
        Assert.areEqual(true, result, 'Method should return true for valid input');
    }
    
    @isTest
    static void testUploadFileBlank() {
        String blankInput = '';
        Boolean result = ICS_CTRL_ApprovalFlow.uploadFile(blankInput);
        
        Assert.areEqual(false, result, 'Method should return false for blank input');
        Assert.areNotEqual(true, result, 'Result should not be true for blank input');
    }
    
    @isTest
    static void testGetTables() {
        String result = ICS_CTRL_ApprovalFlow.getTables('Items to Approve');
        
        Assert.areNotEqual(null, result, 'Method should not return null');
    }
     
    @isTest
    static void testJsonGet() {
        String result = ICS_CTRL_ApprovalFlow.jsonGet('<start json string>{"key":"value"}<end json string>', 'key');
        
        Assert.areNotEqual(null, result, 'Method should not return null');
    }
     
    @isTest
    static void testUploadFileException() {
        String invalidJson = '{invalid json}';
        
        try {
            ICS_CTRL_ApprovalFlow.uploadFile(invalidJson);
        } catch (AuraHandledException e) {
            Assert.areNotEqual(null, e.getMessage(), 'Exception message should not be null');
        }
    }
     
  @isTest
    static void testdeleteRecord() {
        Test.startTest();
        Applicant testApplicant = [SELECT Id FROM Applicant LIMIT 1];
        Assert.areNotEqual(null, testApplicant, 'Test Applicant should exist');
        String result = ICS_CTRL_ApprovalFlow.deleteRecord(testApplicant.Id);
		Assert.areEqual('true', result, 'result should be true');
        Test.stopTest();
    }
     @isTest
    static void testCheckAndGetIds_Coverage() {
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
    
        Test.startTest();
    
        // Initialize dataObj via processFlowRequests, then call checkAndGetIds directly
        ICS_CTRL_ApprovalFlow.Input input = new ICS_CTRL_ApprovalFlow.Input();
        input.opportunityId = testOpportunity.Id;
        input.str = 'Check Queue Conditions';
        input.value = null;
    
        ICS_CTRL_ApprovalFlow.processFlowRequests(new ICS_CTRL_ApprovalFlow.Input[]{ input });
    
        String commonQueryPart = ICS_CTRL_ApprovalFlow.getConfig('Common') + '\n\n';
        String[] result = ICS_CTRL_ApprovalFlow.checkAndGetIds(commonQueryPart + ICS_CTRL_ApprovalFlow.getConfig('Group Sanctions Desk'));
    
        Assert.areNotEqual(null, result, 'checkAndGetIds should not return null');
        Assert.areEqual(2, result.size(), 'Should return String[] of size 2');
    
        Test.stopTest();
    }
     @isTest
    static void testSubList() {
        Test.startTest();
    
        String[] sample = new String[]{'a', 'b', 'c', 'd'};
        String[] r1 = ICS_CTRL_ApprovalFlow.subList(null, 0, 2);
        Assert.areEqual(0, r1.size(), 'null input should return empty list');
        String[] r2 = ICS_CTRL_ApprovalFlow.subList(new String[]{}, 0, 2);
        Assert.areEqual(0, r2.size(), 'empty input should return empty list');
        String[] r3 = ICS_CTRL_ApprovalFlow.subList(sample, -1, 2);
        Assert.areNotEqual(0, r3.size(), 'negative start should clamp to 0');
        String[] r4 = ICS_CTRL_ApprovalFlow.subList(sample, 0, 99);
        Assert.areEqual(4, r4.size(), 'oversized endIndex should clamp to list size');
        String[] r5 = ICS_CTRL_ApprovalFlow.subList(sample, 3, 1);
        Assert.areEqual(0, r5.size(), 'start >= endIndex should return empty');
        String[] r6 = ICS_CTRL_ApprovalFlow.subList(sample, 1, 2);
        Assert.areEqual(2, r6.size(), 'should return 2 elements');
        Assert.areEqual('b', r6[0], 'first element should be b');
    
        Test.stopTest();
    }
     @isTest
    static void testGroupSanctionsDesk() {
        Test.startTest();
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
    
        ICS_CTRL_ApprovalFlow.Input input = new ICS_CTRL_ApprovalFlow.Input();
        input.opportunityId = testOpportunity.Id;
        input.str = 'Group Sanctions Desk';
        input.value = null;
    
        List<String> result = ICS_CTRL_ApprovalFlow.processFlowRequests(
            new ICS_CTRL_ApprovalFlow.Input[]{ input }
        );
    
        Assert.areNotEqual(null, result, 'Result should not be null');
    
        // Also cover getLog path
        ICS_CTRL_ApprovalFlow.Input inputWithLog = new ICS_CTRL_ApprovalFlow.Input();
        inputWithLog.opportunityId = testOpportunity.Id;
        inputWithLog.str = 'Group Sanctions Desk getLog';
        inputWithLog.value = null;
    
        List<String> resultWithLog = ICS_CTRL_ApprovalFlow.processFlowRequests(
            new ICS_CTRL_ApprovalFlow.Input[]{ inputWithLog }
        );
    
        Assert.areNotEqual(null, resultWithLog, 'Result with log should not be null');
    
        Test.stopTest();
    }
      @isTest
    static void testSaveAssessmentDataOnHoldRevert() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        ApplicationForm appForm = [SELECT Id, Stage FROM ApplicationForm 
                                    WHERE AccountId = :testAccount.Id LIMIT 1];
    
        appForm.Stage = 'In Review';
        update appForm;
    
        appForm.Stage = 'On Hold';
        appForm.On_hold_reason__c = 'Challenging Risk Rating';
        update appForm;
    
        Test.startTest();
        String jsonString = '{'
            + '"name":"ICS UK Full Onboarding Component",'
            + '"pId":"' + testAccount.Id + '",'
            + '"OpportunityId":"' + testOpportunity.Id + '"'
            + '}';
        Boolean result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
        Assert.areEqual(true, result, 'Should return true');
        Test.stopTest();
    }
     @isTest
    static void testEvalQueueCodeCoverage() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        // Initialize dataObj
        ICS_CTRL_ApprovalFlow.Input initInput = new ICS_CTRL_ApprovalFlow.Input();
        initInput.opportunityId = opp.Id;
        initInput.str = 'Check Queue Conditions';
    
        ICS_CTRL_ApprovalFlow.processFlowRequests(
            new List<ICS_CTRL_ApprovalFlow.Input>{ initInput }
        );
        Test.startTest();
    
        ICS_CTRL_ApprovalFlow.Input input = new ICS_CTRL_ApprovalFlow.Input();
        input.opportunityId = opp.Id;
        // Must end with $
        input.value = 'FR.NCA$';
        List<ICS_CTRL_ApprovalFlow.Input> inputs =
            new List<ICS_CTRL_ApprovalFlow.Input>{ input };
        String commonQueryPart =
            ICS_CTRL_ApprovalFlow.getConfig('Common') + '\n\n';
        String[] result =
            ICS_CTRL_ApprovalFlow.evalQueueCode(inputs, commonQueryPart);
        Assert.areNotEqual(null, result);
        Assert.areNotEqual(null, result[0]);

        Test.stopTest();
    }

    @isTest
    static void testProcessFlowRequestsJsonGet() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        ICS_CTRL_ApprovalFlow.Input initInput = new ICS_CTRL_ApprovalFlow.Input();
        initInput.opportunityId = opp.Id;
        initInput.str = 'Check Queue Conditions';
        ICS_CTRL_ApprovalFlow.processFlowRequests(new List<ICS_CTRL_ApprovalFlow.Input>{ initInput });

        Test.startTest();
        ICS_CTRL_ApprovalFlow.Input input = new ICS_CTRL_ApprovalFlow.Input();
        input.opportunityId = opp.Id;
        input.str = 'jsonGet';
        input.value = 'key;<start json string>{"key":"value"}<end json string>';

        List<String> result = ICS_CTRL_ApprovalFlow.processFlowRequests(
            new List<ICS_CTRL_ApprovalFlow.Input>{ input }
        );

        Assert.areNotEqual(null, result, 'jsonGet result should not be null');
        Assert.areEqual('value', result[0], 'jsonGet should return value for the given key');
        Test.stopTest();
    }

    @isTest
    static void testSaveAssessmentDataRiskRatingChanged() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        String jsonString = '{'
            + '"Risk Rating Outcome":"Risk Rating Upgraded",'
            + '"name":"ICS UK Full Onboarding Component",'
            + '"pId":"' + testAccount.Id + '",'
            + '"OpportunityId":"' + testOpportunity.Id + '"'
            + '}';
        Boolean result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
        Assert.areEqual(true, result, 'Should return true for Risk Rating Upgraded');

        jsonString = '{'
            + '"Risk Rating Outcome":"Risk Rating Downgraded",'
            + '"name":"ICS UK Full Onboarding Component",'
            + '"pId":"' + testAccount.Id + '",'
            + '"OpportunityId":"' + testOpportunity.Id + '"'
            + '}';
        result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
        Assert.areEqual(true, result, 'Should return true for Risk Rating Downgraded');
        Test.stopTest();
    }

    @isTest
    static void testDeleteRecordBlankId() {
        Test.startTest();
        try {
            ICS_CTRL_ApprovalFlow.deleteRecord('');
            Assert.fail('Should have thrown AuraHandledException for blank id');
        } catch (AuraHandledException e) {
            Assert.areNotEqual(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteRecordNonDeletable() {
        User testUser = [SELECT Id FROM User WHERE IsActive = TRUE LIMIT 1];
        Test.startTest();
        try {
            ICS_CTRL_ApprovalFlow.deleteRecord(testUser.Id);
            Assert.fail('Should have thrown AuraHandledException for non-deletable object');
        } catch (AuraHandledException e) {
            Assert.areNotEqual(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
 }