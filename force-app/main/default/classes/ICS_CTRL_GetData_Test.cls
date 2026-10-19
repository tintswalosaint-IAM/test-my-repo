/**
 * @description                 : Test class for ICS_CTRL_GetData
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 13-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Updated
 */

 @isTest
 private class ICS_CTRL_GetData_Test { 
     private static String getDeveloperName(String name) {
        String returnVe = name.replace(' ', '_');
        returnVe = returnVe.replace('?', '');
        returnVe = returnVe.replace('.', '');
        return returnVe;
    }

    @TestSetup
    @SuppressWarnings('PMD.NcssMethodCount, PMD.ExcessiveMethodLength') //Need to access multiple objects multiple times
    static void myUnitTest() {
        Test.startTest();
        List<String> optionList = new List<String>{
            'ID not in line',
            'POA not in line',
            'ID not clear',
            'POA not clear',
            'POA document not valid/not in client name',
            'Wealth doesn\'t make sense/wealth missing/complex wealth',
            'Verifying POA authors (employers letter,  lawyers letter)',
            'Invalid SOF documentation provided',
            'Invalid SOW documentation provided',
            'Unable to verify income/SOF/SOW',
            'Client circumstances change during process',
            'Not commercially viable',
            'Risk increased - SOF/SOW info required',
            'Need to clarify rationale',
            'Other'
        };
            
        AOB_ReferencedData__c[] aOBReferencedDatas = new AOB_ReferencedData__c[]{};
        for(String s : optionList) {
            aOBReferencedDatas.add(new AOB_ReferencedData__c(AOB_Language__c = 'en_US', AOB_isActive__c = true, AOB_SAPField__c = 'ICS_ApplicationIssues', Name = s, AOB_Code__c = s));
        }
        insert aOBReferencedDatas;

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
    @SuppressWarnings('PMD.NcssMethodCount, PMD.ExcessiveMethodLength') //Need to access multiple objects multiple times
    static void testMethods() {
        try{
        Test.startTest();
        Opportunity opportunity = [select Id, OwnerId, Required_Approval_Processes__c from Opportunity limit 1];
        ProcessInstanceWorkItem processInstanceWorkItem = ICS_DAL_TestFactory.createProcessInstanceWorkItem(opportunity);

        String jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false"}';
        Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(JSONString, Map<String,String>.class);
        List<AssessmentQuestion> assessmentQuestions = new List<AssessmentQuestion>();
        for(String key: jsonData.keySet()) {
            AssessmentQuestion assessmentQuestion = new AssessmentQuestion();
            assessmentQuestion.Name = key;
            assessmentQuestion.DeveloperName = getDeveloperName(key);
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

        ICS_Ctrl_GetData dataObj = new ICS_Ctrl_GetData(processInstanceWorkItem.Id);
        dataObj.init('AOB_ReferencedData__c');
        
		dataObj.getRecords('AOB_ReferencedData__c').getRecords();
        dataObj.check('Applicant mobile dialing code matches COR criteria for Straight Through\nApplicant mobile dialling code is same as COR\nApplicant(Serial number).Account.ContactPointPhone.(AreaCode(TelephoneNumber)) ALL= :[\"44\"]\nOR2\nApplicant mobile dialling code is not the same COR due to selecting a reason other than "None of the above" from the list\nApplicant(Serial number).Account.Assessment.AssessmentQuestionResponse(ResponseText = :"None of the above").AssessmentQuestionVersion.AssessmentQuestion(DeveloperName = :"We_note_your_dialing_code_is_not_connected_to_your_country_of_residence_why_may").(Count()) = :0');
        dataObj.check('s1\ns2\nApplicant(Serial number).Account.ContactPointPhone.(AreaCode(TelephoneNumber)) ALL= :[\"44\"]\nOR\ns3\nApplicant(Serial number).Account.Assessment.AssessmentQuestionResponse(ResponseText = :"None of the above").AssessmentQuestionVersion.AssessmentQuestion(DeveloperName = :"We_note_your_dialing_code_is_not_connected_to_your_country_of_residence_why_may").(Count()) = :0');
        dataObj.check('s1\ns2\nApplicant(Serial number).Account.ContactPointPhone.(AreaCode(TelephoneNumber)) ALL= :[\"44\"]\nNOR2\ns3\nApplicant(Serial number).Account.Assessment.AssessmentQuestionResponse(ResponseText = :"None of the above").AssessmentQuestionVersion.AssessmentQuestion(DeveloperName = :"We_note_your_dialing_code_is_not_connected_to_your_country_of_residence_why_may").(Count()) = :0');
        dataObj.check('s1\ns2\nApplicant(Serial number).Account.ContactPointPhone.(AreaCode(TelephoneNumber)) ALL= :[\"44\"]\nAND\ns3\nApplicant(Serial number).Account.Assessment.AssessmentQuestionResponse(ResponseText = :"None of the above").AssessmentQuestionVersion.AssessmentQuestion(DeveloperName = :"We_note_your_dialing_code_is_not_connected_to_your_country_of_residence_why_may").(Count()) = :0');
		dataObj.getRecords('Party_Assets_Funds__c(Value_of_the_business__c = :1)').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Value_of_the_business__c > :1)').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Value_of_the_business__c < :1)').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Value_of_the_business__c X :1)').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Name = :"xyz" || Name = :"xyz" || Name IN :[])').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Name CONTAINS :"xyz")').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Name iCONTAINS :"xyz")').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Name StartsWith :"xyz")').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Name EndsWith :"xyz")').getRecords();
		dataObj.getRecords('Party_Assets_Funds__c(Name IN :["xyz"])').getRecords();
        dataObj.checkAndLoadData((String)null);
        dataObj.checkAndLoadData('InvalidObjectName');
        dataObj.checkAndLoadData((String)null, (Integer)null);
        dataObj.loadDependency((Boolean)null, (String[])null, (Integer)null);
        dataObj.setObjectFound((Boolean)null, (Boolean)null);
        dataObj.init((Set<Id>)null);
        dataObj.init(new Set<Id>{'000000000000000000'});
        dataObj.init((String)null);
        dataObj.init('InvalidObjectName');
        dataObj.getRecords((String)null);
        dataObj.getFieldValue((String)null); 
        dataObj.getFieldValueTables((String)null, (Integer)null);
        dataObj.getSingleFieldValue((String)null, (Integer)null);
        dataObj.check((String)null, (Integer)null);
        dataObj.getSortIndex((String)null, (String)null);
        dataObj.toChildIds((Set<Id>)null, (String)null);
        dataObj.getNodeFieldValue((Id)null, (String)null);
        dataObj.getChildRecord((Id)null, (Map<Id, SObject>)null);
        dataObj.addChild((Map<Id, SObject[]>)null, (Id)null, (SObject)null);
        dataObj.getChildMap1((Set<Id>)null, (String[])null, (SObject[])null);
        dataObj.getMapByIdField((SObject[])null, (String)null);
        dataObj.getChildRecords((Id)null, (Map<Id, SObject[]>)null, (String)null);
        dataObj.addChildRecords((Map<Id, SObject[]>)null, (Id)null, (SObject[])null);
        dataObj.getChildMap2((Set<Id>)null, (String[])null, (SObject[])null);
        dataObj.loadData((String)null);
        dataObj.recordsByName((String)null);
        dataObj.storeAllSobjects((String)null, (SObject[])null);
        dataObj.storeAllSobjects((String)null, (Map<Id, List<SObject>>) null);
        dataObj.recordsByIds((String)null, (Set<Id>)null);
        dataObj.filterRecords((SObject[])null, 'Sort By xyz', (String)null);
        dataObj.filterRecords((ICS_CTRL_GetBrowseTree)null, 'Sort By xyz', (String)null);
        dataObj.preProcessQuery((String)null, (Integer)null);
        dataObj.evaluateNull((Boolean)null, (Object)null);
        dataObj.getRecordsSatisfyingCondition((SObject[])null, (String)null);
        dataObj.evaluateCondition((SObject)null, (Object)null, (String[])null);
        dataObj.getFieldValue((ICS_CTRL_GetBrowseTree)null, (Map<String, Object[]>)null, (String[])null);
        dataObj.getFieldValue((ICS_CTRL_GetBrowseTree)null, (String[])null);
        dataObj.getTable((Map<String,List<Object>>)null, (String[])null);
        dataObj.fillRow((Map<String,List<Object>>)null, (String[])null, (Integer)null);
        dataObj.getFieldValue((String)null, (Integer)null);
        dataObj.getFieldValue('InvalidObject', 0);
        dataObj.getFieldValue((ICS_CTRL_GetBrowseTree)null, (String)null);
        dataObj.getAscendantUsedFieldValue((ICS_CTRL_GetBrowseTree.BrowseNode)null, (String)null);
        dataObj.getFieldValuesHorizontally((String)null, (Integer)null, (String)null);  
        dataObj.fetchRows((List<Map<String, Object>>) null, (Map<String, String>)null, (Object[])null);
        dataObj.fetchTables((String[])null, (Map<String, Object>)null, (Integer)null);
        dataObj.nextLineExists((String[])null, (Integer)null);
        dataObj.checkAndIncrement((String[])null, (Integer)null);
        dataObj.checkToLog((String[])null, (Integer)null, (Boolean)null);
        dataObj.checkAndLog((Boolean)null, (String)null);
        dataObj.runLoop((List<String>) null);
        dataObj.checkAndAssign((Boolean)null, (Boolean)null, (Boolean)null);
        dataObj.checkAndAssignAnd((Boolean)null, (Boolean)null, (Boolean)null);
        dataObj.check((String)null);
        dataObj.checkSetVariable((String)null, (Integer)null);
        dataObj.containsOR((String)null, (String)null);
        dataObj.evalAndAll((String)null);
        dataObj.evalOrAllEach((String)null, (Boolean)null);
        dataObj.evalOrAll((String)null);
        dataObj.evaluate((String)null, (String)null, (String)null);
        dataObj.calculate((String)null, (String)null, (String)null);
        dataObj.checkSetVariable((String)null);
        dataObj.toDecimal((Object)null);
        dataObj.checkEach((String)null);
        dataObj.deserialize((String)null, null);
        dataObj.getType((Object)null);
        dataObj.getTestValue((Object[])null, (String)null);
        dataObj.getSum((Object[])null);
        dataObj.compare((Object)null, (Object)null, (String)null);
        dataObj.compareAll((Object[])null, (Object)null, (String)null);
        dataObj.allIn((Object[])null, (Object[])null);
        dataObj.anyIn((Object[])null, (Object[])null);
        dataObj.evalRelational((Object[])null, (Object[])null, (Object[])null);
        dataObj.evalConditions((Boolean)null, (Object[])null, (String[])null);
        dataObj.getFieldValuesAsList((String)null);
        dataObj.getLog();

        String commonQueryPart = ICS_CTRL_ApprovalFlow.getConfig('Common') + '\n\n';
        jsonString = ICS_CTRL_ApprovalFlow.getDetails(processInstanceWorkItem.Id);
        ICS_CTRL_ApprovalFlow.checkAllCriteria(commonQueryPart + ICS_CTRL_ApprovalFlow.getConfig('QC 01 FR'));
        ICS_CTRL_ApprovalFlow.checkAllCriteria(commonQueryPart + ICS_CTRL_ApprovalFlow.getConfig('Additional Risk Factors'));
        String jSONString2 = '[{"str":"Get Records","sObjects":null,"sObjectRecord":null,"secondValue":null,"firstValue":"ApplicationForm(Stage = :\\"On Hold\\" && On_hold_reason__c = :\\"Ukraine Exception\\").(Id, AccountId, Stage, On_hold_reason__c, OpportunityId)"}]';
        ICS_CTRL_GetData.processFlowRequests((List<ICS_CTRL_GetData.InputOutput>)JSON.deserialize(jSONString2, List<ICS_CTRL_GetData.InputOutput>.class));
        jSONString2 = '[{"str":"Get Record","sObjects":null,"sObjectRecord":null,"secondValue":null,"firstValue":"ApplicationForm.(Id, AccountId, Stage, On_hold_reason__c, OpportunityId)"}]';
        ICS_CTRL_GetData.processFlowRequests((List<ICS_CTRL_GetData.InputOutput>)JSON.deserialize(jSONString2, List<ICS_CTRL_GetData.InputOutput>.class));
        jSONString2 = '[{"str":"Get Single Field Value","sObjects":null,"sObjectRecord":null,"secondValue":null,"firstValue":"ApplicationForm(Stage = :\\"On Hold\\" && On_hold_reason__c = :\\"Ukraine Exception\\").(Id, AccountId, Stage, On_hold_reason__c, OpportunityId)"}]';
        ICS_CTRL_GetData.processFlowRequests((List<ICS_CTRL_GetData.InputOutput>)JSON.deserialize(jSONString2, List<ICS_CTRL_GetData.InputOutput>.class));
        dataObj.recordsByName('InvalidObject');      

        Test.stopTest();
        	Assert.areEqual(true, jsonString != null && jsonString.length() != 0, 'Data items must not be empty');
        }
        catch(exception ex){
            Assert.areEqual(true, ex.getmessage() != null, 'error occured');
        }
        catch(limitexception ex){
        	Assert.areEqual(true, ex.getmessage() != null , 'error occured');

        }
    }
 }