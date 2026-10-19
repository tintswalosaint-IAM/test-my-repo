/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :CMN_Email_Send_Test
@description       :Test Class for dealing with AccountCreation api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-25770
***************************************************************************************/
@isTest
public class CMN_Email_Send_Test {
    /**
* @description TestMethod for CMN_Email_Send.sendEmailWithTemplate
*
*/
    @isTest
    static void callInvocable(){
        List<Application_Participant__c> participationList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert participationList;
        test.startTest();
        try{        
            CMN_Email_Send.sendEmailWithTemplate(participationList[0],'abcd');   
            
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
        test.stopTest();
        Assert.areNotEqual(null, participationList,'Test'); 
    }
    /**
* @description TestMethod for BCB_ECMN_Email_Send mail_Send.sendEmailTemplateWithTemplate
*
*/
    @isTest
    static void callInvocable1(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].CNGCU_CSEmail__c = 'test@test.com';
        insert applicationList;
        test.startTest();
        try{        
            CMN_Email_Send.sendEmailTemplateWithTemplate(applicationList);   
            
        }catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'Test'); 
        }
        Assert.areNotEqual(null, applicationList,'Test');
    }
}