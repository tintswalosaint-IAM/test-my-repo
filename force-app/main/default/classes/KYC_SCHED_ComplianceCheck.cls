/***************************************************************************************
@Name of the Class :KYC_SCHED_ComplianceCheck
@Description : SFP-32973 class is used to Schedule ComplianceCheck Batch
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public  With Sharing  class KYC_SCHED_ComplianceCheck implements Schedulable {
	    public void execute(SchedulableContext sc) {
        CMN_KYC_ComplianceCheckBatch batchJob = new CMN_KYC_ComplianceCheckBatch();
        
        Database.executeBatch(batchJob);
    }
}