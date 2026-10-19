/**
*  @description BeanClass for dealing with sanction api and sending the result to the main container and storing the values in the wrapper
*
*
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date june 2022
*/
public with sharing class AOB_SanctionScreenBean {
    /** @description name */
    public String name{get;set;}
    /** @description groupId */
    public String groupId{get;set;}
    /** @description name of transposition */
    public Boolean nameTransposition{get;set;}
    /** @description entity type */
    public String entityType{get;set;}
    /** @description providerTypes list from main class */
    public list<String> providerTypes{get;set;}
    /** @description customFieldsl ist from main class */
    public list<String> customFields{get;set;}
    /** @description secondaryFields list from main class */
    public list<String> secondaryFields{get;set;}
    /** @description caseId */
    public String caseId{get;set;}
    /**
    *  @description Class for dealing with sanction api 
    */
    public class Response {
        /** @description name */
        public String name;
        /** @description results */
        public List<Results> results;
    }
    /**
    *  @description Class for dealing with sanction api 
    */
    public class Error {
        /** @description error */
        public String error;
        /** @description cause */
        public String cause;
    }
    /**
    *  @description Class for dealing with sanction api 
    */
    public class Results {
        /** @description mathStrength  */
        public String matchStrength;
        /** @description matchScore */
        public Decimal matchScore;
        /** @description category  */
        public String category;
        /** @description pepStatus of user */
        public String pepStatus;
        /** @description submittedTerm  */
        public String submittedTerm;
        /** @description categories  */
        public Set<String> categories;
    }

}