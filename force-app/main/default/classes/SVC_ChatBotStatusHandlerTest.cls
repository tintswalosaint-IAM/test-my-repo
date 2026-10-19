/**
 * @description SFP-5420 - Test class for the controller with Chatbot requests
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 * @lastModifiedBy Raymond Magezi
 *
 * @date Sep 24th 2021
 * @lastModifiedDate Jan 15th 2025
 */
@isTest
public class SVC_ChatBotStatusHandlerTest {
    
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_CLOSED = 'Closed';
    private static final String STATUS_REOPENED = 'Reopened';
    private static final String STATUS_RESOLVED = 'Resolved';
    private static final String CHAT_KEY = '0000-0000-000x-0x00-0000';
    /**
     * @description Test case not found scenario
     */
    @isTest
    private static void testCaseNotFound() {
        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = '99999999';
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(SVC_ChatBotStatusHandler.CASE_NOT_FOUND_MESSAGE, result[0].errorMessage);
        Assert.areEqual(null, result[0].responseMessage);
        Test.stopTest();
    }
    
    /**
     * @description Test resolved case status message with live chat context
     */
    @isTest
    private static void testResolvedCaseStatus() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;

        LiveChatTranscript newTranscript = new LiveChatTranscript(
            ContactId = newContact.Id,
            AccountId = newAccount.Id,
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = CHAT_KEY
        );
        insert newTranscript;

        // Create a service type record for the test
        SVC_ServiceType__c serviceType = new SVC_ServiceType__c(
            Name = 'Test Service Type',
            SVC_Active__c = true
        );
        insert serviceType;
        
        // Create case with New status first
        Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
        newCase.AccountId = newAccount.Id;
        insert newCase;
        
        // Update to Resolved with required fields
        newCase.Status = STATUS_RESOLVED;
        newCase.SVC_ServiceType__c = serviceType.Id;
        newCase.SVC_RootCauseResolution__c = 'Issue resolved by updating account settings';
        update newCase;
        newCase = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :newCase.Id];

        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = newCase.CaseNumber;
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(null, result[0].errorMessage);
        Assert.areNotEqual(null, result[0].responseMessage);
        Assert.areEqual(true, result[0].responseMessage.contains('resolved'));
        Assert.areEqual(true, result[0].responseMessage.contains('RATE US') || result[0].responseMessage.contains('feedback'));
        Test.stopTest();
    }
    
    /**
     * @description Test closed case status message
     */
    @isTest
    private static void testClosedCaseStatus() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
        newCase.AccountId = newAccount.Id;
        newCase.Status = STATUS_CLOSED;
        insert newCase;
        newCase = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :newCase.Id];

        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = newCase.CaseNumber;
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(null, result[0].errorMessage);
        Assert.areNotEqual(null, result[0].responseMessage);
        Assert.areEqual(true, result[0].responseMessage.contains('resolved'));
        Test.stopTest();
    }
    
    /**
     * @description Test new case status message
     */
    @isTest
    private static void testNewCaseStatus() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
        newCase.AccountId = newAccount.Id;
        newCase.Status = STATUS_NEW;
        insert newCase;
        newCase = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :newCase.Id];

        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = newCase.CaseNumber;
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(null, result[0].errorMessage);
        Assert.areNotEqual(null, result[0].responseMessage);
        Assert.areEqual(true, result[0].responseMessage.contains('successfully submitted'));
        Test.stopTest();
    }
    
    /**
     * @description Test in progress case status message
     */
    @isTest
    private static void testInProgressCaseStatus() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
        newCase.AccountId = newAccount.Id;
        newCase.Status = STATUS_IN_PROGRESS;
        insert newCase;
        newCase = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :newCase.Id];

        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = newCase.CaseNumber;
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(null, result[0].errorMessage);
        Assert.areNotEqual(null, result[0].responseMessage);
        Assert.areEqual(true, result[0].responseMessage.contains('in progress'));
        Test.stopTest();
    }
    
    /**
     * @description Test reopened case status message
     */
    @isTest
    private static void testReopenedCaseStatus() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
        newCase.AccountId = newAccount.Id;
        newCase.Status = STATUS_REOPENED;
        insert newCase;
        newCase = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :newCase.Id];

        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = newCase.CaseNumber;
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(null, result[0].errorMessage);
        Assert.areNotEqual(null, result[0].responseMessage);
        Assert.areEqual(true, result[0].responseMessage.contains('reopened'));
        Test.stopTest();
    }
    
    /**
     * @description Test invalid case number format validation
     */
    @isTest
    private static void testInvalidCaseNumber() {
        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = 'ABC123';
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        Assert.areEqual(SVC_ChatBotStatusHandler.INVALID_CASE_NUMBER_MESSAGE, result[0].errorMessage);
        Assert.areEqual(null, result[0].responseMessage);
        Test.stopTest();
    }
}