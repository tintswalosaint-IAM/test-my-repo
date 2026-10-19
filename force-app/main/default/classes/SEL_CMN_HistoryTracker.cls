/**
 * @description       : SFP-51816 Selector class for the CMN_History_Tracker__c object
 * @author            : Given Khupai
 **/
public inherited sharing class SEL_CMN_HistoryTracker
    extends sbgplatform.fflib_SObjectSelector {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory()
            .createLogger('SEL_CMN_HistoryTracker');
    private static final String LOG_AREA = 'History Tracker Selector';
    private static final String FORCED_EXCEPTION_MESSAGE = 'Forced exception for test';

    @TestVisible
    private static Boolean forceSelectByCaseIdsException = false;

    /**
     * Purpose    : Returns a new instance of the selector
     * Returns    : SEL_CMN_HistoryTracker
     */
    public static SEL_CMN_HistoryTracker newInstance() {
        return new SEL_CMN_HistoryTracker();
    }

    /**
     * Returns sObject type
     */
    public override Schema.SObjectType getSObjectType() {
        return CMN_History_Tracker__c.SObjectType;
    }

    /**
     * Default fields returned by selector
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_History_Tracker__c.Id,
            CMN_History_Tracker__c.CMN_Case__c,
            CMN_History_Tracker__c.CMN_TransferDate__c,
            CMN_History_Tracker__c.CMN_TransferSequence__c
        };
    }

    /**
     * Purpose    : Retrieves History Tracker records for the given Case IDs in a single
     *              query, ordered by Transfer Date descending - so the first record
     *              encountered per Case while iterating the result is that Case's most
     *              recent transfer. Used by INS_SRV_CaseTransferHistory to calculate
     *              Transfer Sequence and Duration With Previous Owner without issuing
     *              one query per Case.
     * Parameters : caseIds - Set of Case record IDs (CMN_Case__c)
     * Returns    : List<CMN_History_Tracker__c>
     */
    public List<CMN_History_Tracker__c> selectByCaseIds(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return new List<CMN_History_Tracker__c>();
        }
        try {
            if (Test.isRunningTest() && forceSelectByCaseIdsException) {
                throw new System.QueryException(FORCED_EXCEPTION_MESSAGE);
            }
            sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(true, true, true);
            queryFactory.setCondition('CMN_Case__c IN :caseIds');
            queryFactory.setOrdering(
                CMN_History_Tracker__c.CMN_TransferDate__c,
                sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING
            );
            return (List<CMN_History_Tracker__c>) Database.query(queryFactory.toSOQL());
        } catch (Exception ex) {
            LOGGER.error(
                'selectByCaseIds() failed for caseIds size={0}, Error={1}',
                LOG_AREA,
                new List<Object>{ caseIds.size(), ex.getMessage() },
                ex
            );
            throw ex;
        }
    }
}