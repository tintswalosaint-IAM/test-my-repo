/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_SignatureVerificationTest
@ Description       :Test Class to cover the code for AOB_SignatureVerification.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :15-02-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/** 
*@description Test Class to cover the code for AOB_SignatureVerification.
*/
@isTest
public class AOB_SignatureVerificationTest {
   /** 
     *@description TestMethod for AOB_SignatureVerification
     */
    @istest static void testCalloutMethod(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        ContentVersion document = AOB_TestDataFactory.createContentVersion(); 
        document.Title =  'Selfie image';
        document.Description='Selfie image';
        insert document;
        ContentVersion contentVersionId = [SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: document.id];
        List<ContentVersion> documentList = new List<ContentVersion>();
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentVersionId.ContentDocumentId,
            LinkedEntityId = lstApp[0].Id,
            ShareType = 'V'
        );


        insert testContentDocumentLink;
        documentList.add(document); 
        String str = '{"signatureAddResponse":{"signatureAddResponse":{},"accountCode":{},"customerNumber":"10000000111","employeeIdent":{},"bankCode":{},"signaturePowerNum":{},"signatureAddStatusCode":"true"}}';
        AOB_SignatureVerification.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SignatureVerification.mockHttpStatus = 'OK';
        AOB_SignatureVerification.mockHttpbody = str;

        Test.startTest();
        String repStatus = AOB_SignatureVerification.invokeSvsCallout(lstApp, documentList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

       Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Response Status Check');
    }
     /** 
     *@description TestMethod for testCallout for no content
     */
    @istest static void testCalloutMethodNoContent(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        ContentVersion document = AOB_TestDataFactory.createContentVersion(); 
        document.Title =  'Selfie image';
        document.Description='Selfie image';
        insert document;
        ContentVersion contentVersionId = [SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: document.id];
        List<ContentVersion> documentList = new List<ContentVersion>();
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentVersionId.ContentDocumentId,
            LinkedEntityId = lstApp[0].Id,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        documentList.add(document); 
        AOB_SignatureVerification.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_SignatureVerification.mockHttpStatus = 'OK';
        AOB_SignatureVerification.mockHttpbody = null;

        Test.startTest();
        String repStatus = AOB_SignatureVerification.invokeSvsCallout(lstApp, documentList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

        Assert.areEqual((String)m.get('status'), 'NO_CONTENT', 'Response Status Check');
    }
     /** 
     *@description TestMethod for AOB_SignatureVerification
     */
    @istest static void testCalloutMethodinternal(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].WI_ClientType__c = 'Staff Assist';
        insert lstApp;
        ContentVersion document = AOB_TestDataFactory.createContentVersion(); 
        document.Title =  'Selfie image';
        document.Description='FaceImage';
        insert document;
        ContentVersion contentVersionId = [SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: document.id];
        List<ContentVersion> documentList = new List<ContentVersion>();
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentVersionId.ContentDocumentId,
            LinkedEntityId = lstApp[0].Id,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        documentList.add(document); 
        String str = '{"signatureAddResponse":{"signatureAddResponse":{},"accountCode":{},"customerNumber":"10000000111","employeeIdent":{},"bankCode":{},"signaturePowerNum":{},"signatureAddStatusCode":"false"}}';
        AOB_SignatureVerification.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SignatureVerification.mockHttpStatus = 'OK';
        AOB_SignatureVerification.mockHttpbody = str;

        Test.startTest();
        String repStatus = AOB_SignatureVerification.invokeSvsCallout(lstApp, documentList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

       Assert.areEqual((String)m.get('status'), 'FAILED', 'Response Status Check');
    } 
      /** 
     *@description TestMethod for AOB_SignatureVerification AddResponse
     */
    @istest static void testCalloutMethodinternalAddResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].WI_ClientType__c = 'Staff Assist';
        insert lstApp;
        ContentVersion document = AOB_TestDataFactory.createContentVersion(); 
        document.Title =  'Selfie image';
        document.Description='FaceImage';
        insert document;
        ContentVersion contentVersionId = [SELECT Id, Title, VersionData,ContentDocumentId FROM ContentVersion WHERE Id =: document.id];
        List<ContentVersion> documentList = new List<ContentVersion>();
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = contentVersionId.ContentDocumentId,
            LinkedEntityId = lstApp[0].Id,
            ShareType = 'V'
        );
        insert testContentDocumentLink;
        documentList.add(document); 
        String str = '{"signatureAddResponse":{}';
        AOB_SignatureVerification.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SignatureVerification.mockHttpStatus = 'OK';
        AOB_SignatureVerification.mockHttpbody = str;

        Test.startTest();
        String repStatus = AOB_SignatureVerification.invokeSvsCallout(lstApp, documentList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

       Assert.areEqual((String)m.get('status'), 'FAILED', 'Response Status Check');
    } 
}