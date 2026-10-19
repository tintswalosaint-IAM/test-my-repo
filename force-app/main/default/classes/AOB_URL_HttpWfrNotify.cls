/**
 * The REST Web Service to update the WFR Status on the AO Application
 *
 * <p>SFP-11823</p>
 *
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 *
 * @date April 12th 2022
 */
@RestResource(UrlMapping='/v1/wfrNotify/*')
/*
 * @description RESTAPI class for WFR Notify 
 */
global with sharing class AOB_URL_HttpWfrNotify {
  public static final String SERVICE_NAME = AOB_API_HttpWfrNotify.class.getName();
  /**
   * @description post method for update application service (inbound)
   */
  @HttpPatch
  global static void updateApplication() {
    CMN_FACTORY_WebserviceManager.processInboundService(SERVICE_NAME);
  }
}