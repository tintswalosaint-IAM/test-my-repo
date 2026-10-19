/**
 * @description             : CTRL class for quote Acceptance
 * @story                   : SFP-55651
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 *                          
 */

public with sharing class INS_CTRL_QuoteAcceptance implements callable{

	private static final String QUOTE_ACCEPTANCE = 'QuoteAcceptance';  
	private static final String QUOTE_ACCEPTANCE_RESPONSE = 'quoteAcceptResponse'; 

	public Object call(String actionType, Map<String, Object> args) {
        if (actionType == QUOTE_ACCEPTANCE) {
            Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return quoteAcceptanceAPI(input, output);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

	@AuraEnabled(cacheable=false)
	public static Object quoteAcceptanceAPI(Map<String, Object> input,Map<String, Object> output){
		Map<String,Object> quoteAcceptance = new Map<String,Object>();
		try{
			String quoteId = (String) input.get('quoteId');
			String payloadJson = generateRequestPayload(quoteId,input);
			Integer statusCode = null;
			String response = null;
			INS_API_QuoteAcceptance quickQuoteAcceptanceService = new INS_API_QuoteAcceptance();
			quickQuoteAcceptanceService.setExceptionOnError(false); 							
			response = quickQuoteAcceptanceService.quoteAcceptance(payloadJson, quoteId);
			statusCode = quickQuoteAcceptanceService.getStatusCode();		
			if (String.isBlank(response)) {
				throw new AuraHandledException('Quote Acceptance API returned empty response. StatusCode=' + statusCode);
			}			

			Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response);		
			
			if (statusCode == 201 || statusCode == 200) {
				
				Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');
				if (validation != null && 'Success'.equalsIgnoreCase((String) validation.get('ResultStatus'))) {
					quoteAcceptance.put('ResultStatus', 'Success');
					quoteAcceptance.put('hasError', 'false'); 
	
					output.put(QUOTE_ACCEPTANCE_RESPONSE,quoteAcceptance);
				}
				
			} else {
				quoteAcceptance.put('hasError', 'true');
				Map<String, Object> errorMap = (Map<String, Object>) jsonResponseMap.get('error');
				String errorDescription = response;
				if(errorMap != null){
					errorDescription = (String) errorMap.get('errorDescription');			}
				
				quoteAcceptance.put(QUOTE_ACCEPTANCE_RESPONSE, errorDescription);
				output.put(QUOTE_ACCEPTANCE_RESPONSE, quoteAcceptance);
				
			}
		}Catch(Exception ex){
			quoteAcceptance.put('hasError', true);
			quoteAcceptance.put(QUOTE_ACCEPTANCE_RESPONSE,ex.getMessage());
			throw new AuraHandledException('Quote acceptance failed ' + ex.getMessage());
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
		bankingDetails.put('name',membersWrapper.get('FirstName') + ' ' + membersWrapper.get('LastName'));
		bankingDetails.put('accountType', 'Savings');
		bankingDetails.put('accountNumber', walletNumber); 

		bankingDetails.put('debitOrderMandateCheck', true);
		bankingDetails.put('validationResponse', '');
		bankingDetails.put('isValidated', true);
		bankingDetails.put('validationOverridden', true);
		bankingDetails.put('bankAccountKey', '');

		Map<String, Object> payload = new Map<String, Object>();

		payload.put('CoverEffectiveDate',  System.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));// String.valueOf(System.now())
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

}