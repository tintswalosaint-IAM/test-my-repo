/**
* @description Trigger for performing Opportunity maintenance tasks
*
* @author Ramya Gurram
*
* @date 15/10/2024
*/
trigger CMN_TRG_Opportunity on Opportunity (after insert, after update, before insert, before update,before delete,After delete) {
       CMN_FACTORY_TriggerHandler.createHandler(ICS_TRH_Opportunity.class);  
}