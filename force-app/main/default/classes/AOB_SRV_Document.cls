/**
 * This class is used as a service class for all operations related with Open Application
 *
 * <p>DBP-1874</p>
 *
 * @author Maryem Bourhi (mbourhi@salesforce.com)
 *
 * @date Jan 11th 2021
 */
public class AOB_SRV_Document {
    public static final String SERVICE_NAME = AOB_SRV_Document.class.getName();

    /**
     * @description Calls the get Document API
     * @return 	a blob containing the document
     */
    public static Blob callGetDocument(String contractId) {
        AOB_API_GetDocument customerServiceCall = new AOB_API_GetDocument(contractId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetDocument.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        Blob responseBody = customerServiceCall.getResponseBlobBody();
        return responseBody;
    }
}