/***************************************************************************************
@Name of the Class :KYC_SCHED_ComplianceCheck_Test
@Description :SFP-40755 Test Class for KYC_SCHED_ComplianceCheck.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
 @IsTest
public class KYC_SCHED_ComplianceCheck_Test {
    /**
    * @description test method for KYC_SCHED_ComplianceCheck
    */
    @IsTest
    static void testScheduler() {
        KYC_SCHED_ComplianceCheck scheduler = new KYC_SCHED_ComplianceCheck();
        
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Job', '0 0 0 * * ?', scheduler);
        Test.stopTest();
        Assert.areEqual(true, jobId !=null, 'Job should be scheduled and have a job ID.');
        
    }
}