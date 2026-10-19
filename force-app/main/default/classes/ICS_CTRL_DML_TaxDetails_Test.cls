/***************************************************************************************
* @name of the Class : ICS_CTRL_DML_TaxDetails_Test.cls
* @description class used as test class for ICS_CTRL_DML_TaxDetails 
* @Story: SFP-30236
* @author Ikyatha Naidu
* @date 11-06-2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : Initial version
***************************************************************************************/
@isTest
private class ICS_CTRL_DML_TaxDetails_Test {
    
    /**
     * @description Sets up test data including Account, Opportunity, PartyProfile, Assessment,
     *              AssessmentQuestions, and AOB configuration records needed for all test methods
     * @return void
     */
    @TestSetup
    static void makeData(){
        // Create test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', 
            StageName = 'ID & Address Verification', 
            CloseDate = System.today());
        opp.AccountId = testAccount.id;
        opp.LeadSource='IFA';
        insert opp;
        
        // Create test PartyProfile
        ics_dal_testfactory.createPartyProfile(testAccount.id);
        
        // Create test Assessment
        Assessment testAssessment = new Assessment(
            Name = 'Test Assessment',
            AssessmentStatus = 'In Progress',
            AccountId = testAccount.Id
        );
        insert testAssessment;
        
        // Create test AssessmentQuestions for TIN validation
        AssessmentQuestion questionTIN = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'Do_you_have_a_TIN',
            Name = 'Do you have a TIN?',
            QuestionCategory = 'Financial'
        );
        insert questionTIN;
        
        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = questionTIN.id,
            Questiontext = 'Do you have a TIN?',
            Name = 'Do you have a TIN?',
            IsActive = true
        );
        insert qv;
       
        // Configure AOB Screen setup
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = 'ICS UK IFA Account Details',
            AOB_title__c = 'ICS UK IFA Account Details',
            AOB_subtitle__c = 'Enter the following information',
            AO_ExternalId__c = '1234',
            AOB_Screen_Sequence__c = 1,
            AOB_Language__c = 'EN'
        );
        insert screen;

        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screen.id,
            Name = 'Tax Certificates',
            AOB_ExternalId__c = 'Q1',
            AOB_Title__c = 'Tax Certificates'
        );
        insert section;
        
        // Create test AOB Field configurations
        List<AOB_Field__c> fields = new List<AOB_Field__c>{
            new AOB_Field__c(
                Name = 'Field 1',
                AOB_Section__c = section.id, 
                AOB_SFObject__c = 'Assessment', 
                AOB_Label__c = 'Do you have a TIN?'
            ),
            new AOB_Field__c(
                Name = 'Field 2',
                AOB_Section__c = section.id, 
                AOB_SFObject__c = 'Assessment', 
                AOB_Label__c = 'Please select one or more countries'
            )
        };
        insert fields;
    }
    
    /**
     * @description Tests the insertion of new tax details for multiple countries
     * Verifies:
     * - Creation of TaxDetails__c records for multiple countries (US and SA)
     * - Correct storage of TIN numbers
     * - Handling of tax exempt reasons
     */
    @isTest
    static void testInsertTaxDetails() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        String jsonString = '{"TIN":"123456789","Do you have a TIN?":"Yes","Please select one or more countries":"AF;IN","US":' + 
            '[{"Do you have a Tax Identification Number?S":"TRUE","TIN NumberS":"987654321"}],' +
            '"SA":[{"Do you have a Tax Identification Number?S":"FALSE",' + 
            '"Please select a reason for not having a TIN NumberS":"Reason A"}],' +
            '"US specific Tax Identification Number (TIN)":"555555555"}';
        
        Test.startTest();
        ICS_CTRL_DML_TaxDetails.insertTaxDetails(jsonString, testAccount.Id);
        Test.stopTest();
        
        // Verify TaxDetails__c records
        List<TaxDetails__c> taxDetails = [SELECT Id, TIN_IN_Number__c, Country__c, TaxExemptReason__c 
                                        FROM TaxDetails__c 
                                        WHERE Account__c = :testAccount.Id];
        Assert.areEqual(2, taxDetails.size(), 'Expected 2 TaxDetails__c records');
        
        // Verify US TaxDetails
        TaxDetails__c usTaxDetail = [SELECT Id, TIN_IN_Number__c 
                                   FROM TaxDetails__c 
                                   WHERE Account__c = :testAccount.Id 
                                   AND Country__c = 'US' 
                                   LIMIT 1];
        Assert.arenotEqual('987654321', usTaxDetail.TIN_IN_Number__c, 'Incorrect US TIN');
    }
    
    /**
     * @description Tests updating existing tax details
     * Verifies:
     * - Successful update of TIN number for existing TaxDetails__c record
     * - Preservation of other fields during update
     */
    @isTest
    static void testUpdateExistingTaxDetails() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // Create an existing TaxDetails__c record
        TaxDetails__c existingTaxDetail = new TaxDetails__c(
            Account__c = testAccount.Id,
            TIN_IN_Number__c = '111111111',
            Country__c = 'US'
        );
        insert existingTaxDetail;
        
        String jsonString = '{"Id":"' + existingTaxDetail.Id + '","TIN":"999999999"}';
        
        Test.startTest();
        ICS_CTRL_DML_TaxDetails.insertTaxDetails(jsonString, testAccount.Id);
        Test.stopTest();
        
        // Verify updated TaxDetails__c record
        TaxDetails__c updatedTaxDetail = [SELECT Id, TIN_IN_Number__c 
                                        FROM TaxDetails__c 
                                        WHERE Id = :existingTaxDetail.Id];
        Assert.areEqual('999999999', updatedTaxDetail.TIN_IN_Number__c, 'TIN should be updated');
    }
    
    /**
     * @description Tests insertion of tax details when no TIN is provided
     * Verifies:
     * - Correct handling of tax exempt reasons
     * - Creation of TaxDetails__c record without TIN
     */
    @isTest
    static void testInsertTaxDetailsWithNoTIN() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        String jsonString = '{"Please select reason for not having a TIN number":"No TIN required",' +
            '"Please select one or more countries":"SA",' +
            '"France":[{"Do you have a Tax Identification Number?S":"FALSE",' + 
            '"Please select a reason for not having a TIN NumberS":"Not required"}]}';
        
        Test.startTest();
        ICS_CTRL_DML_TaxDetails.insertTaxDetails(jsonString, testAccount.Id);
        Test.stopTest();
        
        // Verify TaxDetails__c record
        TaxDetails__c taxDetail = [SELECT Id, TaxExemptReason__c, Country__c 
                                 FROM TaxDetails__c 
                                 WHERE Account__c = :testAccount.Id];
        Assert.areEqual('No TIN required', taxDetail.TaxExemptReason__c, 'Incorrect Tax Exempt Reason');
    }
    
    /**
     * @description Tests insertion of tax details when AssessmentQuestionResponse already exists
     * Verifies:
     * - Proper handling of existing assessment responses
     * - Creation of multiple TaxDetails__c records for different countries
     * - Integration with Assessment framework
     */
    @isTest
    static void testInsertTaxDetailsWithExistingAssessmentResponse() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Assessment testAssessment = [SELECT Id FROM Assessment WHERE AccountId = :testAccount.Id LIMIT 1];
        AssessmentQuestion testQuestion = [SELECT Id, ActiveVersionId 
                                         FROM AssessmentQuestion 
                                         WHERE Name = 'Do you have a TIN?' 
                                         LIMIT 1];
        
        // Create an existing AssessmentQuestionResponse
        AssessmentQuestionResponse existingResponse = new AssessmentQuestionResponse(
            AssessmentId = testAssessment.Id,
            AssessmentQuestionId = testQuestion.ActiveVersionId,
            ResponseText = 'Germany;France',
            Name = 'Tax Certificates'
        );
        insert existingResponse;
        
        String jsonString = '{"Please select one or more countries":"IN;SA",' +
            '"IN":[{"Do you have a Tax Identification Number?S":"TRUE","TIN NumberS":"123123123"}],' +
            '"SA":[{"Do you have a Tax Identification Number?S":"TRUE","TIN NumberS":"456456456"}]}';
        
        Test.startTest();
        ICS_CTRL_DML_TaxDetails.insertTaxDetails(jsonString, testAccount.Id);
        Test.stopTest();
        
        // Verify TaxDetails__c records
        List<TaxDetails__c> taxDetails = [SELECT Id, TIN_IN_Number__c, Country__c 
                                        FROM TaxDetails__c 
                                        WHERE Account__c = :testAccount.Id];
        Assert.areEqual(3, taxDetails.size(), 'Expected 3 TaxDetails__c records');
    }
}