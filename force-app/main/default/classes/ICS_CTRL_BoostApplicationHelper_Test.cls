@isTest
public class ICS_CTRL_BoostApplicationHelper_Test {
    
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
    
        AssetsAndIncomes__c mainAccount = new AssetsAndIncomes__c ();
        for(AssetsAndIncomes__c assetIncome : assetIncomeList){
        	if(assetIncome.Main_Account__c){
        		mainAccount = assetIncome;
        	}
       }
        app.Bank_Account_the_Deposit_will_be_Coming__c = mainAccount.id;
        update app;
        
     	Assert.areEqual(mainAccount.id, app.Bank_Account_the_Deposit_will_be_Coming__c, 'Expected value to be '+mainAccount.id);


    }
    
 	@isTest  
    static void boostProductMapTest() {
      
        String productTypeCurrentAccount = ICS_CTRL_BoostApplicationHelper.boostProductMap('IPB Optimum');
     	String productTypePlatinumAccount = ICS_CTRL_BoostApplicationHelper.boostProductMap('IPB Platinum Optimum');
     	String productTypeProfessionalAccount = ICS_CTRL_BoostApplicationHelper.boostProductMap('IPB Professional Demand');
     	String productTypeStaffAccount = ICS_CTRL_BoostApplicationHelper.boostProductMap('IPB Staff Account');
     
     	Assert.areEqual('Optimum current account', productTypeCurrentAccount, 'Expected value to be Optimum current account');
     	Assert.areEqual('Platinum Optimum account', productTypePlatinumAccount, 'Expected value to be Platinum Optimum account');
     	Assert.areEqual('IFA Professional Demand account', productTypeProfessionalAccount, 'Expected value to be IFA Professional Demand account');
     	Assert.areEqual('SB Staff account', productTypeStaffAccount, 'Expected value to be SB Staff account');
    }
    
    @isTest  
    static void boostProductShortNameMapTest() {
      
        String productTypeShortNameCurrentAccount = ICS_CTRL_BoostApplicationHelper.boostProductShortNameMap('IPB Optimum');
     	String productTypeShortNamePlatinumAccount = ICS_CTRL_BoostApplicationHelper.boostProductShortNameMap('IPB Platinum Optimum');
     	String productTypeShortNameProfessionalAccount = ICS_CTRL_BoostApplicationHelper.boostProductShortNameMap('IPB Professional Demand');
     	String productTypeShortNameStaffAccount = ICS_CTRL_BoostApplicationHelper.boostProductShortNameMap('IPB Staff Account');
     
     	Assert.areEqual('Opti Cur', productTypeShortNameCurrentAccount, 'Expected value to be Opti Cur');
     	Assert.areEqual('Opti Plat', productTypeShortNamePlatinumAccount, 'Expected value to be Opti Plat');
     	Assert.areEqual('IFA PRDA', productTypeShortNameProfessionalAccount, 'Expected value to be IFA PRDA');
     	Assert.areEqual('Staff', productTypeShortNameStaffAccount, 'Expected value to be Staff');
    }
    
    @isTest  
    static void boostEmploymentMapTest() {

     	String employmentStatusUnemployedWithIncome = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Unemployed with Income');
     	String employmentStatusUnemployedWithoutIncome = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Unemployed without Income');
        String employmentStatusSelfemployed = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Self-Employed');
     	String employmentStatusHousePerson = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Home Person');
     	String employmentStatusHomeMaker = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Home Maker');
     	String employmentStatusStudent = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Student');
		String employmentStatusContracting = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Contracting');
     	String employmentStatusRetired = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Retired');
     	String employmentStatusEmployed = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Employed');
     	String employmentStatusEmployedFinanceSector = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Employed in the Finance sector');
     	String employmentStatusEmployedOtherSectors = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Employed in other sectors');
     	String employmentStatusAppointedDirector = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap('Legally Appointed Director');
        
        Assert.areEqual('Unemployed', employmentStatusUnemployedWithIncome, 'Expected value to be Unemployed');
     	Assert.areEqual('Unemployed', employmentStatusUnemployedWithoutIncome, 'Expected value to be Unemployed');
        Assert.areEqual('Selfemployed', employmentStatusSelfemployed, 'Expected value to be Selfemployed');
     	Assert.areEqual('Houseperson', employmentStatusHousePerson, 'Expected value to be Houseperson');
     	Assert.areEqual('Houseperson', employmentStatusHomeMaker, 'Expected value to be Houseperson');
     	Assert.areEqual('Ineducation', employmentStatusStudent, 'Expected value to be Ineducation');
		Assert.areEqual('Contracting', employmentStatusContracting, 'Expected value to be Contracting');
     	Assert.areEqual('Retired', employmentStatusRetired, 'Expected value to be Retired');
     	Assert.areEqual('Employed', employmentStatusEmployed, 'Expected value to be Employed');   
     	Assert.areEqual('Employed', employmentStatusEmployedFinanceSector, 'Expected value to be Employed');    
     	Assert.areEqual('Employed', employmentStatusEmployedOtherSectors, 'Expected value to be Employed');    
     	Assert.areEqual('Employed', employmentStatusAppointedDirector, 'Expected value to be Employed'); 
        
    }
    
     @isTest  
     static void lengthOfTimeTest() {
      
		Date startDate = date.newInstance(1996, 12, 17);
        Date todayDate = date.newInstance(2022, 08, 29);
        List <String> lengthOfTime = new List <String>();    
        lengthOfTime = ICS_CTRL_BoostApplicationHelper.lengthOfTime(startDate, todayDate);
         
     
     	Assert.areEqual('25', lengthOfTime[0], 'Expected value to be 25');
     	Assert.areEqual('8', lengthOfTime[1], 'Expected value to be 8');
    }   
    
     
     @isTest  
     static void employmentListTest() {
      
        Id accID = [SELECT Id FROM Account LIMIT 1].id;
		ICS_SEL_FinServ_Employment selectEmployment = new ICS_SEL_FinServ_Employment();
        List<FinServ__Employment__c> currentEmploymentList = new List<FinServ__Employment__c>() ;
        List<FinServ__Employment__c> previousEmploymentList = new List<FinServ__Employment__c>() ;
        currentEmploymentList = selectEmployment.getEmployment(accID,'Current');
        previousEmploymentList = selectEmployment.getEmployment(accID,'Previous');
		List<AssetsAndIncomes__c> salaryBonusList = new List<AssetsAndIncomes__c>();

        ICS_CTRL_BoostApplicationHelper.EmploymentIncomeWrapper annualEmploymentIncome = new ICS_CTRL_BoostApplicationHelper.EmploymentIncomeWrapper();
        annualEmploymentIncome = ICS_CTRL_BoostApplicationHelper.annualIncomeCalculation(previousEmploymentList, currentEmploymentList, salaryBonusList);

     	Assert.areEqual('Employed', annualEmploymentIncome.employmentType, 'Expected value to be Employed');

    }
    
     @isTest  
     static void employmentConvertedCurrencyListTest() {
      
        Id accID = [SELECT Id FROM Account LIMIT 1].id;
		ICS_SEL_FinServ_Employment selectEmployment = new ICS_SEL_FinServ_Employment();
		List<FinServ__Employment__c> currentEmploymentList = new List<FinServ__Employment__c>() ;
        List<FinServ__Employment__c> previousEmploymentList = new List<FinServ__Employment__c>() ;
        currentEmploymentList = selectEmployment.getEmploymentConvertedCurrencyList(accID,'Current');
        previousEmploymentList = selectEmployment.getEmploymentConvertedCurrencyList(accID,'Previous');
		List<AssetsAndIncomes__c> salaryBonusList = new List<AssetsAndIncomes__c>();
                
        ICS_CTRL_BoostApplicationHelper.EmploymentIncomeWrapper annualEmploymentIncome = new ICS_CTRL_BoostApplicationHelper.EmploymentIncomeWrapper();
        annualEmploymentIncome = ICS_CTRL_BoostApplicationHelper.annualIncomeCalculation(previousEmploymentList, currentEmploymentList, salaryBonusList);
     	
     	Assert.areEqual('Employed', annualEmploymentIncome.employmentType, 'Expected value to be Employed');

    }
    
     @isTest  
     static void otherDescriptionFutureDepositsFundTest() {
      
		String futureDepositsFund = [SELECT Id, Intent_to_Future_Deposits_Funds__c FROM Application__c LIMIT 1].Intent_to_Future_Deposits_Funds__c;
        String otherDescription = ICS_CTRL_BoostApplicationHelper.otherDescriptionFutureDepositsFund(futureDepositsFund);

        Assert.areEqual('Gift', otherDescription, 'Expected value to be Gift');
    } 
    
     @isTest  
     static void otherIncomeForWealth() {
      
		String incomeWealth = [SELECT Id, What_Other_Incomes_Do_You_Have__c FROM Application__c LIMIT 1].What_Other_Incomes_Do_You_Have__c;
        String otherIncomesAccumulatedWealth = ICS_CTRL_BoostApplicationHelper.otherIncomeForWealth(incomeWealth);
        
        Assert.areEqual('Loan',otherIncomesAccumulatedWealth, 'Expected value to be Loan');
    } 
    
     @isTest  
     static void assetIncomeDescriptionTest() {
         
		 Double totalPropertyAmount = 0.0;
		 Double totalAssetAmount = 0.0;
		 Double totalAdditionalAccount = 0.0;
		 String propertyDescription;
		 String assetDescription;
		 String additionalAccountDescription;
         
		 Id appID = [SELECT Id FROM Application__c LIMIT 1].Id;
         
         List<Schema.PicklistEntry> countryPicklistValues = Schema.SObjectType.AssetsAndIncomes__c.fields.Country__c.getPicklistValues();
		 Map<String, String> countryPicklistMap = new Map<String, String>(); 
		 for (Schema.PicklistEntry picklistEntry : countryPicklistValues) { 
		 	countryPicklistMap.put(picklistEntry.getValue(), picklistEntry.getLabel()); 
		 }
      
		 ICS_SEL_AssetAndIncome selectAssetAndIncome = new ICS_SEL_AssetAndIncome();
		 List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
		 assetIncomeList = selectAssetAndIncome.getAssetIncomeConvertedCurrencyList(appID);

		 List<AssetsAndIncomes__c> assetIncomePropertyList = new List<AssetsAndIncomes__c>();
		 assetIncomePropertyList = selectAssetAndIncome.getAssetIncomeList(appID,'Property' );
		 Map<Id, AssetsAndIncomes__c> assetIncomePropertyMap = new Map<Id, AssetsAndIncomes__c>(assetIncomePropertyList);
            			
		 List<AssetsAndIncomes__c> assetIncomeAdditionalAccountList = new List<AssetsAndIncomes__c>();
		 assetIncomeAdditionalAccountList = selectAssetAndIncome.getAssetIncomeList(appID,'Additional Account');
		 Map<Id, AssetsAndIncomes__c> assetIncomeAdditionalAccountMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeAdditionalAccountList);
            
		 List<AssetsAndIncomes__c> assetIncomeOtherIncomeList = new List<AssetsAndIncomes__c>();
		 assetIncomeOtherIncomeList = selectAssetAndIncome.getAssetIncomeList(appID,'Other Income');
		 Map<Id, AssetsAndIncomes__c> assetIncomeOtherIncomeMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeOtherIncomeList);
            			
		 List<AssetsAndIncomes__c> assetIncomeInvestmentsList = new List<AssetsAndIncomes__c>();
		 assetIncomeInvestmentsList = selectAssetAndIncome.getAssetIncomeList(appID,'Assets/Investments/Stocks');
		 Map<Id, AssetsAndIncomes__c> assetIncomeInvestmentsMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeInvestmentsList);

		 List<AssetsAndIncomes__c> assetIncomeCountryWealthList = new List<AssetsAndIncomes__c>();
		 assetIncomeCountryWealthList = selectAssetAndIncome.getAssetIncomeList(appID,'Wealth in Country');
		 Map<Id, AssetsAndIncomes__c> assetIncomeCountryWealthMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeCountryWealthList);     
         
         Map<String, Map<Id, AssetsAndIncomes__c>> assetIncomeMaps = new Map<String, Map<Id, AssetsAndIncomes__c>>();
         assetIncomeMaps.put('Property', assetIncomePropertyMap);
         assetIncomeMaps.put('Additional Account', assetIncomeAdditionalAccountMap);
         assetIncomeMaps.put('Other Income', assetIncomeOtherIncomeMap);
         assetIncomeMaps.put('Assets/Investments/Stocks', assetIncomeInvestmentsMap);
         assetIncomeMaps.put('Wealth in Country', assetIncomeCountryWealthMap);
         
		 for( AssetsAndIncomes__c assetIncome : assetIncomeList){
		 	if( assetIncome.Is_listed_in_assets__c != 'No'){
                    
		 		ICS_CTRL_BoostApplicationHelper.AssetIncomeWrapper assetIncomeSummary = new ICS_CTRL_BoostApplicationHelper.AssetIncomeWrapper();
		 		assetIncomeSummary = ICS_CTRL_BoostApplicationHelper.assetIncomeDescription(assetIncome, countryPicklistMap,assetIncomeMaps);
		 		totalAssetAmount += assetIncomeSummary.totalAssetAmount;
		 		totalPropertyAmount += assetIncomeSummary.totalPropertyAmount;
		 		totalAdditionalAccount += assetIncomeSummary.totalAdditionalAccount;
		 		if(String.IsNotBlank(assetIncomeSummary.assetDescription)){ 
		 			assetDescription += assetIncomeSummary.assetDescription.replace('null','') + '\n' ;
		 		}
		 		if(String.IsNotBlank(assetIncomeSummary.propertyDescription)){ 
		 			propertyDescription += assetIncomeSummary.propertyDescription.replace('null','') + '\n' ;
		 		}
		 		if(String.IsNotBlank(assetIncomeSummary.additionalAccountDescription)){ 
		 			additionalAccountDescription += assetIncomeSummary.additionalAccountDescription.replace('null','') + '\n' ;
		 		}
			}
		 }
       
		Assert.areEqual(true, totalAssetAmount != null, 'Expected value to be true');
		Assert.areEqual(true, totalPropertyAmount != null, 'Expected value to be true');
		Assert.areEqual(true, totalAdditionalAccount != null, 'Expected value to be true');
    } 

     @isTest  
     static void depositDetailsTest() {
         
    	Id oppID = [SELECT Id FROM Opportunity LIMIT 1].id;
		ICS_SEL_Application selectApplication = new ICS_SEL_Application();
    	List<Application__c> apps  = selectApplication.getApplications(oppID);
    	Application__c app = apps[0];
    	Id appID = app.ID;
        
		ICS_SEL_AssetAndIncome selectAssetAndIncome = new ICS_SEL_AssetAndIncome();
    	List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
    	assetIncomeList = selectAssetAndIncome.getAssetIncomeConvertedCurrencyList(appID);
         
    	List<AssetsAndIncomes__c> assetIncomeAdditionalAccountList = new List<AssetsAndIncomes__c>();
    	assetIncomeAdditionalAccountList = selectAssetAndIncome.getAssetIncomeList(appID,'Additional Account');
    	Map<Id, AssetsAndIncomes__c> assetIncomeAdditionalAccountMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeAdditionalAccountList);

		 ICS_CTRL_BoostApplicationHelper.DepositDetailWrapper deposits = new ICS_CTRL_BoostApplicationHelper.DepositDetailWrapper ();
		 deposits = ICS_CTRL_BoostApplicationHelper.depositDetails(assetIncomeList,assetIncomeAdditionalAccountMap, app);
		 String depositBankName = deposits.depositBankName;
		 String depositCountry = deposits.depositCountry;
		 String depositAccountName = deposits.depositAccountName;
		 Boolean depositMainAccount = deposits.depositMainAccount;
		 String futureDepositBankName = deposits.futureDepositBankName;
		 String futureDepositCountry = deposits.futureDepositCountry;
		 String futureDepositAccountName = deposits.futureDepositAccountName;
		 Boolean futureDepositMainAccount = deposits.futureDepositMainAccount;
		 Boolean futureDepositMethod = deposits.futureDepositMethod;
       
         Assert.areEqual('Aruba Mutual Bank', depositBankName, 'Expected value to be Aruba Mutual Bank');
         Assert.areEqual('ZA', depositCountry, 'Expected value to be ZA');
         Assert.areEqual('John Assets', depositAccountName, 'Expected value to be John Assets');
         Assert.areEqual(true, depositMainAccount, 'Expected value to be true');
         Assert.areEqual('Aruba Mutual Bank', futureDepositBankName, 'Expected value to be  Aruba Mutual Bank');
         Assert.areEqual('John Assets', futureDepositAccountName, 'Expected value to be John Assets');
         Assert.areEqual('ZA', futureDepositCountry, 'Expected value to be ZA');
         Assert.areEqual(true,futureDepositMainAccount, 'Expected value to be true');
         Assert.areEqual(true,futureDepositMethod, 'Expected value to be true');
    } 
    
      @isTest  
     static void blankDepositDetailsTest() {
         
    	Id oppID = [SELECT Id FROM Opportunity LIMIT 1].id;
		ICS_SEL_Application selectApplication = new ICS_SEL_Application();
    	List<Application__c> apps  = selectApplication.getApplications(oppID);
    	Application__c app = apps[0];
    	Id appID = app.ID;
        app.Bank_Account_the_Deposit_will_be_Coming__c = null;
        app.Future_Deposits_Funded_From__c = 'NO';
        update app;
        
		ICS_SEL_AssetAndIncome selectAssetAndIncome = new ICS_SEL_AssetAndIncome();
    	List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
    	assetIncomeList = selectAssetAndIncome.getAssetIncomeConvertedCurrencyList(appID);
         
    	List<AssetsAndIncomes__c> assetIncomeAdditionalAccountList = new List<AssetsAndIncomes__c>();
    	assetIncomeAdditionalAccountList = selectAssetAndIncome.getAssetIncomeList(appID,'Additional Account');
    	Map<Id, AssetsAndIncomes__c> assetIncomeAdditionalAccountMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeAdditionalAccountList);
         
    	         
		 ICS_CTRL_BoostApplicationHelper.DepositDetailWrapper deposits = new ICS_CTRL_BoostApplicationHelper.DepositDetailWrapper ();
		 deposits = ICS_CTRL_BoostApplicationHelper.depositDetails(assetIncomeList,assetIncomeAdditionalAccountMap, app);
		 String depositBankName = deposits.depositBankName;
		 String depositCountry = deposits.depositCountry;
		 String depositAccountName = deposits.depositAccountName;
		 Boolean depositMainAccount = deposits.depositMainAccount;
		 String futureDepositBankName = deposits.futureDepositBankName;
		 String futureDepositCountry = deposits.futureDepositCountry;
		 Boolean futureDepositMainAccount = deposits.futureDepositMainAccount;
		 Boolean futureDepositMethod = deposits.futureDepositMethod;
       
         Assert.areEqual(null, depositBankName, 'Expected value to be null');
         Assert.areEqual(null, depositCountry, 'Expected value to be null');
         Assert.areEqual(null, depositAccountName, 'Expected value to be null');
         Assert.areEqual(false, depositMainAccount, 'Expected value to be false');
         Assert.areEqual('AZ Investment Bank', futureDepositBankName, 'Expected value to be AZ Investment Bank');
         Assert.areEqual('ZA', futureDepositCountry, 'Expected value to be ZA');
         Assert.areEqual(false,futureDepositMainAccount,'Expected value to be false');
         Assert.areEqual(true,futureDepositMethod, 'Expected value to be true');
         

    } 
    
      @isTest  
     static void specialCharacterErrorTest() {
         
         Map<String, String> regexCheckMap = new Map<String, String>();
         regexCheckMap.put('Delivery Address Post Code', '1234@');
         regexCheckMap.put('Previous Address Post Code', '1234@');
         regexCheckMap.put('Answer To Mother Former/Maiden Name', 'MotherMaidenName@');
         regexCheckMap.put('Answer To Favourite Sport Or Colour', 'FavouriteSportOrColour@');
         regexCheckMap.put('Answer To Code Word','CodeWord@');
         regexCheckMap.put('Answer To First School Name', 'FirstSchoolName@');
         
         String expectedMessage = '{"Number":-300,"Value":"Pattern of \'Delivery Address Post Code\' is not valid"},'+
             					' {"Number":-300,"Value":"Pattern of \'Previous Address Post Code\' is not valid"},'+
             					' {"Number":-300,"Value":"Pattern of \'Answer To Mother Former/Maiden Name\' is not valid"},'+
             					' {"Number":-300,"Value":"Pattern of \'Answer To Favourite Sport Or Colour\' is not valid"},'+
             					' {"Number":-300,"Value":"Pattern of \'Answer To Code Word\' is not valid"},'+
             					' {"Number":-300,"Value":"Pattern of \'Answer To First School Name\' is not valid"}';
         
         
         String errorMessage = ICS_CTRL_BoostApplicationHelper.errorMessage(regexCheckMap);
         Assert.areEqual(expectedMessage,errorMessage, 'Expected value to be true');

    } 

    
}