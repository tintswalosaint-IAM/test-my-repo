/**
 * @description Tests the various methods of CMN_CTRL_WebserviceManager
 *
 * @see CMN_CTRL_WebserviceManager
 *
 * @author Accenture
 *
 * @date January 2021
 */
@IsTest(SeeAllData=false)
private class CMN_CTRL_WebserviceManager_TEST {
  /**
   * @description Well test the invocation of a service call through the controller
   *
   * @see CMN_CTRL_WebserviceManager.invokeWebserviceCallSynchronously
   */
  @IsTest
  private static void invokeWebserviceCallSynchronously() {
    Test.startTest();

    String response = CMN_CTRL_WebserviceManager.invokeWebserviceCallSynchronously(
      CMN_API_RestOutboundExample.SERVICE_NAME,
      UserInfo.getUserId(),
      CMN_UTIL_String.EMPTY,
      false,
      CMN_UTIL_String.EMPTY
    );

    Test.stopTest();

    System.assertEquals(
      true,
      String.isNotBlank(response),
      'No response received'
    );
  }
}