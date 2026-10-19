/**
 * @name of the class: SEL_IdentityDocument
* @description Selector Class for IdentityDocument Entity
* Story:SFP-30128
* @author Ikyatha Naidu
* @date 09/11/2023
***************************************************************
* @last modified on  : 13-10-2024
* @last modified by  : Swapnil Walse
* @ Modification Description : Added CreatedDate for SAP integration
*/
public inherited sharing class SEL_IdentityDocument extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{
        'Id',
        'Name',
        'PartyProfileId',
        'RelatedLegalEntityId',
        'IdDocumentType',
        'ExpirationDate',
        'IssuingCountry__c',
        'CreatedDate'
    };
/**
* This is used to retrieve the sObject name when building the SOQL
* queries.
*
* @return the SObject type for the selector.
*/
    public override Schema.SObjectType getSObjectType(){
        return IdentityDocument.SObjectType;
    }

/**
* This is used to retrieve a specific set of SObject fields
*
* @return List of SObjectField
*/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            IdentityDocument.Id,
            IdentityDocument.IdDocumentType,
            IdentityDocument.PartyProfileId,
            IdentityDocument.RelatedLegalEntityId,
            IdentityDocument.Name,
            IdentityDocument.ExpirationDate,
            IdentityDocument.IssuingCountry__c,
            IdentityDocument.CreatedDate
        };
    }

/**
* @description Select by Id for SBO-UK Project
* @param accId
* @return IdentityDocument
*/
    public List<IdentityDocument> selectByAccountId(string accId ) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('RelatedLegalEntityId =: accId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
/**
* @description Select by Id for SBO-UK Project
* @param ids
* @return List<IdentityDocument>
*/
    public List<IdentityDocument> selectByAccountIds(set<id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('RelatedLegalEntityId IN: ids');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
* @description Method to fetch identityDocument based on Parameters
* @param partyProfileId
* @return identityDocument
**/
    public IdentityDocument selectByPartyProfileId(String partyProfileId) {

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfileId=: partyProfileId' );
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
* @description Method to fetch identityDocument based on Name
* @author Michal Orawiec | 15-10-2025
* @param name String parameter
* @return identityDocument List
**/
    public List <IdentityDocument> selectByName(String name) {

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Name=: name' );
        fieldQueryFactory.selectField('RelatedLegalEntityId');
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}