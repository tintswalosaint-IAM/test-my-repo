/**
 * @description                 : Selector Class for UserRole
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 26-05-2025
 * @last modified on            : 26-05-2025
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_UserRole extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return UserRole.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            UserRole.Id,
            UserRole.Name,
            UserRole.ParentRoleId,
            UserRole.DeveloperName
        };
    }    

    /**
     * @description Select by id
     * @param id
     * @return UserRole
     */
    public UserRole selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select by set of Ids
     * @param ids
     * @return List<UserRole>
     */
    public List<UserRole> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}