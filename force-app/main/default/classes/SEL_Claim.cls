/**
 * @description       : Selector Class for Lead Entity
 * @author            : Maham Hassan
 * @last modified on  : 09-10-2024
 * @last modified by  : Dhiraj Prajapati (CloudSmiths)
**/
public inherited sharing class SEL_Claim extends sbgplatform.fflib_SObjectSelector {

    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'PolicyNumber.Name',
        'FileNet_Request_Payload__c',
        'Account.CMN_CustomerBPID__pc',
        'Account.CMN_IdentityNumber__pc',
        'Account.LastName',
        'Account.Initials__c',
        'Account.RecordTypeId'
    };

    /**
     *
     * @return  `Schema.SObjectType`
     */
    public override Schema.SObjectType getSObjectType() {
        return Claim.sObjectType;
    }


    /**
     *
     * @description Method to get list of fields to be part of response
     * @author Maham Hassan
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Claim.Id,
            Claim.Name,
            Claim.PolicyNumber.Name,
            Claim.FileNet_Request_Payload__c
        };
    }


    /**
	* @description Method to fetch list of Claim based on Claim Id
	* @param claimid
	* @return List<Claim>
	**/
public List<Claim> selectClaimById(String claimId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =:claimId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }

}