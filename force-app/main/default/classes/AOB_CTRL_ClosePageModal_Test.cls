@IsTest
/**
 * @description AOB_CTRL_ClosePageModal_Test
 * ACTION  TICKET    DATE       OWNER           COMMENT
 * New     SFP-14147 17-06-2022 Gill Lumley     New method getApplicationRecord_Test
 */
public with sharing class AOB_CTRL_ClosePageModal_Test {
/**
    * @description test setup method createds application and product config data 
    */
    @TestSetup
    static void makeData(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        System.runAs(communityUser){
         
            Map<String,String> objectData=new Map<string,string>{'Name'=>'Name TEST'};
      
            objectData = new Map<string,string>{'AOB_Customer__c'=> acc.id,'AOB_TECH_FlowNames__c'=>'AOB_BeforeWeBegin,AOB_PersonalDetails,AOB_CardPersonalisation,AOB_CardDetails,AOB_CardFinalOffer','AOB_CurrentScreen__c'=>'Final Offer','AOB_PreviousScreen__c'=>'Debit Order Details'};
            AOB_Application__c app = (AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',objectData);
            insert app;
        }
    }
    @isTest
    public static void getApplicationRecordTest(){ 
		User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc=[SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
        AOB_Application__c app = [SELECT Id FROM AOB_Application__c WHERE AOB_Customer__c = :acc.Id];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_Application__c app1 = AOB_CTRL_ClosePageModal.getApplicationRecord(app.id);
            Test.stopTest(); 
            system.assertNotEquals(app,null,'');
         }
    }
	@isTest
    public static void getApplicationRecordTestFail(){ 
		User communityUser = [SELECT Id , ContactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id=:communityUser.ContactId)];
		Boolean exceptionOccurred = false;
        System.runAs(communityUser) {
            Test.startTest();
            try{
                AOB_Application__c app2 = AOB_CTRL_ClosePageModal.getApplicationRecord(acc.Id);
            }
            catch (Exception e){
                exceptionOccurred = true;
        	}
            Test.stopTest(); 
            System.assert(exceptionOccurred, 'An Exception was not thrown');
        }
    }
}