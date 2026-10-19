/**
 * @description       : Class with invocable method for template generation
 * User Story		  : SFP-31300
 * @author            : Aliaksei Koval
 * @last modified on  : 08-12-2025
 * @last modified by  : Aliaksei Koval
**/
public with sharing class SVC_TemplateService {

    /**
     * @description Private constructor throws exception to prevent instantiation of this static utility class
     */
    @TestVisible
    private SVC_TemplateService() {}
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_TemplateService');

    private static final String FILE_NAME = 'Complaints Rejection Letter';

    public class TemplateInputs {
        @InvocableVariable public String recordId;
        @InvocableVariable public String reason;
    }

    /**
    * @description 
    * @param requests 
    * @return List<String> 
    **/
    @InvocableMethod(Label='Get template' Description='Get template')
    public static List<String> getTemplate(List<TemplateInputs> requests){
        if (requests.size() > 1) {
            throw new InvalidParameterValueException('Too many arguments', String.valueOf(requests.size()));
        }
        SVC_DTO_TemplateServiceRestRequest body = prepareTemplateBody(requests[0].recordId, requests[0].reason);
        SVC_DTO_TemplateServiceRestResponse response = SVC_API_GenerateDocument.getComplaintsRejectionLetter(body);
        if(response == null){
            return null;
        }
        String contDocId = saveFileToContentVersion(
                response.output_document.content_stream, 
                FILE_NAME, 
                'Rejection Letter', 
                'Rejection Letter.pdf'
            );

            linkContentToRecord(requests[0].recordId, contDocId);
        return new List<String>{contDocId};
        
    }

    /**
    * @description 
    * @param recordId 
    * @param reason 
    * @return String 
    **/
    public static SVC_DTO_TemplateServiceRestRequest prepareTemplateBody(String recordId, String reason){
        SVC_DTO_TemplateServiceRestRequest body = null;
        if(((ID)recordId).getSObjectType() == Schema.Case.getSObjectType()){
            body = SVC_CaseTemplateDataService.prepareTemplateRequestBody(recordId, reason);
        }
        return body;
    }

        /**
    * @description 
    * @param base64FileContent 
    * @param title 
    * @param description 
    * @param fileName 
    * @return String 
    **/
    public static String saveFileToContentVersion(String base64FileContent, String title, String description, String fileName) {
        if(Schema.sObjectType.ContentVersion.isCreateable()){
            try{
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64FileContent);
            cv.Title = title;
            cv.Description = description;
            cv.PathOnClient = fileName;
            insert cv;
    
            return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id WITH SECURITY_ENFORCED LIMIT 1].ContentDocumentId;
            } catch(Exception ex){
                LOGGER.error('Error saving file to Content Version', new String[] {'SVC_TemplateService', 'saveFileToContentVersion'}, ex);
                return null;
            }
    
        } else{
            return null;
        }
    }

    /**
    * @description 
    * @param recordId 
    * @param contentDocumentId 
    **/
    public static void linkContentToRecord(String recordId, String contentDocumentId) {
        if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
            try{
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = contentDocumentId;
            insert cdl;
            } catch(Exception ex){
                LOGGER.error('Error linking file to record', new String[] {'SVC_TemplateService', 'linkContentToRecord'}, ex);
            }
        }
    }
}