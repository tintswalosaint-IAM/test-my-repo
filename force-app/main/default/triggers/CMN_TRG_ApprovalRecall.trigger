/**
 * @description Trigger Handler framework for Approval Recall platform event
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/09
 */
trigger CMN_TRG_ApprovalRecall on CMN_ApprovalRecall__e (after insert) {
    CMN_FACTORY_TriggerHandler.createHandler(CMN_TRH_ApprovalRecall.class);
}