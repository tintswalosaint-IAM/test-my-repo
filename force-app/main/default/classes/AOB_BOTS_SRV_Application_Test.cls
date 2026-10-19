/***************************************************************************************
@Name of the Class :AOB_BOTS_SRV_Application_Test
@Description : Test Class for AOB_BOTS_SRV_Application_Test.	
@Author :Dayakar
@Created Date :sept 13th 2024
***************************************************************************************/
@IsTest
public class AOB_BOTS_SRV_Application_Test {
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> {Application__c.SObjectType, Application_Participant__c.SObjectType,ContentVersion.SObjectType,Application_Document__c.SObjectType });
    
    @testSetup
    static void setup() {
        Application__c app= AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c aps= AOB_BOTS_DAL_TestFactory.createAppParticipant(app.id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(aps.id); 
    } 
    /**
     * @description test method AOB_BOTS_SRV_Application.saveApp
     */
    @Istest
    public static void saveAppTest(){
        Application__c apps = [select Id,AOB_RegistrationNumber__c from Application__c Limit 1];
        Test.startTest();
        new AOB_BOTS_SRV_Application().saveApp(new List<Application__c>{apps},uow);
        Test.stopTest();
        Assert.areEqual(apps.AOB_RegistrationNumber__c,'BW00001881348','RegistrationNumber should match excpected one');
       
    }
    
    /**
     * @description test method AOB_BOTS_SRV_Application.saveApplnParticipants
     */
    @Istest
    public static void saveApplnParticipantsTest(){
        Application_Participant__c apps = [select Id,CNGCU_Email__c from Application_Participant__c Limit 1];
        Test.startTest();
        new AOB_BOTS_SRV_Application().saveApplnParticipants(new List<Application_Participant__c>{apps},uow);
        Test.stopTest();
        Assert.areEqual(apps.CNGCU_Email__c,'test@example.com','Email should match excpected one');
    }
    
    /**
     * @description test method AOB_BOTS_SRV_Application.saveApplnDocuments
     */
    @Istest
    public static void saveApplnDocumentsTest(){
        Application_Document__c doc = [select Id from Application_Document__c Limit 1];
        Test.startTest();
        AOB_BOTS_SRV_Application.newInstance().saveApplnDocuments(null, null, new List<Application_Document__c>{doc},uow);
        Test.stopTest();
        Assert.areNotEqual(doc,null,'Checking the  document not null');
    }
    
    /**
     * @description test method AOB_BOTS_SRV_Application.saveDocuments
     */
    @Istest
    public static void saveDocumentsTest(){
        ContentVersion conv = [select Id,Title from ContentVersion Limit 1];
        Test.startTest();
        new AOB_BOTS_SRV_Application().saveDocuments(null, new List<ContentVersion>{conv}, uow);
        Test.stopTest();
        Assert.areEqual(conv.Title,'My Document','Title should match excpected one');
    }
    
    
}