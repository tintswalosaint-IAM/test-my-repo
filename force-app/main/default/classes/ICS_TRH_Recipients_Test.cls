/**
* @description class used as test class for ICS_TRH_Recipients
*
* Story: SFP-11442
*
* @author Ikyatha Naidu
*
* @date May 2023
* @last modified on  : 29-02-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : Initial Version
*/
@isTest
private class ICS_TRH_Recipients_Test {
    @TestSetup
    static void setupTestData() {
       Account testAccount = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(testAccount.Id);
        ICS_DAL_TestFactory.createApplicationForm(testAccount.Id, testOpportunity.Id);
        echosign_dev1__SIGN_Agreement__c agreement =new echosign_dev1__SIGN_Agreement__c();
        agreement.Name ='test';
        agreement.echosign_dev1__Account__c = testAccount.id;
        insert agreement;
        Echosign_Dev1__SIGN_Recipients__c recipient = new Echosign_Dev1__SIGN_Recipients__c(
           echosign_dev1__Agreement__c = agreement.id,
                echosign_dev1__Contact__c = testAccount.PersonContactId,
                echosign_dev1__Status__c = ICS_Constants.Signed
        );
        insert recipient;
    } 
    
      @isTest
    static void testStatusUpdateToSigned() {
        Echosign_Dev1__SIGN_Recipients__c recipient = [SELECT Id, echosign_dev1__Status__c 
                                                      FROM Echosign_Dev1__SIGN_Recipients__c 
                                                      LIMIT 1];
        
        Test.startTest();
        recipient.echosign_dev1__Status__c = ICS_Constants.Signed;
        update recipient;
        Test.stopTest();
        
        recipient = [SELECT Id, echosign_dev1__Status__c 
                    FROM Echosign_Dev1__SIGN_Recipients__c 
                    WHERE Id = :recipient.Id];
        Assert.areEqual(ICS_Constants.Signed, recipient.echosign_dev1__Status__c, 
            'Recipient status should be updated to Signed after status change');
    }
    
    @isTest
    static void testNoStatusChange() {
        Echosign_Dev1__SIGN_Recipients__c recipient = [SELECT Id, echosign_dev1__Status__c 
                                                      FROM Echosign_Dev1__SIGN_Recipients__c 
                                                      LIMIT 1];
        
        Test.startTest();
        update recipient;
        Test.stopTest();
        
        recipient = [SELECT Id, echosign_dev1__Status__c 
                    FROM Echosign_Dev1__SIGN_Recipients__c 
                    WHERE Id = :recipient.Id];
        Assert.areEqual('Signed', recipient.echosign_dev1__Status__c, 
            'Recipient status should remain unchanged when no status update is made');
    }
    
    @isTest
    static void testStatusUpdateToOtherValue() {
        Echosign_Dev1__SIGN_Recipients__c recipient = [SELECT Id, echosign_dev1__Status__c 
                                                      FROM Echosign_Dev1__SIGN_Recipients__c 
                                                      LIMIT 1];
        
        Test.startTest();
        recipient.echosign_dev1__Status__c = 'InProgress';
        update recipient;
        Test.stopTest();
        
        recipient = [SELECT Id, echosign_dev1__Status__c 
                    FROM Echosign_Dev1__SIGN_Recipients__c 
                    WHERE Id = :recipient.Id];
        Assert.areEqual('InProgress', recipient.echosign_dev1__Status__c, 
            'Recipient status should be updated to InProgress when changed from Signed');
    }
}