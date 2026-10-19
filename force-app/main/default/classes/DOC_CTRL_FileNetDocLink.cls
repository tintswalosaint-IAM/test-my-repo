/**
* This class is used as a controller to the sign modal of the credit card final offer
*
* <p>DBP-1874</p>
*
* @author Maryem Bourhi (mbourhi@salesforce.com)
*
* @date Jan 11th 2021
*/
public class DOC_CTRL_FileNetDocLink {
    /**
* @description Calls the get Document API
* @return 	a blob containing the document
*/
    @AuraEnabled
    public static String callGetDocument(String token, String contractId) {
        try {
            DOC_API_GetDocument customerServiceCall = new DOC_API_GetDocument(
                token,
                contractId
            );
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(DOC_API_GetDocument.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            DOC_API_GetDocument.DTO_Response result = (DOC_API_GetDocument.DTO_Response) customerServiceCall.baseResponseDTO;
            return result.response == null
                ? ''
                : EncodingUtil.base64Encode(result.response);
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, 'DOC_CTRL_FileNetDocLink.callGetDocument');
            throw new AuraHandledException(error.getMessage());
        }
    }
}