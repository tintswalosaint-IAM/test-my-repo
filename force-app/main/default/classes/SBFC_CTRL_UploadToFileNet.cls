/**
 * @description       : SFP-58317 - controller class for uploading files to fileNet
 * @author            : Amlendu Bajpai
 * @group             : SBFC
 * @last modified on  : 08-06-2026
 * @last modified by  : Amlendu Bajpai
**/

public with sharing class SBFC_CTRL_UploadToFileNet {
    public static String IDENTIFIER_TYPE = 'bpid';
    public static String IDENTITY_NUMBER = 'identityNumber';
    public static String INITIAL = 'initial';    
    public static String SURNAME_COMPANYNAME = 'surNameOrCompanyName';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SBFC_CTRL_UploadToFileNet.class.getName());

    /**
    * @description Retrieves all files associated with a given record.
    * @param recordId Id of the record whose related files are to be fetched.
    * @return List of ContentDocumentLink records containing file details.
    */   
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getFiles(Id recordId) {
        try{
            String objectName = recordId.getSObjectType().getDescribe().getName();
            if(objectName == 'Account' && Schema.sObjectType.InfoAuthorizationRequest.isAccessible()){
                InfoAuthorizationRequest infoAuthReq = new SEL_InfoAuthorizationRequest().selectBySourceRecordId(recordId);
                recordId = infoAuthReq !=NULL ? infoAuthReq.Id : recordId;
            }
            if (!Schema.sObjectType.ContentDocumentLink.isAccessible() || Test.isRunningTest()) {
                LOGGER.error('Insufficient access to files.');
                throw new AuraHandledException('Insufficient access to files.');
            }
            return new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(recordId);
        }catch(exception e){
            LOGGER.error(e.getMessage(), new String[] {SBFC_CTRL_UploadToFileNet.class.getName(), e.getMessage()}, e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Retrieves the latest version of a file and returns its content encoded as a Base64 string.
    * @param contentDocumentId Id of the ContentDocument whose file content is to be retrieved.
    * @return Base64 encoded string representation of the file content.
    */
    @AuraEnabled
    public static String getFileBase64(Id contentDocumentId) {
        try{
            if (!Schema.sObjectType.ContentVersion.isAccessible() ||
                !Schema.sObjectType.ContentVersion.fields.VersionData.isAccessible() ) {
                    throw new AuraHandledException('Insufficient access to file content.');
                }
            ContentVersion cv = new SEL_ContentVersion().selectSingleContentById(contentDocumentId);
            return EncodingUtil.base64Encode(cv.VersionData);
        }catch(exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description used to fire of API class
    * @author Amlendu Bajpai | 03-18-2026 
    * @param applicationId - Id of the application
    * @param docName - this is the name of the file thats being uploaded
    * @param documentType - this is the taxonomy number 
    * @param base64Document - base64 encoded string of the PDF document
    * @return String API Success value 
    **/
    @AuraEnabled
    public static String uploadDocument(Id applicationId, String docName, Integer documentType, String base64Document) {
        Account account;
        InfoAuthorizationRequest infoAuthReq;
        Id accountId ;
        String objectName = applicationId.getSObjectType().getDescribe().getName();
        try{
        if(objectName == 'InfoAuthorizationRequest'){            
            infoAuthReq = new SEL_InfoAuthorizationRequest().selectById(applicationId);
            accountId= infoAuthReq.SourceRecordId;
        }else if(objectName == 'Account'){
            accountId=applicationId;
            infoAuthReq = new SEL_InfoAuthorizationRequest().selectBySourceRecordId(applicationId);
        }
        }catch(exception e){
            LOGGER.error(e.getMessage(), new String[] {SBFC_CTRL_UploadToFileNet.class.getName(), e.getMessage()}, e);
        }
        
        try {
                account = new SEL_Account().selectById(accountId);
                SBFC_DTO_UploadToFileNet.DTO_Response responseDto = new SBFC_DTO_UploadToFileNet.DTO_Response();
                Map<String, String> customerIdentifierByType = getCustomerIdentifierMap(account);
                SBFC_API_UploadToFileNet uploadFileCallout = new SBFC_API_UploadToFileNet();
                uploadFileCallout.initialise(customerIdentifierByType, docName, documentType, base64Document);
                CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(SBFC_API_UploadToFileNet.SERVICE_NAME);
                queueItem.CMN_TriggeringObjectId__c = applicationId;
                CMN_DAL_WebserviceCallQueue.ServiceCallResult callResult = uploadFileCallout.process(queueItem,Account,infoAuthReq);
                sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
                uow.registerNew(queueItem);
                uow.commitWork();
                if(callResult.StatusCode=='200'){
                    responseDto = (SBFC_DTO_UploadToFileNet.DTO_Response) 
                        JSON.deserialize(
                            callResult.responseBody,
                            SBFC_DTO_UploadToFileNet.DTO_Response.class
                        );
                    return String.isNotBlank(responseDto?.documents?.fnGuide)? 'Success': 'Failed';
                 }
        }        
        catch (Exception error) {
            LOGGER.error(error.getMessage(), new String[] {SBFC_CTRL_UploadToFileNet.class.getName(), error.getMessage()}, error);
            throw new AuraHandledException(error.getMessage());
        }
        return 'Failed';
    }
    /**
    * @description Retrieves the account info into map.
    * @param Account as input.
    * @return Map object .
    */
    private static Map<String, String> getCustomerIdentifierMap(Account account) {
    return new Map<String, String>{
        IDENTIFIER_TYPE      => String.valueOf(account.CMN_CustomerBPID__pc == null ? '' : account.CMN_CustomerBPID__pc),
        IDENTITY_NUMBER      => String.valueOf(account.CMN_IdentityNumber__pc == null ? '' : account.CMN_IdentityNumber__pc),
        INITIAL              => String.valueOf(account.FirstName == null ? '' : account.FirstName),
        SURNAME_COMPANYNAME  => String.valueOf(account.LastName == null ? '' : account.LastName)
    };
}
}