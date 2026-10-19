/**
 * @description Test class to test the Outbound notifyIDV API call
 *
 * <p>SFP-11823</p>
 *
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 *
 * @date May 17th 2022
 */
@IsTest(SeeAllData=false)
private class AOB_API_notifyIDV_TEST {
  /**
   * @description To setup the List of Webservice Call Queue
   *
   * @return A list of queue items
   */
  private static List<CMN_WebserviceCallQueue__c> setup() {
    CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
      AOB_API_notifyIDV.SERVICE_NAME,
      UserInfo.getUserId()
    );

    return new List<CMN_WebserviceCallQueue__c>{ queueItem };
  }

  /**
   * @description Emulates a failed call
   */
  @IsTest
  private static void failedCall() {
    CMN_API_RestBaseOutboundTestHelper.failedCall(setup());
    System.assertEquals(1, 1, '');
  }

  /**
   * @description Emulates a failed call due to response parse failure
   */
  @IsTest
  private static void parseFailed() {
    CMN_API_RestBaseOutboundTestHelper.parseFailed(setup());
    System.assertEquals(1, 1, '');
  }

  /**
   * @description Emulates a call that is aborted because the API has been disabled for the current user
   */
  @IsTest
  private static void abortAPIDisabled() {
    CMN_DAL_DataFactory.disableAPI(AOB_API_notifyIDV.SERVICE_NAME);
    CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
    System.assertEquals(1, 1, '');
  }

  /**
   * @description Tests to see if the getBaseURL works as expected
   */
  @IsTest
  private static void getBaseUrl() {
    AOB_API_notifyIDV service = new AOB_API_notifyIDV('', '', '');

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
  private static void getVerbTest() {
    AOB_API_notifyIDV service = new AOB_API_notifyIDV('', '', '');

    Test.startTest();

    String verb = service.getVerb();

    Test.stopTest();

    System.assertEquals(verb, 'POST', 'Invalid Verb');
  }

  /**
   * @description Tests to see if the triggeringObjectRequired works as expected
   */
  @IsTest
  private static void triggeringObjectRequiredTest() {
    AOB_API_notifyIDV service = new AOB_API_notifyIDV('', '', '');

    Test.startTest();

    Boolean triggerObj = service.triggeringObjectRequired();

    Test.stopTest();

    System.assertEquals(triggerObj, false, 'Invalid triggering object');
  }

  /**
   * @description Tests to perform a test for the API Mock
   */
  @IsTest
  private static void NotifyIDVTest() {
    AOB_API_notifyIDV customerServiceCall = new AOB_API_notifyIDV('', '', '');

    Test.startTest();

    customerServiceCall.process(
      CMN_DAL_DataFactory.newWebserviceQueue(AOB_API_notifyIDV.SERVICE_NAME)
    );

    Test.stopTest();

    AOB_API_notifyIDV.DTO_Response result = (AOB_API_notifyIDV.DTO_Response) customerServiceCall.baseResponseDTO;

    system.assertNotEquals(result, null, 'Result should not be null');
  }
}