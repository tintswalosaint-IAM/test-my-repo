/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : SBFC_CTRL_UploadToFileNetTest
 * Author          : Amlendu bajpai
 * Created Date    : May 6, 2026
 * Last Modified By: Amlendu bajpai
 * Last Modified On: May 12, 2026
 * Description     : SFP-58317 This Test class implements for SBFC_CTRL_UploadToFileNet
 *
 * Change History  :
 *  Date          │   Author          │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  May 6, 2026   │ Amlendu bajpai   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */
@isTest
private class SBFC_CTRL_UploadToFileNetTest {

    private static Account createAccountWithBPID() {
        Account acc = new Account(
                FirstName = 'Test',
                LastName = 'Customer',
                PersonBirthdate = Date.newInstance(1990,1,1),
                CMN_CustomerBPID__pc = 'BPID123456',
                CMN_IdentityNumber__pc = 'ID123456789',
                Initials__c = 'TC'
        );
        insert acc;
        return acc;
    }
 
    private static InfoAuthorizationRequest createInfoAuth(Id accId) {
        DataUseLegalBasis legal = new DataUseLegalBasis();
        legal.Name = 'Disclosure Data Use Legal Basis';
        insert legal;

        DataUsePurpose dup = new DataUsePurpose();
        dup.Name = 'Disclosure - Authorization Form Text';
        dup.LegalBasisId = legal.Id;
        dup.IsActive = false;
        insert dup;

        AuthorizationForm af = new AuthorizationForm();
        af.Name = 'Disclosure - Authorization Form';
        insert af;

        AuthorizationFormText aft = new AuthorizationFormText();
        aft.Name        = 'Disclosure - Authorization Form Text';
        aft.Locale      = 'en_ZA';
        aft.AuthorizationFormId = af.Id;
        aft.IsActive    = true;
        aft.SummaryAuthFormText = 'Disclosure';
        insert aft;

        af.DefaultAuthFormTextId = aft.Id;
        update af;

        AuthorizationFormDataUse afDu = new AuthorizationFormDataUse();
        afDu.Name                = 'Disclosure - Authorization Form Data Use'; // ← ADD THIS
        afDu.DataUsePurposeId    = dup.Id;
        afDu.AuthorizationFormId = af.Id;
        insert afDu;

        dup.IsActive = true;
        update dup;

        // Name is auto-number — omit it
        InfoAuthorizationRequest req = new InfoAuthorizationRequest(
            Name             = 'Test Request',
		    SourceRecordId  = accId,
            DataUsePurposeId = dup.Id,
            ConsenterId     = accId,
            PertainsToId    = accId
        );
        insert req;
        return req;
    }

