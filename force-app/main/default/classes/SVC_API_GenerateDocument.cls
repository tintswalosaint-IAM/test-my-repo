/**
 * @description       : Class for actual API call for template generation
 * User Story		  : SFP-31300
 * @author            : Aliaksei Koval
 * @last modified on  : 09-05-2025
 * @last modified by  : Aliaksei Koval
**/
public with sharing class SVC_API_GenerateDocument extends sbgplatform.ApiGatewayService{

    private static final String SVC_API_TEMPLATE = 'SVC_API_TEMPLATE';
    private static final String NAMED_CREDENTIALS = 'CHNW_PPB_SAS_ComplaintsManagementN';

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_API_GenerateDocument');
    
    private SVC_API_GenerateDocument() {
        super(NAMED_CREDENTIALS);
    }
    
    /**
    * @description 
    * @param body 
    * @return SVC_DTO_TemplateServiceRestResponse
    **/
    public static SVC_DTO_TemplateServiceRestResponse getComplaintsRejectionLetter(SVC_DTO_TemplateServiceRestRequest body) {
        SVC_API_GenerateDocument service = new SVC_API_GenerateDocument();

        try {
            CMN_WebserviceSetting__mdt webServiceSetting = CMN_DAL_WebserviceSetting.getMetadata(SVC_API_TEMPLATE);
            String response = (String)service.post(webServiceSetting.CMN_Path__c, JSON.serialize(body));
            return (SVC_DTO_TemplateServiceRestResponse)JSON.deserialize(response, SVC_DTO_TemplateServiceRestResponse.class);
        } catch(Exception ex) {
            String errorMessage = 'Error getting Complaints Rejection Letter: ' + ex.getMessage();
            LOGGER.error('Error processing request', new String[] {'SVC_API_GenerateDocument', 'getComplaintsRejectionLetter'}, ex);
            throw new GenerateDocumentException(errorMessage, ex);
        }
    }

    public class GenerateDocumentException extends Exception {}

}