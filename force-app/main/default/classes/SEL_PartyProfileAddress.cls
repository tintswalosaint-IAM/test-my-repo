/**
*@Name of the class: SEL_PartyProfileAddress
* @description class used to fetch partyProfileAddress
* Story:SFP-30128
* @author Ikyatha Naidu
* @date  09/11/2023
***************************************************
* @last modified on  : 04-06-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : SFP-30128
*/
public inherited sharing class SEL_PartyProfileAddress extends sbgplatform.fflib_SObjectSelector {
    //Adding Fields
    private static Set<String> fields = new Set<String>{
        'id', 'Name', 'PartyProfileId', 'Relationship_to_this_postal_address__c', 'Other_Relationship__c',
        'state', 'country', 'street', 'city', 'postalCode', 'AddressType', 'Date_Move_In__c', 'Date_Move_Out__c',
        'Building_Name__c', 'Parish__c', 'Sub_Building__c', 'Apartment_Number__c', 'Secondary_Street__c',
        'Neighbourhood__c', 'District__c', 'Sub_Region__c'
    };

    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public override Schema.SObjectType getSObjectType(){
        return PartyProfileAddress.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PartyProfileAddress.Id, PartyProfileAddress.Name, PartyProfileAddress.state,
            PartyProfileAddress.country, PartyProfileAddress.street, PartyProfileAddress.city,
            PartyProfileAddress.postalCode, PartyProfileAddress.Building_Name__c,
            PartyProfileAddress.Parish__c, PartyProfileAddress.Sub_Building__c,
            PartyProfileAddress.Apartment_Number__c, PartyProfileAddress.Secondary_Street__c,
            PartyProfileAddress.Neighbourhood__c
        };
    }

    /**
     * @description This Method list of PartyProfileAddress records by a given record ID using a query factory.
     * @param recordId
     * @return PartyProfileAddress
     */
    public List<PartyProfileAddress> selectById(String recordId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(recordId == null){
            return null;
        }else{
             fieldQueryFactory.setCondition('Id = :recordId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This Method returns PartyProfileAddress records by PartyProfileId with specific conditions using a query factory.
     * @param partyProfileId
     * @return PartyProfileAddress
     */
    public List<PartyProfileAddress> selectCurrentAddressByPartyProfileId(String partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String addressType = 'Residential Address'; 
        if(addressType != null){
            fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId AND AddressType = :addressType AND Date_Move_Out__c = null AND Date_Move_In__c != null');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This Method returns list of PartyProfileAddress records by a given partyProfile ID using a query factory.
     * @param partyProfileId
     * @param addressType
     * @return PartyProfileAddress
     */
    public List<PartyProfileAddress> selectByPartyProfileType(String partyProfileId, String addressType) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(addressType != null){
            fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId AND AddressType = :addressType');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This Method returns current residential PartyProfileAddress records by a set of PartyProfileId using a query factory.
     * @param partyProfileIds
     * @return List<PartyProfileAddress>
     */
    public List<PartyProfileAddress> selectCurrentResAddressByPartyProfileIds(Set<Id> partyProfileIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String addressType = 'Residential Address';
        if(addressType != null){
            fieldQueryFactory.setCondition('PartyProfileId IN :partyProfileIds AND AddressType = :addressType AND Date_Move_Out__c = null');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This Method returns current residential PartyProfileAddress records by a set of PartyProfileId using a query factory.
     * @param partyProfileIds
     * @return List<PartyProfileAddress>
     */
    public List<PartyProfileAddress> selectByPartyProfileIds(Set<Id> partyProfileIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfileId IN: partyProfileIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This Method Returns previous residential `PartyProfileAddress` records by `PartyProfileId`.
     * @param partyProfileId
     * @return List<PartyProfileAddress>
     */
    public List<PartyProfileAddress> selectPreviousAddressByPartyProfileId(String partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String addressType = 'Residential Address';
        if(addressType != null){
            fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId AND AddressType = :addressType AND Date_Move_Out__c != null AND Date_Move_In__c != null');
        }
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description This Method Returns correspondence `PartyProfileAddress` records by `PartyProfileId`.
     * @param partyProfileId
     * @return List<PartyProfileAddress>
     */
    public List<PartyProfileAddress> selectCorrespondanceAddressByPartyProfileId(String partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String addressType = 'Correspondence Address';
        if(addressType != null){
            fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId AND AddressType = :addressType');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}