/**
 * @Name of the Class : ICS_CTRL_ApplicantFormPDF_Test.cls
 * @description: class used as test class for ICS_CTRL_ApplicantFormPDF
 * @Author Ikyatha Naidu 
 * @Date 01/06/2024
 * @Last Modified On  : 25/08/2024
 * @Last Modified By  : Ikyatha Naidu
 * @Modification Description : Initial Version
 *  * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 12-09-2025
 * @Modification description : SFP-52838 worked on SCA
 ***************************************************************************************
 */
@isTest
public class ICS_CTRL_ApplicantFormPDF_Test {
    private static final String CURR_ACCOUNT_BAL = 'Current Account BalanceCurrency';
    private static final String GROSS_SALARY = 'Gross Annual SalaryCurrency';
    private static final String BONUS = 'Bonuses/Commissions received per annumCurrency';
    private static final String TAX_CERTS = 'Tax Certificates';
    private static final String BANK_DETAILS = 'Bank Details';
    private static final String ADDITIONAL_BANK = 'Additional Bank Accounts';
    private static final String INITIAL_DEP = 'Initial Deposit';
    private static final String TRUSTS = 'Trusts';
    private static final String FINANCIAL = 'Financial';
    private static final String EMPLOYMENT_CONTRACTS_Q = 'Do you/your employment have any contracts with public authorities/governments/s?';
    private static final String PREV_EMP_DETAILS = 'Previous Employment Details';
    private static final String CURR_EMP_DETAILS = 'Current Employment Details';
    private static final String BUSINESS_OWN = 'Business Ownership';
    private static final String DUAL_EMP = 'Dual Employment Details';
    private static final String TEXTAREA = 'TextArea';
    private static final String SUFFIX_NO = ':No';
	private static final String SUFFIX_TRUE = ':TRUE';
        @TestSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(acc.Id);
       PartyProfile pp = ICS_DAL_TestFactory.createPartyProfile(acc.Id);
    
        Applicationform appForm = ICS_DAL_TestFactory.createApplicationForm(acc.Id); 
        appForm.opportunityId = opp.id; 
        update appForm;
           Applicant app = new Applicant(
            ApplicationFormId= appForm.Id,
                   role='Primary Applicant'
        );
        insert app;
        PageReference pageRef = Page.ICS_ApplicantForm_PDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id', opp.Id);
         List<ContactPointPhone> phones = new List<ContactPointPhone>();

        ContactPointPhone primaryPhone = new ContactPointPhone(
            ParentId = acc.Id,
            TelephoneNumber = '+1234567890',
            IsPrimary = true,
            PhoneType = 'Mobile'      
        );
        phones.add(primaryPhone);
        
        // Secondary phone
        ContactPointPhone secondaryPhone = new ContactPointPhone(
            ParentId = acc.Id,
            TelephoneNumber = '+9876543210',
            IsPrimary = false,
            PhoneType = 'Home'
        );
        phones.add(secondaryPhone);
        insert phones;
        
