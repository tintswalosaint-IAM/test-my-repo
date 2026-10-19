/***************************************************************************************
@Name of the Class :AOB_BOTS_SRV_ApplicationParticipant_Test
@Description : Test Class for AOB_BOTS_SRV_ApplicationParticipant	
@Author :Dayakar
@Created Date :sept 13th 2024
***************************************************************************************/
@IsTest
public class AOB_BOTS_SRV_ApplicationParticipant_Test {
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> {Application__c.SObjectType, Application_Participant__c.SObjectType,ContentVersion.SObjectType,Application_Document__c.SObjectType });
    
    @testSetup
    static void setup() {
        Application__c app= AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c aps= AOB_BOTS_DAL_TestFactory.createAppParticipant(app.id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(aps.id); 
    } 
    /**
     * @description test method AOB_BOTS_SRV_Application.saveAppParticipant
     */
    @Istest
    public static void saveAppParticipantTest(){
        Application_Participant__c participant =  [select Id,CNGCU_Email__c from Application_Participant__c Limit 1];
        Test.startTest();
        AOB_BOTS_SRV_ApplicationParticipant.newInstance();
        new AOB_BOTS_SRV_ApplicationParticipant().saveAppParticipant(new List<Application_Participant__c>{participant},uow);
        Test.stopTest();
        Assert.areEqual(participant.CNGCU_Email__c,'test@example.com','Email should match excpected one');
    }
    
    /**
     * @description test method AOB_BOTS_SRV_Application.getValueByFieldLabel
     */
    @Istest
    public static void getValueByFieldLabelTest(){
        Application_Participant__c participant =  new Application_Participant__c();
        participant.Inflight__c='{\r\n    \"test\": \"Apple\"\r\n}';
        Test.startTest();
        Object obj=new AOB_BOTS_SRV_ApplicationParticipant().getValueByFieldLabel(participant,'test');
        Test.stopTest();
        Assert.areEqual(obj,'Apple','Object should match excpected one');
    }
    
    
    /**
     * @description test method AOB_BOTS_SRV_Application.getValueByFieldLabel
     */
    @Istest
    public static void getValueByFieldLabelNegTest(){
        Application_Participant__c participant =  new Application_Participant__c();
        participant.Inflight__c='{\r\n    \"test\": \"Apple\"\r\n}';
        Test.startTest();
        Object obj=new AOB_BOTS_SRV_ApplicationParticipant().getValueByFieldLabel(null,null);
        Test.stopTest();
        Assert.areEqual(obj,null,'Object should match excpected one');
    }
    

}