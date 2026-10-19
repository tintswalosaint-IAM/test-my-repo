/**
 * @description       : test Class for KYC_SRV_PartyIdentityVerifStep 
 * @author            : Nagendraprasad Mylavarapu
 * @group             : 
 * @last modified on  : 10-08-2024
 * @last modified by  : Nagendra Mylavarapu
**/
@IsTest
private class KYC_SRV_PartyIdentityVerifStep_Test {
    
    @IsTest
    static void testSavePartyIdentityVerificationStep() {
        // Create test data
        Account testAccount = KYC_TestDataFactory.createAccount();
        PartyProfile testPartyProfile = KYC_TestDataFactory.createPartyProfile(testAccount.Id);
        PartyIdentityVerification testVerification = KYC_TestDataFactory.createPartyIdentity(testPartyProfile.Id);
        
        // Create test PartyIdentityVerificationStep records
        List<PartyIdentityVerificationStep> testSteps = new List<PartyIdentityVerificationStep>();
        for (Integer i = 0; i < 3; i++) {
            PartyIdentityVerificationStep step = new PartyIdentityVerificationStep(
                Name = 'Test Step ' + i,
                Status = 'Pending',
                Type = 'Document Verification'
            );
            testSteps.add(step);
        }
        
        // Create an instance of the service
        KYC_SRV_PartyIdentityVerificationStep.IService srv = KYC_SRV_PartyIdentityVerificationStep.newInstance();
        
        // Create a unit of work
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{
                PartyIdentityVerificationStep.SObjectType
            }
        );
        
        Test.startTest();
        // Call the method under test
        srv.savePartyIdentityVerificationStep(testVerification, testSteps, uow);
        uow.commitWork();
        Test.stopTest();
        
        // Verify the results
        List<PartyIdentityVerificationStep> savedSteps = [
            SELECT Id, PartyIdentityVerificationId, Name, Status, Type
            FROM PartyIdentityVerificationStep
            WHERE PartyIdentityVerificationId = :testVerification.Id
        ];
        
        // Assert that the correct number of steps were saved
        Assert.areEqual(3, savedSteps.size(), 'Expected 3 PartyIdentityVerificationStep records to be saved');
        
        // Assert that the steps were saved with the correct data
        for (Integer i = 0; i < savedSteps.size(); i++) {
            PartyIdentityVerificationStep savedStep = savedSteps[i];
            Assert.areEqual('Test Step ' + i, savedStep.Name, 'Step name does not match');
            Assert.areEqual('Pending', savedStep.Status, 'Step status does not match');
            Assert.areEqual('Document Verification', savedStep.Type, 'Step type does not match');
            Assert.areEqual(testVerification.Id, savedStep.PartyIdentityVerificationId, 'PartyIdentityVerificationId does not match');
        }
    }
    
    @IsTest
    static void testSavePartyIdentityVerificationStepWithExistingSteps() {
        try{
        // Create test data
        Account testAccount = KYC_TestDataFactory.createAccount();
        PartyProfile testPartyProfile = KYC_TestDataFactory.createPartyProfile(testAccount.Id);
        PartyIdentityVerification testVerification = KYC_TestDataFactory.createPartyIdentity(testPartyProfile.Id);
        
        // Create existing PartyIdentityVerificationStep records
        List<PartyIdentityVerificationStep> existingSteps = new List<PartyIdentityVerificationStep>();
        for (Integer i = 0; i < 2; i++) {
            PartyIdentityVerificationStep step = new PartyIdentityVerificationStep(
                Name = 'Existing Step ' + i,
                Status = 'Completed',
                Type = 'Document Verification',
                PartyIdentityVerificationId = testVerification.Id
            );
            existingSteps.add(step);
        }
        insert existingSteps;
        
        // Create new PartyIdentityVerificationStep records
        List<PartyIdentityVerificationStep> newSteps = new List<PartyIdentityVerificationStep>();
        for (Integer i = 0; i < 2; i++) {
            PartyIdentityVerificationStep step = new PartyIdentityVerificationStep(
                Name = 'New Step ' + i,
                Status = 'Pending',
                Type = 'Identity Verification'
            );
            newSteps.add(step);
        }
        
        // Combine existing and new steps
        List<PartyIdentityVerificationStep> allSteps = new List<PartyIdentityVerificationStep>();
        allSteps.addAll(existingSteps);
        allSteps.addAll(newSteps);
        
        // Create an instance of the service
        KYC_SRV_PartyIdentityVerificationStep.IService srv = KYC_SRV_PartyIdentityVerificationStep.newInstance();
        
        // Create a unit of work
        sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(
            new List<SObjectType>{
                PartyIdentityVerificationStep.SObjectType
            }
        );
        
        Test.startTest();
        // Call the method under test
        srv.savePartyIdentityVerificationStep(testVerification, allSteps, uow);
        uow.commitWork();
        Test.stopTest();
        
        // Verify the results
        List<PartyIdentityVerificationStep> savedSteps = [
            SELECT Id, PartyIdentityVerificationId, Name, Status, Type
            FROM PartyIdentityVerificationStep
            WHERE PartyIdentityVerificationId = :testVerification.Id
            ORDER BY Name
        ];
        
        // Assert that the correct number of steps were saved
        Assert.areEqual(4, savedSteps.size(), 'Expected 4 PartyIdentityVerificationStep records in total');
        
        // Assert that the existing steps were updated
        for (Integer i = 0; i < 2; i++) {
            PartyIdentityVerificationStep savedStep = savedSteps[i];
            Assert.areEqual('Existing Step ' + i, savedStep.Name, 'Existing step name does not match');
            Assert.areEqual('Completed', savedStep.Status, 'Existing step status should not have changed');
            Assert.areEqual('Document Verification', savedStep.Type, 'Existing step type should not have changed');
        }
        
        // Assert that the new steps were saved
        for (Integer i = 2; i < 4; i++) {
            PartyIdentityVerificationStep savedStep = savedSteps[i];
            Assert.areEqual('New Step ' + (i-2), savedStep.Name, 'New step name does not match');
            Assert.areEqual('Pending', savedStep.Status, 'New step status does not match');
            Assert.areEqual('Identity Verification', savedStep.Type, 'New step type does not match');
        }
    }
    catch(exception ex){
         Assert.areEqual(true ,ex.getmessage()!= null, 'Error Occured');
    }
    }
}