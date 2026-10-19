/**
 * @description Finscan API response
 * @author Gnitsevich Anton
 * @date August 2022
 */
public with sharing class ICS_DTO_FinscanResponse {

    /**
     * @description Represents a MultiLookup response, containing a status code and a list of lookup responses
     */
    public class MultiLookup {
        /**
     * @description The Integer responseStatusCode of the response.
     */
        @AuraEnabled public Integer responseStatusCode { get; set; }
        /**
     * @description A list of lookup responses.
     */
        @AuraEnabled public List<Lookup> responses { get; set; }
    }
    
    /**
     * @description Lookup
     */
    public class Lookup {
         /**
         * @description The status code of the Lookup response.
         */
        @AuraEnabled public Integer status { get; set; }
        /**
         * @description The message associated with the Lookup response.
         */
        @AuraEnabled public String message { get; set; }
        /**
         * @description A list of search results for the Lookup.
         */
        @AuraEnabled public List<SearchResult> searchResults { get; set; }
    }
    
    /**
     * @description Represents a search result in a Lookup.
     */
    public class SearchResult {
        /**
         * @description A list of matches found in the search result.
         */
        @AuraEnabled
        public List<SearchMatch> searchMatches { get; set; }
    }
    /**
     * @description Search Matches
     */
    public class SearchMatch {
        /**
         * @description The name of the list where the match was found.
         */
        @AuraEnabled public String listName { get; set; }
        /**
         * @description The key associated with the list profile.
         */
        @AuraEnabled public Decimal listProfileKey { get; set; }
        /**
         * @description The display line for the search match.
         */
        @AuraEnabled public String displayLine { get; set; }
         /**
         * @description The categories associated with the Financial Sanctions (FNS) for the match.
         */
        @AuraEnabled public String fnsCategories { get; set; }
		/**
         * @description The rank score for the match.
         */        
        @AuraEnabled public Decimal rankScore { get; set; }
         /**
         * @description The rank score for the match.
         */
        @AuraEnabled public String rankValue { get; set; }
         /**
         * @description The rank value for the match.
         */
        @AuraEnabled public DynamicFields dynamicFields { get; set; }
        /**
         * @description The container for the record details of the list.
         */
        @AuraEnabled public RecordDetailsContainer listRecordDetail { get; set; }
    }
    
   	/**
    * @description Represents dynamic fields associated with a search match.
    */
    public class DynamicFields {
        /**
         * @description The gender listed in the dynamic fields.
         */
        @AuraEnabled
        public String listGender { get; set; }
    
        /**
         * @description The aliases listed in the dynamic fields.
         */
        @AuraEnabled
        public String listAliases { get; set; }
    
        /**
         * @description The Politically Exposed Person (PEP) category listed in the dynamic fields.
         */
        @AuraEnabled
        public String listPEPCategory { get; set; }
    
        /**
         * @description The dates of birth listed in the dynamic fields.
         */
        @AuraEnabled
        public String listDOBs { get; set; }
    
        /**
         * @description The countries listed in the dynamic fields.
         */
        @AuraEnabled
        public String listCountries { get; set; }
    
        /**
         * @description The citizenships listed in the dynamic fields.
         */
        @AuraEnabled
        public String listCitizenships { get; set; }
    }
    
    /**
     * @description Container for record details associated with a search match.
     */
    public class RecordDetailsContainer {
        /**
         * @description The record details associated with the list.
         */
        @AuraEnabled
        public RecordDetails listRecord { get; set; }
    }

    /**
     * @description Represents the record details associated with a search match.
     */
    public class RecordDetails {
        /**
         * @description The World Check information associated with the record detail.
         */
        @AuraEnabled
        public WorldCheck worldCheck { get; set; }
    
        /**
         * @description The Innovative information associated with the record detail.
         */
        @AuraEnabled
        public Innovative innovative { get; set; }
    }

    /* Worldcheck */ 
    /**
     * @description Represents World Check information associated with a record detail.
     */
    public class WorldCheck {
        /**
         * @description The category of the World Check record.
         */
        @AuraEnabled
        public String category { get; set; }
    
        /**
         * @description The description of the category of the World Check record.
         */
        @AuraEnabled
        public String categoryDescription { get; set; }
    
        /**
         * @description The subcategory of the World Check record.
         */
        @AuraEnabled
        public String subcategory { get; set; }
    
        /**
         * @description The description of the subcategory of the World Check record.
         */
        @AuraEnabled
        public String subcategoryDescription { get; set; }
    
        /**
         * @description The person associated with the World Check record.
         */
        @AuraEnabled
        public WorldCheckPerson person { get; set; }
    
        /**
         * @description The details of the World Check record.
         */
        @AuraEnabled
        public WorldCheckDetails details { get; set; }
    }

    
    /**
     * @description Represents a person associated with a World Check record.
     */
    public class WorldCheckPerson {
        /**
         * @description The position or role of the person in the context of the World Check record.
         */
        @AuraEnabled
        public String position { get; set; }
    }
    
    /**
     * @description Represents detailed information associated with a World Check record.
     */
    public class WorldCheckDetails {
        /**
         * @description Additional information about the World Check record
         * This property name matches the API response field and is an exception to Apex naming conventions.
         */
        @AuraEnabled
        public String further_information { get; set; }
    
        /**
         * @description The place of birth associated with the World Check record
         * This property name matches the API response field and is an exception to Apex naming conventions.
         */
        @AuraEnabled
        public String place_of_birth { get; set; }
    
        /**
         * @description The locations associated with the World Check record.
         */
        @AuraEnabled
        public Locations locations { get; set; }
    
        /**
         * @description The companies associated with the World Check record.
         */
        @AuraEnabled
        public List<Company> companies { get; set; }
    
        /**
         * @description The entities linked to the World Check record.
         This property name matches the API response field and is an exception to Apex naming conventions.
		*/
        @AuraEnabled
        public LinkedEntities linked_to { get; set; }
    
        /**
         * @description The keywords associated with the World Check record.
         */
        @AuraEnabled
        public Keywords keywords { get; set; }
    
        /**
         * @description The external sources associated with the World Check record
         * This property name matches the API response field and is an exception to Apex naming conventions.
		*/
        @AuraEnabled
        public ExternalSources external_sources { get; set; }
        
    }
   
    /**
     * @description Represents locations associated with a World Check record.
     */
    public class Locations {
        /**
         * @description A list of locations associated with the World Check record.
         */
        @AuraEnabled
        public List<Location> location { get; set; }
    }

    /**
     * @description Represents a single location associated with a World Check record.
     */
    public class Location {
        /**
         * @description The city of the location.
         */
        @AuraEnabled
        public String city { get; set; }
    
        /**
         * @description The state of the location.
         */
        @AuraEnabled
        public String state { get; set; }
    
        /**
         * @description The country of the location.
         */
        @AuraEnabled
        public String country { get; set; }
    
        /**
         * @description The detailed location information.
         */
        @AuraEnabled
        public String location { get; set; }
    }    
    /**
     * @description Represents a company associated with a World Check record.
     */
    public class Company {
        /**
         * @description The key associated with the company's profile in the list.
         */
        @AuraEnabled
        public Decimal listProfileKey { get; set; }
    
        /**
         * @description The name of the company.
         */
        @AuraEnabled
        public String company { get; set; }
    
        /**
         * @description The official name of the company.
         */
        @AuraEnabled
        public String companyName { get; set; }
    
        /**
         * @description The category of the company.
         */
        @AuraEnabled
        public String category { get; set; }
    }
    /**
     * @description Represents keywords associated with a World Check record.
     */
    public class Keywords {
        /**
         * @description A list of descriptions for the keywords associated with the World Check record.
         */
        @AuraEnabled
        public List<String> keywordDescription { get; set; }
    }

   /**
     * @description Represents entities linked to a World Check record.
     */
    public class LinkedEntities {
        /**
         * @description The list profile keys associated with the linked entities.
         */
        @AuraEnabled
        public List<Decimal> listProfileKey { get; set; }
    
        /**
         * @description The unique identifiers of the linked entities.
         */
        @AuraEnabled
        public List<String> uid { get; set; }
    
        /**
         * @description The names of the linked entities.
         */
        @AuraEnabled
        public List<String> name { get; set; }
    
        /**
         * @description The Politically Exposed Person (PEP) status of the linked entities.
         */
        @AuraEnabled
        public List<String> pep { get; set; }
    
        /**
         * @description The descriptions of the PEP status of the linked entities.
         */
        @AuraEnabled
        public List<String> pepDescription { get; set; }
    
        /**
         * @description The categories of the linked entities.
         */
        @AuraEnabled
        public List<String> category { get; set; }
    
        /**
         * @description The list categories associated with the linked entities.
         */
        @AuraEnabled
        public List<String> listCategory { get; set; }
    }  
    /**
     * @description Represents external sources associated with a World Check record.
     */
    public class ExternalSources {
        /**
         * @description A list of URIs for the external sources associated with the World Check record.
         */
        @AuraEnabled
        public List<String> uri { get; set; }
    }
    /**
     * @description Search Matches - Innovative
     */
    public class Innovative {
    }

    /* Update Responses */
    
    /**
     * @description Represents the update status of pairs in a response.
     */
    public class PairsUpdate {
        /**
         * @description The status code of the pairs update response.
         */
        @AuraEnabled
        public Integer responseStatusCode { get; set; }
    
        /**
         * @description The status of the pairs update.
         */
        @AuraEnabled
        public Integer status { get; set; }
    } 
    /**
     * @description Represents the update status of a client in a response.
     */
    public class ClientUpdate {
        /**
         * @description The status code of the client update response.
         */
        @AuraEnabled
        public Integer responseStatusCode { get; set; }
    
        /**
         * @description The status of the client update
         */
        @AuraEnabled
        public Integer status { get; set; }
    
        /**
         * @description The message associated with the client update response.
         */
        @AuraEnabled
        public String message { get; set; }
    }
}