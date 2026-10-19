@isTest
public class AOB_SRV_WFR_TEST {
    
	@TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
	
    /**
	 * @description Emulates a successful call 
	 */
	@IsTest
	private static void callgetIdentifiiTokenTest()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           string result=AOB_SRV_WFR.callgetIdentifiiToken('','');
           Test.stopTest(); 
           system.assertEquals(result,'sampleResponse');
		}
    }
    
    /**
	 * @description Emulates a successful call
	 
	@IsTest
	private static void callStartIDVTest()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           AOB_API_StartIDV.DTO_Response result=AOB_SRV_WFR.callStartIDV('','');
           Test.stopTest(); 
           system.assertNotEquals(result,null);
		}
    }
    */
    /**
	 * @description Emulates a successful call
	 
	@IsTest
	private static void callNotifyIDVTest()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           string correlationId='';
           AOB_API_notifyIDV.DTO_Response result=AOB_SRV_WFR.callNotifyIDV(correlationId);
           Test.stopTest(); 
           system.assertNotEquals(result,null);
		}
    }
    */
    
     /**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void callGetIDVTest()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           AOB_API_GetIDVStatus.DTO_Response result=AOB_SRV_WFR.callGetIDV('');
           Test.stopTest(); 
           system.assertNotEquals(result,null);
		}
    }

  /**
	 * @description Emulates a successful call
	 */
	@IsTest 
    //https:standardbankgroupltd--chnwcomdev.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
	private static void callOrchestrateIDVTest()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           String result = AOB_SRV_WFR.callOrchestrateIDV('7602125236089', '8a380482-af59-4a32-87da-d19cad9de7f1', null);
           system.assertEquals(result,null,'');
           //String result2 = AOB_SRV_WFR.callOrchestrateIDV('', '', '');
           Test.stopTest(); 
           system.assertEquals(result,null,'');
		}
    }

    /**
	 * @description Emulates a successful call
	 

	@IsTest
	private static void cancelIDVTest()
	{ 
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
           Test.startTest(); 
           AOB_API_notifyIDV.DTO_Response result = AOB_SRV_WFR.cancelIDV('');
           Test.stopTest(); 
           system.assertNotEquals(result,null,'');
		}
    }
    */
}