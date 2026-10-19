global with sharing class INS_SRV_ProductsRules_RemoteAction implements callable {
    
    global Object call(String actionType, Map<String, Object> args) {

        if (actionType == 'callProductsRulesAPI') {
			Map<String, Object> input = (Map<String, Object>)args.get('input');                       	
			Map<String, Object> output = (Map<String, Object>)args.get('output');
            return callProductsRulesAPI(input,output);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    @AuraEnabled(cacheable=false)
    public static Object callProductsRulesAPI(Map<String, Object> input, Map<String, Object> output) {       
        String ProductCode = (String) input.get('Product_Code__c');
        if (String.isBlank(ProductCode)) {
            ProductCode = '8'; // Default to product code 8 if not provided in input
        }        

        INS_SRV_ProductsRules productsRulesService = new INS_SRV_ProductsRules(ProductCode);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_SRV_ProductsRules.SERVICE_NAME);
        productsRulesService.process(obj);
        insert obj;
        Integer statusCode = productsRulesService.getResponseStatusCode();
        String responseBody = productsRulesService.getResponseBody();
        //Map<String,Object> productbenefitRules = new  Map<String,Object>();
        Map<String, Object> responseMap =
					(Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> productbenefitRules =
					(List<Object>) responseMap.get('ProductBenefitRules');

        List<Map<String, Object>> allSumAssuredLimits = new List<Map<String, Object>>();

        for (Object objct : productbenefitRules) {
            // 1. Cast the generic Object to a Map
            
            Map<String, Object> rule = (Map<String, Object>) objct;
            // 2. Extract the SumAssuredLimits list from the map
            if (rule.containsKey('SumAssuredLimits') && rule.get('SumAssuredLimits') != null) {
                List<Object> limits = (List<Object>)rule.get('SumAssuredLimits');
                
                // 3. Add each limit to our final list
                for (Object limitObj : limits) {
                    allSumAssuredLimits.add((Map<String, Object>)limitObj);
                }
            }
        }
        System.debug('statusCode==' + statusCode);
        System.debug('responseBody==' + responseMap);
        System.debug('productbenefitRules==' + JSON.serialize(productbenefitRules));
        output.put('statusCode', statusCode);
        output.put('productRulesResponse', allSumAssuredLimits);
        
        return output;
    }
}