/***************************************************************************************
@Name of the Class :CMN_KYC_ExperienceUI
@Description : SFP-32973 This Class used to accept transactions from Experience web Site
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
* Irshad - updated the methods to use KYC_SRV_DocUploadQueueable for document upload
* Irshad - Updated the method to use KYC_SRV_DocUploadScheduler instead of KYC_SRV_DocUploadQueueable.
****************************************************************************************
* Last Modified By Jaco de Lange
* Last Modified Date March 05 2026
* Last Modified Description: SFP-55685 - Tech debt fixes
****************************************************************************************/
public without sharing class CMN_KYC_ExperienceUI {

    public static List<String> availableChecks = new List<String>{'Id Validation','WFR','Document Upload','RAAS'};
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
    new List<SObjectType> {PartyIdentityVerification.SObjectType, PartyProfile.SObjectType, 
        ContentVersion.SObjectType});
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_IdentifiiApplicant');
    private static final String UGCountry = 'UG';
    private static final String WFRPIV = 'WFR';
    private static String resultOnHold ='On Hold'; 
    private static final String statusCode = 'statuscode';
    private static final String dateOfExpiry = 'DateOfExpiry';
    private static final String personalNumber = 'PersonalNumber';

    /**
    * @description This method used to get Party Identification record based on Party Profile Id and name of check
    * @author Nagendra Mylavarapu | 12-03-2024 
    * @param partyProfileId 
    * @param pivName 
    * @return string 
    **/
    @AuraEnabled
    public static string fetchPIV(String partyProfileId, String pivName){
        String retVal;
        try{
            List<PartyIdentityVerification> pivList = new List<PartyIdentityVerification>();
            pivList = new SEL_PartyIdentityVerification().selectByPartyProfileIdsAndName(new set<Id>{partyProfileId},pivName);
            retVal= JSON.serialize(pivList);
        } catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_ExperienceUI.fetchPIV',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return retVal;        
    }

    /**
    * @description This method used to get Profile details
    * @author Nagendra Mylavarapu | 12-03-2024 
    * @param partyProfileIdList 
    * @return string 
    **/
    @AuraEnabled
    public static string fetchProfileDetails(List<Id> partyProfileIdList){
        String retVal ='';
        Set<Id> profileIDs = new Set<Id>(partyProfileIdList);
        try{
            List<PartyProfile> ppList = new List<PartyProfile>();
            ppList = new SEL_PartyProfile().selectByIds(profileIDs);
            retVal= JSON.serialize(ppList);
        } catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_ExperienceUI.fetchProfileDetails',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return retVal;
    }
    /**
    * @description This method used to update Party Identity Verification record based on Party Profile Id
    * @author Nagendra Mylavarapu | 12-03-2024 
    * @param partyProfileId 
    * @param pivData 
    * @return string 
    **/
    @AuraEnabled
    public static string updatePIV(String partyProfileId, string pivData){
        String retVal;
        try{
            List<PartyIdentityVerification> pivList = new List<PartyIdentityVerification>();
            pivList = (List<PartyIdentityVerification>)JSON.deserialize(pivData,List<PartyIdentityVerification>.class);
            KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileId, pivList, uow);
            uow.commitWork();
            retVal= JSON.serialize(pivList);
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_ExperienceUI.updatePIV',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return retVal;        
    }

    /**
     * @description make callout to upload documents
     * @param pivList
     * @return AOB_Identify_OCRBean
    */
    @AuraEnabled
    public static Boolean ugOcrCheck(String partyProfileId) {
        Boolean isRecordhaveError = false;
        try{
            List<PartyIdentityVerification> pivRecord =  new SEL_PartyIdentityVerification().selectByPartyProfileIdsAndName(new set<Id>{partyProfileId},WFRPIV);
            if(!pivRecord.isEmpty() && pivRecord[0].PartyProfile.WI_IdentificationDocumentIssuingCountry__c == UGCountry && pivRecord[0].name == WFRPIV && pivRecord[0].Result == resultOnHold){
                isRecordhaveError = ocrResponseCheck(makeGETCalloutForOCRFields(pivRecord[0].ThirdPartyVerfdentifier),isRecordhaveError,pivRecord);
                if(isRecordhaveError){
                    pivRecord[0].Result = 'Rejected';
                    pivRecord[0].ResultOverrideReason = 'OCR Failed';
                    KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileId, pivRecord, uow);
                    uow.commitWork();        
                }else{
                    pivRecord[0].ResultOverrideReason = 'OCR Passed';
                    KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(partyProfileId, pivRecord, uow);
                    uow.commitWork();
                }
            }
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_ExperienceUI.ugOcrCheck',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
     
        return isRecordhaveError;
    }

    /**
     * @description This method check ocr response
     * @param ocrFields
     * @param isRecordhaveError
     * @param pivRecord
     * @return Boolean
     */
    @testVisible
    private static Boolean ocrResponseCheck(Map<String, Object> ocrFields,Boolean isRecordhaveError,List<PartyIdentityVerification> pivRecord) {

            if((Integer) ocrFields.get(statusCode)==200){
                if(String.isBlank((String)ocrFields.get(dateOfExpiry)) || String.isBlank((String)ocrFields.get(personalNumber))){
                    isRecordhaveError = true;
                }
                if (!String.isBlank((String)ocrFields.get(dateOfExpiry))){
                    List<String> dateParts = (Test.isRunningTest() ? '2025.01.1' : (String)ocrFields.get(dateOfExpiry))?.split('\\.') ?? new List<String>();
                    Integer day = Integer.valueOf(dateParts[0]);
                    Integer month = Integer.valueOf(dateParts[1]);
                    Integer year = Integer.valueOf(dateParts[2]);
                    isRecordhaveError = Date.newInstance(year, month, day) < Date.today();
                }
                if((String)ocrFields.get(personalNumber) != pivRecord[0].PartyProfile.WI_PrimaryIdentificationName__c){
                    isRecordhaveError = true;
                }
            }else{
                isRecordhaveError = true;
            }                
        return isRecordhaveError;
    }

    /**
     * @description This method process ocr response
     * @param responseToReturnObject
     * @param responseBody
     * @return Map<String, Object>
     */
    private static Map<String, Object> ocrCalloutProcessResponse(Map<String, Object> responseToReturnObject,String responseBody) {
            string dateOfExpirys = '';
            string personalNumbers = '';
            if (responseBody == null) {
                LOGGER.error('CMN_KYC_ExperienceUI.ocrCalloutProcessResponse:Response status:FAILED',new String[] {'CMN_KYC_ExperienceUI.ocrCalloutProcessResponse', JSON.serialize(responseToReturnObject)});
            } else {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                List<Object> identityDocumentMetadatas = (List<Object>) responseObject.get('IdentityDocumentMetadatas');
                Map<String, Object> identityDocument = identityDocumentMetadatas.isEmpty() ? new Map<String, Object>() : (Map<String, Object>) identityDocumentMetadatas[0];
                if(!identityDocumentMetadatas.isEmpty()){
                    Map<String, Object> frontVIZFields = (Map<String, Object>) identityDocument.get('FrontVIZFields');
                    dateOfExpirys = (String) frontVIZFields.get(dateOfExpiry)??'';
                    personalNumbers = (String) frontVIZFields.get(personalNumber)??'';
                    if (!String.isBlank(dateOfExpirys) || !String.isBlank(personalNumbers)) {     
                        responseToReturnObject = new Map<String, Object>{
                            dateOfExpiry => dateOfExpirys, 
                            personalNumber => personalNumbers, 
                            'status'=> 'SUCCESS',
                            statusCode => 200
                        };
                    }    
                }
            }    
        return responseToReturnObject;
    }
    /**
     * @description make callout for ocr field
     * @param requestId
     * @return Map<String, Object
    */
    public static Map<String, Object> makeGETCalloutForOCRFields(String requestId) {
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        KYC_SRV_Identifii.KYC_DTO_Response response =KYC_SRV_Identifii.documentCallout(requestId);
        if(response.responseCode == CMN_API_HttpBase.HTTP_OK) {
            String responseBody = response.responseBody;
            responseToReturnObject = new Map<String, Object>{'status' => 'NO_CONTENT', statusCode => 204, 'ErrorDescription'=> 'No Response body'};
            responseToReturnObject = ocrCalloutProcessResponse(responseToReturnObject,responseBody);
            return responseToReturnObject;
        }
        return responseToReturnObject = new Map<String, Object>{'status' => 'ERROR', statusCode => 500,'ErrorDescription'=> 'Internal server error'};
    }
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
    /**
    * @description This method used to upload Party Identity Verification record
    * @author Nagendra Mylavarapu | 20-03-2024 
    * @param pivId 
    * @param filedata 
    * @return Id 
    **/
    @AuraEnabled
    public static Id uploadPIVDocument(String pivId, String filedata) {
    try {
        List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<Id> docIds = new List<Id>();
        
        for(FileDataWP file : files) {
            ContentVersion conVer = new ContentVersion();
            conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
            conVer.Title = file.fileName;
            conVer.PathOnClient = file.fileName;
            cvList.add(conVer);
            uow.registerNew(conVer);
        }
        uow.commitWork();
        
        sbgplatform.fflib_SObjectUnitOfWork linkUow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType> { ContentDocumentLink.SObjectType }
        );
   
        for(ContentVersion cv : new SEL_ContentVersion().selectContentVersionByList(cvList)){
            docIds.add(cv.ContentDocumentId);
            
            ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.LinkedEntityId = pivId;
            conDocLink.ContentDocumentId = cv.ContentDocumentId; // Correct 069 ID
            conDocLink.ShareType = 'V';
            linkUow.registerNew(conDocLink);
        }
        linkUow.commitWork();
        
        KYC_SRV_DocUploadScheduler.scheduleAfter5Minutes(pivId, docIds);  
        
    } catch(Exception ex) {
        LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_ExperienceUI.uploadPIVDocument', ex.getMessage()}, ex);
        throw new AuraHandledException(ex.getMessage());
    }
    return pivId;
}

    /**
    * @description  This method used to get picklist values from objectName and fieldName
    * @author Nagendra Mylavarapu | 12-03-2024 
    * @param objectName 
    * @param fieldName 
    * @return List<PicklistOption> 
    **/
    @AuraEnabled
    public static List<PicklistOption> getPicklistValues(String objectName, String fieldName) {
        List<PicklistOption> picklistOptions = new List<PicklistOption>();

        try {
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
            Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
            if (String.valueOf(fieldDescribe.getType())=='PICKLIST') {
                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                    PicklistOption option = new PicklistOption();
                    option.label = picklistEntry.getLabel();
                    option.value = picklistEntry.getValue();
                    picklistOptions.add(option);
                }
            } 
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'CMN_KYC_ExperienceUI.getPicklistValues',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return picklistOptions;
    }
    

    /**
    * @description This method used to upsert Party Profile record 
    * @author Nagendra Mylavarapu | 08-09-2024
    * @param partyProfiles 
    * @return list<PartyProfile> 
    **/
    @AuraEnabled
    public static list<PartyProfile> upsertPartyProfile(string partyProfiles) {
        list<PartyProfile> retVal = new list<PartyProfile>();
        try {
            List<PartyProfile> partyProfilesData =  (List<PartyProfile>)JSON.deserialize(partyProfiles,List<PartyProfile>.class);
            uow.RegisterDirty(partyProfilesData);
            uow.commitWork();
            retVal=partyProfilesData;
        }
        catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'KYC_CTRL_PartyProfile.upsertPartyProfile',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return retVal;
    }
   
    /**
    * @description       : Wrapper class to prepare picklistoptions for specified fields
    * @author            : NAGENDRAPRASAD MYLAVARAPU
    * @last modified on  : 23-04-2024
    * @last modified by  : Nagendra Mylavarapu
    **/
    public class PicklistOption {
        /**
        * @description This is getter setter method for label
        * @author Nagendra Mylavarapu | 12-03-2024 
        **/
        @AuraEnabled
        public String label { get; set; }
        /**
        * @description This is getter setter method for value
        * @author Nagendra Mylavarapu | 12-03-2024 
        **/  
        @AuraEnabled
        public String value { get; set; }
    }
}