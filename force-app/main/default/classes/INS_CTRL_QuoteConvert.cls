/**
 * @description             : CTRL class for quote Conversion
 * @story                   : SFP-56577
 * @author                  : Irshad
 * @created date            : 24-08-2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 *                          
 */

public with sharing class INS_CTRL_QuoteConvert implements callable{

	private static final String QUOTE_CONVERSION = 'QuoteConversion';
	private static final String QUOTE_CONVERSION_RESPONSE = 'quoteConversionResponse';
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_QuoteConvert');
	public Object call(String actionType, Map<String, Object> args) {
        if (actionType == QUOTE_CONVERSION) {
            Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return quoteConversionAPI(input, output);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }	


	@AuraEnabled(cacheable=false)
	public static Object quoteConversionAPI(Map<String, Object> input, Map<String, Object> output) {

		Map<String, Object> quoteConvert = new Map<String, Object>();

		try {
			String quoteId = (String) input.get('quoteId');
			if (String.isBlank(quoteId)) {
				throw new AuraHandledException('Quote Id is required.');
			}
            // validate quote against the actual quote
            String accountId = (String) input.get('ProspectAccountId');			
			if (String.isBlank(accountId)) {
				throw new AuraHandledException('Unauthorised request.');
			}
			
			List<Quote> quoteList =
				new SEL_Quote().guestUserQuoteInProgressByAccIds(new List<Id>{ accountId });

			Boolean matched = false;
			for (Quote q : quoteList) {
				if (quoteId == q.UnderwriterQuoteReferenceNumber__c) {
					matched = true;
					break;
				}
			}
			if (!matched) {
				throw new AuraHandledException('Unauthorised request.');
			}
			

			String payloadJson = generateRequestPayload(quoteId, input);

			INS_API_QuoteConvert quickQuoteConvert = new INS_API_QuoteConvert();
			quickQuoteConvert.setExceptionOnError(false);
			String response    = quickQuoteConvert.quoteConversion(payloadJson, quoteId);
			Integer statusCode = quickQuoteConvert.getStatusCode();

			if (String.isBlank(response)) {
				return errorResponse(output, quoteConvert,
					'Quote Convert API returned empty response. StatusCode=' + statusCode);
			}

			Map<String, Object> jsonResponseMap;
			try {
				jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
			} catch (Exception parseEx) {
				LOGGER.error(parseEx.getMessage(),new String[]{'quoteConversionAPI',parseEx.getMessage()},parseEx);
				return errorResponse(output, quoteConvert,
					'Failed to parse Quote Convert response: ' + parseEx.getMessage());
			}

			if (statusCode != 200 && statusCode != 201) {
				return errorResponse(output, quoteConvert,
					extractErrorDescription(jsonResponseMap, statusCode));
			}

			Object policyPayloadObj = jsonResponseMap.get('policyPayload');            
            if (!(policyPayloadObj instanceof Map<String, Object>)) {
				return errorResponse(output, quoteConvert,
					'Quote Convert API did not return policy details.');
			}
			Map<String, Object> policyPayload =
				(Map<String, Object>) jsonResponseMap.get('policyPayload');
            
			Object policyNumberObj = policyPayload.get('policyNumber');
            String policyNumber = policyNumberObj == null ? null : String.valueOf(policyNumberObj);
			
			if (String.isBlank(policyNumber)) {
				return errorResponse(output, quoteConvert,
					'Quote Convert API did not return a policy number.');
			}

			quoteConvert.put('ResultStatus', 'Success');
			quoteConvert.put('hasError', false);
			quoteConvert.put('policyNumber', policyNumber);
			quoteConvert.put('status', policyPayload.get('status'));
			quoteConvert.put('policyPayload', policyPayload);
			output.put(QUOTE_CONVERSION_RESPONSE, quoteConvert);
			return quoteConvert;

		} catch (Exception ex) {

			LOGGER.error(ex.getMessage(),new String[]{'quoteConversionAPI',ex.getMessage()},ex);

			return errorResponse(
				output,
				quoteConvert,
				'Quote conversion failed: ' + ex.getMessage()
			);
			
		}
	}

	/**
	 * @description Populates the response map with an error and writes it to the
	 *              output, so the OmniScript always receives a response node.
	 */
	private static Map<String, Object> errorResponse(
		Map<String, Object> output, Map<String, Object> quoteConvert, String message
	) {
		quoteConvert.put('hasError', true);
		quoteConvert.put('errorMessage', message);
		output.put(QUOTE_CONVERSION_RESPONSE, quoteConvert);
		return quoteConvert;
	}

	/**
	 * @description Extracts an error description from the API response, falling
	 *              back to the status code when no structured error is present.
	 */
	private static String extractErrorDescription(
		Map<String, Object> jsonResponseMap, Integer statusCode
	) {
		Object errorObj = jsonResponseMap.get('error');
		if (errorObj instanceof Map<String, Object>) {
			Map<String, Object> errorMap = (Map<String, Object>) errorObj;
			Object description = errorMap.get('errorDescription');
			if (description != null) {
				return String.valueOf(description);
			}
		}
		return 'API returned status: ' + statusCode;
	}


	public static String generateRequestPayload(String quoteId, Map<String, Object> input) {
		String otpNumber = '123456';// default value
		date dt = system.today();
		String otpDate = String.valueof(dt);
		Map<String, Object> payload = new Map<String, Object>();
		convertQuoteRequestWrp payloadWrp = new convertQuoteRequestWrp();
		payloadWrp.referenceNumber = quoteId;
		payloadWrp.quoteNumber = quoteId;
		payloadWrp.consultantCode = '12345';
		payloadWrp.promoCode = 'test';
		payloadWrp.campaignCode = 'test';
		payloadWrp.otpNumber = otpNumber;
		payloadWrp.otpDate = otpDate;


		return JSON.serialize(payloadWrp);

	}


	public class convertQuoteRequestWrp{
		public String referenceNumber; // external quoteId
		public String quoteNumber;// external quoteId
		public String consultantCode;//"Bank Code"
		public String promoCode; // Random value BYDS673
		public String campaignCode;// random value CODECAMP12
		public String otpNumber; // cvc number
		public String otpDate; // cvc otp date
  
	}

}