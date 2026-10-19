/**
* @description       : Test Class for AOB_BOTS_SEL_ApplicationParticipant
* @author            : Narendra Teja
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-09-2024
* @ Modification Description : added new test data methods
*/
@IsTest
public with sharing class AOB_BOTS_SEL_ApplicationParticipant_TEST {
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
            										AOB_IDNumber__c='1',
                                                    AOB_PreviousScreens__c = 'Summary',
                                                    Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}',
                                                    AOB_KeyContactPerson__c = true);
        insert participant;
        
    }
   
    /**
    * Test method for BOTS SEL.Application.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldList_Test(){
        Test.startTest();
        AOB_BOTS_SEL_ApplicationParticipant app = new AOB_BOTS_SEL_ApplicationParticipant();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * Test method for BOTS SEL.Application.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectType_Test(){      
        Test.startTest();
        AOB_BOTS_SEL_ApplicationParticipant app = new AOB_BOTS_SEL_ApplicationParticipant();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Application_Participant__c.sObjectType,typ,'checking the SEL_ApplicationParticipant with type of object');
    }
    
    /**
    * Test method for BOTS SEL.Application.selectApplicationParticipantById
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectApplicationParticipantById_Test(){
        Application_Participant__c newParticipant = [Select Id,CNGCU_Phone__c,AOB_IDNumber__c, CNGCU_Email__c, Application__c,AOB_PostalCode__c,AOB_TransactOnTheBusiness__c,AOB_PreviousScreens__c,Inflight__c,AOB_KeyContactPerson__c from Application_Participant__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationParticipant app = new AOB_BOTS_SEL_ApplicationParticipant();
        List<Application_Participant__c> lst = app.selectApplicationParticipantById(New List<ID>{newParticipant.Id});
        List<Application_Participant__c> appListbyId=app.selectApplicationParticpantById(newParticipant.Id);
        Application_Participant__c appdataById=app.selectApplicationParticipant(newParticipant.Id);
        List<Application_Participant__c> appListbyIdandPhone =app.selectApplicationParticpantByAppAndPhone(newParticipant.Application__c,newParticipant.CNGCU_Phone__c);
        List<Application_Participant__c> appListbyIdandKeyContact =app.selectApplicationParticpantByKeyContact(newParticipant.Application__c,true);
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
        Assert.areEqual(appListbyId[0].CNGCU_Phone__c,'+27123456789','Phone number should match excpected one');
        Assert.areEqual(appdataById.CNGCU_Email__c,'test@example.com','Email should match excpected one');
        Assert.areEqual(appListbyIdandPhone[0].AOB_PostalCode__c,'473653','postal code should match excpected one');
        Assert.areEqual(appListbyIdandKeyContact[0].AOB_Signatory__c,true,'Signatory  should match excpected one');
    }
    
    /**
    * Test method for BOTS SEL.Application.selectApplicationParticpantByApplicationId
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationParticpantByApplicationId_Test(){
        Application_Participant__c newParticipant = [Select Id,CNGCU_Phone__c, CNGCU_Email__c, Application__c,AOB_PostalCode__c,AOB_TransactOnTheBusiness__c,AOB_PreviousScreens__c,Inflight__c,AOB_KeyContactPerson__c from Application_Participant__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationParticipant app = new AOB_BOTS_SEL_ApplicationParticipant();
        List<Application_Participant__c> lst = app.selectApplicationParticpantByApplicationId(newParticipant.Application__c);
        Test.stopTest();
        Assert.areEqual(newParticipant.id,lst[0].id);
    }

    /**
    * Test method for BOTS SEL.Application.selectApplicationParticpantByApplicationName
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationParticpantByApplicationName_Test(){
        Application_Participant__c newParticipant = [Select Id,CNGCU_Phone__c, CNGCU_Email__c,Application__r.Name, Application__c,AOB_PostalCode__c,AOB_TransactOnTheBusiness__c,AOB_PreviousScreens__c,Inflight__c,AOB_KeyContactPerson__c from Application_Participant__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationParticipant app = new AOB_BOTS_SEL_ApplicationParticipant();
        List<Application_Participant__c> lst = app.selectApplicationParticpantByApplicationName(newParticipant.Application__r.Name);
        Test.stopTest();
        Assert.areEqual(newParticipant.id,lst[0].id);
    }

    /**
    * Test method for BOTS SEL.Application.selectApplicationParticpantByApplicationIdSign
    * Check that the created application is returned
    */
    @IsTest
    private static void selectApplicationParticpantByApplicationIdSign_Test()
    {
        Application_Participant__c newParticipant = [Select Id,CNGCU_Phone__c, CNGCU_Email__c, Application__c,AOB_PostalCode__c,AOB_TransactOnTheBusiness__c,AOB_PreviousScreens__c,Inflight__c,AOB_KeyContactPerson__c from Application_Participant__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ApplicationParticipant app = new AOB_BOTS_SEL_ApplicationParticipant();
        List<Application_Participant__c> lst = app.selectApplicationParticpantByApplicationIdSign(newParticipant.Application__c, true);
        Test.stopTest();
        Assert.areEqual(newParticipant.Application__c,lst[0].Application__c);        
    }
}