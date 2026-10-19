/**
 * @description       : Selector Class for ContentDocumentLink Entity
 * @author            : Mamidala Rahul
 * @last modified on  : 07-29-2026
**/
@SuppressWarnings('PMD.SOQLInjection') 
public inherited sharing class SEL_ContentDocumentLink extends sbgplatform.fflib_SObjectSelector{

    private static Set<String> fields = new Set<String>{
        'Id', 
       'ContentDocumentId',
       'LinkedEntityId',
       'LinkedEntity.Name',
       'ContentDocument.LatestPublishedVersion.Title',
       'ContentDocument.LatestPublishedVersion.DocumentType__c',
       'ContentDocument.LatestPublishedVersion.DocumentDate__c',
       'ContentDocument.LatestPublishedVersion.Description'
   };

   /**
   * @description Implementation method for Lead Object as part of fflib framweork
   * 
   * @return Schema.SObjectType 
   **/
   public override Schema.SObjectType getSObjectType() {
       return ContentDocumentLink.sObjectType;
   }

    /**
   * @description Method to get list of fields to be part of response
   * 
   * @return List<Schema.SObjectField> 
   **/
   public override List<Schema.SObjectField> getSObjectFieldList() {
       return new List<Schema.SObjectField> {
           ContentDocumentLink.Id, 
           ContentDocumentLink.LinkedEntityId
       };
   }

    /**
     * @description Method to fetch list of contentDocumentLinks based on linkedEntityId
     * 
     * @param linkedEntityIds 
     * @return List<ContentDocumentLink> 
     **/
    public List<ContentDocumentLink> selectByLinkedEntity(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('LinkedEntityId in :ids');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

   /**
   * @description Method to fetch list of contentDocumentLinks based on linkedEntityId
   * 
   * @param linkedEntityIds 
   * @return List<ContentDocumentLink> 
   **/
   public List<ContentDocumentLink> getDocumentLinkByLinkedEntity(List<Id> linkedEntityIds) {
       sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
       fieldQueryFactory.setCondition('LinkedEntityId in :linkedEntityIds');
       fieldQueryFactory.selectFields(fields);
       return Database.query(fieldQueryFactory.toSOQL());
   } 

    /**
   * @description Method to fetch list of contentDocumentLinks based on linkedEntityId
   * 
   * @param linkedEntityId 
   * @return List<ContentDocumentLink> 
   **/
    public List<ContentDocumentLink> getDocumentLinkByLinkedEntityId(Id linkedEntityId) {
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('LinkedEntityId =:linkedEntityId');
    fieldQueryFactory.selectFields(fields);
    return Database.query(fieldQueryFactory.toSOQL());
}

    /**
    * @description Method to fetch list of contentDocumentLinks based on linkedEntityId and limit
    * 
    * @param linkedEntityId 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> getDocumentLinkByLinkedEntityIdWithLimit(Id linkedEntityId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('LinkedEntityId =:linkedEntityId');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);     
        return Database.query(fieldQueryFactory.toSOQL());
    }

        /**
    * @description Method to fetch list of contentDocumentLinks based on linkedEntityId and limit
    * 
    * @param linkedEntityId 
    * @return List<ContentDocumentLink> 
    **/
    public ContentDocumentLink getDocumentLinkByLinkedEntityIdWithLimitOne(Id linkedEntityId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('LinkedEntityId =:linkedEntityId');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(1);     
        return Database.query(fieldQueryFactory.toSOQL());
    }

}