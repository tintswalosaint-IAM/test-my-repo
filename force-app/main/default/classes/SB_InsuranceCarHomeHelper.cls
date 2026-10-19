/**
* @author            : Hasrat Mohammad
* @description       : Helper class for SB_InsuranceCarHomeContoller
* @date 			 : 31/10/2024
* @testclass 		 : SB_InsuranceCarHomeContoller_TEST
**/

public with sharing class SB_InsuranceCarHomeHelper {
    
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SB_InsuranceCarHomeHelper');
    public static Database.LeadConvertResult convertLead(Database.LeadConvert leadConvert){
        Database.LeadConvertResult leadConversionResult;
        try{
            if(leadConvert != null){
                // Unable to create a person account as an SVC Agent due to access level restrictions hence why this operation is ran in system mode 
                leadConversionResult = Database.convertLead(leadConvert,true, AccessLevel.SYSTEM_MODE);
            } 
        }
        catch(Exception ex){
            logger.error('SB_InsuranceCarHomeHelper'+ ex.getMessage() + ' Line Exception '+ ex.getLineNumber() + ' Stack trace: ' + ex.getStackTraceString());
        }
        return leadConversionResult;
        
    }
    
/**
* Method to create Account and identity document from lead
* @return account.id
*/
    public static String createAccount(Lead lead,  Map<String, Object> inputMap){
        String genderCode = '0';
        if(lead.GenderIdentity == 'Male'){
            genderCode = '1';
        }
        else if(lead.GenderIdentity == 'Female'){
            genderCode = '2';
        }
        Account account = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
            PersonTitle = lead.Title,
            FirstName = lead.FirstName,
            LastName = lead.LastName,
            PersonMobilePhone = lead.MobilePhone,
            Identification_Number__c = lead.ID_Number__c,
            FinServ__Gender__pc = genderCode,
            PersonBirthdate = lead.AOB_Date_of_Birth__c,
            FinServ__MaritalStatus__pc = lead.Marital_Status__c,
            BillingStreet = lead.Street,
            BillingCity = lead.City, 
            BillingState = lead.State, 
            BillingPostalCode = lead.PostalCode,
            BillingCountry = lead.Country,
            FinServ__CountryOfResidence__pc='ZA',
            ExternalCIFCountry__c='ZA'
        );
        Database.insert(account, AccessLevel.SYSTEM_MODE);  // Unable to create a person account as an SVC Agent due to access level restrictions hence why this operation is ran in system mode 
            
        IdentityDocument identityDocument = new IdentityDocument(
            Name = lead.ID_Number__c,
            IdDocumentType = '1',
            RelatedLegalEntityId = account.Id
        );
        Database.insert(identityDocument, AccessLevel.USER_MODE);     
        return account?.Id;
    }
/**
* Method to create applicationForm
*/
    public static void createApplicationForm(String accountId,String leadId,String opportunityId){
        ApplicationForm applicationForm = new ApplicationForm(
                AccountId = accountId,
                LeadId = leadId,
                UsageType = 'Onboarding',
                OpportunityId = opportunityId,
                Stage = 'Initiated'
        );
        Database.insert(applicationForm, AccessLevel.USER_MODE);
    }
    
/**
* Method to create opportunity from lead
* @return opportunity.id
*/
     public static String createOpportunityLead(Lead lead,String referrerId,String leadSource){ 
         Opportunity opportunity = createOpportunity();
         opportunity.Name =  lead.FirstName + ' '+lead.LastName + ' - Car and Home Insurance - ' + system.today().format();
         opportunity.AccountId = lead.FinServ__RelatedAccount__c;
         opportunity.Lead__c = lead.Id;
         opportunity.FinServ__ReferredByUser__c = checkValueifBlank(referrerId);
         opportunity.LeadSource = leadSource;
         
        Database.insert(opportunity, AccessLevel.USER_MODE);
        return opportunity.Id;
    }
    
    /**
* Method to create opportunity from Account
* @return opportunity.id
*/
    public static String createOpportunityAccount(Account account){ 
        Opportunity opportunity = createOpportunity();
        opportunity.Name =  account.FirstName + ' '+account.LastName + ' - Car and Home Insurance - ' + system.today().format();
        opportunity.AccountId = account.Id;
        
        Database.insert(opportunity, AccessLevel.USER_MODE);
        return opportunity.Id;
    }
    
    /**
* Method to do common mapping of opportunity
* @return opportunity
*/
    public static Opportunity createOpportunity(){
        Pricebook2 priceBook = getOpportunityPriceBook();
        return new Opportunity(
            Pricebook2Id = priceBook?.Id,
            CurrencyIsoCode = priceBook?.CurrencyIsoCode,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('General').getRecordTypeId(),
            CloseDate = System.today().addDays(30),
            StageName = 'Needs Analysis',
  			Country__c = 'ZA'            
        );
    } 

/**
* Method to check referrerId if return as blank
* @return referrerId
*/
    private static String checkValueifBlank(String referrerId){
        if(String.isBlank(referrerId)){
            referrerId = null;
        }
        return referrerId;
    }
    

    
/**
* Method to check getPricebook
* @return priceBookId
*/ 
    @testVisible
    public static Pricebook2 getOpportunityPriceBook(){
        Pricebook2 priceBook = null;
        List<Pricebook2> priceBookList = new SEL_Pricebook2().selectPriceBook('Name = \'C&HNW (South Africa)\' AND IsActive = true'); 

        if(priceBookList != null && !priceBookList.isEmpty()){
            priceBook = priceBookList[0];
        }
        return priceBook;
    }    
    
    
    public static Map<String, Object> createOpportunityFromAccount(String accountId,Map<String, Object> outMap){
        
        String opportunityId = null;
        Opportunity opportunity = new SEL_Opportunity().getOpenOpportunityByAccountId(accountId,'General','%Car and Home Insurance%');
        
        
        if(opportunity == null && String.isBlank(opportunity?.Id)){
            Account account = new SEL_Account().selectById(accountId);
            opportunityId = createOpportunityAccount(account);
        }
        
        else if(opportunity != null & String.isNotBlank(opportunity?.Id)){
            opportunityId = opportunity.Id;
        }
        
        outMap.put('AccountRecId',accountId);
        outMap.put('OpportunityRecId',opportunityId);
        
        return outMap;
    }

}