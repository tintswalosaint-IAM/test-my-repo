/**
* @Name of the Class: SEL_ApplicationForm_Test
* @description       : Class for Selector Class for ApplicationForm Entity Test class
* @Story: SFP-36390
* @author: Ikyatha Naidu
* @date: 29-02-2024
* @last modified on: 20-07-2024
* @last modified by: Ikyatha Naidu
* @ Modification Description: SFP-36390, used new field signing arrangement SBO-UK
*/
@isTest
private class SEL_ApplicationForm_Test {
    @TestSetup
    static void makeData(){
        Account acc1 = ICS_DAL_TestFactory.createAccount();

        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(acc1.Id);
        ApplicationForm form1 = ICS_DAL_TestFactory.createApplicationForm(acc1.Id);

        form1.OpportunityId = opp.Id;
        update form1;
    }

    @isTest
    static void testGetAppicationFormByAccId() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        List<ApplicationForm> forms = selector.selectByAccountId(acc.Id);
        selector.selectByAccountExternalCIFIdNull(acc.id);
        selector.selectByFirstandLastNameandBirth(new set<string>{'test'},new set<string>{'test'},new set<Date>{});
        selector.selectByAccountId(null);
        Test.stopTest();
        Assert.areEqual(1, forms.size(), 'Expected one ApplicationForm to be returned');
        Assert.areEqual(acc.Id, forms[0].AccountId, 'Expected the returned ApplicationForm to have the correct AccountId');
    }

    @isTest
    static void testSelectByAccountIds() {
        Set<Id> accIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();
        Test.startTest();
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        List<ApplicationForm> forms = selector.selectByAccountIds(accIds);
        selector.selectByAccountIds(null);
        Test.stopTest();
        Assert.areEqual(1, forms.size(), 'Expected two ApplicationForms to be returned');
    }

    @isTest
    static void testSelectApplicationFormById() {
        ApplicationForm testForm = [SELECT Id, AccountId FROM ApplicationForm LIMIT 1];
        Test.startTest();
        SEL_ApplicationForm selectorAppForm = new SEL_ApplicationForm();
        ApplicationForm formById = selectorAppForm.selectById(testForm.Id,true);
        selectorAppForm.selectById(null,true);
        Test.stopTest();
        Assert.areEqual(testForm.Id, formById.Id, 'Expected the correct ApplicationForm to be returned by Id');
    }

    @isTest
    static void testSelectApplicationFormsByIds() {
         List<Id> formIds = new List<Id>();
            for(ApplicationForm form : [SELECT Id FROM ApplicationForm LIMIT 2]) {
                formIds.add(form.Id);
            }

            List<Id> accIds = new List<Id>();
            for(Account acc : [SELECT Id FROM Account LIMIT 2]) {
                accIds.add(acc.Id);
            }
        Test.startTest();
        SEL_ApplicationForm selectorAppForm = new SEL_ApplicationForm();
        List<ApplicationForm> formsByFormIds = selectorAppForm.selectByIds(formIds,true);
        selectorAppForm.selectByIds(null,true);
        selectorAppForm.selectByIds(accIds,false);
        Test.stopTest();
        Assert.areEqual(1, formsByFormIds.size(), 'Expected two ApplicationForms to be returned by form Ids');
    }

    @isTest
    static void testSelectByOpportunityId() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        List<ApplicationForm> forms = selector.selectByOpportunityId(opp.Id);
        selector.selectByOpportunityId(new set<id>{opp.Id});
        Test.stopTest();
        Assert.areEqual(1, forms.size(), 'Expected one ApplicationForm to be returned');
        Assert.areEqual(opp.Id, forms[0].OpportunityId, 'Expected the returned ApplicationForm to have the correct OpportunityId');
    }

    @isTest
    static void testSelectByOpportunityIds() {
        List<Id> oppIds = new List<Id>();
            for(Opportunity form : [SELECT Id FROM Opportunity LIMIT 1]) {
                oppIds.add(form.Id);
            }
        Test.startTest();
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        List<ApplicationForm> forms = selector.selectByOpportunityIds(oppIds);
        selector.selectByOpportunityIds(null);
        Test.stopTest();
        Assert.areEqual(1, forms.size(), 'Expected one ApplicationForm to be returned');
    }

    @isTest
    static void testSelectByOpportunityStage() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        List<Id> idsDisplayed = new List<Id>{opp.Id};
        Test.startTest();
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        List<ApplicationForm> forms = selector.selectByOpportunityStage(idsDisplayed, 10, opp.StageName);
        selector.selectByOpportunityStage(idsDisplayed, 10,null);
        Test.stopTest();
        Assert.areEqual(1, forms.size(), 'Expected one ApplicationForm to be returned');
    }

    @isTest
    static void testGetSObjectType() {
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        Schema.SObjectType result = selector.getSObjectType();
        Assert.areEqual(ApplicationForm.SObjectType, result, 'Expected SObjectType to be ApplicationForm');
    }

    @isTest
    static void testGetSObjectFieldList() {
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
        List<Schema.SObjectField> result = selector.getSObjectFieldList();
        Assert.isTrue(result.contains(ApplicationForm.Name), 'Expected Name field to be in the list');
        Assert.isTrue(result.contains(ApplicationForm.OpportunityId), 'Expected OpportunityId field to be in the list');
    }

     @isTest
    static void testSelectByOwnerId() {
        SEL_ApplicationForm selector = new SEL_ApplicationForm();
	string userId=UserInfo.getUserId();
	 Test.startTest();
        List<ApplicationForm> result= selector.selectByOwnerId(userId);
       Test.stopTest();
	Assert.areEqual(true,result.isEmpty(),'applicationForm Cannot be Empty');
    }

	@isTest
    static void testselectById(){
	ApplicationForm appForm=[select id from ApplicationForm limit 1];
         SEL_ApplicationForm selector = new SEL_ApplicationForm();
	        UserInfo.getUserId();
		 Test.startTest();
        ApplicationForm result= selector.selectById(appForm.id);
       Test.stopTest();
	Assert.areEqual(true,result !=null,'applicationForm record Cannot be Empty');
    }

}