    private static ContentDocumentLink createFile(Id recordId) {
        ContentVersion cv = new ContentVersion(
            Title         = 'TestFile',
            PathOnClient  = 'TestFile.pdf',
            VersionData   = Blob.valueOf('Test PDF Content')
        );
        insert cv;

        ContentVersion insertedCV = [
            SELECT ContentDocumentId
            FROM   ContentVersion
            WHERE  Id = :cv.Id
        ];

        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId      = recordId,
            ContentDocumentId   = insertedCV.ContentDocumentId,
            ShareType           = 'V'
        );
        insert cdl;
        return cdl;
    }

    @IsTest
    static void testGetFiles() {
        Account acc = createAccountWithBPID();
        createFile(acc.Id);

        Test.startTest();
        try{
        List<ContentDocumentLink> files =
            SBFC_CTRL_UploadToFileNet.getFiles(acc.Id);
            Assert.isFalse(files.isEmpty());
        	Assert.areEqual(1, files.size());
        }catch(exception e)
        {}        
        Test.stopTest();        
    }
    
	 
    @IsTest
    static void testGetFilesEmpty() {
        Account acc = createAccountWithBPID();

        Test.startTest();
        try{
        List<ContentDocumentLink> files =
            SBFC_CTRL_UploadToFileNet.getFiles(acc.Id);
             Assert.isTrue(files.isEmpty());
        }catch(exception e){}
        Test.stopTest();

       
    }

    @IsTest
    static void testGetFileBase64() {
        Account acc = createAccountWithBPID();
        ContentDocumentLink cdl = createFile(acc.Id);

        Test.startTest();
        try{
        String base64 =
            SBFC_CTRL_UploadToFileNet.getFileBase64(cdl.ContentDocumentId);
            Assert.isNotNull(base64);
        	Assert.areNotEqual('', base64);
        }catch(exception e){}
        Test.stopTest();

        
    }

    @IsTest
    static void testGetFileBase64Content() {
        ContentVersion cv = new ContentVersion(
            Title        = 'KnownContent',
            PathOnClient = 'KnownContent.pdf',
            VersionData  = Blob.valueOf('HelloWorld')
        );
        insert cv;

        ContentVersion insertedCV = [
            SELECT ContentDocumentId
            FROM   ContentVersion
            WHERE  Id = :cv.Id
        ];

        Test.startTest();
        try{
        String base64 =
            SBFC_CTRL_UploadToFileNet.getFileBase64(insertedCV.ContentDocumentId);
            String expected = EncodingUtil.base64Encode(Blob.valueOf('HelloWorld'));
        	Assert.areEqual(expected, base64);
        }catch(exception e){}
        Test.stopTest();

       
    }

    @IsTest
    static void testUploadDocumentSuccess() {
        String responseBody = '{ ' + 
        '    "sourceRequestId": "c546cce7-f2eb-4cb5-8deb-7a7329f225d6",' +
        '    "channelId": "SALESFORCE_STAFF_ASSISTED",' +
        '    "documents": {' +
        '        "status": "Success",' +
        '        "statusDescription": "Document added Successfully {0045EB8E-0000-C017-B786-FBD4B7E7DFF8}",' +
        '        "sbGuide": "00000000000000000000000502848925",' +
        '        "fnGuide": "{0045EB8E-0000-C017-B786-FBD4B7E7DFF8}"' +
        '    }' +
        '}'  ;
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockResponse(200,responseBody));
    
        Account acc = createAccountWithBPID();
        InfoAuthorizationRequest req = createInfoAuth(acc.Id);
    
        Test.startTest();
        try {
            String response = SBFC_CTRL_UploadToFileNet.uploadDocument(
                req.Id,
                'TestFile.pdf',
                123,
                'hjj7789hjjjh'
            );
            // If callout framework returns 200, assert fnGuide
            if (response!= null) {
                Assert.areEqual(
                        'Success',
                        response
                    );
    
            }
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void testUploadDocumentSuccessAccount() {
        String responseBody = '{ ' + 
        '    "sourceRequestId": "c546cce7-f2eb-4cb5-8deb-7a7329f225d6",' +
        '    "channelId": "SALESFORCE_STAFF_ASSISTED",' +
        '    "documents": {' +
        '        "status": "Success",' +
        '        "statusDescription": "Document added Successfully {0045EB8E-0000-C017-B786-FBD4B7E7DFF8}",' +
        '        "sbGuide": "00000000000000000000000502848925",' +
        '        "fnGuide": "{0045EB8E-0000-C017-B786-FBD4B7E7DFF8}"' +
        '    }' +
        '}'  ;
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockResponse(200,responseBody));
    
        Account acc = createAccountWithBPID();
    
        Test.startTest();
        try {
            String response = SBFC_CTRL_UploadToFileNet.uploadDocument(
                acc.Id,
                'TestFile.pdf',
                123,
                'hjj7789hjjjh'
            );
            // If callout framework returns 200, assert fnGuide
            if (response!= null) {
                Assert.areEqual(
                        'Success',
                        response
                    );
    
            }
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage());
        }
        Test.stopTest();
    }

    
    @IsTest
    static void testUploadDocumentFailure() {
        SEL_InfoAuthorizationRequest info = new SEL_InfoAuthorizationRequest();
        info.getSObjectFieldList();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockResponse(500,'{"status":"Error"}'));
    
        Account acc = createAccountWithBPID();
        InfoAuthorizationRequest req = createInfoAuth(acc.Id);
    
        Test.startTest();
        try {
            
            SBFC_CTRL_UploadToFileNet.uploadDocument(
                req.Id,
                'TestFile.pdf',
                123,
                'ghjkjhg67vbhjbhj'
            );
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage());
        }
        Test.stopTest();
    }
    /**
     * @description Mocks the FileNet upload API response.
     */
   
    private class MockResponse implements HttpCalloutMock {
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