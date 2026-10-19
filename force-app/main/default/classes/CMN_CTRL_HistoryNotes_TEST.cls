/**
 * @description Test Class for CMN_CTRL_HistoryNotes class
 * @author Gnitsevich Anton
 * @date October 2021
 * @LastModified: March, 2026
 * @Author Ross Kshirsagar
 * @UserStory: SFP-56273
 * @LastModifiedReason: API Code Remediation - removed token dependency, added mocks and coverage
 */
@IsTest
public with sharing class CMN_CTRL_HistoryNotes_TEST {
    private static final Id ACCOUNT_RECORDTYPE_PERSON_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId();

    @TestSetup
    private static void setup() {
        User currentUser = [SELECT Id, RM_AE_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
        currentUser.RM_AE_Code__c = 'A123456';
        update currentUser;

        Account testAccount = new Account();
        testAccount.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON_ID;
        testAccount.FirstName = 'Tester';
        testAccount.LastName = 'Tests';
        insert testAccount;

        testAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :testAccount.Id];
        Contact testContact = [SELECT Id, CMN_CustomerBPID__c FROM Contact WHERE Id = :testAccount.PersonContactId];
        testContact.CMN_CustomerBPID__c = '00123456';
        testContact.CMN_BPGUID__c = '00123ASD';
        update testContact;
    }

    // ─── CMN_CTRL_HistoryNotes.getHistoryNotes ───────────────────────────────

    @IsTest
    private static void testGetHistoryNotes() {
        Account account = [SELECT Id FROM Account WHERE LastName = 'Tests' LIMIT 1];
        User currentUser = [SELECT Id, Name, RM_AE_Code__c FROM User WHERE Id = :UserInfo.getUserId()];

        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetHistoryNotes.GetNotesMockResponse());
        CMN_DTO_NoteInformationResponse response = CMN_CTRL_HistoryNotes.getHistoryNotes(account.Id);
        Test.stopTest();

        Assert.isNotNull(response, 'Response should not be null');
        Assert.isNotNull(response.notes, 'Notes list should not be null');
        Assert.isTrue(response.notes.size() == 1, 'One note should be returned');
        Assert.isTrue(response.notes[0].noteCreatedBy == currentUser.Name, 'AE code should be substituted with the current user name');
        Assert.isNotNull(response.notes[0].noteDatedOn, 'Note date should be returned');
        Assert.isNotNull(response.notes[0].type, 'Note type should be returned');
        Assert.isNotNull(response.notes[0].noteDetails, 'Note details should be returned');
    }

    // ─── CMN_CTRL_HistoryNotes.createHistoryNotes ────────────────────────────

    @IsTest
    private static void testCreateHistoryNote() {
        Account account = [SELECT Id FROM Account WHERE LastName = 'Tests' LIMIT 1];

        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetHistoryNotes.CreateNotesMockResponse());
        String response = CMN_CTRL_HistoryNotes.createHistoryNotes(account.Id, 'Test note details', 'APPLICATIONS');
        Test.stopTest();

        Assert.isNotNull(response, 'Response should not be null');
        Assert.isTrue(response == '201', 'HTTP CREATED response code should be returned');
    }

    // ─── CMN_API_GetHistoryNotes direct coverage ─────────────────────────────

    @IsTest
    private static void testGetLatestClientNotesDirect() {
        Account account = [SELECT Id FROM Account WHERE LastName = 'Tests' LIMIT 1];

        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetHistoryNotes.GetNotesMockResponse());
        CMN_DTO_NoteInformationResponse response = new CMN_API_GetHistoryNotes().getLatestClientNotes(account.Id);
        Test.stopTest();

        Assert.isNotNull(response, 'Response should not be null');
        Assert.isNotNull(response.notes, 'Notes list should not be null');
        Assert.isTrue(response.notes.size() == 1, 'One note should be returned');

        CMN_DTO_NoteInformation note = response.notes[0];
        Assert.isNotNull(note.noteDatedOn, 'Note date should not be null');
        Assert.isNotNull(note.type, 'Note type should not be null');
        Assert.isNotNull(note.noteDetails, 'Note details should not be null');
        Assert.isNotNull(note.noteCreatedBy, 'Note created-by should not be null');
    }

    @IsTest
    private static void testCreateClientNotesDirect() {
        Account account = [SELECT Id FROM Account WHERE LastName = 'Tests' LIMIT 1];

        Test.startTest();
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new CMN_API_GetHistoryNotes.CreateNotesMockResponse());
        String response = new CMN_API_GetHistoryNotes()
            .createClientNotes(account.Id, 'Test note details', 'APPLICATIONS');
        Test.stopTest();

        Assert.isNotNull(response, 'Response should not be null');
        Assert.isTrue(response == '201', 'HTTP CREATED response code should be returned');
    }
}