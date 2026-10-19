/**
 * @description       : Trigger for Lead.
 * @author            : Derek Hughes
 * @group             : Lead
 * @last modified on  : 22-05-2024
 * @last modified by  : Derek Hughes
**/
trigger CMN_TRG_Lead on Lead (before insert, after insert, before update, after update, before delete, after delete) {
	CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_Lead.class);
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        AOB_PPB_LeadTriggerHandler.handleStatusUpdate(Trigger.new, Trigger.oldMap);
    } 
}

//check

