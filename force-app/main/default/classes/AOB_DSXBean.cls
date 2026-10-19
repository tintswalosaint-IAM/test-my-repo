/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_DSXBean
@ Description       :Beab Class for dealing with DSX api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-27814
***************************************************************************************/
public without sharing class AOB_DSXBean {
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