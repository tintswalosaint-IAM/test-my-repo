/**
    * @description       : Selector Class for CampaignMember 
    * @author            : Raja Arsalan
    * @last modified on  : 10-31-2023
   **/
   public inherited sharing class INS_SEL_CampaignMember extends sbgplatform.fflib_SObjectSelector {
       private static Set<String> fields = new Set<String>{'Id', 
           'CampaignId',
           'leadId'
       };
               
/**
    * @description       : Selector Class for CampaignMember 
**/          
           public override Schema.SObjectType getSObjectType() {
               return CampaignMember.sObjectType;
           }
       
           /**
           * @description Method to get list of fields to be part of response
           * @author Raja Arsalan | 10-31-2023 
           * @return List<Schema.SObjectField> 
           **/
           public override List<Schema.SObjectField> getSObjectFieldList() {
               return new List<Schema.SObjectField> {
                CampaignMember.Id, 
                CampaignMember.CampaignId,
                CampaignMember.leadId 
                   };
           }
       
       
           /**
           * @description Method to fetch list of CampaignMember based on Lead Id
           * @param leadId
           * @return List<CampaignMember> 
           **/
           public List<CampaignMember> selectCampaignMemberById(String leadId) {
               sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
               fieldQueryFactory.setCondition('leadId =:leadId');
               fieldQueryFactory.selectFields(fields); 
               return Database.query(fieldQueryFactory.toSOQL());
           }
   
   
           
   }