/*
    ***************************************************************************************
    @Name of the Class :KYC_SRV_DocUpload_Request_Test
    @Description :SFP-52092:Created
    @Author :Irshad 
    @Created Date :20/08/2025
    ***************************************************************************************/
@IsTest
private with sharing class KYC_SRV_DocUpload_Request_Test {
    
    @IsTest 
    static void testParse_HappyPath(){
         String json = '{'
            + '"documentIdentification":[{"documentIdentificationType":"DocumentUUID","documentIdentificationValue":"059ed44a-b58a-466d-9192-9a4c24c0f06c","documentVersion":"1"}],'
            + '"documentDateTime":{"documentDateTimeType":"UploadedDateTime","documentDateTime":"2025-01-28T13:34:29"},'
            + '"documentName":"ID Document",'
            + '"documentType":"Identification",'
            + '"documentFormatType":"pdf",'
            + '"documentRepositoryLocation":{"documentRepositoryName":"Document Repository","documentURL":"documents/464981/file"},'
            + '"partyReference":{"partyIdentificationType":"CustomerId","partyIdentificationValue":"194172920","countryofIssue":"KE","firstName":"Themba","lastName":"Shezi"},'
            + '"documentStatus":"Success",'
            + '"documentStatusMessage":"Document Uploaded Successfully",'
            + '"documentValidityPeriod":{"fromDateTime":"2025-01-28T13:34:29","toDateTime":"2027-01-28T13:34:29"},'
            + '"documentStream":"VEVTVA==",'
            + '"documentDirectoryId":"1230961905762304"'
            + '}';

            KYC_SRV_DocUpload_Request req = KYC_SRV_DocUpload_Request.parse(json);
            Assert.isNotNull(req);
            Assert.areEqual('DocumentUUID', req.documentIdentification[0].documentIdentificationType);
    }
}