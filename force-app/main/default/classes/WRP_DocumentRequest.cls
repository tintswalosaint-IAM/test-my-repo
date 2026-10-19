/**
 * @description       : WRP_DocumentRequest Wrapper class to set object
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-14-2024
 * @last modified by  : Dhiraj Prajapati (CloudSmiths)
**/
public with sharing class WRP_DocumentRequest {

    public WRP_DocumentRequest() {}

    @AuraEnabled
    public String name;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String recordId;
    @AuraEnabled
    public boolean required;
    @AuraEnabled
    public boolean disabled;
    @AuraEnabled
    public boolean multiple;
    @AuraEnabled
    public list<String> formats;
    @AuraEnabled
    public list<DocumentRequest> docList;

    public class DocumentRequest {
        @AuraEnabled
        public String actualFile;
        @AuraEnabled
        public String relatedRecordId;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String documentType;
    }
}