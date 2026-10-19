/**
 * @description SFP-5420 - Test class for the controller with Chatbot requests
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 *
 * @date Sep 24th 2021
 */
@isTest
public class SVC_ChatBotStatusHandler_TEST {
    /**
     * @description Checks case status on chatbot request
     */
    @isTest
    private static void checkCaseStatusTest() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;

        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;

        Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
        newCase.AccountId = newAccount.Id;
        insert newCase;
        newCase = [SELECT Id, CaseNumber, Status FROM Case WHERE Id = :newCase.Id];

        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;

        LiveChatTranscript newTranscript = new LiveChatTranscript(
            ContactId = newContact.Id,
            AccountId = newAccount.Id,
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = '0000-0000-000x-0x00-0000'
        );
        insert newTranscript;

        Test.startTest();
        SVC_ChatBotStatusHandler.ChatBotCaseSearchInput input = new SVC_ChatBotStatusHandler.ChatBotCaseSearchInput();
        input.caseNumber = '000000';
        List<SVC_ChatBotStatusHandler.ChatBotCaseSearchOutput> result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        System.assertEquals(null, result[0].errorMessage);
        System.assertEquals(null, result[0].caseStatus);

        input.caseNumber = newCase.CaseNumber;
        result = SVC_ChatBotStatusHandler.checkCaseStatus(
            new List<SVC_ChatBotStatusHandler.ChatBotCaseSearchInput>{input}
        );
        System.assertEquals(null, result[0].errorMessage);
        System.assertEquals(newCase.Status, result[0].caseStatus);
        Test.stopTest();
    }
}