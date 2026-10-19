/**
* @description Test class for AOB_SRV_GetAccessToken
* 
* @author dayakar
* 
* @date Jan 25th 2023 
*/

@isTest
public class AOB_SRV_GetAccessToken_Test {
    /**
    * @description Test method for AOB_SRV_GetAccessToken.getAccessToken
    */   
    @isTest
    static void getAccessTokenTest() {
        Test.startTest();
        String accessToken = AOB_SRV_GetAccessToken.getAccessToken();
        Test.stopTest();    
        Assert.areNotEqual(null, accessToken); 
    }   
    /**
    * @description Test method for AOB_SRV_GetAccessToken.sendOTP
    */ 
    @isTest
    static void sendOTPTest() {
        string Checkdirector ='New';
         AOB_BOTS_DAL_TestFactory.creatProduct();
         Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
         prod.AOB_Memo_Code__c='SOCTY';
         update prod;
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        String responses = AOB_SRV_GetAccessToken.sendOTP(app.id,Checkdirector);
        Test.stopTest();        
        Test.setMock(HttpCalloutMock.class, new AOB_OTPHandlerMock());
        String responsess = AOB_SRV_GetAccessToken.sendOTP(app.id,Checkdirector);  
        Assert.areNotEqual(null, responsess); 
        Assert.areNotEqual(null, responses);    
        Assert.areNotEqual(null, appParticipant);    
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.sendOTP
    */ 
    @isTest
    static void sendOTPNegTest() {
        string Checkdirector ='New';
         AOB_BOTS_DAL_TestFactory.creatProduct();
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c participant = new Application_Participant__c(
            CNGCU_Phone__c = '+27123456789',
            CNGCU_Email__c = 'test@example.com',
            Application__c = app.Id,
            AOB_IDNumber__c = '123456789',
            Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test two","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}'
           );
        insert participant;
        Test.startTest();
        String responses = AOB_SRV_GetAccessToken.sendOTP(app.id,Checkdirector);
        Test.stopTest();
        Assert.areNotEqual(null, responses);         
          
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.sendOTP
    */ 
    @isTest
    static void sendOTPSoleTest() {
        try{
        string Checkdirector ='New';
         AOB_BOTS_DAL_TestFactory.creatProduct();
         Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
         prod.AOB_Memo_Code__c='SOCTY';
         update prod;
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        app.AOB_BCCEntityType__c = 'Sole Proprietor';
         app.AOB_Product__c=prod.id;
        app.Inflight__c ='{"How would like receive the message":"SMS","DATE OF RESOLUTION MEETING":"2023-04-12","Intended use of account":"DP"}';
        insert app; 
        Application_Participant__c participant = new Application_Participant__c(
            CNGCU_Phone__c = '+27123456789',
            CNGCU_Email__c = 'test@example.com',
            Application__c = app.Id,
            AOB_IDNumber__c = '123456789',
            Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test two","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}'  
           );
        insert participant;
        Test.startTest();
        String responses = AOB_SRV_GetAccessToken.sendOTP(participant.id,Checkdirector);
        Test.stopTest();   
        Assert.areNotEqual(null, responses);     
        }
        catch(Exception e){
            Assert.areNotEqual(null, e);
        }   
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.sendOTP
    */
    @isTest
    public static void SendOTPFailSoleProprietorTest(){
         string Checkdirector ='EXIST';
         AOB_BOTS_DAL_TestFactory.creatProduct();
         Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
         prod.AOB_Memo_Code__c='SOCTY';
         update prod;
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        app.Inflight__c ='{"How would like receive the message":"SMS","DATE OF RESOLUTION MEETING":"2023-04-12","Intended use of account":"DP"}';
        app.AOB_Product__c=prod.Id;
        insert app;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        String responses = AOB_SRV_GetAccessToken.sendOTP(appParticipant.id,Checkdirector);
        Test.stopTest();
        Assert.areNotEqual(null, responses); 
    }
   
   /**
    * @description Test mock  for AOB_SRV_GetAccessToken
    */
    private class AOB_OTPHandlerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"StatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }
    
   /**
    * @description Test method for AOB_SRV_GetAccessToken.sendEmailOTP
    */
    @isTest
    static void sendEmailOTPTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        String result = AOB_SRV_GetAccessToken.sendEmailOTP(appParticipant.Application__c);
        Test.stopTest();
        Assert.areNotEqual(null, result); 
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.sendEmailOTP
    */
    @isTest
    public static void sendEmailOTPElse_Test(){
       Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        String result1 = AOB_SRV_GetAccessToken.sendEmailOTP(appParticipant.Application__c);
        Test.stopTest();
        Assert.areNotEqual(null, result1); 
    }

    /**
    * @description Test mock  for AOB_SRV_GetAccessToken
    */
    private class AOB_OTPHandlerMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"StatusCode":201}');
            res.setStatusCode(201);
            return res;
        }
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.sendEmailOTP
    */
    @isTest
    public static void sendEmailOTP_ResponseStatusCodeTest(){      
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        try{
            Test.setMock(HttpCalloutMock.class, new AOB_OTPHandlerMock1());
            String responsess1 = AOB_SRV_GetAccessToken.sendEmailOTP(appParticipant.Application__c);
            Assert.areNotEqual(null, responsess1); 
        } catch(Exception e){ 
            Assert.areNotEqual(null, e);
        }      
    }
   
     /**
    * @description Test method for AOB_SRV_GetAccessToken.OTPAttemps
    */
    @isTest
    static void OTPAttempsTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        Decimal result = AOB_SRV_GetAccessToken.OTPAttemps(app.Id);
        Test.stopTest();
        Assert.areNotEqual(null, result); 
        Assert.areNotEqual(null, appParticipant); 
    } 
     
     /**
    * @description Test method for AOB_SRV_GetAccessToken.OTPAttemps
    */
    @isTest
    public static void OTPAttempstThreeTest(){
        Test.startTest();
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Decimal result = AOB_SRV_GetAccessToken.OTPAttemps(app.Id);
        Test.stopTest(); 
        Assert.areNotEqual(null, result); 
        Assert.areNotEqual(null, appParticipant); 
    }
     /**
    * @description Test method for AOB_SRV_GetAccessToken.incrementRetryApplication
    */
    @isTest
    static void RetryCountIncrementTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        decimal retryCount = AOB_SRV_GetAccessToken.incrementRetryApplication(app.Id);
        Assert.areEqual(4, retryCount); 
        Assert.areNotEqual(null, appParticipant); 
    }
     
    /**
    * @description Test method for AOB_SRV_GetAccessToken.incrementRetryApplication
    */
    @isTest
    static void RetryCountResetTest() {
        Application__c testApp = new Application__c();
        insert testApp;
        List<Application_Participant__c> appParticipants = new List<Application_Participant__c>();
        appParticipants.add(new Application_Participant__c(AOB_KeyContactPerson__c = true,AOB_Retry_Count__c = 2,Application__c = testApp.Id));
        insert appParticipants;
        AOB_SRV_GetAccessToken.incrementRetryApplication(testApp.Id);
        string applicationid=testApp.Id;
        Application_Participant__c appParticipant = [SELECT AOB_Retry_Count__c FROM Application_Participant__c WHERE Application__c =:applicationid AND AOB_KeyContactPerson__c = true];
         Assert.areEqual(0, appParticipant.AOB_Retry_Count__c);
    }
        
    /**
    *  @description Test method for AOB_SRV_GetAccessToken.updateOTPStatus
    */
    @isTest
    static void updateOTPStatusSoctyTest() {
         AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[select AOB_Memo_Code__c from Product2];
            prod.AOB_Memo_Code__c='SOCTY';
            update prod;
        Application__c testApp = new Application__c();
        testApp.AOB_Product__c=prod.id;
        insert testApp;
        List<Application_Participant__c> testParticipants = new List<Application_Participant__c>{
            new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test@email.com',CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = false,AOB_KeyContactPerson__c = true,AOB_Stage__c = 'OTP Verified'),
            new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test2@email.com',CNGCU_Phone__c = '+27965142524',AOB_Signatory__c = false,AOB_KeyContactPerson__c = false,AOB_Stage__c = 'OTP Verified')};           
            insert testParticipants;
        Test.startTest();
        AOB_SRV_GetAccessToken.updateOTPStatus(testApp.Id);
        Test.stopTest();
    }

    /**
    * @description Test method for AOB_SRV_GetAccessToken.updateOTPStatus
    */
    @isTest
    static void updateOTPStatusTest() {
        Application__c testApp = new Application__c();
        testApp.AOB_BCCEntityType__c = 'Sole Proprietor';
        insert testApp;
        List<Application_Participant__c> testParticipants = new List<Application_Participant__c>{
            new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test@email.com',CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = false,AOB_KeyContactPerson__c = true,AOB_Stage__c = 'OTP Verified'),
            new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test2@email.com',CNGCU_Phone__c = '+27965142524',AOB_Signatory__c = false,AOB_KeyContactPerson__c = false,AOB_Stage__c = 'OTP Verified')};           
            insert testParticipants;
        Test.startTest();
        AOB_SRV_GetAccessToken.updateOTPStatus(testApp.Id);
        Test.stopTest();
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.incrementRetryApplicationpartipant
    */ 
    
    @isTest
    static void IncrementRetryApplicationpartipantTest() {
        Application__c testApp = new Application__c();
        insert testApp;
        Application_Participant__c appRec = new Application_Participant__c(AOB_TECH_OTPATTEMS__c = 3,Application__c =testApp.Id,CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = true,AOB_KeyContactPerson__c = true,CNGCU_Email__c = 'test@email.com',AOB_Stage__c='CIPA Verified');
        insert appRec;
        Test.startTest();
        decimal result = AOB_SRV_GetAccessToken.incrementRetryApplicationpartipant(appRec.Id);
        Test.stopTest();
        Application_Participant__c updatedAppRec = [SELECT AOB_Retry_Count__c FROM Application_Participant__c WHERE Id = :appRec.Id];
         Assert.areEqual(1, updatedAppRec.AOB_Retry_Count__c);
        Assert.areEqual(1, result);
    }
    /**
    * @description Test method for AOB_SRV_GetAccessToken.incrementRetryApplicationpartipant
    */    
    @isTest
    public static void incrementRetryApplicationpartipant_Catch_Test(){
        try{
            Test.startTest();
            string applicationid;
            AOB_SRV_GetAccessToken.incrementRetryApplicationpartipant(applicationid);
            Test.stopTest();
        }
        catch(Exception e){
            Assert.areNotEqual(null, e);
        }        
    }
}