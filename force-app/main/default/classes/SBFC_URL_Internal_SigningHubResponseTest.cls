/**
* @File Name : SBFC_URL_Internal_SigningHubResponse.cls
* @Description : SFP-54443 - Test class for SBFC_URL_Internal_SigningHubResponse
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
private class SBFC_URL_Internal_SigningHubResponseTest {

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
                DataUsePurposeId=purpose.Id,
                SBFC_SigningHub_Document_Number__c='12345'
            );

        insert req;
    }

    @IsTest
    static void testApprovedCallback() {

        String pdfBase64 =
            EncodingUtil.base64Encode(
                Blob.valueOf('Dummy PDF')
            );

        RestRequest req = new RestRequest();
        req.requestUri =
            '/services/apexrest/v1/uosigningHubResponse/';
        req.httpMethod = 'PUT';

        req.requestBody = Blob.valueOf(
        '{' +
        '"packageId":"111",' +
        '"documentId":"12345",' +
        '"clientResponse":"APPROVED",' +
        '"signeddocContent":"' + pdfBase64 + '",' +
        '"auditLogContent":"' + pdfBase64 + '"' +
        '}');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();

        SBFC_URL_Internal_SigningHubResponse.upsertSignHubResponse();

        Test.stopTest();

        InfoAuthorizationRequest auth = [
            SELECT Id,
                   ResponseStatus
            FROM InfoAuthorizationRequest
            WHERE SBFC_SigningHub_Document_Number__c='12345'
            LIMIT 1
        ];

        Assert.areEqual('Signed', auth.ResponseStatus,'status should be signed');

        List<ContentDocumentLink> links = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId=:auth.Id
        ];

        Assert.areEqual(
        2,
        links.size(),
        'Two files should be uploaded.'
    );

        List<FeedItem> posts = [
            SELECT Id
            FROM FeedItem
            WHERE ParentId=:auth.Id
        ];

        Assert.areEqual(
        2,
        posts.size()
    );
    }

    @IsTest
    static void testDeclinedCallback() {

        RestRequest req = new RestRequest();
        req.requestUri =
            '/services/apexrest/v1/uosigningHubResponse/';
        req.httpMethod = 'PUT';

        req.requestBody = Blob.valueOf(
        '{' +
        '"documentId":"12345",' +
        '"clientResponse":"DECLINED"' +
        '}');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();

        SBFC_URL_Internal_SigningHubResponse.upsertSignHubResponse();

        Test.stopTest();

        InfoAuthorizationRequest auth = [
            SELECT ResponseStatus
            FROM InfoAuthorizationRequest
            WHERE SBFC_SigningHub_Document_Number__c='12345'
            LIMIT 1
        ];

        Assert.areEqual(
        'Rejected',
        auth.ResponseStatus,
        'status should be Rejected'
    );
    }

    @IsTest
    static void testDocumentNotFound() {

        RestRequest req = new RestRequest();
        req.requestUri =
            '/services/apexrest/v1/uosigningHubResponse/';
        req.httpMethod = 'PUT';

        req.requestBody = Blob.valueOf(
        '{' +
        '"documentId":"99999",' +
        '"clientResponse":"APPROVED"' +
        '}');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();

        SBFC_URL_Internal_SigningHubResponse.upsertSignHubResponse();

        Test.stopTest();

        Assert.isTrue(true);
    }

    @IsTest
    static void testBlankDocumentId() {

        RestRequest req = new RestRequest();
        req.requestUri =
            '/services/apexrest/v1/uosigningHubResponse/';
        req.httpMethod = 'PUT';

        req.requestBody = Blob.valueOf(
        '{' +
        '"clientResponse":"APPROVED"' +
        '}');

        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();

        SBFC_URL_Internal_SigningHubResponse.upsertSignHubResponse();

        Test.stopTest();

        Assert.isTrue(true);
    }
}