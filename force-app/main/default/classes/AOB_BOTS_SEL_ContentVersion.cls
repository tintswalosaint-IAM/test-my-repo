/**
 * @description       : Selector Class for ContentVersion Entity
 * @author            : VenkataRamadevi Ravuri
 * @last modified on  : April 4th 2023
 * @last modified by  : VenkataRamadevi Ravuri
**/
public inherited sharing class AOB_BOTS_SEL_ContentVersion extends sbgplatform.fflib_SObjectSelector{
    private static Set<String> fields = new Set<String>{
        'Id',
        'Title',
        'ContentDocumentId'
    };
        
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
            ContentVersion.Title
        };
    }

    /**
     * Select without conditions
     * @author Narendra Teja | 08/04/2023
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
    * @param List<Id> applicationIds 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectApplicationById(Id ContentDocumentId) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('ContentDocumentId=:ContentDocumentId');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param List<Id> applicationIds 
    * @return List<ContentVersion> 
    **/
    public ContentVersion selectContentVersionById(Id contentVersionId) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('Id=:contentVersionId');
    	fieldQueryFactory.selectFields(fields);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
    * @description Method to fetch list of Applications based on Application Id
    * @author VenkataRamadevi Ravuri | April 4th 2023 
    * @param List<Id> applicationIds 
    * @return List<ContentVersion> 
    **/
    public List<ContentVersion> selectContentVersionByIds(List<Id> contentDocList) {
    	sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    	fieldQueryFactory.setCondition('ContentDocumentId IN:contentDocList');
    	fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING, true);
    	return Database.query(fieldQueryFactory.toSOQL());
    }
   
}