/**
* @description Class for dealing with data to run the  test classes
*
* @author Sizwe November
* @date March 2023
*/
@isTest
public with sharing class ICS_TestDataFactory {
    
    	 /*
    * @description  ZAR currency text   
    */     
    private static final String ZAR = 'ZAR';
     /*
    * @description  GBP currency text  
    */     
    private static final String GBP = 'GBP';
     /*
    * @description  Yes  text  
    */     
    private static final String YES = 'Yes';
     /*
    * @description  FINANCIAL  text  
    */     
    private static final String FINANCIAL = 'Financial';
     /**
 	* @description ICS_TestDataFactory constructor
 	* @param boundary  
 	*/
    private ICS_TestDataFactory() {
    }

    /**
    * @description Method for the Account creation
    * @return Account
    */
    @testVisible
    public static Account createAccount() {
        
       ID recordTypeID = [Select Id, Name FROM RecordType WHERE sObjectType='Account' AND Name = 'Person Account' WITH SECURITY_ENFORCED].id;

       Account acc = new Account(LastName= 'Mulner',
                                FirstName= 'Jacob',
                                Salutation= 'Mr.',
                                MiddleName= 'Steve',
                                RecordTypeId= recordTypeID,
                                Phone= '276788975',
                                CurrencyIsoCode= GBP,
                                PersonEmail= 'mock.mulner@test.com',
                                PersonBirthdate= date.newInstance(1977,1,4),
                                PersonHasOptedOutOfEmail= false,
                                PersonHasOptedOutOfFax= false,
                                PersonDoNotCall= false,
                                ICS_Is_the_applicant_a_Refugee__c= null,
                                Are_you_a_Business_Owner__c= YES,
                                percentage_of_the_Business_which_owned__c= '50',
                                Value_of_shares__c= '4000000',
                                CMN_RestrictedAccess__c= false,
                                PracticinginProfession__c= false,
                                Value_of_the_Business__c= '8000000',
                                Staff_Indicator__c= false,
                                Cash_Based_Business__c= YES,
                                Sort_Code__c= null,
                                ICS_Country_of_Residence__c= 'ZA',
                                ICS_Country_of_Nationality__c= 'ZA',
                                ICS_Full_Name__c= 'Jacob Mulner',
                                Sole_Business_Owner__c= YES,
                                Location_of_Business__c= 'ZA',
                                Former_Names_Maiden_Name__c= 'Sentra',
                                Sub_Industry__c= 'Other',
                                Town_City_of_Birth__c= 'Cape Town',
                                Industry__c= 'Construction',
                                Passport_Number__c= null,
                                Identification_Number__c= '7701045644087',
                                Other_Business_Interests__c= YES,
                                Second_Country_of_Nationality__c= 'AU',
                                Different_FirstName__c= 'Terry',
                                Different_MiddleName__c= 'Melvin',
                                Different_LastName__c= 'Forrest',
                                ValueOfShares__c= 50,
                                Former_Name__c= 'Sentra',
                                Maiden_Name__c= 'Seth',
                                Identification_or_Passport_Number__c= 'Identification Number',
                                ValueOfBusiness__c= 578999534,
                                FinServ__CountryOfBirth__pc= 'ZA',
                                FinServ__CreatedFromLead__pc= false,
                                FinServ__EmailVerified__pc= false,
                                FinServ__FaxVerified__pc= false,
                                FinServ__Gender__pc= 'Male',
                                FinServ__MaritalStatus__pc= 'Single',
                                Alternative_Phone__c = '65467889',
                                Alternative_Phone_Country_Code__c = '501',
                                Alternative_Phone_Nubmer_Type__c = 'Home Contact Number'
                                );
        
        insert acc;
        return acc;
    }
    
    /**
    * @description Method for the opportunity creation
    * @param accID Account ID
    * @return Opportunity
    */
      @testVisible
      public static Opportunity createOpportunity(ID accID) {
          
        ID recordTypeID = [Select Id, Name FROM RecordType WHERE sObjectType='Opportunity' AND Name = 'ICS Applicant' WITH SECURITY_ENFORCED].id;
        Contact brokerBanker = createContact();
        Sales_Codes__c salesCode = createSalesCode();

        Opportunity opp = new Opportunity(AccountId = accID,
                                RecordTypeId = recordTypeID,
                                Name = 'Mock Mulner',
                                Description = null,
                                StageName = 'Application form',
                                Amount = null,
                                Sales_Code__c = salesCode.Id,
                                CurrencyIsoCode = GBP,
                                Bank_Account_Currency__c = 'Sterling;US Dollar;Euro;AU Dollar',
                                ICS_IFA_Broker__c = brokerBanker.ID,
                                ICS_Private_Banker__c = brokerBanker.ID,
                                ICS_Country_of_Residence__c = 'ZA',
                                ICS_Broker_associated_with_the_Opp__c = 'No',
                                CloseDate = Date.valueOf('2024-01-01 00:00:00'),
                                ICS_Distribution_Channel__c = 'Direct (in-person, call, Online)',
                                ICS_Is_the_Opportunity_a_Refugee__c = 'No',
                                ICS_Product_Type__c = 'IPB Optimum',
                                ICS_Business_Acceptance_Criteria__c = 'Personal customer (incl Expats) from/with connection to African target markets (inc.IFA with TOB)',
                                ICS_Switching_from_another_Bank__c = 'No',
                                ICS_Reason_for_acc_in_this_jurisdiction__c = 'Currency stability',
                                ICS_Purpose_of_opening_Account__c = 'Savings');
        
        insert opp;
        return opp;
    
    }
    
    /**
    * @description Method for the PartyProfile creation
    * @param accID Account ID
    * @return PartyProfile
    */
      @testVisible
      public static PartyProfile createPartyProfile(ID accID) {
          
        ID recordTypeID = [Select Id, Name FROM RecordType WHERE sObjectType='PartyProfile' AND Name = 'ICS Party Profile' WITH SECURITY_ENFORCED].id;
        

        PartyProfile partyProfile = new PartyProfile(AccountId = accID,
                                RecordTypeId = recordTypeID,
                                LastName= 'Mulner',
                                FirstName= 'Jacob',
                                Gender= 'Male',
                                Name = 'Jacob Mulner');
          
        
        insert partyProfile;
        return partyProfile;
    }
    
       
     /**
    * @description Method for the ApplicationForm creation
    * @param accID Account ID
    * @param oppID Opportunity ID
    * @return ApplicationForm
    */
      @testVisible
      public static ApplicationForm createApplicationForm(ID accID, ID oppID) {
          
        ApplicationForm appForm = new ApplicationForm(opportunityId = oppId , accountId = accID, UsageType = 'Other');
        insert appForm;
        return appForm;
    }
    
         /**
    * @description Method for the ApplicationForm creation
    * @param accID Account ID
    * @param appFormID ApplicationForm ID
    * @param partyProfileId Party Profile ID
    * @return Applicant
    */
      @testVisible
      public static Applicant createApplicant(ID accID, ID appFormID, ID partyProfileId) {
          
        Applicant applicant = new Applicant(partyProfileId = partyProfileId, applicationFormId = appFormID , accountId=accID);
        insert applicant;
        return applicant;
    }
    
    /**
    * @description Method for the contact creation
    * @return Contact
    */
      @testVisible
      public static Contact createContact() {
          
        ID recordTypeID = [select Id,Name from RecordType where sObjectType='Contact' AND Name = 'Individual' WITH SECURITY_ENFORCED].id;
        Contact cont = new Contact(LastName = 'Bankerlast',
                            FirstName = 'Bankerfirst',
                            RecordTypeId = recordTypeID,
                            Email = 'banker@test.com',
                            CurrencyIsoCode = GBP,
                            ICS_TPI_Code__c = 'ZIM10');
        insert cont;
        return cont;
    }
    
    /**
    * @description Method for the Sales Code creation
    * @return Sales Code
    */
      @testVisible
      public static Sales_Codes__c createSalesCode() {
          
        Sales_Codes__c salesCode = new Sales_Codes__c(Name = '035WC',
                            Sales_Code_Country__c = 'ZA',
                            CurrencyIsoCode = GBP);
      	insert salesCode;
        return salesCode;
    }
    
    /**
     * @description Method for the Application creation
     * @param accID The ID of the Account for which the Application needs to be created.
     * @param oppID The ID of the Opportunity associated with the Application.
     * @return application The newly created Application__c record.
     */
    @testVisible
    public static Application__c createApplication(ID accID, ID oppID) {
        ID recordTypeID = [select Id,Name from RecordType where sObjectType='Application__c' AND Name = 'ICS Application' WITH SECURITY_ENFORCED].id;
        
        Application__c app = new Application__c(CurrencyIsoCode = GBP,
                                                RecordTypeId = recordTypeID,
                                                Opportunity__c = oppID,
                                                Account__c = accID,
                                                Identification_Numbers__c = 'National Insurance',
                                                National_Insurance__c = 'Test',
                                                Other_Identification_Number__c = '555555',
                                                US_Resident_Type__c = null,
                                                Tax_Resident_Other_Countries__c = 'US',
                                                Intent_to_Future_Deposits_Funds__c = 'Life Savings;Gift',
                                                Involvement_with_a_Trust__c = 'No',
                                                Correspondence_Relationship__c = 'Family Address',
                                                First_Deposit_Amount__c = 10000,
                                                Initial_Deposit_by_Bank__c = YES,
                                                Initial_Deposit_Method__c = null,
                                                Your_Own_Bank_Account__c = YES,
                                                Frequency_Future_Deposits__c = 'Annually',
                                                Country_Funds_from__c = 'AD',
                                                Future_Deposits_Funded_From__c = YES,
                                                Additional_Future_Deposits__c = 'NO',
                                                Bank_Name__c = 'AB Bank',
                                                Current_Account_Balance__c = 400000,
                                                Name_of_the_Account_Holder_s__c = 'Jacob Mulner',
                                                AOB_Consent_Status__c = false,
                                                Branch_City_Town__c = 'Cape Town',
                                                Length_of_Time_Account_Held__c = '03/09',
                                                How_many_years_Wealth_been_accumulated__c = '5-9 years',
                                                Country_of_Wealth__c = 'ZA',
                                                Additional_Bank_Accounts__c = 'No',
                                                AOB_Country__c = null,
                                                AOB_County__c = null,
                                                AOB_Course_Name__c = null,
                                                AOB_Current_Address_City__c = null,
                                                Do_You_Own_Any_Property__c = YES,
                                                Is_Tax_Resident_of_Other_Coutries__c = YES,
                                                AOB_Current_Address_Country__c = 'UG',
                                                Investments_Stocks__c = YES,
                                                AOB_Current_Address_Same_As_Address__c = false,
                                                Other_Incomes__c = YES,
                                                What_Other_Incomes_Do_You_Have__c = 'Gift;Maturity of Insurance policy or fixed term investment;Loan;Inheritance;Salary/Bonus;Pensions/Retirement',
                                                Country_of_Tax__c = 'ZA',
                                                Tax_Identification_Number__c = null,
                                                Has_a_Bank_Account__c = YES,
                                                Life_Savings_Bank_Accounts__c = null,
                                                AOB_Email_Type__c = 'COMMEML',
                                                AOB_Have_Referral_Code__c = false,
                                                AOB_Liveness_Matched__c = false,
                                                AOB_Liveness_Score__c = 0,
                                                AOB_Market_Your_Product_Consent__c = false,
                                                AOB_Nationality__c = 'UG',
                                                AOB_Personal_Information_Consent__c = false,
                                                AOB_Phone_Type__c = 'CELLPH',
                                                AOB_Research_Consent__c = false,
                                                AOB_Services_Special_Offers_Consent__c = false,
                                                AOB_Stage__c = 'Your Contact with Us',
                                                Declaration_you_have_fully_disclosed__c = true,
                                                Correct_Information_Declaration__c = true,
                                                Tax_Information_Changes_Declaration__c = true,
                                                Up_To_Date_Tax_Affairs_Declaration__c = true,
                                                Annual_Tax_Certificate__c = YES,
                                                Debit_Visa_Card__c = YES,
                                                AOB_Occupation__c = '999',
                                                Customer_Instruct_Declaration__c = true,
                                                Customer_Data_Usage__c = true,
                                                First_School_Name__c = 'CPT',
                                                Former_Name__c = 'Stern',
                                                Favorite_Sport_or_Colour__c = 'Rugby',
                                                Code_Word__c = 'Pet',
                                                ICS_Is_main_Applicant__c = false,
                                                US_Resident_Confirmation__c = false,
                                                Keep_You_Informed_About__c = 'Phone;Email',
                                                The_Same_as_Current_Address__c = YES,
                                                Bank_Country__c = 'ZA',
                                                Status__c = 'Complete',
                                                Keep_You_Informed_About_Product__c = true,
                                                Card_Delivery_Option__c = YES,
                                                Expected_Annual_Yearly_Turnover_From__c = 0,
                                                Expected_Annual_Yearly_Turnover_To__c = 50,
                                                Current_is_core_Applicant_Address__c = null,
                                                Bank_Account_the_Deposit_will_be_Coming__c = null,
                                                Tax_data__c = '[{"Country_of_Tax__c":"US","Has_TIN__c":"No","Reason_For_TIN_NI_Number__c":"Reason A - The country/jurisdiction where you are resident does not issue TINs to it\'s residents"},{"Country_of_Tax__c":"GB","Has_TIN__c":"No","Tax_Identification_Number__c":"","Reason_For_TIN_NI_Number__c":"Reason B - Unable to obtain a TIN or equivalent number","Reason_B_Explanation__c":"Application still in process"},{"Country_of_Tax__c":"IN","Has_TIN__c":"No","Tax_Identification_Number__c":"","Reason_For_TIN_NI_Number__c":"Reason C - No TIN is required. The domestic Law of the relevant jurisdictions does not require the collection of the TIN issued by such jurisdiction","Reason_B_Explanation__c":""}]'
                                                 );
        insert app;
        return app;
    }
    
    /**
    * @description Method for the current Employment creation
    * @param accID
    * @return FinServ__Employment__c List
    */   
    @testVisible
    public static List<FinServ__Employment__c>  createEmploymentList(ID accID) {
        
        ID currentRecordTypeID = [select Id,Name from RecordType where sObjectType='FinServ__Employment__c' AND Name = 'Current' WITH SECURITY_ENFORCED].id;
        ID previousRecordTypeID = [select Id,Name from RecordType where sObjectType='FinServ__Employment__c' AND Name = 'Previous' WITH SECURITY_ENFORCED].id;
        
        List<FinServ__Employment__c> employmentList = new List<FinServ__Employment__c>{
            										new FinServ__Employment__c (Name = 'AE Construction',
                                                                               CurrencyIsoCode = ZAR,
                                                                               RecordTypeId = currentRecordTypeID,
                                                                               FinServ__AnnualIncome__c = 900000,
                                                                               FinServ__Contact__c = null,
                                                                               FinServ__EmployerAddress__c = null,
                                                                               FinServ__EmployerPhoneNumber__c = null,
                                                                               FinServ__EmploymentStatus__c = 'Employed in the Finance sector',
                                                                               FinServ__EndDate__c = null,
                                                                               FinServ__Occupation__c = null,
                                                                               FinServ__Position__c = 'Engineer',
                                                                               FinServ__StartDate__c = Date.valueOf('2017-01-26'),
                                                                               Employer_s_Website__c = null,
                                                                               Employer_s_Postcode__c = '7570',
                                                                               Employer_s_Address_Line_1__c = '67 Stape Street',
                                                                               Employer_s_Address_Line_2__c = 'Milnerton',
                                                                               Employer_s_Address_Line_3__c = 'Sydney Square',
                                                                               Employer_s_Address_Line_4__c = 'Sydney',
                                                                               Retired_Start_Date__c = null,
                                                                               Unemployment_Start_Date__c = null,
                                                                               In_home_Start_Date__c = null,
                                                                               Occupation__c = 'Engineer',
                                                                               Employer_s_Country__c = 'ZA',
                                                                               Bonuses_Commissions_received_per_annum__c = 370000,
                                                                               Only_employment__c = YES,
                                                                                Person_Account__c = accID
                                                                                ),
            											new FinServ__Employment__c (Name = 'WeBank',
                                                                                CurrencyIsoCode = GBP,
                                                                                RecordTypeId = previousRecordTypeID,
                                                                                FinServ__AnnualIncome__c = 450000,
                                                                                FinServ__Contact__c = null,
                                                                                FinServ__EmployerAddress__c = null,
                                                                                FinServ__EmployerPhoneNumber__c = null,
                                                                                FinServ__EmploymentStatus__c = 'Self-Employed',
                                                                                FinServ__EndDate__c = Date.valueOf('2021-01-07'),
                                                                                FinServ__Occupation__c = 'Community and Social Service',
                                                                                FinServ__Position__c = 'Portfolio Manager',
                                                                                FinServ__StartDate__c = Date.valueOf('2003-05-03'),
                                                                                Employer_s_Website__c = null,
                                                                                Employer_s_Postcode__c = '4532',
                                                                                Employer_s_Address_Line_1__c = '3 Trail Road',
                                                                                Employer_s_Address_Line_2__c = 'Sydney Square',
                                                                                Employer_s_Address_Line_3__c = 'Milnerton',
                                                                                Employer_s_Address_Line_4__c = 'Sydney',
                                                                                Retired_Start_Date__c = null,
                                                                                Unemployment_Start_Date__c = null,
                                                                                In_home_Start_Date__c = null,
                                                                                Occupation__c = null,
                                                                                Employer_s_Country__c = 'AU',
                                                                                Bonuses_Commissions_received_per_annum__c = 370000,
                                                                                Only_employment__c = null,
                                                                                Previously_em__c = null,
                                                                                Other_Status__c = null,
                                                                                Person_Account__c = accID
                                                                                )
        															};
      
        insert employmentList;                                                                           
        return employmentList;
    }
    
    
    /**
    * @description Method for the current Asset and Income creation
    * @param appID
    * @return AssetsAndIncomes__c List
    */
    @testVisible
    public static List<AssetsAndIncomes__c >  createAssetIncomeList(ID appID) {
        
        ID wealthCountryRecordTypeID = [select Id,Name from RecordType where sObjectType='AssetsAndIncomes__c' AND Name = 'Wealth in Country' WITH SECURITY_ENFORCED].id;
        ID assetsInvestmentsStocksRecordTypeID = [select Id,Name from RecordType where sObjectType='AssetsAndIncomes__c' AND Name = 'Assets/Investments/Stocks' WITH SECURITY_ENFORCED].id;
        ID propertyRecordTypeID = [select Id,Name from RecordType where sObjectType='AssetsAndIncomes__c' AND Name = 'Property' WITH SECURITY_ENFORCED].id;
        ID additionalAccountRecordTypeID = [select Id,Name from RecordType where sObjectType='AssetsAndIncomes__c' AND Name = 'Additional Account' WITH SECURITY_ENFORCED].id;
        ID expectedTurnoverRecordTypeID = [select Id,Name from RecordType where sObjectType='AssetsAndIncomes__c' AND Name = 'Expected Turnover' WITH SECURITY_ENFORCED].id;
		List<AssetsAndIncomes__c > allAssetIncomesList = new List<AssetsAndIncomes__c > ();
        List<AssetsAndIncomes__c > otherAssetIncomeList = createOtherAssetIncomeList(appID);
        List<AssetsAndIncomes__c > assetIncomeList = new List<AssetsAndIncomes__c >{
                                                        new AssetsAndIncomes__c  (CurrencyIsoCode = GBP,
                                                                        RecordTypeId = wealthCountryRecordTypeID,
                                                                        Amounts__c =  60000,
                                                                        Application__c = appID,
                                                                        Country__c = 'ZA'
                                                                        ),
                                                        new AssetsAndIncomes__c  (CurrencyIsoCode = ZAR,
                                                                    RecordTypeId = additionalAccountRecordTypeID,
                                                                    Amounts__c = 454505,
                                                                    Bank_Name__c = 'Aruba Mutual Bank',
                                                                    Account_Holder_Name__c = 'John Assets',
                                                                    Locations__c = 'Oranjestad',
                                                                    Application__c = appID,
                                                                    Length_of_time__c = '11/09',
                                                                    Country__c = 'ZA',
                                                                    Main_Account__c = true
                                                                     ),
                                                      new AssetsAndIncomes__c (CurrencyIsoCode = ZAR,
                                                                                    RecordTypeId = expectedTurnoverRecordTypeID,
                                                                                    Application__c = appID,
                                                                                    Expected_Annual_Yearly_Turnover_From__c = 0,
                                                                                    Expected_Annual_Yearly_Turnover_To__c = 100000
                                                                                    ),
                                                     new AssetsAndIncomes__c (CurrencyIsoCode = ZAR,
                                                                                RecordTypeId = assetsInvestmentsStocksRecordTypeID,
                                                                                Is_future_fund__c = false,
                                                                                Application__c = appID,
                                                                                Investments_Stocks_Jurisdiction__c = 'JSE',
                                                                                Investments_Stocks_Financial_Institution__c = 'JSE',
                                                                                What_the_Assets_are__c = 'JSE',
                                                                                Asset_Value__c = 10000
                                                                                ),
                                                    new AssetsAndIncomes__c (CurrencyIsoCode = ZAR,
                                                                Locations__c = 'Cape Town',
                                                                RecordTypeId = propertyRecordTypeID,
                                                                Is_future_fund__c = false,
                                                                Type__c = 'Residential',
                                                                Application__c = appID,
                                                                Mortgage_Deductions__c = 30000,
                                                                Property_Value__c = 20000,
                                                                Country__c = 'ZA'
                                                                ),
                                                   new AssetsAndIncomes__c (CurrencyIsoCode = GBP,
                                                                 RecordTypeId = additionalAccountRecordTypeID,
                                                                 Amounts__c = 4000,
                                                                 Bank_Name__c = 'ABC Bank',
                                                                 Account_Holder_Name__c = 'Mulner',
                                                                 Locations__c = 'London',
                                                                 Country__c = 'GB',
                                                                 Is_future_fund__c = false,
                                                                 Application__c = appID,
                                                                 Length_of_time__c = '11/06',
                                                                Is_SBG_Account__c = 'No'
                                                                )
                                      			};
                                                    
        insert assetIncomeList;        
        allAssetIncomesList.addAll(assetIncomeList);
        allAssetIncomesList.addAll(otherAssetIncomeList);
        return allAssetIncomesList;
       
    }
    
        /**
    * @description Method for the current Asset and Income creation
    * @param appID
    * @return AssetsAndIncomes__c List
    */
    @testVisible
    public static List<AssetsAndIncomes__c >  createOtherAssetIncomeList(ID appID) {
        
        ID otherIncomeRecordTypeID = [select Id,Name from RecordType where sObjectType='AssetsAndIncomes__c' AND Name = 'Other Income' WITH SECURITY_ENFORCED].id;
        
        List<AssetsAndIncomes__c > assetIncomeList = new List<AssetsAndIncomes__c >{
                                                       new AssetsAndIncomes__c  (CurrencyIsoCode = GBP,
                                                                        RecordTypeId = otherIncomeRecordTypeID,
                                                                        Amounts__c = 2000,
                                                                        Other_Income_Type__c = 'Gift',
                                                                        Is_future_fund__c = true,
                                                                        Date__c = Date.valueOf('2010-03-17'),
                                                                        Relationship_between_donor_and_Client__c = 'Father',
                                                                        Application__c = appID
                                                                        ),
                                                        new AssetsAndIncomes__c (CurrencyIsoCode = GBP,
                                                                            RecordTypeId = otherIncomeRecordTypeID,
                                                                            Amounts__c =  323233,
                                                                            Other_Income_Type__c = 'Lottery/Betting Winnings',
                                                                            Date__c = Date.valueOf('1998-03-12'),
                                                                            Application__c = appID,
                                                                            Lottery_Betting_Organisation_Details__c = 'National Lottery',
                                                                            Details_of_the_Win__c = 'Main lottery win'
                                                                            ),
                                                        new AssetsAndIncomes__c (CurrencyIsoCode = GBP,
                                                                                RecordTypeId = otherIncomeRecordTypeID,
                                                                                Amounts__c = 3000,
                                                                                Bank_Name__c = 'Boston Bank',
                                                                                Other_Income_Type__c = 'Bank Deposits',
                                                                                Is_future_fund__c = false,
                                                                                Application__c = appID,
                                                                                Country__c = 'ZA'
                                                                                ),
                                                       new AssetsAndIncomes__c (CurrencyIsoCode = GBP,
                                                                                RecordTypeId = otherIncomeRecordTypeID,
                                                                                Amounts__c = 3000,
                                                                                Bank_Name__c = 'Boston Bank',
                                                                                Other_Income_Type__c = 'Bank Deposits',
                                                                                Is_future_fund__c = false,
                                                                                Application__c = appID,
                                                                                Country__c = 'ZA'
                                                                                ),
                                                     new AssetsAndIncomes__c (CurrencyIsoCode = GBP,
                                                                                RecordTypeId = otherIncomeRecordTypeID,
                                                                                Amounts__c = 30000,
                                                                                Bank_Name__c = 'AZ Investment Bank',
                                                                                Other_Income_Type__c = 'Bank Deposits',
                                                                                Is_future_fund__c = true,
                                                                                Application__c = appID,
                                                                                Country__c = 'ZA'
                                                                                )
                                      			};

        insert assetIncomeList;
        return assetIncomeList;

        
    }
    
    
    
    /**
    * @description Method for the Account Future Fund creation
    * @param appID
    * @return Acc_Future_Funding__c
    */
    @testVisible
    public static Acc_Future_Funding__c  createAccountFutureFund(ID appID) {
        

        Acc_Future_Funding__c  accFutureFund = new Acc_Future_Funding__c  (Reason_for_Transfer__c = 'Reason for transfer',
                                                                            Application__c = appID,
                                                                            Relationship_to_you__c = 'Brother',
                                                                            Whom_Account_Belongs__c = 'Account holder'
                                                                        );
        insert accFutureFund;
        return accFutureFund;
    }    
    
    
    /**
    * @description Method for the current Contact Point Address creation
    * @param accID
    * @return ContactPointAddress list
    */
    @testVisible
    public static List<ContactPointAddress >  createContactPointAddressList(ID accID) {
        
        ID contactPointAddressRecordTypeID = [select Id,Name from RecordType where sObjectType='ContactPointAddress' AND Name = 'ICS Address' WITH SECURITY_ENFORCED].id;
        
        List<ContactPointAddress > contactPointAddressList = new List<ContactPointAddress >{
            									  new ContactPointAddress  (Name = 'Current residential address',
                                                                            ParentId = accID,
                                                                            RecordTypeId = contactPointAddressRecordTypeID,
                                                                            IsPrimary = false,
                                                                            AddressType = 'Current Residential',
                                                                            IsDefault = true,
                                                                            Address_Line_1__c = '7',
                                                                            Address_Line_2__c = 'Tin Street',
                                                                            Address_Line_3__c = 'Century City',
                                                                            Address_Line_4__c = 'South Africa',
                                                                            Postcode__c = '7570',
                                                                            Country__c = 'ZA',
                                                                            Start_Date__c = Date.valueOf('2016-01-07')
                                                                        ),
        									  new ContactPointAddress  (Name = 'Correspondence address',
                                                                        ParentId = accID,
                                                                        RecordTypeId = contactPointAddressRecordTypeID,
                                                                        IsPrimary = false,
                                                                        AddressType = 'Correspondence',
                                                                        IsDefault = false,
                                                                        Address_Line_1__c = '7',
                                                                        Address_Line_2__c = 'Tin Street',
                                                                        Address_Line_3__c = 'Century City',
                                                                        Address_Line_4__c = 'South Africa',
                                                                        Postcode__c = '7570',
                                                                        Country__c = 'ZA',
                                                                        The_Same_as_Current_Address__c = YES
                                                                        ),
                                                new ContactPointAddress (Name = 'Previous Residential Address',
                                                                         RecordTypeId = contactPointAddressRecordTypeID,
                                                                         ParentId = accID,
                                                                         IsPrimary = false,
                                                                         AddressType = 'Previous Residential',
                                                                         IsDefault = false,
                                                                         Address_Line_1__c = '4 Fona Street',
                                                                         End_Date__c = Date.valueof('2021-03-29'),
                                                                         Address_Line_2__c = 'Sunny Estate',
                                                                         Address_Line_3__c = 'London',
                                                                         Address_Line_4__c = 'England',
                                                                         Postcode__c = '4532',
                                                                         Country__c = 'GB',
                                                                         Start_Date__c = Date.valueof('2004-03-26')
                                                                        )
                                                      };
        insert contactPointAddressList;
        return contactPointAddressList;
    }

         /**
    * @description Method for the Assessment creation
    * @param accID Account ID
    * @return Assessment
    */
      @testVisible
      public static Assessment createAssessment(ID accID) {
          
        Assessment assessment = new Assessment(Name='Test Assessment',AssessmentStatus='In Progress' , accountId=accID);
        insert assessment;
        return assessment;
    }
    
        /**
    * @description Method for the Assessment Question creation
    * @return AssessmentQuestion List
    */
      @testVisible
      public static List<AssessmentQuestion>  createAssessmentQuestion() {
          
       List<AssessmentQuestion> questionList = new List<AssessmentQuestion>{
                new AssessmentQuestion(DataType='TextArea',DeveloperName='how_are_you',Name='Select all assets and income',QuestionCategory=FINANCIAL),
                new AssessmentQuestion(DataType='TextArea',DeveloperName='how_are_you2',Name='Select years',QuestionCategory=FINANCIAL),
                new AssessmentQuestion(DataType='TextArea',DeveloperName='how_are_you3',Name='Select all fund assets and income',QuestionCategory=FINANCIAL),
                new AssessmentQuestion(DataType='Checkbox',DeveloperName='how_are_you4',Name='Are you associated to any Shell Banks',QuestionCategory=FINANCIAL)   
        };
        insert questionList;
        return questionList;
    }
        /**
    * @description Method for the current Asset and Income creation
    * @param questionList AssessmentQuestion List
    * @return AssessmentQuestionVersion List
    */
    @testVisible
    public static List<AssessmentQuestionVersion >  createAssessmentQuestionVersion(List<AssessmentQuestion> questionList) {
        
        List<AssessmentQuestionVersion > assessmentQuestionVersionList= new List<AssessmentQuestionVersion >();
        AssessmentQuestionVersion q1 = new AssessmentQuestionVersion(assessmentQuestionId=questionList[0].Id,Questiontext='Select all assets and income*',Name='Assets and Income');
        AssessmentQuestionVersion q2 = new AssessmentQuestionVersion(assessmentQuestionId=questionList[1].Id,Questiontext='Select years*',Name='Assets and Income');
        AssessmentQuestionVersion q3 = new AssessmentQuestionVersion(assessmentQuestionId=questionList[2].Id,Questiontext='Select all fund assets and income',Name='Assets and Income');
        AssessmentQuestionVersion q4 = new AssessmentQuestionVersion(assessmentQuestionId=questionList[3].Id,Questiontext='Are you associated to any Shell Banks',Name='Account Purpose');
        
        assessmentQuestionVersionList.add(q1);
        assessmentQuestionVersionList.add(q2);
        assessmentQuestionVersionList.add(q3);
        assessmentQuestionVersionList.add(q4);
        
        insert assessmentQuestionVersionList;
        return assessmentQuestionVersionList;
    }

    
        
  
}