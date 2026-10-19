/**
 * @description Trigger Handler framework for FieldSetItem object
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/06
 */
trigger WI_TRG_FieldSet_Item on FieldSetItem__c (before insert, before update) {
    CMN_FACTORY_TriggerHandler.createHandler(WI_TRH_FieldSetItem.class);
}