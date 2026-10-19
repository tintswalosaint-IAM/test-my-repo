@isTest
public class AOB_DSXTest {

    @istest static void testCalloutMethod(){     
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        ContentVersion cv = AOB_TestDataFactory.createContentVersion();
        List<ContentVersion> documentList = new List<ContentVersion>{cv};
        insert documentList;
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
        List<Product2> productList = AOB_TestDataFactory.createProduct(); 
        insert productList; 
        ContentDocumentLink cDoc = AOB_TestDataFactory.createContentDocumentLink (productList[0].Id, contentVersion.ContentDocumentId);
        insert cDoc;
        ContentDocumentLink aDoc = AOB_TestDataFactory.createContentDocumentLink (lstApp[0].Id, contentVersion.ContentDocumentId);
        insert aDoc;
        lstApp[0].AOB_Product__c = productList[0].Id; 
        String str='{"documents":[{"reasonCode":"success","status":"queued","reasonDescription":"true"},{"reasonCode":"success","status":"queued","reasonDescription":"true"},{"reasonCode":"success","status":"queued","reasonDescription":"true"}]}';
        AOB_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_DSX.mockHttpStatus='OK';
        AOB_DSX.mockHttpBody=str;
        Test.startTest();
        String repStatus = AOB_DSX.invocableMethod(lstApp, documentList, productList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
    
    @istest static void testCalloutMethod1(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        ContentVersion cv = AOB_TestDataFactory.createContentVersion();
        List<ContentVersion> documentList = new List<ContentVersion>{cv};
        insert documentList;
        List<Product2> productList = AOB_TestDataFactory.createProduct(); 
        insert productList; 
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
        ContentDocumentLink aDoc = AOB_TestDataFactory.createContentDocumentLink (lstApp[0].Id, contentVersion.ContentDocumentId);
        insert aDoc;
        lstApp[0].AOB_Product__c = productList[0].Id; 
        AOB_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_DSX.mockHttpStatus='OK';
        AOB_DSX.mockHttpBody=null;
        Test.startTest();
        String repStatus = AOB_DSX.invocableMethod(lstApp, documentList, productList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status'); 
    }
    
    @istest static void testCalloutMethod2(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        List<Product2> productList = AOB_TestDataFactory.createProduct(); 
        insert productList; 
        ContentVersion cv = AOB_TestDataFactory.createContentVersion();
        List<ContentVersion> documentList = new List<ContentVersion>{cv};
        insert documentList;
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
        ContentDocumentLink aDoc = AOB_TestDataFactory.createContentDocumentLink (lstApp[0].Id, contentVersion.ContentDocumentId);
        insert aDoc;
        lstApp[0].AOB_Product__c = productList[0].Id; 
        AOB_DSX.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_DSX.mockHttpStatus='OK';
        AOB_DSX.mockHttpBody=null;
        Test.startTest();
        String repStatus = AOB_DSX.invocableMethod(lstApp, null, productList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status'); 
    }
    
    
}