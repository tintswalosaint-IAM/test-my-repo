/**
 * @description       : This class is used to call the ESB API for processing documents. 
				        It handles the extraction of document details from Salesforce, prepares the payload, 
				        and makes a callout to the external API. The response from the API is processed to return a global document ID.
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 10-08-2024
 * @last modified by  : Jaco de Lange
**/
public class CMN_DocumentManagement{
    /**
    * @description wrapper method to upload documents to CDN
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    * @param string requests in a serialized format
    * @return String response from the CDN system. in serialized format
    **/
    @AuraEnabled
    public static String documentUpload (String requests, String claimId){
        List<Claim> claims = new SEL_Claim().selectClaimById(claimId);

        if(claims.size() > 0){
            List<DocumentRequest> documemntUploads = new List<DocumentRequest>();
            if (claims.get(0).FileNet_Request_Payload__c != null){
                documemntUploads = (List<DocumentRequest>)JSON.deserialize(claims.get(0).FileNet_Request_Payload__c, List<DocumentRequest>.class);
            }          
            documemntUploads.addAll((List<DocumentRequest>)JSON.deserialize(requests,List<DocumentRequest>.class));

            Map<Id,DocumentRequest> mapDoc = new Map<Id,DocumentRequest>();
                for (DocumentRequest docReq : documemntUploads){
                    mapDoc.put (docReq.contentVersionId, docReq);
                }
                List<DocumentRequest> documemntUploadsNew = mapDoc.values();

            Claim claim = new Claim();
            claim.id = claimId;
            claim.FileNet_Request_Payload__c = JSON.serialize(documemntUploadsNew);
            update claim;
        }
        return requests;
    }
    /**
    * @description Invocable method to be utilized from screen flows for uploading documents where necessary
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    * @param List<DocumentRequest> requests in a serialized format 
    * @return List<DocumentResponse> response from the CDN system
    * @lastModifiedBy Maham Hassan
    **/
    @InvocableMethod(label='CMN Document Upload' description='Processes a document and returns a global document ID for multiple countries')
    public static void commonDocumentUpload(List<String> requestPayloads){
        fileNetAPICallout(requestPayloads[0]);
    }

    @future(callout = true)
    public static void fileNetAPICallout(String requestPayload){

        List<DocumentRequest> requests = (List<DocumentRequest>)JSON.deserialize(requestPayload, List<DocumentRequest>.class);
        List<DocumentResponse> responses = new List<DocumentResponse>();
        List<String> docIds = new List<String>();
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        String claimId;
        for (DocumentRequest request : requests) {
            docIds.add(request.contentVersionId);
            claimId = request.relatedRecordId;
        }

        ClaimInformation claimRecord = getClaimInformation(claimId);
        Map<Id,ContentVersion> docDetails = fetchDocumentData(docIds);       
        
        for(DocumentRequest request : requests){       
            for (DocumentIdentification docIdentification: request.DocumentIdentification){
                if (docIdentification.documentIdentificationType == 'ClaimNumber') {
                    docIdentification.documentIdentificationValue = claimRecord.claimNumber;
                }
            }

            if (docDetails.get(request.contentVersionId) != null){

                DocumentDirectoryReq apiPayload = prepareApiPayload(request, docDetails.get(request.contentVersionId)?.VersionData);

                docDetails.remove(request.contentVersionId);
               
                String globalDocumentId = makeApiCallout(apiPayload);
                
                apiPayload = null;

                ContentVersion cv = new ContentVersion();
                cv.id = request.contentVersionId;
                cv.INS_Document_Link__c = globalDocumentId;
                contentVersions.add(cv);

                DocumentResponse response = new DocumentResponse();
                response.globalDocumentId = globalDocumentId;
                responses.add(response);     
            }
        }

        docIds.clear();
        requests.clear();

        if(contentVersions.size() > 0){
            update contentVersions;
        }
    }
    
    /**
    * @description Method to prepare the API payload
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    * @param DocumentRequest request 
    * @param blob fileData 
    * @return DocumentDirectoryReq 
    **/
    private static DocumentDirectoryReq prepareApiPayload(DocumentRequest request,blob fileData) {
        DocumentDirectoryReq payload = new DocumentDirectoryReq();
        payload.DocumentIdentification = request.DocumentIdentification;
		payload.DocumentName=request.name;
        payload.DocumentType=request.mimeType;

        if(!Test.isRunningTest()){
        	payload.DocumentStream=EncodingUtil.base64Encode(fileData);
        }
        return payload;
    }
    
    /**
    * @description Method to fetch the document details from Content Version
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    * @param list<String> docIds 
    * @return Map<Id, ContentVersion> Content Version details for the input record list
    **/
    private static Map<Id,ContentVersion> fetchDocumentData(list<String> docIds){
		Map<Id,ContentVersion> retVal = new Map<Id,ContentVersion>();
        List<ContentVersion> cvList = new List<ContentVersion>();

        cvList = new SEL_CMN_ContentVersion().selectCVByIds(docIds);
        retVal = new Map<Id,ContentVersion>(cvList);
        return retVal;
    }

