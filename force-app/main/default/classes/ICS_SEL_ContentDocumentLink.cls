/**
*@description Selector class for ContentDocumentLink object.
*This class provides methods to retrieve ContentDocumentLink records.
* @author Ofentse Sacha
* @date May 2023
*/
public with sharing class ICS_SEL_ContentDocumentLink extends sbgplatform.fflib_SObjectSelector {

	/**
     * @description Retrieves the SObjectType for ContentDocumentLink.
     * @return The SObjectType for ContentDocumentLink
     */
    public override Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.SObjectType;
    }
	/**
     * @description Retrieves the list of SObjectFields for ContentDocumentLink.
     * @return The list of SObjectFields for ContentDocumentLink
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return ContentDocumentLink.SObjectType.getDescribe().fields.getMap().values();
    }

    /**
     * @description Retrieves a list of ContentDocumentLink objects associated with a given Application ID.
     * @param recordId record ID 
     * @return List of ContentDocumentLink objects associated with the reord
     */
    public List<ContentDocumentLink> getContentDocumentLinks(Id recordId) {
        return (List<ContentDocumentLink>) Database.query(newQueryFactory().setCondition('LinkedEntityId = :recordId').toSOQL());
    }

    /**
     * @description Retrieves a list of ContentDocumentLink objects associated with a given Application ID.
     * @param recordIds Set of record IDs 
     * @return List of ContentDocumentLink objects associated with the records
     */
    public List<ContentDocumentLink> selectContentDocumentLinks( Set<Id> recordIds) {
        return (List<ContentDocumentLink>) Database.query(newQueryFactory().setCondition('LinkedEntityId = :recordIds').toSOQL());
    }


}