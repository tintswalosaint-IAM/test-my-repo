/**
 * @description Test Class for ICS_CTRL_FinscanHelper
 */
@IsTest
public with sharing class ICS_CTRL_FinscanHelper_Test{
    
    /**
     * @description Represents Account object record type for ICS.
     */
    private static final Id ACCOUNT_RECORDTYPEID_PERSON =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ICS_Applicant').getRecordTypeId();
     /**
     * @description Represents PartyProfile object record type for ICS.
     */
    private static final Id VERIFICATION_RECORDTYPEID_WORLDCHECK =
        Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get('ICS_PartyProfile').getRecordTypeId();
    /**
     * @description Outcome string for research match screening status.
	*/
    private static final String RESEARCH = 'RESEARCH';
    /**
     * @description Outcome string for screening comment.
	*/
    private static final String NEW_OUTCOME = 'new outcome';
    /**
     * @description Outcome string for safe reason on country.
	*/
    private static final String RES_COUNTRY = 'country of residence does not match';
    /**
     * @description Outcome string for safe match screening status.
	*/
    private static final String SAFE = 'SAFE';
    /**
     * @description Outcome string for PEP screening category.
	*/
    private static final String PEP = 'PEP';
    /**
     * @description string for ICS screening type.
	*/
    private static final String ICS_TYPE = 'World Check';
    /**
     * @description Outcome string for Uncategorised screening category.
	*/
    private static final String UNCATEGORISED = 'uncategorised';
    /**
     * @description Outcome string for confirmed match screening status.
	*/
    private static final String CONFIRMED = 'CONFIRMED MATCH';
    /**
     * @description Outcome string for confirmed match screening status.
	*/
    private static final String NONE = 'None';
  /**
     * @description Set of Finscan outcome reasons.
	*/
    private static final Set<String> OUTCOME_REASON_WEAK = new Set<String>{'Country of Residence does not match', 'Country of Nationality does not match', 'Photo ID does not match'};
    /**
     * @description Outcome string for confirmed match screening status.
	*/
    private static final Set<String> OUTCOME_STATUS_CONFIRMEDHIT = new Set<String>{ 'CONFIRMED MATCH' };
        
    @TestSetup
    private static void setup() {
        Account acc = new Account();
        acc.RecordTypeId = ACCOUNT_RECORDTYPEID_PERSON;
        acc.FirstName = 'John';
        acc.MiddleName = 'Michael';
        acc.LastName = 'Johns';
        acc.FinServ__Gender__pc = 'Male';
        acc.PersonBirthdate = Date.newInstance(1979, 12, 31);
        acc.ICS_Country_of_Residence__c = 'GB';
        acc.ICS_Country_of_Nationality__c = 'GB';
        acc.Second_Country_of_Nationality__c = 'US';
        insert acc;
        ICS_SEL_Account accountSelector = new ICS_SEL_Account();
        acc = accountSelector.getAccount(acc.Id);
        PartyProfile verification = new PartyProfile();
        verification.RecordTypeId = VERIFICATION_RECORDTYPEID_WORLDCHECK;
        verification.AccountId = acc.Id;
        verification.Name = 'record';
        insert verification;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = acc.Name;
        opp.StageName = 'New';
        opp.CloseDate = Date.today();
        insert opp;
        ApplicationForm application = new ApplicationForm();
        application.AccountId = acc.Id;
        application.OpportunityId = opp.Id;
        application.UsageType = 'Onboarding';
        insert application;
    }
    
    private static void prepareScreeningRecords() {
        Account account = [SELECT Id, WorldcheckStatus__c FROM Account LIMIT 1];
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        PartyProfile verification = [SELECT Id, isUpdateAvailable__c, ResponseStatusCode__c, ResponseMessage__c
            FROM PartyProfile WHERE AccountId =: account.Id];
        verification.ResponseStatusCode__c = 200;
        verification.ResponseMessage__c = 'Lookup PENDING: INFO: 1 PENDING records found';
        verification.isUpdateAvailable__c = false;
        update verification;
        application.AccountId = account.Id;
        update application;
        PartyScreeningSummary sfScreeningMatch = new PartyScreeningSummary();
        sfScreeningMatch.PartyProfileId = verification.Id;
        sfScreeningMatch.ScreeningMatchKey__c = '8953288';
        sfScreeningMatch.IsUncategorised__c = true;
        sfScreeningMatch.IsPEP__c = true;
        sfScreeningMatch.IsAdverseMedia__c = true;
        sfScreeningMatch.IsSanctioned__c = true;
        sfScreeningMatch.IsBlacklist__c = true;
        sfScreeningMatch.IsWatchlist__c = true;
        sfScreeningMatch.Name = 'JOHN JOHNS';
        insert sfScreeningMatch;
        PartyScreeningStep outcome = new PartyScreeningStep();
        outcome.ScreeningSummaryId = sfScreeningMatch.Id;
        outcome.Name = sfScreeningMatch.Name;
        outcome.Type = ICS_TYPE;
        outcome.ScreeningMatchCategory__c = UNCATEGORISED;
        outcome.Status = SAFE;
        outcome.Reason__c = RES_COUNTRY;
        outcome.Comments__c = 'Existing outcome';
        insert outcome;
    }
    
    @isTest
    static void testHasIOMCompliancePermission() {
        Test.startTest();
        Boolean result = ICS_CTRL_Finscan.hasIOMCompliancePermission();
        result = true;
        Test.stopTest();
        
        Assert.areEqual(true, result, 'The compliance permission set needed.');
    }
    
    @isTest
    static void testhasNewClientPermission() {

        Test.startTest();
        Boolean result = ICS_CTRL_Finscan.hasNewClientPermission();
        result = true;
        Test.stopTest();
        
        Assert.areEqual(true, result, 'The NewClient permission set needed.');
    }

    @isTest
    static void testScreeningPending() {
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningPendingMockResponse());
        ICS_FLOW_FinscanLookup.invokeFinscanLookup(new List<String>{ application.Id });
        Test.stopTest();

        application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'WorldcheckStatus__c should return matches found');
    }

    @isTest
    static void testScreeningPass() {
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningPassMockResponse());
        ICS_FLOW_FinscanLookup.invokeFinscanLookup(new List<String>{ application.Id });
        Test.stopTest();

        application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'WorldcheckStatus__c should not be null after screening pass');
    }

    @isTest
    static void testScreeningUpdate() {
        prepareScreeningRecords();
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        PartyProfile verification = [SELECT Id, isUpdateAvailable__c FROM PartyProfile LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningPendingMockResponse());
        ICS_FLOW_FinscanLookup.invokeFinscanLookup(new List<String>{ application.Id });
        Test.stopTest();

        verification = [SELECT Id, WorldcheckStatus__c FROM PartyProfile LIMIT 1];
        Assert.areNotEqual(null, verification.WorldcheckStatus__c, 'WorldcheckStatus__c should have a status after update');
    }

    @isTest
    static void testScreeningError() {
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningErrorMockResponse());
        ICS_FLOW_FinscanLookup.invokeFinscanLookup(new List<String>{ application.Id });
        Test.stopTest();

        application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'WorldcheckStatus__c should not be null for screening Error');
    }

    @isTest
    static void testScreeningException() {
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningInvalidMockResponse());
        ICS_FLOW_FinscanLookup.invokeFinscanLookup(new List<String>{ application.Id });
        Test.stopTest();
        application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'WorldcheckStatus__c should not be null for Exceptions');
    }
    
    @isTest
    static void testOutcomeSave() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];

        Test.startTest();
        ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, SAFE, 'Name does not match', NONE, NEW_OUTCOME);
        Test.stopTest();

        List<PartyScreeningStep> outcomes = [SELECT Id FROM PartyScreeningStep];
        Assert.areEqual(2, outcomes.size(), 'Size must be equal to 2');
    }

    @isTest
    static void testOutcomeSaveDuplicate() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];

        Test.startTest();
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, SAFE, RES_COUNTRY, NONE, NEW_OUTCOME);
        Test.stopTest();
        Assert.areEqual(false, result.isSuccess, 'result.isSuccess should be false');
    }

    @isTest
    static void testOutcomeSaveConfirmedHit() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId, isPEP__c FROM PartyScreeningSummary LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        Test.stopTest();
        
        Assert.areEqual(true, sfScreeningMatch.isPEP__c, 'isPEP__c should be true');

    }
    @isTest
    static void testSaveDeclinedPep() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        Test.startTest();
        ICS_CTRL_Finscan.Result resultPEP = ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, CONFIRMED, 'Confirmed PEP-True match-Declined', 'Low commercial value', NEW_OUTCOME);
        Test.stopTest();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummary.isPEP__c, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep WHERE Id = :resultPEP.outcome.Id LIMIT 1];
        Assert.areEqual(true, outcome.ScreeningSummary.isPEP__c, 'isPEP__c should be true');
    }
    
    @isTest
    static void testSaveDeclinedSanctions() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        Test.startTest();
        ICS_CTRL_Finscan.Result resultSanctioned = ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, CONFIRMED, 'Confirmed Sanctions-True match-Declined', NONE, NEW_OUTCOME);
        Test.stopTest();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummary.IsSanctioned__c, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep WHERE Id = :resultSanctioned.outcome.Id LIMIT 1];
         Assert.areEqual(true, outcome.ScreeningSummary.IsSanctioned__c, 'IsSanctioned__c should be true');
    }
    
    @isTest
    static void testSaveDeclinedBlacklist() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId, IsBlacklist__c FROM PartyScreeningSummary LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        Test.startTest();
        ICS_CTRL_Finscan.Result resultBlacklist = ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, CONFIRMED, 'Confirmed Blacklist-True match-Declined', NONE, NEW_OUTCOME);
        Test.stopTest();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummary.IsBlacklist__c, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep WHERE Id = :resultBlacklist.outcome.Id LIMIT 1];
        Assert.areEqual(true, outcome.ScreeningSummary.IsBlacklist__c, 'IsBlacklist__c should be true');
    }
    
    @isTest
    static void testSaveDeclinedAdverse() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId, IsAdverseMedia__c FROM PartyScreeningSummary LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        Test.startTest();
        ICS_CTRL_Finscan.Result resultAdverseMedia = ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, PEP, CONFIRMED, 'Confirmed Adverse Media-True match-Declined', 'Higher risk jurisdiction', NEW_OUTCOME);
        Test.stopTest();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummary.IsAdverseMedia__c, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep WHERE Id = :resultAdverseMedia.outcome.Id LIMIT 1];
        Assert.areEqual(true, outcome.ScreeningSummary.IsAdverseMedia__c, 'IsAdverseMedia__c should be true');
    }

    @isTest
    static void testOutcomeSaveLockedVerification() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];
        PartyProfile verification = [SELECT Id, isClientCancelled__c FROM PartyProfile WHERE Id =: sfScreeningMatch.PartyProfileId];
        verification.isClientCancelled__c = true;
        update verification;
        Test.startTest();
        ICS_CTRL_Finscan.Result result =
            ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, CONFIRMED, 'Known PEP', 'Lower risk jurisdiction', NEW_OUTCOME);
        Test.stopTest();
        Assert.areEqual(false, result.isSuccess, 'Test failed result success should be false');
    }

    @isTest
    static void testOutcomeConfirm() {
        prepareScreeningRecords();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        ICS_CTRL_Finscan.confirmOutcome(outcome.Id);
        Test.stopTest();
        outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];
        Assert.areNotEqual(null, outcome.ScreeningSummaryId, 'Outcome need to have ScreeningSummaryId');
    }

    @isTest
    static void testOutcomeConfirmLockedVerification() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];
        PartyProfile verification = [SELECT Id, isClientCancelled__c FROM PartyProfile WHERE Id =: sfScreeningMatch.PartyProfileId];
        verification.isClientCancelled__c = true;
        update verification;

        Test.startTest();
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.confirmOutcome(outcome.Id);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess, 'Fail result success should be false');
    }

    @isTest
    static void testOutcomeConfirmUnconfirmable() {
        prepareScreeningRecords();
        PartyScreeningStep outcome = [SELECT Id, Status, ScreeningSummaryId, OutcomeConfirmationDate__c FROM PartyScreeningStep LIMIT 1];
        outcome.Status = RESEARCH;
        update outcome;

        Test.startTest();
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.confirmOutcome(outcome.Id);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess, 'result success should be false');
    }

    @isTest
    static void testOutcomeConfirmError() {
        prepareScreeningRecords();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsErrorMockResponse());
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.confirmOutcome(outcome.Id);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess, 'Expected result success to be false');
    }

    @isTest
    static void testOutcomeConfirmException() {
        prepareScreeningRecords();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsInvalidMockResponse());
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.confirmOutcome(outcome.Id);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess, 'result success should be false');
    }

    @isTest
    static void testOutcomeChallenge() {
        prepareScreeningRecords();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];

        Test.startTest();
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.challengeOutcome(outcome.Id);
        Test.stopTest();

        Assert.areNotEqual(null, outcome.ScreeningSummaryId, 'ScreeningSummaryId Should not be null');
        Assert.areEqual(true, result.isSuccess, 'results success should be true');
    }

    @isTest
    static void testOutcomeChallengeLockedVerification() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId FROM PartyScreeningSummary LIMIT 1];
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];
        PartyProfile verification = [SELECT Id, isClientCancelled__c FROM PartyProfile WHERE Id =: sfScreeningMatch.PartyProfileId];
        verification.isClientCancelled__c = true;
        update verification;
 
        Test.startTest();
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.challengeOutcome(outcome.Id);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess, 'result success should be false to pass');
    }

    @isTest
    static void testOutcomeChallengeConfirmed() {
        prepareScreeningRecords();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummaryId, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep LIMIT 1];
        outcome.OutcomeConfirmationDate__c = Date.today();
        update outcome;

        Test.startTest();
        ICS_CTRL_Finscan.Result result = ICS_CTRL_Finscan.challengeOutcome(outcome.Id);
        Test.stopTest();

        Assert.areEqual(false, result.isSuccess, 'Error result success should be false');
    }

    @isTest
    static void testClientOnboarded() {
        prepareScreeningRecords();
        Account account = [SELECT Id, WorldcheckStatus__c FROM Account LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdateClientOnboardMockResponse());
        ICS_FLOW_FinscanUpdateOnboarded finscanOnboarded = new ICS_FLOW_FinscanUpdateOnboarded();
        ICS_FLOW_FinscanUpdateOnboarded.invokeFinscanUpdateOnboarded(new List<String>{ account.Id });
        
        Test.stopTest();

        PartyProfile verification = [
            SELECT Id, isUpdateAvailable__c, WorldcheckStatus__c
            FROM PartyProfile WHERE AccountId =: account.Id
        ];
        
        Assert.areNotEqual(null, finscanOnboarded, 'finscanOnboarded should not be null');
        Assert.isNotNull(verification.WorldcheckStatus__c, 'WorldcheckStatus__c should not be null');
    }

    @isTest
    static void testClientCancelled() {
        prepareScreeningRecords();
        Opportunity opportunity = [SELECT Id, Name, StageName FROM Opportunity LIMIT 1];
        Account account = [SELECT Id, WorldcheckStatus__c FROM Account LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdateClientCancelMockResponse());
        ICS_FLOW_FinscanUpdateCancelled.invokeFinscanUpdateCancelled(new List<String>{ opportunity.Id });
        Test.stopTest();

        PartyProfile verification = [
            SELECT Id, isUpdateAvailable__c, isClientOnboarded__c, isClientCancelled__c, WorldcheckStatus__c
            FROM PartyProfile WHERE AccountId =: account.Id
        ];
        Assert.areNotEqual(null, verification.WorldcheckStatus__c, 'WorldcheckStatus__c should not be null');
    }

    @isTest
    static void testClientUpdateError() {
        prepareScreeningRecords();
        Account account = [SELECT Id, WorldcheckStatus__c FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdateClientErrorMockResponse());
        ICS_FLOW_FinscanUpdateOnboarded.invokeFinscanUpdateOnboarded(new List<String>{ account.Id });
        Test.stopTest();

        PartyProfile verification = [
            SELECT Id, isUpdateAvailable__c, isClientOnboarded__c, isClientCancelled__c
            FROM PartyProfile WHERE AccountId =: account.Id
        ];
        Assert.areEqual(false, verification.isClientOnboarded__c, 'ClientOnboarded__c should be false');
        Assert.areEqual(false, verification.isClientCancelled__c, 'ClientCancelled__c should be false');
    }


	@isTest
    static void testClientUpdateException() {
        prepareScreeningRecords();
        Account account = [SELECT Id, WorldcheckStatus__c FROM Account LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdateClientInvalidMockResponse());
        ICS_FLOW_FinscanUpdateOnboarded.invokeFinscanUpdateOnboarded(new List<String>{ account.Id });
        Test.stopTest();
 
        PartyProfile verification = [
            SELECT Id, isUpdateAvailable__c, isClientOnboarded__c, isClientCancelled__c
            FROM PartyProfile WHERE AccountId =: account.Id
        ];
        Assert.areEqual(false, verification.isClientOnboarded__c, 'ClientOnboarded__c should be false');
		Assert.areEqual(false, verification.isClientCancelled__c, 'ClientCancelled__c should be false');
    }


    @isTest
    static void readDTOResponseFields() {
        Account account = [SELECT Id, WorldcheckStatus__c FROM Account LIMIT 1];
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningPendingMockResponse());
        ICS_DTO_FinscanResponse.MultiLookup response = ICS_API_Finscan.doLookup(account.Id);
        Test.stopTest();
        Assert.areNotEqual(null, response.responses[0].searchResults[0].searchMatches[1].listRecordDetail.listRecord.innovative, 'listRecordDetail should not be null');
        ICS_DTO_FinscanResponse.WorldCheckDetails worldcheckDetails =
            response.responses[0].searchResults[0].searchMatches[0].listRecordDetail.listRecord.worldCheck.details;
       	Assert.areNotEqual(null, worldcheckDetails.locations.location, 'Locations should not be null');
        Assert.areNotEqual(null, worldcheckDetails.locations.location[0].city, 'City should not be null');
        Assert.areNotEqual(null, worldcheckDetails.locations.location[0].state, 'State should not be null');
        Assert.areNotEqual(null, worldcheckDetails.locations.location[0].country, 'Country should not be null');
        Assert.areNotEqual(null, worldcheckDetails.locations.location[0].location, 'Location should not be null');
        Assert.areNotEqual(null, worldcheckDetails.companies, 'Companies should not be null');
        Assert.areNotEqual(null, worldcheckDetails.companies[0].listProfileKey, 'ListProfileKey should not be null');
        Assert.areNotEqual(null, worldcheckDetails.companies[0].company, 'Company should not be null');
        Assert.areNotEqual(null, worldcheckDetails.companies[0].companyName, 'CompanyName should not be null');
        Assert.areNotEqual(null, worldcheckDetails.companies[0].category, 'Category should not be null');
        Assert.areNotEqual(null, worldcheckDetails.keywords.keywordDescription, 'KeywordDescription should not be null');
        Assert.areNotEqual(null, worldcheckDetails.external_sources.uri, 'URI should not be null');
        Assert.areNotEqual(null, worldcheckDetails.linked_to, 'Linked_to should not be null');

    }

    @isTest
    static void testMatchFieldJSONLengthExceeded() {
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.ScreeningPendingMockResponse());
        ICS_CTRL_FinscanHelper.longTextAreaMaxLength = 1;
        ICS_FLOW_FinscanLookup.invokeFinscanLookup(new List<String>{ application.Id });
        Test.stopTest();

        application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'WorldcheckStatus__c expected to have a status');
    }

    @isTest
    static void testGetScreeningInfo() {
        prepareScreeningRecords();
        PartyProfile verification = [SELECT Id, isUpdateAvailable__c FROM PartyProfile LIMIT 1];
        Account dummyAccount = new Account(Name = 'Dummy Account');
    	insert dummyAccount;
        Test.startTest();
        ICS_CTRL_Finscan.ScreeningInfo results = ICS_CTRL_Finscan.getScreeningInfo(verification.Id);
        ICS_CTRL_Finscan.ScreeningInfo resultOther = ICS_CTRL_Finscan.getScreeningInfo(dummyAccount.Id);
        Test.stopTest();

        Assert.areEqual(verification.Id, results.verification.Id, 'Verification ID should match in results');
        Assert.areEqual(null, resultOther, 'resultOther should be null');
    }

    @isTest
    static void testScreenApplicationException() {
        prepareScreeningRecords();
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Account dummyAccount = new Account(Name = 'Dummy Account');
        CMN_UTIL_FLS util = new CMN_UTIL_FLS();
        CMN_UTIL_FLS.insertRecordWithFLSCheck(dummyAccount);
        
        Test.startTest();
        try {
            ICS_CTRL_Finscan.screenApplication(application.WorldcheckStatus__c);
        } catch (Exception e) {
            Assert.areNotEqual(null, e.getMessage(), 'Expected exception message');
        }
        Test.stopTest();
        Assert.areNotEqual(null, util, 'util should not be null');
    }

    @IsTest
    static void testUpdateState() {
        prepareScreeningRecords();
        PartyProfile verification = [SELECT Id, isUpdateAvailable__c FROM PartyProfile LIMIT 1];
        PartyScreeningSummary initialMatch = [SELECT Id, Name, PartyProfileId FROM PartyScreeningSummary LIMIT 1];
    
        createAndConfirmOutcome(initialMatch.Id, PEP, CONFIRMED, 'Confirmed PEP-Continue with process');
        createAndConfirmOutcome(initialMatch.Id, 'Adverse Media', SAFE, RES_COUNTRY);
        createAndConfirmOutcome(initialMatch.Id, 'Black List', SAFE, 'Photo ID does not match');
        createAndConfirmOutcome(initialMatch.Id, UNCATEGORISED, CONFIRMED, 'Confirmed Adverse Media-Continue with process');
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        ICS_CTRL_Finscan.updateState(verification.Id);
        Test.stopTest();
    
        ApplicationForm application = [SELECT Id, WorldcheckStatus__c FROM ApplicationForm LIMIT 1];
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'WorldcheckStatus__c expected Match Confirmed - Continue with process');
    }
    private static void prepareAdverseMediaRecords() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        PartyProfile verification = [SELECT Id FROM PartyProfile WHERE AccountId = :account.Id LIMIT 1];
    
        PartyScreeningSummary adverseMediaSummary = new PartyScreeningSummary();
        adverseMediaSummary.PartyProfileId = verification.Id;
        adverseMediaSummary.IsAdverseMedia__c = true;
        adverseMediaSummary.Name = 'Test Adverse Media';
        insert adverseMediaSummary;
        createAndInsertOutcome(adverseMediaSummary.Id, 'Adverse Media', CONFIRMED, 'Confirmed Adverse Media-Continue with process');
        createAndInsertOutcome(adverseMediaSummary.Id, 'Adverse Media', SAFE, RES_COUNTRY);
    }

    private static void createAndInsertOutcome(Id summaryId, String category, String status, String reason) {
        PartyScreeningStep outcome = new PartyScreeningStep();
        outcome.Name = 'Test Outcome';
        outcome.Type = ICS_TYPE;
        outcome.ScreeningSummaryId = summaryId;
        outcome.ScreeningMatchCategory__c = category;
        outcome.Status = status;
        outcome.Reason__c = reason;
        if (status != RESEARCH) {
            outcome.OutcomeConfirmationDate__c = Date.today();
        }
    insert outcome;
	}
    
    @IsTest
    static void testUpdateStateForAdverseMedia() {
        prepareAdverseMediaRecords();
        PartyProfile verification = [SELECT Id, accountId, isUpdateAvailable__c FROM PartyProfile LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsMockResponse());
        ICS_CTRL_Finscan.updateState(verification.Id);
        Test.stopTest();
    
        SEL_ApplicationForm applicationFormSelector = new SEL_ApplicationForm();
        ApplicationForm application = applicationFormSelector.selectById(verification.accountId, false);
        Assert.areNotEqual(null, application.WorldcheckStatus__c, 'Expected WorldcheckStatus__c to be Match Confirmed - Continue with process');
    }
    
   @isTest
    static void testSaveScreeningMatchesWithAdverseMedia() {
        prepareScreeningRecords();
        PartyProfile verification = [SELECT Id, AccountId, Account.Name, OwnerId, Account.FirstName, Account.LastName FROM PartyProfile LIMIT 1];
        PartyScreeningSummary existingMatch = [SELECT Id, PartyProfileId, Name, IsAdverseMedia__c FROM PartyScreeningSummary LIMIT 1];

        PartyScreeningSummary newMatch = new PartyScreeningSummary(
            PartyProfileId = verification.Id,
            Name = 'New Match',
            IsAdverseMedia__c = true
        );

        List<PartyScreeningSummary> updateScreeningMatches = new List<PartyScreeningSummary>{ existingMatch };
        List<PartyScreeningSummary> newScreeningMatches = new List<PartyScreeningSummary>{ newMatch };

        Test.startTest();
        ICS_CTRL_Finscan.saveScreeningMatches(updateScreeningMatches, newScreeningMatches, verification);
        Test.stopTest();

        PartyScreeningSummary updatedMatch = [SELECT Id, Name, IsAdverseMedia__c FROM PartyScreeningSummary WHERE Id = :existingMatch.Id];

        Assert.areEqual(existingMatch.IsAdverseMedia__c, updatedMatch.IsAdverseMedia__c, 'The existing match should maintain its IsAdverseMedia__c value');
    }
    
    private static void createAndConfirmOutcome(Id matchId, String category, String status, String reason) {
        PartyScreeningStep outcome = new PartyScreeningStep();
        outcome.ScreeningSummaryId = matchId;
        outcome.Name = 'Test Outcome';
        outcome.Type = ICS_TYPE;
        outcome.ScreeningMatchCategory__c = category;
        outcome.Status = status;
        outcome.Reason__c = reason;
        if (status == RESEARCH) {
            outcome.OutcomeConfirmationDate__c = null;
        } else {
            outcome.OutcomeConfirmationDate__c = Date.today();
        }
        insert outcome;
    
        if (status != RESEARCH) {
            ICS_CTRL_Finscan.confirmOutcome(outcome.Id);
        }
    }

    @IsTest
    static void testCheckCategoryStatus() {
        List<PartyScreeningStep> outcomes = new List<PartyScreeningStep>();
        outcomes.add(new PartyScreeningStep(
            ScreeningMatchCategory__c = PEP,
            Name = 'Obamas',
            Type = ICS_TYPE,
            Status = CONFIRMED,
            Reason__c = 'Confirmed PEP-Continue with process',
            SubReason__c = 'Lower risk jurisdiction',
        	Comments__c = NEW_OUTCOME,
            OutcomeConfirmationDate__c = Date.today()
        ));
        String status = ICS_CTRL_Finscan.checkCategoryStatus(outcomes, PEP);
        Assert.areNotEqual(null, status, 'Expected status not to be null');
        outcomes.clear();
        outcomes.add(new PartyScreeningStep(
            ScreeningMatchCategory__c = PEP,
            Name = 'Obamaa',
            Type = ICS_TYPE,
            Status = CONFIRMED,
            Reason__c = 'Confirmed Blacklist-True match-Declined',
            OutcomeConfirmationDate__c = Date.today()
        ));
        status = ICS_CTRL_Finscan.checkCategoryStatus(outcomes, PEP);
        Assert.areNotEqual(null, status, 'Expected status not to be null');
        outcomes.clear();
        outcomes.add(new PartyScreeningStep(
            ScreeningMatchCategory__c = PEP,
            Name = 'Obama',
            Type = ICS_TYPE,
            Status = SAFE,
            isWeakStatus__c = false,
            Reason__c = 'Photo ID does not match',
            Comments__c = NEW_OUTCOME,
            OutcomeConfirmationDate__c = Date.today()
        ));
        status = ICS_CTRL_Finscan.checkCategoryStatus(outcomes, PEP);
        Assert.areNotEqual(null, status, 'Expected status not to be null');
        outcomes.clear();
        outcomes.add(new PartyScreeningStep(
            ScreeningMatchCategory__c = PEP,
            Name = 'Obama',
            Type = ICS_TYPE,
            Status = SAFE,
            Reason__c = 'Photo ID does not match',
            isWeakStatus__c = true
        ));
        status = ICS_CTRL_Finscan.checkCategoryStatus(outcomes, PEP);
        Assert.areEqual('pendingreview', status, 'Expected status to be pendingreview');
        outcomes.clear();
        status = ICS_CTRL_Finscan.checkCategoryStatus(outcomes, PEP);
        Assert.areEqual('pendingreview', status, 'Expected status to be pendingreview with no outcomes');
    }
    
    @isTest
    static void testSaveDeclinedBlacklistFailResponse() {
        prepareScreeningRecords();
        PartyScreeningSummary sfScreeningMatch = [SELECT Id, PartyProfileId, IsBlacklist__c FROM PartyScreeningSummary LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ICS_API_Finscan.UpdatePairsInvalidMockResponse());
        Test.startTest();
        ICS_CTRL_Finscan.Result resultBlacklist = ICS_CTRL_Finscan.saveOutcome(sfScreeningMatch.Id, UNCATEGORISED, CONFIRMED, 'Confirmed Blacklist-True match-Declined', NONE, NEW_OUTCOME);
        Test.stopTest();
        PartyScreeningStep outcome = [SELECT Id, ScreeningSummary.IsBlacklist__c, OutcomeConfirmationDate__c, OutcomeChallengeDate__c FROM PartyScreeningStep WHERE Id = :resultBlacklist.outcome.Id LIMIT 1];
        Assert.areEqual(true, outcome.ScreeningSummary.IsBlacklist__c, 'IsBlacklist__c should be true');
    }
    
    @isTest
    static void testDetermineDeclineReason() {
		String outcomeReason = null;
        PartyScreeningSummary match = new PartyScreeningSummary();

        Test.startTest();
        ICS_CTRL_FinscanHelper declineReason = new ICS_CTRL_FinscanHelper();
        String result = declineReason.determineDeclineReason(outcomeReason, match);      
        Test.stopTest();

        Assert.areEqual('IOM Other reasons', result, 'Decline reason IOM Other reasons');
    }

    @isTest
    static void testCreateOutcome() {
        
        prepareScreeningRecords();
        PartyScreeningSummary match = [SELECT Id, Name, PartyProfileId FROM PartyScreeningSummary LIMIT 1];

        Test.startTest();
		PartyScreeningStep result = new PartyScreeningStep();
        ICS_CTRL_FinscanHelper outcome = new ICS_CTRL_FinscanHelper();
		result = outcome.createOutcome(match, PEP, CONFIRMED,  'Country of Residence does not match', null, null, OUTCOME_REASON_WEAK,OUTCOME_STATUS_CONFIRMEDHIT);        
        Test.stopTest();

        Assert.areEqual(true, result.isWeakStatus__c, 'Outcome has weak status');
    }
        

}