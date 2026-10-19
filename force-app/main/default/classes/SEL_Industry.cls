/**
 * @File Name         : SEL_Industry.cls
 * @Description       : Selector class for CMN_Industry__c SObject used to encapsulate queries following fflib pattern.
 * @Author            : Ramya Gurram
 * @Last Modified By  : Ramya Gurram
 * @Last Modified On  : September 12, 2025
 */
public inherited sharing class SEL_Industry extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description Set of fields to be queried from CMN_Industry__c.
     */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name',
        'CMN_MainIndustry__c',
        'CMN_SubIndustry__c',
        'CMN_RiskRating__c',
        'CMN_SlugID__c',
        'CMN_Active__c',
        'RecordType.Name'
    };

    /**
     * @description Provides the SObject type this selector is responsible for.
     * @return Schema.SObjectType of CMN_Industry__c
     */
    public override Schema.SObjectType getSObjectType() {
        return CMN_Industry__c.sObjectType;
    }

    /**
     * @description Fetches a list of active CMN_Industry__c records filtered by RecordType.
     * @param isActive    Whether the industry record is active (CMN_Active__c)
     * @param recordType  The name of the RecordType to filter by
     * @return List of matching CMN_Industry__c records
     */
    public List<CMN_Industry__c> selectByRecordType(Boolean isActive, String recordType) {
        if (String.isBlank(recordType)) {
            return null;
        }

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('CMN_Active__c =: isActive AND RecordType.Name =: recordType');
        fieldQueryFactory.selectFields(fields);

        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Fetches a specific CMN_Industry__c record by Id along with RecordType and active status.
     * @param isActive    Whether the industry record is active (CMN_Active__c)
     * @param recordType  The name of the RecordType to filter by
     * @param Ids          The Id of the CMN_Industry__c record to retrieve
     * @return List containing the matching CMN_Industry__c record (should be max one)
     */
    public List<CMN_Industry__c> selectByRecordTypeIds(Boolean isActive, String recordType, set<String> Ids) {
        if (String.isBlank(recordType)) {
            return null;
        }

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('CMN_Active__c =: isActive AND RecordType.Name =: recordType AND Id in: Ids');
        fieldQueryFactory.selectFields(fields);

        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    

    /**
     * @description Returns the list of fields used by the base selector class (fflib).
     * @return List of Schema.SObjectField for CMN_Industry__c
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            CMN_Industry__c.Id,
            CMN_Industry__c.CMN_MainIndustry__c,
            CMN_Industry__c.CMN_SubIndustry__c,
            CMN_Industry__c.CMN_RiskRating__c,
            CMN_Industry__c.CMN_SlugID__c,
            CMN_Industry__c.CMN_Active__c,
            CMN_Industry__c.RecordType.Name    
        };
    }
}