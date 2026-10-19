trigger AOB_TRG_WebserviceCallQueueTrigger on CMN_WebserviceCallQueue__c (after insert,after update) {
	CMN_FACTORY_TriggerHandler.createHandler(AOB_TRH_WebServiceCallQueue.class);
}