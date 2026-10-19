/***************************************************************************************
@Name of the Class :KYC_SRV_GetRAASResults_Test
@Description :SFP-40754 Test Class for KYC_SRV_GetRAASResults
@Author :Dayakar 
@Created Date :O6 Nov 2024
***************************************************************************************/
@IsTest
public class KYC_SRV_GetRAASResults_Test {
    
    /**
     * @description Test method for getRassCallTest to test positive results
     */
    @IsTest
    private static void getRassCallTest() {
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('UG');
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary',status='Completed', PartyProfileId = profileProfileId);
        insert testSummary;
        Test.startTest();
        KYC_DTO_Response response = KYC_SRV_GetRAASResults.getRassCall(profileProfileId);
        Test.stopTest();
        Assert.areEqual('Success', response.status,'The Get RAAS Results API should return a response');
    }
    
    /**
     * @description Test method for getRassCallTest to test positive results
     */
    @IsTest
    private static void getRassCallNegTest() {
        Id profileProfileId =KYC_TestDataFactory.createPartyProfile('UG');
        try {
            PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary',status='In Progress', PartyProfileId = profileProfileId);
            insert testSummary;
            Test.startTest();
            KYC_SRV_GetRAASResults.getRassCall(profileProfileId);
            Test.stopTest();
        } catch(Exception e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Extpected error :List has no rows for assignment to SObject');
        }
    }

}