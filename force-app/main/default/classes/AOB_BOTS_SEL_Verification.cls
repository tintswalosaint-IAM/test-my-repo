/**
 * @description       : Selector Class for Verification Entity
 * @author            : Narendra Teja
 * @last modified on  : 27-03-2023
 * @last modified by  : Narendra Teja
**/

public inherited sharing class AOB_BOTS_SEL_Verification extends sbgplatform.fflib_SObjectSelector{

    //keep only the fields that you want to query here, no need to mention all the fields
    private static Set<String> fields = new Set<String>{
        'Id', 
        'Name', 
        'Application__c', 
        'Application_Participant__c',
        'Verification_Status__c',
        'Verification_Type__c',
        'Verification_Source__c'
    };
        
    /**
    * @description Implementation method for Verification Object as part of fflib framework
    * @author Narendra Teja | 03-07-2023 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
    	return Verification__c.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Narendra Teja | 03-07-2023 
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Verification__c.Id, 
            Verification__c.Application__c, 
            Verification__c.Application_Participant__c, 
            Verification__c.Client__c, 
            Verification__c.CreatedById, 
            Verification__c.CurrencyIsoCode, 
            Verification__c.AOB_DSX_Response__c, 
            Verification__c.Facial_Recognition_Score__c, 
            Verification__c.AOB_Identifii_Document_Id__c, 
            Verification__c.LastModifiedById, 
            Verification__c.Liveness_Check__c, 
            Verification__c.AOB_Liveness_Matched__c, 
            Verification__c.AOB_Liveness_Score__c, 
            Verification__c.OwnerId	, 
            Verification__c.AOB_PEP_Status__c, 
            Verification__c.AOB_Risk_Score_Rating__c, 
            Verification__c.AOB_Risk_Score_Status__c, 
            Verification__c.AOB_Sanction_Status__c, 
            Verification__c.Name, 
            Verification__c.Verification_Source__c, 
            Verification__c.Verification_Status__c, 
            Verification__c.Verification_Type__c, 
            Verification__c.Verification_URL__c 
            
        };
    }
    
    /**
     * Select without conditions
     * @author Narendra Teja | 08/04/2023
     * @return List<Verification__c>
     */
    public List<Verification__c> selectWithoutCondition() {
        return (List<Verification__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }

    /**
    * @description Method to fetch list of Verification based on Id
    * @author Narendra Teja | 27-03-2023 
    * @param List<Id> participantIds 
    * @return List<Verification__c> 
    **/
    public List<Verification__c> selectVerificationById(List<Id> verificationIds) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Id in :verificationIds');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Verification based on Application_Participant__c & Verification_Status__c
    * @author Narendra Teja | 27-03-2023 
    * @param List<Id> participantIds 
    * @return List<Verification__c> 
    **/
    public List<Verification__c> selectVerificationByPartcipantAndNotStatus(Id participantId, String inprogressStatus, String successStatus  ) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Application_Participant__c=:participantId and Verification_Status__c!=:inprogressStatus and Verification_Status__c!=:successStatus');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Verification based on Application_Participant__c & Verification_Status__c
    * @author Narendra Teja | 27-03-2023 
    * @param List<Id> participantIds 
    * @return List<Verification__c> 
    **/
    public List<Verification__c> selectVerificationByParticipantAndStatus(Id participantId, String Status  ) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Application_Participant__c=:participantId and Verification_Status__c=:Status');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    
}