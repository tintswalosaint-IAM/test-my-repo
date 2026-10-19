@isTest
public class AOB_CTRL_FunFacts_TEST {
    
     /**
	* @description This method is used to test callGetCustomerAPI_contact methd
    */
    @isTest
    public static void AOB_FunFacts_Test(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        Account acc=[select id from account where id IN (select accountId from user where id=:communityUser.id)];
        System.runAs(communityUser){
            Map<string,string> ApplicationData=new Map<string,string>();
            ApplicationData.put('AOB_Customer__c',acc.id);
            AOB_Application__c App= (AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',ApplicationData);
            insert App;
            Test.startTest();
            List<AOB_FunFact__c> result=AOB_CTRL_FunFacts.getFunFactsList(App.id);
            Test.stopTest();
            system.assertNotEquals(result,null);
        }
    }
}