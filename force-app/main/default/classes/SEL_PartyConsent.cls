/**
 * @description Selector class for the PartyConsent SObject
 * @author Shams Arifeen
 * @date 2026-06-26
 * @user story SFP-58864
 */
public inherited sharing class SEL_PartyConsent extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Returns the SObject type for this selector
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType() {
        return PartyConsent.SObjectType;
    }

    /**
     * @description Returns the default field list
     * @return List<Schema.SObjectField>
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PartyConsent.Id,
            PartyConsent.PartyId,
            PartyConsent.Action__c
        };
    }

    /**
     * @description Fetches PartyConsent records by PartyId and Action__c values.
     *              Used for dedup check before inserting new consent records.
     * @param partyIds Set<Id>
     * @param actions List<String>
     * @return List<PartyConsent>
     */
    public List<PartyConsent> selectByPartyIdsAndActions(Set<Id> partyIds, List<String> actions) {
        if (partyIds == null || partyIds.isEmpty() || actions == null || actions.isEmpty()) {
            return new List<PartyConsent>();
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectField('PartyId');
        fieldQueryFactory.setCondition('PartyId IN :partyIds AND Action__c IN :actions');
        return Database.query(fieldQueryFactory.toSOQL());
    }
}