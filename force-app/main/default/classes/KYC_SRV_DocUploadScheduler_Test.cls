/***************************************************************************************
@Name of the Class :KYC_SRV_DocUploadScheduler_Test
@Description :Test class to cover document ipload functionality.	
@Author :Irshad 
@Created Date :28/01/2026
***************************************************************************************
* Last Modified By  Initital Version
* Last Modified Date Initital Version
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_SRV_DocUploadScheduler_Test {

    @IsTest
    static void testScheduleAfter5Minutes_CreatesCronTrigger() {
        // Arrange: dummy IDs are fine because we won't execute async       
        Id fakePartyProfileId = generateFakeId(Account.SObjectType, 1);
        List<Id> fakeContentDocIds = new List<Id>{
            generateFakeId(ContentDocument.SObjectType, 1)
        };
       

        // Act: schedule the job (CronTrigger is created immediately)
        KYC_SRV_DocUploadScheduler.scheduleAfter5Minutes(fakePartyProfileId, fakeContentDocIds);

        // Assert
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name, State, CronExpression
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE 'KYC_DocUploadRetry_%'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        Assert.areEqual(1, jobs.size(), 'One scheduled job should be created');
        
    }

    @IsTest
    static void testBuildCronIndirectly_CronIsValidFormat() {
        Id fakePartyProfileId = generateFakeId(Account.SObjectType, 1);       
        List<Id> fakeContentDocIds = new List<Id>{
            generateFakeId(ContentDocument.SObjectType, 1)
        };

        KYC_SRV_DocUploadScheduler.scheduleAfter5Minutes(fakePartyProfileId, fakeContentDocIds);

        CronTrigger ct = [
            SELECT CronExpression
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE 'KYC_DocUploadRetry_%'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        // Basic sanity check (cron has 7 parts for scheduled apex)
        Assert.areEqual(
            7,
            ct.CronExpression.split('\\s+').size(),
            'Cron expression should contain 7 parts'
        );
    }

    private static Id generateFakeId(Schema.SObjectType sObjectType, Integer index) {
        String keyPrefix = sObjectType.getDescribe().getKeyPrefix();
        return Id.valueOf(keyPrefix + String.valueOf(index).leftPad(12, '0'));
    }
}