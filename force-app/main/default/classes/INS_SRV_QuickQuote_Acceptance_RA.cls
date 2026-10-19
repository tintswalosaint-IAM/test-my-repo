/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : INS_SRV_QuickQuote_Acceptance_RA
 * Author          : <YourName>
 * Created Date    : May 7, 2026
 * Last Modified By: <YourName>
 * Last Modified On: May 7, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 7, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 {
  "INS_Products": {
    "CashBack_Benefit__c": false,
    "Currency__c": "KES",
    "MPESA_Branch_Code__c": "000000",
    "Bank_Name__c": "Stanbic Bank Kenya",
    "Default_Cover_Amount__c": 500000,
    "Product_Code__c": "8",
    "Product__c": "Flexi Protect",
    "PriceBook__c": "C&HNW(Kenya)",
    "Country_of_Issue__c": "KENYA",
    "Country__c": "KE",
    "DeveloperName": "Flexi_Protect_Kenya_New",
    "MasterLabel": "Flexi Protect New",
    "Id": "m0ybY000005EhgXQAS"
  },
  "quoteId": "7a46ec60-9a0b-41f9-90de-2b6af54b1656",
  "PaymentDetails": {
    "collectionMonth": "May",
    "paymentMethod": "MPESA",
    "WalletNumber": "9691919191",
    "CollectionDay":"30"    
  },
    "MembersDetails": {
    "FirstName": "IRSHADw",
    "LastName": "ALAMd",
    "IdNumber": "12343257",
    "Gender": "MALE",
    "OS_DateOfBirth": "2000-05-07"      
  },
  "omniScriptId": "0jNbY0000008B1VUAU",
  "elementName": "IntegrationProcedureAction3"
}
 */

