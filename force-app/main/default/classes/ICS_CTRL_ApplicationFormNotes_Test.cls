@isTest
public with sharing class ICS_CTRL_ApplicationFormNotes_Test {
    @TestSetup
    static void prepareMockRecords() {
        Account acc = ICS_TestDataFactory.createAccount();
        Opportunity opp = ICS_TestDataFactory.createOpportunity(acc.Id);
        Application__c app = ICS_TestDataFactory.createApplication(acc.Id, opp.Id);

        ContentNote applicantDetailsNote = new ContentNote(Title='Applicant Details');
        applicantDetailsNote.Content = Blob.valueOf('test1');
        insert applicantDetailsNote;
        ContentDocumentLink applicantDetailsNoteLink = new ContentDocumentLink(
            LinkedEntityId=app.Id,
            ContentDocumentId=applicantDetailsNote.Id
        );
        insert applicantDetailsNoteLink;

        ContentNote employmentDetailsNote = new ContentNote(Title='Employment Details');
        employmentDetailsNote.Content = Blob.valueOf('test2');
        insert employmentDetailsNote;
        ContentDocumentLink employmentDetailsNoteLink = new ContentDocumentLink(
            LinkedEntityId=app.Id,
            ContentDocumentId=employmentDetailsNote.Id
        );
        insert employmentDetailsNoteLink;

        ContentNote financialDetailsNote = new ContentNote(Title='Financial Details');
        financialDetailsNote.Content = Blob.valueOf('test3');
        insert financialDetailsNote;
        ContentDocumentLink financialDetailsNoteLink = new ContentDocumentLink(
            LinkedEntityId=app.Id,
            ContentDocumentId=financialDetailsNote.Id
        );
        insert financialDetailsNoteLink;

        ContentNote yourAccountDetailsNote = new ContentNote(Title='Your Account Details');
        yourAccountDetailsNote.Content = Blob.valueOf('test4');
        insert yourAccountDetailsNote;
        ContentDocumentLink yourAccountDetailsNoteLink = new ContentDocumentLink(
            LinkedEntityId=app.Id,
            ContentDocumentId=yourAccountDetailsNote.Id
        );
        insert yourAccountDetailsNoteLink;

        ContentNote agreementDetailsNote = new ContentNote(Title='Agreement Details');
        agreementDetailsNote.Content = Blob.valueOf('test5');
        insert agreementDetailsNote;
        ContentDocumentLink agreementDetailsNoteLink = new ContentDocumentLink(
            LinkedEntityId=app.Id,
            ContentDocumentId=agreementDetailsNote.Id
        );
        insert agreementDetailsNoteLink;
    }

    @isTest
    static void getNotesTest() {
        Application__c app = [SELECT Id FROM Application__c LIMIT 1];

        ICS_CTRL_ApplicationFormNotes.Requests request = new ICS_CTRL_ApplicationFormNotes.Requests();
        request.applicationId = app.Id;
        List<ICS_CTRL_ApplicationFormNotes.Requests> requestList = new List<ICS_CTRL_ApplicationFormNotes.Requests>();
        requestList.add(request);
        
        Test.startTest();
        List<ICS_CTRL_ApplicationFormNotes.Results> result = ICS_CTRL_ApplicationFormNotes.getNotes(requestList);
        Test.stopTest();

        Assert.isTrue(result[0].applicantDetails == 'test1');
        Assert.isTrue(result[0].employmentDetails == 'test2');
        Assert.isTrue(result[0].financialDetails == 'test3');
        Assert.isTrue(result[0].yourAccountDetails == 'test4');
        Assert.isTrue(result[0].agreementDetails == 'test5');
    }
}