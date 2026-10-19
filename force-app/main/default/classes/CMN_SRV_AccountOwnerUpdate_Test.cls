/**
* @description Unit test class for CMN_SRV_AccountOwnerUpdate
*
* @author Karabo Machubeni
*
* @date August 2023
*/
@isTest
private class CMN_SRV_AccountOwnerUpdate_Test{
	
	
	private static final String SOUTH_AFRICA = 'ZA';
	private static final Id ACCOUNT_RECORDTYPE_PERSON =
	Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
	@isTest
	private static void processAccountsTest() {
		final String TEST_CODE = 'testCode';
		Account acc = new Account();
		acc.RecordTypeId = ACCOUNT_RECORDTYPE_PERSON;
		acc.FirstName = 'Jan';
		acc.LastName = 'Kowalski';
		acc.ExternalCIFCountry__c = SOUTH_AFRICA;
		acc.VIPIndicator__c = true;
		acc.RelationshipMgrCode__c = TEST_CODE;
		
		List<Account> testAccounts = new List<Account>();
		testAccounts.add(acc);

		Account acc2 = acc.clone();
		acc.FirstName = 'Sam';
		acc.LastName = 'Pavlovski';
		testAccounts.add(acc2);

		insert testAccounts;
		
		User testUser = AOB_DAL_TestFactory.createUser('System Administrator', false);
		testUser.RM_AE_Code__c = TEST_CODE;
		insert testUser;
		
		acc = [SELECT RelationshipMgrCode__c, OwnerId, Name FROM Account WHERE Id = :acc.Id];
        Assert.areNotEqual(acc.OwnerId, testUser.Id, 'Account should not be assigned to the test user at this stage');

        Database.SaveResult result = Database.update(acc, false);
		
		Test.startTest();
			CMN_SRV_AccountOwnerUpdate.processAccounts(testAccounts);
			CMN_SRV_AccountOwnerUpdate.handleError(result,acc);
		Test.stopTest();
		
		acc = [SELECT OwnerId, Name FROM Account WHERE Id = :acc.Id];
		Assert.areEqual(acc.OwnerId, testUser.Id, 'Account owner should be alligned with test user');
		
	}
	
}