/**
* @description       : Test Class for AOB_BOTS_SEL_Application
* @author            : Narendra Teja
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/

@IsTest
public with sharing class AOB_BOTS_SEL_Application_TEST {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        Lead leadRec = new Lead(Company = 'Prox', LastName = 'Prox');
        insert leadRec;
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        app.AOB_Lead__c=leadRec.Id;
        app.Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}';
        insert app;
    }
   
    /**
    * @description Test method for BOTS SEL.Application.getSObjectFieldList
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * @description Test method for BOTS SEL.Application.getSObjectType
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        Test.startTest();
        AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Application__c.sObjectType,typ);
    }
    
    /**
    * @description Test method for BOTS SEL.Application.selectWithoutCondition
    */
    @IsTest
    private static void selectWithoutConditionTest(){
        Test.startTest();
        AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
        List<Application__c> lst = app.selectWithoutCondition();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }
    
    /**
    * @description Test method for BOTS SEL.Application.selectAppsById
    */
    @IsTest
    private static void selectAppsByIdTest(){
        try{
        Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Lead__c, Inflight__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectAppsById(newApplication.id);
            Test.stopTest();
              Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    

    /**
    * @description Test method for BOTS SEL.Application.selectApplicationById
    */
    @IsTest
    private static void selectApplicationByIdTest(){
        try{
        Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Lead__c, Inflight__c from Application__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
        List<Application__c> lst = app.selectApplicationById(New List<Id>{newApplication.id});
              Assert.areEqual(false, lst,'test message');
        Test.stopTest();
        }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }

    /**
    * @description Test method for BOTS SEL.Application.selectApplicationByLeadId
    */
    @IsTest
    private static void selectApplicationByLeadIdTest()
    {
        try{
        Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Lead__c, Inflight__c from Application__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
        List<Application__c> lst = app.selectApplicationByLeadId(New List<Id>{newApplication.AOB_Lead__c});
        Test.stopTest();
             Assert.areEqual(false, lst,'test message');
         }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }        
    }
  
     @IsTest
    private static void selectApplicationByStatusAndSchemaCodeTest()
    {
        try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Lead__c,AOB_Schema_Code__c,Status__c, Inflight__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectApplicationByStatusAndSchemaCode(newApplication.Status__c,newApplication.AOB_Schema_Code__c);
            Test.stopTest();
              Assert.areEqual(false, lst,'test message');
            }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }     
    }
      @IsTest
    private static void selectApplicationByRegAndSchemaCodeListTest()
    {
        try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Schema_Code__c,Status__c, Inflight__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectApplicationByRegAndSchemaCodeList(newApplication.AOB_RegistrationNumber__c,newApplication.AOB_Schema_Code__c);
            Test.stopTest();
              Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }    
    }
      @IsTest
    private static void selectApplicationByRegAndStageTest()
    {
        try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Schema_Code__c,AOB_Stage__c, Inflight__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectApplicationByRegAndStage(newApplication.AOB_RegistrationNumber__c,newApplication.AOB_Stage__c);
            Test.stopTest();
              Assert.areEqual(false, lst,'test message');
            }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }  
    }
        @IsTest
    private static void selectApplicationByOnlyRegTest()
    {
         try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c, AOB_Schema_Code__c,AOB_Stage__c, Inflight__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectApplicationByOnlyReg(newApplication.AOB_RegistrationNumber__c);
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
    @IsTest
    private static void selectApplicationByGroupAndSchemaCodeTest()
    {
         try{
           Application__c newApplication = [Select Id,AOB_GroupName__c, AOB_Schema_Code__c,AOB_Stage__c, Inflight__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectApplicationByGroupAndSchemaCode(newApplication.AOB_GroupName__c,newApplication.AOB_Schema_Code__c);
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
    @IsTest
    private static void getCorpDsxApllicationsTest()
    {
         try{
           Application__c newApplication = [select Id,AOB_PrimaryRelationshipManagerID__c,AOB_CIFID__c,(select Id,Document_Type__c,AOB_DateofExpiry__c,AOB_DSX__c from Application_Documents__r where AOB_DSX__c=true) from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.getCorpDsxApllications(newApplication.Id);
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
            @IsTest
    private static void selectApplicationByOnlyRegListTest()
    {
         try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c,AOB_Stage__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
             List<Application__c> lst = app.selectApplicationByOnlyRegList(new Set<String>{newApplication.AOB_RegistrationNumber__c});
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
        @IsTest
    private static void selectApplicationByregistrationNumberTest()
    {
         try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c,AOB_Stage__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
             List<Application__c> lst = app.selectApplicationByregistrationNumber(new Set<String>{newApplication.AOB_RegistrationNumber__c});
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
    @IsTest
    private static void selectApplicationByRegAndSchemaCodeTest()
    {
         try{
           Application__c newApplication = [Select Id,AOB_RegistrationNumber__c,AOB_Stage__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
             Application__c lst = app.selectApplicationByRegAndSchemaCode(newApplication.AOB_RegistrationNumber__c,newApplication.AOB_Stage__c);
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
     @IsTest
    private static void selectAppByIdTest()
    {
         try{
           Application__c newApplication = [select Id,AOB_RegistrationNumber__c,AOB_Stage__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            Application__c lst = app.selectAppById(newApplication.Id);
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
         @IsTest
    private static void selectByGroupNameAndStageTest()
    {
         try{
           Application__c newApplication = [select Id,AOB_GroupName__c,AOB_Stage__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
            List<Application__c> lst = app.selectByGroupNameAndStage(newApplication.AOB_GroupName__c, newApplication.AOB_Stage__c);
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
    
    @IsTest
    private static void selectApplicationByOnlyGroupTest()
    {
         try{
           Application__c newApplication = [select Id,AOB_GroupName__c,AOB_Stage__c from Application__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Application app = new AOB_BOTS_SEL_Application();
             List<Application__c> lst = app.selectApplicationByOnlyGroup(new Set<String>{newApplication.AOB_GroupName__c});
            Test.stopTest();
               Assert.areEqual(false, lst,'test message');
             }catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }      
    }
}