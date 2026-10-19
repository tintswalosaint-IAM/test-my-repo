/**
 * @description                 : Selector Class for GroupMember
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 04-02-2025
 * @last modified by            : Tushar Walse
 * @last modified on            : 07-23-2025
 * @last modified by            : Raja Arsalan
 * @modification description    : Created
 * @last modified on            : 12-03-2026
 * @last modified by            : Vikash Beersye
 * @modification description    : [SFP-44864] W&I: Value Transfer| Amend fields on Payload to VT Workfusion BOT
 */

 public inherited sharing class SEL_GroupMember extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return GroupMember.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            GroupMember.Id,
            GroupMember.GroupId,
            GroupMember.UserOrGroupId
        };
    }
    
    /**
     * @description Select by set of Ids
     * @param ids Set of ids of GroupMember records
     * @return List<GroupMember>
     */
    public List<GroupMember> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by set of UserOrGroupIds
    * @author Tushar Walse | 04-02-2025 
    * @param ids Set of UserOrGroupIds
    * @return List<GroupMember> 
    **/
    public List<GroupMember> selectByUserOrGroupIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('UserOrGroupId in :ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
     
    public List<GroupMember> selectByGroupId(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('GroupId IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
     
    /**
 * @description Check if a user is a member of the specified public group by group name.
 * @param groupName - Name of the public group 
 * @param userId - Id of the user to check
 * @return Boolean - true if user is a member of the group
 */
public Boolean isUserInGroupByName(String groupName, Id userId) {
        if (!Schema.sObjectType.Group.isAccessible() || !Schema.sObjectType.GroupMember.isAccessible()) {
            throw new AuraException('Insufficient permissions');
        }
    Group g = [
        SELECT Id 
        FROM Group 
        WHERE Name = :groupName AND Type = 'Regular' 
        LIMIT 1
    ];

    if (g == null){
        return false;
    }
    
    List<GroupMember> members = [
        SELECT Id 
        FROM GroupMember 
        WHERE GroupId = :g.Id AND UserOrGroupId = :userId
        LIMIT 1
    ];
		
    return !members.isEmpty();
}
 
     

}