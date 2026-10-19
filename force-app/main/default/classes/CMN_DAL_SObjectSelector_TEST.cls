/**
 * @description Class has base methods that can be used to test the account search result
 * <p/>
 * <p>VCCC-378</p>
 *
 * @see CMN_DAL_SObjectSelector
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_SObjectSelector_TEST
{
	@IsTest
	private static void findByName()
	{
		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		Account foundAccount = (Account)CMN_DAL_SObjectSelector.findByName(Account.SObjectType, newAccount.Name, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

		Test.stopTest();

		System.assert(foundAccount != null, 'Object not found by Name.');
	}

	/**
	 * @description To test the search result of duplicate accounts
	 */
	@IsTest
	private static void findByNameDuplicate()
	{
		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();
		newAccount.Id = null;
		insert newAccount;

		Test.startTest();

		try
		{
			CMN_DAL_SObjectSelector.findByName(Account.SObjectType, newAccount.Name, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

			System.assert(false, 'Exception not thrown for more than 1 result');
		}
		catch(SearchException error)
		{
			System.assert(true, 'Exception thrown for finding more than 1 result');
		}

		Test.stopTest();
	}

	/**
	 * @description To test the search result of duplicate accounts not found
	 */
	@IsTest
	private static void findByNameNoResults()
	{
		Test.startTest();

		Account foundAccount = (Account)CMN_DAL_SObjectSelector.findByName(Account.SObjectType, CMN_DAL_SObjectDomain.generateRandomName(), new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

		Test.stopTest();

		System.assert(foundAccount == null, 'There should be no search results');
	}

	/**
	 * @description To test the search result of accounts
	 */
	@IsTest
	private static void findListById()
	{
		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		List<Account> foundAccounts = CMN_DAL_SObjectSelector.findById(Account.SObjectType, new Set<Id> {newAccount.Id}, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

		Test.stopTest();

		System.assertNotEquals(true, foundAccounts.isEmpty(), 'Objects not found by Id.');
	}

	/**
	 * @description To test the search result from Account by Id
	 */
	@IsTest
	private static void findById()
	{
		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		Account foundAccount = (Account)CMN_DAL_SObjectSelector.findById(Account.SObjectType, newAccount.Id, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

		Test.stopTest();

		System.assert(foundAccount != null, 'Object not found by Id.');
	}

	/**
	 * @description To test the search result from Account by object
	 */
	@IsTest
	private static void findByIdObjectName()
	{
		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		Account foundAccount = (Account)CMN_DAL_SObjectSelector.findById(CMN_DAL_Account.OBJECT_NAME, newAccount.Id, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

		Test.stopTest();

		System.assert(foundAccount != null, 'Object not found by Id.');
	}

	/**
	 * @description To test the search result from Account
	 */
	@IsTest
	private static void findByNameMultiple()
	{
		Account newAccount = CMN_DAL_DataFactory.insertBusinessAccount();
		newAccount.Id = null;
		insert newAccount;

		Test.startTest();

		Account foundAccount = (Account)CMN_DAL_SObjectSelector.findByField(Account.SObjectType, Account.Name, newAccount.Name, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME}, false);

		System.assert(foundAccount == null, 'No results should be returned when more than 1 item is found');

		Test.stopTest();
	}

	/**
	 * @description To test the scenario if no result found in the object.
	 */
	@IsTest
	private static void findWithNoSearchValues()
	{
		CMN_DAL_DataFactory.insertBusinessAccount();

		Test.startTest();

		List<Account> foundAccounts = CMN_DAL_SObjectSelector.findByField(CMN_DAL_Account.OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_NAME, new Set<String> (), new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

		Test.stopTest();

		System.assertEquals(true, foundAccounts.isEmpty(), 'No Objects should be found without search values');
	}

	@IsTest
	private static void testQueryStringFound()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final CMN_Foobar__c queried = (CMN_Foobar__c)CMN_DAL_SObjectSelector.query(created.Id);
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Id, queried.Id);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQueryStringNotFound()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final String anId = created.Id;
		delete created;
		final CMN_Foobar__c queried = (CMN_Foobar__c)CMN_DAL_SObjectSelector.query(anId);
		System.assertEquals(null, queried);
	}

	@IsTest
	private static void testQueryStringListString()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final CMN_Foobar__c queried = (CMN_Foobar__c)CMN_DAL_SObjectSelector.query(created.Id, new List<String> {'Id', 'Name'});
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Id, queried.Id);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQueryStringSetString()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final CMN_Foobar__c queried = (CMN_Foobar__c)CMN_DAL_SObjectSelector.query(created.Id, new Set<String> {'Id', 'Name'});
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Id, queried.Id);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQueryListString()
	{
		final List<CMN_Foobar__c> created = new List<CMN_Foobar__c>
		{
				new CMN_Foobar__c(Name = 'test 123'), new CMN_Foobar__c(Name = 'test ABC')
		};
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(CMN_UTIL_Array.objectToString(CMN_UTIL_Array.pluck(created, 'Id')));
		System.assertNotEquals(null, records);
		System.assertEquals(2, records.size());
		final Set<Object> names = CMN_UTIL_Set.listToSet(CMN_UTIL_Array.pluck(created, 'Name'));
		System.assertNotEquals(null, names);
		System.assertEquals(2, names.size());
		System.assert(names.contains('test 123'));
		System.assert(names.contains('test ABC'));
	}

	@IsTest
	private static void testQuerySetString()
	{
		final List<CMN_Foobar__c> created = new List<CMN_Foobar__c>
		{
				new CMN_Foobar__c(Name = 'test 123'), new CMN_Foobar__c(Name = 'test ABC')
		};
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(CMN_UTIL_Set.listToSet(CMN_UTIL_Array.objectToString(CMN_UTIL_Array.pluck(created, 'Id'))));
		System.assertNotEquals(null, records);
		System.assertEquals(2, records.size());
		final Set<Object> names = CMN_UTIL_Set.listToSet(CMN_UTIL_Array.pluck(created, 'Name'));
		System.assertNotEquals(null, names);
		System.assertEquals(2, names.size());
		System.assert(names.contains('test 123'));
		System.assert(names.contains('test ABC'));
	}

	@IsTest
	private static void testQueryListStringListString()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(new List<String> {created.Id}, new List<String> {'Id', 'Name'});
		System.assertNotEquals(null, records);
		System.assertEquals(1, records.size());
		final CMN_Foobar__c queried = records.get(0);
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQueryListStringSetString()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(new List<String> {created.Id}, new Set<String> {'Id', 'Name'});
		System.assertNotEquals(null, records);
		System.assertEquals(1, records.size());
		final CMN_Foobar__c queried = records.get(0);
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQuerySetStringListString()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(new Set<String> {created.Id}, new List<String> {'Id', 'Name'});
		System.assertNotEquals(null, records);
		System.assertEquals(1, records.size());
		final CMN_Foobar__c queried = records.get(0);
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQuerySetStringSetStringOne()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'test 123');
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(new Set<String> {created.Id}, new Set<String> {'Id', 'Name'});
		System.assertNotEquals(null, records);
		System.assertEquals(1, records.size());
		final CMN_Foobar__c queried = records.get(0);
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQuerySetStringSetStringTwo()
	{
		final CMN_Foobar__c created = new CMN_Foobar__c(Name = 'Smith');
		insert created;
		final List<CMN_Foobar__c> records = CMN_DAL_SObjectSelector.query(new Set<String> {created.Id}, new Set<String> {'Id', 'Name'});
		System.assertNotEquals(null, records);
		System.assertEquals(1, records.size());
		final CMN_Foobar__c queried = records.get(0);
		System.assertNotEquals(null, queried);
		System.assertEquals(created.Name, queried.Name);
	}

	@IsTest
	private static void testQuerySetStringSetStringErrorEmptySet()
	{
		Boolean exceptionCaught = false;
		try
		{
			CMN_DAL_SObjectSelector.query(
					new Set<String>(),
					new Set<String>() //<= is empty so IllegalArgumentException should be thrown
			);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
	}

	@IsTest
	private static void testQuerySetStringSetStringErrorBadIds()
	{
		Boolean exceptionCaught = false;
		try
		{
			CMN_DAL_SObjectSelector.query(
					new Set<String> {'x', 'y'}, //<= invalid Ids so IllegalArgumentException should be thrown
					new Set<String>()
			);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
	}

	@IsTest
	private static void testQuerySetStringSetStringErrorDupPrefixes()
	{
		Boolean exceptionCaught = false;
		try
		{
			CMN_DAL_SObjectSelector.query(
					new Set<String> {'001012345678901234', '003012345678901234'}, //<= key prefixes 001 & 003 differ
					new Set<String>()
			);
		}
		catch(IllegalArgumentException e)
		{
			exceptionCaught = true;
		}
		System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
	}

	@IsTest
	private static void testInstance()
	{
		CMN_DAL_SObjectSelector.ISObjectSelector foobarSelector = new CMN_DAL_SObjectSelector (CMN_Foobar__c.SObjectType);
		System.assertEquals(CMN_Foobar__c.SObjectType, foobarSelector.sObjectType());
		System.assert(foobarSelector.selectSObjectsById(new Set<Id> {CMN_UTIL_Random.randomSObjectId(CMN_Foobar__c.SObjectType)}).isEmpty());
	}

}