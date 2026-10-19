/***************************************************************************************
@Name of the Class :KYC_API_DocumentUploads
@Description : SFP-32986 Class used to Wfr document uploads
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@RestResource(urlMapping='/partyProfileDocuments/*')
global without sharing class KYC_API_DocumentUploads {
   
 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('KYC_API_DocumentUploads');
    private static String failedString = 'Failed';

    /**
    * @description Global static method to handle the HTTP POST request for attaching PIV documents.
    * The method parses the incoming JSON request body, processes the documents, and returns a response.
    */
    @HttpPost
    global static void attachPIVDocument() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes();
        try {
            KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = (KYC_DTO_InboundDocumentUplod.KYC_WRP_Req) JSON.deserializeStrict(
                RestContext.request.requestBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_Req.class
            );
            dtoResponse = attachPIVDocuments(requestBody);
        } catch (JSONException e) {
            dtoResponse.status = failedString;
            dtoResponse.responseCode = SVC_UTIL_CrossOrg.STATUS_CODE_400;
            dtoResponse.message = String.valueOf(e); 
            LOGGER.error('KYC_API_DocumentUploads.attachPIVDocument Exception', new String[] {'KYC_INT_InboundDocumentUpload.attachPIVDocument', dtoResponse.message});
        } catch (Exception e) {
            dtoResponse.status = failedString;
            dtoResponse.responseCode = 500;
            dtoResponse.message = String.valueOf(e);
            LOGGER.error('KYC_API_DocumentUploads.attachPIVDocument Exception', new String[] {'KYC_API_DocumentUploads.attachPIVDocument', dtoResponse.message});
        } finally {
            RestContext.response.statusCode = dtoResponse.responseCode;
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(dtoResponse));
            RestContext.response.addHeader('Content-type', 'application/json');
        }
    }
    /**
    * @description Method to handle the attachment of PIV documents.
    *
    * @param requestBody The request body containing the document details and other information.
    * @return KYC_WRP_DocRes The response object with the status and message.
    */
    public static KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes attachPIVDocuments(KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody) {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes();
        try {
            if(requestBody.hasNullField()){
                dtoResponse.status = failedString;
                dtoResponse.responseCode = SVC_UTIL_CrossOrg.STATUS_CODE_400;
                dtoResponse.message = String.join(requestBody.errorFields,';');
            } else {
                List<PartyIdentityVerification> pivList = new List<PartyIdentityVerification>();
                pivList = new SEL_PartyIdentityVerification().selectByThirdPartyVerfdentifier(new Set<String>{requestBody.uniqueIdentifier});
               	if(pivList.isEmpty()){
                    dtoResponse.message = 'record not found'; 
                }else{
                    if(pivList[0].result == 'On Hold'){
                        dtoResponse.message = processPIVRecord(requestBody,pivList[0]);
                    } else {
                        dtoResponse.message = 'record already updated';
                    }
                    processDocuments(requestBody.documentList, pivList[0].ID);
                }
                dtoResponse.status = 'Success';
                dtoResponse.responseCode = SVC_UTIL_CrossOrg.STATUS_CODE_200;
            }
        } catch (Exception e) {
            dtoResponse.status = failedString;
            dtoResponse.responseCode = 500;
            dtoResponse.message = String.valueOf(e);
            LOGGER.error('KYC_API_DocumentUploads.attachPIVDocument Exception', new String[] {'KYC_API_DocumentUploads.attachPIVDocument', dtoResponse.message});
        }
        return dtoResponse;
    }

    private static String processPIVRecord(KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody, PartyIdentityVerification pivRecord) {
        String message = '';
        if(String.isBlank(requestBody.identityNumber)){
            EventBus.publish(new PartyProfile_Refresh__e(UniqueIdentifier__c = requestBody.uniqueIdentifier,Message__c='Identity Verficaiton Documents are added.Please check and update WFR check manually.'));
            message = 'Identity Number is Mismatching'; 
        } else {
            if(requestBody.livenessFRMatch == false){
                pivRecord.result = 'Rejected';
                EventBus.publish(new PartyProfile_Refresh__e(UniqueIdentifier__c = requestBody.uniqueIdentifier,Message__c='WFR check failed due to Liveness check failed.'));
            }
            else if(pivRecord.PartyProfile.WI_PrimaryIdentificationName__c.equals(requestBody.identityNumber) == false){
                pivRecord.result = 'Rejected';
                EventBus.publish(new PartyProfile_Refresh__e(UniqueIdentifier__c = requestBody.uniqueIdentifier,Message__c='WFR check failed due to Identity Number is Mismatching'));
            }
            else if( requestBody.livenessFRScore < 60){
                pivRecord.result = 'Rejected';
                EventBus.publish(new PartyProfile_Refresh__e(UniqueIdentifier__c = requestBody.uniqueIdentifier,Message__c='WFR check failed due to Liveness Score is less than 60.'));
            } else {
                pivRecord.result = 'Accepted';
                EventBus.publish(new PartyProfile_Refresh__e(UniqueIdentifier__c = requestBody.uniqueIdentifier,ScreeningDecision__c ='Clear' ,Message__c='Verification Completed. Please see the latest Sreening Status.'));
            }                        
            upsert pivRecord;
            message = 'record updated successfully';
        }
        return message;
    }

    private static void processDocuments(List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq> documentList, Id pivRecordId) {
        if (!documentList.isEmpty()) {
            List<ContentVersion> cvList = new List<ContentVersion>();
            for (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq document : documentList) {
                ContentVersion cv = new ContentVersion();
                cv.VersionData = EncodingUtil.base64Decode(document.base64Attachment);
                cv.Title = document.title;
                cv.PathOnClient = document.title;
                cv.FirstPublishLocationId = pivRecordId;
                cvList.add(cv);
            }
            if (!cvList.isEmpty() && Schema.sObjectType.ContentVersion.isUpdateable() && Schema.sObjectType.ContentVersion.isCreateable()) {
                upsert cvList;
            }
        }
    }
}