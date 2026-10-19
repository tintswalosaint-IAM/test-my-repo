/**
 * @description       : Selector class for CampaignMember
 * @author            : Raja Arsalan
 * @group             : Selector
 * @testClass         : SEL_CampaignMember_Test
 * @last modified on  : 27-06-2025
 * @last modified by  : Raja Arsalan
**/
public inherited sharing class SEL_CampaignMember extends sbgplatform.fflib_SObjectSelector {

    /**
    * @description Default constructor must call super()
    **/
    public SEL_CampaignMember() {
        super();
    }

    /**
     * @description Defines the default fields to be added to all queries created by the Query Factory
     * @return List of Schema.SObjectField objects representing the fields
     **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CampaignMember.Id,
            CampaignMember.LeadId,
            CampaignMember.CampaignId
        };
    }

    /**
     * @description Returns the object type
     * @return Schema.SObjectType
     **/
    public override Schema.SObjectType getSObjectType() {
        return CampaignMember.SObjectType;
    }

    /**
     * @description Method to retrieve existing CampaignMember records by LeadId and CampaignId
     * @author Raja Arsalan | 27-06-2025
     * @param leadIds Set of Lead record Ids
     * @param campaignIds Set of Campaign record Ids
     * @return list
     **/
  public List<CampaignMember> selectCampaignMembersByLeadAndCampaignIds(Set<Id> leadIds, Set<Id> campaignIds) {
    if (leadIds.isEmpty() || campaignIds.isEmpty()) {
        return new List<CampaignMember>();
    }

    return [
        SELECT Id, LeadId, CampaignId
        FROM CampaignMember
        WHERE LeadId IN :leadIds AND CampaignId IN :campaignIds
    ];
}
}