/**
* @description  : INS_Quick_Quote_Get_API_RemoteAction.cls to get the latest quote data fro Mobi
* @SFP-50909    : The class has been created to connect to Mobi to get the quote data by passing quoteId
* @author       : Irshad Alam (irshad.alam@standardbank.co.za)
* @date         : March 2026
*/

global with sharing class INS_Quick_Quote_Get_API_RemoteAction implements Callable {
	global Object call(String actionType, Map<String, Object> args) {
        if (actionType == 'getQuickQuote') {
			Map<String, Object> input = (Map<String, Object>)args.get('input');
            String quoteId = (String) input.get('quoteId');			
			Map<String, Object> output = (Map<String, Object>)args.get('output');
            return getQuickQuote(quoteId,output);
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

	@AuraEnabled(cacheable=false)
    public static Object getQuickQuote(String quoteId,Map<String, Object> output) {
		if (String.isBlank(quoteId)) {
            throw new AuraHandledException('Quote Id is required.');
        }

		INS_SRV_Get_QuickQuote GetQuickQuoteService = new INS_SRV_Get_QuickQuote(quoteId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_SRV_Get_QuickQuote.SERVICE_NAME);
        GetQuickQuoteService.process(obj);
        insert obj;

		Map<String,Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(GetQuickQuoteService.getResponseBody());		
        Integer statusCode = GetQuickQuoteService.getResponseStatusCode();
		if (statusCode == 201 || statusCode == 200) {
            INS_SRV_QuickQuote_Util.processSuccessResponse(jsonResponseMap, output);            
        }else {
            output.put('hasError', 'true');
			map<String,Object> errorMap = (Map<String,Object>)jsonResponseMap.get('error');
            String errorDescription = (String) errormap.get('errorDescription');
            output.put('ErrorResponse', errorDescription);
        }
		return output;
	}


}