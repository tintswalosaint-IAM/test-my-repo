/**
 * @description Class for API call personal details indentification section
 *
 * <p></p>
 *
 * @author Maryem BOURHI(mbourhi @salesforce.com)
 *
 * @date Nov 27th 2020
 */
public with sharing class AOB_SRV_WFR {
  private static final String IDV_ACTION_CANCEL = 'CANCEL';
  private static final String IDV_ACTION_UPDATE = 'UPDATE';
  private static final String IDV_DESC_UPDEFAULT = 'Updating the IDV Session';
  private static final String IDV_DESC_CADEFAULT = 'Cancelling the IDV Session to start a new one';
  /**
   * @description Calls the AOB_API_WFRGetIdentifiiToken API
   * @return 	a string containing the token for the WFR
   */
    public static string callgetIdentifiiToken( String idNumber, String correlationId ) {
        AOB_API_WFRGetIdentifiiToken customerServiceCall = new AOB_API_WFRGetIdentifiiToken( idNumber, correlationId);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_WFRGetIdentifiiToken.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_WFRGetIdentifiiToken.DTO_Response result = (AOB_API_WFRGetIdentifiiToken.DTO_Response) customerServiceCall.baseResponseDTO;
        return result.response;
    }
    
    /**
   * @description Calls the AOB_API_WFRGetIdentifiiToken API
   * @param idNumber
   * @param correlationId
   * @param applicationId
   * @return 	a string containing the token for the WFR
   */
    public static String callOrchestrateIDV( String idNumber, String correlationId, String applicationId) {
    //AOB_API_OrchestrateIDV customerServiceCall = new AOB_API_OrchestrateIDV();
    //system.debug('AOB_SRV_WFR applicationId'+applicationId);
    AOB_API_OrchestrateIDV customerServiceCall = new AOB_API_OrchestrateIDV(idNumber, correlationId, applicationId);
    CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_OrchestrateIDV.SERVICE_NAME);
    customerServiceCall.process(obj);
    insert obj;
    AOB_API_OrchestrateIDV.DTO_Response result = (AOB_API_OrchestrateIDV.DTO_Response) customerServiceCall.baseResponseDTO;
    //check on the response code if its 409 allow for retry // use response.getStatusCode()
    Integer status = customerServiceCall.getResponseStatusCode();
    if(status != null && status == 409){
        return 'Error409';
    }else{
        return result.contextId;
        }
    }
    
    /**
    * @description Calls the AOB_API_StartIDV API
    * @param idNumber
    * @param applicationId
    * @return 	the response of the API
    */
    public static AOB_API_StartIDV.DTO_Response callStartIDV(
        String idNumber,
        String applicationId
    ) {
        AOB_API_StartIDV customerServiceCall = new AOB_API_StartIDV(
            idNumber,
            applicationId
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_StartIDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_StartIDV.DTO_Response result = (AOB_API_StartIDV.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

    /**
    * @description Calls the AOB_API_NotifyIDV API
    * @param correlationId
    * @return 	the response of the API
    */
    public static AOB_API_notifyIDV.DTO_Response callNotifyIDV(
        string correlationId
    ) {
        AOB_API_notifyIDV customerServiceCall = new AOB_API_notifyIDV(
            correlationId,
            IDV_ACTION_UPDATE,
            IDV_DESC_UPDEFAULT
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_notifyIDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_notifyIDV.DTO_Response result = (AOB_API_notifyIDV.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

  /**
   * @description Calls the AOB_API_NotifyIDV API
   * @param correlationId
   * @return 	the response of the API
   */
    public static AOB_API_notifyIDV.DTO_Response cancelIDV(string correlationId) {
        AOB_API_notifyIDV customerServiceCall = new AOB_API_notifyIDV(
            correlationId,
            IDV_ACTION_CANCEL,
            IDV_DESC_UPDEFAULT
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_notifyIDV.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        AOB_API_notifyIDV.DTO_Response result = (AOB_API_notifyIDV.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }

    /**
    * @description Calls the AOB_API_GetIDV API
    * @param idNumber
    * @return 	the response of the API
    */
    public static AOB_API_GetIDVStatus.DTO_Response callGetIDV(String idNumber) {
        AOB_API_GetIDVStatus customerServiceCall = new AOB_API_GetIDVStatus(
            idNumber
        );
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetIDVStatus.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        //system.debug('*** callGetIDV customerServiceCall.baseResponseDTO : ' + customerServiceCall.baseResponseDTO);
        AOB_API_GetIDVStatus.DTO_Response result = (AOB_API_GetIDVStatus.DTO_Response) customerServiceCall.baseResponseDTO;
        return result;
    }
}