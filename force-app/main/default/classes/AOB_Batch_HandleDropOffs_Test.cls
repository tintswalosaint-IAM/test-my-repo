/***************************************************************************************
@ Author            :Jagadish Thummala
@ Date              :june 2022
@ Name of the Class :AOB_Batch_HandleDropOffs_Test
@ Description       :test class to cover the test cases for AOB_Batch_HandleDropOffs
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :08/11/2024.
***************************************************************************************/

@isTest
public class AOB_Batch_HandleDropOffs_Test {
    @isTest static void upsertApplicationRecordPersonalDetails() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        List<Application__c> applicationList = AOB_TestDataFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = ld.Id;
        insert applicationList;

        String mockResponse = '{"caseId":"5jb8f6g8q9zj1guky6czii2t7","name":"Leku Joel","providerTypes":["WATCHLIST"],"customFields":[],"secondaryFields":[],"groupId":"5jb75gv0cn6q1g4q4u0643299","entityType":"INDIVIDUAL","caseSystemId":"5jb8f6g8q9zj1guky6czii2t8","caseScreeningState":{"WATCHLIST":"INITIAL"},"lifecycleState":"UNARCHIVED","creator":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"modifier":{"userId":"5jb75ituimr11g17bymq564i1","firstName":"Walusimbi Katungi","lastName":"Nina","fullName":"Walusimbi Katungi Nina","email":"katungin@stanbic.com","status":"ACTIVE"},"assignee":null,"creationDate":"2022-07-22T07:00:45.917Z","modificationDate":"2022-07-22T07:00:49.020Z","nameTransposition":false,"outstandingActions":true,"results":[{"resultId":"5jb7ukkmdn291guky6iwoh1tz","referenceId":"e_tr_wci_6581204","matchScore":89.97,"matchStrength":"EXACT", "matchedTerm":"Joel LEKU","matchedTerms":[{"term":"Joel LEKU","type":"PRIMARY"}],"submittedTerm":"Leku Joel","matchedNameType":"PRIMARY","secondaryFieldResults":[],"sources":["b_trwc_PEP N"],"categories":["PEP","Regulatory Enforcement","Sanctions"],"creationDate":"2022-07-22T07:00:49.018Z","modificationDate":"2022-07-22T07:00:49.018Z","lastAlertDate":"2022-07-22T07:00:49.021Z","resolution":null,"resultReview":{"reviewRequired":false,"reviewRequiredDate":"2021-09-03T00:00:00.000Z","reviewRemark":null,"reviewDate":null},"primaryName":"Joel LEKU","events":[],"countryLinks":[{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"NATIONALITY"},{"country":{"code":"UGA","name":"UGANDA"},"countryText":"UGANDA","type":"LOCATION"}],"identityDocuments":[],"category":"POLITICAL INDIVIDUAL","providerType":"WATCHLIST","gender":"MALE","entityCreationDate":"2021-08-02T00:00:00.000Z","entityModificationDate":"2021-09-03T00:00:00.000Z","pepStatus":"ACTIVE"}]}';
        AOB_SanctionScreen.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_SanctionScreen.mockHttpStatus = 'OK';
        AOB_SanctionScreen.mockHttpbody = mockResponse;
        List<Product2> prodList = AOB_TestDataFactory.createProduct();

