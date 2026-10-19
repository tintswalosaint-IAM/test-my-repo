/***************************************************************************************
@ Author            :Ikyatha Naidu
@ Date              :2024-02-24
@ Name of the Class :ICS_TRG_SignRecipients_Test
@ Description       :class used as test class ICS_TRG_SignRecipients
@ Last Modified By  :Ikyatha Naidu
@ Last Modified On  :2024-02-24
@ Modification Description :SFP-30254
***************************************************************************************/ 
@isTest
public class ICS_TRG_SignRecipients_Test {
    /**
     * @description To check platform event
     */
    @isTest 
    private static void processRecordTest() {
         Test.startTest();
         Account testAccount = ICS_DAL_TestFactory.createAccount();
        echosign_dev1__SIGN_Agreement__c agreement =new echosign_dev1__SIGN_Agreement__c();
        agreement.Name ='test';
        agreement.echosign_dev1__Account__c = testAccount.id; 
        insert agreement;
        echosign_dev1__SIGN_Recipients__c recipeints = new echosign_dev1__SIGN_Recipients__c();
        recipeints.echosign_dev1__Status__c ='Accepted';
        recipeints.echosign_dev1__Agreement__c = agreement.id;
        insert recipeints;
         recipeints.echosign_dev1__Status__c ='Signed';
        
        
        update recipeints;
        Test.stopTest();
         List<echosign_dev1__SIGN_Recipients__c> receipients = [SELECT Id FROM echosign_dev1__SIGN_Recipients__c 
                                                                WHERE echosign_dev1__Agreement__c =: agreement.Id];
        Assert.isTrue(receipients.size() > 0, 'able to fetch receipients');
    }
}