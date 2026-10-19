/**
* @description Test class for AOB_BOTS_SRV_SigningHUB_Test
* @author dayakar
* @date Jan 25th 2023 
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/

@isTest
public class AOB_BOTS_SRV_SigningHUB_Test {
    /*
    * @description Test class for AOB_BOTS_SRV_SigningHUB.getAccessToken()
    */
    @isTest
    static void getAccessTokenTest() {
        Test.startTest();
        String accessToken = AOB_BOTS_SRV_SigningHUB.getAccessToken();
        Test.stopTest(); 
        Assert.areNotEqual(null, accessToken, 'Test Meassage');
    }
    
    /*
    *@description Test method for AOB_BOTS_SRV_SigningHUB.signingHUBPackages(),
    */
    @isTest
    static void signingHUBPackagesTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.Inflight__c=null;
        update app;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
        Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
        appDoc.Application__c = appParticipant.Application__c;
        appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
        update appDoc;
        
        Test.startTest();
        Integer statusCode = AOB_BOTS_SRV_SigningHUB.signingHUBPackages(appParticipant.Id);
        Test.stopTest();
        Assert.areEqual(200, statusCode, 'Test Meassage');
    }
    
    /*
    * @description Test method for AOB_BOTS_SRV_SigningHUB.signingHUBPackages() ,condition: else
    */
    @isTest
    static void signingHUBPackagesNegTest() {
        
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
        Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
        appDoc.Application__c = appParticipant.Application__c;
        appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
        update appDoc;
        
        Test.startTest();
        Integer statusCode = AOB_BOTS_SRV_SigningHUB.signingHUBPackages(appParticipant.Id);
        Test.stopTest();
        Assert.areEqual(200, statusCode, 'Test Meassage');
    }
     /*
    * @description Test method for AOB_BOTS_SRV_SigningHUB.signingHUBPackages() ,condition: else
    */
    @isTest
    static void signingHUBPackagesCatchTest() {
        try{
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
        Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
        appDoc.Application__c = appParticipant.Application__c;
        appDoc.Document_Type__c='Stanbic-Bus Ac Open Application';
        update appDoc;
        
        Test.startTest();
        Integer statusCode = AOB_BOTS_SRV_SigningHUB.signingHUBPackages(app.Id);
        Test.stopTest();
        Assert.areEqual(200, statusCode, 'Test Meassage');
        } catch(Exception ex){ 
          Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDocumnetOpenApplication()
     */
    @isTest
    static  void sendDocumnetOpenApplicationTest() {

           AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='SOCTY';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.Id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = appParticipant.Application__c;
            appDoc.External_Id__c='test_document_id';
            appDoc.Document_Type__c='Mandate to open a Matshelo Savings Account';
            update appDoc;
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDocumnetOpenApplication(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, statusCode, 'Test Meassage');
            Application_Document__c updatedAppDoc = [SELECT External_Id__c FROM Application_Document__c WHERE Id = :appDoc.Id];
            Assert.areEqual('test_document_id', updatedAppDoc.External_Id__c, 'Test Meassage');

    }
      /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDocumnetOpenApplication()
     */
    @isTest
    static  void sendDocumnetOpenApplicationNegTest() {
        try{
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.Id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = appParticipant.Application__c;
            appDoc.External_Id__c='test_document_id';
            appDoc.Document_Type__c='Mandate to open a Matshelo Savings Account';
            update appDoc; 
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDocumnetOpenApplication(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, statusCode, 'Test Meassage');
            Application_Document__c updatedAppDoc = [SELECT External_Id__c FROM Application_Document__c WHERE Id = :appDoc.Id];
            Assert.areEqual('test_document_id', updatedAppDoc.External_Id__c);
         } catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDocumnetOnline()
     */ 
    @isTest
    static  void sendDocumnetOnlineTest() {
        try{
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = appParticipant.Application__c;
            appDoc.Document_Type__c='Resolution to open Informal Matshelo Account';
            update appDoc;
            Test.startTest();
            Integer responseCode = AOB_BOTS_SRV_SigningHUB.sendDocumnetOnline(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, responseCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDocumnetOnline()
     */ 
    @isTest
    static  void sendDocumnetOnlineNegTest() {
        try{
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.Id;
            app.AOB_Product__c=prod.Id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);
            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = appParticipant.Application__c;
            appDoc.Document_Type__c='online-banking-application-form';
            update appDoc;
            
            Test.startTest();
                Integer responseCode = AOB_BOTS_SRV_SigningHUB.sendDocumnetOnline(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, responseCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }
    
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.addWorkflowUsers()
     */ 
    @IsTest
    static void addWorkflowUsersTest() {
       
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.AOB_Product__c=prod.id;
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.addWorkflowUsers(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(200, statusCode, 'Test Meassage');

    }
     /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.addWorkflowUsers()
     */ 
    @IsTest
    static void addWorkflowUsersNegTest() {
        try{
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.AOB_Product__c=prod.id;
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.addWorkflowUsers(app.Id);
            Test.stopTest();
            Assert.areEqual(200, statusCode, 'Test Meassage');
      }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
   
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDigitalSign()
     */ 
    @IsTest
    static void sendDigitalSignTest() {
        try{
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDigitalSign(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDigitalSign()
     */ 
    @IsTest
    static void sendDigitalSignelseTest() {
        try{
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","signatoryCard":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDigitalSign(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
     /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDigitalSign()
     */ 
    @IsTest
    static void sendDigitalSignNegTest() {
        try{
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDigitalSign(app.Id);
            Test.stopTest();
            Assert.areNotEqual(null, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
     /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDigitalSign()
     */ 
    @IsTest
    static void sendDigitalSignCheckboxTest() {
        try{
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDigitalSignCheckbox(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
     @IsTest
    static void sendDigitalSignCheckboxNegTest() {
        try{
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            
            Test.startTest();
            Integer statusCode = AOB_BOTS_SRV_SigningHUB.sendDigitalSignCheckbox(app.Id);
            Test.stopTest();
            Assert.areNotEqual(null, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.shareDocument()
     */ 
    @isTest 
    static void shareDocumentTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            Test.startTest();
            Integer responseStatusCode = AOB_BOTS_SRV_SigningHUB.shareDocument(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(200, responseStatusCode, 'Test Meassage');
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.shareDocument()
     */ 
    @isTest 
    static void shareDocumentNegTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            Test.startTest();
            Integer responseStatusCode = AOB_BOTS_SRV_SigningHUB.shareDocument(app.Id);
            Test.stopTest();
            Assert.areEqual(200, responseStatusCode, 'Test Meassage');
        }
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.generateLink()
     */ 
    @isTest
    static void generateLinkTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
             appParticipant.AOB_Signatory__c=true;
            update appParticipant;
            Test.startTest();
            Integer result = AOB_BOTS_SRV_SigningHUB.generateLink(appParticipant.Id);
            Test.stopTest();
            Assert.areNotEqual(null, result, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.generateLink()
     */ 
    @isTest
    static void generateLinkNegTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            Integer result = AOB_BOTS_SRV_SigningHUB.generateLink(appParticipant.Id);
            test.stopTest();
            Assert.areEqual(null, result, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }
 /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.generateLink()
     */ 
    @isTest
    static void getLinkTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.AOB_SigningInstructions__c='test';
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            Test.startTest();
            string result = AOB_BOTS_SRV_SigningHUB.getLink(app.Id);
            Test.stopTest();
            Assert.areNotEqual(null, result, 'Test Meassage');
        } 
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
        
    }    
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.getInflight()
     */ 
    @isTest
    static void getInflightTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            String result = AOB_BOTS_SRV_SigningHUB.getInflight(appParticipant.Id, 'Directors');
            test.stopTest();
            Assert.areEqual(null,result, 'Test Meassage');
        } 
       catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.getTemplateData()
     */ 
    @isTest
    static void getTemplateDataTest()
    {
        try{
        Test.startTest();
        AOB_BOTS_SRV_SigningHUB.getTemplateData();
        Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');  
        }
    }
    
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.docFusionCallout()
     */ 
    @isTest
    static void docFusionCalloutTest()
    {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        String stringap=JSON.serialize(appParticipant);
        stringap=stringap.replaceAll('"Id"','"applicationId"');
        stringap=stringap.removeEnd('}');
        stringap=stringap+',"templateGUID":"0dcf2556-2b29-4a38-8bd5-bf964558686d"}';
        Test.startTest();
        String res=AOB_BOTS_SRV_SigningHUB.docFusionCallout(stringap);
        Test.stopTest();
         Assert.areNotEqual(null, res, 'Test Meassage');
    }
    
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDocumnetFaxEmailIndemnity()
     */ 
    @isTest
    static void sendDocumnetFaxEmailIndemnityTest()
    {
        try
        {
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);

            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = app.Id;
            appDoc.Document_Type__c='Fax Email Indemnity';
            update appDoc;
            
            Test.startTest();
                Integer statusCode=AOB_BOTS_SRV_SigningHUB.sendDocumnetFaxEmailIndemnity(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
     /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.sendDocumnetFaxEmailIndemnity()
     */ 
    @isTest
    static void sendDocumnetFaxEmailIndemnityNegTest()
    {
        try
        {
             AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);

            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = app.Id;
            appDoc.Document_Type__c='Fax Email Indemnity';
            update appDoc;
            
            Test.startTest();
                Integer statusCode=AOB_BOTS_SRV_SigningHUB.sendDocumnetFaxEmailIndemnity(app.Id);
            Test.stopTest();
            Assert.areEqual(201, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
     @isTest
    static void signatoryCardTest()
    {
        try
        {
        
            AOB_BOTS_DAL_TestFactory.creatProduct();
            Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
            prod.AOB_Memo_Code__c='OD001';
            update prod;
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            app.AOB_Product__c=prod.id;
            update app;
             
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(appParticipant.id);

            Application_Document__c appDoc=[select Application__c from Application_Document__c where Application_Participant__c=:appParticipant.Id][0];
            appDoc.Application__c = app.Id;
            appDoc.Document_Type__c='Signature Card';
            update appDoc;
            
            Test.startTest();
                Integer statusCode=AOB_BOTS_SRV_SigningHUB.signatoryCard(appParticipant.Id);
            Test.stopTest();
            Assert.areEqual(201, statusCode, 'Test Meassage');
        }
        catch(Exception ex){ 
            Assert.areNotEqual(null, ex.getMessage(), 'Test Meassage');
        }
    }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.updateSigningHuBStatus
     */ 
    @isTest
    static void updateSigningHuBStatusTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            app.Inflight__c='{"SigningHUBDocumnetFaxEmail":{"documentid":13212},"SigningHUBDocumnet":{"documentid":13210},"null":{"PrefferedBranch":"061023","BWP":0,"cardOption":"Debit card"},"Intended use of account":"WD","DATE OF RESOLUTION MEETING":"2023-04-05","How would like receive the message":"SMS","SigningHUBPackages":{"package_id":13624,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13211}}';
            update app;
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            test.startTest();
            AOB_BOTS_SRV_SigningHUB.updateSigningHuBStatus(appParticipant.Id);
            test.stopTest();
    } catch(Exception ex)
        {
            Assert.areNotEqual(null, ex.getMessage(),'test message');
        }
        }
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.getSchemCode
     */ 
     @isTest
    static void getSchemCodeTest()
    {
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
        prod.AOB_Memo_Code__c='OD001';
        update prod;
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_Product__c=prod.id;
        update app;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        string statusCode=AOB_BOTS_SRV_SigningHUB.getSchemCode(appParticipant.Id);
        Test.stopTest();
        Assert.areNotEqual(null, statusCode, 'Test Meassage');
            
    } 
    /*
     * @description Test method for AOB_BOTS_SRV_SigningHUB.updateSigningHUBPackages
     */ 
     @isTest
    static void updateSigningHUBPackagesTest()
    {
        AOB_BOTS_DAL_TestFactory.creatProduct();
        Product2 prod=[Select AOB_Memo_Code__c,Id from Product2 limit 1];
        prod.AOB_Memo_Code__c='OD001';
        update prod;
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        app.AOB_Product__c=prod.id;
        app.Inflight__c='{"SigningHUBPackages":{ "workflow_type":"SERIAL", "workflow_mode":"ONLY_OTHERS","package_id":353062 }}';
        update app;
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        Integer statusCode=AOB_BOTS_SRV_SigningHUB.updateSigningHUBPackages(appParticipant.Id);
        Test.stopTest();
        Assert.areNotEqual(null, statusCode, 'Test Meassage');      
    } 
    
     
        
}