        Test.startTest();
        string repStatus = AOB_FlowController.upsertApplicationRecord(applicationList, 'Personal Details', prodList);
        AOB_Batch_HandleDropOffs obj = new AOB_Batch_HandleDropOffs();
        Database.executeBatch(obj,1);
        Test.stopTest(); 
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Assert.areEqual((String)m.get('status'), null, 'Status Check against the response');
    }

    @isTest static void invokeMobileWalletCalloutTest() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Lead__c = ld.Id;
        insert lstApp;
        String str = '{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';
        AOB_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_MobileWallet.mockHttpStatus = 'OK';
        AOB_MobileWallet.mockHttpbody = str;

        Test.startTest();
        String repStatus = AOB_FlowController.invokeMobileWalletCallout(lstApp);
        AOB_Batch_HandleDropOffs scheduleInstance = new AOB_Batch_HandleDropOffs();
        String sch = '0 0 * * * ?';
        System.schedule('Drop Off Assignment', sch, scheduleInstance);
        Test.stopTest();  

        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Assert.areEqual((integer)m.get('status'), 200, 'Status Check against the response');

    }

    @isTest static void invokeGETCustomerAccountNumberTest() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
        appList[0].AOB_Lead__c = ld.Id;
        insert appList;

        string mockResponse = '{"ODAccountAddRes":{"ODaccountNumber":{"accountNumber":"9030020820453","accountType":{"schemaCode":{},"schemaType":{}},"accountCurrency":{},"bankInfo":{"bankId":{},"name":{},"branchId":{},"branchName":{},"postalAddress":{"line1":{},"line2":{},"line3":{},"city":{},"stateProvince":{},"postalCode":{},"country":{},"addressType":{}}}}}}';
        AOB_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_ODAccountCreation.mockHttpStatus = 'OK';
        AOB_ODAccountCreation.mockHttpbody = mockResponse;
        Test.startTest();
        String resultList =AOB_FlowController.invokeGETCustomerAccountNumber(appList);
        AOB_Batch_HandleDropOffs scheduleInstance = new AOB_Batch_HandleDropOffs();
        String sch = '0 0 * * * ?';
        System.schedule('Drop Off Assignment', sch, scheduleInstance);
        Test.stopTest();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Assert.areEqual((String)m.get('status'), 'FAILED', 'Status Check against the response');

    }

    @isTest static void invokeProfileAlertCalloutTest() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        List<Application__c> appList = AOB_TestDataFactory.createApplication(1);
        appList[0].AOB_Lead__c = ld.Id;
        insert appList;

        AOB_CustomerAlertsProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerAlertsProfile.mockHttpStatus = 'OK';
        AOB_CustomerAlertsProfile.mockHttpbody = null; 

        Test.startTest();
        String repStatus = AOB_FlowController.invokeProfileAlertCallout(appList);
        AOB_Batch_HandleDropOffs scheduleInstance = new AOB_Batch_HandleDropOffs();
        String sch = '0 0 * * * ?';
        System.schedule('Drop Off Assignment', sch, scheduleInstance);
        Test.stopTest();

        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Assert.areEqual((String)m.get('status'), 'FAILED', 'Status Check against the response');

    }

    @isTest static void invokeDSXCalloutTest() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Lead__c = ld.Id;
        insert lstApp;
        ContentVersion cv = AOB_TestDataFactory.createContentVersion();
        List<ContentVersion> documentList = new List<ContentVersion>{cv};
        insert documentList;
        ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
        List<Product2> productList = AOB_TestDataFactory.createProduct(); 
        insert productList; 
        ContentDocumentLink cDoc = AOB_TestDataFactory.createContentDocumentLink (productList[0].Id, contentVersion2.ContentDocumentId);
        insert cDoc;
        lstApp[0].AOB_Product__c = productList[0].Id; 
        String str = '{"documents":[{"reasonCode":"success","status":"queued","reasonDescription":"true"}]}';
        AOB_DSX.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        AOB_DSX.mockHttpStatus = 'OK';
        AOB_DSX.mockHttpbody = str;

        Test.startTest();
        String repStatus = AOB_FlowController.invokeDSXCallout(lstApp, productList);
        Database.executeBatch(new AOB_Batch_HandleDropOffs(new Set<Id>{ld.Id}));

        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Status Check against the response');

    }

    @isTest static void leadOwnerChangeToQueue() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        Test.startTest();
        Database.executeBatch(new AOB_Batch_HandleDropOffs(new Set<Id>{ld.Id}));
        Test.stopTest();  

        List<Lead> leadList = [SELECT Id, OwnerId FROM Lead WHERE Id = :ld.Id];
        List<Group> queueList = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName= 'AOB_Incomplete_account_opened'];

        Assert.areEqual(leadList[0].OwnerId, queueList[0].Id, 'Lead Owner Assignment check');

    }

    @isTest static void handleExceptionMethod() {
        Lead ld = AOB_TestDataFactory.createLead();
        insert ld;

        List<Application__c> applicationList = AOB_TestDataFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = ld.Id;
        insert applicationList;

        List<Application__c> applicationList1 = AOB_TestDataFactory.createApplication(1);
        applicationList1[0].AOB_Lead__c = ld.Id;
        applicationList1[0].AOB_Customer_Id__c = null;
        insert applicationList1;

        Test.startTest();
        AOB_Batch_HandleDropOffs scheduleInstance = new AOB_Batch_HandleDropOffs();
        String sch = '0 30 * * * ?';
        System.schedule('Drop Off Assignment', sch, scheduleInstance);
        Test.stopTest(); 
        
        List<Lead> leadList = [SELECT Id, OwnerId FROM Lead WHERE Id = :ld.Id];
        Assert.areEqual(leadList[0].OwnerId, UserInfo.getUserId(), 'Lead Owner Not Assigned to Queue Check');

    }
}