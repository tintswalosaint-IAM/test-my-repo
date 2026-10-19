/**
 * @name of the class: SEL_PartyAssetFunds
* @description Selector Class for PartyAssetFunds Entity
* Story:SFP-30128
* @author Ikyatha Naidu
* @date 09/11/2023
***************************************************************
* @last modified on  : 28-04-2025
* @last modified by  : Tushar Walse
* @ Modification Description : updated to latest version
***************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 11-09-2025
 * @Modification description : SFP-52215 added Industry fields
 ***************************************************************************************
*/
public inherited sharing class SEL_PartyAssetFunds extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>();
    private static final Map<String, String> RECORD_TYPE_MAP = new Map<String, String>{
        'Wealth' => 'Wealth in Country',
        'Funds' => 'Source of Funds',
        'future' => 'Source of Funds',
        'Additional' => 'Additional Accounts',
        'PrimaryAdditional' => 'Additional Accounts'
    };

    private static final Map<String, String> ADDITIONAL_CONDITIONS = new Map<String, String>{
        'PrimaryAdditional' => ' and Main_Account__c = true',
        'Additional' => ' and Main_Account__c = false and Account_Holder_Name_s__c != null',
        'future' => ' and Is_Future_Fund__c = true',
        'Funds' => ' and Is_Future_Fund__c = false'
    };

    Public  SEL_PartyAssetFunds(){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Party_Assets_Funds__c').getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()) {
            fields.add(fieldName);
            fields.add('RecordType.Name');
            fields.add('RecordType.DeveloperName');
            fields.add('CMN_Industry__c');
            fields.add('CMN_Industry__r.CMN_MainIndustry__c');
            fields.add('CMN_Industry__r.CMN_SubIndustry__c');
            fields.add('Party_Profile__r.AccountId');
        }
    }
    /**
* @description This is used to retrieve the sObject name when building the SOQL
* queries.
*
* @return the SObject type for the selector.
*/
    public override Schema.SObjectType getSObjectType(){
        return Party_Assets_Funds__c.SObjectType;
    }

    /**
* @description This is used to retrieve a specific set of SObject fields
*
* @return List of SObjectField
*/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Party_Assets_Funds__c.Id,
                Party_Assets_Funds__c.Party_Profile__c,
                Party_Assets_Funds__c.Occupation__c,
                Party_Assets_Funds__c.Value_of_the_business__c,
                Party_Assets_Funds__c.Industry__c,
                Party_Assets_Funds__c.Name,
                Party_Assets_Funds__c.Business_Location__c,
                Party_Assets_Funds__c.Cash_Based_Business__c,
                Party_Assets_Funds__c.Applicant_Share__c,
                Party_Assets_Funds__c.BankAccountDuration__c
                };
                    }

    /**
* @description Select by Party_Profile__c for SBO-UK Project
* @param partyProfileId
* @param type
* @return List of Party_Assets_Funds__c
*/
    public List<Party_Assets_Funds__c> selectAssetFundsByRecordType(String partyProfileId, List<String> typeList, String source) {
        String recordTypeId = getRecordTypeId(source);
        if (recordTypeId == null) {
            return null;
        }

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String condition = buildCondition(partyProfileId, typeList, recordTypeId, source);
        fieldQueryFactory.setCondition(condition);
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('Name', sbgplatform.fflib_QueryFactory.SortOrder.Ascending, true);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
        /**
    * @description Select by selectByWherClause for SBO-UK Project
    * @param partyProfileId
    * @param type
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByWherClause(string condition,string parentId) {

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition(condition);
        fieldQueryFactory.selectFields(fields);

        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }



    private String getRecordTypeId(String source) {
        String recordTypeName = RECORD_TYPE_MAP.get(source);
        return recordTypeName == null ? null : getRecordTypeIdByName('Party_Assets_Funds__c', recordTypeName);
    }

    private String buildCondition(String partyProfileId, List<String> typeList, String recordTypeId, String source) {
        if(recordTypeId == null || partyProfileId ==null){
            return null;
        }
        String baseCondition = 'Party_Profile__c = :partyProfileId and RecordTypeId = :recordTypeId';

        if (!typeList.isEmpty()) {
            baseCondition += ' and Type__c IN :typeList';
        }

        String additionalCondition = ADDITIONAL_CONDITIONS.get(source);
        return additionalCondition == null ?  baseCondition : baseCondition + additionalCondition;

    }

	public static Id getRecordTypeIdByName(String objectName, String recordTypeName) {

        if (String.isBlank(objectName) || String.isBlank(recordTypeName)) {
            throw new IllegalArgumentException('Object name and Record Type name cannot be null or empty.');
        }

         RecordType recordType = [
        SELECT Id FROM RecordType
        WHERE SObjectType = :objectName AND Name = :recordTypeName
        LIMIT 1
    ];
        // WITH SECURITY_ENFORCED
    return recordType == null ?  null : recordType.Id;

    }


    /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param partyProfileId
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectDepositInfoByPartyProfileIds(Set<Id> partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        Id additionalAccountRecordTypeId = Schema.getGlobalDescribe().get('Party_Assets_Funds__c').getDescribe().getRecordTypeInfosByName().get('Additional Accounts').getRecordTypeId();
        if(additionalAccountRecordTypeId == null){
            return null;
        }
        fieldQueryFactory.setCondition('Party_Profile__c in: partyProfileID and Initial_Deposit__c != null and recordtypeId=: additionalAccountRecordTypeId');
        fieldQueryFactory.selectFields(fields);
          String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

      /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param partyProfileId
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByPartyProfileType(Set<Id> partyProfileId,string recordtypeName,List<string>typeList) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
			string recId = getRecordTypeIdByName('Party_Assets_Funds__c',recordtypeName);
        if(recId == null){
            return null;
        }
        fieldQueryFactory.setCondition('Party_Profile__c =: partyProfileID and type__c in: typeList and recordtypeId=: recId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
            /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param partyProfileId
    * @param type
    * @param recordtypeName
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByPartyProfileTypewithRecordAssests(id partyProfileId,string typeList,string recordtypeName,boolean isFutureFund) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            string recId = getRecordTypeIdByName('Party_Assets_Funds__c',recordtypeName);
        if(recId == null){
            return null;
        }
        fieldQueryFactory.setCondition('Party_Profile__c =: partyProfileID and type__c =: typeList and recordtypeId=: recId and Is_Future_Fund__c = :isFutureFund');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

            /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param partyProfileId
    * @param type
    * @param recordtypeName
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByPartyProfileBulkTypewithRecordAssests(id partyProfileId,List<string> typeList,string recordtypeName,boolean isFutureFund) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            string recId = getRecordTypeIdByName('Party_Assets_Funds__c',recordtypeName);
        if(recId == null){
            return null;
        }
        fieldQueryFactory.setCondition('Party_Profile__c =: partyProfileID and type__c in: typeList and recordtypeId=: recId and Is_Future_Fund__c = :isFutureFund');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

     /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param partyProfileId
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByPartyProfileTypeList(String partyProfileId,List<string>typeList) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);

        fieldQueryFactory.setCondition('Party_Profile__c =: partyProfileID and type__c in: typeList');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('Number_of_Assets__c', sbgplatform.fflib_QueryFactory.SortOrder.Ascending, true);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }


        /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param partyProfileIDs
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByPartyProfileIds(Set<Id> partyProfileIDs) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Party_Profile__c in : partyProfileIDs');
        fieldQueryFactory.selectFields(fields);
         String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }


    /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param accountId
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByAccountId(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Party_Profile__c =: accountId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by Party_Profile__c for SBO-UK Project
    * @param contactIds
    * @return List of Party_Assets_Funds__c
    */
    public List<Party_Assets_Funds__c> selectByContactId(Set<Id> contactIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Party_Profile__c=: contactIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Get records by ids stored in Trust__c field
    * @author Tushar Walse | 28-04-2025 
    * @param ids 
    * @return List<Party_Assets_Funds__c> 
    **/
    public List<Party_Assets_Funds__c> selectByTrusts(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(ids == null){
            return null;
        }else{
          fieldQueryFactory.setCondition('Trust__c IN: ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

}