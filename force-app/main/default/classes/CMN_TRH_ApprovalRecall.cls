/**
 * @description Trigger Handler framework handler class for Aprovall Recall platform event
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/09
 */
public inherited sharing class CMN_TRH_ApprovalRecall extends CMN_TRH_BaseObject {
    /**
     * @description After insert handler
     *
     * @param so - New record
     */
    public override void afterInsert(SObject so) {
        super.afterInsert(so);

        CMN_ApprovalRecall__e pEvent = (CMN_ApprovalRecall__e)so;
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction(pEvent.CMN_Action__c);
        req.setWorkitemId(pEvent.CMN_RecordId__c);
        req.setComments(pEvent.CMN_Comment__c);
        Approval.ProcessResult pResult = Approval.process(req);
        if (!pResult.isSuccess()) {
            sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_TRH_ApprovalRecall').error(pResult.getErrors().get(0).getMessage(), new List<String>{pEvent.CMN_RecordId__c});
        }
    }
}