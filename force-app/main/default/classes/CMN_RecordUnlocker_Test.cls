/***************************************************************************************
@Author            :Karabo Machubeni
@Date              :January 2024
@Name of the Class :CMN_RecordUnlocker_Test
@description       :Test class for CMN_RecordUnlocker
@Modification description :  SFP-23329
***************************************************************************************/
@isTest
private with sharing class CMN_RecordUnlocker_Test{
	
	@isTest 
	static void passedUnlockRecord() {
		
		Boolean lockEnabled;
		
		Account testAccount1 = new Account(Name = 'John Smith');
		insert testAccount1;
		
		List<Id> recordIdsToUnlock = new List<Id>{testAccount1.Id};
		
		Approval.lock(recordIdsToUnlock);
		
		lockEnabled = Approval.isLocked(testAccount1.Id);
		Assert.areEqual(true,lockEnabled,'Record should be locked');
		
		
		Test.startTest();
		CMN_RecordUnlocker.unlockRecords(recordIdsToUnlock);		
		Test.stopTest();
		
		testAccount1 = [SELECT Id, Name FROM Account WHERE Id =: testAccount1.Id LIMIT 1];
		lockEnabled = Approval.isLocked(testAccount1);
		
		
		Assert.areEqual(false, lockEnabled,'Record should be unlocked');
		
	}
	
	@isTest
	static void failedUnlockRecord() {
		
		Account testAccount = new Account(Name = 'Test Account');
		insert testAccount;
		
		User unauthorizedUser= [SELECT Id FROM User WHERE userrole.name = 'SA W&I CSC' AND IsActive=true LIMIT 1];
		
		List<Id> recordIdsToUnlock = new List<Id>{testAccount.Id};
		
		
		try{
			System.runAs(unauthorizedUser) {
				
				CMN_RecordUnlocker.unlockRecords(recordIdsToUnlock);
				
			}
		}
		catch(Exception e){
			Assert.areEqual(true,e.getMessage().contains('Process failed'));
		}
		
	}
	
	
	
	
}