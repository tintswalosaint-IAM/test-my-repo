/***************************************************************************************
@Name of the Component : SEL_SurveyInvitation
@Description : Selector class for the SurveyInvitation object.
               Follows SBG layered architecture (Section 13.2) and fflib selector pattern.
@Author : Raymond Magezi
@Created Date : 15-04-2026
User Story: SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 22-04-2026
@Modification description: Updated all selectBy methods to return List<SurveyInvitation>
    instead of single record, per standard selector pattern.
    Enabled FLS enforcement on all query factory instances via newQueryFactory(true).
    Removed redundant fields set - getSObjectFieldList() is used by the query factory.
 User Story: SFP-57596
***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 27-07-2026
@Modification description: Removed selectByBranchUnit and the SVC_BranchUnit__c field
    reference. That field was added under SFP-55823 to link to the standard BranchUnit
    object, but BranchUnit has never been populated in any connected org (chnwhotfix,
    chnwsit, CHNWUGDEV all show 0-1 records; intugdev/rmage don't have the object
    enabled). Branch selection continues to run on the SVC_BranchName global value set,
    which is the actual working data source. Confirm with BranchUnit's owning team
    before ever reviving this path.
 User Story: SFP-57596
***************************************************************************************/
public virtual inherited sharing class SEL_SurveyInvitation extends sbgplatform.fflib_SObjectSelector {

    private static final String CREATED_DATE_FIELD = 'CreatedDate';

    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return SurveyInvitation.SObjectType;
    }

    /**
     * @description Returns the default field list for queries
     * @return List of Schema.SObjectField
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SurveyInvitation.Id,
            SurveyInvitation.Name,
            SurveyInvitation.InvitationLink,
            SurveyInvitation.SVC_BranchName__c,
            SurveyInvitation.SVC_DepartmentName__c,
            SurveyInvitation.ResponseStatus,
            SurveyInvitation.SurveyId,
            SurveyInvitation.CommunityId
        };
    }

    /**
     * @description Creates a new instance of the selector.
     * @return SEL_SurveyInvitation
     */
    public static SEL_SurveyInvitation newInstance() {
        return new SEL_SurveyInvitation();
    }

    /**
     * @description Selects invitations for a given branch name, ordered by most recent first.
     * @param branchName The branch name
     * @return List of SurveyInvitation records
     */
    public virtual List<SurveyInvitation> selectByBranchName(String branchName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(true);
        qf.setCondition('SVC_BranchName__c = :branchName');
        qf.setOrdering(CREATED_DATE_FIELD, sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
        qf.setLimit(1);
        return Database.query(qf.toSOQL());
    }

    /**
     * @description Selects a SurveyInvitation by Id.
     * @param invitationId The SurveyInvitation record Id
     * @return List of SurveyInvitation records
     */
    public virtual List<SurveyInvitation> selectById(Id invitationId) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(true);
        qf.setCondition('Id = :invitationId');
        qf.setLimit(1);
        return Database.query(qf.toSOQL());
    }

    /**
     * @description Selects invitations for a given department name, ordered by most recent first.
     * @param departmentName The department name
     * @return List of SurveyInvitation records
     */
    public virtual List<SurveyInvitation> selectByDepartmentName(String departmentName) {
        sbgplatform.fflib_QueryFactory qf = newQueryFactory(true);
        qf.setCondition('SVC_DepartmentName__c = :departmentName');
        qf.setOrdering(CREATED_DATE_FIELD, sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
        qf.setLimit(1);
        return Database.query(qf.toSOQL());
    }

}