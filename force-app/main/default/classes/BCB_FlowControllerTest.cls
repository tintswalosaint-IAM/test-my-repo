/***************************************************************************************
@Author            :
@Date              :July 2023
@Name of the Class :BCB_FlowControllerTest
@description       :Test class for BCB_FlowController
@Last Modified By  :Ravi Myaka 
@Last Modified On  :04-04-2024
@Modification Description : SFP-37302
@Modification Description :  
***************************************************************************************/
@isTest
public with sharing class BCB_FlowControllerTest {
    /** 
* @description TestMethodCMN_MobileNumberValidate
*/
    @istest static void mobileNumberValidateTest(){
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeMobileMoneyNumberValidate(null);
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0');
    } 
    
    /** 
* @description TestMethodCMN_MobileNumberValidate
*/
    @istest static void mobileNumberValidateTest1(){
        
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> appList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        appList[0].application__c = app[0].id;
        insert appList; 
        String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"0","Description":"Successful"},"Resultz":{"CustomerReference":"256987654321","Area":"WALLET","StatusCode":"0","StatusDescription":"ACTIVE","CustomerName":"Johnson Tipiyai ","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
        CMN_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileNumberValidate.mockHttpStatus='OK';
        CMN_MobileNumberValidate.mockHttpbody=str;
        try{
        Test.startTest();
        BCB_FlowController.invokeMobileMoneyNumberValidate(appList[0].id);
        Test.stopTest();  
    }catch(exception ex){
        Assert.areNotEqual(null, appList,'Test');
    }  
        
    } 
    
    /** 
* @description TestMethod for invoking CMN_SignatureVerifyTest
*/
    
    @istest static void signatureVerifyTest(){     
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
        String str = '{"signatureAddResponse":{"signatureAddResponse":{},"accountCode":{},"customerNumber":"10000000111","employeeIdent":{},"bankCode":{},"signaturePowerNum":{},"signatureAddStatusCode":"true"}}';
        CMN_SignatureVerify.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_SignatureVerify.mockHttpStatus = 'OK';
        CMN_SignatureVerify.mockHttpbody = str;
        
        Test.startTest();
        String repStatus = BCB_FlowController.invokeSignatureVerify(lstApp[0].Id);   
        if (repStatus != null ) {
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Assert.areEqual((String)m.get('status'), 'SUCCESS', 'Response Status Check');
        } else {
            Assert.areEqual(false, 'Response is null or empty','test');
        }
        Test.stopTest();  
    }
    /** 
* @description TestMethod for invoking CMN_SignatureVerifyTest
*/
    
    @istest static void signatureVerifyTest1(){     
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeSignatureVerify(null);  
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0');
    }
    /** 
* @description TestMethod for verifySelectedFile
*/
    
    @isTest static void verifySelectedFileTest() {
        
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appList; 
        ContentVersion cv = BCB_DAL_TestFactory.createContentVersion();
        String str1 = EncodingUtil.base64Encode(cv.VersionData);
        cv.Description = str1;
        cv.Title = 'testimage.jpg';
        String str = '{"status":"SUCCESS"}';
        CMN_fileScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_fileScreening.mockHttpStatus = 'OK';
        CMN_fileScreening.mockHttpbody = str;
        Test.startTest();
        String response = BCB_FlowController.fileScreeningByParticipantId(appList[0].id, new List<ContentVersion>{cv});
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
        cv.Title = 'testimage.pgm';
        BCB_FlowController.fileScreeningByParticipantId(appList[0].id, new List<ContentVersion>{cv});
        cv.Title = 'testimage.ppm';
        BCB_FlowController.fileScreeningByParticipantId(appList[0].id, new List<ContentVersion>{cv});
        Test.stopTest();
        Assert.areEqual((String) responseMap.get('status'), 'SUCCESS', 'Status Check');
    }
     /** 
* @description TestMethod for verifySelectedFile
*/
    
    @isTest static void verifySelectedFileelseTest() {
        
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appList; 
        ContentVersion cv = BCB_DAL_TestFactory.createContentVersion();
        String str1 = EncodingUtil.base64Encode(cv.VersionData);
        cv.Description = str1;
        cv.Title = 'testimage.jpg';
        String str = '{"status":"SUCCESS"}';
        CMN_fileScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_fileScreening.mockHttpStatus = 'OK';
        CMN_fileScreening.mockHttpbody = str;
        Test.startTest();
        String response = BCB_FlowController.fileScreeningByParticipantId(appList[0].id, new List<ContentVersion>{cv});
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserialize(response, Map<String, String>.class);
        cv.Title = 'testimage.pgm';
        BCB_FlowController.fileScreeningByParticipantId(appList[0].id, new List<ContentVersion>{cv});
        cv.Title = 'testimage.ppm';
        BCB_FlowController.fileScreeningByParticipantId(null, new List<ContentVersion>{cv});
        Test.stopTest();
        Assert.areEqual((String) responseMap.get('status'), 'SUCCESS', 'Status Check');
    }
    
    /** 
*  @description TestMethod for nira
*/
    
    @istest static void niraTest(){
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        try{
        Test.startTest();
        BCB_FlowController.verifyThroughNIRA(participantList[0].Id);
        Test.stopTest();  
        }catch(exception ex){
            Assert.areNotEqual(null, participantList,'Test');
        }   
       
    }
    /** 
*  @description TestMethod for nira
*/
    
    @istest static void niraTest1(){
        
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.verifyThroughNIRA(null);
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0');
    }
    
    @istest static void niraTest2(){
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
        CMN_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_NIRA.mockHttpStatus='OK';
        CMN_NIRA.mockHttpBody=str;
        try{
        Test.startTest();
        BCB_FlowController.verifyThroughNIRA(participantList[0].id);
        
        Test.stopTest();
    }catch(exception ex){
        Assert.areNotEqual(null, participantList,'Test');
    }  
        
    }
    /** 
* @description TestMethod for customerRiskAssessment
*/
    @isTest static void customerRiskAssessment(){
        List<Application_Participant__c> applicationParticipationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert applicationParticipationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        CMN_CustomerRiskAssessment.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerRiskAssessment.mockHttpStatus='OK';
        CMN_CustomerRiskAssessment.mockHttpBody = '{"RiskScoreStatus": "48.33","RiskScoreRating": "MEDIUM"}';
        
        test.startTest();
        String serializedResponse =BCB_FlowController.invokeRiskAssessmentCallout(applicationParticipationList[0].Id,productList[0].AOB_Memo_Code__c);            
        test.stopTest();
        Assert.areNotEqual(null, serializedResponse,'Test');
    }
    
    /** 
* @description TestMethod for customerRiskAssessment
*/
    @isTest static void customerRiskAssessment1(){
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeRiskAssessmentCallout(null,null);
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0');
    }
    
    /** 
* @description TestMethod for createRetailCif
*/
    
    @istest static void createRetailCif(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        
        insert lstApp;
        
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstOfParticipants[0].AOB_CIFID__c = '';
        lstOfParticipants[0].AOB_Title__c='40';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        Indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateRetailCif.mockHttpStatus='OK';
        CMN_CreateRetailCif.mockHttpbody='{ "CustId": "10302321195","Status": "SUCCESS","Description": "Retail Customer successfully created with CIFID 10302321195"}';
        Test.startTest();
        String repStatus = BCB_FlowController.invokeCustomerCreation(lstOfParticipants[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
        
    }
    /** 
* @description TestMethod for createRetailCif
*/
    
    @istest static void createRetailCif1(){    
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeCustomerCreation(null);
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0');
        
    }
    /** 
* @description TestMethod for createCorporateCif
*/
    
    @istest static void createCorporateCif(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c = '';
        insert lstApp;
        
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstOfParticipants[0].AOB_Title__c='40';
        insert lstofParticipants;
        
        lstofParticipants[0].Application__c = lstApp[0].Id;
        update lstofParticipants;
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody='{"uuid": "20301168618","desc": "Corporate Customer successfully created with CIFID 20301168618","entity": "Corporate Customer","status": "SUCCESS"}';
        Test.startTest();
        String repStatus = BCB_FlowController.invokeCustomerCreationCorporate(lstofParticipants[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
        
    }
    /** 
* @description TestMethod for createCorporateCif
*/
    
    @istest static void createCorporateCif2(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeCustomerCreationCorporate(null);
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    }
    /** 
* @description TestMethod for createCorporateCif
*/
    @istest static void createCorporateCif1(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c = '12345567778';
        insert lstApp;
        
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstOfParticipants[0].AOB_Title__c='40';
        insert lstofParticipants;
        
        lstofParticipants[0].Application__c = lstApp[0].Id;
        update lstofParticipants;
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody='{"uuid": "20301168618","desc": "Corporate Customer successfully created with CIFID 20301168618","entity": "Corporate Customer","status": "SUCCESS"}';
        Test.startTest();
        String repStatus = BCB_FlowController.invokeCustomerCreationCorporate(lstofParticipants[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
        
    }
    /** 
*@description TestMethod for odAccountCreation
*/
    
    @istest static void odAccountCreation(){   
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].CNGCU_CSEmail__c = 'test@test.com';
        applicationList[0].AOB_Account_Number__c = '';
        insert applicationList;
        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert prodList;
        
        CMN_ODAccountCreation.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_ODAccountCreation.mockHttpStatus='OK';
        CMN_ODAccountCreation.mockHttpbody='{"ODAccountAddRes": {"ODaccountNumber": {"accountNumber": "9030022144382","accountType": {"schemaCode": {},"schemaType": {}},"accountCurrency": {},"bankInfo": { "bankId": {},"name": {},"branchId": {},"branchName": {},"postalAddress": {"line1": {},"line2": {},"line3": {},"city": {},"stateProvince": {},"postalCode": {},"country": {},"addressType": {}}}}}}';
        Test.startTest();
        BCB_FlowController.invokeGETCustomerAccountNumber(lstofParticipants[0].Id,'OD005');
        
        Test.stopTest();
        Assert.areNotEqual(null, lstofParticipants,'Test');
        
    }
    
    /** 
* @description TestMethod for createCorporateCif
*/
    
    @istest static void odAccountCreation2(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeGETCustomerAccountNumber(null,'OD005');
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    }
    /** 
*@description TestMethod for acountLockProfile
*/
    
    @isTest static void acountLockProfile() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        
        Test.startTest();
        
        string response  = BCB_FlowController.invokeAccountLockProfile(lstofParticipants[0].Id);
        
        Test.stopTest();   
        Assert.areNotEqual(null, response,'Test');
    }
    /** 
* @description TestMethod for createCorporateCif
*/
    
    @istest static void odAccountCreation3(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
             BCB_FlowController.invokeAccountLockProfile(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    }    
    /** 
*@description TestMethod for mobileWallet
*/
    
    @isTest static void mobileWallet() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='OK';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"","statusCode":"200","status":"Pending","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';
        
        
        Test.startTest();
        
        BCB_FlowController.invokeMobileWalletCallout(lstofParticipants[0].Id);
        
        Test.stopTest();  
        Assert.areNotEqual(null, lstofParticipants,'Test'); 
    }
    /** 
* @description TestMethod for createCorporateCif
*/
    
    @istest static void mobileWallet2(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeMobileWalletCallout(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    }    
    /** 
*@description TestMethod for alertCorpAdd
*/  
    @isTest static void alertCorpAdd() {
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        
        CMN_AlertCorpAdd.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_AlertCorpAdd.mockHttpStatus='OK';
        CMN_AlertCorpAdd.mockHttpBody = '{ "customerAlert": {"corporateIdentity": "","customerHostId": "FIN","legalName": "Barlow","status": "Record Added Successfully"}}';
        
        try{
            Test.startTest();
            BCB_FlowController.invokeAlertCorpAdd(participantList[0].Id);
            BCB_FlowController.invokeProfileAlertCallout(participantList[0].Id);
            Test.stopTest();  
        }catch(exception ex){
            Assert.areNotEqual(null, participantList,'Test');
        }
        
        
    }
    /** 
* @description TestMethod for alertCorpAdd
*/
    
    @istest static void alertCorpAdd2(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeAlertCorpAdd(null);
            BCB_FlowController.invokeProfileAlertCallout(null);
            
        }  
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    } 
    /** 
*@description TestMethod for alertCorpAdd
*/
    @isTest static void alertCorpelseAdd() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        CMN_AlertCorpAdd.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_AlertCorpAdd.mockHttpStatus='OK';
        CMN_AlertCorpAdd.mockHttpBody = '{ "customerAlert": {"corporateIdentity": "","customerHostId": "FIN","legalName": "Barlow","status": "Record Added Successfully"}}';
        
        try{
            Test.startTest();
            BCB_FlowController.invokeProfileAlertCallout(lstofParticipants[0].Id);
            Test.stopTest();   
        }catch(Exception ex){
            Assert.areNotEqual(null, lstofParticipants,'Test');
        }
        
        
    }
    /** 
* @description TestMethod for alertCorpAdd
*/
    
    @istest static void alertCorpelseAdd2(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.invokeProfileAlertCallout(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    } 
    /** 
*@description TestMethod for createEnterpriseCustomer
*/
    @isTest static void createEnterpriseCustomer () {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        CMN_AlertCorpAdd.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_AlertCorpAdd.mockHttpStatus='OK';
        CMN_AlertCorpAdd.mockHttpBody = '{ "customerAlert": {"corporateIdentity": "","customerHostId": "FIN","legalName": "Barlow","status": "Record Added Successfully"}}';
        
        string qung;
        try{
            Test.startTest();
            BCB_FlowController.createEnterpriseCustomer(lstofParticipants[0].Id,qung);
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test');
        }
    }
    
    /** 
*@description TestMethod for invokeIdentifiiGETDocumentsCalloutTest
*/
    @isTest
    static void invokeIdentifiiGETDocumentsCalloutTest() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        
        insert applicationList;
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].Application__c=applicationList[0].id;
        lstApp[0].AOB_Title__c='40';
        insert lstApp;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'upload signature';
        document.Application_Participant__c = lstApp[0].Id;
        insert document;
        list<ContentVersion> cvc=new list<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.VersionData =Blob.valueOf('Test Content');
        cv.Title ='upload signature';
        cv.PathOnClient = 'upload signature.pdf';
        cvc.add(cv);
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        cdl.ContentDocumentId = contentVersion.ContentDocumentId;
        cdl.LinkedEntityId = document.Id;
        cdl.ShareType = 'V';
        insert cdl;
        try{
            Test.startTest();
             BCB_FlowController.invokeIdentifiiGETDocumentsCallout(lstApp[0].Id, document.id);
            Test.stopTest();  
        }catch(exception ex){
            Assert.areNotEqual(null, ex,'Test');
        }
    }
     /** 
*@description TestMethod for invokeIdentifiiGETDocumentsCalloutTest
*/
    @isTest
    static void invokeIdentifiiGETDocumentsCalloutelseTest() {
       
        try{
            Test.startTest();
             BCB_FlowController.invokeIdentifiiGETDocumentsCallout(null, null);
            Test.stopTest();  
        }catch(exception ex){
            Assert.areNotEqual(null, ex,'Test');
        }
    }
    /** 
*@description TestMethod for selfRegistration
*/
    @isTest
    static void selfRegistrationTest() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        String mockResponse = '{"customLoginQNAResponse": {"Status": "SUCCESS"}}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));
        Test.startTest();
        String result = BCB_FlowController.selfRegistration(lstofParticipants[0].Id);
        Test.stopTest();
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Assert.areNotEqual(null, parsedStringMap,'Test');
        
    }
    /** 
* @description TestMethod for alertCorpAdd
*/
    
    @istest static void selfRegistrationTest1(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.selfRegistration(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    } 
    /** 
*@description TestMethod for assignLeadToQueue
*/
    @isTest
    static void testAssignLeadToQueue() {       
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
            insert testQueue;
        }
        Lead testLead = new Lead( FirstName = 'John',  LastName = 'Doe', Company = 'John Doe', Status = 'Open');
        insert testLead;
        Lead updatedLead = [SELECT OwnerId FROM Lead WHERE Id = :testLead.Id];
        BCB_FlowController.assignLeadToQueue(testLead.Id, 'test group');   
        Assert.areNotEqual(null, updatedLead.OwnerId, 'Lead was  assigned to the correct queue.');
    }
    
    /** 
*@description TestMethod for relyComplyIndividualScreening
*/
    @isTest
    static void relyComplyIndividualScreeningTest() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        String mockResponse = '{"assessmentStatus": "AcceptableRisk", "assessmentId": "123456"}';
        Test.setMock(HttpCalloutMock.class, new MockBCB_RelyComplyCallout(mockResponse));
        
        Test.startTest();
        String result =BCB_FlowController.relyComplyIndivididualScreening(lstofParticipants[0].Id);
        Test.stopTest();
        Assert.areNotEqual(null, result,'Test'); 
        
        
    }
    
    /** 
* @description TestMethod for alertCorpAdd
*/
    
    @istest static void relyComplyIndividualScreeningTest1(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.relyComplyIndivididualScreening(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    } 
    /** 
*@description TestMethod for MockBCB_RelyComplyCallout
*/
    private class MockBCB_RelyComplyCallout implements HttpCalloutMock {
        private String response;
        /** 
* @description TestMethod for MockBCB_RelyComplyCallout
* @param response
*/
        public MockBCB_RelyComplyCallout(String response) {
            this.response = response;
        }
        /** 
*@description TestMethod for respond
*@param req
*@return HTTPResponse
*/
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    /** 
*@description TestMethod for relyComplyBusinessScreeningTest
*/
    @isTest
    static void relyComplyBusinessScreeningTest() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_RegistrationNumber__c = '2344/754983/4756';
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest();
        String result =BCB_FlowController.relyComplyBusinessScreening(lstofParticipants[0].Id);
        Test.stopTest();
        Assert.areNotEqual(null, result,'Test'); 
        
    }
    /** 
*@description TestMethod for relyComplyBusinessScreeningTest
*/
    @istest static void relyComplyBusinessScreeningTest1(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.relyComplyBusinessScreening(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'List index out of bounds: 0'); 
        
    }    
    
    
    /** 
*@description TestMethod for fileScreeningByDocumentListTest
*/
    @isTest
    static void fileScreeningByDocumentListTest() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Liveness_Matched__c=true;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        Application_Document__c appDoc = new Application_Document__c(Application_Participant__c = lstofParticipants[0].id);
        insert appDoc;
        List<ContentVersion> cvs = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cvs.add(cv);
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id,ContentDocumentId,VersionData  FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = appDoc.Id;
        insert cdl;
        try{
            Test.startTest();
            BCB_FlowController.fileScreeningByDocumentList(cvs);
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
    }
    /** 
*@description TestMethod for relyComplyBusinessScreeningTest
*/
    @istest static void fileScreeningByDocumentListTest1(){   
        BCB_CustomException unexpectedException;
        Test.startTest();
        try
        { 
            BCB_FlowController.fileScreeningByDocumentList(null);
            
        }
        catch (BCB_CustomException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        Assert.areEqual(unexpectedException.getMessage(), 'Attempt to de-reference a null object'); 
        
    }    
    
    /** 
*@description TestMethod for relyComplyFetchAssessmentTest
*/
    @isTest static void relyComplyFetchAssessmentTest(){
        
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        
        CMN_RelyComplyFetchAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyFetchAssessment.mockHttpStatus='OK';
        CMN_RelyComplyFetchAssessment.mockHttpBody ='{"assessmentId": "2361823","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';
        
        Test.startTest();
        String serializedResponse =BCB_FlowController.relyComplyFetchAssessment(participantList[0].Id,'Uganda MVP2 Company Details');    
        Test.stopTest();
        Assert.areNotEqual(null, serializedResponse,'Test'); 
    }
    
    /** 
*@description TestMethod for relyComplyFetchAssessmentTest2
*/
    @isTest static void relyComplyFetchAssessmentTest2(){
        
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        string response = '{"assessmentId": "2361823","assessmentStatus":"Success","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';
        map<string,Object> parsedStringMap  = (map<string,object>)json.deserializeUntyped(response) ;
        participantList[0].Inflight__c = '{ "individualAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
        insert participantList;
        
        CMN_RelyComplyFetchAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyFetchAssessment.mockHttpStatus='OK';
        CMN_RelyComplyFetchAssessment.mockHttpBody ='{"assessmentId": "2361823","assessmentStatus":"Success","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';
        
        Test.startTest();
        String serializedResponse =BCB_FlowController.relyComplyFetchAssessment(participantList[0].Id,'Uganda MVP2 Personal Details');    
        Test.stopTest();
        Assert.areNotEqual(null, serializedResponse,'Test'); 
    }
    
    /** 
*@description TestMethod for MockBCB_RelyComplyFetchAssessment
*/  
    public class MockBCB_RelyComplyFetchAssessment implements HttpCalloutMock {
        private String mockResponse;
        
        /** 
*@description TestMethod for MockBCB_RelyComplyFetchAssessment
*@param mockResponse
*/
        public MockBCB_RelyComplyFetchAssessment(String mockResponse) {
            this.mockResponse = mockResponse;
        }
        /** 
*@description TestMethod for MockBCB_RelyComplyFetchAssessment
*@param req
*@return HTTPResponse
*/
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
    /** 
*@description TestMethod for testUpdateVerificationStatus
*/  
    @isTest
    static void testUpdateVerificationStatus() {
        // Create test data for the Verification__c object
        Verification__c testVerification = new Verification__c(
            
        );
        insert testVerification;
        
        Test.startTest();
        try {
            List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
            insert applications;
            List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
            insert participantList;
            // Provide the necessary parameters for the method
            String verificationRecordId = testVerification.Id;
            String status = 'New Status'; // Replace with the desired status
            String documentId = 'Test Document Id'; // Replace with the desired documentId
            BCB_FlowController.updateVerificationStatus(verificationRecordId, status, documentId);
            BCB_FlowController.fetchingVerificationRecord();
        } catch (Exception ex) {
            Assert.areNotEqual(null,ex.getMessage(),'Test');
        }
        Test.stopTest();
        
        
    }
     /** 
*@description TestMethod for testUpdateVerificationStatus
*/  
    @isTest
    static void testUpdateVerificationStatuselse() {
        // Create test data for the Verification__c object
        Verification__c testVerification = new Verification__c(
            
        );
        insert testVerification;
        
        Test.startTest();
        try {
            BCB_FlowController.fetchingVerificationRecord();
        } catch (Exception ex) {
            Assert.areNotEqual(null,ex.getMessage(),'Test');
        }
        Test.stopTest();
        
        
    }
    /** 
*@description TestMethod for alertCorpProfile
*/ 
    @isTest static void alertCorpProfile() {
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        CMN_CustomerAlertsProfile.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertsProfile.mockHttpStatus='OK';
        CMN_CustomerAlertsProfile.mockHttpBody = '{"Status": "S000000001","Description": "Record Added Successfully"}';
        
        
        Test.startTest();
        
        
        Test.stopTest(); 
        Assert.areNotEqual(null,lstofParticipants,'Test');  
    }
    /** 
*@description TestMethod for invokeIdentifiiCallouttest
*/ 
    @istest  static void invokeIdentifiiCallouttest() {
        List<Application_Participant__c> appList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        
        insert appList;
        list<string> appIdList = new list<string>();
        appIdList.add(appList[0].id);
        Test.startTest();
        String repStatus = CMN_IdentifiiApplicant.invocableMethod(appList);
        Test.stopTest();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Assert.areEqual((String)m.get('status'), 'Success','The status should be Success');
    }
    /** 
*@description TestMethod for invokeIdentifiiCalloutTestException
*/ 
    @isTest static void invokeIdentifiiCalloutTestException() {
        List<Application__c> appList=BCB_DAL_TestFactory.createApplication(1);
        insert appList;
        AOB_AccessTokenGenerator.mockHttpStatusCode = CMN_API_HttpBase.HTTP_Ok;
        AOB_AccessTokenGenerator.mockHttpStatus = 'OK';
        AOB_AccessTokenGenerator.mockHttpbody = '';
        Test.startTest();
        try {
            BCB_FlowController.invokeIdentifiiCallout(appList[0].id);
        } catch(Exception e) {
            Assert.areNotEqual(null,e.getMessage(),'Test');
        }        
        Test.stopTest();
    }
     /** 
*@description TestMethod for invokeIdentifiiCalloutTestException
*/ 
    @isTest static void invokeIdentifiiCalloutelseTest() {
        List<Application__c> appList=BCB_DAL_TestFactory.createApplication(1);
        insert appList;
        AOB_AccessTokenGenerator.mockHttpStatusCode = CMN_API_HttpBase.HTTP_Ok;
        AOB_AccessTokenGenerator.mockHttpStatus = 'OK';
        AOB_AccessTokenGenerator.mockHttpbody = '';
        Test.startTest();
        try {
            BCB_FlowController.invokeIdentifiiCallout(null);
        } catch(Exception e) {
            Assert.areNotEqual(null,e.getMessage(),'Test');
        }        
        Test.stopTest();
    }
    /** 
*@description TestMethod for bcbSELApplicationDocumentTest
*/ 
    @isTest static void bcbSELApplicationDocumentTest() {
        List<Application__c> appList=BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> partList = BCB_DAL_TestFactory.createApplicationParticipant(1);
        List<Application_Document__c> doc = new  List<Application_Document__c>(); 
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application_Participant__c = partList[0].Id;
        doc.add(document);
        insert doc;
        list<id> i = new list<id>();
        i.add(doc[0].id);
        List<Application_Document__c> s=new SEL_ApplicationDocument().selectAppsByIdApplication(appList[0].id);
        List<Application_Document__c> s1= new SEL_ApplicationDocument().selectApplicationDocumentById( i);
        List<Application_Document__c> s2=new SEL_ApplicationDocument().selectAppsByIdAndDoctype(appList[0].id,doc[0].Document_Type__c );
        List<Application_Document__c> s3= new SEL_ApplicationDocument().selectAppsByIdApplication( appList[0].id);
        List<Application_Document__c> s4= new SEL_ApplicationDocument().selectAppsByIdApplicationParcipant( partList[0].id);
        List<Application_Document__c> s5=new SEL_ApplicationDocument().selectAppsParticipantByIdAndDoctype(partList[0].id,doc[0].Document_Type__c );
        
        Assert.areNotEqual(null,s,'Test');
        Assert.areNotEqual(null,s1,'Test');
        Assert.areNotEqual(null,s2,'Test');
        Assert.areNotEqual(null,s3,'Test');
        Assert.areNotEqual(null,s4,'Test');
        Assert.areNotEqual(null,s5,'Test');
    }
    /** 
*@description TestMethod for bcbSELApplicationLineItemTest
*/ 
    
    @isTest static void bcbSELApplicationLineItemTest() {
        List<Application__c> appList=BCB_DAL_TestFactory.createApplication(1);
        insert appList;
        List<Application_Line_Item__c> data = new List<Application_Line_Item__c>();
        
        data.add(new Application_Line_Item__c(
            Application__c = appList[0].id,
            Name = 'accessToMarkets',
            AOB_Status__c = 'Accepted'
        ));
        insert data;
        list<id> i = new list<id>();
        i.add(data[0].id);
        List<Application_Line_Item__c> s=new SEL_ApplicationLineItem().selectApplicationLineItemById(data[0].id);
        List<Application_Line_Item__c> s1= new SEL_ApplicationLineItem().selectApplicationLineItemByIds( i);
        List<Application_Line_Item__c> s2=new SEL_ApplicationLineItem().selectApplicationLineItemByApplicationId(appList[0].id);
        List<Application_Line_Item__c> s3= new SEL_ApplicationLineItem().selectApplicationLineItemByFilter( appList[0].id, true);
        
        
        Assert.areNotEqual(null,s,'Test');
        Assert.areNotEqual(null,s1,'Test');
        Assert.areNotEqual(null,s2,'Test');
        Assert.areNotEqual(null,s3,'Test');
        
    }
    
    
    /** 
*@description TestMethod for MockHttpResponseGenerator
*/ 
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private String response;
        
        /** 
*@description TestMethod for MockHttpResponseGenerator
*@param response
*/
        public MockHttpResponseGenerator(String response) {
            this.response = response;
        }
        
        /** 
*@description TestMethod for MockHttpResponseGenerator
*@param req
*@return HttpResponse
*/
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(200);
            return res;
        }
    }
    /** 
*@description TestMethod for exception class
*/
    @isTest
    static void testCustomException() {
        try {
            throw new BCB_CustomException('This is a custom exception message.');
        } catch (BCB_CustomException ex) {
           Assert.areEqual('This is a custom exception message.', ex.getMessage());
            Assert.areEqual('', ex.param);
        }
    }
    /** 
*@description TestMethod for exception class
*/
    @isTest
    static void imageTypeClassTest() {
        BCB_Identify_BodyBean.Body bodyInstance = new BCB_Identify_BodyBean.Body();
        bodyInstance.ApplicationId = '123';
        bodyInstance.IdNumber = '456';
        bodyInstance.ClientReference = '789';
        bodyInstance.DHACheckDisabled = 0;
        bodyInstance.IDValidationDisabled = 1;
        
        BCB_Identify_BodyBean.Response responseInstance = new BCB_Identify_BodyBean.Response();
        responseInstance.LivenessFRMatch = true;
        responseInstance.LivenessFRScore = 0.95;
        
        BCB_Identify_BodyBean.IdentityImages identityImagesInstance = new BCB_Identify_BodyBean.IdentityImages();
        identityImagesInstance.ID = '123';
        identityImagesInstance.IdentityID = '456';
        
        BCB_Identify_BodyBean.ImageType imageTypeInstance = new BCB_Identify_BodyBean.ImageType();
        imageTypeInstance.Description = 'Sample Description';
        imageTypeInstance.ID = '789';
    }
    
    /**
* @description TestMethod for invoking CMN_DSXTest
*/
    @istest static void testDSX1(){     
        List<Application__c> appList=BCB_DAL_TestFactory.createApplication(1);
        insert appList;
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstApp[0].application__c=appList[0].id;
        insert lstApp;
        Application_Document__c document = new Application_Document__c();
        document.Document_Type__c = 'FaceImage';
        document.Application__c = lstApp[0].application__c;
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
        String repStatus = BCB_FlowController.invokeDSXapplicationId(lstApp[0].id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
    /**
* @description TestMethod for invoking CMN_DSXTest
*/
    @istest static void testDSX2(){     
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
        String repStatus = BCB_FlowController.invokeDSXparticipantId(lstApp[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();  
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
     /**
* @description TestMethod for invoking CMN_DSXTest
*/
    @istest static void testDSX23(){     
        try{
        Test.startTest();
        String repStatus = BCB_FlowController.invokeDSXparticipantId(null);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        }catch(exception e){}
    }
     /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod6() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='SUCCESS';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;       
        Test.startTest(); 
         BCB_FlowController.invokeMobileWalletCallout(lstofParticipants[0].Id);
        Test.stopTest(); 
        Assert.areNotEqual(null, lstofParticipants,'Test');        
    }
    /** 
@description Test Class for BCB_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod7() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='SUCCESS';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"", "status": "FAILED","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","statusCode":"01"}';        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;       
        try{
            Test.startTest(); 
            BCB_FlowController.invokeMobileWalletCallout(lstofParticipants[0].Id);
            //System.enqueueJob(new BCB_MobileWalletQueueable(applicationList,lstofParticipants));          
            Test.stopTest();  
        }catch(Exception ex){
            Assert.areNotEqual(null, lstofParticipants,'Test'); 
        }
    }
    
     /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod5(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"Pending","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        try{
             Test.startTest();
        		BCB_FlowController.invokeMobileWalletStatusCallout(lstAppParticipants[0].Id,str);
        	Test.stopTest();
        }catch(Exception ex){
            Assert.areNotEqual(null, lstApp,'Test');
        }   
    }
    
    /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod6(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
         List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"FAILED","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        try{
           Test.startTest();
        		BCB_FlowController.invokeMobileWalletStatusCallout(lstAppParticipants[0].Id,str); 
        	Test.stopTest(); 
        }catch(Exception ex){
            Assert.areNotEqual(null, lstApp,'Test');
        }      
    }
     /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod7(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        try{
            Test.startTest();
        		BCB_FlowController.invokeMobileWalletStatusCallout(lstAppParticipants[0].Id,str);        
        	Test.stopTest();
        }catch(exception ex){
             Assert.areNotEqual(null, lstApp,'Test');
        }   
    }
    /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod8(){  
        try{
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
            List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        BCB_FlowController.invokeMobileWalletStatusCallout(lstAppParticipants[0].Id,str);
        
        Test.stopTest();
        }catch(exception dmx){
             Assert.areNotEqual(null, dmx.getMessage());
        }
        
    }
         /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @isTest
    static void testCallInvocableMethod10() {
        
        CMN_CustomerAlertSubscription.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertSubscription.mockHttpStatus='SUCCESS';
        CMN_CustomerAlertSubscription.mockHttpBody = '{"customerAlert": {"CustomData": ""},"errorCode": "S000000001","statusMsg": "Record Added Successfully"}';       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;         
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
           lstofParticipants[0].Application__c = applicationList[0].Id;
           insert lstofParticipants;        
        Test.startTest(); 
        BCB_FlowController.invokeAlertSubscriptionCallout(lstofParticipants[0].Id);
        Test.stopTest(); 
        Assert.areNotEqual(lstofParticipants, null,'It should Not be null');      
    }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @isTest
    static void testCallInvocableMethod9() {
        
        CMN_CustomerAlertSubscription.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertSubscription.mockHttpStatus='SUCCESS';
        CMN_CustomerAlertSubscription.mockHttpBody = '{"customerAlert": {"CustomData": ""},"ErrorDescription": "S000000001","statusMsg": "Record Added Successfully"}';       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
           lstofParticipants[0].Application__c = applicationList[0].Id;
           insert lstofParticipants;
        try{
            Test.startTest();
            BCB_FlowController.invokeAlertSubscriptionCallout(lstofParticipants[0].Id);
        Test.stopTest();
        }catch(Exception ex){
            Assert.areNotEqual(lstofParticipants, null,'It should Not be null'); 
        }     
    }
}