/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :July 2023
@ Name of the Class :CMN_DSX
@description       :Test Class for dealing with CMN_DSX
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-07-2023
@ Modification Description : SFP-25652
***************************************************************************************/
@isTest
public  class CMN_DSXTest {
     /**
    * @description TestMethod for invoking CMN_DSXTest
    */
    @istest static void testCalloutMethod(){     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='FaceImage';
        cv.PathOnClient = 'FaceImage.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title,VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
       
        String str='{"documents":[{"reasonCode":"success","status":"queued","reasonDescription":"true"},{"reasonCode":"success","status":"queued","reasonDescription":"true"},{"reasonCode":"success","status":"queued","reasonDescription":"true"}]}';
        CMN_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_DSX.mockHttpStatus='OK';
        CMN_DSX.mockHttpBody=str;
        Test.startTest();
        String repStatus = CMN_DSX.invocableMethodApplicationId(lstApp[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
     /**
    * @description TestMethod for invoking CMN_DSXTest
    */
    @istest static void testCalloutMethod3(){     
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='FaceImage';
        cv.PathOnClient = 'FaceImage.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title,VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        String str='{"documents":[{"reasonCode":"success","status":"queued","reasonDescription":"true"},{"reasonCode":"success","status":"queued","reasonDescription":"true"},{"reasonCode":"success","status":"queued","reasonDescription":"true"}]}';
        CMN_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_DSX.mockHttpStatus='OK';
        CMN_DSX.mockHttpBody=str;
        Test.startTest();
        String repStatus = CMN_DSX.invocableMethodParticipant(lstApp[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
    /**
    * @description TestMethod for invoking CMN_DSXTest
    *
    */
    @istest static void testCalloutMethod1(){     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='FaceImage';
        cv.PathOnClient = 'FaceImage.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title,VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        CMN_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_DSX.mockHttpStatus='OK';
        CMN_DSX.mockHttpBody=null;
        Test.startTest();
        String repStatus = CMN_DSX.invocableMethodApplicationId(lstApp[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status'); 
    } 

	/**
    * @description TestMethod for invoking CMN_DSXTest
    *
    */
    @istest static void testCalloutMethod4(){     
		List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='FaceImage';
        cv.PathOnClient = 'FaceImage.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title,VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        CMN_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_UNAUTHORISED;
        CMN_DSX.mockHttpStatus='';
        CMN_DSX.mockHttpBody=null;
        Test.startTest();
        String repStatus = CMN_DSX.invocableMethodParticipant(lstApp[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status'); 
    }
    /**
    * @description TestMethod for invoking CMN_DSX
    *
    */
    @istest static void testCalloutMethod2(){     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application__c = lstApp[0].Id;
        insert document;
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='FaceImage';
        cv.PathOnClient = 'FaceImage.pdf';
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title,VersionData, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
  
        CMN_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_DSX.mockHttpStatus='OK';
        CMN_DSX.mockHttpBody=null;
        Test.startTest();
        String repStatus =  CMN_DSX.invocableMethodApplicationId(lstApp[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status'); 
    }   
}