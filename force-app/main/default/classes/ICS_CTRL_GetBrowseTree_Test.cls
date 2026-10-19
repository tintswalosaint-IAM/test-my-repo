/**
 * @description                 : Test class for ICS_CTRL_GetBrowseTree
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 03-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Updated
 */

 @isTest
 private class ICS_CTRL_GetBrowseTree_Test {
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
    static void myUnitTest() {
        Test.startTest();
        Id processInstanceId = [select id from ProcessInstance limit 1].Id;
        Assert.areNotEqual(null, processInstanceId, 'ProcessInstance should not be null');

        Account testAccount = [select id from Account limit 1];
        Opportunity testOpportunity = [select id from Opportunity limit 1];

        String jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false","name":"ICS UK Full Onboarding Component","pId":"' + testAccount.Id + '","OpportunityId":"' + testOpportunity.Id + '"}';
        Boolean result = ICS_CTRL_ApprovalFlow.saveAssessmentData(jsonString);
        Assert.areEqual(true, result, 'Assessment data could not be saved');

        ICS_Ctrl_GetData dataObj = new ICS_Ctrl_GetData(processInstanceId);
        Assert.areNotEqual(null, dataObj, 'dataObj should not be null');
        
        dataObj.loadAllData();
        Assert.areEqual(false, dataObj.getRecords('Opportunity.ApplicationForm.Applicant.<ApplicationForm').getRecords().isEmpty(), 'Records cannot be empty');
        ICS_CTRL_GetBrowseTree browseTree = dataObj.getRecords('Opportunity.ApplicationForm.Applicant.<InvalidObject.(InValidObject.InvalidField)');
        Assert.areEqual(null, browseTree, 'browseTree should be null');
        browseTree = dataObj.getRecords('Opportunity.ApplicationForm.Applicant.<InvalidObject');
        Assert.areNotEqual(null, browseTree, 'browseTree should not be null');
        ICS_CTRL_GetBrowseTree.BrowseNode node = new ICS_CTRL_GetBrowseTree.BrowseNode();
        node.getAscendantUsed(new String[]{'Opportunity', 'InvalidObject'});
        browseTree = new ICS_CTRL_GetBrowseTree(new ICS_CTRL_GetDataTree());
        Assert.areNotEqual(null, browseTree, 'browseTree should not be null');
        browseTree.init('InvalidObject');
        browseTree.init((String)null);
        browseTree.setChildNodes((ICS_CTRL_GetBrowseTree.BrowseNode)null, (String)null);
        browseTree.setBackNode((ICS_CTRL_GetBrowseTree.BrowseNode)null, (String)null);
        browseTree.browseChild((String)null);
        browseTree.browseChild('InvalidObject');
        browseTree.browseChild('<InvalidObject');
        
    }
 }