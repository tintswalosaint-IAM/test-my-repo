/**
* @description Rest Resource for processing Inbound Service
*
* 
* 
* @date 2022
*/
@RestResource(UrlMapping='/v1/InvestmentProposal/*')
global class INVM_URL_InvestmentProposal {
    
    @HttpPut
    global static void upsertInvestmentProposal()
    {
       
            CMN_FACTORY_WebserviceManager.processInboundService(INVM_API_UpsertInvestmentProposal.SERVICE_NAME);
        
    }

}