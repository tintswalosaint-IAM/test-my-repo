/**
 * @description       : SFP-55625 Selector class for the CMN_CaseMilestoneMetric__c object
 * @author            : Given Khupai
 * @last modified on  : 07-31-2026
 * 
 **/
public inherited sharing class SEL_CMN_CaseMilestoneMetric
    extends sbgplatform.fflib_SObjectSelector {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory()
            .createLogger('SEL_CMN_CaseMilestoneMetric');
    private static final String LOG_AREA = 'Case Milestone Metric Selector';
    private static final String FORCED_EXCEPTION_MESSAGE = 'Forced exception for test';

    @TestVisible
    private static Boolean forceSelectByIdException = false;
    @TestVisible
    private static Boolean forceSelectByCaseIdsException = false;

    /**
     * Purpose    : Returns a new instance of the selector
     * Returns    : SEL_CMN_CaseMilestoneMetric
     */
    public static SEL_CMN_CaseMilestoneMetric newInstance() {
        return new SEL_CMN_CaseMilestoneMetric();
    }

    /**
     * Returns sObject type
     */
    public override Schema.SObjectType getSObjectType() {
        return CMN_CaseMilestoneMetric__c.SObjectType;
    }

    /**
     * Default fields returned by selector
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_CaseMilestoneMetric__c.Id,
            CMN_CaseMilestoneMetric__c.CMN_Case__c,
            CMN_CaseMilestoneMetric__c.CreatedDate,
            CMN_CaseMilestoneMetric__c.CMN_CaseAllocationTurnaroundTime__c,
            CMN_CaseMilestoneMetric__c.CMN_CreationToAllocationMillisecond__c,
            CMN_CaseMilestoneMetric__c.CMN_ClassificationMillisecond__c,
            CMN_CaseMilestoneMetric__c.CMN_ClassificationTurnaroundTime__c,
            CMN_CaseMilestoneMetric__c.CMN_CaseOverallDurationMillisecond__c,
            CMN_CaseMilestoneMetric__c.CMN_CaseOverallTurnaroundTime__c,
            CMN_CaseMilestoneMetric__c.CMN_ResolutionMillisecond__c,
            CMN_CaseMilestoneMetric__c.CMN_ResolutionTurnaroundTime__c,
            CMN_CaseMilestoneMetric__c.CMN_SpecialistDurationMillisecond__c,
            CMN_CaseMilestoneMetric__c.CMN_SpecialistTurnaroundTime__c
        };
    }

    /**
     * Purpose    : Retrieves CMN_CaseMilestoneMetric__c records by record IDs
     * Parameters : idSet - Set of CMN_CaseMilestoneMetric__c record IDs
     * Returns    : List<CMN_CaseMilestoneMetric__c>
     */
    public List<CMN_CaseMilestoneMetric__c> selectById(Set<Id> idSet) {
        if (idSet == null || idSet.isEmpty()) {
            return new List<CMN_CaseMilestoneMetric__c>();
        }
        try {
            if (Test.isRunningTest() && forceSelectByIdException) {
                throw new System.QueryException(FORCED_EXCEPTION_MESSAGE);
            }
            return (List<CMN_CaseMilestoneMetric__c>) selectSObjectsById(idSet);
        } catch (Exception ex) {
            LOGGER.error(
                'selectById() failed for idSet size={0}, Error={1}',
                LOG_AREA,
                new List<Object>{ idSet.size(), ex.getMessage() },
                ex
            );
            throw ex;
        }
    }

    /**
     * Purpose    : Retrieves CMN_CaseMilestoneMetric__c records linked to the
     *              given Case IDs, ordered by CreatedDate descending
     * Parameters : caseIds - Set of Case record IDs (CMN_Case__c)
     * Returns    : List<CMN_CaseMilestoneMetric__c>
     */
    public List<CMN_CaseMilestoneMetric__c> selectByCaseIds(Set<Id> caseIds) {
        if (caseIds == null || caseIds.isEmpty()) {
            return new List<CMN_CaseMilestoneMetric__c>();
        }
        try {
            if (Test.isRunningTest() && forceSelectByCaseIdsException) {
                throw new System.QueryException(FORCED_EXCEPTION_MESSAGE);
            }
            sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(true, true, true);
            queryFactory.setCondition('CMN_Case__c IN :caseIds');
            queryFactory.setOrdering(
                CMN_CaseMilestoneMetric__c.CreatedDate,
                sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING
            );
            return (List<CMN_CaseMilestoneMetric__c>) Database.query(queryFactory.toSOQL());
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