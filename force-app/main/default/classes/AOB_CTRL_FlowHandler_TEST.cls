/**
 * @description Test class for the flow Handler controller
 * <p/>
 * 
 *
 * @see AOB_CTRL_FlowHandler
 *
 * @author Salesforce
 *
 * @date December 2020
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed N/A       22-06-2022 Gill Lumley   Restore new methods that were overwritten when prod was restored for Ping investigation
 */
@isTest
public class AOB_CTRL_FlowHandler_TEST {

    /**
    * @description test setup method createds application and product config data 
    */
    @TestSetup
    static void makeData(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        System.runAs(communityUser){
         
            Map<String,String> objectData=new Map<string,string>{'Name'=>'Name TEST'};
            Product2 produit=(Product2)AOB_DAL_TesTFactory.genericObjectCreation('Product2',objectData);
            insert produit;
        
            objectData = new Map<string,string>{'AOB_Customer__c'=> acc.id,'AOB_TECH_FlowNames__c'=>'AOB_BeforeWeBegin,AOB_PersonalDetails,AOB_CardPersonalisation,AOB_CardDetails,AOB_CardFinalOffer','AOB_CurrentScreen__c'=>'Final Offer','AOB_PreviousScreen__c'=>'Debit Order Details'};
            AOB_Application__c app = (AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',objectData);
            insert app;

            objectData = new Map<string,string>{'AOB_Application__c'=> app.id,'AOB_Product__c'=>produit.id};
            insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_ApplicationLineItem__c',objectData);

            objectData = new Map<string,string>{'AOB_FlowType__c'=>'Account Origination','AOB_Label__c'=>'Personal Details','AOB_ScreenFlowAPIName__c'=>'AOB_PersonalDetails'};
            AOB_FlowsConfigurator__c flowConf = (AOB_FlowsConfigurator__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_FlowsConfigurator__c',objectData);
            flowConf.AOB_TECH_ShowBackButton__c = true;
            insert flowConf;
            objectData = new Map<string,string>{'AOB_FlowsConfigurator__c'=> flowConf.Id,'AOB_Product__c'=>produit.Id};
            AOB_ProductConfigurators__c prodConfigurators = (AOB_ProductConfigurators__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_ProductConfigurators__c',objectData);
            insert prodConfigurators;
        }
    }
    /**
    * @description test method for AOB_CTRL_FlowHandler.getFlows
    */
    @isTest
    static void getFlowsTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];

        System.runAs(communityUser) {
            Test.startTest();
            Object flow = AOB_CTRL_FlowHandler.getFlows(app.Id);
            Test.stopTest();
            System.assertNotEquals(null, flow, 'No flow found');
        }
    }
    
    /**
    * @description test method for AOB_CTRL_FlowHandler.getFlows exception
    */
    @isTest
    static void getFlowsFailTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc=[SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
        AuraHandledException unexpectedException;

        System.runAs(communityUser) {
        app.AOB_TECH_WFRStatus__c = AOB_Constants.WFR_DONE_STATUS;
        update app;
        Test.startTest();
        try
        { 
            Object flow = AOB_CTRL_FlowHandler.getFlows(null);
        }
        catch (AuraHandledException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
        } 
    }
    
    /**
    * @description test method for AOB_CTRL_FlowHandler.goBacktoPreviousFlow
    */
    @isTest
    static void goBacktoPreviousFlowTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        AOB_Application__c  app = [SELECT Id , AOB_PreviousScreen__c, AOB_CurrentScreen__c , AOB_TECH_NumOfScreens__c FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
        final String expectedScreen = 'Personal Details';

        System.runAs(communityUser) {
            Test.startTest();
            AOB_CTRL_FlowHandler.goBacktoPreviousFlow(app.Id,2);
            Test.stopTest();
            app = [SELECT Id , AOB_PreviousScreen__c, AOB_CurrentScreen__c , AOB_TECH_NumOfScreens__c FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
            System.assertEquals(expectedScreen, app.AOB_CurrentScreen__c, 'Wrong AOB_CurrentScreen__c');
        }
    }
    
    /**
    * @description test method for AOB_CTRL_FlowHandler.initFlowNames
    */
    @isTest
    static void initFlowNamesTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        AOB_Application__c  app = [SELECT Id , AOB_PreviousScreen__c, AOB_CurrentScreen__c , AOB_TECH_NumOfScreens__c FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_CTRL_FlowHandler.Flows flows =  AOB_CTRL_FlowHandler.initFlowNames(app.id);
            Test.stopTest();
            System.assertNotEquals(flows,null,'');
        }
    }
    
    /**
    * @description test method for AOB_CTRL_FlowHandler.getAdobeInfo
    */
    @isTest
    static void getAdobeInfoTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        System.runAs(communityUser) {
            Test.startTest();
            String adobeInfoObj =  AOB_CTRL_FlowHandler.getAdobeInfo();
            Test.stopTest();
            System.assertEquals('{"encryptedUsername":"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855","bpguid":"RandonBPGUID"}', adobeInfoObj, 'adobeInfoObj is not null');
        }
    }
    
    /**
    * @description test method for AOB_CTRL_FlowHandler.getShowBackButtonMapping
    */
    @isTest
    static void getShowBackButtonMappingTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        
        acc.ExternalCIFUUID__c = 'TEXTTEST1234TEST';
        update acc;

        acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id =:acc.Id];
        //System.debug(acc);

