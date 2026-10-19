/**
* @File Name : SBFC_API_SendToSigningHubTest.cls
* @Description : SFP-54443 - Test class for SBFC_API_SendToSigningHub
* @Author : Amlendu Bajpai
* @Last Modified By : Amlendu Bajpai
* @Last Modified On : Jun 11, 2026
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 11, 2025 |   | Initial Version
**/

@IsTest
public class SBFC_API_SendToSigningHubTest {

    @testSetup
    static void setupData() {

        Account acc = new Account(
            LastName = 'Test Person',
            PersonEmail = 'test@test.com'
        );
        insert acc;

        DataUseLegalBasis legal = new DataUseLegalBasis(
            Name = 'Legal Basis'
        );
        insert legal;

        DataUsePurpose purpose = new DataUsePurpose(
            Name = 'Purpose',
            LegalBasisId = legal.Id,
            IsActive = false
        );
        insert purpose;
        purpose.IsActive =true;
       // update purpose;

        AuthorizationForm form = new AuthorizationForm(
            Name='Form'
        );
        insert form;

        AuthorizationFormText aft = new AuthorizationFormText(
            Name='Form Text',
            Locale='en_ZA',
            AuthorizationFormId=form.Id,
            IsActive=true,
            SummaryAuthFormText='Disclosure'
        );
        insert aft;

        form.DefaultAuthFormTextId = aft.Id;
        update form;

        AuthorizationFormDataUse afdu =
            new AuthorizationFormDataUse(
                Name='Data Use',
                AuthorizationFormId=form.Id,
                DataUsePurposeId=purpose.Id
            );
        insert afdu;
        update purpose;

        InfoAuthorizationRequest req =
            new InfoAuthorizationRequest(
                Name='Test',
                SourceRecordId=acc.Id,
                ConsenterId=acc.Id,
                PertainsToId=acc.Id,
                DataUsePurposeId=purpose.Id
            );

        insert req;
    }

    @IsTest
    static void testSendDocumentSuccess() {

        InfoAuthorizationRequest auth = [
            SELECT Id
            FROM InfoAuthorizationRequest
            LIMIT 1
        ];

        SBFC_DTO_DocumentManagement.DTO_ApplicationDocument doc =
            new SBFC_DTO_DocumentManagement.DTO_ApplicationDocument();

        doc.contentStream =
            EncodingUtil.base64Encode(
                Blob.valueOf('Dummy PDF')
            );

        String json =
            JSON.serialize(
                new List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument>{doc}
            );
           String responseBody = '{' +
        '"packageId":"25423",' +
        '"clientResponse":"UPLOADED",' +
        '"uploadDocumentResponses":[{"documentId":"34975","addSignatureFieldResponses":[]}],' +
        '"addSignerToWorkFlowResponse":{"status":"success","statusDescription":"success"},' +
        '"shareDocumentResponses":[{"packageId":"25423","documents":["34975"]}]' +
        '}';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockResponse(200,responseBody));

        Test.startTest();

        SBFC_CTRL_SendToSigningHub.SBFC_DTO_Response response =
            SBFC_CTRL_SendToSigningHub.sendDocument(
                auth.Id,
                json
            );

        Test.stopTest();

        Assert.areEqual(
            'SUCCESS',
            response.status
        );

        Assert.areEqual(
            'Document sent successfully',
            response.message
        );

        CMN_WebserviceCallQueue__c queue = [
            SELECT Id,
                   CMN_Status__c
            FROM CMN_WebserviceCallQueue__c
            LIMIT 1
        ];
		
