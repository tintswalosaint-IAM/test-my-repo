/**
 * @description       : Test Class for CMN_DocumentManagement Class
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-13-2024
 * @last modified by  : Jaco de Lange
**/
@IsTest
public class CMN_DocumentManagement_TEST{
    /**
    * @description To test upload documents CMN_DocumentManagement.DocumentUpload
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    **/
    @isTest
    public static void uploadDocTest(){
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='FaceImage';
        cv.PathOnClient = 'FaceImage.pdf';
        insert cv;
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        InsurancePolicy insPolicy = new InsurancePolicy();
        insPolicy.NameInsuredId = testAccount.Id;
        insPolicy.Name = 'Test Insurance';
        insert insPolicy;

        Claim claim = new Claim();
        claim.PolicyNumberId = insPolicy.id;
        claim.Name = 'Test Claim';
        claim.FileNet_Request_Payload__c = '[{"type":"image/jpeg","relatedRecordId":' + claim.id + ',"name":"68465528_2206751399451114_6549460410662125568_n.jpg","documentType":null,"documentIdentification":[{"documentIdentificationValue":"INSDC","documentIdentificationType":"ENTY_TYPE"},{"documentIdentificationValue":"750","documentIdentificationType":"DocumentType"},{"documentIdentificationValue":"Medical Report - VAFTEST SITONE - 7201011234123","documentIdentificationType":"DocumentTitle"},{"documentIdentificationValue":"12335678","documentIdentificationType":"BPID"},{"documentIdentificationValue":"7201011234123","documentIdentificationType":"IDNUM"},{"documentIdentificationValue":"VAFTEST SITONE","documentIdentificationType":"Surname"},{"documentIdentificationValue":"Salesforce","documentIdentificationType":"Source"},{"documentIdentificationValue":"T","documentIdentificationType":"Initials"},{"documentIdentificationValue":"Salesforce","documentIdentificationType":"UserID"},{"documentIdentificationValue":"CL-0389","documentIdentificationType":"ClaimNumber"},{"documentIdentificationValue":"FUN000126917","documentIdentificationType":"PolicyNumber"},{"documentIdentificationValue":"0683M000002qlUuQAI","documentIdentificationType":"SourceID"},{"documentIdentificationValue":"12cc01b-de4c-4d8d-b5bb-10822a9ba345","documentIdentificationType":"SBGUID"}],"country":null,"contentVersionId":"' + cv.id + '","actualFile":"0693M000002hKsEQAU"}]';
        insert claim;

        PartyProfile pp = new PartyProfile(AccountId = testAccount.Id, Name = 'Profile 1');
        Test.setMock(HttpCalloutMock.class, new CMN_DocumentManagement_TEST.MockHttpResponseGenerator());
        Test.startTest();                
        String sampleinput= '[{"name":"ProductCatalogue (56).pdf","type":"application/pdf","contentVersionId":"'+cv.Id+'","relatedRecordId":"'+claim.Id+'","country":"South Africa","documentType":"Tax Statement","documentIdentification":[{"DocumentIdentificationType":"ENTY_TYPE","DocumentIdentificationValue":"INSDC"},{"DocumentIdentificationType":"DocumentType","DocumentIdentificationValue":"531"},{"DocumentIdentificationType":"DocumentTitle","DocumentIdentificationValue":"asd"},{"DocumentIdentificationType":"BPID","DocumentIdentificationValue":"12335678"},{"DocumentIdentificationType":"IDNUM","DocumentIdentificationValue":"343000801495"},{"DocumentIdentificationType":"Surname","DocumentIdentificationValue":"changeMe"},{"DocumentIdentificationType":"Initials","DocumentIdentificationValue":"T"},{"DocumentIdentificationType":"UserID","DocumentIdentificationValue":"Salesforce"},{"DocumentIdentificationType":"ClaimNumber","DocumentIdentificationValue":"claim123"},{"DocumentIdentificationType":"PolicyNumber","DocumentIdentificationValue":"pol456"},{"DocumentIdentificationType":"SourceID","DocumentIdentificationValue":"123"},{"DocumentIdentificationType":"Source","DocumentIdentificationValue":"Salesforce"},{"DocumentIdentificationType":"SBGUID","DocumentIdentificationValue":"12cc01b-de4c-4d8d-b5bb-10822a9ba345"}]}]';
        String responseList = CMN_DocumentManagement.DocumentUpload(sampleinput, claim.id);
        CMN_DocumentManagement.commonDocumentUpload(new List<String>{claim.FileNet_Request_Payload__c});
        
        CMN_DocumentManagement.getClaimInformation (claim.Id);
        CMN_DocumentManagement.generateGUID();

        Assert.areNotEqual(null, responseList, 'Global Document ID should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getFileNetConfigurationsTest(){
        Test.startTest();
        List<CMN_DocumentManagement.DocumentFileNetConfiguration> fileNetConfigurations =  CMN_DocumentManagement.getFileNetConfigurations();
        Test.stopTest();
    }
    /**
    * @description mock class CMN_DocumentManagement
    */
    public class MockHttpResponseGenerator implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"DocumentDirectoryResponse": {"DocumentDirectoryId": "fakeId"}}');
            return res;
        }
    }
}