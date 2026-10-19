/**
 * @description Selector class for Account object.
 * This class provides methods to retrieve Account records.
 * 
 * @testClass CMN_SRV_AccountTeamUpdate
 *
 * @author Dhiraj Kumar
 */
public inherited sharing class CMN_SEL_Account extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Default contructor must call super()
    **/
    public CMN_SEL_Account() {
        super();
    }

    private List<String> getDefaultFields() {
        return new List<String> {
            'Id',
            'Name',
            'OwnerId',
            'Owner.RM_AE_Code__c',
            'Owner.IsActive',
            'RelationshipMgrCode__c',
            'VIPIndicator__c',
            'ExternalCIFCountry__c'
        };
    }

    private List<String> getTeamMembersFields() {
        return new List<String> {
            'Id',
            'AccountId',
            'UserId',
            'TeamMemberRole',
            'AccountAccessLevel'
        };
    }

    /**
     * @description Retrieves a list of Account fields dynamically.
     * @return List of Schema.SObjectField objects representing the fields of the Account object
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
       return new List<Schema.SObjectField>{};
    }

    /**
    * @description Returns the object type
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    /**
    * @description Gets Accounts with the Account Team Member 
    * @author Dhiraj Kumar | 30-01-2024 
    * @param records 
    * @param countries 
    * @return List<Account> 
    **/
    public List<Account> selectWithAccountTeamsByCountries(Set<Id> records, Set<String> countries) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ExternalCIFCountry__c IN :countries AND Id IN :records');
        fieldQueryFactory.selectFields(this.getDefaultFields());
        sbgplatform.fflib_QueryFactory childQuery = fieldQueryFactory.subselectQuery(
            this.getChildRelationship(
                this.getSObjectType(),
                AccountTeamMember.SObjectType
            )
        );
        childQuery.selectFields(this.getTeamMembersFields());
        return Database.Query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Gets the chiled relationships from a parent and child combination
    * @author Dhiraj Kumar | 30-01-2024 
    * @param parentObject 
    * @param childObject 
    * @return Schema.ChildRelationship 
    **/
    private Schema.ChildRelationship getChildRelationship(
            SObjectType parentObject,
            SObjectType childObject
    ) {
        Schema.ChildRelationship childRelation;
        for (
                Schema.ChildRelationship child :
                parentObject.getDescribe().getChildRelationships()
        ) {
            if (child.getChildSObject() == childObject && child.getRelationshipName() != null) {
                childRelation = child;
                break;
            }
        }
        return childRelation;
    }

    /**
    * @description Select Accounts for a set of External Identifiers
    * @author Derek Hughes | 12-05-2024 
    * @param externalIds 
    * @return List<Account> 
    **/
    public List<Account> selectByExternalIds(Set<String> externalIds) {
        final List<Account> accounts = [
            SELECT Id, ExternalIdentifier__c, Name 
            FROM Account 
            WHERE ExternalIdentifier__c IN :externalIds
        ];

        return accounts;
    }
}