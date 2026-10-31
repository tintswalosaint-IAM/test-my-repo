/**
 * @description Selector class for CMN_Team__c.
 * @author Hlayisani Hlungwani
 * @created Date 25 August 2026
 * @story SFP-55563 Insurance: Manual case creation should reflect status of new
 */
public inherited sharing class SVC_SEL_Team
    extends sbgplatform.fflib_SObjectSelector {

    private static final Integer MAX_RESULTS = 10;

    /**
     * @description Factory method to return a new selector instance.
     * @return SVC_SEL_Team
     */
    public static SVC_SEL_Team newInstance() {
        return new SVC_SEL_Team();
    }

    /**
     * @description Returns the SObject type for CMN_Team__c.
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return CMN_Team__c.SObjectType;
    }

    /**
     * @description Returns the fields selected by this selector.
     * @return List of SObject fields
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_Team__c.Id,
            CMN_Team__c.Name,
            CMN_Team__c.CMN_Country__c,
            CMN_Team__c.CMN_Active__c
        };
    }

    /**
     * @description Selects active teams matching the specified country
     *              and optional team-name search.
     * @param country Country of the current user.
     * @param searchText Optional team-name search text.
     * @return Matching active teams, limited to 10 records.
     */
    public List<CMN_Team__c> selectByCountry(
        String country,
        String searchText
    ) {
        if (String.isBlank(country)) {
            return new List<CMN_Team__c>();
        }

        String condition =
            'CMN_Country__c = :country AND CMN_Active__c = true';

        Map<String, Object> bindVariables = new Map<String, Object>{
            'country' => country.trim()
        };

        if (String.isNotBlank(searchText)) {
            bindVariables.put(
                'searchPattern',
                '%' + searchText.trim() + '%'
            );
            condition += ' AND Name LIKE :searchPattern';
        }

        sbgplatform.fflib_QueryFactory queryFactory =
            newQueryFactory(false, false, false);

        queryFactory.selectFields(getSObjectFieldList());
        queryFactory.setCondition(condition);
        queryFactory.addOrdering(
            'Name',
            sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING
        );
        queryFactory.setLimit(MAX_RESULTS);

        return (List<CMN_Team__c>) Database.queryWithBinds(
            queryFactory.toSOQL(),
            bindVariables,
            AccessLevel.USER_MODE
        );
    }

    /**
     * @description Retrieves teams by their record IDs.
     * @param teamIds Set of CMN Team record IDs.
     * @return Matching teams.
     */
    public List<CMN_Team__c> selectById(Set<Id> teamIds) {
        if (teamIds == null || teamIds.isEmpty()) {
            return new List<CMN_Team__c>();
        }

        return (List<CMN_Team__c>) selectSObjectsById(teamIds);
    }
}