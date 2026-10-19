/**
 * @description Test class for ICS_UTIL_AppFormDataService
 * @author Ridhima Saxena
 * @date June 14, 2024
 */
@isTest
public class ICS_UTIL_AppFormDataService_Test {
    
    @TestSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(acc.Id);
        // Create related records
        ICS_DAL_TestFactory.createEmployment(acc.Id);
        PartyProfile partyProfile =ICS_DAL_TestFactory.createPartyProfile(acc.Id);
        createPartyAssetsFunds(partyProfile.Id);     
        // Create additional test data
        ApplicationForm appForm=ICS_DAL_TestFactory.createApplicationForm(acc.Id,opp.Id);
        ICS_DAL_TestFactory.createApplicant(acc.Id,partyProfile.Id,appForm.id);
        createAssessmentWithQuestions(acc.Id);
    }
    
    @isTest
    static void testGetOpportunity() {
        // Setup
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        ICS_UTIL_AppFormDataService dataService = new ICS_UTIL_AppFormDataService(opp.AccountId);
        // Execute
        Test.startTest();
        Map<String, Object> result = dataService.getOpportunity();
        Test.stopTest();        
        // Assert
        Opportunity resultOpp = (Opportunity) result.get('opportunity');
        Assert.areEqual(opp.Id, resultOpp.Id, 'Returned Opportunity Id should match the input Id');  
        List<Object> resultAppList = (List<Object>) result.get('applications');
        Assert.isTrue(!resultAppList.isEmpty(), 'Should return at least one application');
    }
    
    private static void createPartyAssetsFunds(Id partyProfileId) {
        Id recordTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Source of Funds').getRecordTypeId();
        List<Party_Assets_Funds__c> fundsList = new List<Party_Assets_Funds__c>{
            new Party_Assets_Funds__c(Party_Profile__c = partyProfileId, RecordTypeId = recordTypeId, Is_Future_Fund__c = true, Type__c = 'Ownership/shares in business'),
            new Party_Assets_Funds__c(Party_Profile__c = partyProfileId, RecordTypeId = recordTypeId, Is_Future_Fund__c = true, Type__c = 'Sale of Property'),
            new Party_Assets_Funds__c(Party_Profile__c = partyProfileId, RecordTypeId = recordTypeId, Is_Future_Fund__c = true, Type__c = 'Investment/Stock'),
            new Party_Assets_Funds__c(Party_Profile__c = partyProfileId, RecordTypeId = recordTypeId, Is_Future_Fund__c = false, Type__c = 'Gift'),
            new Party_Assets_Funds__c(Party_Profile__c = partyProfileId, RecordTypeId = recordTypeId, Is_Future_Fund__c = true, Type__c = 'Bank Account')
        };
        insert fundsList;
    }
    
    private static void createAssessmentWithQuestions(Id accountId) {
        Assessment assessment = new Assessment(
            AccountId = accountId,
            Name = 'Test Assessment',
            AssessmentStatus = 'In Progress'
        );
        insert assessment;  
        List<AssessmentQuestion> questions = new List<AssessmentQuestion>{
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you', Name = 'Select all assets and income', QuestionCategory = 'Financial'),
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you2', Name = 'Select years', QuestionCategory = 'Financial'),
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you3', Name = 'Select all fund assets and income', QuestionCategory = 'Financial'),
            new AssessmentQuestion(DataType = 'Checkbox', DeveloperName = 'how_are_you4', Name = 'Are you associated to any Shell Banks', QuestionCategory = 'Financial')
        };
        insert questions;       
        List<AssessmentQuestionVersion> questionVersions = new List<AssessmentQuestionVersion>();
        List<AssessmentQuestionResponse> responses = new List<AssessmentQuestionResponse>();   
        for (Integer i = 0; i < questions.size(); i++) {
            AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
                AssessmentQuestionId = questions[i].Id,
                QuestionText = questions[i].Name + '*',
                Name = 'Assets and Income'
            );
            questionVersions.add(qv);
        }
        insert questionVersions;  
        for (Integer i = 0; i < questionVersions.size(); i++) {
            AssessmentQuestionResponse ar = new AssessmentQuestionResponse(
                AssessmentQuestionId = questionVersions[i].Id,
                AssessmentId = assessment.Id,
                Name = 'Assets and Income',
                ResponseText = i == 3 ? 'TRUE' : 'Compensation Payment;Gift;'
            );
            responses.add(ar);
        }
        insert responses;
    }
    @isTest
    static void testGetApplicantData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(acc.Id);
        // Create related records
        ICS_DAL_TestFactory.createEmployment(acc.Id);
        PartyProfile partyProfile =ICS_DAL_TestFactory.createPartyProfile(acc.Id);
        createPartyAssetsFunds(partyProfile.Id);     
        // Create additional test data
        ApplicationForm appForm=ICS_DAL_TestFactory.createApplicationForm(acc.Id,opp.Id);
        ICS_UTIL_AppFormDataService dataService = new ICS_UTIL_AppFormDataService(acc.Id);
        Test.startTest();
        Map<String, Object> result = dataService.getApplicantData(appForm.Id);
        Test.stopTest();

        // Assertions to verify the expected behavior
        Assert.areNotEqual(result, null, 'Result should not be null');
        
        // Add more assertions for other keys in the response as needed
    }
    @isTest
    public static void testGetProcessCurrency() {
        // Test 1: Normal case with valid input
        String input = 'USD, 1.00; EUR, 0.85; GBP, 0.75';
        List<String> result = ICS_UTIL_AppFormDataService.getProcessCurrency(input);
        
        // Assert the size of the result list
        Assert.areEqual(6, result.size(), 'Result list should have 6 items');
        
        // Assert each value in the result list
        Assert.areEqual('USD', result[0], 'First currency should be USD');
        Assert.areEqual('1.00', result[1], 'First value should be 1.00');
        
        Assert.areEqual('EUR', result[2], 'Second currency should be EUR');
        Assert.areEqual('0.85', result[3], 'Second value should be 0.85');
        
        Assert.areEqual('GBP', result[4], 'Third currency should be GBP');
        Assert.areEqual('0.75', result[5], 'Third value should be 0.75');
        
        // Test 2: Case with extra spaces around the commas and semicolons
        String inputWithSpaces = ' USD, 1.00 ; EUR,  0.85  ;  GBP,0.75 ';
        List<String> resultWithSpaces = ICS_UTIL_AppFormDataService.getProcessCurrency(inputWithSpaces);
        
        // Assert the result list size
         Assert.areEqual(6, resultWithSpaces.size(), 'Result list should have 6 items with spaces');
        
        // Assert values, making sure that trim works correctly
         Assert.areEqual('USD', resultWithSpaces[0], 'First currency should be USD');
         Assert.areEqual('1.00', resultWithSpaces[1], 'First value should be 1.00');
        
         Assert.areEqual('EUR', resultWithSpaces[2], 'Second currency should be EUR');
         Assert.areEqual('0.85', resultWithSpaces[3], 'Second value should be 0.85');
        
         Assert.areEqual('GBP', resultWithSpaces[4], 'Third currency should be GBP');
         Assert.areEqual('0.75', resultWithSpaces[5], 'Third value should be 0.75');
        
        // Test 3: Case with an empty input
        String emptyInput = '';
        List<String> resultEmpty = ICS_UTIL_AppFormDataService.getProcessCurrency(emptyInput);
        
        // Assert the result list size for empty input (should be 0)
         Assert.areEqual(0, resultEmpty.size(), 'Result list should be empty for empty input');
    
    }
}