global with sharing class INS_SRV_QuickQuote_Acceptance_RA implements Callable{
	private static final String QUOTE_ACCEPTANCE = 'QuoteAcceptance';
	global Object call(String actionType, Map<String, Object> args) {
        if (actionType == QUOTE_ACCEPTANCE) {
            Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return quoteAcceptanceAPI(input, output);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

	@AuraEnabled(cacheable=false)
	public static Object quoteAcceptanceAPI(Map<String, Object> input,Map<String, Object> output){

		
        String quoteId = (String) input.get('quoteId');
        String payloadJson = generateRequestPayload(quoteId,input);

		INS_SRV_QuickQuote_Acceptance QuickQuoteAcceptanceService = new INS_SRV_QuickQuote_Acceptance(payloadJson,quoteId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_SRV_QuickQuote_Acceptance.SERVICE_NAME);
        QuickQuoteAcceptanceService.process(obj);
        insert obj;

		Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            QuickQuoteAcceptanceService.getResponseBody()
        );
		Integer statusCode = QuickQuoteAcceptanceService.getResponseStatusCode();
        Map<String,Object> quoteAcceptance = new Map<String,Object>();
        if (statusCode == 201 || statusCode == 200) {
            
            Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');
            if (validation != null && 'Success'.equalsIgnoreCase((String) validation.get('ResultStatus'))) {
             	quoteAcceptance.put('ResultStatus', 'Success');
				quoteAcceptance.put('hasError', 'false'); 
                output.put('quoteAcceptResponse',quoteAcceptance);
            }
			
        } else {
            quoteAcceptance.put('hasError', 'true');
            Map<String, Object> errorMap = (Map<String, Object>) jsonResponseMap.get('error');
            String errorDescription = errorMap != null
                ? (String) errorMap.get('errorDescription')
                : QuickQuoteAcceptanceService.getResponseBody();
            quoteAcceptance.put('quoteAcceptResponse', errorDescription);
            output.put('quoteAcceptResponse', quoteAcceptance);
            
        }

		return output;

		

	}


    public static String generateRequestPayload(String quoteId, Map<String, Object> input) {

    Map<String, Object> productsMetadata = (Map<String, Object>) input.get('INS_Products');        
    Map<String, Object> paymentDetails   = (Map<String, Object>) input.get('PaymentDetails');
    Map<String, Object> membersWrapper   = (Map<String, Object>) input.get('MembersDetails');

    String debitOrderDayStr = (String) paymentDetails.get('CollectionDay');
    String walletNumber;
    if ((String) productsMetadata.get('Country__c') == 'KE' && (String) paymentDetails.get('WalletNumber') != null) {
        walletNumber = '254'+(String) paymentDetails.get('WalletNumber');    
    }
    Map<String, Object> bankingDetails = new Map<String, Object>();

    bankingDetails.put('idCountryOfIssue', productsMetadata.get('Country_of_Issue__c'));
    bankingDetails.put('identityDocumentType', 'SAIDENTITYDOCUMENT');
    bankingDetails.put('title', 'Mr');
    bankingDetails.put('idNumber', membersWrapper.get('IdNumber'));
    bankingDetails.put('gender', membersWrapper.get('Gender'));
    bankingDetails.put('contactNumber', walletNumber);
    bankingDetails.put('dateOfBirth', membersWrapper.get('OS_DateOfBirth'));
    bankingDetails.put('branchCode', productsMetadata.get('MPESA_Branch_Code__c'));
    bankingDetails.put('branchName', 'MPESA');
    bankingDetails.put('surname', membersWrapper.get('LastName'));
    bankingDetails.put('bankName', 'MPESA');
    bankingDetails.put(
        'name',
        String.valueOf(membersWrapper.get('FirstName')) + ' ' + String.valueOf(membersWrapper.get('LastName'))
    );
    bankingDetails.put('accountType', 'Savings');
    bankingDetails.put('accountNumber', walletNumber); 

    bankingDetails.put('debitOrderMandateCheck', true);
    bankingDetails.put('validationResponse', '');
    bankingDetails.put('isValidated', true);
    bankingDetails.put('validationOverridden', true);
    bankingDetails.put('bankAccountKey', '');

    Map<String, Object> payload = new Map<String, Object>();

    payload.put('CoverEffectiveDate', '2018-03-17T10:44:45.729Z');// String.valueOf(System.now())
    payload.put('BankingDetails', bankingDetails); // IMPORTANT: capital B
    payload.put('UnderwriterNotes', '');
    payload.put('premiumTypes', 1);
    payload.put('referralOverrideIndicator', true);
    payload.put('DebitOrderDate', debitOrderDayStr == 'LastdayofMonth' ? '-1' : debitOrderDayStr);
    payload.put('policyNumber', quoteId);
    payload.put('policyId', quoteId);
    payload.put('QuoteNumber', quoteId);
    payload.put('prorataPremium', 0);
        
   
    System.debug('Quote Acceptance Payload == ' + JSON.serializePretty(payload));

    return JSON.serialize(payload);
}

	/*
    public Static String  generateRequestPayload(String quoteId, Map<String, Object> input){

        Map<String, Object> productsMetadata = (Map<String, Object>) input.get('INS_Products');        
        Map<String, Object> paymentDetails = (Map<String, Object>) input.get('PaymentDetails');
        //Map<String, Object> INS_Product = (Map<String, Object>) input.get('INS_Products');
        Map<String, Object> membersWrapper = (Map<String, Object>) input.get('MembersDetails');
        System.debug('INPUT JSON2 == ' + JSON.serializePretty(input));
        
        AcceptQuoteWrapper wrap = new AcceptQuoteWrapper();
        String debitOrderDayStr = (String) paymentDetails.get('CollectionDay');
        wrap.QuoteNumber = quoteId;
        wrap.CoverEffectiveDate = String.valueOf(system.now());
        wrap.UnderwriterNotes = '';
        wrap.DebitOrderDate = debitOrderDayStr=='LastdayofMonth'?'-1':debitOrderDayStr;
        wrap.premiumTypes = 1;//hardcoded
        wrap.referralOverrideIndicator = true;//hardcoded
        wrap.policyNumber = quoteId;
        wrap.policyId = quoteId;
        wrap.prorataPremium = 0;//hardcoded
        AcceptQuoteWrapper.BankingDetails bankDetails = new AcceptQuoteWrapper.BankingDetails();
        bankDetails.idCountryOfIssue = (String)productsMetadata.get('Country_of_Issue__c');
        
        
        bankDetails.identityDocumentType = 'SAIDENTITYDOCUMENT';
        bankDetails.title = 'Mr';
        bankDetails.idNumber = (String) membersWrapper.get('IdNumber');
        bankDetails.gender = (String) membersWrapper.get('Gender');
        bankDetails.contactNumber =  (String) paymentDetails.get('WalletNumber');
        bankDetails.dateOfBirth = (String)membersWrapper.get('OS_DateOfBirth');
       // bankDetails.initials = 
        bankDetails.branchCode = (String)productsMetadata.get('MPESA_Branch_Code__c');
        bankDetails.branchName = 'MPESA';
        bankDetails.surname = (String) membersWrapper.get('LastName');
        bankDetails.bankName = 'MPESA';
        bankDetails.name = (String) membersWrapper.get('FirstName')+' '+(String) membersWrapper.get('LastName');
        //bankDetails.accountType = 2;
        if((String) productsMetadata.get('Country__c') == 'KE'){
            bankDetails.accountNumber ='254' + (String) paymentDetails.get('WalletNumber');
        }
        //bankDetails.accountNumber = (String) paymentDetails.get('WalletNumber');
        bankDetails.debitOrderMandateCheck = true;//hardcoded
        bankDetails.validationResponse = '';
        bankDetails.isValidated = true;
        bankDetails.validationOverridden = true;
        bankDetails.bankAccountKey = '';
        wrap.BankingDetails = bankDetails;
        System.debug('wrap == ' + JSON.serializePretty(wrap));
		return JSON.serialize(wrap);

	}*/

}