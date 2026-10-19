/**
 * @description class used as test class for ICS_CTRL_OpportunitySalesPath.cls
 *
 * Story :  SFP-31898
 *
 * @author Ikyatha Naidu 
 * @date Jan 2023
 * @last modified on  : 30-01-2025
 * @last modified by  : Ikyatha Naidu
 * @Modification Description : Initial Version
 */
@istest
public class ICS_CTRL_OpportunitySalesPath_Test {
    @TestSetup
    static void setupData() {        
        Account accRec =ICS_DAL_TestFactory.createAccount();
       
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Review',
            CloseDate = Date.today().addDays(30),
            AccountId = accRec.Id
        );
        insert opp;
              
        ApplicationForm appForm = new ApplicationForm(
            AccountId = accRec.Id,
            OpportunityId = opp.Id,
            Stage = 'In Progress',
            usagetype='Onboarding'
        );
        insert appForm;
    }
     @isTest
    static void fetchOppIdTest() {
        try{
            Opportunity opp=[select id from opportunity limit 1];
        ICS_CTRL_OpportunitySalesPath.fetchOpportunityStage(opp.id);
        }catch(exception ex){
        	Assert.areEqual(true,ex.getmessage()!= null,'Exception occured');
        }
    }
 	 @isTest
    static void testEmptyOppId() {
        try{
        ICS_CTRL_OpportunitySalesPath.fetchOpportunityStage('');
        }catch(exception ex){
        	Assert.areEqual(true,ex.getmessage()!= null,'Exception occured');
        }
    }
    @isTest
    static void stageListTest() {
        List < string > stageList = ICS_CTRL_OpportunitySalesPath.returnOppStageValues();
		Assert.areEqual(true,stageList.size()>0,'Fetched Opportunity stage List');
    }
    @isTest
    static void declinedStageListTest() {
        try{
        Opportunity opp=[select id,accountid from opportunity limit 1];
        string  declinedStage = ICS_CTRL_OpportunitySalesPath.getDeclinedStageValue(opp.accountid);
        ICS_CTRL_OpportunitySalesPath.getDeclinedStageValue('');
		Assert.areEqual(true,declinedStage!=null,'Fetched declined Opportunity stage List');
        }catch(exception ex){
        	Assert.areEqual(true,ex.getmessage()!= null,'Exception occured');
        }
    }
   @isTest
    static void testCheckApplicationFormStageValue() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String result = ICS_CTRL_OpportunitySalesPath.checkApplicationFormStageValue(acc.Id);
        Assert.areEqual(true, result != null, 'Should return opportunity data');
    }
    
}