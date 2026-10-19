/**
* @description       : Selector Class for Leads_ProductQueueAllocation__c 
* @author            : Raja Arsalan
* @last modified on  : 10-31-2023
**/
public inherited sharing class INS_SEL_Leads_ProductQueueAllocation extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{'Id', 
        'Leads_Product_Name__c',
        'Leads_Product_Group__c',
        'Leads_Product_Family__c',
        'Leads_ProductSubFamily__c',
        'Leads_Jurisdiction__c',
        'Lead_Type__c'
        };
            
            
            public override Schema.SObjectType getSObjectType() {
                return Leads_ProductQueueAllocation__c.sObjectType;
            }
    
    /**
* @description Method to get list of fields to be part of response
* @author Raja Arsalan | 05-31-2023 
* @return List<Schema.SObjectField> 
**/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Leads_ProductQueueAllocation__c.Id, 
                Leads_ProductQueueAllocation__c.Leads_Product_Name__c,
                Leads_ProductQueueAllocation__c.Leads_Product_Group__c,
                Leads_ProductQueueAllocation__c.Leads_Product_Family__c,
                Leads_ProductQueueAllocation__c.Leads_ProductSubFamily__c,
                Leads_ProductQueueAllocation__c.Leads_Jurisdiction__c,
                Leads_ProductQueueAllocation__c.Lead_Type__c
                };
                    }
    
    
    /**
* @description Method to fetch list of Leads_ProductQueueAllocation__c based on Lead Id
* @param expressedProdutId
* @return List<Leads_ProductQueueAllocation__c> 
**/
    public List<Leads_ProductQueueAllocation__c> selectProductQueueAllocationById(String expressedProdutId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =:expressedProdutId');
        fieldQueryFactory.selectFields(fields); 
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
* @description Retrieves a list of Leads_ProductQueueAllocation__c records by their IDs.
* @param productQueueIds 
* @return List 
*/
    public List<Leads_ProductQueueAllocation__c> selectProductQueueByIds(Set<Id> productQueueIds) {
        if (productQueueIds == null || productQueueIds.isEmpty()) {
            return new List<Leads_ProductQueueAllocation__c>();
        }
        
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN :productQueueIds');
        fieldQueryFactory.selectFields(fields); 
        String query = fieldQueryFactory.toSOQL();
        return Database.query(query);
    }
    

    /**
 * @Description Retrieves active product queue allocation records by jurisdiction and segment.
 * @Param jurisdiction
 * @Param segment
 * @Return List<Leads_ProductQueueAllocation__c>
 */
public List<Leads_ProductQueueAllocation__c> selectAvailableProducts(
    String Jurisdiction,
    String Segment
) {
    sbgplatform.fflib_QueryFactory qf = newQueryFactory(true, true, false);

    qf.selectFields(new List<String>{
        'Id',
        'Leads_Product_Search__c',
        'Leads_Product_Title__c'
    });

    qf.setCondition(
        'Leads_Jurisdiction__c = :jurisdiction ' +
        'AND Leads_Product_Segment__c = :segment ' +
        'AND Active__c = TRUE ' +
        'AND CMN_Visible_for_Product_Referral__c = TRUE'
    );

    qf.addOrdering('Lead_Product_Level__c', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
    system.debug('QUERY' + qf.toSOQL());
    system.debug('JUR' + Jurisdiction);
    system.debug('SEG' + Segment);
    return Database.query(qf.toSOQL());
}
    
    
    
    
    
}