/**
* @description Test class for AOB_BOTS_CTRL_PreApplication_TEST
* @author Dayakar Deekondas
* @date Jan 3rd 2023
*/
@isTest
public class AOB_BOTS_CTRL_PreApplication_TEST { 
    /**
    * @description Test method for AOB_BOTS_CTRL_PreApplication.saveParticipants
    */
    @isTest
    public static void saveParticipantsTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        String iString = JSON.serialize(new List<Application_Participant__c>{appParticipant});
        String result = AOB_BOTS_CTRL_PreApplication.saveParticipants(iString);
        List<Application_Participant__c> participants = (List<Application_Participant__c>)JSON.deserialize(result,List<Application_Participant__c>.class);
        Assert.areEqual(1, participants.size());
    } 
    /**
    * @description Test method for AOB_BOTS_CTRL_PreApplication.saveParticipants
    */
    @isTest
    public static void saveParticipantsFailTest() {
        try{
            Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
            Application_Participant__c appParticipant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
            String iString = JSON.serialize(new List<Application_Participant__c>{appParticipant});
            String result = AOB_BOTS_CTRL_PreApplication.saveParticipants(ApexPages.currentPage().getParameters().get('iString'));
            List<Application_Participant__c> participants = (List<Application_Participant__c>)JSON.deserialize(result,List<Application_Participant__c>.class);
            Assert.areEqual(1, participants.size());
        }
        catch(Exception ex)
        {
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    
    
}