/**
 * @description SFP-5420 - Tests for Case Transcript Document Generator class
 *
 * @author Raman Bazyleu
 *
 * @date Sep 24th 2021
 */
@isTest
public class SVC_CaseDocumentGenerator_Test {

    @testSetup static void setup() {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        insert newAccount;
        
        Contact newContact = CMN_DAL_DataFactory.newContact();
        newContact.AccountId = newAccount.Id;
        insert newContact;
        
        Case caseRecord = CMN_DAL_DataFactory.newCase(newContact.Id);
        insert caseRecord;
        
        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;

        LiveChatTranscript newTranscript = new LiveChatTranscript(
            ContactId = newContact.Id,
            AccountId = newAccount.Id,
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = '0000-0000-0000-0000-0001',
            CaseId = caseRecord.Id,
            Status = 'Completed'
        );
        insert newTranscript;
    }
    
    /**
    * @description Checks case creation on chatbot request
    */
    @isTest
    private static void createCaseDocumentBasedOnTranscriptTest() {
        
        List<Case> cases = [
            SELECT Id
            FROM Case
            LIMIT 10
        ];
        
        test.startTest();
            String resultMessage = SVC_CaseDocumentGenerator.createCaseDocumentBasedOnTranscript(cases[0].Id);
            System.assertEquals(resultMessage, 'Document was generated');
            
            resultMessage = SVC_CaseDocumentGenerator.createCaseDocumentBasedOnTranscript(cases[0].Id);
            System.assertEquals(resultMessage, 'Document already Exist');
        
        	resultMessage = SVC_CaseDocumentGenerator.createCaseDocumentBasedOnTranscript('');
            System.assertEquals(resultMessage, 'Incoming params are invalid');
		test.stopTest();
    }
    
}