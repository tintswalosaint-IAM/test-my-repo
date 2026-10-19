/**
 * @description Boost Application SharePoint Pdf Controller Class
 * @author November Sizwe
 * @date September 2022
 */
public with sharing class ICS_CTRL_BoostApplicationPDF {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_Boost_Application');    
   /**
    * @description Account variable, can be used to get and set Account data
    * @return Account
    */
    public Account acc{get;set;}
    /**
    * @description Property to hold a list of other Business Account
    * @return Account
    */
    public List <Account> otherBusiness{get;set;}
    /**
    * @description Property to hold Opportunity data
    * @return Opportunity
    */
    public Opportunity opp{get;set;}
    /**
    * @description Property to hold a list of Application__c data
    * @return Application__c
    */
    public List <Application__c> applicationList{get;set;}
    
    /**
    * @description Property to hold a list of ContactPointAddress data
    * @return ContactPointAddress
    */
    public List<ContactPointAddress> addressList{get;set;}
    /**
    * @description employmentList variable to hold a list of FinServ__Employment__c data
    * @return FinServ__Employment__c
    */
    public List<FinServ__Employment__c>  employmentList{get;set;}
    /**
    * @description Property to hold a list of FinServ__Employment__c from Previous record type data
    * @return FinServ__Employment__c
    */
    public List<FinServ__Employment__c>  previousEmploymentList{get;set;}
    
    /**
     * @description This property holds an instance of the notesContentDetails class.
     * @return List instance of the notesContentDetails class.
     */
    public List<ContentNoteWrapper> wrappedContentNotes {get; set;}
    
    /**
     * @description The assetIncomeDetails class is a container for various types of asset and income data.
     * It is structured to hold lists of AssetsAndIncomes__c records, categorized by different record types.
     */
    public class AssetIncomeDetails {
        /**
        * @description List of AssetsAndIncomes__c fields, used to get set asset and income data
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeList {get; set;}
        /**
        * @description List of AssetsAndIncomes__c fields,used to get set asset income by country record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeCountry {get; set;}
        /**
        * @description List of AssetsAndIncomes__c fields,used to get set asset income by property record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeProperty{get;set;}
        /**
        * @description List of AssetsAndIncomes__c fields,used to get set asset income by investment/stocks record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeInvestStocks{get;set;}
        /**
        * @description List of AssetsAndIncomes__c fields, used to get set asset income by Additional Account record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeAddAcc{get;set;}
        /**
        * @description List of AssetsAndIncomes__c fields, to get and set asset income by Other record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeOther{get;set;}
        /**
        * @description List of AssetsAndIncomes__c fields, to get and set asset income Expected Turnover
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> expectedTurnOver{get;set;}
        /**
        * @description List of AssetsAndIncomes__c fields from future fund record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> assetIncomeFutureFund{get;set;}
        /**
        * @description List of AssetsAndIncomes__c fields from Bank deposits record type
        * @return AssetsAndIncomes__c
        */
        public List<AssetsAndIncomes__c> initialdepositBank{get;set;}
    }
    /**
     * @description This property holds an instance of the assetIncomeDetails class.
     * @return An instance of the assetIncomeDetails class.
     */
    public AssetIncomeDetails assetDetails {get; set;}
     
    /**
    * @description List of Acc_Future_Funding__c fields
    * @return Acc_Future_Funding__c
    */
    public List<Acc_Future_Funding__c> accfuturefunList{get;set;}
    /**
    * @description List of PartyProfile fields
    * @return PartyProfile
    */
    public List<PartyProfile> partyProfileList{get;set;}
    
    /**
    * @description Property to indicate if the user owns a bank account (true if they do, false otherwise)
    * @return Boolean
    */
    public Boolean ownBankAccount {get;set;}
    
    /**
    * @description Property to hold the turnover amount
    * @return Decimal
    */
    public Decimal turnOver {get;set;}
    /**
    * @description Property to hold the turnover from amount
    * @return Decimal
    */
    public Decimal turnOverfrom {get;set;}
    
    /**
    * @description Property to hold index amount
    * @return Integer
    */
    public Integer index { get; set; }
    
    /**
    * @description Property to hold the type of currency for future transactions
    * @return String
    */
    public String futureCurrency {get;set;}
    
    /**
    * @description Property to hold the status of the user's previous employment
    * @return String
    */
    public String prevemploymentStatus {get;set;}
    
    /**
    * @description Property to hold a list of Tax Data wrapped in a custom wrapper class
    * @return List<TaxDataWrapper>
    */
    public List<TaxDataWrapper> taxDataList {get;set;}
    
    /**
     * @description This class holds the Contact records of different types of brokers associated with an account. 
     * Each property represents the Contact records of a specific type of broker. 
     */
    public class BrokerContact{
        /**
        * @description Property to hold Contact records of the IFA from Account Contact
        * @return Contact
        */
        public List<Contact> ifaContacts {get;set;}
        
        /**
        * @description Property to hold the Contact records of the SBFC from Account Contact
        * @return Contact
        */
        public List<Contact> sbfcContact {get;set;}
        
        /**
        * @description Property to hold the Contact records of the Private Banker from Account Contact
        * @return Contact
        */
        public List<Contact> privateBankerContact {get;set;}
        
        /**
        * @description Property to hold the Contact records of the Prestige Banker Account Contact
        * @return Contact
        */
        public List<Contact> prestigeBankerContact {get;set;}
        
    }
    
    /**
     * @description This instance variable holds an object of type brokerContact.
     * It stores the Contact Lists of different types of brokers associated with an Account Contact
     */
    public BrokerContact brokerContact {get;set;} 
    
    /**
    * @description Method to map the country name
    * @return Map of String	 Map of the country name
    */  
    public Map<String, String> getCountryNameMap() {
        
        Map<String, String> countryNameMap = new Map<String, String>();
        try{
            
            Schema.DescribeFieldResult fieldResult = Application__c.Country_of_Tax__c.getDescribe();
            List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
    
            for (Schema.PicklistEntry entry : picklistValues) {
                countryNameMap.put(entry.getValue(), entry.getLabel());
            }
        }
        catch(Exception e){
            LOGGER.error('Error on getCountryNameMap', e); 
            
        }
       
        return countryNameMap;
    }

   
    /**
     * @description Controller constructor, query application and related objects
     */    
    public  ICS_CTRL_BoostApplicationPDF (){
		
        try{
            String oppID;
            if(Test.isRunningTest()) { 
                oppID = [SELECT Id FROM Opportunity LIMIT 1].id;
            } 
            else {
                oppID = Id.valueOf(Apexpages.currentPage().getparameters().get('Id'));
            }
           brokerContact = new BrokerContact();
           assetDetails = new AssetIncomeDetails();
           ICS_SEL_Opportunity opportunitySelector = new ICS_SEL_Opportunity();
           opp = opportunitySelector.getOpportunity(oppID);
           String accID = opp.Accountid;
           ICS_SEL_Account accountSelector = new ICS_SEL_Account();
           acc = accountSelector.getAccount(accID);
           prevemploymentStatus = acc.Previous_Employment_Status__c;
           ICS_SEL_Application applicationSelector = new ICS_SEL_Application();
           applicationList = applicationSelector.getApplications(oppID);
           String appID = applicationList[0].id;
           otherBusiness = accountSelector.getOtherBusinessList(appID);
           wrappedContentNotes = new List<ContentNoteWrapper>();
           ICS_SEL_ContentDocumentLink contentDocumentLinkSelector = new ICS_SEL_ContentDocumentLink();
           ICS_SEL_ContentNote contentNoteSelector = new ICS_SEL_ContentNote();
           List<ContentNote> notesList = contentNoteSelector.getContentNotes(contentDocumentLinkSelector.getContentDocumentLinks(appID));
           for(ContentNote cn : notesList) {
                wrappedContentNotes.add(new ContentNoteWrapper(cn));
            }

           ICS_SEL_ContactPointAddress addressSelector = new ICS_SEL_ContactPointAddress();
           addressList = addressSelector.getContactPointAddresses(accID);
           ICS_SEL_FinServ_Employment employmentSelector = new ICS_SEL_FinServ_Employment();
           employmentList = employmentSelector.getEmployment(accID, 'Current');
           previousEmploymentList = employmentSelector.getEmployment(accID, 'Previous');
           ICS_SEL_AssetAndIncome assetIncomeSelector = new ICS_SEL_AssetAndIncome();
           assetDetails.assetIncomeCountry = assetIncomeSelector.getAssetIncomeList(appID, 'Wealth in Country');
           assetDetails.assetIncomeProperty = assetIncomeSelector.getAssetIncomeList(appID, 'Property');
           assetDetails.assetIncomeInvestStocks = assetIncomeSelector.getAssetIncomeList(appID, 'Assets/Investments/Stocks');
           assetDetails.expectedTurnOver = assetIncomeSelector.getAssetIncomeList(appID, 'Expected Turnover');
           assetDetails.assetIncomeAddAcc = assetIncomeSelector.getAssetIncomeList(appID, 'Additional Account');
           assetDetails.assetIncomeOther = assetIncomeSelector.getAssetIncomeList(appID, 'Other Income');
           ICS_SEL_AccFutureFunding accFutureSelector = new ICS_SEL_AccFutureFunding();
           accfuturefunList = accFutureSelector.getAccFutureList(appID);
           ICS_SEL_PartyProfile partyProfileSelector = new ICS_SEL_PartyProfile();
           partyProfileList = partyProfileSelector.getPartyProfileList(accID);
           ICS_SEL_Contact contactSelector = new ICS_SEL_Contact();
           
          Map<String, List<Contact>> ifaMap = new Map<String, List<Contact>>();

            if (opp.ICS_IFA_Broker__c != null) {
                List<Contact> ifaContactList = ifaMap.get('ICS_IFA_Broker__c');
                if (ifaContactList == null) {
                    ifaContactList = new List<Contact>();
                    ifaMap.put('ICS_IFA_Broker__c', ifaContactList);
                }
                brokerContact.ifaContacts = contactSelector.buildBrokerContactsQuery(opp.ICS_IFA_Broker__c);
                ifaContactList.addAll(brokerContact.ifaContacts);
            }
            
            if (opp.ICS_Prestige_Banker__c != null) {
                List<Contact> prestigeBankerContactList = ifaMap.get('ICS_Prestige_Banker__c');
                if (prestigeBankerContactList == null) {
                    prestigeBankerContactList = new List<Contact>();
                    ifaMap.put('ICS_Prestige_Banker__c', prestigeBankerContactList);
                }
                brokerContact.prestigeBankerContact = contactSelector.buildBrokerContactsQuery(opp.ICS_Prestige_Banker__c);
                prestigeBankerContactList.addAll(brokerContact.prestigeBankerContact);
            }
     
            if (opp.ICS_Private_Banker__c != null) {
                List<Contact> privateBankerContactList = ifaMap.get('ICS_Private_Banker__c');
                if (privateBankerContactList == null) {
                    privateBankerContactList = new List<Contact>();
                    ifaMap.put('ICS_Private_Banker__c', privateBankerContactList);
                }
                brokerContact.privateBankerContact = contactSelector.buildBrokerContactsQuery(opp.ICS_Private_Banker__c);
                privateBankerContactList.addAll(brokerContact.privateBankerContact);
            }

            if (opp.ICS_SBFC_Broker__c != null) {
                List<Contact> sbfcBrokerContactList = ifaMap.get('ICS_SBFC_Broker__c');
                if (sbfcBrokerContactList == null) {
                    sbfcBrokerContactList = new List<Contact>();
                    ifaMap.put('ICS_SBFC_Broker__c', sbfcBrokerContactList);
                }
                brokerContact.sbfcContact = contactSelector.buildBrokerContactsQuery(opp.ICS_SBFC_Broker__c);
                sbfcBrokerContactList.addAll(brokerContact.sbfcContact);
            }

           List<String> intentToFundAssetsList =  new List<String>();
           String intentToFundAssets = applicationList[0].Intent_to_Future_Deposits_Funds__c;
           turnOver = assetDetails.expectedTurnOver[0].Expected_Annual_Yearly_Turnover_To__c;
           turnOverfrom = assetDetails.expectedTurnOver[0].Expected_Annual_Yearly_Turnover_From__c;
           futureCurrency = assetDetails.expectedTurnOver[0].CurrencyIsoCode;
           if (String.isNotBlank(intentToFundAssets)){
           		intentToFundAssetsList = intentToFundAssets.split(';');
            }
           
           assetDetails.assetIncomeList = assetIncomeSelector.getAssetIncomeUsingAppIdList(appID);
            
           Boolean ownBankAccount = false;
            for (Application__c app : applicationList) {
                if (app.Your_Own_Bank_Account__c == 'Yes') {
                    ownBankAccount = true;
                    break;
                }
            }
                     
           Id assetBankId = applicationList[0].Bank_Account_the_Deposit_will_be_Coming__c;
           Map<Id, AssetsAndIncomes__c> assetBankMap = new Map<Id, AssetsAndIncomes__c>(assetDetails.assetIncomeList);
           AssetsAndIncomes__c initialBank = assetBankMap.get(assetBankId);
           assetDetails.initialdepositBank = (initialBank != null) ? new List<AssetsAndIncomes__c>{initialBank} : new List<AssetsAndIncomes__c>();
             
           List<AssetsAndIncomes__c> assetIncomePairs = new List<AssetsAndIncomes__c>();
    
           for (String intentToFund : intentToFundAssetsList) {
                Map<String, AssetsAndIncomes__c> assetIncomeMap = new Map<String, AssetsAndIncomes__c>();
            
                for (AssetsAndIncomes__c assetIncome : assetDetails.assetIncomeList) {
                    if (intentToFund != assetIncome.RecordType.Name && intentToFund != assetIncome.Other_Income_Type__c) {
                        continue;
                    }
            
                    String key = assetIncome.RecordType.Name + '_' + assetIncome.Other_Income_Type__c;
                    AssetsAndIncomes__c existingRecord = assetIncomeMap.get(key);
            
                    if (existingRecord == null) {
                        assetIncomeMap.put(key, assetIncome);
                    } else {
                        Boolean isNewRecordValid = assetIncome.Amounts__c != null && assetIncome.Is_future_fund__c;
                        Boolean isExistingRecordValid = existingRecord.Amounts__c != null && existingRecord.Is_future_fund__c;
            
                        if (isNewRecordValid && !isExistingRecordValid) {
                            assetIncomeMap.put(key, assetIncome);
                        }
                    }
                }
            
                assetIncomePairs.addAll(assetIncomeMap.values());
            }
    
            Map<String, AssetsAndIncomes__c> uniqueAssetIncomeMap = new Map<String, AssetsAndIncomes__c>();
            for (AssetsAndIncomes__c assetIncome : assetIncomePairs) {
                String key = assetIncome.RecordType.Name + '_' + assetIncome.Other_Income_Type__c;
                uniqueAssetIncomeMap.put(key, assetIncome);
            }

			assetDetails.assetIncomeFutureFund = new List<AssetsAndIncomes__c>(uniqueAssetIncomeMap.values());
            
            Application__c record = [SELECT Tax_data__c FROM Application__c WHERE Id =:appId LIMIT 1];
            Map<String, String> countryNameMap = getCountryNameMap();
            taxDataList = new List<TaxDataWrapper>();
            if (record != null && record.Tax_data__c != null) {
                List<Map<String, String>> tempList = (List<Map<String, String>>)JSON.deserialize(record.Tax_data__c, List<Map<String, String>>.class);
                for (Map<String, String> data : tempList) {
                    taxDataList.add(new taxDataWrapper(data, countryNameMap));
                }
            }
            
        }
        catch(Exception e){
            LOGGER.error('Error on ICS_CTRL_BoostApplicationPDF constructor', e); 
            
        }
    }
    /**
   * @description Wrapper class to hold ContentNote data and its content in string format.
   */ 
    public class ContentNoteWrapper {
        
        /**
     	* @description This instance variable holds an object of ContentNote.
     	*/
        public ContentNote note {get; set;}
        
		/**
     	* @description This instance variable holds an object of Content String.
     	*/
        public String contentString {get; set;}
    	
           /**
   		* @description This method maps the content string
   		* @param  cn  	Content note to converted to string
   		*/
        public ContentNoteWrapper(ContentNote cn) {
            this.note = cn;
            this.contentString = cn.Content.toString();
        }
    }

    /**
    * @description Tax data wrapper class to deserialize the tax data on Application 
    */       
    public class TaxDataWrapper {
        /**
        * @description Property to hold the countryOfTax field from Json Tax_data__c field 
        * @return String
        */
        public String countryOfTax {get; set;}
        /**
        * @description Property to hold the hasTIN field from Json Tax_data__c field 
        * @return String
        */
        public String hasTIN {get; set;}
        /**
        * @description Property to hold the taxIdentificationNumber field from Json Tax_data__c field 
        * @return String
        */
        public String taxIdentificationNumber {get; set;}
        /**
        * @description Property to hold the reasonForTINNINumber field from Json Tax_data__c field 
        * @return String
        */
        public String reasonForTINNINumber {get; set;}
        /**
        * @description Property to hold the reasonBExplanation field from Json Tax_data__c field 
        * @return String
        */
        public String reasonBExplanation {get; set;}
        /**
        * @description Property to hold the countryName field from Json Tax_data__c field 
        * @return String
        */
        public String countryName {get; set;}
        
        
        /**
         * @description Tax data wrapper constructor
         * @param data 				 Tax data on the Application
         * @param countryNameMap 	 Map of the country name
         */   
        public taxDataWrapper(Map<String, String> data, Map<String, String> countryNameMap) {
            
            this.countryOfTax = data.get('Country_of_Tax__c');
            this.hasTIN = data.get('Has_TIN__c');
            this.taxIdentificationNumber = data.get('Tax_Identification_Number__c');
            this.reasonForTINNINumber = data.get('Reason_For_TIN_NI_Number__c');
            this.reasonBExplanation = data.get('Reason_B_Explanation__c');

            this.countryName = isoToCountryName(this.countryOfTax, countryNameMap);

            }
        
        
            /*
            * @description Method to retrieve country name
         	* @param countryCode 		 ISO code of the country
         	* @param countryNameMap 	 Map of the country name
			* 
 			* @return String 			Country Name
            */
            private String isoToCountryName(String countryCode, Map<String, String> countryNameMap) {
                
                String countryISOName;
                
                if (countryCode == null) {
                    countryISOName = '';
                }
                else if(countryNameMap.containsKey(countryCode)){
                    
                    countryISOName = countryNameMap.get(countryCode);
                 }
                else{
                     
                     countryISOName = countryCode;
                 }
                return countryISOName;
           }
                        
    }

    
    /**
     * @description Invocable Method invoked by ICS Boost Application Submission flow
     * @param requestList 			Opportunity Id  and application reference number (Boost ID) from Boost in List format related to application to be submitted to Boost
     * @return List of Results 		Repsonse from SharePoint
     */    
    @InvocableMethod(label='Get Application' description='Returns the application for the specified opportunity ID.' category='Opportunity')
    public static List<Results> getApplicationPDF(List<Requests> requestList) {
        
       List<Results> response = new List<Results>(); 
       Results responseSharePoint = new Results();  
       responseSharePoint.statusCodePDF = ICS_API_BoostApplicationPDF.savePDFSharePointCallout(requestList[0].oppID, requestList[0].applicationReferenceNumber);
       response.add(responseSharePoint);        
  
       return response;      
      
    }
    
	/**
    * @description Results class with Invocable Variable returned to the ICS Boost Application Submission flow from SharePoint
    */   
    public class Results {
       @InvocableVariable(label = 'applicationPDFStatusCode')
       public Integer statusCodePDF;
    
    }
        
    /**
    * @description Request class with Invocable Variable received from the ICS Boost Application Submission flow
    */   
    public class Requests {
      @InvocableVariable(label = 'applicationRecordIDPDF')
      public Id oppID;
      @InvocableVariable(label = 'applicationReferencePDF')
      public String applicationReferenceNumber;
    }

}