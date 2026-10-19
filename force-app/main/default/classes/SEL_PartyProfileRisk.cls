/**
 * @description                 : Selector Class for AssessmentQuestionVersion
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Swapnil Walse
 * @date                        : 01-02-2024
 * @last modified on            : 17-10-2024
 * @last modified by            : Tushar Walse
 * @modification description    : Modified for escapeSingleQuotes
 */

 public inherited sharing class SEL_PartyProfileRisk extends sbgplatform.fflib_SObjectSelector {
       
    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public override Schema.SObjectType getSObjectType(){
        return PartyProfileRisk.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PartyProfileRisk.Id,
            PartyProfileRisk.RiskCategory,
            PartyProfileRisk.PartyProfileId,
            PartyProfileRisk.Type,
            PartyProfileRisk.Enhanced_Due_Diligence_Required__c,
            PartyProfileRisk.Full_CRA_Result__c,
            PartyProfileRisk.CreatedDate
        };
    }        
    
    /**
    * @description Select by PartyProfileId set for SBO-UK Project
    * @param partyProfileIDs
    * @return list of PartyProfileRisk
    */
    public List<PartyProfileRisk> selectByPartyProfileIds(Set<Id> partyProfileIDs) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfileId in : partyProfileIDs');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
    * @description Select by partyProfileRiskId for SBO-UK Project
    * @param partyProfileRiskId
    * @return PartyProfileRisk
    */
    public list<PartyProfileRisk> selectById(Id partyProfileRiskId){
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('id =: partyProfileRiskId');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}