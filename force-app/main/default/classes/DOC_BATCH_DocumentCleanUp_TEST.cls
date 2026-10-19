/**
 * Test class of DOC_BATCH_DocumentCleanUp
 *
 * <p>DBP-2291</p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 * @date Feb 8th 2021
 */
@IsTest
public class DOC_BATCH_DocumentCleanUp_TEST {
    @TestSetup
    public static void testSetUp(){
        User communityUser=AOB_DAL_TestFactory.createCommunityUser();
        Account acc=[select id from account where id IN (select accountId from contact where id=:communityUser.contactId)];
        System.runAs(communityUser) {
            Map<string,string> ApplicationData=new Map<string,string>();
            ApplicationData.put('AOB_Customer__c',acc.id);
            AOB_Application__c app=(AOB_Application__c)AOB_DAL_TesTFactory.genericObjectCreation('AOB_Application__c',ApplicationData);
            insert app;
            Map<string,string> DocData=new Map<string,string>{'AOB_Application__c'=>app.id,'DOC_DocumentGUID__c'=>'TEST'};
            insert AOB_DAL_TesTFactory.genericObjectCreation('DOC_Document__c',DocData);
        }
    }
    
    @isTest
	public static void testMethod1() 
    {
       User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
       System.runAs(communityUser) {
           Test.startTest();
           DOC_BATCH_DocumentCleanUp obj = new DOC_BATCH_DocumentCleanUp();
           DataBase.executeBatch(obj); 
           Test.stopTest();
           System.assertEquals(0, [SELECT Id, Name FROM DOC_Document__c where DOC_DocumentGUID__c !=null].size());
       }
    }
}