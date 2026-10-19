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
private class AOB_API_GetBranches_TEST {
  /**
   * @description To setup the List of Webservice Call Queue
   *
   * @return A list of queue items
   */
  private static List<CMN_WebserviceCallQueue__c> setup() {
    CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
      AOB_API_GetBranches.SERVICE_NAME,
      UserInfo.getUserId()
    );

    return new List<CMN_WebserviceCallQueue__c>{ queueItem };
  }

  /**
   * @description Emulates a successful call
   */
  @IsTest
  private static void successfulCall() {
    CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
  }

  /**
   * @description Emulates a failed call
   */
  @IsTest
  private static void failedCall() {
    CMN_API_RestBaseOutboundTestHelper.failedCall(setup());
  }

  /**
   * @description Emulates a failed call due to response parse failure
   */
  @IsTest
  private static void parseFailed() {
    CMN_API_RestBaseOutboundTestHelper.parseFailed(setup());
  }

  /**
   * @description Emulates a call that is aborted because not ID was proved
   */
  @IsTest
  private static void abortedCallNoId() {
    CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
      AOB_API_GetBranches.SERVICE_NAME
    );
    CMN_API_RestBaseOutboundTestHelper.abortedCall(
      new List<CMN_WebserviceCallQueue__c>{ queueItem }
    );
  }

  /**
   * @description Emulates a call that is aborted because the API has been disabled for the current user
   */
  @IsTest
  private static void abortAPIDisabled() {
    CMN_DAL_DataFactory.disableAPI(AOB_API_GetBranches.SERVICE_NAME);
    CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
  }

  /**
   * @description Tests to see if the getBaseURL works as expected
   */
  @IsTest
  private static void getBaseUrl() {
    AOB_API_GetBranches service = new AOB_API_GetBranches('fakeToken');

    Test.startTest();

    String baseUrl = service.getBaseUrl();

    Test.stopTest();

    System.assertNotEquals(
      service.getWebServiceEndPoint(),
      baseUrl,
      'Invalid base URL'
    );
  }

  /**
   * @description Tests to see if the getVerb works as expected
   */
  @IsTest
  private static void getVerb_Test() {
    AOB_API_GetBranches service = new AOB_API_GetBranches('fakeToken');

    Test.startTest();

    String Verb = service.getVerb();

    Test.stopTest();

    System.assertEquals(Verb, 'GET', 'Invalid Verb');
  }

  /**
   * @description Tests to see if the triggeringObjectRequired works as expected
   */
  @IsTest
  private static void triggeringObjectRequired_Test() {
    AOB_API_GetBranches service = new AOB_API_GetBranches('fakeToken');

    Test.startTest();

    Boolean triggerObj = service.triggeringObjectRequired();

    Test.stopTest();

    System.assertEquals(triggerObj, false, 'Invalid triggering object');
  }

  /**
   * @description Tests to perform a test for the API Mock
   */
  @IsTest
  private static void OpenAPPAPI_Test() {
    AOB_API_GetBranches customerServiceCall = new AOB_API_GetBranches(
      'fakeToken'
    );

    Test.startTest();

    customerServiceCall.process(
      CMN_DAL_DataFactory.newWebserviceQueue(AOB_API_GetBranches.SERVICE_NAME)
    );

    Test.stopTest();

    AOB_API_GetBranches.DTO_Response result = (AOB_API_GetBranches.DTO_Response) customerServiceCall.baseResponseDTO;

    system.assertNotEquals(result.ETdata8_Detail_Record, null);
  }
}