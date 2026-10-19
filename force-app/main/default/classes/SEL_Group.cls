/**
 * @description                 : Selector Class for Group
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 28-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

 public inherited sharing class SEL_Group extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return Group.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Group.Id,
            Group.RelatedId,
            Group.DeveloperName,
            Group.Name
        };
    }
    
    /**
     * @description Select by Id
     * @param id Id of Group record
     * @return Group
     */
    public Group selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id = : id');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description select by DeveloperName and Type
    * @author Tushar Walse | 08-04-2025 
    * @param developerName DeveloperName field value to filter
    * @param type Type field value to filter
    * @return Group The record
    **/
    public Group selectByDeveloperNameAndType(String developerName, String type) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('DeveloperName = : developerName and Type = : type');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by set of Ids
     * @param ids Set of ids of Group records
     * @return List<Group>
     */
    public List<Group> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by set of RelatedIds
     * @param ids Set of RelatedIds
     * @return List<Group>
     */
    public List<Group> selectByRelatedIdsAndType(Set<Id> ids, String type) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('RelatedId IN : ids and Type = : type');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}