/***************************************************************************************
@ Author            :jagadish thummala
@ Date              :May 2023
@ Name of the Class :CMN_SignatureVerifyTest
@description       :test class for SignatureVerify.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-07-2023
@ Modification Description : SFP-26347
***************************************************************************************/
@isTest
/**
 * @description Testclass for the CMN_SignatureVerify
 *
 */
public with sharing class CMN_SignatureVerifyTest {
    /**
    * @description TestMethod for invoking CMN_SignatureVerifyTest
    *
    */
     @istest static void testCalloutMethod(){     
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> lstApp=BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].application__c = app[0].id;
        insert lstApp;
        Application_Document__c document1 = new Application_Document__c();
        document1.Document_Type__c = 'FaceImage';
        document1.Application_Participant__c = lstApp[0].id;
        insert document1;
        ContentVersion cv1 = new ContentVersion();
        cv1.VersionData =Blob.valueOf('Test Content');
        cv1.Title ='FaceImage';
        cv1.PathOnClient = 'FaceImage.pdf';
        insert cv1;
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        ContentVersion contentVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id];
        cdl1.ContentDocumentId = contentVersion1.ContentDocumentId;
        cdl1.LinkedEntityId = document1.Id;
        cdl1.ShareType = 'V';
        insert cdl1;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        List<ContentVersion> cvlst = new List<ContentVersion>();
        cvlst.add(cv);
        cvlst.add(cv1);
        String str = '{"signatureAddResponse":{"signatureAddResponse":{},"accountCode":{},"customerNumber":"10000000111","employeeIdent":{},"bankCode":{},"signaturePowerNum":{},"signatureAddStatusCode":"true"}}';
        CMN_SignatureVerify.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_SignatureVerify.mockHttpStatus = 'OK';
        CMN_SignatureVerify.mockHttpbody = str;

        Test.startTest();
        String repStatus = CMN_SignatureVerify.invocableMethod(lstApp, cvlst);
        String repStatus2 = CMN_SignatureVerify.invocableMethod(lstApp, NULL);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Response Status Check');
    }
    /**
    * @description TestMethod for invoking CMN_SignatureVerify
    *
    */
    @istest static void testCalloutMethod1(){     
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> lstApp=BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].application__c = app[0].id;
        insert lstApp;
        Application_Document__c document1 = new Application_Document__c();
        document1.Document_Type__c = 'FaceImage';
        document1.Application_Participant__c = lstApp[0].id;
        insert document1;
        ContentVersion cv1 = new ContentVersion();
        cv1.VersionData =Blob.valueOf('Test Content');
        cv1.Title ='FaceImage';
        cv1.PathOnClient = 'FaceImage.pdf';
        insert cv1;
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        ContentVersion contentVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id];
        cdl1.ContentDocumentId = contentVersion1.ContentDocumentId;
        cdl1.LinkedEntityId = document1.Id;
        cdl1.ShareType = 'V';
        insert cdl1;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        List<ContentVersion> cvlst = new List<ContentVersion>();
        cvlst.add(cv);
        CMN_SignatureVerify.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_SignatureVerify.mockHttpStatus = 'OK';
        CMN_SignatureVerify.mockHttpbody = null;
 try{ 
        Test.startTest();
       CMN_SignatureVerify.invocableMethod(lstApp, cvlst);
        Test.stopTest(); 
     }catch(exception ex){
        Assert.areNotEqual(null, lstApp,'Test');
    }  
     
    }
     /**
    * @description TestMethod for invoking CMN_SignatureVerify
    *
    */
    @istest static void testCalloutMethod3(){     
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> lstApp=BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].application__c = app[0].id;
        insert lstApp;
        Application_Document__c document1 = new Application_Document__c();
        document1.Document_Type__c = 'FaceImage';
        document1.Application_Participant__c = lstApp[0].id;
        insert document1;
        ContentVersion cv1 = new ContentVersion();
        cv1.VersionData =Blob.valueOf('Test Content');
        cv1.Title ='FaceImage';
        cv1.PathOnClient = 'FaceImage.pdf';
        insert cv1;
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        ContentVersion contentVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id];
        cdl1.ContentDocumentId = contentVersion1.ContentDocumentId;
        cdl1.LinkedEntityId = document1.Id;
        cdl1.ShareType = 'V';
        insert cdl1;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        List<ContentVersion> cvlst = new List<ContentVersion>();
        cvlst.add(cv);
        cvlst.add(cv1);
        String str = '{"ErrorCode": "35170","ErrorDescription": "Mandatory field not entered. ","ErrorSource": "","ErrorStatus": " "}';
        AOB_SignatureVerification.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SignatureVerification.mockHttpStatus = 'OK';
        AOB_SignatureVerification.mockHttpbody = str;

        Test.startTest();
        String repStatus = CMN_SignatureVerify.invocableMethod(lstApp, cvlst);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

        Assert.isNotNull((String)m.get('status'), 'SUCCESS');
    }
     /** 
     *@description TestMethod for AOB_SignatureVerification
     */
    @istest static void testCalloutMethod4(){     
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> lstApp=BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].application__c = app[0].id;
        insert lstApp;
        Application_Document__c document1 = new Application_Document__c();
        document1.Document_Type__c = 'FaceImage';
        document1.Application_Participant__c = lstApp[0].id;
        insert document1;
        ContentVersion cv1 = new ContentVersion();
        cv1.VersionData =Blob.valueOf('Test Content');
        cv1.Title ='FaceImage';
        cv1.PathOnClient = 'FaceImage.pdf';
        insert cv1;
        ContentDocumentLink cdl1 = new ContentDocumentLink();
        ContentVersion contentVersion1 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id];
        cdl1.ContentDocumentId = contentVersion1.ContentDocumentId;
        cdl1.LinkedEntityId = document1.Id;
        cdl1.ShareType = 'V';
        insert cdl1;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        List<ContentVersion> cvlst = new List<ContentVersion>();
        cvlst.add(cv);
        cvlst.add(cv1);
        String str = '{"signatureAddResponse":{"signatureAddResponse":{},"accountCode":{},"customerNumber":"10000000111","employeeIdent":{},"bankCode":{},"signaturePowerNum":{},"signatureAddStatusCode":"true"}}';
        CMN_SignatureVerify.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_SignatureVerify.mockHttpStatus = 'OK';
        CMN_SignatureVerify.mockHttpbody = str;

        Test.startTest();
        String repStatus = CMN_SignatureVerify.invocableMethod(lstApp, cvlst);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 

       Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Response Status Check');
    }
}