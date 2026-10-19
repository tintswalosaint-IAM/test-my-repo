/**
 * @description       : Selector class for DSA_Ping_Registration_Site__mdt custom metadata type
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * @created date      : 09-10-2025
**/
public inherited sharing class SEL_DSA_PingRegistration_Site extends sbgplatform.fflib_SObjectSelector{
    /**
     * @description Defines the default fields to be added to all queries created ny the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     */
     private static Set<String> fields = new Set<String>{
        'Id',
        'INS_Comma_Separated_Permission_Set__c', 
        'INS_Network_Id__c',
        'INS_Username_Suffix__c'
    };
    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return DSA_Ping_Registration_Site__mdt.SObjectType;
    }
    /**
     *
     * @description Method to get list of fields to be part of response
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            DSA_Ping_Registration_Site__mdt.Id,
            DSA_Ping_Registration_Site__mdt.INS_Comma_Separated_Permission_Set__c,
            DSA_Ping_Registration_Site__mdt.INS_Network_Id__c,
            DSA_Ping_Registration_Site__mdt.INS_Username_Suffix__c
        };
    }
    /**
     * @description Select DSA_Ping_Registration_Site__mdt by network id
     * @param networkId
     * @return List<DSA_Ping_Registration_Site__mdt>
     **/
    public DSA_Ping_Registration_Site__mdt selectByNetworkId(String networkId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('INS_Network_Id__c =:networkId');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}