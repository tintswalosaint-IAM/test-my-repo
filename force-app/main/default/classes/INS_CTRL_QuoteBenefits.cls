/**
 * @description             : CTRL class for quote Benefits
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : Added Logger
 *                          
 */
global with sharing class INS_CTRL_QuoteBenefits implements Callable{
	private static final String ACTION_WITH_CASHBACK = 'AdditionalBenefitsWithCashback';
    private static final String BENEFIT_ID_BASE = '1';
    private static final String BENEFIT_ID_CASHBACK = '100';
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_QuoteBenefits');
    

	global Object call(String actionType, Map<String, Object> args) {
        if (actionType == ACTION_WITH_CASHBACK) {
            Map<String, Object> input = (Map<String, Object>) args.get('input');            
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return AdditionalBenefitsWithCashback(input, output);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }
    
    /**
	* @AdditionalBenefitsWithoutCashback : When cashback is checked
	* @ return : Object
	**/
	@AuraEnabled(cacheable=false)
	public static Object AdditionalBenefitsWithCashback(Map<String, Object> input, Map<String, Object> output){
		String payloadJson;
        String quoteId = (String) input.get('quoteId');
		String cashbackValue = 'true';
		String verb = 'POST';	 
		String paymentFrequency = 'Monthly';
		String automaticBenefit = '5';

		// Reset the value if input contains PersonaliseQuote node		
		boolean isPersonlisedQuote = false;
		if(input.containsKey('PersonalisedQuote') && input.get('PersonalisedQuote') != ''){
			Map<String, Object> personalisedQuote = (Map<String, Object>) input.get('PersonalisedQuote');
			isPersonlisedQuote = true;
			verb = 'PUT';

			String cashbackBenefit = (String) personalisedQuote.get('CashbackBenefit');
			if(cashbackBenefit == 'No'){
				cashbackValue = 'false';		
			}
    		paymentFrequency = (String) personalisedQuote.get('PaymentFrequency');
			automaticBenefit = (String) personalisedQuote.get('AutomaticBenefit');
		}		

		payloadJson = buildPayloadJson(quoteId, paymentFrequency, cashbackValue, automaticBenefit);		
		
		Integer statusCode = null;
		String response = null;
		
		try {
			INS_API_QuoteBenefits service = new INS_API_QuoteBenefits();
			service.setExceptionOnError(false);
			response = service.putQuoteBenefits(payloadJson, quoteId);
			statusCode = service.getStatusCode();
			
		} catch (Exception e) {
			// Return error response
			if (output != null) {
				output.put('hasError', true);
				output.put('populatePremiumsError', 'API call failed: ' + e.getMessage());
			}
			LOGGER.error(e.getMessage(),new String[]{'AdditionalBenefitsWithCashback',e.getMessage()},e);
			return output;
		}

        // Process response - handle null/empty response
        if (String.isBlank(response)) {
            // Handle empty response
            if (output != null) {
                output.put('hasError', false);
                if (!isPersonlisedQuote) {
                    populatePremiums(null, output);
                }
            }
            return output;
        }

        // Process the response
        try {
            Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(response);            
            // Check if statusCode is null (shouldn't happen, but handle it)
            if (statusCode == null) {
                output.put('hasError', true);
                output.put('populatePremiumsError', 'No status code received');
                return output;
            }
            
            if (statusCode == 201 || statusCode == 200) {
                if (!isPersonlisedQuote) {
                    populatePremiums(response, output);
                } else {
                    responseFromPutCall(response, output);
                }
            } else {
                output.put('hasError', true);
                if (jsonResponseMap != null && jsonResponseMap.containsKey('error')) {
                    Map<String, Object> errorObjMap = (Map<String, Object>) jsonResponseMap.get('error');
                    String errorDescription = (String) errorObjMap.get('errorDescription');
                    output.put('populatePremiumsError', errorDescription != null ? errorDescription : 'Unknown error');
                } else {
                    output.put('populatePremiumsError', 'API returned error status: ' + statusCode);
                }
            }
        } catch (System.JSONException e) {
            
			LOGGER.error(e.getMessage(),new String[]{'additionalBenefitsWithCashback',e.getMessage()},e);
            if (output != null) {
                output.put('hasError', true);
                output.put('populatePremiumsError', 'Error parsing response: ' + e.getMessage());
            }
            // Re-throw in test context to help with debugging
            if (Test.isRunningTest()) {
                throw e;
            }
        }

		return output;
	}
    
    /**
	* @ populatePremiums : When cashback is false
	* @ return : Object
	**/
	private static void populatePremiums(String jsonResponse, Map<String, Object> output) {
    	if (String.isBlank(jsonResponse) || output == null) {
       	 return;
    	}

    	try {
        	Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);        	
    		output.put('hasError', false);
    		output.put('monthlyPremium', responseMap.get('monthlyPremium') != null ? (Decimal) responseMap.get('monthlyPremium') : null);
    		output.put('monthlyCashbackPremium', responseMap.get('monthlyCashbackPremium') != null ? (Decimal) responseMap.get('monthlyCashbackPremium') : null);
    		output.put('monthlyCashbackBenefitPremium', responseMap.get('monthlyCashbackBenefitPremium') != null ? (Decimal) responseMap.get('monthlyCashbackBenefitPremium') : null);
    		output.put('annualPremium', responseMap.get('annualPremium') != null ? (Decimal) responseMap.get('annualPremium') : null);
    		output.put('annualCashbackPremium', responseMap.get('annualCashbackPremium') != null ? (Decimal) responseMap.get('annualCashbackPremium') : null);
    		output.put('annualCashbackBenefitPremium', responseMap.get('annualCashbackBenefitPremium') != null ? (Decimal) responseMap.get('annualCashbackBenefitPremium') : null);
    	} catch (Exception e) {
    		LOGGER.error(e.getMessage(),new String[]{'populatePremiums',e.getMessage()},e);
    		if (output != null) {
    			output.put('hasError', true);
    			output.put('populatePremiumsError', 'Error parsing premiums: ' + e.getMessage());
    		}
    		if (Test.isRunningTest()) {
    			throw e;
    		}
    	}
    }
    
    /**
	* Process Response for put call
	**/
	private static void responseFromPutCall(String jsonResponse, Map<String, Object> output){
		if (String.isBlank(jsonResponse) || output == null) {
       	 return;
    	}

    	try {
        	Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
    		if (responseMap.containsKey('result')) {
    			output.put('result', responseMap.get('result'));	
    		}
    	} catch (Exception e) {
			LOGGER.error(e.getMessage(),new String[]{'responseFromPutCall',e.getMessage()},e);
    		if (output != null) {
    			output.put('hasError', true);
    			output.put('populatePremiumsError', 'Error parsing PUT response: ' + e.getMessage());
    		}
    		if (Test.isRunningTest()) {
    			throw e;
    		}
    	}
	}

	private static Decimal getBenefitPremium(List<Object> benefits, String benefitId) {
        if (benefits == null || String.isBlank(benefitId)) {
            return null;
        }

        for (Object obj : benefits) {
            Map<String, Object> benefit = (Map<String, Object>) obj;

            if (String.valueOf(benefit.get('benefitId')) == benefitId &&
                benefit.get('premium') != null) {
                return ((Decimal) benefit.get('premium')).setScale(2, RoundingMode.HALF_UP);
            }
        }

        return null;
    }

	private static String buildPayloadJson(String quoteId, String paymentFrequency, String cashbackValue, String annualBenefitValue) {
    	List<additionalBenefitsWrapper> additionalBenefitsWrapperList = new List<additionalBenefitsWrapper>();

		additionalBenefitsWrapper annualBenefit = new additionalBenefitsWrapper();
		annualBenefit.benefitType = 'AnnualBenefitIncrease';
		annualBenefit.benefitValue = annualBenefitValue;
		additionalBenefitsWrapperList.add(annualBenefit);

		additionalBenefitsWrapper cashBack = new additionalBenefitsWrapper();
		cashBack.benefitType = 'CashBackOption';
		cashBack.benefitValue = cashbackValue;
		additionalBenefitsWrapperList.add(cashBack);

		requestWrapper reqWrpClass = new requestWrapper();
		reqWrpClass.QuoteNumber = quoteId;
		reqWrpClass.paymentFrequency = paymentFrequency;
		reqWrpClass.additionalBenefits = additionalBenefitsWrapperList;

		return JSON.serialize(reqWrpClass);
	}

	private class requestWrapper {
		private String QuoteNumber;
		private String paymentFrequency;
		private List<additionalBenefitsWrapper> additionalBenefits;
	}

	private class additionalBenefitsWrapper {
		private String benefitType;
		private String benefitValue;
	}
}