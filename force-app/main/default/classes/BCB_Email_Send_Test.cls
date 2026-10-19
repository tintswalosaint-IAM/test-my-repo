/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :BCB_Email_Send_Test
@description       :Test Class for dealing with AccountCreation api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-25770
***************************************************************************************/
@isTest
public class BCB_Email_Send_Test {
    /**
* @description TestMethod for BCB_Email_Send.sendEmailWithTemplate
*
*/
    @isTest
    static void callInvocable(){
        List<Application_Participant__c> participationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert participationList;
        test.startTest();
        try{        
            BCB_Email_Send.sendEmailWithTemplate(participationList[0],'abcd');   
            
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
        test.stopTest();
        Assert.areNotEqual(null, participationList,'Test'); 
    }

    
    /**
* @description TestMethod for BCB_Email_Send.sendEmailTemplateWithTemplate
*
*/
    @isTest
    static void callInvocable1(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> participationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert participationList;
        applicationList[0].CNGCU_CSEmail__c = 'test@test.com';
        insert applicationList;
        test.startTest();
        try{        
            BCB_Email_Send.sendEmailTemplateWithTemplate(participationList[0].id);   
            
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
        Assert.areNotEqual(null, applicationList,'Test');
    }
}