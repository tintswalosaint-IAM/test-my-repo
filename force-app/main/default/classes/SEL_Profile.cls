/**
 * @description       : Selector class for Profile
 * @story             : SFP-47621 - DSA Portal Ping registration
 * @author            : Jaco de Lange
 * @created date      : 17-09-2025
 * @group             : Cloudsmiths
**/
public inherited sharing class SEL_Profile extends sbgplatform.fflib_SObjectSelector{

    /**
    * @description Defines the default fields to be added to all queries created ny the Query Factory
    * @return List of Schema.SObjectField objects representing the fields
    */
    private static Set<String> fields = new Set<String>{
        'Id',
        'Name'
    };

    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return Profile.SObjectType;
    }

    /**
    *
    * @description Method to get list of fields to be part of response
    * @return  `List<Schema.SObjectField>`
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Profile.Id,
            Profile.Name
        };
    }
    /**
     * @description Select profile by Name
     * @param profileName
     * @return List<Profile>
     **/
    public List<Profile> selectByName(String profileName) {
        if(!Schema.SobjectType.Profile.isAccessible()){
            return null;
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Name =:profileName');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    } 
}