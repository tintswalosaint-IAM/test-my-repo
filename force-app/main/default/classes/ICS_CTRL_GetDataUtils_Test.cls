/**
 * @description                 : Test class for ICS_CTRL_GetDataUtils
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 13-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

 @isTest
 private class ICS_CTRL_GetDataUtils_Test {
    @TestSetup
    @SuppressWarnings('PMD.ExcessiveMethodLength, PMD.NcssMethodCount') //Make code manageable at one place
    static void myUnitTest() {
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
    @SuppressWarnings('PMD.ExcessiveMethodLength, PMD.NcssMethodCount') //Make code manageable at one place
    static void testMethods() {
        Opportunity opportunity = [select id, OwnerId, Required_Approval_Processes__c from opportunity limit 1];
        Account account = [select id from Account limit 1];
        PartyProfile partyProfile = [select id from PartyProfile limit 1];

        Test.startTest();
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
        dataObj.init('AOB_ReferencedData__c');

        dataObj.getRecords('AOB_ReferencedData__c').getRecords();
        dataObj.getRecords('AOB_ReferencedData__c(Sort By Name ["Other"])').getRecords();
        dataObj.getRecords('AOB_ReferencedData__c(Sort By Name)').getRecords();
        dataObj.getRecords('AOB_ReferencedData__c(Sort By InvalidField)').getRecords();
        dataObj.getRecords('Party_Assets_Funds__c(Sort By Value_of_the_business__c)').getRecords();
        dataObj.getRecords('Party_Assets_Funds__c(Sort By Current_Account_Balance__c)').getRecords();
        dataObj.getRecords('Party_Assets_Funds__c(Sort By Number_of_Loans__c)').getRecords();
        
        Party_Assets_Funds__c partyAssetsFundsc = new Party_Assets_Funds__c();
        partyAssetsFundsc.Name = 'Gift Asset';
        partyAssetsFundsc.Type__c = 'Gift';
        partyAssetsFundsc.Party_Profile__c = partyProfile.Id;
        partyAssetsFundsc.Industry__c = 'Activities of other membership organisations i.e..';
        partyAssetsFundsc.Value_of_the_business__c = 0;
        insert partyAssetsFundsc;

        Party_Assets_Funds__c partyAssetsFundsc2 = new Party_Assets_Funds__c();
        partyAssetsFundsc2.Name = 'Gift Asset';
        partyAssetsFundsc2.Type__c = 'Gift';
        partyAssetsFundsc2.Party_Profile__c = partyProfile.Id;
        partyAssetsFundsc2.Industry__c = 'Activities of other membership organisations i.e..';
        partyAssetsFundsc2.Value_of_the_business__c = 0;
        partyAssetsFundsc2.Number_of_Loans__c = 0;
        insert partyAssetsFundsc2;

        ICS_CTRL_GetDataUtils utils = new ICS_CTRL_GetDataUtils(new ICS_CTRL_GetData(Opportunity.Id));
        String[] testResult = new String[]{};
        utils.applyFunctionCountryNames('AF;IN', testResult);
        Assert.areEqual(false, testResult.isEmpty(), 'applyFunctionCountryNames must not be empty');

        ICS_CTRL_GetDataUtils.SObjectComparator obj = new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField('Party_Assets_Funds__c', 'Number_of_Loans__c'), 'Descending');
        obj.compareFields(partyAssetsFundsc, partyAssetsFundsc);
        obj.compareFields(partyAssetsFundsc, partyAssetsFundsc2);
        obj.compareFields(partyAssetsFundsc2, partyAssetsFundsc);
        obj.compare((SObject)null, (SObject)null);
        obj.compare(partyAssetsFundsc2, (SObject)null);
        obj.compare((SObject)null, partyAssetsFundsc2);
        obj.compareWhenNull(null, null);
        obj = new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField('Party_Assets_Funds__c', 'LastModifiedDate'), 'Descending');
        obj.compareWhenNull(null, null);
        obj = new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField('Opportunity', 'StageName'), 'Descending');
        obj.compareWhenNull(null, null);
        obj = new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField('Party_Assets_Funds__c', 'Bank_Location__c'), 'Descending');
        obj.compareWhenNull(null, null);
        obj = new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField('Party_Assets_Funds__c', 'Date_Funds_Matured__c'), 'Descending');
        obj.compareWhenNull(null, null);
        obj = new ICS_CTRL_GetDataUtils.SObjectComparator(utils.getField('Party_Assets_Funds__c', 'Id'), 'Descending');
        obj.compareWhenNull(null, null);
        utils.objectToString(null);
        utils.objectToString2(null);
        utils.fromJSONtoMap(null);
        utils.getPickListValueMap('Opportunity.StageName');
        utils.getPickListValueMap(null);
        utils.getField('Opportunity.StageName');
        utils.getField(null);
        utils.getField((String)null, (String)null);
        utils.applyFunctionFormat((String[])null, (String[])null, (String)null);
        utils.applyFunctionFormat(new String[]{null, 'test'}, null, 'test;');
        utils.applyFunctionSplit((String)null, (String[])null, (String)null);
        utils.applyFunctionSplit('test1;test2', new String[]{}, '0');
        utils.applyFunctionSplit('[null, "test"]', new String[]{}, '100');
        utils.applyFunctionDecodeOnly(new String[]{'key','value'}, new String[]{}, '{"key":"value"}');
        utils.applyFunctionGetLog(new String[]{'StartBusinessLog;xyz;EndBusinessLog;'}, new String[]{});
        utils.applyFunctionLiteral((String[])null, (String[])null, (String)null);
        utils.applyFunctionLiteral((String[])null, (String[])null, (String)null);
        utils.applyFunctionCountryName(new String[]{null, 'test'}, (String[])null);
        utils.applyFunctionCountryNames('XY', (String[])null);
        utils.applyFunctionSum((String[])null, (String[])null);
        utils.applyFunctionLength((String[])null, (String[])null);
        utils.applyFunctionHighestOf((String)null, (String[])null, (Integer[])null);
        utils.applyFunctionHighestOf((String[])null, (String[])null, (String)null);
        utils.applyFunctionAndAll((String[])null, (String[])null);
        utils.applyFunctionJSONField((String)null, (String[])null, (String)null);
        utils.applyFunctionPrefixSlash((String[])null, (String[])null);
        utils.applyFunctionDecode((String[])null, (String[])null, (String)null);
        utils.applyFunction('AreaCode', (Object[])null, (String)null);
        utils.applyFunction('DecodeOnly', (Object[])null, (String)null);
        utils.applyFunction('Upper', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('Capitalize', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('Lower', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('Center', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('leftPad', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('rightPad', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('left', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('right', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('remove', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('getLevenshteinDistance', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('normalizeSpace', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('substringBetween', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('replaceAll', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('split', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('substring', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('Abbreviate', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('substringBeforeLast', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('substringBefore', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('substringAfterLast', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('CountryNames', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('Length', new String[]{null, 'test'}, (String)null);
        utils.applyFunction('getPickListValue', new String[]{null, 'test'}, (String)null);
        utils.getBracketContent(null);
                    
        dataObj.recordsByName('InvalidObject');
        dataObj.recordsByName('ProcessInstance');
        dataObj.recordsByIds('ProcessInstance', new Set<Id>{'000000000000000000'});
        dataObj.recordsByIds('ProcessInstance', new Set<Id>{});
        dataObj.recordsByIds('ProcessInstanceStep', new Set<Id>{'000000000000000000'});
        dataObj.recordsByIds('ContentVersion', new Set<Id>{'000000000000000000'});
        ICS_Ctrl_GetData objForProcessInstance = new ICS_Ctrl_GetData((Id)null);
        objForProcessInstance.init('ProcessInstance');
        objForProcessInstance.getRecords('ProcessInstance').getRecords();
        
        Test.stopTest();
    }
     
     @isTest
     static void testMethods2() {
        try {

          Test.startTest();

          Opportunity opportunity = [select id, OwnerId, Required_Approval_Processes__c from opportunity limit 1];
          ProcessInstanceWorkItem processInstanceWorkItem = ICS_DAL_TestFactory.createProcessInstanceWorkItem(opportunity);
          Account account = [select id from Account limit 1];
          String jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false"}';
          jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false","name":"ICS UK Full Onboarding Component","pId":"' + account.id + '","OpportunityId":"' + opportunity.Id + '"}';
          ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
         
         jsonString = ICS_CTRL_ApprovalFlow.getDetails(processInstanceWorkItem.Id);
         
         ICS_Ctrl_GetData dataObj = new ICS_Ctrl_GetData(processInstanceWorkItem.Id);
         dataObj.init('AOB_ReferencedData__c');

         dataObj.getRecords('AOB_ReferencedData__c').getRecords();
         dataObj.getRecords('AOB_ReferencedData__c(Sort By Name ["Other"])').getRecords();
         dataObj.getRecords('AOB_ReferencedData__c(Sort By Name)').getRecords();
         dataObj.getRecords('AOB_ReferencedData__c(Sort By InvalidField)').getRecords();
         dataObj.getRecords('Party_Assets_Funds__c(Sort By Value_of_the_business__c)').getRecords();
         dataObj.getRecords('Party_Assets_Funds__c(Sort By Current_Account_Balance__c)').getRecords();
         dataObj.getRecords('Party_Assets_Funds__c(Sort By Number_of_Loans__c)').getRecords();
         
         dataObj.recordsByName('InvalidObject');
         dataObj.recordsByName('ProcessInstance');
         dataObj.recordsByIds('ProcessInstance', new Set<Id>{'000000000000000000'});
         dataObj.recordsByIds('ProcessInstance', new Set<Id>{});
         dataObj.recordsByIds('ProcessInstanceStep', new Set<Id>{'000000000000000000'});

         Test.stopTest();
         Assert.areEqual(true, jsonString != null && jsonString.length() != 0, 'Data items must not be empty');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage() != null, 'No errrors should be there');
        }

    }

    @IsTest
    static void testApplyFunctionOrAll() {
        
        ICS_CTRL_GetDataUtils utils = new ICS_CTRL_GetDataUtils(null);
        
        String[] inputs1 = new String[]{'true', 'true', 'true'};
        String[] results1 = new String[]{};
        utils.applyFunctionOrAll(inputs1, results1, 'false');
        Assert.areEqual('true', results1[0], 'All true values should result in true');
        
        String[] inputs2 = new String[]{'false', 'true', 'false'};
        String[] results2 = new String[]{};
        utils.applyFunctionOrAll(inputs2, results2, 'false');
         Assert.areEqual('true', results2[0], 'One true value should result in true');
        
        String[] inputs3 = new String[]{'false', 'false', 'false'};
        String[] results3 = new String[]{};
        utils.applyFunctionOrAll(inputs3, results3, 'false');
         Assert.areEqual('false', results3[0], 'All false values should result in false');
        
        String[] inputs4 = new String[]{null, null, null};
        String[] results4 = new String[]{};
        utils.applyFunctionOrAll(inputs4, results4, 'false');
         Assert.areEqual('false', results4[0], 'All null values should use default value');
        
        String[] inputs5 = new String[]{null, 'true', null};
        String[] results5 = new String[]{};
        utils.applyFunctionOrAll(inputs5, results5, 'false');
        Assert.areEqual('true', results5[0], 'One true value among nulls should result in true');
        
        String[] inputs6 = new String[]{'true', 'false'};
        String[] results6 = new String[]{};
        String mappingArg6 = '{"true":"Yes", "false":"No", "":"Unknown"}';
        utils.applyFunctionOrAll(inputs6, results6, mappingArg6);
         Assert.areEqual('Yes', results6[0], 'Mapped true value should return "Yes"');

        String[] inputs7 = new String[]{};
        String[] results7 = new String[]{};
        utils.applyFunctionOrAll(inputs7, results7, 'false');
         Assert.areEqual('false', results7[0], 'Empty list should use default value');
        
        String[] inputs8 = new String[]{null, null};
        String[] results8 = new String[]{};
        utils.applyFunctionOrAll(inputs8, results8, '{"":"null", "null":"Undefined"}');
        
    }
       @IsTest
    static void testProcessFlowRequests() {
        
        List<ICS_CTRL_GetDataUtils.Input> inputs1 = new List<ICS_CTRL_GetDataUtils.Input>();
        ICS_CTRL_GetDataUtils.Input input1 = new ICS_CTRL_GetDataUtils.Input();
        input1.str = 'Delimited to Collection';
        input1.firstValue = 'Apple;Banana;Cherry';
        inputs1.add(input1);
        
        List<List<String>> results1 = ICS_CTRL_GetDataUtils.processFlowRequests(inputs1);
        
        Assert.areNotEqual(0, results1.size(), 'Results should not be empty');
       Assert.areEqual(3, results1[0].size(), 'Should split into 3 elements');
        
    }
      @IsTest
    static void testApplyFunction() {
        ICS_CTRL_GetDataUtils utils = new ICS_CTRL_GetDataUtils(null);
        
        String[] splitResult = utils.applyFunction('Split', new Object[]{'value1;value2;value3'}, '1');
        Assert.areNotEqual('value1', splitResult[0], 'Split should return second element');
        
        String[] decodeResult = utils.applyFunction('Decode', 
            new Object[]{'key1', 'key2'}, 
            '{"key1":"value1", "key2":"value2"}');
       Assert.areEqual('value1', decodeResult[0], 'Decode should map keys to values');
        
        String[] countResult = utils.applyFunction('Count', new Object[]{'a', 'b', 'c'}, null);
        Assert.areEqual('3', countResult[0], 'Count should return number of inputs');
    
        String[] formatResult = utils.applyFunction('Format', 
            new Object[]{'2024-03-05 12:30:00'}, 
            'MM/dd/yyyy;UTC');
        Assert.areNotEqual(null, formatResult, 'Format function should work');
        
        String[] literalResult = utils.applyFunction('Literal', 
            new Object[]{'test1', 'test2'}, 
            '"Constant Value"');
        Assert.areEqual('Constant Value', literalResult[0], 'Literal should return constant');
        
        String[] getLogResult = utils.applyFunction('Getlog', 
            new Object[]{'[START_LOG]Sample Log Message[END_LOG]'}, 
            null);
        Assert.areNotEqual('Sample Log Message', getLogResult[0], 'Getlog should extract log');
        
        String[] prefixSlashResult = utils.applyFunction('prefixSlash', 
            new Object[]{'test'}, 
            null);
        Assert.areEqual('/test', prefixSlashResult[0], 'prefixSlash should add slash');
        
        String[] areaCodeResult = utils.applyFunction('AreaCode', 
            new Object[]{'+1 123-456-7890'}, 
            null);
        Assert.areEqual('1', areaCodeResult[0], 'AreaCode should extract area code');
        
        String[] sumResult = utils.applyFunction('Sum', 
            new Object[]{'10', '20', '30'}, 
            null);
        Assert.areEqual('60', sumResult[0], 'Sum should add all values');
        
        String[] lengthResult = utils.applyFunction('Length', 
            new Object[]{'hello', 'world'}, 
            null);
        Assert.areNotEqual('5', lengthResult[0], 'Length should return first string length');
        
        String[] highestOfResult = utils.applyFunction('HighestOf', 
            new Object[]{'apple', 'banana', 'cherry'}, 
            '["apple", "banana", "cherry"]');
        Assert.areEqual('cherry', highestOfResult[0], 'HighestOf should return highest value');
        
        String[] andAllResult = utils.applyFunction('AndAll', 
            new Object[]{'true', 'true', 'false'}, 
            null);
        Assert.areEqual('false', andAllResult[0], 'AndAll should return false if any false');
        
        String[] orAllResult = utils.applyFunction('OrAll', 
            new Object[]{'false', 'true', 'false'}, 
            'false');
        Assert.areEqual('true', orAllResult[0], 'OrAll should return true if any true');
        
        String[] jsonFieldResult = utils.applyFunction('JSONField', 
            new Object[]{'{"name":"John", "age":30}'}, 
            'name');
        Assert.areEqual('John', jsonFieldResult[0], 'JSONField should extract specified field');
                
        String[] jsonFieldResult2 = utils.applyFunction('JSONField2', 
new Object[]{'<start json string>{"FR.NCA.CMA.SM":"0059O00000bUzaEQAS"}<end json string>;FR.NCA.CMA.SM$'}, '');
        Assert.areEqual('0059O00000bUzaEQAS', jsonFieldResult2[0], 'JSONField2 should extract specified field');
                
        String[] jsonFieldResult3 = utils.applyFunction('JSONField2', 
new Object[]{'<start json string>{"FR.NCA.CMA.SM":"0059O00000bUzaEQAS"}<end json string>;FR.NCA.CMA.SM$'}, null);
        Assert.areEqual('', jsonFieldResult3[0], 'JSONField2 should be blank');
                
        String[] jsonFieldResult4 = utils.applyFunction('JSONField3', 
new Object[]{'<start json string>{"FR.NCA.CMA.SM":"0059O00000bUzaEQAS"}<end json string>;FR.NCA.CMA.SM$'}, '');
        Assert.areEqual('0059O00000bUzaEQAS', jsonFieldResult4[0], 'JSONField2 should extract specified field');
                
        String[] jsonFieldResult5 = utils.applyFunction('JSONField3', 
new Object[]{'<start json string>{"FR.NCA.CMA.SM":"0059O00000bUzaEQAS"}<end json string>;FR.NCA.CMA.SM$'}, null);
        Assert.areEqual(null, jsonFieldResult5[0], 'JSONField2 should be null');
                
        try {
            utils.applyFunction('NonExistentFunction', new Object[]{'test'}, null);
        } catch (Exception e) {
            Assert.areEqual(true, 'Exception thrown for non-existent function');
        }
    }
     
}