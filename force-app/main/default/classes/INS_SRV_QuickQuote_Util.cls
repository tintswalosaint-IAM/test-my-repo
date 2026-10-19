/***************************************************************************************
@Name of the Class :INS_SRV_QuickQuote_Util
@Description :SFP-51843:Created
@Author :Irshad 
@Created Date :12/02/2026
***************************************************************************************/

public with sharing class INS_SRV_QuickQuote_Util {

	@AuraEnabled(cacheable=true)
	public static void processSuccessResponse(Map<String, Object> jsonResponseMap, Map<String, Object> output){
        Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');
        try{
            if (validation != null) {
                String resultStatus = (String) validation.get('ResultStatus');
                System.debug('Validation Message==' + validation.get('Message'));
                if ('Failed'.equalsIgnoreCase(resultStatus)) {
                    output.put('hasError', 'true');
                    output.put('ErrorResponse', validation.get('Message'));
                } else if ('Success'.equalsIgnoreCase(resultStatus)) {
                    List<Object> benefits = (List<Object>) jsonResponseMap.get('members');
                    output.put('hasError', 'false');
                    output.put('SuccessResponse', benefits);
                }
            }else{
                output.put('hasError', 'true');
                String errorDescription = (String) jsonResponseMap.get('errorDescription');
                output.put('ErrorResponse', errorDescription);  
            }
        }catch(Exception ex){

        }
        

    }

}