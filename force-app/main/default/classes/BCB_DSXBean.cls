/**
* @description BeanClass for dealing with DSX api and sending the result to the main container and storing the values in the wrapper
* @author Jagadish
* @date june 2022
*/
public without sharing class BCB_DSXBean {

    /** @description attribute **/
    public String agent{get;set;}
    /** @description attribute **/
    public String country{get;set;}
    /** @description attribute **/
    public String cif{get;set;}
    /** @description attribute **/
    public List<documents> documents{get;set;}
    /** @description Documents is using for DSX API request body **/
    public class Documents{
        /** @description attribute **/
        public String documentType{get;set;}
        /** @description attribute **/
        public String name{get;set;}
        /** @description attribute **/
        public String content{get;set;} 
         /** @description attribute **/
         public String documentExpiryDate{get;set;} 
    }
    /** @description Documents is using for DSX API request body **/
    public class Response {
        /** @description attribute **/
        public List<ResponseDocuments> documents{get;set;}
    }

    /** @description ResponseDocuments is using for DSX API request body **/
    public class ResponseDocuments {
        /** @description attribute **/
        public String reasonCode{get;set;}
        /** @description attribute **/
        public String status{get;set;}
        /** @description attribute **/
        public String reasonDescription{get;set;} 
    }
}