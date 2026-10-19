/**
* @description       : Selector class for Campaign
* @author            : Derek Hughes
* @group             : Selector
* @testClass         : SEL_Campaign_Test, CMN_TRH_Lead_Test
* @last modified on  : 07-07-2025
* @last modified by  : Raja Arsalan
*
* Change log
* 2025-07-07   Raja Arsalan    Added selectCampaignsByName and selectByCampaignSourceIds methods for fetching the campaign records.
**/
public inherited sharing class SEL_Campaign extends sbgplatform.fflib_SObjectSelector {
    
    /**
* @description Default contructor must call super()
**/
    public SEL_Campaign() {
        super();
    }
    
    /**
* @description Defines the default fields to be added to all queries created ny the Query Factory
* @return List of Schema.SObjectField objects representing the fields
*/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Campaign.Id,
                Campaign.Name
                };
                    }
    
    /**
* @description Returns the object type
* @return Schema.SObjectType 
**/
    public override Schema.SObjectType getSObjectType() {
        return Campaign.SObjectType;
    }
    
    /**
* @description Select all the campaigns for those campaign codes with any members for the leads 
* @author Derek Hughes | 12-05-2024 
* @param campaignCodes 
* @param leadIds 
* @return List<Campaign> 
**/
    public List<Campaign> selectWithMembersByCampaignCodes(Set<String> campaignCodes, Set<Id> leadIds) {
        
        final List<Campaign> campaigns = [
            SELECT 
            Id, Campaign_Code__c, Name, 
            (SELECT Id, CampaignId, LeadId FROM CampaignMembers WHERE LeadId IN :leadIds) 
            FROM Campaign 
            WHERE Campaign_Code__c IN :campaignCodes
        ];
        return campaigns;
    }
    
    /**
* @description Select all the campaigns for those campaign sources. This method runs **without enforce crud and fls** to allow full access to records, ignoring the user's access. 
* @param campaignSourceIds 
* @return List<Campaign> 
**/

//TODO: Is this where I must add the new fields from Campaign???
    public List<Campaign> selectByCampaignSourceIds(Set<String> campaignSourceIds) {
        if (campaignSourceIds == null || campaignSourceIds.isEmpty()) {
            return new List<Campaign>();
        }
        
        sbgplatform.fflib_QueryFactory campaignQueryFactory = newQueryFactory(false, false, false);
        String combinedConditions = 'Campaign_Source_ID__c IN :campaignSourceIds';
        campaignQueryFactory.setCondition(combinedConditions);
        campaignQueryFactory.selectFields(new Set<String>{
                'Id',
                'Campaign_Source_ID__c',
                'Name',
                'Dialler_System_Code__c',
                'INS_Campaign_Start_Time__c',
                'INS_Campaign_End_Time__c'
                });
        String generatedSOQL = campaignQueryFactory.toSOQL();
        return (List<Campaign>) Database.query(generatedSOQL);
    }

    
    /**
* @description Select all campaigns matching given names. This method runs **without enforce crud and fls** to allow full access to records, ignoring the user's access. 
* @author      Arsalan Mehfooz
* @param       campaignNames
* @return      List<Campaign>
**/
    public List<Campaign> selectCampaignsByName(List<String> campaignNames) {
        if (campaignNames == null || campaignNames.isEmpty()) {
            return new List<Campaign>();
        }
        
        sbgplatform.fflib_QueryFactory campaignQueryFactory = newQueryFactory(false, false, false);
        
        String combinedConditions = 'Name IN :campaignNames';
        campaignQueryFactory.setCondition(combinedConditions);
        campaignQueryFactory.selectFields(new Set<String>{
            'Id',
                'Name'
                });
        
        String generatedSOQL = campaignQueryFactory.toSOQL();
        return (List<Campaign>) Database.query(generatedSOQL);
    }

    
}