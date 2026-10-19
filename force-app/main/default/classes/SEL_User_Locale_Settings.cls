/**
 * @description       : Selector class for INS_User_Locale_Settings custom metadata type
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * @created date      : 22-09-2025
 * @group             : Cloudsmiths
**/
public inherited sharing class SEL_User_Locale_Settings extends sbgplatform.fflib_SObjectSelector{
    /**
     * @description Defines the default fields to be added to all queries created ny the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */
     private static Set<String> fields = new Set<String>{
        'Id',
        'INS_Country__c', 
        'INS_Currency_Code__c',
        'INS_Language_Locale__c',
        'INS_Locale__c',
        'INS_Time_Zone__c'
    };
    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return INS_User_Locale__mdt.SObjectType;
    }
    /**
     *
     * @description Method to get list of fields to be part of response
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            INS_User_Locale__mdt.Id,
            INS_User_Locale__mdt.INS_Country__c,
            INS_User_Locale__mdt.INS_Currency_Code__c,
            INS_User_Locale__mdt.INS_Language_Locale__c,
            INS_User_Locale__mdt.INS_Locale__c,
            INS_User_Locale__mdt.INS_Time_Zone__c
        };
    }
    /**
     * @description Select INS_User_Locale__mdt by country
     * @param country
     * @return List<INS_User_Locale__mdt>
     **/
    public INS_User_Locale__mdt selectByCountry(String country) {
        if(!Schema.SobjectType.INS_User_Locale__mdt.isAccessible()){
            return null;
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('INS_Country__c =:country');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}