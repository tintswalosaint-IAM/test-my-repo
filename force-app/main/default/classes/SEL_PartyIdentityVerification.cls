/***************************************************************************************
* @description Selector Class for SEL_PartyIdentityVerification Entity
* Story:SFP-30128
* @date 01/03/2024
* @author Ikyatha Naidu
**************************************************************************************
* @last modified on  : 02-09-2024
* @last modified by  : Nagendra Mylavarapu
* @ Modification Description :Added new method for selectByPartyProfileIdsAndName
****************************************************************************************/
public inherited sharing class SEL_PartyIdentityVerification extends sbgplatform.fflib_SObjectSelector {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SEL_PartyIdentityVerification');

    private static Set<String> fields = new Set<String>{
        'Id',
        'PartyProfileId',
        'Result',
        'Status',
        'PartyProfileId',
        'ReportURL',
        'Name',
        'VerificationRequestDate',
        'RequestCompletionDate',
        'Result',
        'ThirdPartyVerfdentifier',
        'PartyProfile.AccountId',
        'VerifiedBy', 
        'ThirdPartyVerfdentifier',
        'PartyProfile.WI_PrimaryIdentificationName__c',
        'PartyProfile.WI_IdentificationDocumentIssuingCountry__c'

    };
            
    /**
    * @description Implementation method for PartyIdentityVerification Object as part of fflib framweork
    * @author Swapnil Walse | 01-03-2024
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return PartyIdentityVerification.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author Swapnil Walse | 01-03-2024
    * @return List<Schema.SObjectField> 
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PartyIdentityVerification.Result,
            PartyIdentityVerification.Status,
            PartyIdentityVerification.PartyProfileId,
            PartyIdentityVerification.ReportURL,
            PartyIdentityVerification.Name,
            PartyIdentityVerification.VerificationRequestDate,
            PartyIdentityVerification.RequestCompletionDate,
            PartyIdentityVerification.Result,
            PartyIdentityVerification.ThirdPartyVerfdentifier
        };
    }

    /**
    * @description Method to fetch list of PartyIdentityVerification based on Parameters 
    * @param Set<Id> PartyProfile ids
    * @return PartyIdentityVerification List
    **/
    public List<PartyIdentityVerification> selectByPartyProfileIds(Set<Id> partyProfileIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfileId IN :partyProfileIds');
        fieldQueryFactory.selectFields(fields); 
        Map<String, Object> bindVars = new Map<String, Object>{'partyProfileIds' => partyProfileIds};
        return (List<PartyIdentityVerification>)Database.queryWithBinds(fieldQueryFactory.toSOQL(), bindVars, AccessLevel.System_MODE);
    }

    /**
    * @description Method to fetch PartyIdentityVerification based on Parameters 
    * @param accId
    * @return PartyIdentityVerification
    **/
    public PartyIdentityVerification selectByPartyProfileAccountId(String accId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfile.AccountId = :accId');
        fieldQueryFactory.selectFields(fields); 
        Map<String, Object> bindVars = new Map<String, Object>{'accId' => accId};
        List<PartyIdentityVerification> results = (List<PartyIdentityVerification>)Database.queryWithBinds(fieldQueryFactory.toSOQL(), bindVars, AccessLevel.System_MODE);
        return results.isEmpty() ? null : results[0];
    }     
     /**
	* @description Method to fetch list of Party Identity Verification on Party Profile Ids and Name
	* @param ppIds
	* @param name
    * @return List<PartyIdentityVerification>
    **/
    public List<PartyIdentityVerification> selectByPartyProfileIdsAndName(set<Id> ppIds,String name) {
        List<PartyIdentityVerification> returnList = new List<PartyIdentityVerification>();
        try {
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('PartyProfileId in :ppIds and Name = :name');
            fieldQueryFactory.selectFields(fields);
            String query = fieldQueryFactory.toSOQL();    
            returnList = Database.query(query);
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'SEL_PartyIdentityVerification.selectByPartyProfileIdsAndName',ex.getMessage()}, ex);
        }
        return returnList;
    }
    
     /**
	* @description Method to fetch list of Party Identity Verification on ThirdPartyVerfdentifier field
	* @param tpIds
    * @return List<PartyIdentityVerification>
    **/
    public List<PartyIdentityVerification> selectByThirdPartyVerfdentifier(Set<String> ThirdPartyVerfdentifier) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ThirdPartyVerfdentifier in :ThirdPartyVerfdentifier');
        fieldQueryFactory.selectFields(fields);
        String query = fieldQueryFactory.toSOQL();    
        return Database.query(query);
    }
}