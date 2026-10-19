/**
 * @description Boost Application Helper Class
 * @author November Sizwe
 * @date May 2023
 */
public with sharing class ICS_CTRL_BoostApplicationHelper  {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_Boost_Application');    
    
    private static final String PRODUCT_OPTIMUM = 'IPB Optimum';
    private static final String PRODUCT_PLATINUM_OPTIMUM = 'IPB Platinum Optimum';
    private static final String PRODUCT_PROFESSIONAL_DEMAND_ACCOUNT = 'IPB Professional Demand';
    private static final String PRODUCT_STAFF_ACCOUNT = 'IPB Staff Account';
    
    private static final String BANK_DEPOSITS = 'Bank Deposits';
    private static final String LIFE_SAVINGS = 'Life Savings';
    private static final String BUSINESS_DIVIDENDS = 'Business Dividends';
    private static final String PENSION_PAYMENTS = 'Pension Payments';
    private static final String PENSION_RETIREMENT = 'Pensions/Retirement';
    private static final String SALE_OF_BUSINESS = 'Sale of Business';
    private static final String SALE_OF_PROPERTY = 'Sale of Property';
    private static final String INVESTMENTS = 'Investments';
    private static final String SALARY_BONUS = 'Salary/Bonus';
    private static final String INVESTMENT_DIVIDEND ='Investment/Dividend';
    private static final String SALE_OF_INVESTMENTS = 'Sale of Investments';
        
    private static final String SELF_EMPLOYED = 'Self-Employed';
    private static final String HOME_PERSON = 'Home Person';
    private static final String HOUSE_MAKER = 'Home Maker';
    private static final String HOUSE_PERSON = 'House-person';
    private static final String CONTRACTING = 'Contracting';
    private static final String RETIRED = 'Retired';
    private static final String EMPLOYED = 'Employed';
    private static final String UNEMPLOYED = 'Unemployed';
    private static final String STUDENT = 'Student';
    private static final String IN_EDUCATION = 'In Education';

    private static final String PROPERTY = 'Property';
    private static final String ADDITIONAL_ACCOUNT = 'Additional Account';
    private static final String OTHER_INCOME = 'Other Income';
    private static final String ASSETS_INVESTMENTS_STOCKS = 'Assets/Investments/Stocks';
    
    private static final String STRING_FRENQUENCY = 'No further deposits to be made, just the initial payment';
    
    private static final String OTHER = 'Other';
    private static final String LOTTERY_BETTING_WINNINGS = 'Lottery/Betting Winnings';
    private static final String COMPENSATION_PAYMENT = 'Compensation Payment';
    private static final String LOAN = 'Loan';
    
    
    private static final String NO = 'NO';
    private static final String YES = 'YES';

    
    /**
    * @description Tax wrapper class to deserialize the tax data on Application 
    */       
    public class TaxData {
        
        public String countryOfTax;
        public String hasTIN;
        public String taxIdentificationNumber;
        public String reasonForTinNiNumber; 
        public String reasonBExplanation;
    }
    
   /**
   * @description This method maps the Salesforce product name to Boost 
   * @param  productType  	Product name or type in application
   * @return String   		Boost product name that exist in Boost
   */
    public static String boostProductMap(String productType) {
        
        String boostProduct;
        if (productType == PRODUCT_OPTIMUM) {		
            boostProduct = 'Optimum current account';
        }	
        else if (productType == PRODUCT_PLATINUM_OPTIMUM) {		
            boostProduct  = 'Platinum Optimum account';  
        }
        else if (productType == PRODUCT_PROFESSIONAL_DEMAND_ACCOUNT) {		
            boostProduct    = 'IFA Professional Demand account';
        }
        else if (productType == PRODUCT_STAFF_ACCOUNT) {		
            boostProduct= 'SB Staff account';
        }

      
        return boostProduct; 
    }
    
   /**
   * @description This method maps the Salesforce product name to Boost 
   * @param  employmentStatus  	Employment status in the application
   * @return String   			Employment status that exist in Boost
   */
    public static String boostEmploymentMap(String employmentStatus) {
        
        String boostEmploymentStatus;
        
        if (employmentStatus.contains(UNEMPLOYED)){
            
            boostEmploymentStatus  = 'Unemployed';
        }else if(employmentStatus == STUDENT || employmentStatus == IN_EDUCATION){
            
            boostEmploymentStatus= 'Ineducation';
            
        }else if (employmentStatus == SELF_EMPLOYED)  {		
            
            boostEmploymentStatus = 'Selfemployed';
            
        }	
        else if (employmentStatus == HOUSE_PERSON) {		  
            
            boostEmploymentStatus= 'Houseperson';
            
        }
        else if (employmentStatus == HOME_PERSON) {		  
            
            boostEmploymentStatus= 'Houseperson';
            
        }
        else if (employmentStatus == HOUSE_MAKER)  {		  
            
            boostEmploymentStatus= 'Houseperson';
            
        }
        else if (employmentStatus == CONTRACTING)  {		  
            
            boostEmploymentStatus= 'Contracting';
            
        }
        else if (employmentStatus == RETIRED) {		  
            
            boostEmploymentStatus= 'Retired';
            
        }
        else {		 
            
            boostEmploymentStatus = 'Employed'; 
            
        }  
            
        return boostEmploymentStatus;
    }
    
   /**
   * @description This method determines the length of time at current address
   * @param  startDate  		Start date at current address
   * @param  endDate  		End date to determine length at current address
   * @return List of String   	List of string with the contains length of year and month at current address 
   */
    public static List<String> lengthOfTime(Date startDate, Date endDate ) {
        
        List<String> lengthOfTimeList = new List<String>();
        
        Integer years = endDate.year() - startDate.year();
        Integer months = endDate.month() - startDate.month();
        
        if(startDate == null || endDate == null){
			years = 0;
			months = 0; 
        }
        
        if (endDate.day() < startDate.day()) {
            months--;
        }
        
        if (months < 0) {
            years--;
            months += 12;
        }

        lengthOfTimeList.add(String.valueOf(years));
        lengthOfTimeList.add(String.valueOf(months));

        return lengthOfTimeList;

    }
    
   /**
   * @description This method maps the Salesforce product name to Boost product short name 
   * @param  productTypeShortName  	Product name or type in application
   * @return String   				Boost product short/alias name that exist in Boost
   */
    public static String boostProductShortNameMap(String productTypeShortName) {

        String boostProduct;
        if (productTypeShortName == PRODUCT_OPTIMUM){		
            boostProduct = 'Opti Cur';
        }	
        else if (productTypeShortName == PRODUCT_PLATINUM_OPTIMUM){		
            boostProduct  = 'Opti Plat';  
        }
        else if (productTypeShortName == PRODUCT_PROFESSIONAL_DEMAND_ACCOUNT){		
            boostProduct    = 'IFA PRDA';
        }
        else if (productTypeShortName == PRODUCT_STAFF_ACCOUNT){		 
            boostProduct= 'Staff';
        }
        
        return boostProduct;
    }
    
   /**
   * @description This method provides employment income details 
   * @param  previousEmploymentList  	Previous employment list
   * @param  employmentList  			Current employment list
   * @param  salaryBonusConvertedCurrencyList Salary/Bonus list with converted amounts
   * @return EmploymentIncomeWrapper   	Employment income details object
   */
    public static EmploymentIncomeWrapper annualIncomeCalculation(List<FinServ__Employment__c> previousEmploymentList, List<FinServ__Employment__c> employmentList, List<AssetsAndIncomes__c> salaryBonusConvertedCurrencyList ) {
		
        EmploymentIncomeWrapper annualIncome = new EmploymentIncomeWrapper();
      
        if (salaryBonusConvertedCurrencyList.size() !=0){
            for(AssetsAndIncomes__c salaryBonusConvertedCurrency : salaryBonusConvertedCurrencyList){
                if(!salaryBonusConvertedCurrency.Is_future_fund__c){
                    
               		annualIncome.totalAnnualEarnings = annualIncome.totalAnnualEarnings + salaryBonusConvertedCurrency.Amounts__c + salaryBonusConvertedCurrency.Bonus_Amount__c;
                	annualIncome.annualIncomeCurrency =  UserInfo.getDefaultCurrency();
                }

            }
        }
        
        for(FinServ__Employment__c employ : employmentList){
            
            if (String.IsNotBlank(employ.FinServ__EmploymentStatus__c)){

                annualIncome.employmentType = boostEmploymentMap(employ.FinServ__EmploymentStatus__c);
            }

            if(String.IsNotBlank(employ.Only_employment__c) && (annualIncome.employmentType != RETIRED && annualIncome.employmentType != UNEMPLOYED) && 
               employmentList.size() != 0 && (employmentList[0].FinServ__AnnualIncome__c != null ||employmentList[0].Bonuses_Commissions_received_per_annum__c != null )){
                   
                   annualIncome.totalAnnualEarnings = annualIncome.totalAnnualEarnings + employ.FinServ__AnnualIncome__c   +  employ.Bonuses_Commissions_received_per_annum__c;
                   annualIncome.annualIncomeCurrency =  UserInfo.getDefaultCurrency();
               }
        }
        return annualIncome;
    }
    
    /**
 	* @description Employment Income Details Wrapper Class
 	*/
    public class EmploymentIncomeWrapper {
        
        public String employmentType;
    	public String annualIncomeCurrency;
		public Decimal totalAnnualEarnings = 0;

    }
    
   /**
   * @description This method provides description of other ways to  fund future deposits
   * @param  appIntentToFutureDepositsFunds  	Intent to future deposits funds
   * @return String   							Description of other ways to  fund future deposits
   */
    public static String otherDescriptionFutureDepositsFund( String appIntentToFutureDepositsFunds) {
		
        String otherDescription;
        List<String> futureDepositsFundsList =  new List<String>();
        futureDepositsFundsList = appIntentToFutureDepositsFunds.split(';');
        List<String> otherDescriptionList =  new List<String>();
        for (String futureDepositsFund : futureDepositsFundsList){
        	if(futureDepositsFund != BANK_DEPOSITS && futureDepositsFund != LIFE_SAVINGS && futureDepositsFund != BUSINESS_DIVIDENDS &&
        		futureDepositsFund != PENSION_PAYMENTS && futureDepositsFund != SALE_OF_BUSINESS && futureDepositsFund != PENSION_RETIREMENT &&
        		futureDepositsFund != SALE_OF_PROPERTY && futureDepositsFund != INVESTMENTS && futureDepositsFund != SALARY_BONUS && 
               	futureDepositsFund != INVESTMENT_DIVIDEND && futureDepositsFund != SALE_OF_INVESTMENTS){
					
                    otherDescriptionList.add(futureDepositsFund.replace('Maturity of Insurance Policy or Fixed Term Investment', 'Insurance Policy/Fixed Term Investment')
                                            				   .replace('Lottery/Betting Winnings', 'Lottery/Betting'));
                    }
            	}
        otherDescription = otherDescriptionList.toString().remove('(').remove(')'); 
        return otherDescription;
    }
    
     /**
   * @description This method provides the summary of asset & income details 
   * @param  assetIncome  			Asset & Income record 
   * @param  countryPicklistMap  	Map of countries related to Asset & Income
   * @param  assetIncomeMaps  		Map of with the record type of Asset & Income maps
   * @return AssetIncomeWrapper   	Summary of the asset & income details object
   */
    public static AssetIncomeWrapper assetIncomeDescription(AssetsAndIncomes__c assetIncome,Map<String, String> countryPicklistMap, Map<String, Map<Id, AssetsAndIncomes__c>> assetIncomeMaps) {
        
        Map<Id,  AssetsAndIncomes__c> assetIncomePropertyMap = assetIncomeMaps.get(PROPERTY);
        Map<Id, AssetsAndIncomes__c> assetIncomeAdditionalAccountMap = assetIncomeMaps.get(ADDITIONAL_ACCOUNT);
        Map<Id, AssetsAndIncomes__c> assetIncomeOtherIncomeMap = assetIncomeMaps.get(OTHER_INCOME);
        Map<Id, AssetsAndIncomes__c> assetIncomeInvestmentsMap = assetIncomeMaps.get(ASSETS_INVESTMENTS_STOCKS);
        
        AssetIncomeWrapper assetIncomeSummary = new AssetIncomeWrapper();
        
        JSONGenerator assetIncomeDescription = JSON.createGenerator(true);
        if(assetIncome.Amounts__c != null && assetIncome.RecordType.Name == OTHER_INCOME &&  !assetIncome.Main_Account__c &&
           assetIncome.Other_Income_Type__c != BANK_DEPOSITS &&  assetIncome.Other_Income_Type__c != LIFE_SAVINGS && assetIncome.Other_Income_Type__c != SALARY_BONUS){
            assetIncomeSummary.totalAssetAmount += assetIncome.Amounts__c;
            AssetsAndIncomes__c assetIncomeOtherIncome = assetIncomeOtherIncomeMap.get(assetIncome.ID);                    
            assetIncomeDescription.writeStartObject();
            assetIncomeDescription.writeStringField('Description', assetIncome.RecordType.Name );
            assetIncomeDescription.writeStringField('Other Income Type', String.IsNotBlank(assetIncome.Other_Income_Type__c) ?  assetIncome.Other_Income_Type__c  : ''  );
            if(String.IsNotBlank(assetIncome.Country__c)){
                assetIncomeDescription.writeStringField('Country', countryPicklistMap.get(assetIncome.Country__c));
            } 
            assetIncomeDescription.writeStringField('Currency', String.IsNotBlank(assetIncome.CurrencyIsoCode) ?  assetIncome.CurrencyIsoCode  : '' );
            assetIncomeDescription.writeStringField('Amount', assetIncomeOtherIncome.Amounts__c != null ? (assetIncomeOtherIncome.Amounts__c.format()): '' );
            assetIncomeDescription.writeEndObject();
            assetIncomeSummary.assetDescription += assetIncomeDescription.getAsString().replace('{','').replace('}','').replace('"','').replace(',','');
        }
        else if(assetIncome.Asset_Value__c != null && assetIncome.RecordType.Name == ASSETS_INVESTMENTS_STOCKS){
            assetIncomeSummary.totalAssetAmount += assetIncome.Asset_Value__c;
            AssetsAndIncomes__c assetIncomeInvestment = assetIncomeInvestmentsMap.get(assetIncome.ID);                   
            assetIncomeDescription.writeStartObject();
            assetIncomeDescription.writeStringField('Description', assetIncome.RecordType.Name );
            assetIncomeDescription.writeStringField('What the Assets are', String.IsNotBlank(assetIncome.What_the_Assets_are__c) ?  assetIncome.What_the_Assets_are__c  : ''  );
            assetIncomeDescription.writeStringField('Investments/Stocks Jurisdiction', String.IsNotBlank(assetIncome.Country__c) ?  countryPicklistMap.get(assetIncome.Country__c)  : '' );
            assetIncomeDescription.writeStringField('Investments/Stocks Financial Institution', String.IsNotBlank(assetIncome.Investments_Stocks_Financial_Institution__c) ?  assetIncome.Investments_Stocks_Financial_Institution__c  : ''  );
            assetIncomeDescription.writeStringField('Currency', String.IsNotBlank(assetIncome.CurrencyIsoCode) ?  assetIncome.CurrencyIsoCode  : '' );
            assetIncomeDescription.writeStringField('Asset Value', assetIncomeInvestment.Asset_Value__c != null ? (assetIncomeInvestment.Asset_Value__c.format()): '' );
            assetIncomeDescription.writeEndObject();
            assetIncomeSummary.assetDescription += assetIncomeDescription.getAsString().replace('{','').replace('}','').replace('"','').replace(',','');
        }
        else if(assetIncome.RecordType.Name == property && assetIncome.Property_Value__c != null ){
            assetIncomeSummary.totalPropertyAmount += assetIncome.Property_Value__c;
            AssetsAndIncomes__c assetIncomeProperty = assetIncomePropertyMap.get(assetIncome.ID);
            assetIncomeDescription.writeStartObject();
            assetIncomeDescription.writeStringField('Type', String.IsNotBlank(assetIncome.Type__c) ?  assetIncome.Type__c  : ''  );
            if(String.isNotBlank(assetIncome.Locations__c)){
                assetIncomeDescription.writeStringField('Locations', assetIncome.Locations__c);
            }
            assetIncomeDescription.writeStringField('Country', String.IsNotBlank(assetIncome.Country__c) ? countryPicklistMap.get(assetIncome.Country__c)  : ''  );
            assetIncomeDescription.writeStringField('Currency', String.IsNotBlank(assetIncome.CurrencyIsoCode) ?  assetIncome.CurrencyIsoCode  : '' );
            assetIncomeDescription.writeStringField('Property Value', assetIncomeProperty.Property_Value__c != null ? (assetIncomeProperty.Property_Value__c.format()): '' );
            if(assetIncome.Amounts__c != null){
            	assetIncomeDescription.writeStringField('Income',  (assetIncomeProperty.Amounts__c.format()));
            }
            assetIncomeDescription.writeEndObject();
            assetIncomeSummary.propertyDescription += assetIncomeDescription.getAsString().replace('{','').replace('}','').replace('"','').replace(',','');
        }
        else if((assetIncome.RecordType.Name == ADDITIONAL_ACCOUNT && assetIncome.Amounts__c != null && (assetIncome.Main_Account__c || assetIncome.Bank_Name__c != null ))||
                (assetIncome.RecordType.Name == OTHER_INCOME && assetIncome.Amounts__c != null && (assetIncome.Other_Income_Type__c == BANK_DEPOSITS || assetIncome.Other_Income_Type__c == LIFE_SAVINGS ))){
                    assetIncomeSummary.totalAdditionalAccount += assetIncome.Amounts__c;
                    assetIncomeDescription.writeStartObject();
                    if(assetIncome.RecordType.Name == ADDITIONAL_ACCOUNT && !assetIncome.Main_Account__c){
                        AssetsAndIncomes__c assetIncomeAdditionalAccount = assetIncomeAdditionalAccountMap.get(assetIncome.ID);
                        assetIncomeSummary.bankAmount = assetIncomeAdditionalAccount.Amounts__c;
                        assetIncomeDescription.writeStringField('Description', assetIncome.RecordType.Name );
                    }
                    else if(assetIncome.RecordType.Name == ADDITIONAL_ACCOUNT && assetIncome.Main_Account__c){
                        AssetsAndIncomes__c assetIncomeAdditionalAccount = assetIncomeAdditionalAccountMap.get(assetIncome.ID);
                        assetIncomeSummary.bankAmount = assetIncomeAdditionalAccount.Amounts__c;
                        assetIncomeDescription.writeStringField('Main Bank Account', 'Yes');
                    }
                    else if(assetIncome.RecordType.Name == OTHER_INCOME){
                        AssetsAndIncomes__c assetIncomeOtherDeposits = assetIncomeOtherIncomeMap.get(assetIncome.ID);
                        assetIncomeSummary.bankAmount = assetIncomeOtherDeposits.Amounts__c;
                        assetIncomeDescription.writeStringField('Description', assetIncome.RecordType.Name);
                        assetIncomeDescription.writeStringField('Other Income Type', String.IsNotBlank(assetIncome.Other_Income_Type__c) ?  assetIncome.Other_Income_Type__c  : ''  );
                    }       
                    assetIncomeDescription.writeStringField('Bank Name', String.IsNotBlank(assetIncome.Bank_Name__c) ?  assetIncome.Bank_Name__c  : ''  );
                    if(String.isNotBlank(assetIncome.Account_Holder_Name__c)){
                        assetIncomeDescription.writeStringField('Account Holder Name', assetIncome.Account_Holder_Name__c );
                    }
                    if(String.IsNotBlank(assetIncome.Length_of_time__c)){
                    	assetIncomeDescription.writeStringField('Length of Time Account Held (yy/mm)', assetIncome.Length_of_time__c);
                    }
                    if(String.isNotBlank(assetIncome.Is_SBG_Account__c)){
                        assetIncomeDescription.writeStringField('Is SBG Account',  assetIncome.Is_SBG_Account__c );
                    }
                    if(String.isNotBlank(assetIncome.Locations__c)){
                        assetIncomeDescription.writeStringField('Locations', assetIncome.Locations__c);
                    }
                    assetIncomeDescription.writeStringField('Country', String.IsNotBlank(assetIncome.Country__c) ?  countryPicklistMap.get(assetIncome.Country__c)  : ''  );
                    assetIncomeDescription.writeStringField('Currency', String.IsNotBlank(assetIncome.CurrencyIsoCode) ?  assetIncome.CurrencyIsoCode  : '' );
                    assetIncomeDescription.writeStringField('Amount', assetIncomeSummary.bankAmount != null ? (assetIncomeSummary.bankAmount.format()): '' );
                    assetIncomeDescription.writeEndObject();
                    assetIncomeSummary.additionalAccountDescription += assetIncomeDescription.getAsString().replace('{','').replace('}','').replace('"','').replace(',','');
                }
                
                return assetIncomeSummary;
                                                  
			
    }
    
        /**
 	* @description Asset & Income Details Wrapper Class
 	*/
    public class AssetIncomeWrapper {
        
            public Double bankAmount = 0.0;
         	public Double totalPropertyAmount = 0.0;
            public Double totalAssetAmount = 0.0;
            public Double totalAdditionalAccount = 0.0;
            public String propertyDescription;
            public String assetDescription;
            public String additionalAccountDescription;
    }
    
    
    /**
   * @description This method provides other incomes for wealth accumulation
   * @param  whatOtherIncomesDoYouHave  	Other incomes in the application
   * @return String   						Other Incomes for Wealth Accumulation
   */
    public static String otherIncomeForWealth( String whatOtherIncomesDoYouHave) {
		
        String otherIncomesAccumulatedWealth;
        List<String> otherIncomesYouHaveList =  new List<String>();
        otherIncomesYouHaveList =  whatOtherIncomesDoYouHave.split(';');
        List<String> otherIncomesAccumulatedWealthList =  new List<String>();
        for (String otherIncomesYouHave : otherIncomesYouHaveList){
        	if(otherIncomesYouHave == other || otherIncomesYouHave == LOTTERY_BETTING_WINNINGS || 
        	otherIncomesYouHave == COMPENSATION_PAYMENT || otherIncomesYouHave == LOAN){
							
        		otherIncomesAccumulatedWealthList.add(otherIncomesYouHave);
        	}
        }
        otherIncomesAccumulatedWealth = otherIncomesAccumulatedWealthList.toString().remove('(').remove(')'); 

        return otherIncomesAccumulatedWealth;
    }
    
   /**
   * @description This method maps the Salesforce product name to Boost product short name 
   * @param  assetIncomeList  					List of Asset & Incomes
   * @param  assetIncomeAdditionalAccountMap  	Map of additional accounts in Asset & Income
   * @param  app  								Application record
   * @return DepositDetailWrapper   			Summary of deposit details object
   */
    public static DepositDetailWrapper depositDetails(List<AssetsAndIncomes__c> assetIncomeList, Map<Id, AssetsAndIncomes__c> assetIncomeAdditionalAccountMap, Application__c app) {
                                         
                                         
		
		AssetsAndIncomes__c mainAccount = new AssetsAndIncomes__c ();
		for(AssetsAndIncomes__c additionalAccount : assetIncomeAdditionalAccountMap.values()){
			if(additionalAccount.Main_Account__c){
				mainAccount = additionalAccount;
			}
        }
		DepositDetailWrapper deposits = new DepositDetailWrapper ();                                         
                                         
        if(String.IsNotBlank( app.Bank_Account_the_Deposit_will_be_Coming__c)){
                           
				deposits.depositBankName = assetIncomeAdditionalAccountMap.get(app.Bank_Account_the_Deposit_will_be_Coming__c).Bank_Name__c;
				deposits.depositCountry = assetIncomeAdditionalAccountMap.get(app.Bank_Account_the_Deposit_will_be_Coming__c).Country__c;
				deposits.depositAccountName = assetIncomeAdditionalAccountMap.get(app.Bank_Account_the_Deposit_will_be_Coming__c).Account_Holder_Name__c;
                deposits.depositMainAccount =  assetIncomeAdditionalAccountMap.get(app.Bank_Account_the_Deposit_will_be_Coming__c).Main_Account__c;
            }

        if(app.Future_Deposits_Funded_From__c == no){
                for(AssetsAndIncomes__c assetIncome : assetIncomeList){
                    if(assetIncome.Other_Income_Type__c == BANK_DEPOSITS &&
                       assetIncome.RecordType.Name == OTHER_INCOME && assetIncome.Is_future_fund__c){
                           
                        deposits.futureDepositBankName = assetIncome.Bank_Name__c;
            			deposits.futureDepositCountry = assetIncome.Country__c;
                		deposits.futureDepositAccountName = assetIncome.Account_Holder_Name__c;
                        deposits.futureDepositMethod = true;
                    }
                }
            }
            else if(app.Future_Deposits_Funded_From__c == yes){
                
                deposits.futureDepositBankName = deposits.depositBankName;
            	deposits.futureDepositCountry = deposits.depositCountry;
                deposits.futureDepositAccountName = deposits.depositAccountName;
				deposits.futureDepositMainAccount = deposits.depositMainAccount;
                deposits.futureDepositMethod = true;
            }
            
            return deposits;                             
    }
    
     /**
 	* @description Deposit Details Wrapper Wrapper Class
 	*/
    public class DepositDetailWrapper {
        
         	public String depositBankName;
            public String depositCountry;
            public String depositAccountName;
            public Boolean depositMainAccount = false;
            public String futureDepositBankName;
            public String futureDepositCountry;
            public String futureDepositAccountName;
            public Boolean futureDepositMainAccount = false;
            public Boolean futureDepositMethod = false;

    }

   /**
   * @description This method validates special characters in fields 
   * @param  regexCheckMap  	Map of fields to validate special characters
   * @return String   			Error message string
   */
    public static String errorMessage( Map<String, String> regexCheckMap){
                                         
        String regex = '[[A-Z][a-z][0-9] ./,:().?\'-]*';            
        Boolean regexCheckResult;
        Pattern specialCharacters = Pattern.compile(regex);
        List<String> errorMessageList = new List<String>();
        
        for(String key : regexCheckMap.keySet()){
            if(regexCheckMap.get(key) != null){
                Matcher matchCharacters = specialCharacters.matcher(regexCheckMap.get(key));
                regexCheckResult = matchCharacters.matches();
                
                if(!regexCheckResult){
                    
                    errorMessageList.add('{"Number":-300,"Value":"Pattern of \''+key+'\' is not valid"}');
                }
            }
        }
        String errorMessage = errorMessageList.toString().remove('(').remove(')');            
        return errorMessage;                             
    }

}