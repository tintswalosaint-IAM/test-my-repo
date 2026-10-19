/***************************************************************************************
* @Name            : ICS_API_SAPCreateAccount
* @Description     : Creates SAP accounts by generating and sending formatted JSON requests
* @Author          : Mahesh
* @Created Date    : Oct 22 2024
* @Last Modified   : Improved documentation for methods and data structures
*******************************************************************************************
* @Name            : ICS_API_SAPCreateAccount
* @Description     : SFP-57198 @Last Modified By 		
* @Author          : Ikyatha Naidoo
* @Last Modified On: 30-11-2026
*@Modification description : SFP-57198  constructFullName() → method intended to build a full name (though the logic shown is about account resolution)
* 
****************************************************************************************/
public without sharing class ICS_API_SAPCreateAccount {
    final Id accountId;
    public String jsonRequest { get; private set; }
     Public static string currencyCode;
    public ics_customlabel__mdt customMetaData;
    Map<String, String> parsedData = new Map<String, String>();
    
    /**
* @description Constructor initializes the class with account ID and generates JSON request
* @param accId Salesforce Account ID for which SAP account needs to be created
*/
    public ICS_API_SAPCreateAccount(Id accId,string currencyCCode) {
        this.accountId = accId;
        currencyCode =currencyCCode;
         this.jsonRequest = generatejsonRequest();
              
    }
    
    /**
* @description Retrieves custom metadata configuration for SAP account creation
* @return ics_customlabel__mdt Custom metadata record containing SAP configuration
* @throws SecurityException If user lacks access permissions
* @throws MetadataParsingException If query fails
*/
    private ics_customlabel__mdt getCustomMetaData() {
        String developerName = 'Ics_Custom_SAPCreateAccountData';
        if (!ics_customlabel__mdt.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Insufficient permissions to access ics_customlabel__mdt');
        }
        try {
            return [SELECT DeveloperName, Description__c FROM ics_customlabel__mdt WHERE DeveloperName = :developerName LIMIT 1];
        } catch (QueryException e) {
            throw new SAPCreateAccountException(e.getMessage() , e);
        }
    }
    
    /**
* @description Generates JSON request payload for SAP account creation
* @return String Formatted JSON string containing account creation request
*/
    public String generatejsonRequest() {
        customMetaData = getCustomMetaData();
        parsedData = parseCustomMetadataJson(customMetadata);
        
        ICS_DTO_SAP_CreateAccountRequest requestBody = new ICS_DTO_SAP_CreateAccountRequest();
        requestBody.Account = new List<ICS_DTO_SAP_CreateAccountRequest.Account>();
        
        
        SEL_FinServ_FinancialAccount financialAccount = new SEL_FinServ_FinancialAccount();
        List<FinServ__FinancialAccount__c> accountInfoList = financialAccount.selectByPrimaryOwnerIds(new set<Id>{accountId});
        if (accountInfoList.size() > 0) {
            String bpId = accountInfoList[0].ExternalCIFId__c;
            ICS_DTO_SAP_CreateAccountRequest.Account account = new ICS_DTO_SAP_CreateAccountRequest.Account();
            account.AccountNumber = createAccountNumber(bpId);
            account.ProductInstanceReference = createProductInstanceReference(accountId);
            account.CustomerCashFlowPosition = createCustomerCashFlowPosition();
            account.AdditionalData = createAdditionalData();
            requestBody.Account.add(account);
        }
        return JSON.serialize(requestBody, true);
    }
    
    /**
* @description Parses JSON from custom metadata into map of key-value pairs
* @param metadata Custom metadata record containing JSON configuration
* @return Map<String, String> Parsed key-value pairs from JSON
* @throws MetadataParsingException If JSON is invalid or missing
*/
    private Map<String, String> parseCustomMetadataJson(ics_customlabel__mdt metadata) {
        Map<String, String> stringMap = new Map<String, String>();
        
        if (metadata == null || String.isEmpty(metadata.Description__c)) {
            throw new SAPCreateAccountException('Metadata or Description__c is null');
        }
        
        try {
            Object parsed = JSON.deserializeUntyped(metadata.Description__c);
            if (!(parsed instanceof Map<String, Object>)) {
                throw new SAPCreateAccountException('Invalid JSON structure: expected object');
            }
            
            Map<String, Object> rawMap = (Map<String, Object>)parsed;
            for (String key : rawMap.keySet()) {
                if (key == null){ 
                    continue;
                }
                Object value = rawMap.get(key);
                stringMap.put(key, value == null ?'': String.valueOf(value) );
            }
        } catch (JSONException e) {
            throw new SAPCreateAccountException('Invalid JSON format: ' + e.getMessage() , e);
        }
        
        return stringMap;
    }
    
    /**
* @description Creates account number structure with identification details
* @param bpId Business Partner ID for account identification
* @return Account number structure with identification information
*/
    private ICS_DTO_SAP_CreateAccountRequest.AccountNumber createAccountNumber(String bpId) {
        ICS_DTO_SAP_CreateAccountRequest.AccountNumber accountnum = new ICS_DTO_SAP_CreateAccountRequest.AccountNumber();
        accountnum.AccountIdentification = new List<ICS_DTO_SAP_CreateAccountRequest.AccountIdentification>();
        
        ICS_DTO_SAP_CreateAccountRequest.AccountIdentification accountIdentification = new ICS_DTO_SAP_CreateAccountRequest.AccountIdentification();
        accountIdentification.AccountIdentificationType = (String)parsedData.get('ics_accountNumber_AccountIdentificationType');
        accountIdentification.AccountIdentification = new ICS_DTO_SAP_CreateAccountRequest.IdentifierValueWrapper();
        accountIdentification.AccountIdentification.IdentifierValue = new ICS_DTO_SAP_CreateAccountRequest.IdentifierValue();
        accountIdentification.AccountIdentification.IdentifierValue.Value = bpId;
        accountIdentification.AccountIdentification.IdentifierStartDate = new ICS_DTO_SAP_CreateAccountRequest.IdentifierStartDate();
        Date today = Date.today();
        accountIdentification.AccountIdentification.IdentifierStartDate.DateTimeContent = 
            DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
        accountIdentification.AccountIdentification.IdentifierIssuingAuthority  = new ICS_DTO_SAP_CreateAccountRequest.IdentifierIssuingAuthority();
        accountIdentification.AccountIdentification.IdentifierIssuingAuthority.PartyInvolvement = new ICS_DTO_SAP_CreateAccountRequest.PartyInvolvement();
        
        string name=constructFullName();
        if(name.length() > 25 ){
            accountIdentification.AccountIdentification.IdentifierIssuingAuthority.PartyInvolvement.PartyInvolvementType= name.substring(0,25);
        } else {
            accountIdentification.AccountIdentification.IdentifierIssuingAuthority.PartyInvolvement.PartyInvolvementType= name;
        }
        
        
        accountnum.AccountIdentification.add(accountIdentification);
        
        return accountnum;
    }
    
    private String constructFullName() {
       
        List<AccountContactRelation> accrList = [SELECT Id,AccountId,Contact.AccountId 
                                                 FROM AccountContactRelation 
                                                 WHERE accountId =: accountId and Account.RecordType.Name ='Joint Account'];
        String accId='';
        if(accrList.isEmpty()){
            accId = accountId;
        }else{
            accId = accrList[0].Contact.AccountId;
        }
        SEL_ApplicationForm selAppForm=new SEL_ApplicationForm();
        List<ApplicationForm> appform=selAppForm.selectByAccountId(accId);
        if(appform.size()>0){
            List<ApplicationForm> appforms=selAppForm.selectByOpportunityId(appform[0].OpportunityId);
            List<String> namesList = new List<String>();
            for(ApplicationForm appf :appforms){
                namesList.add(appf.account.persontitle + ' ' + appf.account.lastName);
            }
            String concatenatedNames = String.join(namesList, ', ');
            return concatenatedNames;
        }
        return null;
    }
    
    /**
* @description Creates product instance references for the account
* @param accId Account ID to retrieve product information
* @return List of product instance references with product codes
*/
    private List<ICS_DTO_SAP_CreateAccountRequest.ProductInstanceReference> createProductInstanceReference(String accId) {
        List<ICS_DTO_SAP_CreateAccountRequest.ProductInstanceReference> productInstanceReferences = 
            new List<ICS_DTO_SAP_CreateAccountRequest.ProductInstanceReference>();
        
        SEL_Opportunity oppSelector = new SEL_Opportunity();
            List<Opportunity> oppList = oppSelector.selectByAccountId(accountId);
        String oppId = oppList[0].Id;
        OpportunityLineItem oppLineItem = [SELECT Id, ProductCode FROM OpportunityLineItem WHERE OpportunityId = :oppId LIMIT 1];
        
        ICS_DTO_SAP_CreateAccountRequest.ProductInstanceReference productInstanceReference = 
            new ICS_DTO_SAP_CreateAccountRequest.ProductInstanceReference();
        productInstanceReference.ProductIdentificationType = (String)parsedData.get('ics_productInstanceReference_productIdentificationType');
        productInstanceReference.ProductIdentification = new ICS_DTO_SAP_CreateAccountRequest.ProductIdentification();
        productInstanceReference.ProductIdentification.IdentifierValue = new ICS_DTO_SAP_CreateAccountRequest.IdentifierValue();
        productInstanceReference.ProductIdentification.IdentifierValue.Value = oppLineItem.ProductCode;
        
        productInstanceReferences.add(productInstanceReference);
        return productInstanceReferences;
    }
    
    /**
* @description Creates customer cash flow position information
* @return List of cash flow positions with currency details
*/
    private List<ICS_DTO_SAP_CreateAccountRequest.CustomerCashFlowPosition> createCustomerCashFlowPosition() {
        List<ICS_DTO_SAP_CreateAccountRequest.CustomerCashFlowPosition> customercashflows = 
            new List<ICS_DTO_SAP_CreateAccountRequest.CustomerCashFlowPosition>();
        
        ICS_DTO_SAP_CreateAccountRequest.CustomerCashFlowPosition customercashflow = 
            new ICS_DTO_SAP_CreateAccountRequest.CustomerCashFlowPosition();
            
        customercashflow.PositionAmount = new ICS_DTO_SAP_CreateAccountRequest.PositionAmount();
        customercashflow.PositionAmount.AmountCurrency = currencyCode;
        customercashflows.add(customercashflow);
        
        return customercashflows;
    }
    
    /**
* @description Creates additional metadata for SAP account request
* @return Additional data structure with category information and tracking details
*/
    private ICS_DTO_SAP_CreateAccountRequest.AdditionalData createAdditionalData() {
        ICS_DTO_SAP_CreateAccountRequest.AdditionalData additionaldata = new ICS_DTO_SAP_CreateAccountRequest.AdditionalData();
        additionaldata.CategoryInformation = new ICS_DTO_SAP_CreateAccountRequest.CategoryInformation();
        additionaldata.CategoryInformation.Category = new List<ICS_DTO_SAP_CreateAccountRequest.Category>();
        
        ICS_DTO_SAP_CreateAccountRequest.Category category = new ICS_DTO_SAP_CreateAccountRequest.Category();
        category.CategoryItem = (String)parsedData.get('ics_category_CategoryItem');
        category.CategoryDetails = new List<ICS_DTO_SAP_CreateAccountRequest.CategoryDetail>();
        
        String guid = AOB_Utils.generateGUID();
        Map<String, String> categoryDetails = new Map<String, String>{
            'timestamp' => DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss'),
                'correlationID' => guid,
                'channelID' => parsedData.get('ics_category_channelID'),
                'UserID' => parsedData.get('ics_category_UserID'),
                'referenceID' => parsedData.get('ics_category_referenceID'),
                'OriginatingChannel' => parsedData.get('ics_category_OriginatingChannel'),
                'OriginatingProcess' => parsedData.get('ics_category_OriginatingProcess')
                };
                    
                    for (String key : categoryDetails.keySet()) {
                        ICS_DTO_SAP_CreateAccountRequest.CategoryDetail categorydetail = new ICS_DTO_SAP_CreateAccountRequest.CategoryDetail();
                        categorydetail.CategoryType = key;
                        categorydetail.CategoryIdentifierValue = categoryDetails.get(key);
                        category.CategoryDetails.add(categorydetail);
                    }
        
        additionaldata.CategoryInformation.Category.add(category);
        return additionaldata;
    }
    
    public class SAPCreateAccountException extends Exception {}
}