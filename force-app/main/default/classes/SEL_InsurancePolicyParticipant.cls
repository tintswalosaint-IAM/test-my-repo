/**
 * @description Selector class for InsurancePolicyParticipant object
 * @author Alexandr Goryachko
 * @date 30-03-2026
 * @userStory SFP-53079
 */
public inherited sharing class SEL_InsurancePolicyParticipant extends sbgplatform.fflib_SObjectSelector {

    /**
     * Implementation method for Object as part of fflib framework
     * @return Schema.SObjectType
     */  
    public override Schema.SObjectType getSObjectType() {
        return InsurancePolicyParticipant.sObjectType;
    }

    /**
     * List of selected object fields
     * @return list of SObjectField
     */
    public override List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            InsurancePolicyParticipant.RelationshipToInsured,
            InsurancePolicyParticipant.BeneficiarySharePercentage,
            InsurancePolicyParticipant.FirstName__c,
            InsurancePolicyParticipant.LastName__c
        };
    }

    /**
     * Method to fetch list of records based on InsurancePolicy ids
     * @param insurancePolicyIds List of InsurancePolicy ids
     * @return List<InsurancePolicyParticipant>
     */
    public List<InsurancePolicyParticipant> selectByInsurancePolicyIds(List<Id> insurancePolicyIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, true, true);
        fieldQueryFactory.setCondition('InsurancePolicyId IN :insurancePolicyIds');
        return Database.query(fieldQueryFactory.toSOQL());
    }
}