/**
 * @description Test class for AOB_CTRL_CameraMissing
 * 
 * <p>SFP-9126</p> 
 * 
 * @author Gill Lumley
 * 
 * @date 12 November 2021
 */
@IsTest
public with sharing class AOB_CTRL_CameraMissing_Test {
/**
     * @description getCommerceAccountsLinkTest,in this Test method for AOB_CTRL_CameraMissing.getCommerceAccountsLink - check non-null link is returned
     */
    
	@IsTest
	private static void getCommerceAccountsLinkTest(){
        User admin = AOB_DAL_TestFactory.createUser(AOB_Constants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            Test.startTest();
            String commerceAccountsLink = AOB_CTRL_CameraMissing.getCommerceAccountsLink();
            AOB_CTRL_CameraMissing.url=null;
            AOB_CTRL_CameraMissing.errorMessage=null;
            Test.stopTest();
            System.assertNotEquals(null, commerceAccountsLink,'Commerce accounts link missing');
        }  
    }


}