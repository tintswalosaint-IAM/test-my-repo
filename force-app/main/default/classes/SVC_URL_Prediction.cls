/**
 * @description APEX REST inbound endpoint for receiving the results of predictions requested
 *
 * @author Accenture
 *
 * @date December 2020
 */
@RestResource(UrlMapping='/v1/predictions/*')
global inherited sharing class SVC_URL_Prediction {
  /**
   * @description Will process prediction results
   */
  @HttpPost
  global static void processPredictions() {
    CMN_FACTORY_WebserviceManager.processInboundService(
      SVC_API_UpdatePrediction.SERVICE_NAME
    );
  }
}