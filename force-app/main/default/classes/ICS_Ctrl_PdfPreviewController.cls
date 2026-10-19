/**
* @description Class used to display PDF for New Client Team
*
* Story:SFP-48980
*
* @author Ikyatha Naidu
*
* @date May 2025
* @last modified on  : 12-05-2025
* @last modified by  : Ikyatha Naidu
* @Modification Description : Initial Version

*/

public without sharing class ICS_Ctrl_PdfPreviewController {
        private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_Ctrl_PdfPreviewController');

    /**
     * Retrieves ContentVersion data for a specific ContentDocument
     * @param contentDocumentId - The Id of the ContentDocument
     * @return ContentVersion - The ContentVersion record with file details
     */
    @AuraEnabled(cacheable=true)
    public static ContentVersion getContentVersion(String  accountId) {
        try {
            // Query the latest published version for the specified ContentDocument
            set<string> docIds = new set<string>();
            for(Contentdocumentlink docuObj: [select id,contentdocumentId from Contentdocumentlink where LinkedEntityId  =: accountId]){
                docIds.add(docuObj.contentdocumentId);
            }
            List<ContentVersion> versionList = [
                SELECT Id, Title, FileExtension, ContentSize, VersionData, ContentDocumentId
                FROM ContentVersion 
                WHERE ContentDocumentId in :docIds
                AND IsLatest = true and DocumentType__c = 'Mandate/Application Form'
                LIMIT 1
            ];
            if(versionList.size()>0){
                return versionList[0];
            }else{
                return null;
            }
            
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage(),' Failed to fetch Document');
             return null;
        }
    }
    
    /**
     * Retrieves the URL to view the PDF content
     * @param contentDocumentId - The Id of the ContentDocument
     * @return String - URL to view the file
     */
    @AuraEnabled(cacheable=true)
    public static String getContentDocumentUrl(String accountId) {
        
            
            return '/apex/ICS_ApplicantForm_PDF?Id='+accountId ;
               
    
    }
}