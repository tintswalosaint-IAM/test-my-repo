/**
* @description Test class for AOB_BOTS_CTRL_Directories
* @author dayakar
* @date Jan 25th 2023 
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test methods
*/
@istest
public class AOB_BOTS_CTRL_Directories_Test {
   /*
* @description Test method for AOB_BOTS_CTRL_Directories.isSignatory;
*/    
 @isTest
    static void isSignatoryTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        participant.AOB_Signatory__c=true;
        update participant;
        
        Test.startTest();
        Boolean result=AOB_BOTS_CTRL_Directories.isSignatory(participant.Id);
        Test.stopTest();
       Assert.areEqual(true,result, 'Test Meassage');
    }
     /*
* @description Test method for AOB_BOTS_CTRL_Directories.isNewDirector;
*/    
 @isTest
    static void isNewDirectorTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        participant.AOB_Signatory__c=true;
        update participant;
        Test.startTest();
        Boolean result=AOB_BOTS_CTRL_Directories.isNewDirector(participant.Id);
        Test.stopTest();
       Assert.areEqual(true,result, 'Test Meassage');
    }
     @isTest
    static void checkKeyContactTest() {
        Application__c app = AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c participant = AOB_BOTS_DAL_TestFactory.createAppParticipant(app.Id);
        participant.AOB_Signatory__c=true;
        update participant;
        Test.startTest();
        Boolean result=AOB_BOTS_CTRL_Directories.checkKeyContact(participant.Id);
        Test.stopTest();
        Assert.areEqual(true,result, 'Test Meassage');
    }
}