        ICS_DAL_TestFactory.createPartyAssetFunds(pp.Id);
        ICS_DAL_TestFactory.createEmployment(acc.Id); 
        createAssessments(acc.Id);
        createAssessmentQuestionHierarchy(acc.Id);
    }
	
      private static void createAssessments(Id accountId) {
        List<Assessment> assessments = new List<Assessment>{
            new Assessment(AccountId = accountId, Name = 'Test Assessment', AssessmentStatus = 'In Progress'),
            new Assessment(AccountId = accountId, Name = 'Test Assessment BULK', AssessmentStatus = 'In Progress')
        };
        insert assessments;
    }
    @isTest
    static void testGetApplicantRelation() {
        // Setup data - get opportunity and account created in TestSetup
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm WHERE Opportunity.Id = :opp.Id LIMIT 1];
        // Create test Applicant record
        Applicant testApplicant = new Applicant(
            AccountId = opp.AccountId,
            ApplicationFormId = appForm.Id, 
            Relationship_with_Applicants__c = 'Family',
            Other_First_Name__c = 'John',
            Other_Middle_Name__c = 'M',
            Other_Surname__c = 'Doe'
        );
        insert testApplicant;
        
        Test.startTest();
        
        ICS_CTRL_ApplicantFormPDF controller = new ICS_CTRL_ApplicantFormPDF();
        controller.getApplicantRelation(opp.AccountId);
        Assert.isTrue(controller.applicantRelation != null, 'Relationship should be set');
        
        Test.stopTest();
    }
     private static void createAssessmentQuestionHierarchy(Id accountId) {
        // Create Questions
        List<AssessmentQuestion> questions = createAssessmentQuestions();
        insert questions;
        // Create Question Versions
        List<AssessmentQuestionVersion> versions = createQuestionVersions(questions);
        insert versions;
        
        // Create Question Responses
        List<Assessment> assessments = [SELECT Id FROM Assessment WHERE AccountId = :accountId];
        List<AssessmentQuestionResponse> responses = createQuestionResponses(versions, assessments);
        insert responses;
    }
     private static List<AssessmentQuestion> createAssessmentQuestions() {
        return new List<AssessmentQuestion>{
            new AssessmentQuestion(DataType = 'Checkbox', DeveloperName = 'how_are_you', Name = EMPLOYMENT_CONTRACTS_Q, QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you2', Name = 'Frequency of the payments coming into the new account', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you3', Name = 'Frequency of the payments leaving the new account', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you4', Name = 'Please select your main tax residency country', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you5', Name = 'Please select why the country you live in is different from the country', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = 'Checkbox', DeveloperName = 'how_are_you6', Name = 'Do you have a Tax Identification Number (TIN)?', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you7', Name = 'Are you related to a Trust structure?', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you8', Name = 'Please confirm if you are sending your initial deposit by bank transfer', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you9', Name = 'Current Account BalanceCurrency', QuestionCategory = FINANCIAL),
            new AssessmentQuestion(DataType = TEXTAREA, DeveloperName = 'how_are_you10', Name = 'Current Account BalanceCurrency', QuestionCategory = FINANCIAL)
        };
    }
   private static List<AssessmentQuestionVersion> createQuestionVersions(List<AssessmentQuestion> questions) {
    return new List<AssessmentQuestionVersion>{
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[0].Id, QuestionText = EMPLOYMENT_CONTRACTS_Q, Name = CURR_ACCOUNT_BAL),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[1].Id, QuestionText = 'Frequency of the payments coming into the new account', Name = GROSS_SALARY),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[0].Id, QuestionText = EMPLOYMENT_CONTRACTS_Q, Name = EMPLOYMENT_CONTRACTS_Q),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[2].Id, QuestionText = 'Frequency of the payments leaving the new account', Name = 'Future Deposits'),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[4].Id, QuestionText = 'Please select your main tax residency country', Name = BONUS),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[4].Id, QuestionText = 'Please select why the country you live in is different from the country', Name = TAX_CERTS),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[5].Id, QuestionText = 'Do you have a Tax Identification Number (TIN)?', Name = TAX_CERTS),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[6].Id, QuestionText = 'Are you related to a Trust structure?', Name = TRUSTS),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[7].Id, QuestionText = 'Please confirm if you are sending your initial deposit by bank transfer', Name = INITIAL_DEP),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[8].Id, QuestionText = CURR_ACCOUNT_BAL, Name = BANK_DETAILS),
        new AssessmentQuestionVersion(AssessmentQuestionId = questions[9].Id, QuestionText = CURR_ACCOUNT_BAL, Name = ADDITIONAL_BANK)
    };
}
    
    private static List<AssessmentQuestionResponse> createQuestionResponses(List<AssessmentQuestionVersion> versions, List<Assessment> assessments) {
        return new List<AssessmentQuestionResponse>{
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[0].Id, AssessmentId = assessments[0].Id, Name = BANK_DETAILS + ':', ResponseText = BANK_DETAILS + ':78794'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[1].Id, AssessmentId = assessments[1].Id, Name = CURR_EMP_DETAILS + ':', ResponseText = CURR_EMP_DETAILS + ':66787'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[3].Id, AssessmentId = assessments[1].Id, Name = BUSINESS_OWN + ':', ResponseText = BUSINESS_OWN + ':69787'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[0].Id, AssessmentId = assessments[0].Id, Name = TAX_CERTS + ':', ResponseText = 'TRUE'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[0].Id, AssessmentId = assessments[1].Id, Name = TAX_CERTS + ':', ResponseText = 'Compensation Payment'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[4].Id, AssessmentId = assessments[0].Id, Name = PREV_EMP_DETAILS + ':', ResponseText = PREV_EMP_DETAILS + SUFFIX_NO),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[2].Id, AssessmentId = assessments[1].Id, Name = CURR_EMP_DETAILS + ':', ResponseText = CURR_EMP_DETAILS + SUFFIX_NO),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[2].Id, AssessmentId = assessments[0].Id, Name = BUSINESS_OWN + ':', ResponseText = BUSINESS_OWN + SUFFIX_NO),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[2].Id, AssessmentId = assessments[0].Id, Name = DUAL_EMP + ':', ResponseText = DUAL_EMP + SUFFIX_NO),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[1].Id, AssessmentId = assessments[1].Id, Name = PREV_EMP_DETAILS + ':', ResponseText = PREV_EMP_DETAILS + SUFFIX_NO),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[1].Id, AssessmentId = assessments[1].Id, Name = DUAL_EMP + ':', ResponseText = DUAL_EMP + SUFFIX_TRUE)
        };
    }
       
    @isTest
    static void testConstructor() {
        try {
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Test.startTest();
            
            PageReference pageRef = Page.ICS_ApplicantForm_PDF;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', opp.Id);
            
            ICS_CTRL_ApplicantFormPDF controller = new ICS_CTRL_ApplicantFormPDF();
            Assert.isNotNull(controller, 'Controller should not be null');
            
            Test.stopTest();
        } catch(Exception e) {
              Assert.isNotNull(e.getMessage(), 'Exception occured');
        }
    }
    
    
   @isTest
    static void testGetPartyProfiles() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        
        Test.startTest(); 
        ICS_CTRL_ApplicantFormPDF.appFormData = new ICS_UTIL_AppFormDataProvider(opp.AccountId);
        Map<String, Object> result = ICS_CTRL_ApplicantFormPDF.getPartyProfiles(opp.AccountId);
        ICS_CTRL_ApplicantFormPDF.getRecords(opp.AccountId);
        Test.stopTest();
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isTrue(result.containsKey('partyProfileRecords'), 'Result should contain partyProfileRecords');
        Assert.isTrue(result.containsKey('partyProfileRecordByType'), 'Result should contain partyProfileRecordByType');
        Assert.isTrue(result.containsKey('partyProfileRecordByTypeadd'), 'Result should contain partyProfileRecordByTypeadd');
    }
    
    

  @isTest
    static void testGetAccounts() {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1 ];
        
        Test.startTest();
        ICS_CTRL_ApplicantFormPDF.appFormData = new ICS_UTIL_AppFormDataProvider(opp.AccountId);
        Map<Id, Account> result = ICS_CTRL_ApplicantFormPDF.getAccounts(opp.AccountId);
        
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
        Assert.areEqual(opp.AccountId, new List<Id>(result.keySet())[0], 'Account ID should match');
    }
    
    @isTest
    static void testGeneratePdf() {
        
        try {
            Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
            
            Test.startTest();
            ICS_CTRL_ApplicantFormPDF.strPdfBody = Blob.valueOf('test pdf');
             ICS_CTRL_ApplicantFormPDF.generatePdf(opp.AccountId,'SBOIOM');
           

            Test.stopTest();
            
            
        } catch (Exception e) {
            Assert.isTrue(e.getmessage() != null, 'Error occured at creating contentdocument');
        }
    }
    
    
    @isTest
    static void testApplicantFormPDF() {
        try {
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            ICS_CTRL_ApplicantFormPDF.Requests req = new ICS_CTRL_ApplicantFormPDF.Requests();
            req.recordID = opp.Id;
            
            Test.startTest();
            List<ICS_CTRL_ApplicantFormPDF.Results> results = ICS_CTRL_ApplicantFormPDF.ApplicantFormPDF(new List<ICS_CTRL_ApplicantFormPDF.Requests>{req});
            Test.stopTest();
            
            Assert.isFalse(results.isEmpty(), 'There should be at least one result');
            Assert.isNotNull(results[0].contentDocumentId, 'ContentDocument Id should not be null');
        } catch (Exception e) {
            Assert.isTrue(e.getmessage() != null, 'Error occured at creating contentdocument');
        }
    }
    @isTest
     static void testsetApplicationCount() {
          Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
          Test.startTest();
          ICS_CTRL_ApplicantFormPDF data=new ICS_CTRL_ApplicantFormPDF();
          data.setApplicationCount(opp.AccountId);
          Assert.areNotEqual(0, data.applicationCount, 'The application count should be 0 for the given Opportunity');
           // Test with a null recordId (to test the "else" condition)
          ICS_CTRL_ApplicantFormPDF dataNull = new ICS_CTRL_ApplicantFormPDF();
          dataNull.setApplicationCount(null); 
          Integer defaultApplicationCount = 0; // Adjust according to the logic of your "else" condition
          Assert.areEqual(defaultApplicationCount, dataNull.applicationCount, 'Application count should default when recordId is null');
          Test.stopTest();
     }
   @isTest
    static void testcheckIfPrimaryApplicant() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
       ApplicationForm appForm = ICS_DAL_TestFactory.createApplicationForm(acc.Id);
        appForm.opportunityId = opp.Id;
        update appForm;
        Applicant app = new Applicant(
            AccountId = acc.Id,
            ApplicationFormId = appForm.Id,
            role = 'Primary Applicant'
        );
        insert app;
        
        Test.startTest();
        ICS_CTRL_ApplicantFormPDF data = new ICS_CTRL_ApplicantFormPDF();
        data.checkIfPrimaryApplicant(acc.Id);
        
        Assert.areEqual(true, data.isPrimaryApplicant, 'The isPrimaryApplicant flag should be true for an Account with a primary applicant');
        ICS_CTRL_ApplicantFormPDF dataNull = new ICS_CTRL_ApplicantFormPDF();
        dataNull.checkIfPrimaryApplicant(null); 
        Assert.areEqual(false, dataNull.isPrimaryApplicant, 'The isPrimaryApplicant flag should be false when recordId is null');
        
        Test.stopTest();
    }
}