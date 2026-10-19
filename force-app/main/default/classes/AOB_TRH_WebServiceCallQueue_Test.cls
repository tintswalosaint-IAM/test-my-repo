/**
 * Test class for AOB_TRH_WebServiceCallQueue
 *
 * <p></p>
 *
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 *
 */
@isTest
public class AOB_TRH_WebServiceCallQueue_Test {
	
    @TestSetup
    public static void testSetUp() {
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    }
    
    @istest
    public static void AOB_insertWebService(){
        CMN_WebserviceCallQueue__c item=new CMN_WebserviceCallQueue__c();
        item.CMN_Service__c='AOB_class';
        item.CMN_Status__c='Failed';
        Test.startTest();
        insert item;
        item.CMN_Service__c='AOB_class2';
        update item; 
        Test.stopTest();
        List<Case> cases=[select id from case where subject='Application Technical Error'];
        system.assertNotEquals(cases,null);
    }
}