/***************************************************************************************
@Name of the Class :INS_SRV_CallAddBenefits_RemoteAction
@Description :SFP-55750:Created
@Author :Irshad 
@Created Date :10/03/2026
***************************************************************************************/

global with sharing class INS_SRV_CallAddBenefits_RemoteAction implements Callable{
	private static final String ACTION_WITH_CASHBACK = 'AdditionalBenefitsWithCashback';
    private static final String BENEFIT_ID_BASE = '1';
    private static final String BENEFIT_ID_CASHBACK = '100';

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
	public static Object AdditionalBenefitsWithCashback(Map<String, Object> input,Map<String, Object> output){
		String payloadJson;
        String quoteId = (String) input.get('quoteId');
		String cashbackValue = 'true';
		String verb = 'POST';	 
		String paymentFrequency = 'Monthly';
		String automaticBenefit = '5';

		// Reset the value if input contains PersonaliseQuote node		
		
		boolean isPersonlisedQuote = false;
		if(input.containsKey('PersonalisedQuote') && input.get('PersonalisedQuote') != ''){
			Map<String, Object> personalisedQuote =
        		(Map<String, Object>) input.get('PersonalisedQuote');
			isPersonlisedQuote = true;
			verb = 'PUT';

			String cashbackBenefit = (String) personalisedQuote.get('CashbackBenefit');
			if(cashbackBenefit == 'No'){
				cashbackValue = 'false';		
			}
    		paymentFrequency = (String) personalisedQuote.get('PaymentFrequency');
			automaticBenefit = (String) personalisedQuote.get('AutomaticBenefit');
			

		}		

		payloadJson = buildPayloadJson(quoteId,paymentFrequency,cashbackValue,automaticBenefit);
		System.debug('payloadJson=='+payloadJson);
		INS_SRV_QuickQuote_AdditionalBenefits addBenefitsService = new INS_SRV_QuickQuote_AdditionalBenefits(payloadJson, quoteId,verb);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_AdditionalBenefits.SERVICE_NAME
        );
        addBenefitsService.process(obj);
        insert obj;

        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            addBenefitsService.getResponseBody()
        );
		Integer statusCode = addBenefitsService.getResponseStatusCode();

        if (statusCode == 201 || statusCode == 200) {
            if(!isPersonlisedQuote){
				populatePremiums(addBenefitsService.getResponseBody(), output);
			}else{
				//populate result
				responseFromPutCall(addBenefitsService.getResponseBody(), output);
			}
        } else {
            output.put('hasError', true);
			Map<String,Object> errorObjMap = (Map<String, Object>) jsonResponseMap.get('error');
            String errorDescription = (String) errorObjMap.get('errorDescription');
            output.put('populatePremiumsError', errorDescription);
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

    	Map<String, Object> responseMap =
        	(Map<String, Object>) JSON.deserializeUntyped(jsonResponse);	

		String statusRes = (String)responseMap.get('status');		
		output.put('hasError', false);
		output.put('monthlyPremium',(Decimal)responseMap.get('monthlyPremium'));
		output.put('monthlyCashbackPremium',(Decimal)responseMap.get('monthlyCashbackPremium'));
		output.put('monthlyCashbackBenefitPremium',(Decimal)responseMap.get('monthlyCashbackBenefitPremium'));
		output.put('annualPremium',(Decimal)responseMap.get('annualPremium'));
		output.put('annualCashbackPremium',(Decimal)responseMap.get('annualCashbackPremium'));
		output.put('annualCashbackBenefitPremium',(Decimal)responseMap.get('annualCashbackBenefitPremium'));
		
		//output.put('benefitResponse', responseMap);
		// -----------------------
		// MONTHLY PREMIUM SECTION
		// -----------------------
		/*
		if (responseMap.containsKey('monthly')) {

			Map<String, Object> monthly =
				(Map<String, Object>) responseMap.get('monthly');

			if(monthly != null && monthly.containsKey('result')){
				String monthlyResult = (String) monthly.get('result');
				output.put('result',monthlyResult);
			}

			if (monthly != null && monthly.containsKey('totalPremiumMonthly')) {

				
				Decimal totalPremiumMonthly =
					(Decimal) monthly.get('totalPremiumMonthly');

				output.put(
					'totalPremiumMonthly',
					totalPremiumMonthly.setScale(2, RoundingMode.HALF_UP)
				);
			}

			if (monthly != null && monthly.containsKey('benefitArray')) {

				List<Object> benefits =
					(List<Object>) monthly.get('benefitArray');

				Decimal cashbackPremium =
					getBenefitPremium(benefits, BENEFIT_ID_CASHBACK);

				if (cashbackPremium != null) {
					output.put('cashbackPremium', cashbackPremium);
				}

				Decimal monthlyPremium =
					getBenefitPremium(benefits, BENEFIT_ID_BASE);

				if (monthlyPremium != null) {
					output.put('monthlyPremium', monthlyPremium);
				}
			}
		}*/

		// -----------------------
		// ANNUAL PREMIUM SECTION
		// -----------------------
		/*
    	if (responseMap.containsKey('annual')) {

			Map<String, Object> annual =
				(Map<String, Object>) responseMap.get('annual');

			if (annual != null && annual.containsKey('totalPremiumAnnual')) {

				Decimal totalPremiumAnnual =
					(Decimal) annual.get('totalPremiumAnnual');

				output.put(
					'totalPremiumAnnual',
					totalPremiumAnnual.setScale(2, RoundingMode.HALF_UP)
				);
			}

        	if (annual != null && annual.containsKey('benefitArray')) {

				List<Object> benefits =
					(List<Object>) annual.get('benefitArray');
				Decimal annualPremium =
                getBenefitPremium(benefits, BENEFIT_ID_BASE);
				if (annualPremium != null) {
					output.put('annualPremium', annualPremium);
				}


				Decimal cashbackAnnualPremium =
					getBenefitPremium(benefits, BENEFIT_ID_CASHBACK);

				if (cashbackAnnualPremium != null) {
					output.put('cashbackAnnualPremium', cashbackAnnualPremium);
				}
        	}
    	}
		*/
	}

	/**
	* Process Response for put call
	*
	**/

	private static void responseFromPutCall(String jsonResponse, Map<String, Object> output){
		if (String.isBlank(jsonResponse) || output == null) {
       	 return;
    	}

    	Map<String, Object> responseMap =
        	(Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
		if(responseMap.containsKey('result')){
			output.put('result',responseMap.get('result'));	
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

	private static String buildPayloadJson(String quoteId, String paymentFrequency, String cashbackValue,String annualBenefitValue) {
    	List<additionalBenefitsWrapper> additionalBenefitsWrapperList =
        new List<additionalBenefitsWrapper>();

		additionalBenefitsWrapper annualBenefit = new additionalBenefitsWrapper();
		annualBenefit.benefitType = 'AnnualBenefitIncrease';
		annualBenefit.benefitValue = annualBenefitValue;
		additionalBenefitsWrapperList.add(annualBenefit);

		additionalBenefitsWrapper cashBack = new additionalBenefitsWrapper();
		cashBack.benefitType = 'CashBackOption';
		cashBack.benefitValue = cashbackValue;//'true';
		additionalBenefitsWrapperList.add(cashBack);

		requestWrapper reqWrpClass = new requestWrapper();
		reqWrpClass.QuoteNumber = quoteId;
		reqWrpClass.paymentFrequency = paymentFrequency;
		reqWrpClass.additionalBenefits = additionalBenefitsWrapperList;

		return JSON.serialize(reqWrpClass);
	}

	private class requestWrapper{
		private String QuoteNumber;
		private String paymentFrequency;
		private List<additionalBenefitsWrapper> additionalBenefits;


	}

	private class additionalBenefitsWrapper{
		Private String benefitType;
		Private String benefitValue;
	}

}