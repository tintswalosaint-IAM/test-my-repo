/**
* @description Conversations API response
*
* @testclass CMN_CTRL_Conversation_Test
*
* @author Gnitsevich Anton
*
* @date October 2021
*
* 2024-02-26    Derek Hughes    Added customerNumber to support new AR data structure 
*/
@SuppressWarnings('PMD') 
// DTO's violate many PMD rules such as public count and attribute naming conventions.
@JsonAccess(deserializable='always')
public with sharing class CMN_DTO_ConversationsResponse {
    @AuraEnabled public Integer totalSize { get; set; }
    @AuraEnabled public List<Conversation> clientPortfolioConversationList { get; set; }

    /**
    * @description Single Conversation
    */
    @JsonAccess(deserializable='always')
    public class Conversation {
        @AuraEnabled public Long newCustN { get; set; }
        @AuraEnabled public Long customerNumber { get; set; }
        @AuraEnabled public String clientType { get; set; }
        @AuraEnabled public String clientName { get; set; }
        @AuraEnabled public String identification { get; set; }
        @AuraEnabled public String identifier { get; set; }
        @AuraEnabled public String tier { get; set; }
        @AuraEnabled public String aeNumber { get; set; }

        @AuraEnabled public String conversationId { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public Integer catPosition { get; set; }
        @AuraEnabled public String subCategory { get; set; }
        @AuraEnabled public Integer subCatPosition { get; set; }
        @AuraEnabled public String detail { get; set; }
        @AuraEnabled public String actionScript { get; set; }
        @AuraEnabled public String contactType { get; set; }
        @AuraEnabled public String response { get; set; }
        @AuraEnabled public String reason { get; set; }
        @AuraEnabled public String additionalInformation { get; set; }
        @AuraEnabled public Decimal expectedRevenue { get; set; }
        @AuraEnabled public String futureContactDate { get; set; }
        @AuraEnabled public String leadKey { get; set { leadKey = value.trim(); } }
    }
}