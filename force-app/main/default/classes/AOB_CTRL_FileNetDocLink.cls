/**
 * This class is used as a controller to the sign modal of the credit card final offer
 * 
 * <p>DBP-1874</p>
 * 
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 * 
 * @date Jan 11th 2021
 */
public class AOB_CTRL_FileNetDocLink {
	
    /**
    * @description Calls the get Document API 
    * @return 	a blob containing the document
    */
    @AuraEnabled
    public static DOC_API_GetDocument.DTO_Response callGetDocument(String token,String documentId){
        try{
        	DOC_API_GetDocument customerServiceCall = new DOC_API_GetDocument(token,documentId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(DOC_API_GetDocument.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            DOC_API_GetDocument.DTO_Response result=(DOC_API_GetDocument.DTO_Response)customerServiceCall.baseResponseDTO;
            return result;
           
		}
        catch(Exception error)
		{
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_signModal.callGetDocument');
			throw new AuraHandledException(error.getMessage());
		}
	}
    /**
    * @description Calls the get token API 
    * @return 	a string containing the token
    */
    @AuraEnabled
    public static String callGetToken(){
        try{
        	return AOB_SRV_OpenApplications.callGetToken();
		}
        catch(Exception error)
		{
			CMN_UTIL_Logger.error(error, 'AOB_CTRL_signModal.callGetToken');
			throw new AuraHandledException(error.getMessage());
		}
	}
    
}