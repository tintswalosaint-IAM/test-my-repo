/**
*@description Selector class for ContentNote object.
*This class provides methods to retrieve ContentNote records.
* @author Ofentse Sacha
* @date May 2023
*/
public with sharing class ICS_SEL_ContentNote extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description Constructs an instance of the ICS_SEL_ContentNote class.
     */
    public ICS_SEL_ContentNote() {
        super();
    }
	/**
     * @description Retrieves the SObjectType for ContentNote.
     * @return The SObjectType for ContentNote
     */
    public override Schema.SObjectType getSObjectType() {
        return ContentNote.SObjectType;
    }
	/**
     * @description Retrieves the list of SObjectFields for ContentNote.
     * @return The list of SObjectFields for ContentNote
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return ContentNote.SObjectType.getDescribe().fields.getMap().values();
    }

    /**
     * @description Retrieves a list of ContentNote objects associated with a given list of ContentDocumentLink objects.
     * @param contentDocumentList The list of ContentDocumentLink objects
     * @return List of ContentNote objects associated with the ContentDocumentLink objects
     */
    public List<ContentNote> getContentNotes(List<ContentDocumentLink> contentDocumentList) {
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink cdl : contentDocumentList) {
            contentDocIds.add(cdl.ContentDocumentId);
        }
    
        if (contentDocIds.isEmpty()) {
            return new List<ContentNote>();
        }
    
        return (List<ContentNote>) Database.query(newQueryFactory().setCondition('Id IN :contentDocIds').toSOQL());
}

}