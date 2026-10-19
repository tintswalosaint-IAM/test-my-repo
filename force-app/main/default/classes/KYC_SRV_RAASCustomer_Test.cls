/***************************************************************************************
@Name of the Class :KYC_SRV_RAASCustomer_Test
@Description :SFP-40754 Test Class for KYC_SRV_RAASCustomer
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version 
****************************************************************************************/
@isTest
private class KYC_SRV_RAASCustomer_Test {
    /**
     * @description Test method for callRAASCustomerTest to test positive results
     */
    @IsTest
    private static void callRAASCustomerTest() {
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('UG');
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary',status='In Progress', PartyProfileId = profileProfileId);
        insert testSummary;
        Test.startTest();
        KYC_DTO_Response response = KYC_SRV_RAASCustomer.callRAASCustomer(profileProfileId);
        Test.stopTest();
        Assert.areEqual('Success', response.status);
    }
    /**
     * @description Test method for callRAASCustomerNegativeTest to test negative results
     */
    @IsTest
    private static void callRAASCustomerNegativeTest() {
        KYC_TestDataFactory.createPartyProfile('UG');
        try {
          Test.startTest();  
          KYC_SRV_RAASCustomer.callRAASCustomer(null);
          Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('Attempt to de-reference a null object', e.getMessage(), 'Attempt to de-reference a null object');
        }
    }

    /**
     * @description Test method for getRassResultsTest to test positive results
     */
    @isTest
    public static void getRassResultsTest(){
        List< object > screeningResults = new List< object >();
        Map<String ,String> screeningResultMap = new Map<String ,String>();
        screeningResultMap.put('screeningType','Sanction Status');
        screeningResultMap.put('result','Pass');
        screeningResults.add(screeningResultMap);
        screeningResultMap = new Map<String ,String>();
        screeningResultMap.put('screeningType','Prominent Influential Persons (PIP)');
        screeningResultMap.put('result','Fail');
        screeningResults.add(screeningResultMap);
        screeningResultMap = new Map<String ,String>();
        screeningResultMap.put('screeningType','CRA High Risk Review');
        screeningResultMap.put('result','Pass');
        screeningResults.add(screeningResultMap);
        Test.startTest();
        Map<String ,String> rassResults = KYC_SRV_RAASCustomer.getRassResults(screeningResults);
        Test.stopTest();
        assert.areEqual(rassResults.get('Sanction Screening'),'Pass');
        assert.areEqual(rassResults.get('PIP/FPPO'),'Fail');
        assert.areEqual(rassResults.get('Credit Risk Assessment'),'Pass');
    }  
    
    /**
     * @description Test method for getRassResultsTest to test positive results
     */
    @isTest
    public static void updatepartyScreeningSummaryCompletedAndFulfilledTest() {
        Id pssId =  KYC_TestDataFactory.createPartyScreening(null);
        PartyScreeningSummary p = new SEL_PartyScreeningSummary().selectById(pssId);
        Map<String, Object> assessmentResult = new Map<String, Object>();
        assessmentResult.put('result', 'Fulfilled');
        assessmentResult.put('status', 'Completed');
        Map<String ,String> screeningResultMap = new Map<String ,String>();
        screeningResultMap.put('screeningType','CRA High Risk Review');
        screeningResultMap.put('result','Pass');
        assessmentResult.put('screeningResults', new List<Object>{ screeningResultMap });
        Test.startTest();
        KYC_SRV_RAASCustomer.updatepartyScreeningSummary(p, assessmentResult);
        Test.stopTest();
        PartyScreeningSummary updatedSummary = [SELECT Id, Status, ScreeningDecision FROM PartyScreeningSummary WHERE Id = :pssId];
        assert.areEqual('Clear', updatedSummary.ScreeningDecision);
    }
    /**
     * @description Test method for updatepartyScreeningSummaryCompletedAndAcceptableRiskTest to test positive results
     */
    @isTest
    public static void updatepartyScreeningSummaryCompletedAndAcceptableRiskTest() {
        Id pssId =  KYC_TestDataFactory.createPartyScreening(null);
        PartyScreeningSummary p = new SEL_PartyScreeningSummary().selectById(pssId);
        Map<String, Object> assessmentResult = new Map<String, Object>();
        assessmentResult.put('result', 'AcceptableRisk');
        assessmentResult.put('status', 'Completed');
        Map<String ,String> screeningResultMap = new Map<String ,String>();
        screeningResultMap.put('screeningType','CRA High Risk Review');
        screeningResultMap.put('result','Pass');
        assessmentResult.put('screeningResults', new List<Object>{ screeningResultMap });
        Test.startTest();
        KYC_SRV_RAASCustomer.updatepartyScreeningSummary(p, assessmentResult);
        Test.stopTest();
        PartyScreeningSummary updatedSummary = [SELECT Id, Status, ScreeningDecision FROM PartyScreeningSummary WHERE Id = :pssId];
        assert.areEqual('AcceptableRisk', updatedSummary.ScreeningDecision);
    }
    /**
     * @description Test method for updatepartyScreeningSummaryPendingAndInProgressTest to test pending results
     */
    @isTest
    public static void updatepartyScreeningSummaryPendingAndInProgressTest() {
        Id pssId =  KYC_TestDataFactory.createPartyScreening(null);
        PartyScreeningSummary p = new SEL_PartyScreeningSummary().selectById(pssId);
        Map<String, Object> assessmentResult = new Map<String, Object>();
        assessmentResult.put('result', 'pending');
        assessmentResult.put('status', 'In Progress');
        Map<String ,String> screeningResultMap = new Map<String ,String>();
        screeningResultMap.put('screeningType','CRA High Risk Review');
        screeningResultMap.put('result','Pass');
        assessmentResult.put('screeningResults', new List<Object>{ screeningResultMap });
        Test.startTest();
        KYC_SRV_RAASCustomer.updatepartyScreeningSummary(p, assessmentResult);
        Test.stopTest();
        PartyScreeningSummary updatedSummary = [SELECT Id, Status, ScreeningDecision FROM PartyScreeningSummary WHERE Id = :pssId];
        assert.areEqual('On Hold', updatedSummary.ScreeningDecision);
    }
    
