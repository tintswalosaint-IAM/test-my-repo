/**
* @description This class is used as call the AOB_BOT_API_DocFusionAccToken api
* @author Dayakar 
* @date Jan 5th 2021
*/
public class AOB_BOTS_UTIL_DocFusion {
    /**
    * @description This method is used as call the makeCallout 
    * @param String templateGUID, String applicationId
    * @return string
    */
    @auraEnabled(cacheable=false)
    public static string makeCallout(String templateGUID,String applicationId){
        String retVal;
        String businessUnitGuid=System.label.BusinessUnitGuid;
        System.debug('businessUnitGuid'+businessUnitGuid);
        String bdyStr = '{"Source":"DefaultTest","JobReference":"ExampleJob","Timeout":"00:01:00","Process":{"ProcessType":0,"BusinessUnitGuid":"'+businessUnitGuid+'","TemplateGuid":"'+templateGUID+'","TemplateVersion":null,"ChainGuid":"72f1976c-d7de-4b0b-9e0f-576eab7753e1","ChainVersion":null,"WorkflowProcessGuid":"","WorkflowProcessVersion":null,"ProcessAsync":false},"Data":{"DataType":4,"Data":"PFNjaGVtYT4KPC9TY2hlbWE+","DataProcessor":null,"ProcessorProfile":null},"Parameters":{"SalesForce.Application__cId":"'+applicationId+'"}}';
        AOB_BOTS_API_Docfusion customerServiceCall = new AOB_BOTS_API_Docfusion(bdyStr);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_Docfusion.SERVICE_NAME);
        customerServiceCall.process(obj);
        
        if(customerServiceCall.getResponseStatusCode()==200) {
            retVal=customerServiceCall.getResponseBody();
        }
        System.debug('retVal>>'+retVal);
        return retVal;
    }
    /**
    * @description This method is used as call the AOB_BOT_API_DocFusionAccToken feeatch api 
    * @return string
    */
    public static string fetchToken(){
        String retVal;
        AOB_BOT_API_DocFusionAccToken customerServiceCall = new AOB_BOT_API_DocFusionAccToken();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOT_API_DocFusionAccToken.SERVICE_NAME);
        customerServiceCall.process(obj);
        
        if(customerServiceCall.getResponseStatusCode()==200) {
            Map<String,object> respJSON = new Map<String,Object>();
            respJSON = (Map<String,object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
            retVal = String.valueOf(respJSON.get('access_token'));
        }
        return retVal;
    }
    
}