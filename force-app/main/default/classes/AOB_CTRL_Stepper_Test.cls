/**
 * Test class for AOB_CTRL_Stepper
 * 
 * <p>DPB-1155</p> 
 * 
 * @author Achraf ABOUL (aaboul@salesforce.com)
 * 
 * @date Nov 10th 2020
 */
@IsTest
public with sharing class AOB_CTRL_Stepper_Test {
    /**
	 * Test method for AOB_CTRL_Stepper.getApplicationStepInformation
	 */
	@IsTest
	private static void getApplicationStepInformation_Test(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        System.runAs(communityUser){
        	AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(AOB_TestConstants.CURRENT_SCREEN, AOB_TestConstants.PREVIOUS_SCREEN, AOB_TestConstants.CURRENT_SCREEN_NUMBER, AOB_TestConstants.NUMBER_OF_SCREENS);
            Test.startTest(); 
            AOB_Application__c applicationInformation = AOB_CTRL_Stepper.getApplicationStepInformation(newApplication.Id);
            Test.stopTest();
        	System.assertEquals(newApplication.AOB_CurrentScreen__c, applicationInformation.AOB_CurrentScreen__c);
        	System.assertEquals(newApplication.AOB_PreviousScreen__c, applicationInformation.AOB_PreviousScreen__c);
        	System.assertEquals(newApplication.AOB_TECH_NumOfScreens__c, applicationInformation.AOB_TECH_NumOfScreens__c);
        	System.assertEquals(newApplication.AOB_TECH_CurrentScreenNum__c, applicationInformation.AOB_TECH_CurrentScreenNum__c);
        }  
    }
    /**
	 * Test method for AOB_CTRL_Stepper.getApplicationStepInformation throwing an exception
	 */
	@IsTest
	private static void getApplicationStepInformation_Exception_Test(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        System.runAs(communityUser){
        	AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(AOB_TestConstants.CURRENT_SCREEN, AOB_TestConstants.PREVIOUS_SCREEN, AOB_TestConstants.CURRENT_SCREEN_NUMBER, AOB_TestConstants.NUMBER_OF_SCREENS);
			Id applicationId = newApplication.Id;
        	delete newApplication;
            Test.startTest();
            Exception exc;
            try{
                AOB_Application__c applicationInformation = AOB_CTRL_Stepper.getApplicationStepInformation(applicationId);
            }
            catch(Exception e){
                exc = e;
            }
            System.assertNotEquals(null, exc);
            System.assertEquals(AOB_Constants.SCRIPT_THROWN_EXCEPTION, exc.getMessage());
            Test.stopTest();
        }  
    }
}