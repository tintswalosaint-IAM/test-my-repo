/**
*@Name of the class:SEL_PartyProfile
* @description class used to fetch partyProfile
* Story:SFP-30128
* @author Ofentse Sacha
* @date  09/11/2023
***************************************************
* @last modified on  : 07-11-2024
* @last modified by  : Dhriven Hamlall
* @Modification Description : SFP-32079
* @Last Modified : SFP-51839 - Added Document sync fields to the selector.
* @Last Modified : SFP-53266 - updated class to accomodate TSR feedback.
***************************************************
* Last Modified By Alexandr Goryachko
* Last Modified Date 10/03/2026
* Last Modified Description: Added FundSource field to query
* User Story : SFP-54457
*/
public without sharing class SEL_PartyProfile extends sbgplatform.fflib_SObjectSelector {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SEL_PartyProfile');

    /**
     * @description adding fields to retrieve.
     */
    private static Set<String> fields = new Set<String>{
            'Account.CMN_IdentityNumber__pc',
            'Account.FirstName',
            'Account.LastName',
            'Account.Name',
            'Account.PersonEmail',
            'AccountId',
            'Birthdate__c',
            'CMN_CardNumber__c',
            'CMN_Channel__c',
            'CMN_DocumentSyncReason__c',
            'CMN_DocumentSyncStatus__c',
            'CMN_FICPIP__c',
            'CMN_FICPIPREL__c',
            'CMN_FICPIPRELFIRSTNAME__c',
            'CMN_FICPIPRELLASTNAME__c',
            'CMN_Initials__c',
            'CMN_IsEmployed__c',
            'CMN_OccupationLevel__c',
            'CMN_RelyComplyCustomerId__c',
            'Country_of_Nationality__c',
            'Country_of_Residence__c',
            'CountryofBirth',
            'CreatedDate',
            'DateOfBirth',
            'Different_First_Name__c',
            'Different_Last_Name__c',
            'Different_Middle_Name__c',
            'EmploymentIndustry',
            'EmploymentType',
            'FirstName',
            'Former_Name__c',
            'FullName',
            'Gender',
            'Has_Former_Name__c',
            'Has_Maiden_Name__c',
            'Has_different_First_Middle_Family_Name__c',
            'Id',
            'Industry__c',
            'IsClientCancelled__c',
            'IsClientOnboarded__c',
            'IsUpdateAvailable__c',
            'LastName',
            'LastProfileReviewDate',
            'Location_of_Business__c',
            'Maiden_Name__c',
            'MiddleName',
            'Name',
            'Opportunity__c',
            'OwnerId',
            'Percentage_Of_The_Business_Owned__c',
            'Percentage_of_Business__c',
            'Person_Title__c',
            'Preferred_Method_of_Contact__c',
            'PrimaryEmail',
            'PrimaryIdentifier',
            'PrimaryIdentifierType',
            'PrimaryPhone',
            'RecordType.Name',
            'RecordTypeId',
            'RelatedPartyProfileId',
            'ResponseMessage__c',
            'Second_Country_of_Nationality__c',
            'SurnameAtBirth',
            'FundSource',
            'Town_City_of_Birth__c',
            'WI_CountryOfCitizenship__c',
            'WI_IdentificationDocumentIssuingCountry__c',
            'WI_MaritialStatus__c',
            'WI_MaritialType__c',
            'WI_PassportIssuingCountry__c',
            'WI_PrimaryIdentificationName__c',
            'WI_WhatIsTheNatureOfRelationship__c',
            'WorldcheckStatus__c'
    };


    /**
    * @description gets  SObjectType
    * @param
    * @return SObjectType
    */
    public override Schema.SObjectType getSObjectType(){
        return PartyProfile.SObjectType;
    }

    /**
     * @description This is used to retrieve a specific set of SObject fields
     * @param
     * @return List of SObjectField
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                PartyProfile.Id,
                PartyProfile.accountid
        };
    }

    /**
     * @description This method retrieves a PartyProfile record associated with a given Account Id
     * @param accId
     * @return PartyProfile
     */
    public PartyProfile selectByAccountAndRecordType(string accId,string recName) {
        PartyProfile profileInfo = new PartyProfile();
        Id recId=getRecordTypeIdByName('PartyProfile',recName);
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(recId != null){
            fieldQueryFactory.setCondition('accountId =: accId and recordtypeId=: recId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        List<PartyProfile> profileList = Database.query(query);
        if(profileList.IsEmpty()){
            profileInfo = new PartyProfile();
        }else{
            profileInfo = profileList[0];
        }

        return profileInfo;
    }

    /**
     * @description This method retrieves a list of 'ICS Additional Business Owner' PartyProfile records associated with a given PartyProfile Id.
     * @param partyProfileId
     * @return List of PartyProfile
     */
    public List<PartyProfile> selectBusinessOwnerByPartyProfileId(string partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        Id recId=getRecordTypeIdByName('PartyProfile','ICS_Additional_Business_Owner');
        if(recId != null){
            fieldQueryFactory.setCondition('RelatedPartyProfileId =: partyProfileId and recordtypeId=:recId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This method retrieves a list of 'ICS Additional Business Owner' PartyProfile records associated with a given PartyProfile Id.
     * @param partyProfileId
     * @return List of PartyProfile
     */
    public List<PartyProfile> selectByPartyAssetFund(string partyAssetfundId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        Id recId=getRecordTypeIdByName('PartyProfile','ICS_Additional_Business_Owner');
        if(recId != null){
            fieldQueryFactory.setCondition('Party_Assets_Funds__c =: partyAssetfundId and recordtypeId=:recId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
   * @description This method retrieves a list of PartyProfile records associated with a given set of Account Ids for the SBO-UK project
   * @param ids
   * @return PartyProfile
   */
    public List<PartyProfile> selectByAccountIds(set<id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(ids == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('accountId IN :ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by Id for SBO-UK Project
     * @author Ofentse Sacha
     * @param accId
     * @return PartyProfile
     */
    public List<PartyProfile> selectByAccountId(String accId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accId == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('accountId =: AccId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
   * @description Select by Id for SBO-UK Project
   * @param ids
   * @return PartyProfile
   */
    public List<PartyProfile> selectByIds(set<id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(ids == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('Id IN: ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by RelatedPartyProfileId for SBO-UK Project
    * @param ids
    * @return PartyProfile
    */
    public List<PartyProfile> selectByRelatedPartyProfileIds(set<id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(ids == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('RelatedPartyProfileId IN: ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Fetches a PartyProfile based on Record ID.
    * @param recordId The Record ID.
    * @return PartyProfileSFP-11621 Display the WorldCheck screening outcomes
    */
    public PartyProfile selectById(String recordId) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, false);
        if(recordId == null){
            return null;
        }else{
            queryFactory.setCondition('Id = :recordId');
        }
        queryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(queryFactory.toSOQL());
        return Database.query(query);
    }


    public static Id getRecordTypeIdByName(String objectName, String recordTypeName) {
        if (String.isBlank(objectName) || String.isBlank(recordTypeName)) {
            throw new IllegalArgumentException('Object name and Record Type name cannot be null or empty.');
        }

        if (!Schema.sObjectType.RecordType.fields.Id.isAccessible()) {
            LOGGER.error('Insufficient permissions to query RecordType');
        }

        try {
            List<RecordType> recordTypes = [
                    SELECT Id
                    FROM RecordType
                    WHERE SObjectType = :objectName
                    AND DeveloperName = :recordTypeName
                    LIMIT 1
            ];
            if(recordTypes.isEmpty()){
                return null;
            }else{
                return recordTypes[0].Id;
            }
        } catch (QueryException e) {
            throw new AuraHandledException('Error retrieving RecordType: ' + e.getMessage());
        }
    }

    /**
     * @description Select by Id for SBO-UK Project
     * @author
     * @param accId and primaryIdentifier
     * @return PartyProfile
     **/
    public List<PartyProfile> selectByAccountIdANDPrimaryIdentifier(String accId, String primaryIdentifier) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accId == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('accountId =: AccId AND PrimaryIdentifier=:primaryIdentifier');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
       * @description Select by Id for KYC Party Profile
       * @param accId
       * @return PartyProfile
       */
    public Map<Id, PartyProfile> selectByIdsandRecordType(set<Id> idList,string recName) {
        string recId = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().getRecordTypeInfosByDeveloperName().get(recName).getRecordTypeId();
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(recId != null){
            fieldQueryFactory.setCondition('Id IN: idList and recordtypeId=: recId');
        }
        fieldQueryFactory.selectFields(new Set<String>{'Id'});
        String query = fieldQueryFactory.toSOQL();

        return new Map<Id, PartyProfile>((PartyProfile[])Database.query(query));
    }




    /**
    * @description Method to fetch existing of Party Profiles based on FirstName, LastName, DateOfBirth, WI_PrimaryIdentificationName__c
    * @param  firstName, lastName, dateOfBirth, primaryIdNumber
    * @return List<PartyProfile>
    **/
    public List<PartyProfile> selectByFirstLastNameandDateofBirth(String firstName, String lastName, Date dateOfBirth, String primaryIdNumber) {
        List<PartyProfile> returnList = new List<PartyProfile>();
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String conditions = 'FirstName = :firstName AND LastName = :lastName AND DateOfBirth = :dateOfBirth AND WI_PrimaryIdentificationName__c = :primaryIdNumber AND LastModifiedDate >= LAST_N_MONTHS:12';
        fieldQueryFactory.setCondition(conditions);
        fieldQueryFactory.selectFields(fields);
        String query = fieldQueryFactory.toSOQL();
        returnList = Database.query(query);
        return returnList;
    }

    /**
* @author Dhriven Hamlall | 7-11-2024
* @description Retrieves a list of PartyProfile records associated with either a Lead or Account,
*              filtered by the specified RecordType 'Insurance_Individual'.
* @param recordId The ID of the Lead or Account record to filter by.
* @param isLead Boolean flag indicating whether the provided recordId is a Lead (true) or Account (false).
* @return List of PartyProfile records associated with the given Lead or Account ID and record type.
*/
    public List<PartyProfile> selectInsuranceIndividualPartyProfileById(String recordId, Boolean isLead) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(new Set<String>{'Id', 'LeadId', 'AccountId'});
        String condition = (isLead ? 'LeadId = :recordId' : 'AccountId = :recordId') +
                ' AND RecordType.DeveloperName = \'Insurance_Individual\'';
        fieldQueryFactory.setCondition(condition);
        return Database.query(fieldQueryFactory.toSOQL());
    }


    public List<PartyProfile> selectByAccountId(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AccountId IN:accountIds');
        fieldQueryFactory.selectFields(fields);
        List<String> subQueryFields = new List<String>{'id', 'Date_Move_In__c', 'Date_Move_Out__c', 'AddressType', 'Address', 'Street', 'City', 'State', 'PostalCode', 'Country', 'Building_Name__c', 'Apartment_Number__c', 'Neighbourhood__c', 'Secondary_Street__c', 'Sub_Building__c', 'Parish__c'};
        fieldQueryFactory.subselectQuery('PartyProfileAddresses').selectFields(subQueryFields).setOrdering('Date_Move_In__c', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);

        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    public List<PartyProfile> selectByAccountIdandPrimaryIdentificationName(Set<Id> accountIds,set<String> PrimaryIdentificationName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('accountId In: accountIds AND PrimaryIdentificationName In: PrimaryIdentificationName');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}