    /**
    * @description Method to initiate the API call from SF system for the CDN
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    * @param DocumentDirectoryReq apiPayload 
    * @return String Serialized document directory id
    **/
    private static String makeApiCallout(DocumentDirectoryReq apiPayload){
        String globalDocumentId = '';
        CMN_DocUpload_API customerServiceCall = new CMN_DocUpload_API(JSON.serialize(apiPayload));
        CMN_WebserviceCallQueue__c obWebSvcQueue=CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_DocUpload_API.SERVICE_NAME);
        
        //Process the web service with the prepared api payload
        customerServiceCall.process(obWebSvcQueue);

        Integer responseCode= customerServiceCall.getResponseStatusCode();
        Map<String,Object> responseJSON=(Map<String,Object>)JSON.deserializeuntyped(customerServiceCall.getResponseBody());

        if(responseCode == 200){
            //Fetch DocumentDirectoryId from the response of the wbe service call to be returned back to the invoked method
            Map<String,Object> ddResponseJSON = (Map<String,Object>)responseJSON.get('DocumentDirectoryResponse');
            globalDocumentId=(String)ddResponseJSON.get('DocumentDirectoryId');
        }
        return globalDocumentId;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<DocumentFileNetConfiguration> getFileNetConfigurations(){
        try 
        {
                List<DocumentFileNetConfiguration> documentFileNetConfigurations = new List<DocumentFileNetConfiguration>();
                List<Document_Upload_Configuration__mdt> fileNetConfigurationRecords = Document_Upload_Configuration__mdt.getAll().values();
                for (Document_Upload_Configuration__mdt fileNetConfigurationRecord: fileNetConfigurationRecords) {
                    DocumentFileNetConfiguration docFileNetConfig = new DocumentFileNetConfiguration();
                    docFileNetConfig.bpId = fileNetConfigurationRecord.BPID__c;
                    docFileNetConfig.claimDocumentName = fileNetConfigurationRecord.Claim_Document_Name__c;
                    docFileNetConfig.labelName = fileNetConfigurationRecord.MasterLabel;
                    docFileNetConfig.entityType = fileNetConfigurationRecord.Entity_Type__c;
                    docFileNetConfig.documentTypeCode = fileNetConfigurationRecord.Document_Type_Id__c;
                    docFileNetConfig.paramsToExclude = fileNetConfigurationRecord.Params_to_Exclude__c;
                    documentFileNetConfigurations.add(docFileNetConfig);
                }
                return documentFileNetConfigurations;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ClaimInformation getClaimInformation(String claimId){
        ClaimInformation claimInfo = new ClaimInformation();
        try 
        {
                List<Claim> claims = new SEL_Claim().selectClaimById(claimId);
                if (claims.size() > 0){
                    claimInfo.claimNumber = claims.get(0).Name;
                    claimInfo.insurancePolicyNumber = claims.get(0).PolicyNumber.Name;
                    claimInfo.accountBPID = claims.get(0).Account.CMN_CustomerBPID__pc;
                }
                return claimInfo;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) +
            '-' +
            h.SubString(8, 12) +
            '-' +
            h.SubString(12, 16) +
            '-' +
            h.SubString(16, 20) +
            '-' +
            h.subString(20);
    }
    public class DocumentRequest {
        @InvocableVariable
        public String name;
        @InvocableVariable
        public String type;
        @InvocableVariable
        public String mimeType;
        @InvocableVariable
        public String actualFile;
        @InvocableVariable
        public String contentVersionId;
        @InvocableVariable
        public String relatedRecordId;
        @InvocableVariable
        public String country;
        @InvocableVariable
        public String documentType;
        @InvocableVariable
        public List<CMN_DocumentManagement.DocumentIdentification> documentIdentification;
    }
    public class DocumentResponse {
        @InvocableVariable
        public String globalDocumentId;
    }
    public class DocumentDirectoryReq {
        public List<CMN_DocumentManagement.DocumentIdentification> DocumentIdentification;
        public String DocumentName;
        public String DocumentType;
        public String DocumentStream;
    }
    public class DocumentIdentification {
        @InvocableVariable
		public String DocumentIdentificationType;
        @InvocableVariable
		public String DocumentIdentificationValue;
	}
    public class DocumentFileNetConfiguration {
        @AuraEnabled
        public String bpId;
        @AuraEnabled
        public String claimDocumentName;
        @AuraEnabled
        public String labelName;
        @AuraEnabled
        public String entityType;
        @AuraEnabled
        public String documentTypeCode;
        @AuraEnabled
        public String paramsToExclude;
    }
    public class ClaimInformation {
        @AuraEnabled
        public String claimNumber;
        @AuraEnabled
        public String insurancePolicyNumber;
        @AuraEnabled
        public String accountBPID;
    }
}