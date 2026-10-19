/**
* @description       : Selector Class for Content Version Entity
* @author            : NAGENDRAPRASAD MYLAVARAPU
* @last modified on  : 10-11-2024
* @last modified by  : Jaco de Lange
**/
public with sharing class SEL_CMN_ContentVersion extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{
        'Id',
        'Title',
        'ContentDocumentId',
        'VersionData'
    };

    /**
    * @description Implementation method for Content Version Object as part of fflib framework
    * @return Schema.SObjectType
    **/
    public override Schema.SObjectType getSObjectType() {
        return ContentVersion.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentVersion.Id,
            ContentVersion.IsAssetEnabled,
            ContentVersion.Description,
            ContentVersion.FileExtension,
            ContentVersion.SharingPrivacy,
            ContentVersion.FileType,
            ContentVersion.OwnerId,
            ContentVersion.LastModifiedById,
            ContentVersion.LastModifiedDate,
            ContentVersion.SharingOption,
            ContentVersion.ContentSize,
            ContentVersion.TagCsv,
            ContentVersion.Title,
            ContentVersion.ContentDocumentId,
            ContentVersion.VersionData,
            ContentVersion.ContentBodyId,
            ContentVersion.CreatedDate,
            ContentVersion.Document_Type_Id__c,
            ContentVersion.DocumentType__c,
            ContentVersion.INS_Document_Link__c,
            ContentVersion.Filenet_Upload__c,
            ContentVersion.Linked_Entity_Identifier__c,
            ContentVersion.Document_Name__c
        };
    }

    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Nagendra Mylavarapu | January 29th 2024
    * @param contentVersionIds Id
    * @return List<ContentVersion>
    **/
    public List<ContentVersion> selectCVByIds(List<Id> contentVersionIds) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Id=:contentVersionIds');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Nagendra Mylavarapu | January 29th 2024
    * @param contentVersionIds Id
    * @return List<ContentVersion>
    **/
    public List<ContentVersion> getContentVersions(Set<Id> documents) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
    	fieldQueryFactory.setCondition('ContentDocumentId IN :documents');
    	fieldQueryFactory.selectFields(this.getSObjectFieldList());
    	return Database.query(fieldQueryFactory.toSOQL());
    }
}