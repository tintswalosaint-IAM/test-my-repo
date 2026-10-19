/**
* @description       : Test Class for AOB_BOTS_SEL_ApplicationDocument
* @author            : Narendra Teja
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/
@IsTest
public with sharing class AOB_BOTS_SEL_ApplicationDocument_TEST {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        app.Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}';
        insert app;
        Application_Participant__c participant = new Application_Participant__c(
                                                    CNGCU_Phone__c = '+27123456789',
                                                    CNGCU_Email__c = 'test@example.com',
                                                    Application__c = app.Id,
                                                    AOB_PostalCode__c='473653',
                                                    AOB_TransactOnTheBusiness__c=true,
                                                    AOB_Signatory__c=true,
                                                    AOB_PreviousScreens__c = 'Summary',
                                                    Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}',
                                                    AOB_KeyContactPerson__c = true);
        insert participant;
        Application_Document__c appDoc = new Application_Document__c(Application__c= app.Id ,Application_Participant__c = participant.Id, Document_Type__c='Debit Card Application');
        insert appDoc;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = appDoc.Id;
        insert cdl;
        
    }
   
    /**
    * Test method for BOTS SEL.ApplicationDocument.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldList_Test(){
        Test.startTest();
        AOB_BOTS_SEL_ApplicationDocument app = new AOB_BOTS_SEL_ApplicationDocument();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * Test method for BOTS SEL.ApplicationDocument.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectType_Test(){      
        Test.startTest();
        AOB_BOTS_SEL_ApplicationDocument app = new AOB_BOTS_SEL_ApplicationDocument();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Application_Document__c.sObjectType,typ);
    }
    
    /**
    * Test method for BOTS SEL.ApplicationDocument.selectApplicationDocumentById
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectApplicationDocumentById_Test(){
        Application_Document__c newDocument = [Select Id,Application_Participant__c from Application_Document__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationDocument app = new AOB_BOTS_SEL_ApplicationDocument();
        List<Application_Document__c> lst = app.selectApplicationDocumentById(New List<Id>{newDocument.Id});
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }

    /**
    * Test method for BOTS SEL.ApplicationDocument.selectAppsByIdAndDoctype
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectAppsByIdAndDoctype_Test(){
        Application_Document__c newDocument = [Select Id,Application_Participant__c, Document_Type__c  from Application_Document__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationDocument app = new AOB_BOTS_SEL_ApplicationDocument();
        List<Application_Document__c> lst = app.selectAppsByIdAndDoctype(newDocument.Id, newDocument.Document_Type__c);
        Test.stopTest();
        Assert.areEqual(0,lst.size(),'successful-application/s returned');
    }

    /**
    * Test method for BOTS SEL.ApplicationDocument.selectAppsByIdApplication
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectAppsByIdApplication_Test(){
        Application_Document__c newDocument = [Select Id,Application__c, Application_Participant__c from Application_Document__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationDocument app = new AOB_BOTS_SEL_ApplicationDocument();
        List<Application_Document__c> lst = app.selectAppsByIdApplication(newDocument.Application__c);
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }

    /**
    * Test method for BOTS SEL.ApplicationDocument.selectAppsByIdApplicationParcipant
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectAppsByIdApplicationParcipant_Test(){
        Application_Document__c newDocument = [Select Id,Application_Participant__c from Application_Document__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationDocument app = new AOB_BOTS_SEL_ApplicationDocument();
        List<Application_Document__c> lst = app.selectAppsByIdApplicationParcipant(newDocument.Application_Participant__c);
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }
    
    
}