/**
 * @description       : Selector class for OrgWideEmailAddress
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52370
 * @date              : 24-03-2026
 **/
public inherited sharing class SEL_OrgWideEmailAddress extends sbgplatform.fflib_SObjectSelector {

    public override Schema.SObjectType getSObjectType() {
        return OrgWideEmailAddress.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OrgWideEmailAddress.Id,
            OrgWideEmailAddress.DisplayName,
            OrgWideEmailAddress.Address            
        };
    }
  /**
     * @description Fetch a single Org-Wide Email Address by Address Name
     * @param Address name of the Org-Wide Email Address
     * @return OrgWideEmailAddress     
     */
    public OrgWideEmailAddress selectOneByAddress(String address) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, true);
        queryFactory.setCondition('Address = :address');
        queryFactory.setLimit(1);
    
        List<OrgWideEmailAddress> results = Database.query(queryFactory.toSOQL());
        return results.isEmpty() ? null : results[0];
    }
}