    /**
     * @description Test method for updateParty Screening Step to test positive results
     */
    @isTest
    public static void updatePartyScreeningCompletedStepTest(){
        Id screeingSummaryId = KYC_TestDataFactory.createPartyScreening(null);
        KYC_TestDataFactory.createPartyScreeningStep(screeingSummaryId, 'Completed');
        Map<String ,String> rassResults = new Map<String ,String>();
        rassResults.put('PEP', 'Approved');
        Test.startTest();
        KYC_SRV_RAASCustomer.updatePartyScreeningStep(screeingSummaryId, rassResults, false);
        Test.stopTest();
        List<PartyScreeningStep> partyScreeningStepsList = new SEL_PartyScreeningStep().selectBySummaryIds(new Set<Id>{screeingSummaryId});
        assert.areEqual(partyScreeningStepsList[0].Status, 'Completed', 'Update completed');
    }
    /**
     * @description Test method for updateParty Screening Step to test positive results
     */
    @isTest
    public static void updatePartyScreeningStepSanctionScreeningTest(){
        Id screeingSummaryId = KYC_TestDataFactory.createPartyScreening(null);
        KYC_TestDataFactory.createPartyScreeningStep(screeingSummaryId, 'Completed');
        Map<String ,String> rassResults = new Map<String ,String>();
        rassResults.put('Sanction Screening', 'Approved');
        Test.startTest();
        KYC_SRV_RAASCustomer.updatePartyScreeningStep(screeingSummaryId, rassResults, true);
        Test.stopTest();
        List<PartyScreeningStep> partyScreeningStepsList = new SEL_PartyScreeningStep().selectBySummaryIds(new Set<Id>{screeingSummaryId});
        assert.areEqual(partyScreeningStepsList[0].Status, 'Completed', 'Update completed');
    }

    /**
     * @description Test method for checkPartyprofileVerificationTest to test positive results
     */
    @isTest
    public static void checkPartyprofileVerificationTest() {
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(ppId, 'Completed', 'Accepted');
        Test.startTest();
        Boolean isVerification = KYC_SRV_RAASCustomer.checkPartyprofileVerification(ppId);
        Test.stopTest();
        assert.areEqual(true, isVerification);
    }
    /**
     * @description Test method for checkPartyprofileVerificationTest to test negative results
     */
    @isTest
    public static void checkPartyprofileVerificationNegativeTest() {
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');
        KYC_TestDataFactory.createPartyPartyIdentityVerification(ppId, '', '');
        Test.startTest();
        Boolean isVerification = KYC_SRV_RAASCustomer.checkPartyprofileVerification(ppId);
        Test.stopTest();
        assert.areEqual(false, isVerification);
    }

    /**
     * @description Test method for getRaasCodeTest to test positive results
     */
    @isTest
    public static void getRaasCodeTest() {
        Test.startTest();
        String str=KYC_SRV_RAASCustomer.getRaasCode('Self Employed');
        Test.stopTest();
        assert.areEqual(str, 'self_employed');
    }
}