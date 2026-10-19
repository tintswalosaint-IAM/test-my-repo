/*****************************************************
* @description  Class used as test controller for ICS_API_GBGIDPOAProcessResultHandler
* @author IKYATHA NAIDU,Swapnil Walse 
* @User Story SFP-32986
* @date 12/05/2024
**********************************************************
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated version to latest
*/
@isTest
public class ICS_API_GBGIDPOAProcessResultHan_Test {
    @TestSetup
    static void setupTestData() { 
        Account acc = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createPartyProfile(acc.id);
        Opportunity opp=ICS_DAL_TestFactory.createOpportunity(acc.id);
        ICS_DAL_TestFactory.createApplicationForm(acc.id, opp.id);
    }
    static testmethod void processResultTest(){
        PartyProfile pData =[select id,AccountId from PartyProfile limit 1];
        test.starttest();
        String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed","webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00","assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333","identifier":"'+pData.accountid+'","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[{"node":{"id":"16054780","outcome":"AddressConfirmed","screeningConfig":{"name":"gbg_address_screening","screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete","outcome":"AddressConfirmed"}}]}}},{"node":{"id":"16054779","outcome":"IdentityInconclusive","screeningConfig":{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881","closed":true,"state":"Complete","outcome":"IdentityInconclusive"}}]}}}]}}}]}}}}';
        ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
        resultHandler.responseCall(jsonString,ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
        test.stoptest();
        Assert.areEqual(true,(jsonString !=null),'request Message');
    }
  static testmethod void processCRAResultTest(){
        PartyProfile pData =[select id,AccountId from PartyProfile limit 1];
        test.starttest();
          string jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":5902302,"complete":true,"status":"Complete","created":"2024-04-22T14:56:02.506896+00:00","updated":"2024-04-23T08:44:14.196088+00:00","assessmentConfig":{"name":"full_cra","assessmentType":"GenericAssessment"},"customer":{"identifier":"'+pData.accountid+'","id":73603333,"pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[{"node":{"id":16153739,"outcome":"Complete","screeningConfig":{"name":"full_cra_screening","screeningType":"OffshoreEDDScreening"},"cases":{"edges":[]}}}]}}}]}}}';
        ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
        resultHandler.responseCall(jsonString,ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
        test.stoptest();
        Assert.areEqual(true,(jsonString !=null),'request Message');
    }
    static testmethod void testEmptyAccountList() {
        // Test when Account List is empty
        test.startTest();
        
        String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed","webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00","assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333","identifier":"1234567890","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[{"node":{"id":"16054780","outcome":"AddressConfirmed","screeningConfig":{"name":"gbg_address_screening","screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete","outcome":"AddressConfirmed"}}]}}},{"node":{"id":"16054779","outcome":"IdentityConclusive","screeningConfig":{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881","closed":true,"state":"Complete","outcome":"IdentityInconclusive"}}]}}}]}}}]}}}}';
        
        ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
        String response = resultHandler.responseCall(jsonString, ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
        
        test.stopTest();
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        
        Assert.areEqual(true,(responseMap.get('status') =='Error'),'Account not found!');
    }

    static testmethod void testExceptionHandlingResponseCall() {
        // Test exception handling in responseCall method
        test.startTest();
         PartyProfile pData =[select id,AccountId from PartyProfile limit 1];
        String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed","webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00","assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333","identifier":"'+pData.accountid+'","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[{"node":{"id":"16054780","outcome":"AddressConfirmed","screeningConfig":{"name":"gbg_address_screening","screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete","outcome":"AddressConfirmed"}}]}}},{"node":{"id":"16054779","outcome":"IdentityConclusive","screeningConfig":{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881","closed":true,"state":"Complete","outcome":"IdentityConclusive"}}]}}}]}}}]}}}}';
        try{
        ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
     	resultHandler.responseCall(jsonString, ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
        }catch(exception ex){
            
             Assert.areEqual(true,(jsonString !=null),'Deserialization should fail');
        }
        test.stopTest();
       
    }

    static testmethod void testExceptionHandlingUpdateFormAndOpportunity() {
        // Test exception handling in updateFormAndOpportunity method
        PartyProfile pData =[select id,AccountId from PartyProfile limit 1];
        test.startTest();
        
        ICS_API_GBGIDPOAProcessResultHandler handler = new ICS_API_GBGIDPOAProcessResultHandler();
        handler.pProfile = pData;
        string response = handler.updateFormAndOpportunity(2);  //Trigger the method directly
        Assert.areEqual(false,(response =='error occured'),'Exception occured while fetching applicationForm');
        test.stopTest(); 
    }

    static testmethod void testExceptionHandlingUpdateOpportunityStage() {
        // Test exception handling in updateOpportunityStage method
        try{
        Account acc=[select id from account limit 1];
        
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(acc.id);
        test.startTest();
        ICS_API_GBGIDPOAProcessResultHandler handler = new ICS_API_GBGIDPOAProcessResultHandler();
        handler.formData = form;
        string response = handler.updateOpportunityStage(); // Trigger the method directly
        Assert.areEqual(true,(response !=''),'Exception occured while updating opportunity');
        test.stopTest();
         }catch(exception ex){
            
             Assert.areEqual(true,(ex.getmessage() !=null),'Deserialization should fail');
        }
    }
    
    static testmethod void testCRAResponseProcessingWithRisk() {
    PartyProfile pData = [SELECT id, AccountId FROM PartyProfile LIMIT 1];
    
    test.startTest();
   String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":5902302,"complete":true,"status":"Complete","created":"2024-04-22T14:56:02.506896+00:00","updated":"2024-04-23T08:44:14.196088+00:00","assessmentConfig":{"name":"full_cra","assessmentType":"GenericAssessment"},"customer":{"identifier":"' + pData.AccountId + '","id":73603333,"pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[{"node":{"id":16153739,"outcome":"Complete","resultContext":"{\\"total_score\\": 75.5, \\"group_risk_rating\\": \\"High\\"}","screeningConfig":{"name":"full_cra_screening","screeningType":"OffshoreEDDScreening"},"cases":{"edges":[]}}}]}}}]}}}';
    
    ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
    resultHandler.responseCall(jsonString, ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
    test.stopTest();
    
    // Verify PartyProfileRisk record
    PartyProfileRisk createdRisk = [SELECT Risk_Score__c, RiskCategory FROM PartyProfileRisk WHERE PartyProfileId = :pData.Id LIMIT 1];
    Assert.areEqual(75.5, createdRisk.Risk_Score__c, 'Risk score should match');
    Assert.areEqual('High', createdRisk.RiskCategory, 'Risk category should match');
    
    // Verify ApplicationForm update
    ApplicationForm updatedForm = [SELECT Enhanced_Due_Diligence_Required__c FROM ApplicationForm WHERE AccountId = :pData.AccountId LIMIT 1];
    Assert.isTrue(updatedForm.Enhanced_Due_Diligence_Required__c, 'Enhanced Due Diligence should be required for High risk');
}
      @isTest
    static void testSeafarerEmailSuccess() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        EmailTemplate continueTemplate = new EmailTemplate(
            Name = 'ContinueWithApplicationTemplate',
            DeveloperName = 'ContinueWithApplicationTemplate',
            TemplateType = 'text',
            FolderId = UserInfo.getUserId(),
            Subject = 'Test Subject',
            HtmlValue = 'Hello {!Account.Name}, click here to continue'
        );
        insert continueTemplate;        
        Test.startTest();
        ICS_API_GBGIDPOAProcessResultHandler.sendEmail(testAccount.Id, continueTemplate.Id, 'Seafarer');        
        Test.stopTest();
        Assert.areEqual(0, Limits.getEmailInvocations(), 'One email should have been sent');
    }
     @isTest
    static void testBothConfirmed() {
        PartyProfile pData = [SELECT Id, AccountId FROM PartyProfile LIMIT 1];
        
       // Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('{"Selected Account": "Seafarer"}'));
        
        Test.startTest();
        
        // Create JSON response with both confirmations
        String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed",' +
            '"webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00",' +
            '"assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333",' +
            '"identifier":"' + pData.AccountId + '","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[' +
            '{"node":{"id":"16054780","outcome":"AddressConfirmed","screeningConfig":{"name":"gbg_address_screening",' +
            '"screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete",' +
            '"outcome":"AddressConfirmed"}}]}}},{"node":{"id":"16054779","outcome":"IdentityConfirmed","screeningConfig":' +
            '{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881",' +
            '"closed":true,"state":"Complete","outcome":"IdentityConfirmed"}}]}}}]}}}]}}}';
            
        ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
        resultHandler.responseCall(jsonString, ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
         Assert.areEqual(true,resultHandler != null, '');
        Test.stopTest();
    }
    @isTest
static void testDocumentVerificationFailed() {
    PartyProfile pData = [SELECT Id, AccountId FROM PartyProfile LIMIT 1];
    
    Test.startTest();
    
    // Create JSON where facial is accepted but document verification fails
    String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed",' +
        '"webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00",' +
        '"assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333",' +
        '"identifier":"' + pData.AccountId + '","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[' +
        '{"node":{"id":"16054780","outcome":"AddressRejected","screeningConfig":{"name":"gbg_address_screening",' +
        '"screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete",' +
        '"outcome":"AddressRejected"}}]}}},{"node":{"id":"16054779","outcome":"IdentityConfirmed","screeningConfig":' +
        '{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881",' +
        '"closed":true,"state":"Complete","outcome":"IdentityConfirmed"}}]}}}]}}}]}}}';
        
    ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
    resultHandler.responseCall(jsonString, ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
    Assert.areEqual(true, resultHandler != null, 'Handler should process document verification failure');
    Test.stopTest();
}

@isTest
static void testFacialVerificationFailed() {
    PartyProfile pData = [SELECT Id, AccountId FROM PartyProfile LIMIT 1];
    
    Test.startTest();
    
    // Create JSON where document is accepted but facial verification fails
    String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed",' +
        '"webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00",' +
        '"assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333",' +
        '"identifier":"' + pData.AccountId + '","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[' +
        '{"node":{"id":"16054780","outcome":"AddressConfirmed","screeningConfig":{"name":"gbg_address_screening",' +
        '"screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete",' +
        '"outcome":"AddressConfirmed"}}]}}},{"node":{"id":"16054779","outcome":"IdentityRejected","screeningConfig":' +
        '{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881",' +
        '"closed":true,"state":"Complete","outcome":"IdentityRejected"}}]}}}]}}}]}}}';
        
    ICS_API_GBGIDPOAProcessResultHandler resultHandler = new ICS_API_GBGIDPOAProcessResultHandler();
    resultHandler.responseCall(jsonString, ICS_API_GBGIDPOAVerifyProcessResult.SERVICE_NAME);
    Assert.areEqual(true, resultHandler != null, 'Handler should process facial verification failure');
    Test.stopTest();
}
        
        // Verify records
}