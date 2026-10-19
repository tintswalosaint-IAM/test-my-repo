/**
 * @description       : Selector class for Site object
 * @author            : Jaco de Lange
 * @group             : IAM : SFP-48886 - Premium Collection Gateway - Initiate payment collection via Mobility
 * @last modified on  : 07-01-2025
**/
public inherited sharing class SEL_Site  extends sbgplatform.fflib_SObjectSelector{
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
        return Site.SObjectType;
    }
     /**
     *
     * @description Method to get list of fields to be part of response
     * @return  `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Site.Id,
            Site.Name
        };
    }
    /**
     * @description Select site by name
     * @param siteName
     * @return List<Site>
     **/
    public List<Site> selectByName(String siteName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.setCondition('Name =:SiteName');
        fieldQueryFactory.selectFields(fields);
        return Database.query(fieldQueryFactory.toSOQL());
    }
}