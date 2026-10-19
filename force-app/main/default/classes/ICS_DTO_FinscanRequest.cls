/**
 * @description Finscan request
 * @author Gnitsevich Anton
 * @date August 2022
 */
public with sharing class ICS_DTO_FinscanRequest{
    
    /**
     * @description Represents the lookup details for a Finscan request.
     */
    public class Lookup {
        /**
         * @description The name of the organization associated with the Finscan request.
         */
        @AuraEnabled public String organizationName { get; set; }
    
        /**
         * @description The username used for authentication with the Finscan service.
         */
        @AuraEnabled public String userName { get; set; }
    
        /**
         * @description The password used for authentication with the Finscan service.
         */
        @AuraEnabled public String password { get; set; }
    
        /**
         * @description The application ID associated with the Finscan request.
         */
        @AuraEnabled public String applicationId { get; set; }
    
        /**
         * @description The client search code used to specify the type of search in the Finscan request.
         */
        @AuraEnabled public Integer clientSearchCode { get; set; }
    
        /**
         * @description The client ID associated with the Finscan request, used for identifying the client in the system.
         */
        @AuraEnabled public String clientId { get; set; }
    
        /**
         * @description The name line used in the Finscan search, typically including the full name of the individual or entity being searched.
         */
        @AuraEnabled public String nameLine { get; set; }
    
        /**
         * @description The gender of the individual being searched, used as a parameter in the Finscan request.
         */
        @AuraEnabled public String gender { get; set; }
    
        /**
         * @description The label for the first user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField1Label { get; set; }
    
        /**
         * @description The value for the first user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField1Value { get; set; }
    
        /**
         * @description The label for the second user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField2Label { get; set; }
    
        /**
         * @description The value for the second user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField2Value { get; set; }
    
        /**
         * @description The label for the ninth user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField9Label { get; set; }
    
        /**
         * @description The value for the ninth user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField9Value { get; set; }
    
        /**
         * @description The label for the tenth user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField10Label { get; set; }
    
        /**
         * @description The value for the tenth user-defined field in the Finscan request.
         */
        @AuraEnabled public String userField10Value { get; set; }
    
        /**
         * @description The options for the Finscan request, specifying various parameters and settings for the search.
         */
        @AuraEnabled public Options options { get; set; }
    
        /**
         * @description A list of country codes for the user-defined fields in the Finscan request.
         */
        @AuraEnabled public List<Integer> userFieldsCountry { get; set; }
    }
    /**
     * @description Represents the options for a Finscan request.
     */
    public class Options {
        /**
         * @description Indicates whether to add a new client to the Finscan system.
         */
        @AuraEnabled public Integer addClient { get; set; }
    
        /**
         * @description Indicates whether to generate a new client ID for the Finscan request.
         */
        @AuraEnabled public Integer generateClientId { get; set; }
    
        /**
         * @description Indicates whether to update user fields in the Finscan system.
         */
        @AuraEnabled public Integer updateUserFields { get; set; }
    
        /**
         * @description Indicates whether to send the Finscan request for review.
         */
        @AuraEnabled public Integer sendToReview { get; set; }
    
        /**
         * @description Indicates whether to return the category information in the Finscan response.
         */
        @AuraEnabled public Integer returnCategory { get; set; }
    
        /**
         * @description Indicates whether to return search compliance records in the Finscan response.
         */
        @AuraEnabled public Integer returnSearchComplianceRecords { get; set; }
    
        /**
         * @description Indicates whether to return compliance records in the Finscan response.
         */
        @AuraEnabled public Integer returnComplianceRecords { get; set; }
    
        /**
         * @description Indicates whether to return source lists in the Finscan response.
         */
        @AuraEnabled public Integer returnSourceLists { get; set; }
    
        /**
         * @description Indicates whether to return search details in the Finscan response.
         */
        @AuraEnabled public Integer returnSearchDetails { get; set; }
    
        /**
         * @description Indicates whether to skip the search process in the Finscan request.
         */
        @AuraEnabled public Integer skipSearch { get; set; }
    
        /**
         * @description Indicates whether to skip updating the client information in the Finscan request.
         */
        @AuraEnabled public Integer skipClientUpdate { get; set; }
    
        /**
         * @description Indicates whether to process Ultimate Beneficial Owners (UBO) in the Finscan request.
         */
        @AuraEnabled public Integer processUBO { get; set; }
    
        /**
         * @description Indicates whether to search for UBO members in the Finscan request.
         */
        @AuraEnabled public Integer searchUBOMembers { get; set; }
    }  
   /**
     * @description Represents the details for updating pairs in a Finscan request.
     */
    public class PairsUpdate {
        /**
         * @description The name of the organization associated with the pairs update request.
         */
        @AuraEnabled public String organizationName { get; set; }
    
        /**
         * @description The username used for authentication with the Finscan service for the pairs update request.
         */
        @AuraEnabled public String userName { get; set; }
    
        /**
         * @description The password used for authentication with the Finscan service for the pairs update request.
         */
        @AuraEnabled public String password { get; set; }
    
        /**
         * @description The client ID associated with the pairs update request, used for identifying the client in the system.
         */
        @AuraEnabled public String clientId { get; set; }
    
        /**
         * @description The list of application IDs associated with the pairs update request.
         */
        @AuraEnabled public List<String> applicationId { get; set; }
    
        /**
         * @description The list of pairs to be updated in the Finscan request.
         */
        @AuraEnabled public List<Pair> pairs { get; set; }
    } 
    /**
     * @description Represents a pair in the context of a Finscan pairs update request.
     */
    public class Pair {
        /**
         * @description The key associated with the list profile for the pair.
         */
        @AuraEnabled public Decimal listProfileKey { get; set; }
    
        /**
         * @description The status of the pair, indicating its current state in the Finscan system.
         */
        @AuraEnabled public String pairStatus { get; set; }
    
        /**
         * @description The reason for the current status of the pair, providing additional context.
         */
        @AuraEnabled public String pairReason { get; set; }
    
        /**
         * @description Comments associated with the pair, providing further details or explanations.
         */
        @AuraEnabled public String pairComments { get; set; }
    }
  
    /**
     * @description Represents the details for updating a client in a Finscan request.
     */
    public class ClientUpdate {
        /**
         * @description The name of the organization associated with the client update request.
         */
        @AuraEnabled public String organizationName { get; set; }
    
        /**
         * @description The username used for authentication with the Finscan service for the client update request.
         */
        @AuraEnabled public String userName { get; set; }
    
        /**
         * @description The password used for authentication with the Finscan service for the client update request.
         */
        @AuraEnabled public String password { get; set; }
    
        /**
         * @description The current application ID associated with the client in the Finscan system.
         */
        @AuraEnabled public String applicationId { get; set; }
    
        /**
         * @description The new application ID to be associated with the client in the Finscan system.
         */
        @AuraEnabled public String newApplicationId { get; set; }
    
        /**
         * @description The current client ID associated with the client in the Finscan system.
         */
        @AuraEnabled public String clientId { get; set; }
    
        /**
         * @description The new client ID to be associated with the client in the Finscan system.
         */
        @AuraEnabled public String newClientId { get; set; }
    
        /**
         * @description The status of the client update request.
         */
        @AuraEnabled public Integer clientStatus { get; set; }
    
        /**
         * @description The name line used in the Finscan search, typically including the full name of the individual or entity being updated.
         */
        @AuraEnabled public String nameLine { get; set; }
    }
}