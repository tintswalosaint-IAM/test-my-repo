/**
 * @description       : Test Class for AOB_BOTS_SEL_Verification
 * @author            : Narendra Teja
 * @last modified on  : 08-04-2023
 * @last modified by  : Narendra Teja
**/
@IsTest
public with sharing class AOB_BOTS_SEL_Verification_TEST {
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
                                                    AOB_PreviousScreens__c = 'Summary',
                                                    Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}',
                                                    AOB_KeyContactPerson__c = true);
        Verification__c verify=new Verification__c();
        verify.Application__c=app.Id;
        verify.Application_Participant__c=participant.Id;
        verify.Verification_Status__c='Completed by Customer';
        insert verify;
    }
   
    /**
    * Test method for BOTS SEL.Verification__c.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldList_Test(){
        Test.startTest();
        AOB_BOTS_SEL_Verification app = new AOB_BOTS_SEL_Verification();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }
    
    /**
    * Test method for BOTS SEL.Verification__c.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectType_Test(){      
        Test.startTest();
        AOB_BOTS_SEL_Verification app = new AOB_BOTS_SEL_Verification();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Verification__c.sObjectType,typ);
    }
    
    /**
    * Test method for BOTS SEL.Verification__c.selectWithoutCondition
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectWithoutCondition_Test(){
        Test.startTest();
        AOB_BOTS_SEL_Verification app = new AOB_BOTS_SEL_Verification();
        List<Verification__c> lst = app.selectWithoutCondition();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }
    
    /**
    * Test method for BOTS SEL.Verification__c.selectVerificationByPartcipantAndNotStatus
    * Check that the created application is returned
    */
    @IsTest
    private static void selectVerificationById_TEST(){
        Verification__c newVerification = [Select Id,Application__c, Application_Participant__c from Verification__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Verification app = new AOB_BOTS_SEL_Verification();
            List<Verification__c> lst = app.selectVerificationById(New List<Id>{newVerification.Id});
            Test.stopTest();
            Assert.areEqual(newVerification.id,lst[0].id);
    }

    /**
    * Test method for BOTS SEL.Verification__c.selectVerificationByPartcipantAndNotStatus
    * Check that the created application is returned
    */
    @IsTest
    private static void selectVerificationByPartcipantAndNotStatus_Test(){
        Verification__c newVerification = [Select Id,Application__c, Application_Participant__c from Verification__c Limit 1 ];
            Test.startTest();
            AOB_BOTS_SEL_Verification app = new AOB_BOTS_SEL_Verification();
            List<Verification__c> lst = app.selectVerificationByPartcipantAndNotStatus(newVerification.Application_Participant__c, 'In Progress', 'Success');
            Test.stopTest();
            Assert.areEqual(newVerification.id,lst[0].id);
    }

    /**
    * Test method for BOTS SEL.Verification__c.selectApplicationById
    * Check that the created application is returned
    */
    @IsTest
    private static void selectVerificationByParticipantAndStatus_Test(){
        Verification__c newVerification = [Select Id,Application__c, Application_Participant__c from Verification__c Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_Verification app = new AOB_BOTS_SEL_Verification();
        List<Verification__c> lst = app.selectVerificationByParticipantAndStatus(newVerification.Application_Participant__c, 'Completed by Customer');
        Test.stopTest();
        Assert.areEqual(newVerification.id,lst[0].id);
    }

}