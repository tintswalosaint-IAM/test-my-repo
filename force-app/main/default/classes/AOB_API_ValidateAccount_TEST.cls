/**
 * @description Test class to test the Outbound API call
 * 
 * <p></p>
 * 
 * @author mbourhi@salesforce.com
 *
 * @date 2020
 */
@IsTest(SeeAllData=false)
public class AOB_API_ValidateAccount_TEST {
    
    @TestSetup
    public static void testSetUp(){
        AOB_DAL_TestFactory.createCommunityUser();
    }
	/**
	 * @description To setup the List of Webservice Call Queue
	 *
	 * @return A list of queue items
	 */ 
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_ValidateAccount.SERVICE_NAME, UserInfo.getUserId());

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
			CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
        }
	}

	/**
	 * @description Emulates a failed call
	 */
	@IsTest
	private static void failedCall()
	{
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
			CMN_API_RestBaseOutboundTestHelper.failedCall(setup());
        }
	}

	/**
	 * @description Emulates a failed call due to response parse failure
	 */
	@IsTest
	private static void parseFailed()
	{
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
			CMN_API_RestBaseOutboundTestHelper.parseFailed(setup());
        }
	}


	/**
	 * @description Emulates a call that is aborted because the API has been disabled for the current user
	 */
	@IsTest
	private static void abortAPIDisabled()
	{
		CMN_DAL_DataFactory.disableAPI(AOB_API_ValidateAccount.SERVICE_NAME);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
	}

        
    
    /**
	 * @description Tests to perform a test for the API Mock
	 */
	@IsTest
	private static void AOB_API_ValidateAccount_Test()
	{
        User communityUser = [SELECT Id FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser) {
            AOB_API_ValidateAccount customerServiceCall = new AOB_API_ValidateAccount('BranchCode','AccountNumber');
            
            Test.startTest();
            
            customerServiceCall.process(CMN_DAL_DataFactory.newWebserviceQueue(AOB_API_ValidateAccount.SERVICE_NAME));
            
            Test.stopTest(); 
            
            AOB_API_ValidateAccount.DTO_Response result=(AOB_API_ValidateAccount.DTO_Response)customerServiceCall.baseResponseDTO;
            
            system.assertNotEquals(result,null);
        }
    }
}