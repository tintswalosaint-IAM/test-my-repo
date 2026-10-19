/***************************************************************************************
@Author            : Lokesh
@Date              : Oct 7th 2021
@Name of the Class : CMN_SRV_GetAccessToken_Test
@description       : Test Class for CMN_SRV_GetAccessToken
@Last Modified By  : Lokesh   
@Last Modified On  : 19 July 2023
@Modification Description : 
***************************************************************************************/
@istest
public class CMN_SRV_GetAccessToken_Test {
    
    
    /**
* @description MockBCB_GetRelyComplyAccessToken
*/ 
    private class MockBCB_GetRelyComplyAccessToken implements HttpCalloutMock {
        private String mockResponse;
        /**
* @description MockBCB_GetRelyComplyAccessToken
* @param mockResponse
*/ 
        public MockBCB_GetRelyComplyAccessToken(String mockResponse) {
            this.mockResponse = mockResponse;
        }
        /**
* @description MockBCB_GetRelyComplyAccessToken
* @param req
* @return HTTPResponse
*/ 
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(mockResponse);
            res.setStatusCode(200);
            return res;
        }
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.sendOTP
*/ 
    @isTest
    static void sendOTPTest() {     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        Test.startTest();
        String responses = CMN_SRV_GetAccessToken.sendOTP(lstApp[0].id);
        Test.stopTest();        
        Test.setMock(HttpCalloutMock.class, new AOB_OTPHandlerMock());
        String responsess = CMN_SRV_GetAccessToken.sendOTP(lstApp[0].id);  
        
        Assert.isNotNull(responsess,'Test'); 
        Assert.isNotNull(responses,'Test');    
        
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.sendSMSonCongratsTest
*/ 
    @isTest
    static void sendSMSonCongratsTest() {     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        Test.startTest();
        String responses = CMN_SRV_GetAccessToken.sendOTP(lstApp[0].id);
        Test.stopTest();        
        Test.setMock(HttpCalloutMock.class, new AOB_OTPHandlerMock());
        string congResponse=CMN_SRV_GetAccessToken.sendSMSonCongrats(lstParticipants[0].id);
        
        
        Assert.isNotNull(congResponse,'Test');    
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.sendSMSonCongratsTest
*/ 
    @isTest
    static void sendSMSonCongratsTest26() {     
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        try{
            Test.startTest();
            String responses = CMN_SRV_GetAccessToken.sendOTP(lstApp[0].id);
            Test.stopTest();        
            Test.setMock(HttpCalloutMock.class, new AOB_OTPHandlerMock());
            string congResponse=CMN_SRV_GetAccessToken.sendSMSonCongrats(null);
        }catch(exception ex){
            Assert.isNotNull(ex.getmessage(),'test'); 
            
        }
        
        
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.sendSMSonCongratsTest
*/ 
    @isTest
    static void sendSMSonCongratsTest2() {  
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        try{
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AOB_OTPHandlerMockFailed());
            String responses = CMN_SRV_GetAccessToken.sendOTP(null);
            Test.stopTest();        
        }catch(exception ex){
            Assert.isNotNull(ex.getMessage(),'Test'); 
        }   
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.sendOTP
*/ 
    @isTest
    static void sendOTPSoleTest() {
        try{
            Application__c app = new Application__c();
            app.AOB_RegistrationNumber__c = 'BW00001881348';
            app.AOB_BCCEntityType__c = 'Sole Proprietor';
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
            String responses = CMN_SRV_GetAccessToken.sendOTP(participant.id);
            Test.stopTest();   
            Assert.isNotNull(responses,'Test'); 
            Map<String,Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responses);
            Assert.areEqual((Integer)responseMap.get('statusCode'),200);     
        }
        catch(Exception e){
            Assert.isNotNull(e,'Test');   
        }   
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.sendOTP
*/ 
    @isTest
    static void sendOTPNegTest() {
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        Application_Participant__c participant = new Application_Participant__c(
            CNGCU_Phone__c = '+27123456789',
            CNGCU_Email__c = 'test@example.com',
            Application__c = lstApp[0].Id,
            AOB_IDNumber__c = '123456789',
            Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test two","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}'
        );
        insert participant;
        Test.startTest();
        String responses = CMN_SRV_GetAccessToken.sendOTP(lstApp[0].id);
        Test.stopTest();
        Map<String,Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responses);
        Assert.isNotNull(responses,'Test');           
    }
    
    /**
* @description Test mock  for CMN_SRV_GetAccessToken
*/
    private class AOB_OTPHandlerMock implements HttpCalloutMock {
        /**
* @description Test mock  for HTTPResponse
* @param req
* @return HTTPResponse
*/
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"StatusCode":200}');
            res.setStatusCode(200);
            return res;
        }
    }
    /**
* @description Test mock  for CMN_SRV_GetAccessToken
*/
    private class AOB_OTPHandlerMockFailed implements HttpCalloutMock {
        /**
* @description Test mock  for HTTPResponse
* @param req
* @return HTTPResponse
*/
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody('{"StatusCode":500}');
            res.setStatusCode(500);
            return res;
        }
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.retryCountIncrementTest
*/
    @isTest
    static void retryCountIncrementTest() {
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        decimal retryCount = CMN_SRV_GetAccessToken.incrementRetryApplication(lstApp[0].Id);
        Assert.isNotNull(lstParticipants,'Test');   
        Assert.isNotNull(retryCount,'Test'); 
        Assert.areEqual(retryCount,1);     
    }
    
    /**
* @description Test method for CMN_SRV_GetAccessToken.incrementRetryApplication
*/
    @isTest
    static void retryCountResetTest() {
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        CMN_SRV_GetAccessToken.incrementRetryApplication(lstApp[0].Id);
        Assert.isNotNull(lstParticipants,'Test');   
    }
    
    /**
* @description Test method for CMN_SRV_GetAccessToken.incrementRetryApplicationpartipant
*/ 
    @isTest
    static void incrementRetryApplicationpartipantTest() {
        Application__c testApp = new Application__c();
        insert testApp;
        Application_Participant__c appRec = new Application_Participant__c(AOB_TECH_OTPATTEMS__c = 3,Application__c =testApp.Id,CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = true,AOB_KeyContactPerson__c = true,CNGCU_Email__c = 'test@email.com',AOB_Stage__c='CIPA Verified');
        insert appRec;
        Test.startTest();
        decimal result = CMN_SRV_GetAccessToken.incrementRetryApplicationpartipant(appRec.Id);
        Test.stopTest();
        Application_Participant__c updatedAppRec = [SELECT AOB_Retry_Count__c FROM Application_Participant__c WHERE Id = :appRec.Id];
        Assert.isNotNull(result,'Test');   
    }
    /**
* @description Test method for CMN_SRV_GetAccessToken.incrementRetryApplicationpartipant
*/    
    @isTest
    public static void incrementRetryApplicationpartipant_Catch_Test(){
        try{
            Test.startTest();
            string applicationid;
            CMN_SRV_GetAccessToken.incrementRetryApplicationpartipant(applicationid);
            Test.stopTest();
        }
        catch(Exception e){
            Assert.isNotNull(e,'Test');   
        }        
    }  
    /**
*  @description Test method for CMN_SRV_GetAccessToken.updateOTPStatus
*/
    @isTest
    static void updateOTPStatusTest() {
        Application__c testApp = new Application__c();
        testApp.AOB_UG_BCB_Stage__c='Strong Auth';
        insert testApp;
        List<Application_Participant__c> testParticipants = new List<Application_Participant__c>{
            new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test@email.com',CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = false,AOB_KeyContactPerson__c = true),
                new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test2@email.com',CNGCU_Phone__c = '+27965142524',AOB_Signatory__c = false,AOB_KeyContactPerson__c = false)};           
                    insert testParticipants;
        Test.startTest();
        CMN_SRV_GetAccessToken.updateOTPStatus(testApp.Id);
        Test.stopTest();
        Assert.isNotNull(testApp,'Test'); 
    }
    /**
*  @description Test method for CMN_SRV_GetAccessToken.updateOTPStatus
*/
    @isTest
    static void updateOTPStatuscatchTest() {
        Application__c testApp = new Application__c();
        testApp.AOB_UG_BCB_Stage__c='Strong Auth';
        insert testApp;
        List<Application_Participant__c> testParticipants = new List<Application_Participant__c>{
            new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test@email.com',CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = false,AOB_KeyContactPerson__c = true),
                new Application_Participant__c(Application__c = testApp.Id,CNGCU_Email__c = 'test2@email.com',CNGCU_Phone__c = '+27965142524',AOB_Signatory__c = false,AOB_KeyContactPerson__c = false)};           
                    insert testParticipants;
        Test.startTest();
        CMN_SRV_GetAccessToken.updateOTPStatus(null);
        Test.stopTest();
        Assert.isNotNull(testApp,'Test'); 
    }
    /**
* @description Test method for AOB_SRV_GetAccessToken.sendEmailOTP
*/
    @isTest
    static void sendEmailOTPTest() {
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        Test.startTest();
        String result = CMN_SRV_GetAccessToken.sendEmailOTP(lstParticipants[0].Application__c);
        Test.stopTest();
        Assert.isNotNull(result,'Test'); 
    }
    /**
* @description Test method for AOB_SRV_GetAccessToken.sendEmailOTP
*/
    @isTest
    public static void sendEmailOTPElseTest(){
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp; 
        List<Application_Participant__c> lstParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstParticipants[0].Application__c =  lstApp[0].Id;
        insert lstParticipants;
        Test.startTest();
        String result1 = CMN_SRV_GetAccessToken.sendEmailOTP(lstParticipants[0].Application__c);
        Test.stopTest();
        Assert.isNotNull(result1,'Test');   
    }
}