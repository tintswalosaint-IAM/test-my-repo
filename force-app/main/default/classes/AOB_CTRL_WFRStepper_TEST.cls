@isTest
public class AOB_CTRL_WFRStepper_TEST {
    
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
	
     /**
	* @description This method is used to test callGetCustomerAPI_contact methd
    */
    @isTest
    public static void AOB_Stepper_Test(){
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            List<String> result=AOB_CTRL_WFRStepper.getWFRSteps();
            Test.stopTest();
            system.assertNotEquals(result.size(),0);
        }
    }
}