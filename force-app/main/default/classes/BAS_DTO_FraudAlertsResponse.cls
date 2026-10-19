/**
* @description Fraud Alerts API response
*
* @author Sandile Mathe
*
* @date April 2024
*/
@JsonAccess(deserializable='always')
public with sharing class BAS_DTO_FraudAlertsResponse {  
 
        @AuraEnabled public String detail { get; set; }
        @AuraEnabled public String eventContent { get; set; }
        @AuraEnabled public String eventDetails { get; set; }
        @AuraEnabled public String accountId { get; set; }
        @AuraEnabled public String eventType { get; set; }
        @AuraEnabled public String eventId { get; set; }
        @AuraEnabled public String portfolioCode { get; set; }
        @AuraEnabled public Date eventLoadDate { get; set; }
        @AuraEnabled public String clientName { get; set; }
        @AuraEnabled public String aeNumber { get; set; }
        @AuraEnabled public String bpid { get; set; }
            
}