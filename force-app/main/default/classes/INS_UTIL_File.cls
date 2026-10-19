/**
 * @description: Wrapper class to hold Content Version, Custom Metadata Document Type
 * and Content Document info
 *
 * @author: Dhiraj Prajapti
 *
  _____   ____    _   _  ____ _______   ______ _____ _____ _______
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|

 THIS CODE IS CONTROLLED BY THE INSURANCE TEAM
 For any changes requied please contact the Insurance team.
**/
public inherited sharing class INS_UTIL_File {

    @AuraEnabled
    public Id id {get;set;}

    @AuraEnabled
    public Id documentTypeId {get;set;}

    @AuraEnabled
    public String documentType {get;set;}

    @AuraEnabled
    public String documentId {get;set;}

    @AuraEnabled
    public String name {get;set;}

    @AuraEnabled
    public String title {get;set;}

    @AuraEnabled
    public String mimeType {get;set;}

    @AuraEnabled
    public String contentBodyId {get;set;}

    @AuraEnabled
    public String contentVersionId {get;set;}

    @AuraEnabled
    public Date createdDate {get;set;}

    @AuraEnabled
    public String uploadIconName {get;set;}

    @AuraEnabled
    public Boolean isUploaded {get;set;}

    @AuraEnabled
    public Id recordId {get;set;}

    /**constructor*/
    public INS_UTIL_File(){}

    public INS_UTIL_File(ContentVersion contentVersion) {
        this.setFile(contentVersion);
    }

    public INS_UTIL_File setFile(ContentVersion contentVersion) {
        this.id = contentVersion.Id;
        this.contentVersionId = contentVersion.Id;
        this.name = contentVersion.Title;
        this.documentId = contentVersion?.ContentDocumentId;
        this.contentBodyId = contentVersion.ContentBodyId;
        this.title = contentVersion?.Title;
        this.mimeType = contentVersion?.FileExtension;
        this.createdDate = Date.valueOf(contentVersion?.CreatedDate);
        this.uploadIconName = 'utility:' + (String.isNotBlank(contentVersion?.INS_Document_Link__c) ? 'fully_synced' : 'not_saved');
        this.isUploaded = String.isNotBlank(contentVersion?.INS_Document_Link__c);
        this.documentTypeId = contentVersion?.Document_Type_Id__c;
        return this;
    }

    public String getContentVersionId() {
        return this.contentVersionId;
    }

    public String getTitle() {
        return this.title;
    }

    public Id getDocumentTypeId() {
        return this.documentTypeId;
    }

    public INS_UTIL_File setDocumentName(String name) {
        this.documentType = name;
        return this;
    }

    public INS_UTIL_File setRecordId(Id recordId) {
        this.recordId = recordId;
        return this;
    }

    public Id getRecordId() {
        return this.recordId;
    }

}