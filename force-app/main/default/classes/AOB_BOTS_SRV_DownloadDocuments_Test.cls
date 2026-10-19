/**
* @description test class for AOB_BOTS_SRV_DownloadDocuments
*
* @author Dayakar Deekonda
*
* @date June 6th
*/
@isTest
public class AOB_BOTS_SRV_DownloadDocuments_Test {
    
    /**
    * @description Test method for AOB_BOTS_SRV_DownloadDocuments.getapplicationId
    */
    @isTest
    static void getapplicationIdTest() {
        try{
         Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
         Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
         String appParticipantId = AOB_BOTS_SRV_DownloadDocuments.getapplicationId(appParticipant.Id);
         Assert.areEqual(appParticipant.Id, appParticipantId);
        }
        catch(Exception e)
        {
            Assert.areNotEqual(null, e);
        }
    } 
    
    /**
    * @description Test method for AOB_BOTS_SRV_DownloadDocuments.downloadDocuments
    */
    @IsTest
    public static void downloadDocuments_Test(){
        try{
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
            AOB_BOTS_SRV_DownloadDocuments.downloadDocuments(appParticipant.Id);
            Test.stopTest();     
        }catch(Exception e){
            Assert.areNotEqual(null, e);
        }
    }

}