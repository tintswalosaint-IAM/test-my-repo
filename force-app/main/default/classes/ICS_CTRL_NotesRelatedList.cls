public class ICS_CTRL_NotesRelatedList {
	 @AuraEnabled(cacheable=true)
    public static list<object> getNoteRecords(String parentId) {
        try {
            // Query ContentDocumentLink to get all notes linked to the parent record
            List<ContentDocumentLink> contentLinks = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :parentId 
                AND ContentDocument.FileType = 'SNOTE'
            ];
            
            Set<Id> contentDocumentIds = new Set<Id>();
            for(ContentDocumentLink cdl : contentLinks) {
                contentDocumentIds.add(cdl.ContentDocumentId);
            }
            
            list<object> returnedList=new list<object>();
          list<ContentNote> contentNoteList=[
                SELECT Id, Title, Content, CreatedDate, LastModifiedDate, CreatedBy.Name, LastModifiedBy.Name
                FROM ContentNote
                WHERE Id IN :contentDocumentIds
                ORDER BY LastModifiedDate DESC
            ];
            for(ContentNote note:contentNoteList){
              map<string,string> noteMap=new Map<string,string>();  
                noteMap.put('LastModifiedDate',note.LastModifiedDate.format());
                 noteMap.put('Title',note.Title);
                 noteMap.put('Content',note.Content.toString());
                returnedList.add(noteMap);
            }
           return returnedList;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving notes: ' + e.getMessage());
        }
    }
}