        InfoAuthorizationRequest authReq = [
            SELECT Id,SBFC_SigningHub_Document_Number__c
            FROM InfoAuthorizationRequest
            LIMIT 1
        ];
        Assert.isNotNull(authReq.SBFC_SigningHub_Document_Number__c);
        Assert.isNotNull(queue);

    }
    @IsTest
    static void testSendDocumentSuccessAccount() {

        Account auth = [
            SELECT Id
            FROM Account
            LIMIT 1
        ];

        SBFC_DTO_DocumentManagement.DTO_ApplicationDocument doc =
            new SBFC_DTO_DocumentManagement.DTO_ApplicationDocument();

        doc.contentStream =
            EncodingUtil.base64Encode(
                Blob.valueOf('Dummy PDF')
            );

        String json =
            JSON.serialize(
                new List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument>{doc}
            );
           String responseBody = '{' +
        '"packageId":"25423",' +
        '"clientResponse":"UPLOADED",' +
        '"uploadDocumentResponses":[{"documentId":"34975","addSignatureFieldResponses":[]}],' +
        '"addSignerToWorkFlowResponse":{"status":"success","statusDescription":"success"},' +
        '"shareDocumentResponses":[{"packageId":"25423","documents":["34975"]}]' +
        '}';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockResponse(200,responseBody));

        Test.startTest();

        SBFC_CTRL_SendToSigningHub.SBFC_DTO_Response response =
            SBFC_CTRL_SendToSigningHub.sendDocument(
                auth.Id,
                json
            );

        Test.stopTest();

        Assert.areEqual(
            'SUCCESS',
            response.status
        );

        Assert.areEqual(
            'Document sent successfully',
            response.message
        );

        CMN_WebserviceCallQueue__c queue = [
            SELECT Id,
                   CMN_Status__c
            FROM CMN_WebserviceCallQueue__c
            LIMIT 1
        ];
		
        InfoAuthorizationRequest authReq = [
            SELECT Id,SBFC_SigningHub_Document_Number__c
            FROM InfoAuthorizationRequest
            LIMIT 1
        ];
        Assert.isNotNull(authReq.SBFC_SigningHub_Document_Number__c);
        Assert.isNotNull(queue);

    }
    @IsTest
    static void testSendDocumentFailure() {

        InfoAuthorizationRequest auth = [
            SELECT Id
            FROM InfoAuthorizationRequest
            LIMIT 1
        ];

        SBFC_DTO_DocumentManagement.DTO_ApplicationDocument doc =
            new SBFC_DTO_DocumentManagement.DTO_ApplicationDocument();

        doc.contentStream =
            EncodingUtil.base64Encode(
                Blob.valueOf('Dummy PDF')
            );

        String json =
            JSON.serialize(
                new List<SBFC_DTO_DocumentManagement.DTO_ApplicationDocument>{doc}
            );
           String responseBody = '{' +
        '"packageId":"",' +
        '"clientResponse":"FAILED",' +
        '"uploadDocumentResponses":[{"documentId":"","addSignatureFieldResponses":[]}],' +
        '"addSignerToWorkFlowResponse":{"status":"fail","statusDescription":"fail"},' +
        '"shareDocumentResponses":[{"packageId":"","documents":[""]}]' +
        '}';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockResponse(500,responseBody));

        Test.startTest();

        SBFC_CTRL_SendToSigningHub.SBFC_DTO_Response response =
            SBFC_CTRL_SendToSigningHub.sendDocument(
                auth.Id,
                json
            );

        Test.stopTest();

        Assert.areEqual(
            'FAILED',
            response.status
        );

        Assert.areEqual(
            'Error : API failed try again',
            response.message
        );

        CMN_WebserviceCallQueue__c queue = [
            SELECT Id,
                   CMN_Status__c
            FROM CMN_WebserviceCallQueue__c
            LIMIT 1
        ];
        InfoAuthorizationRequest authReq = [
            SELECT Id,SBFC_SigningHub_Document_Number__c
            FROM InfoAuthorizationRequest
            LIMIT 1
        ];
        Assert.isNull(authReq.SBFC_SigningHub_Document_Number__c);

        Assert.isNotNull(queue);

    }
    @IsTest
    static void testSendDocumentException() {
        Test.startTest();

        SBFC_CTRL_SendToSigningHub.SBFC_DTO_Response response =
            SBFC_CTRL_SendToSigningHub.sendDocument(
                null,
                null
            );

        Test.stopTest();
    }

    /**
     * @description Mocks the FileNet upload API response.
     */
   
    public class MockResponse implements HttpCalloutMock {
        private final Integer statusCode;
        private final String responseBody;
        /**
         * @description Constructor 
         * @param statuscode and responsebody
         * */
        public MockResponse(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }
        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setBody(responseBody);
            return response;
        }
    }

}