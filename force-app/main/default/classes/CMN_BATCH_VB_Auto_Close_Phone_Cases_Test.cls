/**
 * @description       : Test Class for CMN_BATCH_VB_Auto_Close_Phone_Cases
 * @author            : Sandile Mathe
 * @group             : Voice Branch
 * @Created on        : 06-03-2025
**/
@isTest
public class CMN_BATCH_VB_Auto_Close_Phone_Cases_Test {
        
   @testSetup
    static void setupTestData() {
        Id testAccountId = CMN_BATCH_VB_Auto_Close_TestDataFactory.createTestAccount();
        CMN_BATCH_VB_Auto_Close_TestDataFactory.createTestServiceType();
        CMN_BATCH_VB_Auto_Close_TestDataFactory.createTestCases(5, testAccountId);
    }

    @isTest
    static void testBatchExecution() {
        User testUser = CMN_BATCH_VB_Auto_Close_TestDataFactory.insertTestUser();
        // Verify initial state
        List<Case> casesBefore = [SELECT Id, AccountId, Status,CreatedDate,SVC_ReasonForBreach__c FROM Case WHERE Status = 'New'];
        Assert.areEqual(5, casesBefore.size(), 'There should be 5 test cases before batch execution.');
        
        // Instantiate the batch job
        CMN_BATCH_VB_Auto_Close_Phone_Cases batchJob = new CMN_BATCH_VB_Auto_Close_Phone_Cases(); 
        Database.executeBatch(batchJob, 200);
 
        Test.startTest();
    		System.runAs(testUser) {
            batchJob.execute(null,casesBefore);  
           
        }
        Test.stopTest();

        // Verify Cases are updated
        List<Case> casesAfter = [SELECT Id, Status, SVC_RootCauseResolution__c,AccountId,SVC_ReasonForBreach__c FROM Case WHERE Id IN :casesBefore];
        
        for (Case c : casesAfter) {
            Assert.areEqual('Closed', c.Status, 'Case status should be updated to Closed.');
            Assert.areEqual(5, casesAfter.size(), 'Processed 5 Cases and updated');
            Assert.areEqual('Auto Closed due to case being automatically created through Amazon Connect Phone to Case, SR logged on Customer1st',
                                c.SVC_RootCauseResolution__c, 'Root Cause Resolution should be updated.');
        }
    }
    
    @IsTest
    private static void testBatchExecuteMethod() {
      
        Test.startTest();
        
        CMN_BATCH_VB_Auto_Close_Phone_Cases batchJob = new CMN_BATCH_VB_Auto_Close_Phone_Cases();
        batchJob.execute(null);
        
        Test.stopTest();
         AsyncApexJob job = [SELECT Id, Status, JobType FROM AsyncApexJob 
                        WHERE JobType = 'BatchApex' 
                        ORDER BY CreatedDate DESC LIMIT 1];

         Assert.areNotEqual(null, job, 'Batch job was not scheduled.');
   		 Assert.areEqual('Completed', job.Status, 'Batch job did not complete successfully.');      
    }
    
    
    @isTest
    static void testMissingServiceType_ThrowsException() {
        // Delete all service types so the constructor fails
        delete [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'General Enquiry'];

        Test.startTest();
        Boolean caught = false;

        try {
            new CMN_BATCH_VB_Auto_Close_Phone_Cases();
        } catch (CMN_BATCH_VB_Auto_Close_Phone_Cases.BatchableException ex) {
            caught = true;
        }

        Test.stopTest();

        Assert.areEqual(true,caught, 'Expected BatchableException was not thrown.');
    }
    
    @isTest
    static void testExecuteCatchBlock() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Insert the failing case
        Case failCase = CMN_BATCH_VB_Auto_Close_TestDataFactory.createCaseForDMLException(acc.Id);
        
        Boolean exceptionCaught = false;

        Test.startTest();
        try{
            insert failCase;
			Database.executeBatch(new CMN_BATCH_VB_Auto_Close_Phone_Cases(), 1);	
				            
        }catch(Exception e){
            exceptionCaught = true;
        }
        
        Test.stopTest();

        Assert.areEqual(true,exceptionCaught, 'Catch block should be triggered by long string value.');
    }
}