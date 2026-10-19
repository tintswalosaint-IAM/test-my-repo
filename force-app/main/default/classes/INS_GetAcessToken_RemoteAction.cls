global with sharing class INS_GetAcessToken_RemoteAction implements callable {
    
    
    global Object call(String actionType, Map<String, Object> args) {
       	
        if (actionType == 'getToken') {
        	Map<String, Object> input = (Map<String, Object>)args.get('input');
			Map<String, Object> output = (Map<String, Object>)args.get('output');             
            return getStandard_Bank_OAuth(output);
            
        }
        throw new AuraHandledException('Unsupported action: ' + actionType);
    }
    
    
    @AuraEnabled(cacheable=false)
    public static Object getStandard_Bank_OAuth(Map<String, Object> output) {
        
		String accessToekn = INS_Quote_Helper.getAccessToken('Quote');	        
        output.put('access_token', accessToekn);
        return output;
        
        
    }

}