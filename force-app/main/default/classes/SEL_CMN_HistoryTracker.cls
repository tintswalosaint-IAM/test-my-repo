/**
 * @description Selector for the CMN_History_Tracker__c object.
 *              <br/>SFP-51816
 *              Declared inherited sharing so it runs with the sharing of its caller.
 *              INS_SRV_CaseTransferHistory calls it from its without sharing inner class,
 *              so every earlier transfer is returned whoever owns it.
 *
 * @author Given Khupai
 *
 * @date September 2026
 *
 * @see SEL_CMN_HistoryTracker_TEST
 */
public inherited sharing class SEL_CMN_HistoryTracker
    extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Returns a new instance of the selector.
     *
     * @return SEL_CMN_HistoryTracker new selector instance
     */
    public static SEL_CMN_HistoryTracker newInstance() {
        return new SEL_CMN_HistoryTracker();
    }

    /**
     * @description Returns the SObject type the selector queries.
     *
     * @return Schema.SObjectType CMN_History_Tracker__c
     */
    public override Schema.SObjectType getSObjectType() {
        return CMN_History_Tracker__c.SObjectType;
    }

    /**
     * @description Returns the default fields the selector queries.
     *
     * @return List<Schema.SObjectField> default field list
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_History_Tracker__c.Id,
            CMN_History_Tracker__c.CMN_Case__c,
            CMN_History_Tracker__c.CMN_TransferDate__c,
            CMN_History_Tracker__c.CMN_TransferCount__c
        };
    }

    /**
     * @description Retrieves the trackers for the given Cases in one query, latest transfer
     *              first, so the first record per Case is its most recent transfer.
     *              Object and field access are not enforced: the records are system audit
     *              data used to calculate the next transfer, not shown to the running user.
     *
     * @param caseIds Case record Ids (CMN_Case__c)
     *
     * @return List<CMN_History_Tracker__c> matching trackers; empty when caseIds is null or empty
     */
    public List<CMN_History_Tracker__c> selectByCaseIds(Set<Id> caseIds) {
        List<CMN_History_Tracker__c> trackers = new List<CMN_History_Tracker__c>();
        if (caseIds != null && !caseIds.isEmpty()) {
            sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, true);
            queryFactory.setCondition('CMN_Case__c IN :caseIds');
            queryFactory.setOrdering(
                CMN_History_Tracker__c.CMN_TransferDate__c,
                sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING
            );
            trackers = (List<CMN_History_Tracker__c>) Database.query(queryFactory.toSOQL());
        }
        return trackers;
    }
}