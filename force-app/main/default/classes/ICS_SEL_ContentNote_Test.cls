@IsTest
private class ICS_SEL_ContentNote_Test {
    @IsTest
    static void testGetContentDocumentLinks() {
        
        Application__c app = new Application__c();
        insert app;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestPath/TestDocument.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;

        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cdId;
        cdl.LinkedEntityId = app.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;

        // Test the getContentDocumentLinks method
        ICS_SEL_ContentDocumentLink contentDocumentLinkSelector = new ICS_SEL_ContentDocumentLink();
        List<ContentDocumentLink> contentDocumentLinks = contentDocumentLinkSelector.getContentDocumentLinks(app.Id);

        Assert.areEqual(1, contentDocumentLinks.size(), 'Unexpected number of ContentDocumentLink records');
        ContentDocumentLink fetchedContentDocumentLink = contentDocumentLinks[0];

        Assert.areEqual(cdl.Id, fetchedContentDocumentLink.Id, 'Unexpected ContentDocumentLink Id');
        Assert.areEqual(cdl.ContentDocumentId, fetchedContentDocumentLink.ContentDocumentId, 'Unexpected ContentDocumentLink ContentDocumentId');
        Assert.areEqual(cdl.LinkedEntityId, fetchedContentDocumentLink.LinkedEntityId, 'Unexpected ContentDocumentLink LinkedEntityId');
    }

    @IsTest
    static void testGetContentNotes() {
        // Create test data
        Application__c app = new Application__c();
        insert app;
    
        ContentNote contentNote = new ContentNote();
        contentNote.Title = 'Test Note';
        contentNote.Content = Blob.valueOf('Test Content');
        insert contentNote;
    
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentNote.Id;
        cdl.LinkedEntityId = app.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    
        List<ContentDocumentLink> links = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :app.Id];
    
        ICS_SEL_ContentNote contentNoteSelector = new ICS_SEL_ContentNote();
        List<ContentNote> contentNotes = contentNoteSelector.getContentNotes(links);
    
        Assert.areEqual(1, contentNotes.size(), 'Unexpected number of ContentNote records');
        ContentNote fetchedContentNote = contentNotes[0];
    
        Assert.areEqual(contentNote.Id, fetchedContentNote.Id, 'Unexpected ContentNote Id');
        Assert.areEqual(contentNote.Content.toString(), fetchedContentNote.Content.toString(), 'Unexpected ContentNote Content');
       }

}