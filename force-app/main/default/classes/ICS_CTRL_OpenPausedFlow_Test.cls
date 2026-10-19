@isTest
public with sharing class ICS_CTRL_OpenPausedFlow_Test {
    @TestSetup
    static void prepareMockupData() {
        Account account = new Account(Name = 'mockup');
        insert account;
        Opportunity opportunity = new Opportunity(
            AccountId = account.Id,
            Name = 'mockup',
            StageName = 'New',
            CloseDate = date.today().addMonths(2)
        );
        insert opportunity;
    }

    @isTest
    static void getPausedFlowIdTest() {
        Opportunity opportunity = [SELECT Id, Name FROM Opportunity WHERE Name = 'mockup'];
        Test.startTest();
        String result = ICS_CTRL_OpenPausedFlow.getPausedFlowId(opportunity.Id);
        Test.stopTest();

        Assert.areEqual(result, null, 'Failed to get flow interview Id');
    }
}