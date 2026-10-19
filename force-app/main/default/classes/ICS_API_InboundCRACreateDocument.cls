/***********************************************************
* @description SFP-34697 Class used to expose urls to RelyComply to fetch Documents
* @author Ikyatha Naidu
* @date 31/08/2024
******************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 31/08/2024
* Last Modified Description: Updated to latest version 
*/ 

@RestResource(UrlMapping='/RCCreateDocument/*')
global with sharing class ICS_API_InboundCRACreateDocument {  
  /**
   * @description post method for update application service (inbound)
   */
  @HttpPOST
  global static void processRequest() {
    RestRequest request = RestContext.request;
    String requestBody =  request.requestBody.toString();
    ICS_API_CRACreateDocument.responseCall(requestBody);

  }

}