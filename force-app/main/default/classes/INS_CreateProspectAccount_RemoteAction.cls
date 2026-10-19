/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : INS_CreateProspectAccount_RemoteAction
 * Author          : <YourName>
 * Created Date    : Mar 19, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Mar 19, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Mar 19, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

global without sharing class INS_CreateProspectAccount_RemoteAction implements callable{

	global Object call(String actionType, Map<String, Object> args) {
        if (actionType == 'createAccount') {
            Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return createAccount(input, output);
        }else if(actionType == 'createOpportunity'){
			Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return createOpportunity(input, output);
		}else if(actionType == 'getProductDetails'){
			Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return getProductDetails(input, output);	

		}

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }	


	@AuraEnabled(cacheable=false)
	public Static Object createAccount(Map<String, Object> input, Map<String, Object> output){
		Map<String,String> MaritalStausMap = new Map<String,String>{
			'Single' => '1',
			'Married' => '2',
			'Divorced' => '4',
			'Widowed' => '5'
		};

		Map<String,Object> PersonalInformation = (Map<String,Object>)input.get('PersonalInformation');		     
        String dobStr = (String)PersonalInformation.get('OS_DateOfBirth');		
        Date dateOfBirth = Date.valueOf(dobStr);            
		String prospectPersonAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account - Prospect').getRecordTypeId();
		
		Account accObj = new Account();
		accObj.FirstName = (String) PersonalInformation.get('FirstName');
		accObj.LastName = (String) PersonalInformation.get('LastName');
		accObj.PersonGender = (String)PersonalInformation.get('Gender');
		String maritalStatus = (String)PersonalInformation.get('MaritalStatus');
		accObj.FinServ__MaritalStatus__pc = MaritalStausMap.get(maritalStatus);
		//accObj.FinServ__Gender__pc = (String)PersonalInformation.get('Gender');// female=2, Male=1
		accObj.PersonEmail = (String) PersonalInformation.get('Email');
		accObj.PersonBirthdate = dateOfBirth;
		accObj.RecordTypeId = prospectPersonAccRecTypeId;
		accObj.CMN_IdentityNumber__pc = (String) PersonalInformation.get('IdNumber');
		accObj.PersonMobilePhone = (String) PersonalInformation.get('PhoneNumber');
		accObj.PersonHomePhone = (String) PersonalInformation.get('PhoneNumber');
		// ExternalCIFId__c[TBC] accObj.Id
		//ExternalCIFCountry__c// KE or INS_productmetdata
		insert accObj;

		output.put('ProspectAccountId',accObj.Id);

		return output;
	}


	@AuraEnabled
	public static Object getProductDetails(Map<String, Object> input, Map<String, Object> output){

		// Search for product data
		Product2 prod2Obj = [Select Id, Name from Product2 where Name = 'Flexi Protect' LIMIT 1];
		// Search Pricebook2
		output.put('ProductId',prod2Obj.Id);
		Pricebook2 pbObj = [Select Id, isActive, Name FROM Pricebook2 where Name ='C&HNW(Kenya)' AND isActive=true];
		output.put('PricebookId',pbObj.Id);
		// Search PBE
		PricebookEntry pbeObj =[Select Id, Pricebook2Id, Product2Id, UnitPrice from PricebookEntry WHERE Product2Id =: prod2Obj.Id AND Pricebook2Id=: pbObj.Id];
		output.put('PricebookEntryId',pbeObj.Id);
		output.put('PricebookEntryUnitPrice',pbeObj.UnitPrice);
		return output;
	}

	@AuraEnabled(cacheable=false)
	public static Object createOpportunity(Map<String, Object> input, Map<String, Object> output) {

		String accountId  = (String) input.get('accountId');
		String userId     = (String) input.get('assistedUserId');
		String contactId  = (String) input.get('assistedContactId');
		Map<String, Object> quoteDetails = (Map<String, Object>) input.get('CreateQuoteResponse');
		Map<String, Object> insProduct   = (Map<String, Object>) input.get('INS_Products');

		//  ONE combined query instead of 6 — gets Product, Pricebook, and PricebookEntry together
		PricebookEntry pbe = [
			SELECT Id, UnitPrice,
				Product2Id, Product2.Name,
				Pricebook2Id, Pricebook2.Name
			FROM PricebookEntry
			WHERE Product2.Name = 'Flexi Protect'
			AND Pricebook2.Name = 'C&HNW(Kenya)'
			AND Pricebook2.IsActive = true
			LIMIT 1
		];

		// Cache record type IDs (one-time lookup, no SOQL)
		Id oppRtId   = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('General').getRecordTypeId();
		Id quoteRtId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('LookSee Quote').getRecordTypeId();

		//  Compute date once
		Date today = Date.today();
		String oppName =
			String.valueOf(insProduct.get('Product__c')) + ' ' +
			String.valueOf(insProduct.get('Country__c')) + ' - ' +
			today.year() + '-' + today.month() + '-' + today.day();

		String benefitAmountValue = quoteDetails.containsKey('benefitAmountValue') && quoteDetails.get('benefitAmountValue') != null
			? String.valueOf(quoteDetails.get('benefitAmountValue'))
			: '0';

		// === STEP 1: Insert Opportunity ===
		Opportunity opp = new Opportunity();
		opp.AccountId                  = accountId;
		opp.Name                       = oppName;
		opp.StageName                  = 'Quoting';
		opp.Type                       = 'Liberty Life';
		opp.ICS_Opportunity_Type__c    = 'Single';
		opp.CloseDate                  = today;
		opp.RecordTypeId               = oppRtId;
		opp.Country__c                 = String.valueOf(insProduct.get('Country__c'));
		opp.CurrencyIsoCode            = String.valueOf(insProduct.get('Currency__c'));
		opp.LeadSource                 = 'Liberty';
		opp.Opportunity_Source__c      = 'Direct (in-person, call, Online)';
		opp.Proposal_Date__c           = today;
		opp.Quote_Id__c                = (String) quoteDetails.get('quoteId');
		opp.Total_Cover_Amount__c      = (Decimal) quoteDetails.get('coverAmount');
		opp.Total_Monthly_Premium__c   = Decimal.valueOf(benefitAmountValue);

		if (contactId != null) opp.FinServ__ReferredByContact__c = contactId;
		if (userId    != null) opp.FinServ__ReferredByUser__c    = userId;

		insert opp;

		// === STEP 2: Build OpportunityLineItem AND Quote, then insert in ONE batched DML ===
		// Note: OLI requires Opportunity to exist first, so we couldn't combine with Step 1.
		// But OLI and Quote can be inserted together since they only depend on opp.Id.
		OpportunityLineItem oli = new OpportunityLineItem();
		oli.OpportunityId    = opp.Id;
		oli.PricebookEntryId = pbe.Id;
		oli.Product2Id       = pbe.Product2Id;
		oli.Quantity         = 1;

		Quote qt = new Quote();
		qt.OpportunityId                            = opp.Id;
		qt.Name                                     = 'Flexi Protect Quote';
		qt.RecordTypeId                             = quoteRtId;
		qt.Status                                   = 'Quote In-Progress';
		qt.UnderwriterQuoteReferenceNumber__c       = (String) quoteDetails.get('quoteId');
		qt.ExpirationDate                           = today.addDays(30);
		qt.CurrencyIsoCode                          = String.valueOf(insProduct.get('Currency__c'));

		// Single Database.insert call inserts both records at once
		Database.insert(new List<SObject>{ oli, qt }, true);

		// Quote.QuoteNumber is auto-generated; need to query back, but we can do it cheaply
		String quoteNumber = [SELECT QuoteNumber FROM Quote WHERE Id = :qt.Id LIMIT 1].QuoteNumber;

		output.put('OppId',       opp.Id);
		output.put('QuoteNumber', quoteNumber);
		return output;
	}

	

}