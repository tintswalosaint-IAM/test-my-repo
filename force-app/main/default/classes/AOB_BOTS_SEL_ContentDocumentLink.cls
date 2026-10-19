/**
 * @description       : Selector Class for ContentDocumentLink Entity
 * @author            : Mamidala Rahul
 * @last modified on  : 09-04-2023
 * @last modified by  : Mamidala Rahul
**/
public inherited sharing class AOB_BOTS_SEL_ContentDocumentLink extends sbgplatform.fflib_SObjectSelector{
     private static Set<String> fields = new Set<String>{'Id', 
        'ContentDocumentId',
        'LinkedEntityId'
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
    * @description Method to fetch list of contentDocumentLinks based on LinkedEntityId
    * 
    * @param List<Id> LinkedEntityIds 
    * @return List<ContentDocumentLink> 
    **/
    public List<ContentDocumentLink> getDocumentLinkByLinkedEntity(List<Id> LinkedEntityIds) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('LinkedEntityId in :LinkedEntityIds');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    

}