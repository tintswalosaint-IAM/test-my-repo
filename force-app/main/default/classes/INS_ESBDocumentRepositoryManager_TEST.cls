/**
 * @description : Test class for INS_API_ESBDocumentRepositoryManager
 * @author : Jaco de Lange
 * @last modified on : 11-11-2024
**/
@isTest
public class INS_ESBDocumentRepositoryManager_TEST {
    @isTest
    public static void sendDoc() {
        INS_UTIL_File testFile = new INS_UTIL_File();
        INS_API_ESBDocumentRepositoryManager esbDM = new INS_API_ESBDocumentRepositoryManager();
        ContentVersion cv = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id);
        Claim cl = INS_DocumentManagementTestFactory_TEST.createClaim();
        testFile.setRecordId(cl.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        esbDM.setFile(testFile.setFile(cv));
        esbDM.send();
        Test.stopTest();
        Assert.areEqual('doc upload', cv.Title, 'matching content');
        Assert.areEqual('TestClaim', cl.Name, 'matching claim');
    }
    @isTest
    public static void sendDocFail() {
        INS_UTIL_File testFile = new INS_UTIL_File();
        INS_API_ESBDocumentRepositoryManager esbDM = new INS_API_ESBDocumentRepositoryManager();
        ContentVersion cv = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id);
        Claim cl = INS_DocumentManagementTestFactory_TEST.createClaim();
        testFile.setRecordId(cl.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFail());
        esbDM.getTaxonomies();
        esbDM.setFile(testFile.setFile(cv));
        esbDM.send();
        Test.stopTest();
        Assert.areEqual('doc upload', cv.Title, 'matching content');
        Assert.areEqual('TestClaim', cl.Name, 'matching claim');
    }

    public class MockHttpResponseGeneratorSuccess implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"DocumentDirectoryResponse": {"DocumentDirectoryId": "idd_90AB4591-0000-CD15-B22E-B71BC8A601A0"}}');
            return res;
        }
    }

    public class MockHttpResponseGeneratorFail implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('FAIL');
            res.setStatusCode(401);
            res.setBody('{"httpCode": "404","httpMessage": "Not Found"}');
            return res;
        }
    }
}