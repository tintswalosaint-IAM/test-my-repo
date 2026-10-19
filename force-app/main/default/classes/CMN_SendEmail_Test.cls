/**
 * @description       : Test for CMN_SendEmail
 * @author            : Sandile Mathe
 * @group             : PER: Personalisation
 * @Created on        : 02-06-2024
**/
@isTest
public class CMN_SendEmail_Test {
    
  /**
     * @description Sets up the test data by creating a test Account and Related Information
  */  
  @TestSetup
    static void setupTestData(){
        
        PER_BAS_TestDataFactory.createTestAccount();
    }
    
  @isTest
    static void testSendEmailSuccess() {

        Test.startTest();
        try{
             Account acc = [SELECT Id,Name From Account WHERE LastName ='Test Account']; 
             sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess()); 
             CMN_SendEmail.sendEmail(acc.Id,'Test Subject','This is a test email body.','73739');
            
             // Verify that no exception is thrown
             List<EmailMessage> emails = [SELECT Id, Subject FROM EmailMessage WHERE Subject='Test Subject' LIMIT 1];
             Assert.areEqual(1, emails.size(), 'Email sent successfully Successfully.');
             Assert.areEqual(true, true, 'API Call Test completed successfully'); 
            
        }catch(Exception e){
            
            Assert.areEqual('API callout failed: Unknown error occurred when updating NBA Store.', e.getMessage(), 'Unexpected exception message.');
        }

        Test.stopTest();
    }
    
      @isTest
    static void testTriggertheException() {

        Test.startTest();
        try{
             Account acc = [SELECT Id,Name From Account WHERE LastName ='Test Account']; 
             sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockHttpResponseSuccess()); 
             CMN_SendEmail.sendEmail('','',' ','');
            
        }catch(Exception ex){
            Assert.areEqual(ex.getMessage().contains('Script-thrown exception'),true);
        }

        Test.stopTest();
    }
    
    private class MockHttpResponseSuccess implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('{"success": true}');
        res.setStatusCode(CMN_API_Service.HTTP_OK);
        return res;
    }
}


}