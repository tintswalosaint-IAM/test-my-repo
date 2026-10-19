/**
* @description Selector Class for SEL_PartyIdentityVerificationStep Entity
*
* Story:SFP-30254
* @date 16/05/2024
* @author Swapnil Walse
***************************************************************
* @last modified on  : 01-07-2024
* @last modified by  : Ikyatha Naidu
* @ Modification Description :updated to latest version
*/
public inherited sharing class SEL_PartyIdentityVerificationStep extends sbgplatform.fflib_SObjectSelector{
    //Adding Fields
    private static Set<String> fields = new Set<String>{
        'PartyIdentityVerificationId',
        'Name',
        'Status',
        'Type',
        'VerificationDecision'
    };
            
    /**
    * @description Implementation method for PartyIdentityVerification Object as part of fflib framweork
    * @author Swapnil Walse | 15-05-2024
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return PartyIdentityVerificationStep.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Swapnil Walse | 15-05-2024
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PartyIdentityVerificationStep.PartyIdentityVerificationId,
            PartyIdentityVerificationStep.Name,
            PartyIdentityVerificationStep.Status,
            PartyIdentityVerificationStep.Type,
            PartyIdentityVerificationStep.VerificationDecision
        };
    }
    /**
    * @description Method to fetch   list of Par based on Parameters 
    * @param Set<Id> PartyIdentityVerification ids
    * @return PartyIdentityVerificationStep List
    **/
    public List<PartyIdentityVerificationStep> selectByVerificationId(Set<Id> verificationIds) {
	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(verificationIds == null){
            return null;
        } else{
            fieldQueryFactory.setCondition('PartyIdentityVerificationId in :verificationIds');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}