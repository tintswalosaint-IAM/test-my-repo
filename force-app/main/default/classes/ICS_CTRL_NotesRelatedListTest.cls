@isTest
private class ICS_CTRL_NotesRelatedListTest {
    @TestSetup
    static void setupTestData() {
        // Create a test account as parent record
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test content notes
        List<ContentNote> notes = new List<ContentNote>();
        for(Integer i = 0; i < 3; i++) {
            ContentNote note = new ContentNote();
            note.Title = 'Test Note ' + i;
            note.Content = Blob.valueOf('Test Content ' + i);
            notes.add(note);
        }
        insert notes;
        
        // Create ContentDocumentLinks
        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for(ContentNote note : notes) {
            ContentDocumentLink link = new ContentDocumentLink();
            link.LinkedEntityId = testAccount.Id;
            link.ContentDocumentId = note.Id;
            link.ShareType = 'V';
            links.add(link);
        }
        insert links;
    }
    
    @isTest
    static void testGetNoteRecordsPositive() {
        // Get the test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Test.startTest();
        List<Object> results = ICS_CTRL_NotesRelatedList.getNoteRecords(testAccount.Id);
        Test.stopTest();
        
        // Verify results
        Assert.areEqual(3, results.size(), 'Should return 3 notes');
        
        // Verify content of returned maps
        for(Object obj : results) {
            Map<String, String> noteMap = (Map<String, String>)obj;
            Assert.isTrue(noteMap.containsKey('Title'), 'Map should contain Title');
            Assert.isTrue(noteMap.containsKey('Content'), 'Map should contain Content');
            Assert.isTrue(noteMap.containsKey('LastModifiedDate'), 'Map should contain LastModifiedDate');
        }
    }
    
    @isTest
    static void testGetNoteRecordsNoNotes() {
        // Create a new account without any notes
        Account newAccount = new Account(Name = 'Account Without Notes');
        insert newAccount;
        
        Test.startTest();
        List<Object> results = ICS_CTRL_NotesRelatedList.getNoteRecords(newAccount.Id);
        Test.stopTest();
        
        // Verify results
        Assert.areEqual(0, results.size(), 'Should return empty list for record with no notes');
    }
   
    
    
}