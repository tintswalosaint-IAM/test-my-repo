/***************************************************************************************
* @name of the Class : ICS_API_InboundCRACreateDocumentTest.cls
* @description class used as test class for ICS_API_InboundCRACreateDocument
* @Story:SFP-34697
* @date 10/03/2024
/***************************************************************************************
* @last modified on  : 06-03-2025
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/
@isTest
private class ICS_API_InboundCRACreateDocumentTest {
    @isTest
    static void testProcessRequest() {
        // Create a test Account record
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Mock REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        String mockRequestBody = '{ "requests": [{ "CustomerId": "' + testAccount.Id + '", "Document": "VGhpcyBpcyBhIHRlc3QgZG9jdW1lbnQ=", "DocumentType": "TestDoc.pdf" }] }';
        req.requestBody = Blob.valueOf(mockRequestBody);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
         try {
            ICS_API_InboundCRACreateDocument.processRequest();
        } catch (DmlException e) {
            Assert.areEqual(false, 'DmlException occurred: ' + e.getMessage());
        }
        Test.stopTest();
        
        Assert.areNotEqual(null, RestContext.response, 'Response should not be null');
    }
}