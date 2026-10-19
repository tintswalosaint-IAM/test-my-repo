/***************************************************************************************
@Name of the Component : SEL_Case
@Description : Selector class for the Case object
@Author : Jaco de Lange
@Created Date : 11 Nov 2024
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 18 July 2025
@Modification description: added a new method selectCasesBySuppliedEmail for rest resource
 classes RES_UG_URL_CrossOrgCasesRest and RES_UG_URL_CrossOrgGetCaseDataRest
 added additional requested fields
 added newInstance() method
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 18 July 2025
@Modification description: added spaces before comments
 User Story: BCBSFSA-496
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 3 Sept 2025
@Modification description: added limit by last days
 User Story: BCBSFSA-844
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 15 June 2026
@Modification description: Added selectCountryById and selectWithTeamNotificationFieldsByIds
 for UG unresolved reason filtering and notifications
 User Story: SFP-58600
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 28 July 2026
@Modification description: Added selectEscalationCandidatesQueryLocator for the UG batch
 escalation job
 User Story: SFP-59565
/***************************************************************************************
@Last Modified By : Givem Khupai
@Last Modified On : 2026-08-04
@Modification description: Re-added case metrics fields (BusinessHoursId, Status, CreatedDate,
 ClosedDate, SVC_ResolvedDate__c, SVC_Case_Allocation_Date__c, SVC_CaseClassificationDate__c)
 to getSObjectFieldList() carried over from SFP-46473; restored selectEscalationCandidatesQueryLocator
 (SFP-59565) that was dropped by the SIT merge
***************************************************************************************/
public virtual inherited sharing class SEL_Case extends sbgplatform.fflib_SObjectSelector{

    /**
     * @description Defines the default fields to be added to all queries created ny the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */
    private static final String FIELD_STATUS = 'Status';

    private static Set<String> fields = new Set<String>{
        'Id',
        'CaseNumber',
        'Subject',
        'Description',
        FIELD_STATUS,
        'Origin',
        'Priority',
        'Type',
        'ContactId',
        'Contact.Email',
        'SuppliedEmail',
        'AccountId',
        'CreatedDate',
        'LastModifiedDate',
        'Account.CMN_CustomerBPID__pc',
        'Account.CMN_IdentityNumber__pc',
        'Account.Initials__c',
        'Account.LastName',
        'Account.RecordTypeId',
        'Insurance_Claim__c',
        'Insurance_Policy__c'
    };

    /**
     * @description Defines the limit last days for case queries to avoid internal SF exceptions
     */
    private static final String CASE_QUERY_LIMIT = 'CreatedDate = LAST_N_DAYS:10';

     /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return Case.SObjectType;
    }

     /**
     *
     * @description Method to get list of fields to be part of response
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Case.Id,
            Case.CaseNumber,
            Case.BusinessHoursId,
            Case.Status,
            Case.CreatedDate,
            Case.ClosedDate,
            Case.SVC_ResolvedDate__c,
            Case.SVC_Case_Allocation_Date__c,
            Case.SVC_CaseClassificationDate__c
        };
    }

    /**
	* @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	* and inject a mock instead of this class or to switch out this class for a new version.
	* @return SEL_Case
	*/
    public static SEL_Case newInstance() {
        return(SEL_Case) ORG_Application.selector.newInstance(Case.SObjectType);
    }
    /**
     * @description Select case by Id
     * @param caseId
     * @return List<Case>
     **/
    public List<Case> selectCaseById(String caseId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Id =:caseId');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);
        return Database.query(fieldQueryFactory.toSOQL());
    }



    /**
     * @description Select case by CaseNumber field
     * @param caseNumber
     * @return List<Case>
     **/
    public List<Case> selectCaseByNumber(String caseNumber) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('CaseNumber =:caseNumber');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);
        return Database.query(fieldQueryFactory.toSOQL());
    }
     /**
     * @description Select all the cases for an insurance claim
     * @param caseIds
     * @return List<Case>
     **/
    public List<Case> selectCasesByClaimId(String insuranceClaimId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Insurance_Claim__c =:insuranceClaimId');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(100);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select all the cases for an insurance policy
     * @param caseIds
     * @return List<Case>
     **/
    public List<Case> selectCasesByPolicyId(String insurancePolicyId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Insurance_Policy__c =:insurancePolicyId');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(100);
        return Database.query(fieldQueryFactory.toSOQL());
    }



    /**
     * @description Selects a case by Id with the Case_Owner_Country__c field
     *              for unresolved reason picklist filtering.
     * <br/>SFP-58600
     *
     * @param caseId the Id of the Case to retrieve
     * @return List of Case records
     * @author Raymond Magezi
     * @date 15 June 2026
     */
    public List<Case> selectCountryById(Id caseId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Id = :caseId');
        fieldQueryFactory.selectFields(new Set<String>{
            'Id', 'Case_Owner_Country__c'
        });
        fieldQueryFactory.setLimit(1);
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Selects cases by Ids with service team notification fields
     *              for sending unresolved email notifications.
     *
     * @param caseIds set of Case Ids to query
     * @return List of Cases with team notification fields
     * @author Raymond Magezi
     * @date April 2026
     */
    public List<Case> selectWithTeamNotificationFieldsByIds(Set<Id> caseIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Id IN :caseIds');
        fieldQueryFactory.selectFields(new Set<String>{
            'Id', FIELD_STATUS, 'SVC_Email__c',
            'SVC_ServiceTeam__r.CMN_Team__r.CMN_Email__c',
            'SVC_ServiceTeam__r.CMN_Team__r.SVC_CaseResolvedEmailTemplate__c',
            'SVC_ServiceTeam__r.CMN_Team__r.SVC_SendResolvedNotification__c'
        });
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Selects escalation candidate cases for the UG batch escalation job:
     *              open, escalated cases below the max escalation level for a given
     *              country, excluding a resolved status, owned by a User (not a Queue).
     * <br/>SFP-59565
     *
     * @param countryCode Country code matching Case_Owner_Country__c (e.g. 'UG')
     * @param maxLevel Maximum escalation level
     * @param resolvedStatus Resolved status value to exclude
     * @return Database.QueryLocator for the matching cases, ordered by CreatedDate ascending
     * @author Raymond Magezi
     * @date 28 July 2026
     */
    public Database.QueryLocator selectEscalationCandidatesQueryLocator(String countryCode, Decimal maxLevel, String resolvedStatus) {
        String safeCountryCode = String.escapeSingleQuotes(countryCode);
        String safeResolvedStatus = String.escapeSingleQuotes(resolvedStatus);
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition(
            'Case_Owner_Country__c = :safeCountryCode ' +
            'AND IsClosed = false ' +
            'AND SVC_Escalation_Level__c < :maxLevel ' +
            'AND IsEscalated = true ' +
            'AND Status != :safeResolvedStatus ' +
            'AND Owner.Type = \'User\''
        );
        fieldQueryFactory.selectFields(new Set<String>{
            'Id', 'SVC_Escalation_Level__c', 'OwnerId', 'SVC_Escalate_to__c',
            'CaseNumber', 'Status', 'LastModifiedDate'
        });
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        return Database.getQueryLocator(fieldQueryFactory.toSOQL(), AccessLevel.USER_MODE);
    }

    /**
     * @description Select case by SuppliedEmail field
     * @param suppliedEmail
     * @return List<Case>
     **/
    public List<Case> selectCasesBySuppliedEmail(String suppliedEmail) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('SuppliedEmail =:suppliedEmail AND ' + CASE_QUERY_LIMIT);
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
        fieldQueryFactory.setLimit(100);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}