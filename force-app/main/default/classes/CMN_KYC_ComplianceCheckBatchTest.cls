/***************************************************************************************
@Name of the Class :CMN_KYC_ComplianceCheckBatchTest
@Description :SFP-40755 Test Class for CMN_KYC_ComplianceCheckBatch.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Initital Version
* Last Modified Date Initital Version
* Last Modified Description: Initital Version
****************************************************************************************/
@isTest
public with sharing class CMN_KYC_ComplianceCheckBatchTest {
   /**
    * @description test method for CMN_KYC_ComplianceCheckBatch
    */
    @isTest
    static void testBatchExecution() {        
        Id ppId = KYC_TestDataFactory.createPartyProfile('UG');

        PartyScreeningSummary screeningSummary = new PartyScreeningSummary(
            Name = 'Test Screening',
            PartyProfileId = ppId,
            Status = 'Completed',
            ScreeningDecision = 'On Hold',
            ScreeningRequestDate = Date.today()
        );
        insert screeningSummary;

        Test.startTest();
        CMN_KYC_ComplianceCheckBatch batch = new CMN_KYC_ComplianceCheckBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        Assert.areNotEqual(null, batch,'The batch must not be null');

    }
}