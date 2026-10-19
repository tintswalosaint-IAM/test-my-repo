/**
 * Created by Łukasz Kojzar on 13.10.2022.
 * @description Unit test class for CMN_BATCH_AccountMaintenance
 * SFP-18188
 */

@IsTest
private class CMN_BATCH_AccountMaintenance_Test {
    private static final String GHANA = 'GH';
    private static final Id ACCOUNT_RECORDTYPE_PERSON = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    @IsTest
    private static void reassigningAccountTest() {
        List<Account> testAccounts = new CMN_AccountMaintenance_TestDataFactory(true).createPersonAccounts(
            5, ACCOUNT_RECORDTYPE_PERSON
        );

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User testUser = new CMN_AccountMaintenance_TestDataFactory(true).createUsers(
            1,profileId, 'XBWER', 'XBWER', 'RM Assistant'
        ).get(0);

        Database.SaveResult result = Database.update(testAccounts[0], false);

        Test.startTest();

            System.runAs(testUser) {
                CMN_BATCH_AccountMaintenance.run(200);
                CMN_SRV_AccountOwnerUpdate.handleError(result,testAccounts[0]);
            }

        Test.stopTest();

        Account acc = [SELECT OwnerId, RelationshipMgrCode__c, Owner.RM_AE_Code__c, Name FROM Account WHERE Id IN: testAccounts].get(0);
        Assert.areEqual(acc.OwnerId, testUser.Id, 'Account owner should be alligned with test user');
        Assert.areEqual(acc.RelationshipMgrCode__c, acc.Owner.RM_AE_Code__c, 'RM AE Code on Account and User match');
    }

    @IsTest
    private static void scheduleBatchTest() {

        Test.startTest();

            CMN_BATCH_AccountMaintenance.scheduleMe('TestJob192898');
            Assert.areEqual(1,[SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :'TestJob192898' LIMIT 1].size(), 'There should be 1 scheduled job with this name');

            CMN_BATCH_AccountMaintenance.unscheduleMe('TestJob192898');
            Assert.areEqual(0,[SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :'TestJob192898' LIMIT 1].size(), 'Job should be unscheduled');

        Test.stopTest();
    }
}