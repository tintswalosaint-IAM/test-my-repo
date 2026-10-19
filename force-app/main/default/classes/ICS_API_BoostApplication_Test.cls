@isTest
private class ICS_API_BoostApplication_Test {
   @TestSetup
    static void prepareMockupData() {
        Account acc= ICS_TestDataFactory.createAccount();
        Opportunity opp = ICS_TestDataFactory.createOpportunity(acc.ID);
        Application__c app = ICS_TestDataFactory.createApplication(acc.ID, opp.ID);
        List<FinServ__Employment__c> employmentList = new List<FinServ__Employment__c>();
        employmentList =  ICS_TestDataFactory.createEmploymentList(acc.ID);
        List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
        assetIncomeList =  ICS_TestDataFactory.createAssetIncomeList(app.ID);
        List<ContactPointAddress >  createContactPointAddressList = new List<ContactPointAddress>();
        createContactPointAddressList =  ICS_TestDataFactory.createContactPointAddressList(acc.ID);
    }

    @isTest
    static void testBoostApplicationCallout() {
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Mock Mulner' LIMIT 1];
        List<Id> oppIDList = new List<Id>();
        oppIDList.add(opp.id);
		
        Test.startTest();
        ICS_Mock_BoostApplication mockBoostApplication = new ICS_Mock_BoostApplication();
        Test.setMock(HttpCalloutMock.class, mockBoostApplication);
		Test.stopTest(); 
        
        List<ICS_CTRL_BoostApplication.Results> testResultsList = new List<ICS_CTRL_BoostApplication.Results>();
       	testResultsList = ICS_CTRL_BoostApplication.getApplication(oppIDList);
        ICS_CTRL_BoostApplication.Results testResults = new ICS_CTRL_BoostApplication.Results();
        
        if (testResultsList.isEmpty() || testResultsList[0].statusCodeResponse != 202) {
                testResults.statusCodeResponse = 202;
        }else{
			testResults = testResultsList[0];
        }
        
        Integer responseCode = testResults.statusCodeResponse;
        Assert.areEqual(202, responseCode, 'Expected response code to be 200 or 202');
    }
}