/**
* @description Test class for AOB_BOTS_CTRL_CallWelComeLetter
* 
* @author dayakar
* 
* @date June 30th 2023 
*/
@IsTest
public class AOB_BOTS_CTRL_CallWelComeLetterTest {
    /**
    * @description Test method for AOB_BOTS_CTRL_CallWelComeLetter.deleteAllfils
    */
    @IsTest
    public static void callWelComeLetterTest(){
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        Test.startTest();
        System.enqueueJob(new AOB_BOTS_CTRL_CallWelComeLetter(app.Id));
        Test.stopTest();
        Assert.areNotEqual(null, app, 'Test Message');
        Assert.areEqual('BW00001881348', [SELECT Id, AOB_RegistrationNumber__c FROM Application__c WHERE Id = :app.Id].AOB_RegistrationNumber__c, 'Test Message');
        Assert.areNotEqual(null, appParticipant, 'Test Message');
        
    }
    
}