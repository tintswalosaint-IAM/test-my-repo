/**
 * @description       : This is test class for WRP_UploadedFiles
 * @author            : Nagendra Mylavarapu
 * @group             : SBG Insurance
 * @last modified on  : 06-19-2024
 * @last modified by  : Jaco de Lange
**/
@isTest
private class WRP_UploadedFiles_Test {
    @isTest
    static void testDocumentIdentification() {
        //Create a DocumentIdentification object
        Test.startTest();
        WRP_UploadedFiles wrp = new WRP_UploadedFiles();
        WRP_UploadedFiles.DocumentIdentification docIdent = new WRP_UploadedFiles.DocumentIdentification();
        docIdent.DocumentIdentificationType = 'Type';
        docIdent.DocumentIdentificationValue = 'Value';
        Test.stopTest();
        
        //Assert that the values are set correctly
        Assert.areEqual('Type', docIdent.DocumentIdentificationType, 'Type is set correctly');
        Assert.areEqual('Value', docIdent.DocumentIdentificationValue, 'Value is set correctly');

        //Assert that the values are not set correctly
        Assert.areNotEqual(null, docIdent.DocumentIdentificationType, 'Type is not set correctly');
        Assert.areNotEqual(null, docIdent.DocumentIdentificationValue, 'Value is not set correctly');
    }

    @isTest
    static void testDocumentDetails() {
        //Create a DocumentIdentification object
        Test.startTest();
        WRP_UploadedFiles.DocumentIdentification docIdent = new WRP_UploadedFiles.DocumentIdentification();
        docIdent.DocumentIdentificationType = 'Type';
        docIdent.DocumentIdentificationValue = 'Value';

        //Create a DocumentDetails object
        WRP_UploadedFiles.DocumentDetails docDetails = new WRP_UploadedFiles.DocumentDetails();
        docDetails.id = '123';
        docDetails.name = 'Document Name';
        docDetails.mimeType = 'application/pdf';
        docDetails.contentVersionId = '456';
        docDetails.readOnly = false;
        docDetails.relatedRecordId = '789';
        docDetails.country = 'South Africa';
        docDetails.documentType = 'Contract';
        docDetails.documentIdentification = new List<WRP_UploadedFiles.DocumentIdentification>();
        docDetails.documentIdentification.add(docIdent);
       	Test.stopTest();

        //Assert that the values are set correctly
        Assert.areEqual('123', docDetails.id, 'Id is set correctly');
        Assert.areEqual('application/pdf', docDetails.mimeType, 'MimeType is set correctly');
        Assert.areEqual('456', docDetails.contentVersionId, 'ContentVersionId is set correctly');
        Assert.areEqual('Document Name', docDetails.name, 'Name is set correctly');
        Assert.areEqual(false, docDetails.readOnly, 'ReadOnly is set correctly');
        Assert.areEqual('789', docDetails.relatedRecordId, 'RelatedRecordId is set correctly');
        Assert.areEqual('South Africa', docDetails.country, 'Country is set correctly');
        Assert.areEqual('Contract', docDetails.documentType, 'DocumentType is set correctly');
        Assert.areEqual(1, docDetails.documentIdentification.size(), 'Document identification record found');
        Assert.areEqual('Type', docDetails.documentIdentification[0].DocumentIdentificationType, 'Type is set correctly');
        Assert.areEqual('Value', docDetails.documentIdentification[0].DocumentIdentificationValue, 'Value is set correctly');

        //Assert that the values are not set correctly
        Assert.areNotEqual(null, docDetails.id, 'Id is not set correctly');
        Assert.areNotEqual(null, docDetails.mimeType, 'MimeType is not set correctly');
        Assert.areNotEqual(null, docDetails.contentVersionId, 'ContentVersionId is not set correctly');
        Assert.areNotEqual(null, docDetails.name, 'Name is not set correctly');
        Assert.areNotEqual(true, docDetails.readOnly, 'ReadOnly is not set correctly');
        Assert.areNotEqual(null, docDetails.relatedRecordId, 'RelatedRecordId is not set correctly');
        Assert.areNotEqual(null, docDetails.country, 'Country is not set correctly');
        Assert.areNotEqual(null, docDetails.documentType, 'DocumentType is set correctly');
        Assert.areNotEqual(0, docDetails.documentIdentification.size(), 'Document identification record not found');
        Assert.areNotEqual(null, docDetails.documentIdentification[0].DocumentIdentificationType, 'Type is not set correctly');
        Assert.areNotEqual(null, docDetails.documentIdentification[0].DocumentIdentificationValue, 'Value is not set correctly');
    }
}