/***********************************************************
* @description SFP-32986 Class used to expose urls to RelyComply
* @author Ikyatha Naidu
* @date Jan 12 2024
******************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 23/04/2024
* Last Modified Description: Updated to latest version 
*/ 

@RestResource(UrlMapping='/RCVerifyAssessmentResponse/*')
global with sharing class ICS_API_GBGIDPOAVerifyResult {  

// Used to store serviceName
  public static final String SERVICE_NAME = ICS_API_GBGIDPOAVerifyProcessResult.class.getName();
  /**
   * @description post method for update application service (inbound)
   */
  @HttpPOST
  global static void processRequest() {
    CMN_FACTORY_WebserviceManager.processInboundService(SERVICE_NAME);
  }

}