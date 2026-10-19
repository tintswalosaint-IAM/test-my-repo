/**
 * @description Boost Application Controller Class
 * @author November Sizwe
 * @date September 2022
 */
public with sharing class ICS_CTRL_BoostApplication  {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_Boost_Application');    
    
    private static final String NO  = 'No';
    private static final String YES  = 'Yes';
  	private static final String EMPTRY_STRING  = '';
    private static final String CORRESPONDENCE  = 'Correspondence';
    
    private static final String NAME_FIRST_SCHOOL = 'Name of 1st School';
    private static final String MOTHERS_MAIDEN_NAME = 'Mothers maiden name';
    private static final String FAVOURITE_SPORT_COLOUR = 'Favourite sport or colour';

    private static final String CURRENT_EMPLOYMENT = 'Current';
    private static final String PREVIOUS_EMPLOYMENT = 'Previous';
    
    private static final String EXPECTED_TURNOVER = 'Expected Turnover';
    private static final String COUNTRY = 'Country';
    private static final String PATTERN_OF = 'Pattern of';
  	private static final String NUMB ='Number'; 
  	private static final String NUMBER_X = 'numberX';

    
    private static final String PROPERTY = 'Property';
    private static final String ADDITIONAL_ACCOUNT = 'Additional Account';
    private static final String OTHER_INCOME= 'Other Income';
    private static final String ASSETS_INVESTMENTS_STOCKS = 'Assets/Investments/Stocks';
    private static final String WEALTH_IN_COUNTRY = 'Wealth in Country';
    private static final String SALARY_BONUS = 'Salary/Bonus'; 


    private static final String STRING_FREQUENCY = 'No further deposits to be made, just the initial payment';
    private static final String YEARLY_FREQUENCY = 'Yearly';

    private static final String HOUSE_PERSON = 'Houseperson';
    private static final String RETIRED = 'Retired';
    private static final String UNEMPLOYED  = 'Unemployed'; 
    private static final String IN_EDUCATION = 'In Education';

    private static final String REASON_A = 'Reason A';
    private static final String REASON_B = 'Reason B';
    private static final String REASON_C = 'Reason C';   
  	private static final String BUSINESS_TEAM = 'IPB_SA';

    /**
   * @description Boost Application Response Wrapper Class
   */
    public class BoostResponseWrapper {
        
        Boolean isSuccess;
        Integer boostResponseStatusCode;
        String sessionId;
        String applicationReference; 
        String boostResponseStatus;
        ErrorMessage[] errorMessage;
    }
    
    /**
   * @description  Error Message Object for Boost Application Response Wrapper Class
   */
    public class ErrorMessage {
        
        Integer numberX;
        String value;
    }
  

   /**
     * @description Invocable Method invoked by ICS Boost Application Submission flow
     * @param ids           Opportunity Id in List format related to application to be submitted to Boost
     * @return List of Results     Boost response is deserialized to Results list and
     */    
    @InvocableMethod(label='Get Application' description='Returns the application for the specified opportunity ID.' category='Opportunity')
    public static List<Results> getApplication(List<ID> ids) {

        String responseJSON = payloadJSON (ids[0]);
        Results boostResponse = new Results(); 
        List<Results> boostResponseList = new List<Results>();
        try{
      
            String responseJSONDeserialize = responseJSON.replace(NUMB, NUMBER_X);
            BoostResponseWrapper deserializeResponse = (BoostResponseWrapper)JSON.deserializeStrict(responseJSONDeserialize,BoostResponseWrapper.class);
            boostResponse.statusCodeResponse = deserializeResponse.boostResponseStatusCode;
            boostResponse.isSuccess = deserializeResponse.isSuccess;
            boostResponse.applicationReference = deserializeResponse.applicationReference;
            boostResponseList.add(boostResponse);
            
            if(deserializeResponse.ErrorMessage != null){
                LOGGER.error('Debug error response on getApplication: '+deserializeResponse.ErrorMessage);
                
                boostResponse.applicationInProgress = false;
                for(errorMessage error : deserializeResponse.ErrorMessage){
                    if(error.value.contains(PATTERN_OF) || error.value.contains(COUNTRY)){
                        
                        boostResponse.applicationInProgress = true;
                        boostResponse.errorList.add(error.value);

                  }
                }
                
            }
            
        }
        catch(Exception e){
            LOGGER.error('Error on getApplication', e); 
        }

        return boostResponseList;
        
    }
    
    /**
    * @description Results class with Invocable Variable returned to the ICS Boost Application Submission flow
    */   
    public class Results {
        
        @InvocableVariable(label = 'boostApplicationStatusCode')
        public Integer statusCodeResponse;
        @InvocableVariable(label = 'boostIsSuccess')
        public Boolean isSuccess;
        @InvocableVariable(label = 'boostApplicationReference')
        public String applicationReference;
        @InvocableVariable(label = 'boostApplicationInProgress')
        public Boolean applicationInProgress;
        @InvocableVariable(label = 'boostErrorList')
        public List<String> errorList = new List<String>();

    }
  
   /**
   * @description This method generates the JSON payload that will sent Boost as a request
   * @param  oppID    Opportunity id retrieved from flow
   * @return String     Payload JSON to be sent to Boost as a request
   */
    public static String payloadJSON (ID oppID) {
        
    JSONGenerator gen = JSON.createGenerator(true);
        String responseBody; 
        
        try{
      		ICS_SEL_Opportunity selectOpportunity = new ICS_SEL_Opportunity();
            Opportunity opp = selectOpportunity.getOpportunity(oppID);
           
           
            String accID = opp.Accountid;
            ICS_SEL_Account selectAccount = new ICS_SEL_Account();
      		Account acc = selectAccount.getAccount(accID);

      		ICS_SEL_Application selectApplication = new ICS_SEL_Application();
            List<Application__c> apps  = selectApplication.getApplications(oppID);
            Application__c app = apps[0];
            List<Application__c> appsConvertedCurrency  = selectApplication.getApplicationsConvertedCurrency(oppID);
            Application__c appConvertedCurrency = appsConvertedCurrency[0];
            String appID = app.ID;

            

      		ICS_SEL_ContactPointAddress selectContactPointAddress = new ICS_SEL_ContactPointAddress();
            List<ContactPointAddress> addressList = new List<ContactPointAddress>() ;
            addressList = selectContactPointAddress.getContactPointAddresses(accID);
            
            SEL_Sales_Code selectedSalesCode = new SEL_Sales_Code();
			List<Sales_Codes__c> allocatedCode = selectedSalesCode.getSalesCodesById(opp.Sales_Code__c);
            String salesCode;
            if(allocatedCode.size() != 0){
            	salesCode = allocatedCode[0].Name;
            }
            
             
            ICS_SEL_Contact selectContact = new ICS_SEL_Contact();
            String ifaBroker = String.IsNoTBlank(opp.ICS_IFA_Broker__c) ? selectContact.buildBrokerContactsQuery( opp.ICS_IFA_Broker__c)[0].ICS_TPI_Code__c : EMPTRY_STRING ;
            String privateBanker = String.IsNoTBlank(opp.ICS_Private_Banker__c) ? selectContact.buildBrokerContactsQuery( opp.ICS_Private_Banker__c)[0].ICS_TPI_Code__c  : EMPTRY_STRING ;
            String prestigeBanker = String.IsNoTBlank(opp.ICS_Prestige_Banker__c) ?selectContact.buildBrokerContactsQuery( opp.ICS_Prestige_Banker__c)[0].ICS_TPI_Code__c  : EMPTRY_STRING ;
            String sbfcBroker =  String.IsNoTBlank(opp.ICS_SBFC_Broker__c) ?selectContact.buildBrokerContactsQuery( opp.ICS_SBFC_Broker__c)[0].ICS_TPI_Code__c  : EMPTRY_STRING ;
      
            ICS_SEL_AccFutureFunding accFuture = new ICS_SEL_AccFutureFunding();
            List<Acc_Future_Funding__c> accfuturefunList = new List<Acc_Future_Funding__c>();
            accfuturefunList =  accFuture.getAccFutureList(appID);
            Acc_Future_Funding__c accFutureSelector = new Acc_Future_Funding__c ();
            if(accfuturefunList.size() != 0){
               accFutureSelector   = accfuturefunList[0]; 
            }
            
      		ICS_SEL_AssetAndIncome selectAssetAndIncome = new ICS_SEL_AssetAndIncome();
            List<AssetsAndIncomes__c> assetIncomeList = new List<AssetsAndIncomes__c>();
        	assetIncomeList = selectAssetAndIncome.getAssetIncomeConvertedCurrencyList(appID);

            List<AssetsAndIncomes__c> assetIncomePropertyList = new List<AssetsAndIncomes__c>();
            assetIncomePropertyList = selectAssetAndIncome.getAssetIncomeList(appID,PROPERTY );
            Map<Id, AssetsAndIncomes__c> assetIncomePropertyMap = new Map<Id, AssetsAndIncomes__c>(assetIncomePropertyList);
                  
            List<AssetsAndIncomes__c> assetIncomeAdditionalAccountList = new List<AssetsAndIncomes__c>();
            assetIncomeAdditionalAccountList = selectAssetAndIncome.getAssetIncomeList(appID,ADDITIONAL_ACCOUNT);
            Map<Id, AssetsAndIncomes__c> assetIncomeAdditionalAccountMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeAdditionalAccountList);
            
            List<AssetsAndIncomes__c> assetIncomeOtherIncomeList = new List<AssetsAndIncomes__c>();
            assetIncomeOtherIncomeList = selectAssetAndIncome.getAssetIncomeList(appID,OTHER_INCOME);
            Map<Id, AssetsAndIncomes__c> assetIncomeOtherIncomeMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeOtherIncomeList);
                  
            List<AssetsAndIncomes__c> assetIncomeInvestmentsList = new List<AssetsAndIncomes__c>();
            assetIncomeInvestmentsList = selectAssetAndIncome.getAssetIncomeList(appID,ASSETS_INVESTMENTS_STOCKS);
            Map<Id, AssetsAndIncomes__c> assetIncomeInvestmentsMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeInvestmentsList);

            List<AssetsAndIncomes__c> assetIncomeCountryWealthList = new List<AssetsAndIncomes__c>();
            assetIncomeCountryWealthList = selectAssetAndIncome.getAssetIncomeList(appID,WEALTH_IN_COUNTRY);
            Map<Id, AssetsAndIncomes__c> assetIncomeCountryWealthMap = new Map<Id, AssetsAndIncomes__c>(assetIncomeCountryWealthList);
            
            Map<String, Map<Id, AssetsAndIncomes__c>> assetIncomeMaps = new Map<String, Map<Id, AssetsAndIncomes__c>>();
            assetIncomeMaps.put(PROPERTY, assetIncomePropertyMap);
            assetIncomeMaps.put(ADDITIONAL_ACCOUNT, assetIncomeAdditionalAccountMap);
            assetIncomeMaps.put(OTHER_INCOME, assetIncomeOtherIncomeMap);
            assetIncomeMaps.put(ASSETS_INVESTMENTS_STOCKS, assetIncomeInvestmentsMap);
            assetIncomeMaps.put(WEALTH_IN_COUNTRY, assetIncomeCountryWealthMap);

            String otherDescription;
            String otherIncomesAccumulatedWealth;   
            if(String.IsNoTBlank(app.Intent_to_Future_Deposits_Funds__c)){
              otherDescription =  ICS_CTRL_BoostApplicationHelper.otherDescriptionFutureDepositsFund(app.Intent_to_Future_Deposits_Funds__c) ;
            }
            if(String.IsNoTBlank(app.What_Other_Incomes_Do_You_Have__c)){
              otherIncomesAccumulatedWealth = ICS_CTRL_BoostApplicationHelper.otherIncomeForWealth(app.What_Other_Incomes_Do_You_Have__c);
            }
            
            List<Schema.PicklistEntry> countryPicklistValues = Schema.SObjectType.AssetsAndIncomes__c.fields.Country__c.getPicklistValues();
            Map<String, String> countryPicklistMap = new Map<String, String>(); 
            for (Schema.PicklistEntry picklistEntry : countryPicklistValues) 
            { 
                    countryPicklistMap.put(picklistEntry.getValue(), picklistEntry.getLabel()); 
            }
            
            List<AssetsAndIncomes__c> salaryBonusConvertedCurrencyList = new List<AssetsAndIncomes__c>();
            Double totalPropertyAmount = 0.0;
            Double totalAssetAmount = 0.0;
            Double totalAdditionalAccount = 0.0;
            String propertyDescription;
            String assetDescription;
            String additionalAccountDescription;
            Double  expectedAnnualTurnover;
            String  expectedAnnualTurnoverCurrency;  
            
            for( AssetsAndIncomes__c assetIncome : assetIncomeList){
                 if( assetIncome.Is_listed_in_assets__c != NO){
                    
                    ICS_CTRL_BoostApplicationHelper.AssetIncomeWrapper assetIncomeSummary = new ICS_CTRL_BoostApplicationHelper.AssetIncomeWrapper();
                    assetIncomeSummary = ICS_CTRL_BoostApplicationHelper.assetIncomeDescription(assetIncome, countryPicklistMap, assetIncomeMaps);
                     
                    totalAssetAmount += assetIncomeSummary.totalAssetAmount;
                    totalPropertyAmount += assetIncomeSummary.totalPropertyAmount;
                    totalAdditionalAccount += assetIncomeSummary.totalAdditionalAccount;
                    if(String.IsNotBlank(assetIncomeSummary.assetDescription)){ 
                         assetDescription += assetIncomeSummary.assetDescription.replace('null',EMPTRY_STRING) + '\n' ;
                    }
                     if(String.IsNotBlank(assetIncomeSummary.propertyDescription)){ 
                         propertyDescription += assetIncomeSummary.propertyDescription.replace('null',EMPTRY_STRING) + '\n' ;
                    }
                    if(String.IsNotBlank(assetIncomeSummary.additionalAccountDescription)){ 
                         additionalAccountDescription += assetIncomeSummary.additionalAccountDescription.replace('null',EMPTRY_STRING) + '\n' ;
                    }
                     
                     if(assetIncome.Other_Income_Type__c == SALARY_BONUS){
                         salaryBonusConvertedCurrencyList.add(assetIncome);
                     }
                 }
                if(assetIncome.RecordType.Name == EXPECTED_TURNOVER){
                   
                    expectedAnnualTurnover = assetIncome.Expected_Annual_Yearly_Turnover_To__c;
                    expectedAnnualTurnoverCurrency = UserInfo.getDefaultCurrency();
                }
            }
			
            ICS_SEL_FinServ_Employment selectEmployment = new ICS_SEL_FinServ_Employment();
            List<FinServ__Employment__c> employmentConvertedCurrencyList = new List<FinServ__Employment__c>() ;
            List<FinServ__Employment__c> previousEmploymentConvertedCurrencyList = new List<FinServ__Employment__c>() ;
            employmentConvertedCurrencyList = selectEmployment.getEmploymentConvertedCurrencyList(accID,CURRENT_EMPLOYMENT);
            previousEmploymentConvertedCurrencyList = selectEmployment.getEmploymentConvertedCurrencyList(accID,PREVIOUS_EMPLOYMENT);
            List<FinServ__Employment__c> employmentList = new List<FinServ__Employment__c>() ;
            List<FinServ__Employment__c> previousEmploymentList = new List<FinServ__Employment__c>() ;
            employmentList = selectEmployment.getEmployment(accID,CURRENT_EMPLOYMENT);
            previousEmploymentList = selectEmployment.getEmployment(accID,PREVIOUS_EMPLOYMENT);

            
            
            ICS_CTRL_BoostApplicationHelper.EmploymentIncomeWrapper annualEmploymentIncome = new ICS_CTRL_BoostApplicationHelper.EmploymentIncomeWrapper();
            annualEmploymentIncome = ICS_CTRL_BoostApplicationHelper.annualIncomeCalculation(previousEmploymentConvertedCurrencyList, employmentConvertedCurrencyList, salaryBonusConvertedCurrencyList);
            String employmentType = annualEmploymentIncome.employmentType;
            Decimal totalAnnualEarnings = annualEmploymentIncome.totalAnnualEarnings;
            String annualIncomeCurrency = annualEmploymentIncome.annualIncomeCurrency;
            List<String> accountCurrencies = new List<String>();
            if(String.isNotBlank(opp.Bank_Account_Currency__c)){
      	      accountCurrencies = opp.Bank_Account_Currency__c.split(';');
       		}
            
            
            AssetsAndIncomes__c mainAccount = new AssetsAndIncomes__c ();
            for(AssetsAndIncomes__c additionalAccount : assetIncomeAdditionalAccountList){
                if(additionalAccount.Main_Account__c){
                    mainAccount = additionalAccount;
                }
            }
            
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
            
      		Boolean correspondenceAddress = false;
      		Boolean currentAddress = false;
            String jurisdictionReason = opp.ICS_Reason_for_acc_in_this_jurisdiction__c.replace(';',', ').replace('–',' ');
            String purpose = opp.ICS_Purpose_of_opening_Account__c.replace(';',', ').replace('–',' ');

            String previousAddressPostCode;
     		String deliveryAddressPostCode  = app.Delivery_Postcode__c;
      		String motherMaidenName = app.Former_Name__c;
      		String favouriteSportOrColour = app.Favorite_Sport_or_Colour__c;
      		String codeWord = app.Code_Word__c;
            String firstSchoolName = app.First_School_Name__c;

            

            gen.writeStartObject();
                gen.writeFieldName('SearchData');
                gen.writeStartObject();
          		gen.writeBooleanField('TaxCertificate', app.Annual_Tax_Certificate__c == yes.toUpperCase()? true : false);
                gen.writeBooleanField('TelephoneFax', app.Customer_Instruct_Declaration__c);
                if(totalAnnualEarnings != null ){
                	gen.writeFieldName('TotalAnnualEarnings');
                    gen.writeStartObject();
                        gen.writeNumberField('Amount', totalAnnualEarnings != null  ? totalAnnualEarnings.round() : 0 );
                      gen.writeStringField('Currency', String.IsNoTBlank(annualIncomeCurrency) ?  annualIncomeCurrency : EMPTRY_STRING);
                    gen.writeEndObject();
                }
                    gen.writeFieldName('FinanceDetails');
                    gen.writeStartObject();
                      gen.writeStringField('ProductType', ICS_CTRL_BoostApplicationHelper.boostProductMap(opp.ICS_Product_Type__c));
                      gen.writeStringField('Purpose',String.IsNoTBlank(opp.ICS_Purpose_of_opening_Account__c) ? purpose : EMPTRY_STRING);
                    gen.writeEndObject();
                    gen.writeFieldName('StandardBank');
                    gen.writeStartObject();
                            gen.writeFieldName('AdditionalInformation');
                            gen.writeStartObject();
                                  gen.writeBooleanField('DoNotContact', !app.Customer_Data_Usage__c);
                            gen.writeEndObject();
                          gen.writeStringField('BusinessTeam', BUSINESS_TEAM);
                          gen.writeStringField('OffshoreManager', String.IsNoTBlank(salesCode) ?salesCode : EMPTRY_STRING);
                          gen.writeStringField('BrokerConsultant', String.IsNoTBlank(privateBanker) ? privateBanker : (String.IsNoTBlank(prestigeBanker) ?prestigeBanker : EMPTRY_STRING));
                          gen.writeStringField('IntroducerCode',  String.IsNoTBlank(ifaBroker) ? ifaBroker : (String.IsNoTBlank(sbfcBroker) ?sbfcBroker : EMPTRY_STRING));
                          gen.writeStringField('JurisdictionReason',String.IsNoTBlank(opp.ICS_Reason_for_acc_in_this_jurisdiction__c) ? jurisdictionReason : EMPTRY_STRING);
                    gen.writeEndObject();

                    gen.writeFieldName('Accounts');
                    gen.writeStartArray();
                    gen.writeStartObject();
                        gen.writeStringField('Name', ICS_CTRL_BoostApplicationHelper.boostProductMap(opp.ICS_Product_Type__c));
                        gen.writeStringField('Type', ICS_CTRL_BoostApplicationHelper.boostProductShortNameMap(opp.ICS_Product_Type__c));
                        gen.writeFieldName('Currencies');
                        gen.writeStartArray();
                        for(String accountCurrency : accountCurrencies){
                              gen.writeString(String.IsNoTBlank(accountCurrency) ? accountCurrency.replace('US Dollar','USD').replace('Euro','EUR').
                                                                                   replace('AU Dollar','AUD').replace('Sterling','GBP'): EMPTRY_STRING );
                        }
                        gen.writeEndArray();
            
                        if(app.Debit_Visa_Card__c == YES){
                        gen.writeFieldName('DebitCard');
                        gen.writeStartObject();
                            gen.writeFieldName('CardApplicants');
                            gen.writeStartArray();
                            gen.writeStartObject();
                            gen.writeNumberField('SequenceNo', 1);
                                gen.writeFieldName('Currencies');
                                gen.writeStartArray();
                                for(String accountCurrency : accountCurrencies){
                                  gen.writeString(String.IsNoTBlank(accountCurrency) ? accountCurrency.replace('US Dollar','USD').replace('Euro','EUR').
                                                                                       replace('AU Dollar','AUD').replace('Sterling','GBP'): EMPTRY_STRING );
                                }
                                gen.writeEndArray();
                            gen.writeEndObject();
                            gen.writeEndArray();
                        gen.writeEndObject();
                        }
            
                    gen.writeEndObject();
                    gen.writeEndArray();
            
        
                    gen.writeFieldName('Deposit');
                    gen.writeStartObject();
                   if(app.Initial_Deposit_by_Bank__c == yes.toUpperCase()){                       
                           gen.writeStringField('Method', 'Transfer' );
                       }
                       gen.writeBooleanField('OwnAccount', app.Your_Own_Bank_Account__c == yes.toUpperCase() ? true : false);
                       gen.writeBooleanField('MainAccount', depositMainAccount  ? true : false);
                       gen.writeStringField('SourceOfFunds', String.isNotBlank(app.Whom_Account_Belongs__c) ||  String.isNotBlank(app.Relationship_to_you__c)? app.Whom_Account_Belongs__c +', ' + app.Relationship_to_you__c  : EMPTRY_STRING);
                       if(app.First_Deposit_Amount__c != null){
					   gen.writeFieldName('Initial');
                       gen.writeStartObject();
                            gen.writeNumberField('Amount',  appConvertedCurrency.First_Deposit_Amount__c != null ? appConvertedCurrency.First_Deposit_Amount__c : 0 );
                            gen.writeStringField('Currency',  appConvertedCurrency.First_Deposit_Amount__c != null ?  UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                       gen.writeEndObject();
                       }
                       gen.writeFieldName('Bank');
                       gen.writeStartObject();
                            gen.writeStringField('BankName', String.IsNotBlank(depositBankName) ? depositBankName : EMPTRY_STRING );
                            gen.writeStringField('AccountName', String.IsNotBlank(depositAccountName) ? depositAccountName : EMPTRY_STRING);
                            gen.writeFieldName('BankAddress');
                            gen.writeStartObject();
                                gen.writeStringField('Country', String.IsNotBlank(depositCountry) ?  depositCountry: EMPTRY_STRING);
                            gen.writeEndObject();
                       gen.writeEndObject();
                    gen.writeEndObject();
                    gen.writeFieldName('FutureDeposits');
                    gen.writeStartObject();
                        gen.writeFieldName('FutureSource');
                        gen.writeStartObject();
                        if(String.IsNotBlank(app.Intent_to_Future_Deposits_Funds__c)){
                            gen.writeBooleanField('BankDeposits', app.Intent_to_Future_Deposits_Funds__c.contains('Life Savings')|| 
                                                  app.Intent_to_Future_Deposits_Funds__c.contains('Bank Deposits') ?   true : false);
                            gen.writeBooleanField('Salary', app.Intent_to_Future_Deposits_Funds__c.contains('Salary/Bonus') ?   true : false);
                            gen.writeBooleanField('BusinessDividends', app.Intent_to_Future_Deposits_Funds__c.contains('Business Dividends') ? true : false);
                            gen.writeBooleanField('PensionPayments', app.Intent_to_Future_Deposits_Funds__c.contains('Pension Payments')|| 
                                                  app.Intent_to_Future_Deposits_Funds__c.contains('Pensions/Retirement') ?   true : false);
                            gen.writeBooleanField('SaleOfBusiness', app.Intent_to_Future_Deposits_Funds__c.contains('Sale of Business') ? true : false);
                            gen.writeBooleanField('SaleOfProperty', app.Intent_to_Future_Deposits_Funds__c.contains('Sale of Property') ? true : false);
                            gen.writeBooleanField('Investments', app.Intent_to_Future_Deposits_Funds__c.contains('Investments') ||
                                                           app.Intent_to_Future_Deposits_Funds__c.contains('Investment/Dividend') ? true : false);
                            gen.writeBooleanField('Other',  app.Intent_to_Future_Deposits_Funds__c.contains('Compensation Payment')||
                                                            app.Intent_to_Future_Deposits_Funds__c.contains('Loan')||
                                                            app.Intent_to_Future_Deposits_Funds__c.contains('Lottery/Betting Winnings') ||
                                                            app.Intent_to_Future_Deposits_Funds__c.contains(' Maturity of Insurance Policy or Fixed Term Investment') ||
                                                            app.Intent_to_Future_Deposits_Funds__c.contains('Other Income')||
                                                            app.Intent_to_Future_Deposits_Funds__c.contains('Inheritance')? true : false);
             				gen.writeStringField('OtherDescription',  String.IsNotBlank(otherDescription) ?  otherDescription : EMPTRY_STRING);                      
                        }
                        gen.writeEndObject(); 
                        gen.writeStringField('Frequency', String.IsNotBlank(app.Frequency_Future_Deposits__c) && (STRING_FREQUENCY != app.Frequency_Future_Deposits__c)?
                                             ((app.Frequency_Future_Deposits__c == 'Annually') ?  YEARLY_FREQUENCY : app.Frequency_Future_Deposits__c) : 'Never');
                        if(!app.Frequency_Future_Deposits__c.contains('No further deposits')){
                            gen.writeFieldName('Amount');
                         		gen.writeStartObject();
                            		gen.writeNumberField('Amount',  expectedAnnualTurnover != null ? expectedAnnualTurnover : 0 );
                            		gen.writeStringField('Currency',  String.IsNotBlank(expectedAnnualTurnoverCurrency) ?  expectedAnnualTurnoverCurrency : EMPTRY_STRING);
                         		gen.writeEndObject();
                        }
                  		gen.writeFieldName('BankDetails');
                        gen.writeStartObject();
                    	if(futureDepositMethod){
                        gen.writeStringField('Method',  'Transfer' );        
                             gen.writeBooleanField('OwnAccount', true);
                            }
                     if(String.isNotBlank(accFutureSelector.Whom_Account_Belongs__c) ||  String.isNotBlank(accFutureSelector.Relationship_to_you__c)){
                        gen.writeStringField('Method',  'Transfer' );        
                            }
                           gen.writeBooleanField('MainAccount', futureDepositMainAccount ? true : false);
                           gen.writeStringField('SourceOfFunds', String.isNotBlank(accFutureSelector.Whom_Account_Belongs__c) ||  String.isNotBlank(accFutureSelector.Relationship_to_you__c)? accFutureSelector.Whom_Account_Belongs__c +', ' + accFutureSelector.Relationship_to_you__c  : EMPTRY_STRING);
                           gen.writeFieldName('Bank');
                           gen.writeStartObject();
                              gen.writeStringField('BankName', String.IsNotBlank( futureDepositBankName) ? futureDepositBankName :  EMPTRY_STRING);
                              gen.writeStringField('AccountName', String.IsNotBlank(futureDepositAccountName) ?  futureDepositAccountName : EMPTRY_STRING);
                              gen.writeFieldName('BankAddress');
                              gen.writeStartObject();
                                  gen.writeStringField('Country', String.IsNotBlank(futureDepositCountry) ? futureDepositCountry : EMPTRY_STRING );
                              gen.writeEndObject();
                          gen.writeEndObject();   
                      gen.writeEndObject();   
                   gen.writeEndObject();   
            
                    gen.writeFieldName('Wealth');
                    gen.writeStartObject();
                        gen.writeFieldName('Property');
                        gen.writeStartObject();
                            gen.writeStringField('Currency', totalPropertyAmount != 0 ? UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                            gen.writeNumberField('Amount1',totalPropertyAmount != 0 ?  totalPropertyAmount.round() : 0);
                            gen.writeStringField('Description', String.IsNotBlank(propertyDescription) ?  propertyDescription.replace('null\n',EMPTRY_STRING)  : EMPTRY_STRING);
                        gen.writeEndObject();
                        gen.writeFieldName('Assets');
                        gen.writeStartObject();
                            gen.writeStringField('Currency', totalAssetAmount != 0 ? UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                            gen.writeNumberField('Amount1',totalAssetAmount != 0 ?  totalAssetAmount.round() : 0);
                            gen.writeStringField('Description', String.IsNotBlank(assetDescription) ?  assetDescription.replace('null\n',EMPTRY_STRING)  : EMPTRY_STRING);
                        gen.writeEndObject();
                        gen.writeFieldName('BankDeposits');
                        gen.writeStartObject();
                            gen.writeStringField('Currency', totalAdditionalAccount != 0 ? UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                            gen.writeNumberField('Amount1',totalAdditionalAccount != 0 ?  totalAdditionalAccount.round() : 0);
                            gen.writeStringField('Description', String.IsNotBlank(additionalAccountDescription) ?  additionalAccountDescription.replace('null\n',EMPTRY_STRING)  : EMPTRY_STRING);
                        gen.writeEndObject();
                        gen.writeBooleanField('AccumulatedOver1to4', app.How_many_years_Wealth_been_accumulated__c == '1-4 years' ?   true : false);
                        gen.writeBooleanField('AccumulatedOver5to9', app.How_many_years_Wealth_been_accumulated__c == '5-9 years' ?   true : false);
                        gen.writeBooleanField('AccumulatedOver10', app.How_many_years_Wealth_been_accumulated__c == '10+ years' ?   true : false);
                        if(String.IsNotBlank(app.How_have_you_accumulated_your_wealth__c)){
                        	gen.writeBooleanField('AccumulatedSavings', (app.How_have_you_accumulated_your_wealth__c.contains('Savings (from salary)') )?   true : false);
                        	gen.writeBooleanField('AccumulatedBonus', app.How_have_you_accumulated_your_wealth__c.contains('Bonus') ?   true : false);
                        	gen.writeBooleanField('AccumulatedAsset', app.How_have_you_accumulated_your_wealth__c.contains('Asset / Property sale') ? true : false);
                        	gen.writeBooleanField('AccumulatedOther', app.How_have_you_accumulated_your_wealth__c.contains('Other') ? true : false);
                        	gen.writeBooleanField('AccumulatedPension', app.How_have_you_accumulated_your_wealth__c.contains('Redundancy / Pension') ? true : false);
                       	 	gen.writeBooleanField('AccumulatedGift', app.How_have_you_accumulated_your_wealth__c.contains('Gift / Inheritance') ? true : false);
                        	gen.writeStringField('AccumulatedOtherDesc',  String.IsNotBlank(app.Other_Source_of_Wealth__c) ?  app.Other_Source_of_Wealth__c.replace('\r\n', EMPTRY_STRING) : EMPTRY_STRING);                      
                        }
                        gen.writeBooleanField('DisclosedAllAssets', app.Declaration_you_have_fully_disclosed__c ? true : false);
                    gen.writeEndObject();   
                    gen.writeFieldName('Applicants');
                    gen.writeStartArray();
                    gen.writeStartObject();
                  gen.writeBooleanField('NoBankAccount', app.Has_a_Bank_Account__c.contains(yes) ? false : true);
                            gen.writeFieldName('BankDetails');
                            gen.writeStartObject();
                                gen.writeFieldName('TimeWithBank');
                                gen.writeStartObject();
                                        gen.writeNumberField('Years',   String.IsNotBlank(mainAccount.Length_of_time__c) ?  Integer.valueOf(mainAccount.Length_of_time__c.left(2)) : 0);
                                        gen.writeNumberField('Months',  String.IsNotBlank(mainAccount.Length_of_time__c) && Integer.valueOf(mainAccount.Length_of_time__c.right(2))<12 ?  Integer.valueOf(mainAccount.Length_of_time__c.right(2)) :0);
                                gen.writeEndObject();
                                gen.writeStringField('AccountName', String.IsNotBlank(mainAccount.Account_Holder_Name__c) ?  mainAccount.Account_Holder_Name__c : EMPTRY_STRING);
                                gen.writeStringField('BankName', String.IsNotBlank(mainAccount.Bank_Name__c) ?  mainAccount.Bank_Name__c : EMPTRY_STRING);
                                gen.writeFieldName('BankAddress');
                                gen.writeStartObject();
                                    gen.writeStringField('Country', String.IsNotBlank(mainAccount.Country__c) ?  mainAccount.Country__c : EMPTRY_STRING);
                                    gen.writeStringField('City', String.IsNotBlank(mainAccount.Locations__c) ?  mainAccount.Locations__c : EMPTRY_STRING);
                                gen.writeEndObject();
                            gen.writeEndObject();               
                        gen.writeFieldName('SecurityDetails');
                        gen.writeStartObject();
                            gen.writeStringField('Password', String.IsNoTBlank(app.Code_Word__c) ?app.Code_Word__c : EMPTRY_STRING);
                            gen.writeFieldName('Questions');
                            gen.writeStartArray();
                            gen.writeStartObject();
                                gen.writeStringField('Question', NAME_FIRST_SCHOOL ); 
                                gen.writeStringField('Answer', String.IsNoTBlank(app.First_School_Name__c) ?app.First_School_Name__c : EMPTRY_STRING);
                            gen.writeEndObject();
                            gen.writeStartObject();
                                gen.writeStringField('Question', MOTHERS_MAIDEN_NAME); 
                                gen.writeStringField('Answer', String.IsNoTBlank(app.Former_Name__c) ?app.Former_Name__c : EMPTRY_STRING);
                            gen.writeEndObject();       
                            gen.writeStartObject();
                                gen.writeStringField('Question', FAVOURITE_SPORT_COLOUR);
                                gen.writeStringField('Answer', String.IsNoTBlank(app.Favorite_Sport_or_Colour__c) ?app.Favorite_Sport_or_Colour__c : EMPTRY_STRING);
                            gen.writeEndObject();
                            gen.writeEndArray();                       
                        gen.writeEndObject(); 
                        
                        gen.writeFieldName('PersonalDetails');
                        gen.writeStartObject();
                            gen.writeDateField('DateOfBirth',  acc.PersonBirthdate != null ? acc.PersonBirthdate : date.valueOf(EMPTRY_STRING));
            
                            if(acc.FinServ__Gender__pc != 'Unknown'){
                				gen.writeStringField('Gender', String.IsNoTBlank(acc.FinServ__Gender__pc) ? acc.FinServ__Gender__pc : EMPTRY_STRING);
                            }
                            gen.writeStringField('MaritalStatus', String.IsNoTBlank(acc.FinServ__MaritalStatus__pc) ? acc.FinServ__MaritalStatus__pc : EMPTRY_STRING);
                            gen.writeStringField('CountryOfResidence', String.IsNoTBlank(acc.ICS_Country_of_Residence__c) ? acc.ICS_Country_of_Residence__c :EMPTRY_STRING);
                            gen.writeStringField('CountryOfBirth', String.IsNoTBlank(acc.FinServ__CountryOfBirth__pc) ? acc.FinServ__CountryOfBirth__pc : EMPTRY_STRING);
                            gen.writeStringField('PlaceOfBirth', String.IsNoTBlank(acc.Town_City_of_Birth__c) ? acc.Town_City_of_Birth__c : EMPTRY_STRING);
                            gen.writeStringField('IDNumber', String.IsNoTBlank(acc.Passport_Number__c) &&  acc.Identification_or_Passport_Number__c == 'Passport Number'? acc.Passport_Number__c : acc.Identification_Number__c);
                            gen.writeStringField('PassportNumber', String.IsNoTBlank(acc.Passport_Number__c) ? acc.Passport_Number__c : EMPTRY_STRING);
               				gen.writeStringField('Nationality', String.IsNoTBlank(acc.ICS_Country_of_Nationality__c) ? acc.ICS_Country_of_Nationality__c : EMPTRY_STRING);
                            gen.writeStringField('DualNationality', String.IsNoTBlank(acc.Second_Country_of_Nationality__c) ? acc.Second_Country_of_Nationality__c : EMPTRY_STRING);
              				gen.writeFieldName('Name');
                            gen.writeStartObject();
                                gen.writeStringField('Title', String.IsNoTBlank(acc.Salutation) ? acc.Salutation.replace('.',EMPTRY_STRING) : EMPTRY_STRING);
                                gen.writeStringField('Forename', String.IsNoTBlank(acc.FirstName) ? acc.FirstName : EMPTRY_STRING);
                                gen.writeStringField('MiddleNames', String.IsNoTBlank(acc.MiddleName) ? acc.MiddleName : EMPTRY_STRING);
                                gen.writeStringField('Surname', String.IsNoTBlank(acc.LastName) ? acc.LastName : EMPTRY_STRING);
                            gen.writeEndObject();
                    
            
                    List<String> formerNames = new List<String>();
                    formerNames.add(acc.Former_Name__c);
                    formerNames.add(acc.Maiden_Name__c);
                    formerNames.add(acc.Former_Names_Maiden_Name__c);
                            gen.writeFieldName('Aliases');
                            gen.writeStartArray();
                    for(String formerName : formerNames){
                                if (String.IsNoTBlank(formerName)){
                                   gen.writeStartObject();
                                    gen.writeStringField('Surname', formerName);
                                gen.writeEndObject();
                              }
                            }
              		gen.writeEndArray();
           
                            List <String> otherNames  = new List <String>(); 
                            otherNames.add(acc.Different_FirstName__c);
                            otherNames.add(acc.Different_MiddleName__c);
                            otherNames.add(acc.Different_LastName__c);
                            gen.writeFieldName('OtherNames');
                            gen.writeStartArray();
                            for(String anotherName : otherNames){
                                if (String.IsNoTBlank(anotherName)){
                                    gen.writeStartObject();
                   					  gen.writeStringField('Number', String.valueOf(otherNames.indexOf(anotherName) + 1));
                                      gen.writeStringField('Value', anotherName);
                  					gen.writeEndObject(); 
                              }
                            }
                            gen.writeEndArray();
                            
                            gen.writeFieldName('EmailAddresses');
                            gen.writeStartArray();
                            gen.writeStartObject();
                                gen.writeStringField('Type', 'Home');
                                gen.writeStringField('Value', String.IsNoTBlank(acc.PersonEmail) ? acc.PersonEmail : EMPTRY_STRING);
                            gen.writeEndObject();
                            gen.writeEndArray();
                            gen.writeFieldName('PhoneNumbers');
                            gen.writeStartArray();
                            gen.writeStartObject();
                                gen.writeStringField('Type', 'mobile');
                                gen.writeStringField('Value', String.IsNoTBlank(acc.Phone) ? acc.Phone : EMPTRY_STRING);
                                gen.writeStringField('Country', String.IsNoTBlank(acc.ICS_Country_Code__c) ?  [SELECT ISO_Code__c FROM Country_Codes__mdt WHERE Country_Phone_Code__c =: acc.ICS_Country_Code__c LIMIT 1].ISO_Code__c : EMPTRY_STRING);
                            gen.writeEndObject();
                           if(acc.Alternative_Phone_Nubmer_Type__c == 'Home Contact Number'){
                           gen.writeStartObject();
                                gen.writeStringField('Type', 'home');
                                gen.writeStringField('Value', String.IsNoTBlank(acc.Alternative_Phone__c) ? acc.Alternative_Phone__c: EMPTRY_STRING);
                                gen.writeStringField('Country', String.IsNoTBlank(acc.Alternative_Phone_Country_Code__c) ?  [SELECT ISO_Code__c FROM Country_Codes__mdt WHERE Country_Phone_Code__c =: acc.Alternative_Phone_Country_Code__c LIMIT 1].ISO_Code__c : EMPTRY_STRING);
                           gen.writeEndObject();
                           }else  if(acc.Alternative_Phone_Nubmer_Type__c == 'Work Contact Number'){
                           gen.writeStartObject();
                                gen.writeStringField('Type', 'work');
                                gen.writeStringField('Value', String.IsNoTBlank(acc.Alternative_Phone__c) ? acc.Alternative_Phone__c: EMPTRY_STRING);
                                gen.writeStringField('Country', String.IsNoTBlank(acc.Alternative_Phone_Country_Code__c) ?  [SELECT ISO_Code__c FROM Country_Codes__mdt WHERE Country_Phone_Code__c =: acc.Alternative_Phone_Country_Code__c LIMIT 1].ISO_Code__c : EMPTRY_STRING);
                            gen.writeEndObject();
                            }
                            gen.writeEndArray();
                     
                          gen.writeFieldName('CurrentAddress');
                            gen.writeStartObject();
                            for(ContactPointAddress address :addressList){
                                if(address.AddressType   == 'Current Residential' && !currentAddress){
                                      currentAddress = true;
                                        gen.writeStringField('Country',  String.IsNoTBlank(address.Country__c ) ?  address.Country__c  : acc.ICS_Country_of_Residence__c);
                                        gen.writeStringField('PostCode', String.IsNoTBlank (address.Postcode__c) ?  address.Postcode__c : EMPTRY_STRING);
                                        gen.writeStringField('Line1', String.IsNoTBlank(address.Address_Line_1__c) ? address.Address_Line_1__c : EMPTRY_STRING);
                                        gen.writeStringField('Line2',  String.IsNoTBlank( address.Address_Line_2__c) ?   address.Address_Line_2__c : EMPTRY_STRING);
                                        gen.writeStringField('Line3',  String.IsNoTBlank( address.Address_Line_3__c) ?   address.Address_Line_3__c : EMPTRY_STRING);
                                        gen.writeStringField('Line4',  String.IsNoTBlank( address.Address_Line_4__c) ? address.Address_Line_4__c : EMPTRY_STRING);
                                    	if(String.IsNoTBlank(String.ValueOf(address.Start_Date__c))){
										gen.writeFieldName('TimeAtAddress');
                                        gen.writeStartObject();
                                                gen.writeStringField('Years',   String.IsNoTBlank(String.ValueOf(address.Start_Date__c)) ? ICS_CTRL_BoostApplicationHelper.lengthOfTime(address.Start_Date__c, date.today())[0] : '0');
                                                gen.writeStringField('Months', String.IsNoTBlank(String.ValueOf(address.Start_Date__c)) ? ICS_CTRL_BoostApplicationHelper.lengthOfTime(address.Start_Date__c, date.today())[1] :'0');
                                        gen.writeEndObject();
                                    	}                                    
                                }
                            }
                            gen.writeEndObject();

                    
                            gen.writeFieldName('PreviousAddresses');
                            gen.writeStartArray();
                                for(ContactPointAddress address :addressList){
                                    if(address.AddressType   == 'Previous Residential'){
                                        previousAddressPostCode =  address.Postcode__c;
                                        gen.writeStartObject();
                                            gen.writeStringField('Country',  String.IsNoTBlank(address.Country__c ) ?  address.Country__c  : EMPTRY_STRING);
                                            gen.writeStringField('PostCode', String.IsNoTBlank (address.Postcode__c) ?  address.Postcode__c : EMPTRY_STRING);
                                            gen.writeStringField('Line1', String.IsNoTBlank(address.Address_Line_1__c) ? address.Address_Line_1__c : EMPTRY_STRING);
                                            gen.writeStringField('Line2',  String.IsNoTBlank( address.Address_Line_2__c) ?   address.Address_Line_2__c : EMPTRY_STRING);
                                            gen.writeStringField('Line3',  String.IsNoTBlank( address.Address_Line_3__c) ?   address.Address_Line_3__c : EMPTRY_STRING);
                                            gen.writeStringField('Line4',  String.IsNoTBlank( address.Address_Line_4__c) ? address.Address_Line_4__c : EMPTRY_STRING);
                                            gen.writeFieldName('TimeAtAddress');
                                            gen.writeStartObject();
                                                gen.writeStringField('Years', String.IsNoTBlank(String.ValueOf(address.Start_Date__c)) && String.IsNoTBlank(String.ValueOf(address.End_Date__c)) ? ICS_CTRL_BoostApplicationHelper.lengthOfTime(address.Start_Date__c, address.End_Date__c)[0] :'0');
                                                gen.writeStringField('Months',String.IsNoTBlank(String.ValueOf(address.Start_Date__c)) && String.IsNoTBlank(String.ValueOf(address.End_Date__c))? ICS_CTRL_BoostApplicationHelper.lengthOfTime(address.Start_Date__c, address.End_Date__c)[1] :'0');
                                            gen.writeEndObject();
                                        gen.writeEndObject();
                                    }
                                }
                            gen.writeEndArray();
           
                              gen.writeFieldName('CorrespondenceAddress');
              				  gen.writeStartObject();
                              for(ContactPointAddress address :addressList){
                                if(address.AddressType   == CORRESPONDENCE && !correspondenceAddress){
                                    correspondenceAddress = true;
                                    gen.writeStringField('Country',  String.IsNoTBlank(address.Country__c ) ?  address.Country__c  : EMPTRY_STRING);
                                    gen.writeStringField('Line1', String.IsNoTBlank(address.Address_Line_1__c) ? address.Address_Line_1__c : EMPTRY_STRING);
                                    gen.writeStringField('Line2',  String.IsNoTBlank( address.Address_Line_2__c) ?   address.Address_Line_2__c : EMPTRY_STRING);
                                    gen.writeStringField('Line3',  String.IsNoTBlank( address.Address_Line_3__c) ?   address.Address_Line_3__c : EMPTRY_STRING);
                                    gen.writeStringField('Line4',  String.IsNoTBlank( address.Address_Line_4__c) ? address.Address_Line_4__c : EMPTRY_STRING);
                                    gen.writeStringField('Postcode', String.IsNoTBlank (address.Postcode__c) ?  address.Postcode__c : EMPTRY_STRING);
                                }
                              }
              				  gen.writeEndObject();

                    gen.writeFieldName('TaxCountries');
                            gen.writeStartArray();
                            gen.writeStartObject();
                                gen.writeNumberField('Number', 1);
                                gen.writeStringField('Country',  String.IsNoTBlank(app.Country_of_Tax__c) ? app.Country_of_Tax__c : EMPTRY_STRING);
                                gen.writeStringField('TaxID',   String.IsNoTBlank(app.National_Insurance__c) && app.Identification_Numbers__c == 'National Insurance' ? 
                                                     app.National_Insurance__c : ( String.IsNoTBlank(app.Tax_Identification_Number__c) ? app.Tax_Identification_Number__c : ''));
                       if(String.IsNoTBlank(app.Reason_For_TIN_NI_Number__c)) {
                                          gen.writeBooleanField('NoTaxResDoesNotIssueTIN', app.Reason_For_TIN_NI_Number__c.contains(REASON_A) ? true : false);
                                          gen.writeBooleanField('NoTaxResUnableToObtainTIN', app.Reason_For_TIN_NI_Number__c.contains(REASON_B)  ?true : false);
                                          gen.writeStringField('NoTaxResUnableToObtainTINDesc', app.Reason_For_TIN_NI_Number__c.contains(REASON_B) ?app.Reason_B_Explanation__c : EMPTRY_STRING);
                                          gen.writeBooleanField('NoTaxResNoTINRequired', app.Reason_For_TIN_NI_Number__c.contains(REASON_C) ?true : false);
                                }
                    gen.writeEndObject();
                            if(String.IsNotBlank(app.Tax_data__c)){
                                String str = app.Tax_data__c; 
                                List<Map<String,String>> taxData  = new List<Map<String,String>>((List<Map<String,String>>)JSON.deserialize(str,List<Map<String,String>>.class));
                                Integer i = 1;
                                for(Object obj : taxData) {
                                       String str01 = JSON.serialize(obj).replace('Country_of_Tax__c','countryOfTax').replace('Has_TIN__c','hasTIN').replace('Tax_Identification_Number__c','taxIdentificationNumber')
                                                            .replace('Reason_For_TIN_NI_Number__c','reasonForTinNiNumber').replace('Reason_B_Explanation__c','reasonBExplanation');
                                       String str02 = str01.replace('\\t', EMPTRY_STRING);
                                      
                                       ICS_CTRL_BoostApplicationHelper.TaxData otherTax = (ICS_CTRL_BoostApplicationHelper.TaxData)JSON.deserialize(str02, ICS_CTRL_BoostApplicationHelper.TaxData.class);
                                       i++;
                                       gen.writeStartObject();
                                           gen.writeNumberField('Number', i);
                                           gen.writeStringField('Country',  String.IsNoTBlank(otherTax.countryOfTax) ?otherTax.countryOfTax : EMPTRY_STRING);
                                           gen.writeStringField('TaxID', String.IsNoTBlank(otherTax.taxIdentificationNumber) ?otherTax.taxIdentificationNumber : EMPTRY_STRING);
                                           if(String.IsNoTBlank(otherTax.reasonForTinNiNumber)) {
                                          gen.writeBooleanField('NoTaxResDoesNotIssueTIN', otherTax.reasonForTinNiNumber.contains(REASON_A) ? true : false);
                                          gen.writeBooleanField('NoTaxResUnableToObtainTIN', otherTax.reasonForTinNiNumber.contains(REASON_B)  ?true : false);
                                          gen.writeStringField('NoTaxResUnableToObtainTINDesc', otherTax.reasonForTinNiNumber.contains(REASON_B) ?otherTax.reasonBExplanation : EMPTRY_STRING);
                                          gen.writeBooleanField('NoTaxResNoTINRequired', otherTax.reasonForTinNiNumber.contains(REASON_C) ?true : false);
                                           }
                                       gen.writeEndObject();
                                  }
                               }
                          gen.writeEndArray(); 
                        gen.writeEndObject();
            
    
           
                        gen.writeFieldName('IncomeDetails');
                        gen.writeStartObject(); 
                            gen.writeFieldName('CurrentEmployment');
                            gen.writeStartObject();
                                Integer i = 0;
                                for(FinServ__Employment__c employ : employmentConvertedCurrencyList){
                                    if(employ.RecordType.Name == 'Current' && i == 0 && String.isNotBlank(employ.Only_employment__c)){
                                        i++;
                     					employmentType = ICS_CTRL_BoostApplicationHelper.boostEmploymentMap(employ.FinServ__EmploymentStatus__c);
                                        gen.writeStringField('EmployerName', String.IsNoTBlank(employ.Name) && employmentType != RETIRED && String.IsNoTBlank(employ.Occupation__c) && employmentType != UNEMPLOYED && employmentType != HOUSE_PERSON ?  employ.Name : EMPTRY_STRING);
                                        if(employ.FinServ__LengthOfEmployment__c != null){
                                        gen.writeFieldName('TimeWithEmployer');
                                        gen.writeStartObject();
                                            gen.writeNumberField('Years', employ.FinServ__LengthOfEmployment__c != null ? employ.FinServ__LengthOfEmployment__c.intValue() : 0   );
                                            gen.writeNumberField('Months',  employ.FinServ__LengthOfEmployment__c != null ? (12 * (employ.FinServ__LengthOfEmployment__c - employ.FinServ__LengthOfEmployment__c.intValue())).round() : 0  );
                                        gen.writeEndObject();
                                        }
                                        gen.writeStringField('EmployersBusiness', String.IsNoTBlank(employ.Industry__c) ?  employ.Industry__c : EMPTRY_STRING);
                                        gen.writeStringField('Occupation', String.IsNoTBlank(employ.Occupation__c) ?  employ.Occupation__c : EMPTRY_STRING);
                                        gen.writeFieldName('EmployerAddress');
                                        gen.writeStartObject();
                                            gen.writeStringField('Country',String.IsNoTBlank(employ.Employer_s_Country__c) ?  employ.Employer_s_Country__c : EMPTRY_STRING);
                                            gen.writeStringField('Line1',  String.IsNoTBlank(employ.Employer_s_Address_Line_1__c) ?  employ.Employer_s_Address_Line_1__c : EMPTRY_STRING);
                                            gen.writeStringField('Line2', String.IsNoTBlank(employ.Employer_s_Address_Line_2__c) ?  employ.Employer_s_Address_Line_2__c : EMPTRY_STRING);
                                            gen.writeStringField('Line3', String.IsNoTBlank(employ.Employer_s_Address_Line_3__c) ?  employ.Employer_s_Address_Line_3__c : EMPTRY_STRING);
                                            gen.writeStringField('Line4', String.IsNoTBlank(employ.Employer_s_Address_Line_4__c) ?  employ.Employer_s_Address_Line_4__c : EMPTRY_STRING);
                                            gen.writeStringField('Postcode', String.IsNoTBlank(employ.Employer_s_Postcode__c) ?  employ.Employer_s_Postcode__c : EMPTRY_STRING);
                                        gen.writeEndObject();
                                        gen.writeStringField('PositionHeld', String.IsNoTBlank(employ.FinServ__Position__c) ?  employ.FinServ__Position__c : EMPTRY_STRING);
                                        if(String.IsNoTBlank(employ.FinServ__EmploymentStatus__c)){
                                        gen.writeStringField('EmploymentType', employmentType);
                                        }      
                                          gen.writeFieldName('GrossSalary');
                                          gen.writeStartObject();
                                              gen.writeStringField('Currency', employ.FinServ__AnnualIncome__c != null ?  UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                                                gen.writeNumberField('Amount', employ.FinServ__AnnualIncome__c != null ? employ.FinServ__AnnualIncome__c: 0   );
                                          gen.writeEndObject();  
                                          gen.writeFieldName('BonusCommission');
                                          gen.writeStartObject();
                                              gen.writeStringField('Frequency', 'Yearly');
                                              gen.writeStringField('Currency', employ.Bonuses_Commissions_received_per_annum__c != null ?  UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                                              gen.writeNumberField('Amount1', employ.Bonuses_Commissions_received_per_annum__c != null ? employ.Bonuses_Commissions_received_per_annum__c: 0   );
                                           gen.writeEndObject(); 
                                        gen.writeStringField('Website', String.IsNoTBlank(employ.Employer_s_Website__c) ?  employ.Employer_s_Website__c : EMPTRY_STRING);
                                        gen.writeStringField('BusinessPercentageOwned', String.IsNoTBlank(acc.percentage_of_the_Business_which_owned__c) ?  acc.percentage_of_the_Business_which_owned__c : EMPTRY_STRING);
                                        gen.writeStringField('BusinessValue', acc.ValueOfBusiness__c != null ?  acc.CurrencyIsoCode+' '+ acc.ValueOfBusiness__c : EMPTRY_STRING);
                                    }
                                }
                            gen.writeEndObject();
            
    
                            gen.writeFieldName('LastEmployment');
                            gen.writeStartObject();
                            if(acc.Has_Previous_Employment__c == 'No' && (acc.Previous_Employment_Status__c != 'Other'|| String.IsNotBlank (acc.Previous_Employment_Status__c))){
                                gen.writeStringField('EmploymentType', ICS_CTRL_BoostApplicationHelper.boostEmploymentMap(acc.Previous_Employment_Status__c));
                            }
                            else{
                				for(FinServ__Employment__c employ : previousEmploymentConvertedCurrencyList){
                                    if(employ.RecordType.Name == PREVIOUS_EMPLOYMENT && i == 1){
                                        i++;
                                        gen.writeStringField('EmployerName', String.IsNoTBlank(employ.Name) && String.IsNoTBlank(employ.Occupation__c) ?  employ.Name : EMPTRY_STRING);
                                        if(employ.FinServ__LengthOfEmployment__c != null){
										gen.writeFieldName('TimeWithEmployer');
                                        gen.writeStartObject();
                                            gen.writeNumberField('Years', employ.FinServ__LengthOfEmployment__c != null ? employ.FinServ__LengthOfEmployment__c.intValue() : 0   );
                                            gen.writeNumberField('Months',  employ.FinServ__LengthOfEmployment__c != null ? (12 * (employ.FinServ__LengthOfEmployment__c - employ.FinServ__LengthOfEmployment__c.intValue())).round() : 0  );
                                        gen.writeEndObject();
    
                                        }
                                        gen.writeStringField('EmployersBusiness', String.IsNoTBlank(employ.Industry__c) ?  employ.Industry__c : EMPTRY_STRING);
                                        gen.writeStringField('Occupation', String.IsNoTBlank(employ.Occupation__c) ?  employ.Occupation__c : EMPTRY_STRING);
                                        gen.writeFieldName('EmployerAddress');
                                        gen.writeStartObject();
                                            gen.writeStringField('Country',String.IsNoTBlank(employ.Employer_s_Country__c) ?  employ.Employer_s_Country__c : EMPTRY_STRING);
                                            gen.writeStringField('Line1',  String.IsNoTBlank(employ.Employer_s_Address_Line_1__c) ?  employ.Employer_s_Address_Line_1__c : EMPTRY_STRING);
                                            gen.writeStringField('Line2', String.IsNoTBlank(employ.Employer_s_Address_Line_2__c) ?  employ.Employer_s_Address_Line_2__c : EMPTRY_STRING);
                                            gen.writeStringField('Line3', String.IsNoTBlank(employ.Employer_s_Address_Line_3__c) ?  employ.Employer_s_Address_Line_3__c : EMPTRY_STRING);
                                            gen.writeStringField('Line4', String.IsNoTBlank(employ.Employer_s_Address_Line_4__c) ?  employ.Employer_s_Address_Line_4__c : EMPTRY_STRING);
                                            gen.writeStringField('Postcode', String.IsNoTBlank(employ.Employer_s_Postcode__c) ?  employ.Employer_s_Postcode__c : EMPTRY_STRING);
                                        gen.writeEndObject();
                                        gen.writeStringField('PositionHeld', String.IsNoTBlank(employ.FinServ__Position__c) ?  employ.FinServ__Position__c : EMPTRY_STRING);
                                        if(String.IsNoTBlank(employ.FinServ__EmploymentStatus__c)){
                                        	gen.writeStringField('EmploymentType', ICS_CTRL_BoostApplicationHelper.boostEmploymentMap(employ.FinServ__EmploymentStatus__c));
                                        }
                                            gen.writeFieldName('GrossSalary');
                                            gen.writeStartObject();
                                                gen.writeStringField('Currency', employ.FinServ__AnnualIncome__c != null ? UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                                                gen.writeNumberField('Amount', employ.FinServ__AnnualIncome__c != null ? employ.FinServ__AnnualIncome__c: 0   );
                                            gen.writeEndObject(); 
                                        if (employ.Bonuses_Commissions_received_per_annum__c > 0){
                                            gen.writeFieldName('BonusCommission');
                                            gen.writeStartObject();
                                                gen.writeStringField('Frequency', 'Yearly');
                                                gen.writeStringField('Currency', employ.Bonuses_Commissions_received_per_annum__c != null ?  UserInfo.getDefaultCurrency() : EMPTRY_STRING);
                                                gen.writeNumberField('Amount1',employ.Bonuses_Commissions_received_per_annum__c != null ? employ.Bonuses_Commissions_received_per_annum__c: 0   );
                                            gen.writeEndObject();
                                        }
                                        gen.writeStringField('Website', String.IsNoTBlank(employ.Employer_s_Website__c) ?  employ.Employer_s_Website__c : EMPTRY_STRING);
                                    }
                                }
            				 }
                             gen.writeEndObject();
                  gen.writeEndObject();            
            
                    Boolean debitCardAddress = false;
                            if(String.IsNoTBlank(app.Card_Delivery_Option__c)  && app.Debit_Visa_Card__c == YES){
                            gen.writeBooleanField('DebitCardAddressCorrespondence',  app.Card_Delivery_Option__c == YES ? true : false);
                            gen.writeFieldName('DebitCardAddress');
                            gen.writeStartObject();
                            for(ContactPointAddress address :addressList){
                                if(address.AddressType   == CORRESPONDENCE && String.IsNoTBlank(app.Card_Delivery_Option__c)  && !debitCardAddress){
                                      debitCardAddress = true;
                                        gen.writeStringField('Country',  app.Card_Delivery_Option__c == YES && String.IsNoTBlank( address.Country__c) ?  address.Country__c  : 
                                                             String.IsNoTBlank(app.Delivery_Country__c) ? app.Delivery_Country__c : EMPTRY_STRING);
                                        gen.writeStringField('Line1', app.Card_Delivery_Option__c == YES && String.IsNoTBlank(address.Address_Line_1__c) ? address.Address_Line_1__c : 
                                                             String.IsNoTBlank(app.Delivery_Address_Line_1__c ) ? app.Delivery_Address_Line_1__c : EMPTRY_STRING);
                                        gen.writeStringField('Line2',  app.Card_Delivery_Option__c == YES && String.IsNoTBlank(address.Address_Line_2__c) ?   address.Address_Line_2__c : 
                                                             String.IsNoTBlank(app.Delivery_Address_Line_2__c) ? app.Delivery_Address_Line_2__c : EMPTRY_STRING);
                                        gen.writeStringField('Line3',  app.Card_Delivery_Option__c == YES && String.IsNoTBlank(address.Address_Line_3__c) ?   address.Address_Line_3__c : 
                                                             String.IsNoTBlank(app.Delivery_Address_Line_3__c) ? app.Delivery_Address_Line_3__c : EMPTRY_STRING);
                                        gen.writeStringField('Line4',  app.Card_Delivery_Option__c == YES && String.IsNoTBlank(address.Address_Line_4__c) ? address.Address_Line_4__c : 
                                                             String.IsNoTBlank(app.Delivery_Address_Line_4__c) ? app.Delivery_Address_Line_4__c : EMPTRY_STRING);
                                        gen.writeStringField('Postcode', app.Card_Delivery_Option__c == YES && String.IsNoTBlank(address.Postcode__c) ?  address.Postcode__c :
                                                             String.IsNoTBlank(app.Delivery_Postcode__c) ? app.Delivery_Postcode__c : EMPTRY_STRING);
                                }
                            }
                            gen.writeEndObject();
                          }
                    gen.writeEndObject();
                    gen.writeEndArray();
                gen.writeEndObject();
            gen.writeEndObject();
            
            Map<String, String> regexCheckMap = new Map<String, String>();
            regexCheckMap.put('Delivery Address Post Code', deliveryAddressPostCode);
            regexCheckMap.put('Previous Address Post Code', previousAddressPostCode);
            regexCheckMap.put('Answer To Mother Former/Maiden Name', motherMaidenName);
            regexCheckMap.put('Answer To Favourite Sport Or Colour', favouriteSportOrColour);
      		regexCheckMap.put('Answer To Code Word',codeWord);
            regexCheckMap.put('Answer To First School Name', firstSchoolName);

      String errorMessage = ICS_CTRL_BoostApplicationHelper.errorMessage(regexCheckMap);
            
            if(String.IsNotBlank(errorMessage)){
                responseBody = '{"ErrorMessage":['+errorMessage+'],"BoostResponseStatus":"FAIL"}';
                
            }else{
            responseBody = ICS_API_BoostApplication.boostApplicationCallout(gen.getAsString());
    		}
    }
        catch(Exception e){
      LOGGER.error('Error on boostApplicationCallout', e); 
        }
       
    return responseBody;
    }
    
     

}