        System.runAs(communityUser) {
            Test.startTest();
            Map<String,Boolean> mapStringToBolean =   AOB_CTRL_FlowHandler.getShowBackButtonMapping(new List<String>{'AOB_PersonalDetails'});
            Test.stopTest();
            System.assertNotEquals(null, mapStringToBolean, 'mapStringToBolean is null');
            System.assert(mapStringToBolean.containskey('AOB_PersonalDetails'), 'mapStringToBolean is wrong');
            System.assert(mapStringToBolean.get('AOB_PersonalDetails'), 'mapStringToBolean is wrong');
        }
    }

    /**
    * @description test method for AOB_CTRL_FlowHandler.getShowBackButtonMapping exception
    */
    @isTest
    static void getShowBackButtonMappingFailTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        acc.ExternalCIFUUID__c = 'TEXTTEST1234TEST';
        update acc;
        acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id =:acc.Id];
        AuraHandledException unexpectedException;

        System.runAs(communityUser) {
        Test.startTest();
        try
        { 
            Map<String,Boolean> mapStringToBolean =  AOB_CTRL_FlowHandler.getShowBackButtonMapping(null);
        }
        catch (AuraHandledException dmx)
        {
            unexpectedException = dmx;
        }
        Test.stopTest();
        system.assertEquals(unexpectedException.getMessage(), 'Script-thrown exception','');
        } 
    }

    /**
    * @description test method for AOB_CTRL_FlowHandler.getApplicationState
    */
    @isTest
    static void getApplicationStateTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];

        System.runAs(communityUser) {
            Test.startTest();
            Boolean result = AOB_CTRL_FlowHandler.getApplicationState(app.Id);
            Test.stopTest();
            System.assertNotEquals(null, result, 'AOB_Callback_Requested__c is null');
            System.assertEquals(result, false, 'AOB_Callback_Requested__c');
		}
    }
     @isTest
    static void isWFRStepTest(){
        User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
		Account acc=[SELECT Id , ExternalCIFUUID__c , PersonEmail FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
		AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];

        System.runAs(communityUser) {
            Test.startTest();
            Boolean result = AOB_CTRL_FlowHandler.isWFRStep(app.Id);
            Test.stopTest();
            System.assertNotEquals(null, result, 'AOB_Callback_Requested__c is null');
            System.assertEquals(result, false, 'AOB_Callback_Requested__c');
		}
    }
    
     
}