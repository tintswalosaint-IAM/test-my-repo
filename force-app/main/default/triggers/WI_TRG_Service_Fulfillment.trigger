/**
 * @description Trigger Handler framework for Service Fulfillment object
 * 
 * @author Adam Redlinski
 *
 * @date 2023/06/02
 */
trigger WI_TRG_Service_Fulfillment on ServiceFulfillment__c (before update) {
    CMN_FACTORY_TriggerHandler.createHandler(WI_TRH_ServiceFulfillment.class);
}