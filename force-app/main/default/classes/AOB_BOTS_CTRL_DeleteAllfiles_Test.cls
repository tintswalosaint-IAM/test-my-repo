/**
* @description Test class for AOB_BOTS_CTRL_DeleteAllfiles
* 
* @author dayakar
* 
* @date Jan 25th 2023 
*/
@isTest
public class AOB_BOTS_CTRL_DeleteAllfiles_Test {
/**
* @description Test method for AOB_BOTS_CTRL_DeleteAllfiles.deleteAllfils
*/
@isTest
    public static void deleteAllfilsTest(){
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AOB_BotswanaBCC').getRecordTypeId();
        Application__c app = new Application__c();
        app.AOB_BusinessLegalName__c = 'Nit Legal Associates';
        app.Inflight__c = '{"RelyStatusList":[{"complete":"true","customerId":"20243156","Status":"AcceptableRisk"},{"complete":"true","customerId":"20243154","Status":"AcceptableRisk"}],"createAssementRely":["1271359","1271360"],"createCustomerRely":{"upsertCustomers":{"customers":[{"created":true,"customer":{"id":"20243156","identifier":"145746af-bcc2-ff7e-2dae-05ec0636b2b3"}}]}},"SigningHUBDocumnetFaxEmail":{"documentid":13191},"SigningHUBDocumnet":{"documentid":13189},"null":{"cardOption":"Debit card","BWP":0,"PrefferedBranch":"062096"},"SigningHUBPackages":{"package_id":13617,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13190},"createBusinessRely":{"createCustomer":{"customer":{"id":"20243154","created":"2023-04-05T10:06:03.654254+00:00","identifier":"233876e6-16fa-b0dc-f190-cd17668f3986","businessName":"test"}}}}';
        app.AOB_RegistrationNumber__c = 'BW12345678779';
        app.RecordTypeId=recordTypeId;
        app.AOB_GUID__c = 'BW12345678779';
        app.Status__c='Complete';
        insert app;
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(participant.id);
        
        Application_Document__c appDoc = new Application_Document__c(Application__c = app.id);
        insert appDoc;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id,ContentDocumentId,VersionData  FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = appDoc.Id;
        insert cdl;
        
        Test.startTest();
        SchedulableContext sc = null;
        AOB_SCHED_DeleteAllfiles tsc = new AOB_SCHED_DeleteAllfiles();
        tsc.execute(sc);
        Test.stopTest();
        Assert.areNotEqual(null, tsc, 'Test Message');
        List<ContentDocumentLink> contentDocList =  [SELECT Id,ContentDocumentId,LinkedEntityId  FROM ContentDocumentLink WHERE LinkedEntityId =:appDoc.Id];
        Assert.areEqual(0, contentDocList.size(), 'Test Message');

      }
}