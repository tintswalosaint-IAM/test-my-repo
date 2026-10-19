/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :July 2023
@ Name of the Class :CMN_DSX
@description       :Class for dealing with DSX api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  : Ravi Myaka
@ Last Modified On  :18-04-2024
@ Modification Description : SFP-37845
***************************************************************************************/
public without sharing class CMN_DSX {
    
    private static final String AUTHORIZATION_TYPE_BASIC = 'Basic ';
    private static final String CONTENT_TYPE_APPLICATION_JSON = 'application/json';
    private static final String HEADER_ACCEPT = 'accept';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CLIENT_ID = 'X-IBM-Client-Id';
    private static final String HEADER_CLIENT_SECRET = 'X-IBM-Client-Secret';
    private static final String HEADER_CLIENT_CERTIFICATE = 'X-Client-Certificate';
    private static final String HEADER_AUTHORIZATION = 'Authorization';
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    private static final String HTTP_METHOD_POST = 'POST';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_DSX');
    
    private static final String PARAM_COLON = ':';
    
    private static final String PATH_TOKEN = '/sysauth/oauth2/token';
    private static final String PATH_CALLOUT = '/content/integration';   
    
    @testVisible private static Integer mockHttpStatusCode;
    @testVisible private static String mockHttpStatus;
    @testVisible private static String mockHttpBody = '';
    
    /** 
* @description This method used for invocableMethod
* @param mappedId
* @param mappedIdValue
* @return String Returns a callout response in map format for remaining processing
*/
    private static String getMappedIdKey(Map<String, String> mappedId, String mappedIdValue) {
        for (String key : mappedId.keySet()) {
            if (mappedId.get(key).equals(mappedIdValue)) {
                return key;
            }
        }
        return null; 
    }
    
    /** 
* @description This method used for invocableMethod
* @param applicationParticipantId
* @return String 
*/
    public static String invocableMethodParticipant(String applicationParticipantId) {
        if(applicationParticipantId != null){
            List<Application_Document__c> appDoc = new SEL_ApplicationDocument().selectAppsByIdApplicationParcipant(applicationParticipantId);
            List<Application_Participant__c> appliactionParticipantS =New AOB_BOTS_SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipantId);
            
            List<String> keysList = new List<String>{'Proof Of Identity','Upload Registration Document','Upload statement of Particulars for sole props','upload image of your national id',
                'Upload Proof of Trading Address','online-banking-application-form','KeyFactsDocumentsigned','SignedDeclarationofliteracy','upload signature','FaceImage'};
                    List<String> appDocIds = new List<String>();
            Map<String, String> mappedId = new Map<String, String>();
            for (Application_Document__c doc : appDoc) {
                if (keysList.contains(doc.Document_Type__c)) {     
                    mappedId.put(doc.Document_Type__c, doc.Id);
                    appDocIds.add(doc.Id);
                } 
            }      
            Map<String, string> mappeddocLinks = new Map<String, string>();
            for (String mappedIdValue : mappedId.values()) {        
                List<ContentDocumentLink> docLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(mappedIdValue);
                for(ContentDocumentLink cdl : docLinks){
                    mappeddocLinks.put(getMappedIdKey(mappedId, mappedIdValue), cdl.ContentDocumentId); 
                }
            }
            
            if(!mappeddocLinks.isEmpty()){
                
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                for (String idValue : mappeddocLinks.values()) {
                    List<ContentVersion> participantCvs = new SEL_ContentVersion().selectApplicationById(idValue);
                    for (ContentVersion cv : participantCvs) {
                        ContentVersion newCv = new ContentVersion();
                        newCv.Title = getMappedIdKey(mappeddocLinks, idValue);
                        newCv.VersionData = cv.VersionData;
                        contentVersions.add(newCv);
                    }
                }
                Boolean isApplication = false;
                Map<String, Object> responseObject = makeDSXCallOutHelper( contentVersions, isApplication,null,appliactionParticipantS);
                if(responseObject != null && responseObject.containsKey('ErrorDescription') == true) {
                    BCB_FlowController.createVerificationRecordForParticipant( appliactionParticipantS[0],'DSX','Failed'); 
                } else {
                    BCB_FlowController.createVerificationRecordForParticipant( appliactionParticipantS[0],'DSX','Success');
                } 
                return JSON.serialize(responseObject);
            }
        }
        return null;
    }
    
    /** 
* @description This method used for invocableMethod
* @param applicationId
* @return null 
*/
    
    public static String invocableMethodApplicationId(string  applicationId)  { 
        if(applicationId != null){
            List<Application__c> applicationList =New SEL_Application().selectAppsById(applicationId);
            List<Application_Document__c> appDoc = new SEL_ApplicationDocument().selectAppsByIdApplication(applicationId);
            List<String> keysList = new List<String>{'Upload Proof of Identity','Upload Registration Document','Upload statement of Particulars for sole props','Upload Company Registration Certificate',
                'Upload trade license','FaceImage','online-banking-application-form','KeyFactsDocumentsigned','SignedDeclarationofliteracy','upload signature','FATCAform'};
                    List<String> appDocIds = new List<String>();
                   
            Map<String, String> mappedId = new Map<String, String>();// mapped with app doc id and doc type
            for (Application_Document__c doc : appDoc) {
                if (keysList.contains(doc.Document_Type__c)) {
                    mappedId.put(doc.Document_Type__c, doc.Id);
                    appDocIds.add(doc.Id);
                }
            } 
           
            Map<String, string> mappeddocLinks1 = new Map<String, string>();// mapped with doc type and ContentDocumentId
            for (String mappedIdValue : mappedId.values()) {
                List<ContentDocumentLink> docLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(mappedIdValue);
                for(ContentDocumentLink cdl : docLinks){
                    mappeddocLinks1.put(getMappedIdKey(mappedId, mappedIdValue), cdl.ContentDocumentId);  
                }
            }
            
            if(!mappeddocLinks1.isEmpty()){
                List<ContentVersion> contentVersions = new List<ContentVersion>();
                for (String idValue : mappeddocLinks1.values()) {
                    List<ContentVersion> participantCvs = new SEL_ContentVersion().selectApplicationById(idValue);
                    for (ContentVersion cv : participantCvs) {
                        ContentVersion newCv = new ContentVersion();
                        newCv.Title = getMappedIdKey(mappeddocLinks1, idValue);
                        newCv.VersionData = cv.VersionData;
                        contentVersions.add(newCv);
                    }
                }
                Boolean isApplication = true;
                Map<String, Object> responseObject = makeDSXCallOutHelper( contentVersions, isApplication,applicationList,null);
                if(responseObject != null && responseObject.containsKey('ErrorDescription') == true) {
                    BCB_FlowController.createVerificationRecord( applicationList[0],'DSX','Failed'); 
                } else {
                    BCB_FlowController.createVerificationRecord( applicationList[0],'DSX','Success');
                } 
                return JSON.serialize(responseObject);
            }
        }
        return null;
    }
    
    /** 
* @description This method used for makeDSXCallOut
* @param documentList
* @param isApplication
* @param applicationList
* @param appliactionParticipantS
* @return Map<String, Object> Returns a callout response in map format for remaining processing
*/
    private static Map<String, Object> makeDSXCallOutHelper( List<ContentVersion> documentList, Boolean isApplication,List<Application__c> applicationList,List<Application_Participant__c> appliactionParticipantS) {
        Map<String, String> documentAndKYCNameMap = new Map<String, String>{
            'Upload Proof of Identity' => 'KYC Documents Proof of Identity',
                'Upload Company Registration Certificate' => 'KYC Documents Proof of Registration',
                'Upload statement of Particulars for sole props' => 'KYC Documents Proof of Particulars of Directors/Trustees',
                'Upload trade license' => 'KYC Documents Proof of Operating License',
                'online-banking-application-form' => 'Account Administration Application Form(s)',
                'KeyFactsDocumentsigned' => 'Mandatory Central Bank documents Key facts document',
                'SignedDeclarationofliteracy' => 'Mandatory Bank documents Declaration of Literacy',    

                'upload signature' => 'Mandates Signature Card',
                'FATCAform' => 'KYC Documents FATCA',
                'KYC Documents Proof of Identity' => 'KYC Documents Proof of Identity',
                'upload image of your national id' =>'KYC Documents Proof of Identity',
                'Proof Of Income' => 'KYC Documents Proof of Income',
                'KYC Documents Proof of Residence' => 'KYC Documents Proof of Residence',
                'Account Administration Passport Sized Photos' => 'Account Administration Passport Sized Photos',
               
                'Account Administration Application Form(s)' =>'Account Administration Application Form(s)'
                };      
                    BCB_DSXBean dsxBean = new BCB_DSXBean();
                    
        if(isApplication == true && !applicationList.isEmpty()){
            if(documentList.isEmpty() == false) {
                PageReference pageOutput = new PageReference('/apex/BCB_ApplicationAsAPDF');
                Blob setBody = Blob.valueof('Test');
                if(!Test.isRunningTest()) {
                    pageOutput.getParameters().put('id', applicationList[0].Id);
                    setBody = pageOutput.getContentAsPdf();
                }
                ContentVersion applicationPdfVersion = new ContentVersion(
                    Title = 'Account Administration Application Form(s)', 
                    Description = 'Account Administration Application Form(s)', 
                    VersionData = setBody
                );
                documentList.add(applicationPdfVersion);
                
            }
            Application__c applicationRecord = applicationList[0];
            List<Id> identifiiDocumentIdList = new List<Id>();
            for(ContentDocumentLink contentDocumentLinkInstance : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :applicationRecord.Id]) {
                identifiiDocumentIdList.add(contentDocumentLinkInstance.ContentDocumentId);
            }
            if(identifiiDocumentIdList.isEmpty() == false) {
                for(ContentVersion contentVersionInstance : [
                    SELECT Id, Description, Title, VersionData 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :identifiiDocumentIdList 
                    AND Title IN ('KYC Documents Proof of Identity', 'Account Administration Passport Sized Photos', 'Mandates Document Image', 'KYC Documents Proof of Residence')
                    AND IsMajorVersion = true AND IsLatest = true 
                ]
                   ) {
                       
                       documentList.add(contentVersionInstance);
                      
                   }
            }
            
            dsxBean.agent   = 'A232337';
            dsxBean.country = 'UG'; 
            dsxBean.cif     = applicationRecord.AOB_Customer_Id__c;  
            List<BCB_DSXBean.Documents> dsxDocsList = new List<BCB_DSXBean.Documents>();
            for(ContentVersion document : documentList) {
                BCB_DSXBean.Documents dsxDocs = new BCB_DSXBean.Documents();
                dsxDocs.documentType  = documentAndKYCNameMap.get(document.Title); 
                dsxDocs.name          = documentAndKYCNameMap.get(document.Title);     
                if(document.Title == 'Signature File') {
                    dsxDocs.content   = String.valueOf(document.VersionData);
                }else if(document.Description == 'FrontImage'){
                    document.Description = 'KYC Documents Proof of Identity';
                    dsxDocs.documentExpiryDate = string.valueOf(applicationRecord.AOB_Identifii_Expire_Date__c);
                    dsxDocs.content   = EncodingUtil.base64Encode(document.VersionData);
                } else {
                    dsxDocs.content   = EncodingUtil.base64Encode(document.VersionData);
                }
                dsxDocsList.add(dsxDocs);
            }
            dsxBean.Documents = dsxDocsList;
            
            Map<String, Object> apiResponseObject= makeDSXAPICallOut(dsxBean);
            return apiResponseObject;
        }else if(!appliactionParticipantS.isEmpty()){
            if(documentList.isEmpty() == false) {
                PageReference pageOutput = new PageReference('/apex/BCB_ParticipantAsAPDF');
                Blob setBody = Blob.valueof('Test');
                if(!Test.isRunningTest()) {
                    pageOutput.getParameters().put('id', appliactionParticipantS[0].Id);
                    setBody = pageOutput.getContentAsPdf();
                }
                ContentVersion participantPdfVersion = new ContentVersion(
                    Title = 'Account Administration Application Form(s)', 
                    Description = 'Account Administration Application Form(s)', 
                    VersionData = setBody
                );
                documentList.add(participantPdfVersion); 
            }
            Application_Participant__c applicationPartRecord = appliactionParticipantS[0];
            Application__c app = new SEL_Application().selectAppById( applicationPartRecord.Application__c);
            List<Id> identifiiDocumentIdList = new List<Id>();
            for(ContentDocumentLink contentDocumentLinkInstance : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: app.Id]) {
                identifiiDocumentIdList.add(contentDocumentLinkInstance.ContentDocumentId);
            }
            if(identifiiDocumentIdList.isEmpty() == false) {
                for(ContentVersion contentVersionInstance : [
                    SELECT Id, Description, Title, VersionData 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :identifiiDocumentIdList 
                    AND Title IN ('KYC Documents Proof of Identity')
                    AND IsMajorVersion = true AND IsLatest = true 
                ]
                ) {
                    documentList.add(contentVersionInstance);
                }
            }
            Map<String, Blob> staticResourceBodies = new Map<String, Blob>();
            List<String> kfdLabels = new List<String>();
            if(app.AOB_Schema_Code__c == 'OD005'){
                if(app.AOB_Selected_Currency__c == 'UGX'){
                    kfdLabels.add('BCB_OD005UGXKFD');
                }
                else if(app.AOB_Selected_Currency__c == 'USD'){
                    kfdLabels.add('BCB_OD005USDKFD');
                }
            }
            else if(app.AOB_Schema_Code__c == 'CTRAD'){
                if(app.AOB_Selected_Currency__c == 'UGX'){
                    kfdLabels.add('BCB_CTRADUGXKFD');
                }
                else if(app.AOB_Selected_Currency__c == 'USD'){
                    kfdLabels.add('BCB_CTRADUSDKFD');
                }
            }
            List<StaticResource> staticResources = [SELECT Id, Name, Body FROM StaticResource WHERE Name IN :kfdLabels];
            for (StaticResource staticResource : staticResources) {
                staticResourceBodies.put(staticResource.Name, staticResource.Body);
            }
            for (String resourceName : staticResourceBodies.keySet()) {
                Blob resourceBlob = staticResourceBodies.get(resourceName);
                ContentVersion kfdVersion = new ContentVersion(
                    Title = 'Mandatory Central Bank documents Key facts document', 
                    Description = 'Mandatory Central Bank documents Key facts document', 
                    VersionData = resourceBlob
                );
                if (!Test.isRunningTest()) {
                    documentList.add(kfdVersion);
                }
            }
            
            dsxBean.agent   = 'A232337';
            dsxBean.country = 'UG'; 
            dsxBean.cif     = applicationPartRecord.AOB_CIFID__c;  
            List<BCB_DSXBean.Documents> dsxDocsList = new List<BCB_DSXBean.Documents>();
            for(ContentVersion document : documentList) {
            
                BCB_DSXBean.Documents dsxDocs = new BCB_DSXBean.Documents();
                dsxDocs.documentType  = documentAndKYCNameMap.containsKey(document.Title) ? documentAndKYCNameMap.get(document.Title) : document.Title;
                dsxDocs.name          = documentAndKYCNameMap.containsKey(document.Title) ? documentAndKYCNameMap.get(document.Title) : document.Title;

                if(document.Title == 'Signature File') {
                    dsxDocs.content   = String.valueOf(document.VersionData);
                } else if(document.Title == 'upload image of your national id'){
                    document.Description = 'KYC Documents Proof of Identity';
                    dsxDocs.documentExpiryDate = string.valueOf(app.AOB_Identifii_Expire_Date__c);
                    dsxDocs.content   = EncodingUtil.base64Encode(document.VersionData);
                  
                }else if(document.Title == 'KYC Documents Proof of Identity'){
                    document.Description = 'KYC Documents Proof of Identity';
                    dsxDocs.documentExpiryDate = string.valueOf(app.AOB_Identifii_Expire_Date__c);
                    dsxDocs.content   = EncodingUtil.base64Encode(document.VersionData);
                  
                }else {
                    dsxDocs.content   = EncodingUtil.base64Encode(document.VersionData);
                }
                dsxDocsList.add(dsxDocs);
            }
            dsxBean.Documents = dsxDocsList;
            Map<String, Object> apiResponseObject= makeDSXAPICallOut(dsxBean);
            return apiResponseObject;
        }else{
            
            return null;
        }
        
        
    }
    
    /** 
* @description This method used for makeDSXCallOut
* @param dsxBean
* @return Returns a callout response in map format for remaining processing
*/
    private static Map<String, Object> makeDSXAPICallOut(BCB_DSXBean dsxBean){
        
        CMN_WebserviceSetting__mdt webServiceSetting = AOB_APIHandler.webservices();
        NamedCredential namedCredentialRecord = AOB_APIHandler.credentials();
        String endpoint = namedCredentialRecord.Endpoint + PATH_CALLOUT;
        String fApiInteractionId = BCB_FlowController.createGUID();
        string bcbAccessToken = CMN_SRV_GetAccessToken.getAccessToken();
        Map<String, Object> responseToReturnObject = new Map<String, Object>();
        if(String.isNotBlank(bcbAccessToken) == true) {
            HttpRequest httpRequest = AOB_APIHandler.assignAccessToken(AUTHORIZATION_TYPE_BEARER, bcbAccessToken);
            httpRequest.setHeader(HEADER_ACCEPT, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CONTENT_TYPE, CONTENT_TYPE_APPLICATION_JSON);
            httpRequest.setHeader(HEADER_CLIENT_CERTIFICATE, webServiceSetting.CMN_AdditionalKey__c);
            httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
            httpRequest.setHeader(HEADER_CLIENT_ID, webServiceSetting.CMN_ClientID__c);
            httpRequest.setHeader(HEADER_CLIENT_SECRET, webServiceSetting.CMN_Client_Secret__c);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setMethod(HTTP_METHOD_POST);
            httpRequest.setBody(JSON.serialize(dsxBean));
            httpRequest.setTimeout(120000);
            try {
                Http http = new Http();
                HttpResponse httpResponse = new HttpResponse();
                
                if (System.Test.isRunningTest()) {
                    if(mockHttpStatusCode!=null && mockHttpStatus!=null){
                        BCB_HttpMockGenerator.setTestMockResponse(mockHttpStatusCode, mockHttpStatus, mockHttpBody);
                    }
                }
                httpResponse = http.Send(httpRequest);
                if(httpResponse.getStatusCode() == CMN_API_HttpBase.HTTP_OK) {
                    String responseBody = httpResponse.getBody();
                    if (responseBody != null) {
                        BCB_DSXBean.Response docsResponseWrapper = (BCB_DSXBean.Response) JSON.deserialize(responseBody, BCB_DSXBean.Response.class);
                        responseToReturnObject = responseParser(docsResponseWrapper,responseBody);
                    } else {
                        responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS', 'statusCode' => 200, 'ErrorDescription' => 'No response body'};
                            LOGGER.error('CMN_DSX.makeDSXCallOut:No response body',new String[] {'CMN_DSX.makeDSXCallOut'});
                        
                    }
                } else {
                    String errorMessage = 'No Response From Server';
                    String responseBody = httpResponse.getBody();
                    if(String.isNotBlank(responseBody) == true) {
                        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                        errorMessage = (String) responseObject.get('moreInformation');
                    }
                    responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'statusCode' => httpResponse.getStatusCode(), 'ErrorDescription' => errorMessage};
                        LOGGER.error('CMN_DSX.makeDSXCallOut:Response status:FAILED',new String[] {'CMN_DSX.makeDSXCallOut', JSON.serialize(responseToReturnObject)});
                }
            } catch (Exception ex) {
                LOGGER.error('CMN_DSX.makeDSXCallOut:Some Un-Handled Exception Occurred',new String[] {'CMN_DSX.makeDSXCallOut', ex.getMessage()});
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => ex.getMessage()};
                    }
        } else {
            LOGGER.error('CMN_DSX.makeDSXCallOut:Access Token Failure',new String[] {'CMN_DSX.makeDSXCallOut'});
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED', 'ErrorDescription' => 'Access Token Failure'};
                }
        
        return responseToReturnObject; 
    } 
     /** 
* @description This method used for responseParser
* @param docsResponseWrapper
* @param responseBody
* @return  Map<String, Object> Returns a callout response in map format for remaining processing
*/
    private static Map<String, Object> responseParser( BCB_DSXBean.Response docsResponseWrapper,string responseBody){
        Map<String, Object>   responseToReturnObject = new Map<String, Object>();
        
        if(docsResponseWrapper != null && docsResponseWrapper.documents.isEmpty() == false) {
            Boolean isOneDocumentSuccess = false;
            for(BCB_DSXBean.ResponseDocuments documentResponse : docsResponseWrapper.documents) {
                if(documentResponse.reasonCode == 'success') {
                    responseToReturnObject = new Map<String, Object>{'status' => 'SUCCESS'};
                        isOneDocumentSuccess = true;
                    if(Test.isRunningTest() == true) {
                        responseToReturnObject.put('statusCode', documentResponse.status);
                        responseToReturnObject.put('reasonDescription', documentResponse.reasonDescription);
                    }
                    break;
                }
            }
            responseToReturnObject.put('Response', responseBody);
            if(isOneDocumentSuccess == false) {
                responseToReturnObject = new Map<String, Object>{'status' => 'FAILED',
                    'ErrorDescription' => 'Your KYC documents could not be successfully uploaded!'
                    };
                        }
        } else {
            responseToReturnObject = new Map<String, Object>{'status' => 'FAILED',
                'ErrorDescription' => 'Your KYC documents could not be successfully uploaded!'
                };
                    }
        return responseToReturnObject;
    }
    
}