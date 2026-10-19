/***************************************************************************************
@name of the Class : ICS_CTRL_ApplicationFormCancel_Test.cls
@Story:SFP-34733
@description :Testclass used to cover the ICS_CTRL_ApplicationFormCancel class
@author : RIDHIMA SAXENA
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Tushar Walse
@last Modified On : 26-11-2024
@modification description: Updated to latest version
***************************************************************************************/
@istest
public class ICS_CTRL_ApplicationFormCancel_Test  {
   /**
   * @description This method is used creating setup data
   */
    @isTest
    static void saveCancelFeedbackTest() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        Account acc = ICS_DAL_TestFactory.createAccount();
        Opportunity opportunity = ICS_DAL_TestFactory.createOpportunity(acc.Id);
        ICS_DAL_TestFactory.triggerApprovalRequest(opportunity);
        string data = ' {"Please let us know why you are leaving us?":"Lost to competitor", "Competitor name":"dsad"}';
        string data1 = ' {"Please let us know why you are leaving us?":"Other reason", "Please provide details":"dsad"}';
        string data2 = ' {"Please let us know why you are leaving us?":"Lost to competitor", "Competitor name":"Other"}';
        string data3 = ' {"Please let us know why you are leaving us?":"Lost to competitor", "Competitor name":"FNB"}';
        ICS_CTRL_ApplicationFormCancel.saveCancelFeedback(acc.Id, data);
        Test.startTest();
        system.runas(commUser) {
          
                ICS_CTRL_ApplicationFormCancel.saveCancelFeedback(acc.Id, data1);
                ICS_CTRL_ApplicationFormCancel.saveCancelFeedback(acc.Id, data2);
                ICS_CTRL_ApplicationFormCancel.saveCancelFeedback(acc.Id, data3);
           
        }
        Opportunity updatedOpportunity = [SELECT Id, StageName, Loss_Reason__c, Other_Loss_Reason__c, ICS_Competitors__c, ICS_Other_Competitor__c 
        FROM Opportunity WHERE Id = :opportunity.Id];

        // Assert the values set by the method
        Assert.areEqual('Closed Lost', updatedOpportunity.StageName, 'Opportunity stage should be updated to "Closed Lost"');
        Assert.areEqual('FNB', updatedOpportunity.ICS_Competitors__c, 'ICS_Competitors__c should not be set for "Other" competitor');
        Test.stopTest();
        
    }
}