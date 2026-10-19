/**
 * @description Trigger Handler framework for platform event
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/04/05
 */
trigger WI_TRG_ChatterNotification on WI_ChatterNotification__e (after insert) {
    CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_ChatterNotification.class);
}