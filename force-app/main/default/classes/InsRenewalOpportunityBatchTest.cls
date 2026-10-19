/**
* @author            : Ihtishaam Mohammoodally
* @description       : TestClass for InsRenewalOpportunityBatch [SFP-29010]
* @date 			  : 10-01-2024
**/

@isTest(SeeAllData = false)
public class InsRenewalOpportunityBatchTest {

    @TestSetup
    private static void buildTestData(){
        Account account = createAccount();
        ActionPlanTemplate actionTemplate = createActionTemplate(); 

        ActionPlanTemplateVersion actionTemplateVersion = [Select Id,Status,ActionPlanTemplateId From ActionPlanTemplateVersion where ActionPlanTemplateId =: actionTemplate.Id];
        ActionPlanTemplateItem actionPlanTemplateItem = createActionPlanTemplateItem(actionTemplateVersion);

        actionTemplateVersion.Status = 'Final';
        Database.Update(actionTemplateVersion);
        
        InsurancePolicy originalPolicy = createInsurancePolicy(account,'0001');
        InsurancePolicy insuranceErrorPolicy = createInsurancePolicy(account,'0001/3');
        

        
        InsurancePolicyParticipant insurancePolicyParticipant = new InsurancePolicyParticipant(
                                                                                InsurancePolicyId = originalPolicy.Id,
                                                                                Role = 'Driver');
        Database.insert(insurancePolicyParticipant);
        
        
        InsurancePolicyAsset insuredItem = new InsurancePolicyAsset(
                                                        InsurancePolicyId = originalPolicy.Id,
        												PrimaryPolicyParticipantId  = insurancePolicyParticipant.Id);
        Database.insert(insuredItem);
        
        
        InsurancePolicyCoverage insurancePolicyCoverage = new InsurancePolicyCoverage();
        insurancePolicyCoverage.InsurancePolicyId = originalPolicy.Id;
        Database.insert(insurancePolicyCoverage);
        
               
       Id batchJobId = Database.executeBatch(new InsRenewalOpportunityBatch(), 200);
    } 
    
    @isTest
    private static void testBatch (){        
        Test.startTest();
            InsurancePolicy renewedPolicy = [Select Id,RenewalDate From InsurancePolicy where Name = '0001/1'limit 1];
            Assert.isNotNull(renewedPolicy.Id, 'Renewal Policy Created'); // Succeeds
        Test.stopTest();   
        
    }
    
     @isTest
    private static void testBatchWithPostFix(){
        InsurancePolicy renewedPolicy = [Select Id,RenewalDate From InsurancePolicy where Name = '0001/4'limit 1];
        Assert.isNotNull(renewedPolicy.Id, 'Renewal Policy Created'); // Succeeds        
    }
    
    
    private static InsurancePolicy createInsurancePolicy(Account account,String Name){
        InsurancePolicy originalPolicy = new InsurancePolicy(
                                                        NameInsuredId  = account.Id,
                                                        RecordTypeId  =  Schema.getGlobalDescribe()
                                                                                    .get('InsurancePolicy').getDescribe()
                                                                                    .getRecordTypeInfosByDeveloperName()
                                                                                    .get('Short_Term_Insurance').getRecordTypeId(), //Get RecordType Id
                                                       	Name = Name,
                                                        ExternalCountry__c = 'ZA',
                                                        Status =  'In Force',
                                                        ExpirationDate =  System.today(),
                                                        RenewalDate = System.today().addDays(20) 
        );
        
        Database.insert(originalPolicy);
        return originalPolicy;
    }
    
    
    private static Account createAccount(){
        Account account = new Account();
        account.RecordTypeId = Schema.getGlobalDescribe()
            					.get('Account').getDescribe()
            					.getRecordTypeInfosByDeveloperName()
            					.get('PersonAccount').getRecordTypeId(); //Get RecordType Id
        
        account.FirstName = 'Test';
        account.LastName = 'Test';
        Database.insert(account);
        
        return account;
    }
    
    private static ActionPlanTemplate createActionTemplate(){
        ActionPlanTemplate actionTemplate = new ActionPlanTemplate();       
        actionTemplate.Name = 'Insurance Renewal';
        actionTemplate.TargetEntityType = 'Opportunity';
        actionTemplate.ActionPlanType = 'Industries';
        Database.insert(actionTemplate);
        return actionTemplate;
        
    }
    
    private static ActionPlanTemplateItem createActionPlanTemplateItem (ActionPlanTemplateVersion actionTemplateVersion){
        
        ActionPlanTemplateItem actionPlanTemplateItem = new ActionPlanTemplateItem (
                                                                                    ActionPlanTemplateVersionId = actionTemplateVersion.Id,
                                                                                    Name = 'Renewal Notice Received',
                                                                                    ItemEntityType = 'Task'        
        																			);
        
        Database.insert(actionPlanTemplateItem);
        return actionPlanTemplateItem;
        
    }
}