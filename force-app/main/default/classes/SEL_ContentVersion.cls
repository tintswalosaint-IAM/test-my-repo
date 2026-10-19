/**
 * @description       : Selector Class for ContentVersion Entity
 * @author            : VenkataRamadevi Ravuri
 * @last modified on  : 07-29-2026
 * @last modified by  : jagadish Thummala
**/
@SuppressWarnings('PMD.SOQLInjection') 
public inherited sharing class SEL_ContentVersion extends sbgplatform.fflib_SObjectSelector{

        
    /**
    * @description Implementation method for Lead Object as part of fflib framweork
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @return Schema.SObjectType 
    **/
    public override Schema.SObjectType getSObjectType() {
      return ContentVersion.sObjectType;
    }
    
    /**
    * @description Method to get list of fields to be part of response
    * @author VenkataRamadevi Ravuri | April 4th 2023 
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
            ContentVersion.RecordTypeId,
            ContentVersion.DocumentType__c,
            ContentVersion.DocumentDate__c,
            ContentVersion.Title,
            ContentVersion.IsLatest
  
        };
    }

    /**
     * @description Select without conditions
     * @author Narendra Teja | 08/04/2023
     * @param  List<ContentVersion>
     * @return List<ContentVersion>
     */
    public List<ContentVersion> selectWithoutCondition() {
        return (List<ContentVersion>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param contentDocumentId Id 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectApplicationById(Id contentDocumentId) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId=:contentDocumentId');
      fieldQueryFactory.selectFields(getSObjectFieldList());
      return Database.query(fieldQueryFactory.toSOQL());
    }

    public ContentVersion selectSingleContentById(Id contentDocumentId) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId=:contentDocumentId');
      fieldQueryFactory.selectFields(getSObjectFieldList());
      return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param contentVersionId Id 
    * @return List<ContentVersion> 
    **/
    public ContentVersion selectContentVersionById(Id contentVersionId) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('Id=:contentVersionId');
      fieldQueryFactory.selectFields(getSObjectFieldList());
      return Database.query(fieldQueryFactory.toSOQL());
    }
    
      /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param contentVersionList 
    * @return List<ContentVersion> 
    **/
    public list<ContentVersion> selectContentVersionByList( list<ContentVersion> contentVersionList) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('Id IN:contentVersionList');
      fieldQueryFactory.selectFields(getSObjectFieldList());
      return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Tushar Walse | July 29th 2024
    * @param ids 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectByIds(Set<Id> ids) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('Id IN :ids');
      fieldQueryFactory.selectFields(getSObjectFieldList());
      return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param contentDocList List<Id>
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectContentVersionByIds(List<Id> contentDocList) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId IN:contentDocList');
      fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
      return Database.query(fieldQueryFactory.toSOQL());
    }
      /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Lokesh Bothsa  | September 11th september 2023 
    * @param contentDocumentId 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectContentVersionByContentDocLatest(string contentDocumentId) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId =:contentDocumentId');
      fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
      return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Lokesh Bothsa  | September 11th september 2023 
    * @param contentDocumentIds 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectContentVersionByContentDocListLatest(set<id> contentDocumentIds) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId =:contentDocumentIds');
      fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
      return Database.query(fieldQueryFactory.toSOQL());
    }
     /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param contentDocumentId 
    * @param documentTitle 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectApplicationByIdandTitle(list<id> contentDocumentId,list<string> documentTitle) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId IN:contentDocumentId AND Title IN:documentTitle');
      fieldQueryFactory.selectFields(getSObjectFieldList());
      return Database.query(fieldQueryFactory.toSOQL());
    }

     /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Jagadish Thummala
    * @param contentDocumentId 
    * @param documentTitle 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectApplicationByIdandTitleAndlastModifiedDate(set<id> contentDocumentId,list<string> documentTitle) {
      sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
      fieldQueryFactory.setCondition('ContentDocumentId IN:contentDocumentId AND Title IN:documentTitle');
      fieldQueryFactory.selectFields( getSObjectFieldList());
        fieldQueryFactory.setOrdering('lastModifiedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING, true);
      return Database.query(fieldQueryFactory.toSOQL());
    }
   /**
    * @description Method to fetch list of Applications based on Application Id
    * @author Jagadish Thummala
    * @param contentDocList 
    * @param title 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectContentVersionByIds(List<Id> contentDocList, string title) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        String titleWithWildcards = '%' + title + '%';
        titleWithWildcards.trim();
        fieldQueryFactory.setCondition('ContentDocumentId IN :contentDocList AND Title LIKE :titleWithWildcards');
        fieldQueryFactory.selectFields( getSObjectFieldList());
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
        
    /**
    * @description Method to fetch list of ContentVersion based on linkedEntityId and limit
    * 
    * @param linkedEntityId 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> getDocumentLinkByLinkedEntityIdWithLimit(Id linkedEntityId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('ContentDocumentId =:linkedEntityId');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        fieldQueryFactory.setLimit(1);     
        return Database.query(fieldQueryFactory.toSOQL());
    }
  
}