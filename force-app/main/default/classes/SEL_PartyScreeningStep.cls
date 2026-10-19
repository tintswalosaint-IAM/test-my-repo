/**
 * @description Selector class for PartyScreeningStep object.
 * This class provides methods to retrieve PartyScreeningStep records.
 * @author Ofentse Sacha
 * @date 04 January 2024
 */
public inherited sharing class SEL_PartyScreeningStep extends sbgplatform.fflib_SObjectSelector {
    
    /**
     * @description fields to retrieve.
     */
    private static List<String> fields = new List<String>{
        'Id', 'Name', 'Status', 'ScreeningMatchCategory__c', 'OutcomeConfirmationDate__c', 'Comments__c', 'OutcomeChallengeDate__c','isWeakStatus__c', 'CreatedBy.Name',
        'ScreeningSummaryId', 'Reason__c', 'SubReason__c', 'LastModifiedDate', 'CreatedBy.Username', 'CreatedDate','Type','ResultCode'
    };

    /**
     * @description Retrieves the SObjectType for PartyScreeningStep.
     * @return The SObjectType for PartyScreeningStep
     */
    public override Schema.SObjectType getSObjectType() {
        return PartyScreeningStep.SObjectType;
    }

    /**
     * @description Retrieves the list of SObjectFields for PartyScreeningStep.
     * @return The list of SObjectFields for PartyScreeningStep
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }

    /**
     * @description Fetches a PartyScreeningStep based on Record ID.
     * @param recordId The Record ID.
     * @return PartyScreeningStep
     */
    public PartyScreeningStep selectById(Id recordId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('Id = :recordId');
        fieldQueryFactory.selectFields(fields);
		String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    

    /**
     * @description Retrieves a list of PartyScreeningStep
     * @param recordId The ID value (ScreeningSummaryId or PartyScreeningStep Id).
     * @param usePartyStepId Boolean flag to Whether to use PartyScreeningStep Id instead of ScreeningSummaryId.
     * @return List of PartyScreeningStep objects by Id
     */
    public List<PartyScreeningStep> selectByIdorSummaryId(String recordId, Boolean usePartyStepId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.selectFields(fields);
        if (usePartyStepId) {
            fieldQueryFactory.setCondition('Id = :recordId');
        } else {
            fieldQueryFactory.setCondition('ScreeningSummaryId = :recordId');
        }
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Retrieves a list of PartyScreeningStep by ScreeningSummaryId.
     * @param partySummaryIds The set of ScreeningSummaryIds.
     * @return List of PartyScreeningStep objects.
     */
    public List<PartyScreeningStep> selectBySummaryIds(Set<Id> partySummaryIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('ScreeningSummaryId IN :partySummaryIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch   list of Par based on Parameters 
    * @param Id screeningSummaryId id
    * @return PartyScreeningStep List
    **/
    public List<PartyScreeningStep> fetchPartyScreeningStepFromVerification(Id screeningSummaryId) {

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.setCondition('ScreeningSummaryId =: screeningSummaryId');
        fieldQueryFactory.selectFields(fields);
        String query = fieldQueryFactory.toSOQL();    
        return Database.query(query);
    }
}