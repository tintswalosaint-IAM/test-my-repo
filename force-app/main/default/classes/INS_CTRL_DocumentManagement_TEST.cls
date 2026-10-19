/**
 * @description : Test class for INS_CTRL_DocumentManagement
 *
 * @last modified on : 11-11-2024
 *
**/
@isTest
public class INS_CTRL_DocumentManagement_TEST {

    private final static string CASEOBJ = 'Case';

    @isTest
    static Void testHasAccessToDocumentManagment() {
        PermissionSet documentPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Custom_Document_Upload_Access'];
        insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = documentPermSet.Id);
        Test.startTest();
        Boolean hasAccess = INS_CTRL_DocumentManagement.hasAccessToDocumentManagment();
        Test.stopTest();
        Assert.areEqual(true, hasAccess, 'Should have access to INS_CTRL_DocumentManagement');
    }

    @isTest
    static Void testGetRelatedRecords() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id
        );
        version.FirstPublishLocationId = claim.Id;
        insert version;
        Test.startTest();
        List<INS_UTIL_File> files = INS_CTRL_DocumentManagement.getRelatedDocuments(claim.Id);
        Test.stopTest();
        Assert.areEqual(1, files.size(), 'No files found!');
    }

    @isTest
    static Void testGetRelatedObjectRecordsClaim() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        Case c = INS_DocumentManagementTestFactory_TEST.createCaseWithClaim(claim.Id);
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id);

        version.FirstPublishLocationId = c.Id;
        insert version;
        Test.startTest();
        List<ContentVersion> cvClaim = INS_CTRL_DocumentManagement.relatedObjectFiles(claim.Id, CASEOBJ);
        Test.stopTest();
        Assert.areEqual(1, cvClaim.size(), 'No files found!');
    }

    @isTest
    static Void testGetRelatedObjectRecordsInsurancePolicy() {
        Account acc = INS_DocumentManagementTestFactory_TEST.createAccount();
        InsurancePolicy ip = INS_DocumentManagementTestFactory_TEST.createInsurancePolicy(acc.Id);
        Case c = INS_DocumentManagementTestFactory_TEST.createCaseWithInsurancePolicy(ip.Id);
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id);

        version.FirstPublishLocationId = c.Id;
        insert version;
        Test.startTest();
        List<ContentVersion> cvPolicy = INS_CTRL_DocumentManagement.relatedObjectFiles(ip.Id, CASEOBJ);
        Test.stopTest();
        Assert.areEqual(1, cvPolicy.size(), 'No files returned!');
    }

    @isTest
    static Void testDeleteDocument() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id
        );
        version.FirstPublishLocationId = claim.Id;
        insert version;
        version = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id];
        Test.startTest();
        INS_CTRL_DocumentManagement.deleteDocument(version.ContentDocumentId);
        List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE Id = :version.ContentDocumentId];
        Test.stopTest();
        Assert.areEqual(0, documents.size(), 'Document was not deleted!');
    }

    @isTest
    static Void testUpdateDocument() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id
        );
        version.FirstPublishLocationId = claim.Id;
        insert version;
        Test.startTest();
        version.Title = 'Dummy Name';
        version = INS_CTRL_DocumentManagement.updateContentVersion(
            new INS_UTIL_File(version)
        );
        Test.stopTest();
        Assert.areEqual(true, version.Title.equalsIgnoreCase('Dummy Name'), 'Document was not updated!');
    }

    @isTest
    static Void testUpload() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id
        );
        version.FirstPublishLocationId = claim.Id;
        insert version;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        Test.startTest();
        INS_UTIL_DocumentInfo info = INS_CTRL_DocumentManagement.upload(claim.Id, 'INSURANCE', new INS_UTIL_File(version).setRecordId(claim.Id));
        Test.stopTest();
        Assert.areEqual(true, info.isSuccess, 'File upload failed!');
    }

    @isTest
    static Void testUploadForFailure() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        Test.startTest();
        try {
            INS_CTRL_DocumentManagement.upload(claim.Id, 'INSURANCE', new INS_UTIL_File());
        }
        catch(Exception ex) {
            Assert.isTrue(ex.getMessage().equalsIgnoreCase('Attempt to de-reference a null object'), 'Should be throwing an exception!');
        }
        Test.stopTest();
    }

    @isTest
    static Void testRelatedObjectUpload() {
        Claim claim = INS_DocumentManagementTestFactory_TEST.createClaim();
        Case c = INS_DocumentManagementTestFactory_TEST.createCaseWithClaim(claim.Id);
        ContentVersion version = INS_DocumentManagementTestFactory_TEST.createContentVersion(
            INS_DocumentManagementTestFactory_TEST.getDocumentType()?.Id
        );
        version.FirstPublishLocationId = c.Id;
        insert version;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        Test.startTest();
        INS_UTIL_DocumentInfo info = INS_CTRL_DocumentManagement.uploadRelatedDoc(CASEOBJ, new INS_UTIL_File(version).setRecordId(claim.Id));
        Test.stopTest();
        Assert.areEqual(true, info.isSuccess, 'File upload failed!');
    }

    @isTest
    static Void testRelatedObjectUploadFailure() { 
        INS_DocumentManagementTestFactory_TEST.createClaim();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());
        Test.startTest();
        try { 
            INS_CTRL_DocumentManagement.uploadRelatedDoc(CASEOBJ, new INS_UTIL_File());
        }
        catch(Exception ex) {
            Assert.isTrue(ex.getMessage().equalsIgnoreCase('Attempt to de-reference a null object'), 'Should be throwing an exception!');
        }
        Test.stopTest();
    }

    public class MockHttpResponseGeneratorSuccess implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"DocumentDirectoryResponse": {"DocumentDirectoryId": "idd_90AB4591-0000-CD15-B22E-B71BC8A601A0"}}');
            return res;
        }
    }
}