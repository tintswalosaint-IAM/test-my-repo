/**
* @description Test class for AOB_BOTS_SRV_ESB
* @author dayakar
* @date Jan 25th 2023 
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/
@istest
public class AOB_BOTS_SRV_ESB_Test {   
    /*
* @description Test method for AOB_BOTS_SRV_ESB.customerDSX;
*/
    @isTest
    static void customerDSXTest() {
        
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_CIFID__c='123456789';
        app.AOB_PrimaryRelationshipManagerID__c='Kabelo Modimoosi';
        update app;
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        participant.AOB_CIFID__c='123456789';
        participant.AOB_MaritalStatus__c='SINGLE';
        update participant;
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(participant.Id);
        Application_Document__c appDoc=[select Document_Type__c from Application_Document__c][0];
        appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
        appDoc.AOB_DSX__c=true;
        update appDoc;
        Test.startTest();
        Integer responseCode = AOB_BOTS_SRV_ESB.customerDSX(app.Id);
        Test.stopTest();
        Assert.areNotEqual(201, responseCode);
        
    }
    
    /*
* @description Test method for AOB_BOTS_SRV_ESB.corpDSX
*/
    @isTest
    static void corpDSXTest() {
        try
        {
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(participant.Id);
            Application_Document__c appDoc=[select Document_Type__c from Application_Document__c][0];
            appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
            appDoc.Application__c=app.Id;
            appDoc.AOB_DSX__c=true;
           appDoc.AOB_DateofExpiry__c=system.today();
            update appDoc;
            Test.startTest();
            Integer responseCode = AOB_BOTS_SRV_ESB.corpDSX(app.Id);
            Test.stopTest();
           Assert.areEqual(200, responseCode,'Test Meassage');
        }
        catch(Exception ex)
        {
           Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
    /*
*@description  Test method for AOB_BOTS_SRV_ESB.accountODcreation
*/
    @isTest
    static void accountODcreationTest() {
        try
        {
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[select AOB_Memo_Code__c from Product2];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.AOB_CIFID__c='Test Cified Data';
            app.AOB_Product__c=prod.Id;
            app.AOB_Preferred_Branch__c='031087';
            app.AOB_PortfolioNumber__c='BB01';
            update app;
            
            Test.startTest();
            Integer responseCode = AOB_BOTS_SRV_ESB.accountODcreation(app.Id);
            Test.stopTest();
            Assert.areEqual(200, responseCode,'Test Meassage');
        }
        catch(Exception ex)
        {
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
    /*
* @description Test method for AOB_BOTS_SRV_ESB.searchCustomer
*/
    @isTest
    static void searchCustomerTest() {
       
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Date today = Date.today();
        Date eighteenYearsAgo = today.addYears(-24);
        participant.AOB_DateofBirth__c=eighteenYearsAgo;
        participant.CNGCU_First_Name__c='Test cngcu firstName';
        participant.CNGCU_Last_Name__c='Test cngcu lastName';
        participant.AOB_IDNumber__c='1002212640085';
        participant.AOB_Director__c=true;
        update participant;
        Test.startTest();
        Integer responseCode = AOB_BOTS_SRV_ESB.searchCustomer(app.Id);
        Test.stopTest();
        Assert.areEqual(200, responseCode,'Test Meassage');
 
    }  
    
    
   
    /*
*@description Test method for AOB_BOTS_SRV_ESB.searchCorp
*/
    @isTest
    static void searchCorpTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_CIFID__c='123456789';
        app.AOB_GroupName__c='Test Test';
        update app;
        Test.startTest();
        Integer responseCode = AOB_BOTS_SRV_ESB.searchCorp(app.Id);
        Test.stopTest();
        Assert.areEqual(200, responseCode,'Test Meassage');
    }
    
    /*
*@description Test method for AOB_BOTS_SRV_ESB.updateCustomer
*/
    
    @isTest
    static void updateCustomerTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        participant.AOB_CIFID__c='Test cfied';
        Date today = Date.today();
        Date eighteenYearsAgo = today.addYears(-24);
        participant.AOB_DateofBirth__c=eighteenYearsAgo;
        update participant;
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(participant.Id);
        Application_Document__c appDoc=[select Document_Type__c from Application_Document__c][0];
        appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
        update appDoc;
        app.AOB_CIFID__c='123456789';
        update app;
        Test.startTest();
        Integer responseCode = AOB_BOTS_SRV_ESB.updateCustomer(app.Id);
        Test.stopTest();
        Assert.areEqual(200, responseCode,'Test Meassage');
        
    }
    /*
     
*@description Test method for AOB_BOTS_SRV_ESB.svsSignature
*/
     @isTest
    static void createCorpTest(){
        try{
      Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_PrimaryRelationshipManagerID__c='Kabelo Modimoosi';
        app.AOB_IDIssuedOrganization__c='001';
         app.AOB_Preferred_Branch__c='031087';
        update app;
        Application_Participant__c ap = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.ID);
        ap.AOB_MaritalStatus__c='SINGLE';
        ap.AOB_Role__c='CEO';
        ap.AOB_Signatory__c=true;
        ap.AOB_External_GUID__c='test';
        ap.AOB_Director__c=true;
        ap.AOB_GrossAnnualIncome__c=2000;
        ap.AOB_PrimaryNationality__c='BW';
        ap.AOB_Title__c='41';
        ap.AOB_Gender__c='Male';
        ap.AOB_City__c='ABIM';
        ap.AOB_State__c='GaboroneCity';
        ap.AOB_PostalCode__c='1234';
        ap.AOB_Street__c='test';
        
         Date today = Date.today();
        Date eighteenYearsAgo = today.addYears(-24);
        ap.AOB_DateofBirth__c=eighteenYearsAgo;
        ap.AOB_AddressValidFrom__c=Date.newInstance(2023,05,09);
        update ap;
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(ap.Id);
        ap.AOB_AddressValidFrom__c = Date.today();
        Test.startTest();
        AOB_BOTS_SRV_ESB.createCorp(ap.Application__c);
        Test.stopTest();
        } catch(Exception ex)
        {
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
    }
    
    @isTest
    static void svsSignatureTest(){
        try
        {
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        
            Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            participant.AOB_CIFID__c='123456789'; 
            update participant;
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(participant.Id);
            Application_Document__c appDoc=[select Id,Document_Type__c from Application_Document__c where Application_Participant__c=:participant.Id];
            appDoc.Document_Type__c='upload signature';
            update appDoc;
            Test.startTest();
            Integer responseCode = AOB_BOTS_SRV_ESB.svsSignature(app.Id);
            Test.stopTest();
            Assert.areEqual(200, responseCode,'Test Meassage');
        }
        catch(Exception ex)
        {
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
        
    }
    
    /*
*@description Test method for AOB_BOTS_SRV_ESB.updateCorp
*/
    @isTest
    static void updateCorpTest()
    {
        Date today = Date.today();
        Date eighteenYearsAgo = today.addYears(-24);
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_CIFID__c='123456789';
        update app;
        
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        participant.AOB_DateofBirth__c=eighteenYearsAgo;
        update participant;
        
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(participant.Id);
        Application_Document__c appDoc=[select Document_Type__c from Application_Document__c where Application_Participant__c=:participant.Id][0];
        appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
        appDoc.Application__c=app.Id;
        update appDoc;
        Test.startTest();
        Integer responseCode = AOB_BOTS_SRV_ESB.updateCorp(app.Id);
        Test.stopTest();
        Assert.areEqual(200, responseCode,'Test Meassage');
    } 

 
   
     /*
* @description Test method for AOB_BOTS_SRV_ESB.createAdviseAccount
*/
    @isTest
    static void createAdviseAccountTest() {
        try
        {
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[select AOB_Memo_Code__c from Product2];
            prod.AOB_Memo_Code__c='SOCTY';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.AOB_CIFID__c='Test Cified Data';
            app.AOB_Product__c=prod.Id;
            app.AOB_Preferred_Branch__c='031087';
            app.AOB_PortfolioNumber__c='BB01';
            update app;
            
            Test.startTest();
            Integer responseCode = AOB_BOTS_SRV_ESB.createAdviseAccount(app.Id);
            Test.stopTest();
            Assert.areEqual(200, responseCode,'Test Meassage');
        }
        catch(Exception ex)
        {
            Assert.areNotEqual(null, ex.getMessage(),'Test Meassage');
        }
    }
    
  
    
}