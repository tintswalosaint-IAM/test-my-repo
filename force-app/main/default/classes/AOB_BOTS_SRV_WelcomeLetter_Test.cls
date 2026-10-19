/**
* @description Test class for AOB_SRV_GetAccessToken
* 
* @author dayakar
* 
* @date Jan 25th 2023 
*/

@isTest
public class AOB_BOTS_SRV_WelcomeLetter_Test {
    
     /*
    * @description Test method for AOB_BOTS_SRV_WelcomeLetter.GetapplicationId(),
    */
    
    @isTest
    static void getapplicationIdTest() {
        try{
         Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
         Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
         String appParticipantId = AOB_BOTS_SRV_WelcomeLetter.getapplicationId(appParticipant.Id);
         Assert.areEqual(appParticipant.Id, appParticipantId);
        }
        catch(Exception e)
        {
            Assert.areNotEqual(null, e);
        }
    } 
    
    /*
    * @description Test method for AOB_BOTS_SRV_WelcomeLetter.signingHUBPackages(),
    */
    @isTest
    static void signingHUBPackagesTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13335},"sendDocumnetWelcomeletter":{"documentid":13342},"SigningHUBDocumnetonline":{"documentid":13334},"CardSelection":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"DP","DATE OF RESOLUTION MEETING":"2023-04-07","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13675,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnet":{"documentid":13333},"SigningHUBPackageswelcomeletter":{"package_id":13680,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"}}';
        update app;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
        Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
        appDoc.Application__c = appParticipant.Application__c;
        appDoc.Document_Type__c='Welcome Letter';
        update appDoc;
        
        Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_WelcomeLetter.signingHUBPackages(appParticipant.Id);
        Test.stopTest();
        Assert.areEqual(200, statusCode);
    }
    /*
     * @description Test method for AOB_BOTS_SRV_WelcomeLetter.sendDocumnetWelcomeletter()
     */
    @isTest
    static  void sendDocumnetWelcomeletterTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13335},"sendDocumnetWelcomeletter":{"documentid":13342},"SigningHUBDocumnetonline":{"documentid":13334},"CardSelection":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"DP","DATE OF RESOLUTION MEETING":"2023-04-07","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13675,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnet":{"documentid":13333},"SigningHUBPackageswelcomeletter":{"package_id":13680,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
			appDoc.Application__c = appParticipant.Application__c;
            appDoc.External_Id__c='test_document_id';
            appDoc.Document_Type__c='Welcome Letter';
            update appDoc;
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_WelcomeLetter.sendDocumnetWelcomeletter(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, statusCode);
            Application_Document__c updatedAppDoc = [SELECT External_Id__c FROM Application_Document__c WHERE Id = :appDoc.Id];
            Assert.areEqual('test_document_id', updatedAppDoc.External_Id__c);
        }
        catch(Exception e)
        {
           Assert.areNotEqual(null, e);
        }
    }
    
   /*
     * @description  Test method for AOB_BOTS_SRV_WelcomeLetter.addWorkflowUsers()
     */ 
    @IsTest
    static void addWorkflowUsersTest() {
        try{
            
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13335},"sendDocumnetWelcomeletter":{"documentid":13342},"SigningHUBDocumnetonline":{"documentid":13334},"CardSelection":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"DP","DATE OF RESOLUTION MEETING":"2023-04-07","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13675,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnet":{"documentid":13333},"SigningHUBPackageswelcomeletter":{"package_id":13680,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            Test.startTest();
                Integer statusCode = AOB_BOTS_SRV_WelcomeLetter.addWorkflowUsers(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(200, statusCode);
        }
        catch(Exception e)
        {
            Assert.areNotEqual(null, e);
        }
    }
    
    /*
     * @description Test method for AOB_BOTS_SRV_WelcomeLetter.sendDigitalSign()
     */
    
    @IsTest
    static void sendDigitalSignTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13335},"sendDocumnetWelcomeletter":{"documentid":13342},"SigningHUBDocumnetonline":{"documentid":13334},"CardSelection":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"DP","DATE OF RESOLUTION MEETING":"2023-04-07","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13675,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnet":{"documentid":13333},"SigningHUBPackageswelcomeletter":{"package_id":13680,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_WelcomeLetter.sendDigitalSign(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, statusCode); 
        }
        catch(Exception e)
        {
          Assert.areNotEqual(null, e);
        }
    } 
    
    /*
     * @description Test method for AOB_BOTS_SRV_WelcomeLetter.shareDocument()
     */ 
    
    @isTest 
    static void shareDocumentTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13335},"sendDocumnetWelcomeletter":{"documentid":13342},"SigningHUBDocumnetonline":{"documentid":13334},"CardSelection":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"DP","DATE OF RESOLUTION MEETING":"2023-04-07","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13675,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnet":{"documentid":13333},"SigningHUBPackageswelcomeletter":{"package_id":13680,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);

            Test.startTest();
            Integer responseStatusCode = AOB_BOTS_SRV_WelcomeLetter.shareDocument(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(200, responseStatusCode);
        }
        catch(Exception e)
        {
            Assert.areNotEqual(null, e);
        }
        
    }
    
}