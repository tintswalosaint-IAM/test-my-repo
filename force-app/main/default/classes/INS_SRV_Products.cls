/**
* @description       : SFP-54443 - Service class for fetching Product picklist values in the Leads flow.
* @author            : Raja Arsalan
* @group             : Standard Bank
* @last modified on  : 20-07-2026
* @last modified by  : Raja Arsalan
**/

public inherited sharing class INS_SRV_Products {
    
    private INS_SRV_Products() {
    }
    
    
    /**
* @description Retrieves the active picklist values for the specified
*              field and returns them as product response wrappers.
*
* @param fieldName
* @return A list of INS_DTO_ProductResponse objects.
*/    
    public static List<INS_DTO_ProductResponse> getAvailableValuesinPickList(String fieldName) {
        
        
        List<INS_DTO_ProductResponse> response = new List<INS_DTO_ProductResponse>();
        
        Schema.DescribeFieldResult fieldDescription;
        
        switch on fieldName {
            when 'jurisdiction' {
                fieldDescription = Leads_ProductQueueAllocation__c.Leads_Jurisdiction__c.getDescribe();
            }
            when 'segment' {
                fieldDescription = Leads_ProductQueueAllocation__c.Leads_Product_Segment__c.getDescribe();
            }
            when else {
                throw new IllegalArgumentException('Invalid field name: ' + fieldName);
            }
        }
        
        for (Schema.PicklistEntry entry : fieldDescription.getPicklistValues()) {
            
            if (entry.isActive()) {
                
                INS_DTO_ProductResponse wrapper = new INS_DTO_ProductResponse();
                
                wrapper.name = entry.getLabel();
                wrapper.value = entry.getValue();
                wrapper.subtext = '';
                
                response.add(wrapper);
            }
        }
        
        return response;
    }
    
    
    /**
* @description Retrieves the available products based on the specified
*              jurisdiction and segment.
*
* @param Jurisdiction
* @param Segment
* @return A list of INS_DTO_ProductResponse objects.
*/    
    
    public static List<INS_DTO_ProductResponse> getAvailableProducts(
        String Jurisdiction,
        String Segment
    ) {
        
        INS_SEL_Leads_ProductQueueAllocation selector =
            new INS_SEL_Leads_ProductQueueAllocation();
        
        List<Leads_ProductQueueAllocation__c> products =
            selector.selectAvailableProducts(Jurisdiction, Segment);
        
        List<INS_DTO_ProductResponse> response =
            new List<INS_DTO_ProductResponse>();
        
        for (Leads_ProductQueueAllocation__c product : products) {
            
            INS_DTO_ProductResponse wrapper =
                new INS_DTO_ProductResponse();
            
            wrapper.name = product.Leads_Product_Search__c;
            wrapper.value = product.Id;
            wrapper.subtext = product.Leads_Product_Title__c;
            wrapper.subtext = product.Leads_Product_Search__c;
            
            response.add(wrapper);
        }
        
        return response;
    }
    
    /**
* @description Wrapper class used to return product
*              and picklist data to Lightning components.
*/
    public class INS_DTO_ProductResponse {
        
        @AuraEnabled public String name;
        @AuraEnabled public String value;
        @AuraEnabled public String subtext;
    }
}