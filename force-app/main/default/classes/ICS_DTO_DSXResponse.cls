/**
 * @description DSX API response
 * @author Gnitsevich Anton
 * @date January 2023
 */
public with sharing class ICS_DTO_DSXResponse {
    
    /**
     * @description Inner Class for DSX Search
     */
    public class Search {
        
       /**
       * @description  Document page information
       */        
        @AuraEnabled public PageInfo pageInfo { get; set; }
       /**
       * @description  Document information in DSX
       */        
        @AuraEnabled public List<DocumentInfo> documents { get; set; }
    }
    
    /**
     * @description Inner Class for DSX PageInfo
     */
    public class PageInfo {
        
       /**
       * @description  DSX current page
       */        
        @AuraEnabled public Integer currentPage { get; set; }
       /**
       * @description  DSX total pages
       */        
        @AuraEnabled public Integer totalPages { get; set; }
    }
    
    /**
     * @description Inner Class for DSX DocumentInfo
     */
    public class DocumentInfo {
       /**
       * @description  Document id when document is stored in DSX
       */        
        @AuraEnabled public String documentId { get; set; }
       /**
       * @description  Document name
       */        
        @AuraEnabled public String documentName { get; set; }
       /**
       * @description  DSX document type
       */        
        @AuraEnabled public String documentType { get; set; }
       /**
       * @description  Document received date
       */        
        @AuraEnabled public String documentDate { get; set; }
       /**
       * @description  Document retention date
       */        
        @AuraEnabled public String retentionDate { get; set; }
       /**
       * @description  DSX client number/BP number Account id
       */        
		@AuraEnabled public String clientNo { get; set; }
       /**
       * @description  DSX client name
       */        
        @AuraEnabled public String clientName { get; set; }
       /**
       * @description  Salesforce Account id
       */        
        @AuraEnabled public String salesForceId { get; set; }
    }
}