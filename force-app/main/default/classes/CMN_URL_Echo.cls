/**
 * @description REST Endpoint wrapper class for inbound echo test service
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@RestResource(UrlMapping='/echo/*')
global class CMN_URL_Echo {
  /**
   * @description post method for echo service (inbound)
   */
  @HttpPost
  global static void echo() {
    CMN_FACTORY_WebserviceManager.processInboundService(
      CMN_API_RestInboundEcho.SERVICE_NAME
    );
  }
}