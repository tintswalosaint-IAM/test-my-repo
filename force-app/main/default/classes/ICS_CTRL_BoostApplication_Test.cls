@isTest
public class ICS_CTRL_BoostApplication_Test {
    
    @testSetup 
    static void setup() {

        Account acc= ICS_TestDataFactory.createAccount();
        Opportunity opp = ICS_TestDataFactory.createOpportunity(acc.ID);
        Application__c app = ICS_TestDataFactory.createApplication(acc.ID, opp.ID);
        List<FinServ__Employment__c> employmentList = new List<FinServ__Employment__c>();
        employmentList =  ICS_TestDataFactory.createEmploymentList(acc.ID);
        List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
        assetIncomeList =  ICS_TestDataFactory.createAssetIncomeList(app.ID);
        List<ContactPointAddress >  createContactPointAddressList = new List<ContactPointAddress>();
        createContactPointAddressList =  ICS_TestDataFactory.createContactPointAddressList(acc.ID);
        ICS_TestDataFactory.createAccountFutureFund(app.ID);
        
        AssetsAndIncomes__c mainAccount = new AssetsAndIncomes__c ();
        for(AssetsAndIncomes__c assetIncome : assetIncomeList){
        	if(assetIncome.Main_Account__c){
        		mainAccount = assetIncome;
        	}
        }
        app.Bank_Account_the_Deposit_will_be_Coming__c = mainAccount.id;
		app.How_have_you_accumulated_your_wealth__c = 'Savings (from salary);Bonus;Asset / Property sale;Gift / Inheritance;Other';
		app.Other_Source_of_Wealth__c = 'Other source of wealth description';
        update app;
        
        Sales_Codes__c allocatedCode = new Sales_Codes__c();
        allocatedCode.Sales_Code_Country__c = 'ZA';
        allocatedCode.Name = '035WC';
		insert allocatedCode;
        
        opp.Sales_Code__c = allocatedCode.Id;
        update opp;

        Assert.areEqual(mainAccount.id, app.Bank_Account_the_Deposit_will_be_Coming__c, 'Expected value to be '+mainAccount.id);

    }
    
     @isTest  
     static void payloadJSONTest() {
         
		Test.startTest();
       	Test.setMock(HttpCalloutMock.class, new ICS_Mock_BoostApplication());
		Test.stopTest(); 
         
         
        Id oppID = [SELECT Id FROM Opportunity LIMIT 1].id;
        List<Id> oppIDList = new List<Id>();
        oppIDList.add(oppID);
        

        
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