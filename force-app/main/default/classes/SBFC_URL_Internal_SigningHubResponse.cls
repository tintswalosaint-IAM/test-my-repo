/**
* @File Name : SBFC_URL_Internal_SigningHubResponse.cls
* @Description : SFP-54443 - this class used to update the Info Authorization Request status after document is signed from signing Hub
* @Author : Amlendu Bajpai
* @Last Modified By : Amlendu Bajpai
* @Last Modified On : June 30, 2026
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 2, 2025 | Amlendu Bajpai  | Initial Version
**/

@RestResource(UrlMapping='/v1/uosigningHubResponse/*')
global class SBFC_URL_Internal_SigningHubResponse {
    
    /**
    * @description runs the rest service from ESB feedback
    * @author Amlendu bajpai | 02-16-2026
    **/
    @HttpPut 
    global static void upsertSignHubResponse() {                   
        CMN_FACTORY_WebserviceManager.processInboundService(SBFC_API_Internal_SigningHubResponse.SERVICE_NAME);        
    } 
}