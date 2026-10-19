/**
 * Test class for Controller to prepare data that will be displayed in final offer sceen
 *
 * <p>DBP-3038</p>
 *
 * @author Salesforce
 *
 * @date Jun 22nd 2021
 */
@isTest
public with sharing class AOB_CTRL_declineErrorTest {

    /**
	 * @description Test setup to prepare data for tests
	 */
    @TestSetup
    public static void testSetUp(){
		User communityUser=AOB_DAL_TestFactory.createCommunityUser();
		Map<string,string> applicationData=new Map<string,string>();
        System.runAs(communityUser) {
            Account acc=[select id from account where id IN (select accountId from user where id=:communityUser.id)];
            applicationData.put('AOB_Customer__c',acc.id);
            insert AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',ApplicationData);
        } 
            
    }
    
    /**
	 * @description method used to test the getApplicationId method
	 */
    @isTest
    public static void getCustomerNameTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            AOB_Application__c app=[select id from AOB_Application__c limit 1];
            Test.startTest();
            string customerName=AOB_CTRL_declineError.getCustomerName(app.id);
            Test.stopTest();
            system.assertNotEquals(customerName, null);
        }
    }
}