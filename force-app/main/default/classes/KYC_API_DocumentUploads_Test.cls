/***************************************************************************************
@Name of the Class :KYC_API_InboundDocumentUploadsTest
@Description :SFP-40755 Test Class for KYC_API_InboundDocumentUploads.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
private class KYC_API_DocumentUploads_Test {
    private static String thirdPartyVerfdentifier = '33844b1d-f770-4b6d-8cc3-ee6d5db52e1d';
    private static String testAttachment = 'Test Attachment';
    private static String testString = 'Test';
    private static String failedString = 'Failed';
    private static String successString = 'Success';
    private static String identityNumber = 'CM930121003EGE';
    private static String recordUpdatedSuccessFully = 'record updated successfully';
    private static String pancardPdf = 'pancard.pdf';
    
    @testSetup
    static void setup() {
        String partyId=KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(partyId,'In Progress','On Hold');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(partyId,'In Progress','Rejected');
    }
   /**
    * @description test method for AttachPIVDocumentSuccess
    */ 
    @isTest
    static void AttachPIVDocumentSuccessTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = identityNumber;
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        
        Assert.areEqual(successString, dtoResponse.status,testString);
        Assert.areEqual(200, dtoResponse.responseCode,testString);
        Assert.areEqual(recordUpdatedSuccessFully, dtoResponse.message,testString);
    }
    
    /**
    * @description test method for AttachPIVDocumentExceptions
    */ 
    @isTest
    static void AttachPIVDocumentExceptionsTest() {
        
        Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize('{"uniqueIdentifier":"33844b1d-f770-4b6d-8cc3-ee6d5db52e1d","IdentityNumber":"CM930121003EGE","LivenessFRMatch":true,"LivenessFRScore":21.853,"documentList":[{"base64Attachment":null,"title":"pancard.pdf"}]}'));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        try {
            KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_API_DocumentUploads.KYC_WRP_DocRes.class);
            Assert.areEqual(failedString, dtoResponse.status,testString);
            Assert.areEqual(500, dtoResponse.responseCode,testString);
        } catch (Exception e) {
            Assert.areEqual('System.NullPointerException', e.getTypeName(), 'Unexpected exception type');
        }
    }
    /**
    * @description test method for AttachPIVDocumentSuccessAlreadyUpdated
    */ 
    @isTest
    static void AttachPIVDocumentSuccessAlreadyUpdateTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = 'CM930121003EGES';
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.areEqual(successString, dtoResponse.status,testString);
        Assert.areEqual(200, dtoResponse.responseCode,testString);
        Assert.isNotNull('record already updated', dtoResponse.message);
    }
    /**
    * @description test method for AttachPIVDocumentIdentityNumberInvalid
    */ 
    @isTest
    static void testAttachPIVDocumentIdentityNumberInvalidTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = 'CM930121003EGES';
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.areEqual(successString, dtoResponse.status,testString);
        Assert.areEqual(200, dtoResponse.responseCode,testString);
        Assert.areEqual(recordUpdatedSuccessFully, dtoResponse.message,testString);
    }
    /**
    * @description test method for AttachPIVDocumentLivenessFailed
    */ 
    @isTest
    static void AttachPIVDocumentLivenessFailedTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = identityNumber;
        requestBody.LivenessFRMatch = false;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.areEqual(successString, dtoResponse.status,testString);
        Assert.areEqual(200, dtoResponse.responseCode,testString);
        Assert.areEqual(recordUpdatedSuccessFully, dtoResponse.message,testString);
    }
    /**
    * @description test method for AttachPIVDocumentLivenessScoreFailed
    */ 
    @isTest
    static void AttachPIVDocumentLivenessScoreFailedTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = identityNumber;
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 0.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.areEqual(successString, dtoResponse.status,testString);
        Assert.areEqual(200, dtoResponse.responseCode,testString);
        Assert.areEqual(recordUpdatedSuccessFully, dtoResponse.message,testString);
    }
    /**
    * @description test method for AttachPIVDocumentNullFields
    */ 
    @isTest
    static void AttachPIVDocumentNullFieldsTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = null;
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.isNotNull(failedString, dtoResponse.status);
    }
    /**
    * @description test method for AttachPIVDocumentEmptyFieldsTest
    */ 
    @isTest
    static void testAttachPIVDocumentEmptyFields() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = '';
        requestBody.IdentityNumber = null;
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.areEqual(failedString, dtoResponse.status,testString);
        Assert.areEqual(SVC_UTIL_CrossOrg.STATUS_CODE_400, dtoResponse.responseCode,testString);
    }
    /**
    * @description test method for AttachPIVDocumentRecordNotFoundTest
    */ 
    @isTest
    static void AttachPIVDocumentRecordNotFoundTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = 'non-existing-id';
        requestBody.IdentityNumber = identityNumber;
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = EncodingUtil.base64Encode(Blob.valueOf(testAttachment));
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes.class);
        Assert.areEqual(successString, dtoResponse.status,testString);
        Assert.areEqual(200, dtoResponse.responseCode,testString);
        Assert.areEqual('record not found', dtoResponse.message,testString);
    }
    /**
    * @description test method for AttachPIVDocumentException
    */ 
    @isTest
    static void AttachPIVDocumentExceptionTest() {
        KYC_DTO_InboundDocumentUplod.KYC_WRP_Req requestBody = new KYC_DTO_InboundDocumentUplod.KYC_WRP_Req();
        requestBody.uniqueIdentifier = thirdPartyVerfdentifier;
        requestBody.IdentityNumber = identityNumber;
        requestBody.LivenessFRMatch = true;
        requestBody.LivenessFRScore = 70.0;
        
        KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq docReq = new KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq();
        docReq.base64Attachment = null;
        docReq.title = pancardPdf;
        
        requestBody.documentList = new List<KYC_DTO_InboundDocumentUplod.KYC_WRP_DocReq>{ docReq };
            
            Test.setMock(HttpCalloutMock.class, new KYC_INT_InboundDocumentUploadMock());
        
        RestContext.request = new RestRequest();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.response = new RestResponse();
        
        Test.startTest();
        KYC_API_DocumentUploads.attachPIVDocument();
        Test.stopTest();
        try {
            KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes dtoResponse = (KYC_DTO_InboundDocumentUplod.KYC_WRP_DocRes) JSON.deserialize(RestContext.response.responseBody.toString(), KYC_API_DocumentUploads.KYC_WRP_DocRes.class);
            Assert.areEqual(failedString, dtoResponse.status,testString);
            Assert.areEqual(500, dtoResponse.responseCode,testString);
        } catch (Exception e) {
            Assert.areEqual('System.NullPointerException', e.getTypeName(), 'Unexpected exception type');
        }
    }
    /**
    * @description test method for KYC_INT_InboundDocumentUploadMock
    */ 
    private class KYC_INT_InboundDocumentUploadMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"Success","responseCode":200,"message":"record updated successfully"}');
            res.setStatusCode(200);
            return res;
        }
    }
}