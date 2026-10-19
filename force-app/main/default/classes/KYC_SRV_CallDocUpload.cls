/**
 * @description             : KYC_SRV_CallDocUpload to make an API callout.
 * @story                   : SFP-51843
 * @author                  : Irshad Alam
 * @created date            : 12/08/2025
 * @lastModified			: SFP-53562: Updated Sharing setting of the class
 */
public without sharing class KYC_SRV_CallDocUpload {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('KYC_SRV_CallDocUpload');
    
    public KYC_SRV_CallDocUpload() {

    }
    /**
     * @description Calls the KYC_SRV_DocUpload service to upload a document
     * @param pivObjId The ID of the party profile object
     */
    public static void callDocUploadService(Id partyProfileId, Id cdId) {
        List<PartyProfile> partyProfilesToUpdate = new List<PartyProfile>();
        try{
            PartyProfile PartyProfileObj = new SEL_PartyProfile().selectById(PartyProfileId);                   
            ContentVersion cv = [SELECT Id, title,
                                        FileType,
                                        VersionData,
                                        DocumentType__c,
                                        VersionNumber
                                    FROM contentVersion 
                                    WHERE contentDocumentId=: cdId
                                    ORDER BY VersionNumber DESC
                                    LIMIT 1];
            
            if(PartyProfileObj != null){        
                String jsonRequestBody = generateDocUploadRequest(PartyProfileObj, cv);
                
                KYC_SRV_DocUpload docUploadService = new KYC_SRV_DocUpload(jsonRequestBody);    

                CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_SRV_DocUpload.SERVICE_NAME);
                docUploadService.process(obj);
                insert obj;
                
                Map<String,Object> jsonRes = (Map<String,Object>)JSON.deserializeUntyped(docUploadService.getResponseBody());
                Integer statusCode = docUploadService.getResponseStatusCode();
               
                if (statusCode == 201 || statusCode == 200) {                   
                    
                    if (jsonRes.containsKey('documentStatus')) {
                        String documentStatus = (String)jsonRes.get('documentStatus');
                        if (documentStatus == 'Success') {
                            PartyProfileObj.CMN_DocumentSyncStatus__c = 'Success';
                            PartyProfileObj.CMN_DocumentSyncReason__c = jsonRes.containsKey('documentStatusMessage')? (String)jsonRes.get('documentStatusMessage') : 'Document uploaded successfully';
                            partyProfilesToUpdate.add(PartyProfileObj);
                            

                        }else{
                            // update the fields Document_Sync__c on party profile
                            PartyProfileObj.CMN_DocumentSyncStatus__c = 'Failed';
                            PartyProfileObj.CMN_DocumentSyncReason__c = jsonRes.containsKey('documentStatusMessage')? (String)jsonRes.get('documentStatusMessage') : 'Document upload failed';
                            partyProfilesToUpdate.add(PartyProfileObj);
                            
                        } 
                    }            

                    
                } else{
                     if (jsonRes.containsKey('error')) {
                        Map<String, Object> errorMap = (Map<String, Object>) jsonRes.get('error');
                        PartyProfileObj.CMN_DocumentSyncReason__c = (String) errorMap.get('errorDescription');
                        partyProfilesToUpdate.add(PartyProfileObj);                        
                     }    
                    LOGGER.error('KYC_SRV_CallDocUpload.callDocUploadService', new List<String>{'Failed=' + docUploadService.getResponseStatusCode()});
                }
           
            }else{
                LOGGER.error('Party Profile Doesnt exist', new List<String>{'PartyProfileId=' + PartyProfileId});
            }

        }catch(Exception ex){
            LOGGER.error('KYC_SRV_CallDocUpload.callDocUploadService', new List<String>{'Exception=' + ex.getMessage()});
            
        }
        if (!partyProfilesToUpdate.isEmpty()) {
            update partyProfilesToUpdate;
        }
        
    }

    /**
     * @description Generates the JSON request body for the document upload service
     * @param PartyProfile The party profile object containing necessary data
     * @return JSON string of the request body
     */
    private static string generateDocUploadRequest(partyProfile PartyProfileObj, ContentVersion conVerObj) {
       KYC_SRV_DocUpload_Request request = new KYC_SRV_DocUpload_Request();

        request.documentName = conVerObj.title;
        request.documentType = conVerObj.DocumentType__c;
        request.documentFormatType = conVerObj.filetype;//'jpg';
        request.documentStatus = '';
        request.documentStatusMessage = '';
        request.documentStream = EncodingUtil.base64Encode(conVerObj.VersionData);
        request.documentDirectoryId = '1234567890'; // Replace with actual directory ID 

        // Identification list
        request.documentIdentification = new List<KYC_SRV_DocUpload_Request.cls_documentIdentification>();
        KYC_SRV_DocUpload_Request.cls_documentIdentification docId = new KYC_SRV_DocUpload_Request.cls_documentIdentification();
        docId.documentIdentificationType  = 'DocumentUUID';
        docId.documentIdentificationValue = conVerObj.Id;
        docId.documentVersion              = conVerObj.VersionNumber;//'1';
        request.documentIdentification.add(docId);

        // document date and repository location
        request.documentDateTime = new KYC_SRV_DocUpload_Request.cls_documentDateTime();
        request.documentDateTime.documentDateTimeType = 'UploadedDateTime';
        request.documentDateTime.documentDateTime = System.now().format();
        request.documentRepositoryLocation = new KYC_SRV_DocUpload_Request.cls_documentRepositoryLocation();
        request.documentRepositoryLocation.documentRepositoryName = 'Document Repository';
        request.documentRepositoryLocation.documentURL = 'documents/464981/file';

        // Party Reference Details
        request.partyReference = new KYC_SRV_DocUpload_Request.cls_partyReference();
        request.partyReference.partyIdentificationType = PartyProfileObj.PrimaryIdentifierType;
        request.partyReference.partyIdentificationValue = PartyProfileObj.CMN_RelyComplyCustomerId__c;
        request.partyReference.countryofIssue = PartyProfileObj.Country_of_Residence__c;
        request.partyReference.firstName = PartyProfileObj.firstName;
        request.partyReference.lastName = PartyProfileObj.LastName;

        // Document Validity Period
        request.documentValidityPeriod = new KYC_SRV_DocUpload_Request.cls_documentValidityPeriod();
        request.documentValidityPeriod.fromDateTime = System.now().format();
        request.documentValidityPeriod.toDateTime = System.now().addYears(2).format();  
        String jsonRequest = JSON.serialize(request);
        
       
        return jsonRequest;
    }
}