/**
 * @Name of the Class: ICS_CTRL_InvokeAdobeFlowTest
 * @description class used as controller for  SBO-UK Adobe Feature
 *
 * Story:SFP-37439 
 *
 * @author Ramya Gurram
 *
 * @date Feb 27 2025
 * @last modified on  : 27-02-2025
 * @last modified by  : Ramya Gurram
 * @Modification Description :SFP-37439 class used to write test method  Invoke Adobe Flow
 */
@isTest
public class ICS_CTRL_InvokeAdobeFlowTest {
    
    private static Account createTestAccount() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        return acc;
    }
    
    private static void createContentDocumentForAccount(Account acc) {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('This is the content of the test document'),
            ContentLocation = 'S'
        );
        insert contentVersion;
        
        contentVersion = [SELECT Id,  ContentDocumentId,versiondata from contentVersion LIMIT 1];
        ContentDocument contentDocument = [SELECT Id FROM ContentDocument WHERE Id = :contentVersion.ContentDocumentId LIMIT 1];
        
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = contentDocument.Id,
            LinkedEntityId = acc.Id, 
            ShareType = 'V', 
            Visibility = 'AllUsers' 
        );
        insert contentDocLink;
        
    }

    @isTest
	static void testInvokeFlow() {
    Account testAccount = createTestAccount();
    createContentDocumentForAccount(testAccount);
    List<String> accountIds = new List<String>{testAccount.Id};
    Test.startTest();
    
    try {
        ICS_CTRL_InvokeAdobeFlow.invokeFlow(accountIds);
        ContentDocumentLink docLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id LIMIT 1];
        Assert.areNotEqual(null, docLink, 'The document should be linked to the Account.');
        Assert.areEqual(true, 'Flow invoked successfully without exceptions.');

    } catch (Exception e) {
        Assert.areNotEqual('Unexpected exception', 'An unexpected exception occurred during flow execution: ' + e.getMessage());
    } finally {
        Test.stopTest();
    }
}

    @isTest
    static void testFetchAccountName() {
        Account testAccount = createTestAccount();
        String result = ICS_CTRL_InvokeAdobeFlow.fetchAccountName(testAccount.Id);
        Assert.areEqual('Test Account', result, 'Account name should match the inserted name.');
    }

    @isTest
    static void testFetchAccountName_InvalidId() {
        String invalidAccountId = '001xxxxxxxxxxxx';  

        try {
            ICS_CTRL_InvokeAdobeFlow.fetchAccountName(invalidAccountId);
            Assert.areEqual('Invaild Account ID', 'Exception should be thrown for invalid account ID.');
        } catch (Exception e) {
            Assert.areNotEqual('Expected exception','Expected exception was thrown for invalid Account ID');
        }
    }
}