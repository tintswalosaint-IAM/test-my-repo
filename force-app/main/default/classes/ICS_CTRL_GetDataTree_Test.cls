/**
 * @description                 : Test class for ICS_CTRL_GetDataTree
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 03-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Updated
 */

 @isTest 
 private class ICS_CTRL_GetDataTree_Test { 
    @TestSetup
    @SuppressWarnings('PMD.ExcessiveMethodLength, PMD.NcssMethodCount') //Make code manageable at one place
    static void myUnitTest() {
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
    }

    @istest
    @SuppressWarnings('PMD.ExcessiveMethodLength, PMD.NcssMethodCount') //Make code manageable at one place
    static void testMethods() {

        Test.startTest();
        Opportunity opportunity = [select Id, OwnerId, Required_Approval_Processes__c from Opportunity limit 1];
        List<Account> accounts = [select Id from account limit 1];
        Account account = accounts[0];

        ProcessInstanceWorkItem processInstanceWorkItem = ICS_DAL_TestFactory.createProcessInstanceWorkItem(opportunity);

        String jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false"}';
        Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(JSONString, Map<String,String>.class);
        List<AssessmentQuestion> assessmentQuestions = new List<AssessmentQuestion>();
        for(String key: jsonData.keySet()) {
            AssessmentQuestion assessmentQuestion = new AssessmentQuestion();
            assessmentQuestion.Name = key;
            assessmentQuestion.DeveloperName = ICS_CTRL_ApprovalFlow.getDeveloperName(key);
            assessmentQuestion.DataType = 'Text';
            assessmentQuestion.QuestionCategory = 'Demographic';
            assessmentQuestions.add(assessmentQuestion);
        }
        insert assessmentQuestions;

        List<AssessmentQuestionVersion> assessmentQuestionVersions = new List<AssessmentQuestionVersion>();
        for(AssessmentQuestion assessmentQuestion : assessmentQuestions) {
            AssessmentQuestionVersion assessmentQuestionVersion = new AssessmentQuestionVersion(assessmentQuestionId=assessmentQuestion.Id, Questiontext=assessmentQuestion.Name, Name='Application Issues', isActive=True);
            assessmentQuestionVersions.add(assessmentQuestionVersion);
        }
        insert assessmentQuestionVersions;

        jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false","name":"ICS UK Full Onboarding Component","pId":"' + account.id + '","OpportunityId":"' + opportunity.Id + '"}';
        ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);

        ICS_Ctrl_GetData dataObj = new ICS_Ctrl_GetData(processInstanceWorkItem.Id);
        
        dataObj.getRecords('Opportunity.ApplicationForm.Applicant.<ApplicationForm').getRecords();
        dataObj.getRecords('Opportunity.ApplicationForm.Applicant.<InvalidObject').getRecords();
        
        ICS_CTRL_GetDataTree dataTree = new ICS_CTRL_GetDataTree();
        ICS_CTRL_GetDataTree.Node node = new ICS_CTRL_GetDataTree.Node();

        node.getLinkedNodes('InvalidObject');
        dataTree.getType((SObject)null);
        dataTree.addNodes((Id)null, (SObject[])null, (String)null);
        dataTree.register((ICS_CTRL_GetDataTree.Node)null);

        SObject sObject1 = [select Id, OwnerId, Required_Approval_Processes__c from Opportunity limit 1];
        dataTree.getType(sObject1);

        
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        TaxDetails__c existingTaxDetail = new TaxDetails__c(
            Account__c = account.Id,
            TIN_IN_Number__c = '111111111',
            Country__c = 'US'
        );
        insert existingTaxDetail;
                        
        ProcessInstanceWorkItem piw = new SEL_ProcessInstanceWorkItem().selectById(processInstanceWorkItem.Id);
        new SEL_ProcessInstanceWorkItem().selectByTargetObjectId(opportunity.Id);
        new SEL_ProcessInstanceWorkItem().selectByIds(new Set<Id>{processInstanceWorkItem.Id});
        new SEL_ProcessInstanceWorkItem().selectByProcessInstanceIds(new Set<Id>{piw.ProcessInstanceId});
        
        new SEL_ProcessInstance().selectById(piw.ProcessInstanceId);
        new SEL_ProcessInstance().selectByIds(new Set<Id>{piw.ProcessInstanceId});
        
        ProcessInstanceStep pis = [Select Id from ProcessInstanceStep where ProcessInstanceId = :piw.ProcessInstanceId];
        new SEL_ProcessInstanceStep().selectById(pis.Id);
        new SEL_ProcessInstanceStep().selectByIds(new Set<Id>{pis.Id});
        
        new SEL_AssessmentQuestion().selectById(assessmentQuestions[0].Id);
        new SEL_AssessmentQuestion().selectByIds(new Set<Id>{assessmentQuestions[0].Id});
		new SEL_AssessmentQuestionVersion().selectById(assessmentQuestionVersions[0].Id);
        new SEL_AssessmentQuestionVersion().selectByIds(new Set<Id>{assessmentQuestionVersions[0].Id});
        
        new SEL_ApplicationFormProduct().getSObjectFieldList();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id,ContentDocumentId,VersionData  FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = opportunity.Id;
        insert cdl;
        
        new SEL_ContentDocumentLink().selectByLinkedEntity(new Set<Id>{opportunity.Id});
        new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(opportunity.Id);

        PartyProfile partyProfile = [select id from PartyProfile limit 1];
        new SEL_PartyProfileRisk().selectById(partyProfile.Id);
        String objectType = dataTree.getType(partyProfile);
        dataTree.getType((Id)'000000000000000000');

        Test.stopTest();
        Assert.areEqual('Opportunity', dataTree.getType(sObject1), 'objectType should be Opportunity');
        Assert.areEqual('PartyProfile', objectType, 'objectType should be PartyProfile');
        Assert.areEqual(null, dataTree.getType((Id)null), 'Get type for null should return null');

    }

 }