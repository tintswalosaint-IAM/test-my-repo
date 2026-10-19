/**
 * @description  : Global callable class for OmniScript Remote Action to call Quick Quote API.
 * @author       : Irshad
 */

global with sharing class INS_Quick_Quote_RemoteAction implements Callable {

    // ======================================================
    // MAIN CALLABLE ENTRY — Required for OmniScript
    // ======================================================
	
    global Object call(String actionType, Map<String, Object> args) {

        if (actionType == 'callQuickQuote') {
			Map<String, Object> input = (Map<String, Object>)args.get('input');

            String quoteId = (String) input.get('quoteId');
			system.debug('quoteId=='+quoteId);
			Map<String, Object> output = (Map<String, Object>)args.get('output');

            return callQuickQuote(quoteId,output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    // ======================================================
    // INTERNAL EXECUTION METHOD FOR YOUR QUICK QUOTE API
    // ======================================================
    @AuraEnabled(cacheable=false)
    public static Object callQuickQuote(String quoteId,Map<String, Object> output) {

        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Quote Id is required.');
        }

        // Prepare request wrapper for existing API class
        INS_Get_Quick_Quote.RequestWrapper req = new INS_Get_Quick_Quote.RequestWrapper();
        req.quoteId = quoteId;

        List<INS_Get_Quick_Quote.RequestWrapper> listReq = new List<INS_Get_Quick_Quote.RequestWrapper>{ req };

        // Invoke the existing GetQuote() API method
        List<INS_Quick_Quote_Wrapper.Response> apiResponse =
            INS_Get_Quick_Quote.GetQuote(listReq);

        INS_Quick_Quote_Wrapper.Response rawResponse =
            apiResponse.isEmpty() ? null : apiResponse[0];

			System.debug('rawResponse=='+rawResponse);
			System.debug('rawResponse.totalPremium=='+rawResponse.totalPremium);
		
		Map<String, Object> result = new Map<String, Object>();

		if(rawResponse != null){
			output.put('totalPremium', rawResponse.totalPremium);
			output.put('totalBenefitAmount', rawResponse.totalBenefitAmount);
			output.put('memberId', rawResponse.memberId);
			output.put('quoteNumber', rawResponse.quoteNumber);
			output.put('mainFuneralId', rawResponse.mainFuneralId);
			output.put('accessToken', rawResponse.accessToken);
		}
		System.debug('output=='+output);
		//System.debug('totalPremium=='+result.get('totalPremium'));
        // Return a Remote-Action-friendly wrapper
        return output;
    }


    // ======================================================
    // RESPONSE WRAPPER RETURNED TO OMNISCRIPT
    // ======================================================
    public class INS_Quick_Quote_Response {

        @AuraEnabled public Decimal totalPremium;
        @AuraEnabled public Decimal totalBenefitAmount;
        @AuraEnabled public String quoteNumber;
        @AuraEnabled public String quoteId;
        @AuraEnabled public String memberId;
        @AuraEnabled public String mainFuneralId;
        @AuraEnabled public String accessToken;
        @AuraEnabled public String beneficiariesJson;

        public INS_Quick_Quote_Response(INS_Quick_Quote_Wrapper.Response r) {
            if (r != null) {
                this.totalPremium       = r.totalPremium;
                this.totalBenefitAmount = r.totalBenefitAmount;
                this.quoteNumber        = r.quoteNumber;
                this.quoteId            = r.quoteId;
                this.memberId           = r.memberId;
                this.mainFuneralId      = r.mainFuneralId;
                this.accessToken        = r.accessToken;
                this.beneficiariesJson  = r.beneficiariesJson;
            }
        }
    }
}