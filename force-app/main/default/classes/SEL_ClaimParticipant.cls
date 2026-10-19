/**
 * @description : Selector Class for ClaimParticipant Entity
 * @author : Dhiraj Prajapati
 * @last modified on  : 04-01-2024
 * @last modified by  : Dhiraj Prajapati (CloudSmiths)
**/
public with sharing class SEL_ClaimParticipant extends sbgplatform.fflib_SObjectSelector {

    private Set<String> fields = new Set<String>{
        'Id',
        'ClaimId',
        'Claim.Name',
        'Claim.CreatedDate',
        'Claim.OwnerId'
    };

    /**
     *
     * @return  `Schema.SObjectType`
    */
    public override Schema.SObjectType getSObjectType() {
        return ClaimParticipant.sObjectType;
    }

    /**
     *
     * @description Method to get list of fields to be part of response
     * @author
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {};
    }


    /**
    * @description Method to fetch list of ClaimParticipant based on Policy, Owners and Roles
    * @param insurancePolicies
    * @param owners
    * @param roles
    *
    * @return List<ClaimParticipant>
    **/
    public List<ClaimParticipant> selectClaimParticipants(Set<Id> insurancePolicies, Set<Id> owners, Set<String> roles, Set<String> status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition(
            'Claim.PolicyNumberId IN :insurancePolicies AND Claim.OwnerId IN :owners AND Roles IN :roles AND Claim.CreatedDate = TODAY AND Claim.Status IN :status'
        );
        fieldQueryFactory.selectFields(this.fields);
        fieldQueryFactory.setOrdering('Claim.CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
        return new List<ClaimParticipant>((List<ClaimParticipant>) Database.query(fieldQueryFactory.toSOQL()));
    }
}