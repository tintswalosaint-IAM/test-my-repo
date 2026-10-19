/**
* @author            : Ihtishaam Mohammoodally
* @description       : TestClass for InsurancePolicyStatusBatch [SFP-29010]
* @date 			  : 10-01-2024
**/

@isTest(SeeAllData = false)
public class InsurancePolicyStatusBatchTest {
    
    @TestSetup
    private static void buildTestData(){
        Account account = createAccount();
        InsurancePolicy expiredPolicy = createInsurancePolicy(account,'0002',null);
        
        Id batchJobId = Database.executeBatch(new InsurancePolicyStatusBatch(), 200);
        
    }
    
    @isTest
    private static void testBatch (){        
        Test.startTest();
            InsurancePolicy expiredPolicy = [Select Id,ExpirationDate,Status From InsurancePolicy where Name = '0002'limit 1];
            Assert.isNotNull(expiredPolicy.Status, 'Expired');
        Test.stopTest();  
    }
    
    private static InsurancePolicy createInsurancePolicy(Account account,String Name,InsurancePolicy parentPolicy){
        InsurancePolicy originalPolicy = new InsurancePolicy(
                                                        NameInsuredId  = account.Id,
                                                        RecordTypeId  =  Schema.getGlobalDescribe()
                                                                                    .get('InsurancePolicy').getDescribe()
                                                                                    .getRecordTypeInfosByDeveloperName()
                                                                                    .get('Short_Term_Insurance').getRecordTypeId(), //Get RecordType Id
                                                       	Name = Name,
                                                        ExternalCountry__c = 'ZA',
                                                        Status =  'In Force',
                                                        ExpirationDate =  System.today().addDays(-1),
                                                        RenewalDate = System.today().addDays(20),
            											DateRenewed = parentPolicy != null ? System.today() : null,
            											RenewedFromPolicyId = parentPolicy?.Id
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
}