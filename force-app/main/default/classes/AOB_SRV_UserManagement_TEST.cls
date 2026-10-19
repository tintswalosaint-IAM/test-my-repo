/**
* Test class is use to test AOB_SRV_ApplicationManagement methods
* 
* <p></p>
*
* @author Asmae ESSBAI (aessbai@salesforce.com)
*
* @date Apr 05th 2021
*/
@IsTest
private class AOB_SRV_UserManagement_TEST {
    
	@TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
	 * @description Method used to Test create Preson Account 
	 */
    @isTest
    public static void createPresonAccountTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put(AOB_Constants.PING_LAST_NAME, 'test');
        attributeMap.put(AOB_Constants.PING_FIRST_NAME, 'fist');
        attributeMap.put(AOB_Constants.PING_EMAIL, 'a@gmail.com');
        attributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_BPID, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        attributeMap.put(AOB_Constants.CUSTOMER_CC, 'XXXXXXXX');
        attributeMap.put(AOB_Constants.COMMERCE_SITE_ID, 'SB-COZA');
        attributeMap.put(AOB_Constants.NATIONAL_ID, 'XXXXXXXX');
        attributeMap.put(AOB_Constants.PING_BPGUID, AOB_Utils.generateGUID());
        Account acc = AOB_SRV_UserManagement.createPersonAccount(attributeMap);
        System.assertNotEquals(null,acc);
    }
    
    /**
	 * @description Method used to Test create Preson Account 
	 */
    @isTest
    public static void createUserTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_application__c app = AOB_DAL_TestFactory.createDefaultApplications(communityUser.contactId);
        String EXTERNAL_USER_PROFILE = AOB_Utils.getAppSettingByLabel(
            AOB_Constants.PROFILE
        );
        Map<String, String> attributeMap = new Map<String,String>();
        attributeMap.put(AOB_Constants.PING_LAST_NAME, 'test');
        attributeMap.put(AOB_Constants.PING_FIRST_NAME, 'fist');
        attributeMap.put(AOB_Constants.PING_EMAIL, 'a@gmail.com');
        attributeMap.put(AOB_Constants.ID_STRING, 'XXXXX');
        attributeMap.put(AOB_Constants.PING_SUB, 'sub@gmail.com');
        User u = AOB_SRV_UserManagement.createUser(attributeMap, communityUser,[SELECT id FROM Profile
                                                                                WHERE name = :EXTERNAL_USER_PROFILE
                                                                               ]);
        System.assertEquals(u.FirstName,'fist');
    }
}