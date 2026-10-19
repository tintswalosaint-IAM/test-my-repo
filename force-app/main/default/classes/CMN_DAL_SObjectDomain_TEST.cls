/**
 * @description Class has base methods that can be used to test and DAL class of Base Object
 *
 * @see CMN_DAL_SObjectDomain VCCC-378
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_SObjectDomain_TEST
{
	private static final String REF_PHONE_NUMBER = '1234567890';
	private static final Integer NUMBER_BOOLEANS_TO_GENERATE = 20;
	private static final String DOT = '.';
	private static final String IDD1 = '001000000000001AAA';
	private static final String IDD2 = '001000000000002AAA';
	private static final String IDD3 = '001000000000003AAA';


	/**
	 * @description Method is use to test the new Object
	 */
	@IsTest
	private static void newObject()
	{
		SObject a = CMN_DAL_SObjectDomain.newObject(CMN_DAL_Account.OBJECT_NAME);

		Schema.SObjectType expected = Account.SObjectType;
		System.assertEquals(expected, a.getSObjectType());

		//Null object
		SObject empty = CMN_DAL_SObjectDomain.newObject(CMN_DAL_SObjectDomain.generateRandomName());
		System.assertEquals(null, empty);
	}

	/**
	 * @description Method is use to test the database error handling when update failed
	 */
	@IsTest
	private static void failedUpdateDatabase()
	{
		Account a = CMN_DAL_DataFactory.newBusinessAccount();
		a.Name = CMN_UTIL_String.EMPTY;
		List<Account> accounts = new List<Account>();

		accounts.add(a);

		//TEST 1 - Insert object (Causes exception but does not fail because allInsertsMustSucceed=false)
		Boolean isInserted = CMN_DAL_SObjectDomain.insertDBObjects(accounts, false);
		System.assertEquals(isInserted, false, 'Expected Insert to Fail');

		//TEST 2 - Update object (Causes exception but does not fail because allUpdatesMustSucceed=false)
		Boolean isUpdated = CMN_DAL_SObjectDomain.updateDBObjects(accounts, false);
		System.assertEquals(isUpdated, false, 'Expected Update to Fail');

		//TEST 3
		//Preparing test data;
		accounts = new List<Account>();
		Account a2 = CMN_DAL_DataFactory.newBusinessAccount();
		accounts.add(a2);
		isInserted = CMN_DAL_SObjectDomain.insertDBObjects(accounts, true);

		//Deleting objects
		Boolean isDeleted = CMN_DAL_SObjectDomain.deleteDBObjects(accounts, true);

		//Deleting objects second time causes exception but does not fail because allDeletesMustSucceed=false
		isDeleted = CMN_DAL_SObjectDomain.deleteDBObjects(accounts, false);
		System.assertEquals(isDeleted, false);
	}

	/**
	 * @description Will test random date generation
	 */
	@IsTest
	private static void generateRandomDate()
	{
		Test.startTest();

		Date date1 = CMN_DAL_SObjectDomain.generateRandomDate();
		Date date2 = CMN_DAL_SObjectDomain.generateRandomDate();

		Test.stopTest();

		System.assertNotEquals(date1, date2, 'Dates not Random');
		System.assertNotEquals(true, date1.isSameDay(date2), 'Dates should not be on same day');
	}

	/**
	 * @description Will test random date time generation
	 */
	@IsTest
	private static void generateRandomDateTime()
	{
		Test.startTest();

		Datetime dateTime1 = CMN_DAL_SObjectDomain.generateRandomDateTime();
		Datetime dateTime2 = CMN_DAL_SObjectDomain.generateRandomDateTime();

		Test.stopTest();

		System.assertNotEquals(dateTime1, dateTime2, 'Dates not random');
		System.assertNotEquals(true, dateTime1.isSameDay(dateTime2), 'Dates should not be on same day');
	}

	/**
	 * @description Method is use to test the number
	 */
	@IsTest
	private static void generateRandomNumber()
	{
		String randomNumber = CMN_DAL_SObjectDomain.generateRandomNumber();

		Boolean isNumeric = randomNumber.isNumeric();

		System.assertEquals(true, isNumeric);

		Integer expectedLength = 8;
		System.assertEquals(expectedLength, randomNumber.length());
	}

	/**
	 * @description Will test that random number is generated between a min and max value
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomInteger
	 */
	@IsTest
	private static void generateRandomIntegerMinMax()
	{
		Integer min = 5;
		Integer max = 10;

		Test.startTest();

		Integer randomInteger = CMN_DAL_SObjectDomain.generateRandomInteger(min, max);

		Test.stopTest();

		System.assert(randomInteger >= min, 'Generated Integer is lower than min value');
		System.assert(randomInteger <= max, 'Generated Integer is higher than max value');
	}

	/**
	 * @description Method is use test generation of a random integer
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomInteger
	 */
	@IsTest
	private static void generateRandomInteger()
	{
		Test.startTest();

		Integer randomInteger1 = CMN_DAL_SObjectDomain.generateRandomInteger();
		Integer randomInteger2 = CMN_DAL_SObjectDomain.generateRandomInteger();

		Test.stopTest();

		System.assertNotEquals(randomInteger1, randomInteger2, 'Integers not random');
	}

	/**
	 * @description Method is use test generation of a random currency
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomCurrencyAsString
	 */
	@IsTest
	private static void generateRandomCurrencyAsString()
	{
		Test.startTest();

		String randomCurrencyAsString = CMN_DAL_SObjectDomain.generateRandomCurrencyAsString();

		Test.stopTest();

		System.assertEquals(true, randomCurrencyAsString.contains(DOT), 'No decimal point found');

		List<String> splitString = randomCurrencyAsString.split('\\.');

		System.assertEquals(2, splitString.size(), 'More than 1 decimal point found');

		String stringBeforeDot = splitString.get(0);
		String stringAfterDot = splitString.get(1);

		System.assert(CMN_UTIL_String.isNumeric(stringBeforeDot) && CMN_UTIL_String.isNumeric(stringAfterDot), 'Not a valid number');
		System.assertEquals(2, stringAfterDot.length(), 'There should be two digits after the decimal point');
	}

	/**
	 * @description Method is use test generation of a random percentage
	 *
	 * @see CMN_DAL_SObjectDomain.generateRandomPercentageAsString
	 */
	@IsTest
	private static void generateRandomPercentageAsString()
	{
		Test.startTest();

		String randomPercentageAsString = CMN_DAL_SObjectDomain.generateRandomPercentageAsString();

		Test.stopTest();

		System.assertEquals(true, randomPercentageAsString.contains(DOT), 'No decimal point found');

		List<String> splitString = randomPercentageAsString.split('\\.');

		System.assertEquals(2, splitString.size(), 'More than 1 decimal point found');

		String stringBeforeDot = splitString.get(0);
		String stringAfterDot = splitString.get(1);

		System.assert(CMN_UTIL_String.isNumeric(stringBeforeDot) && CMN_UTIL_String.isNumeric(stringAfterDot), 'Not a valid number');
		System.assertEquals(true, stringBeforeDot.length() <= 2, 'Number should be between 0 and 100');
		System.assertEquals(2, stringAfterDot.length(), 'There should be two digits after the decimal point');
	}

	/**
	 * @description Method is use to test the number
	 */
	@IsTest
	private static void generateRandomName()
	{
		String randomName = CMN_DAL_SObjectDomain.generateRandomName();

		Boolean isAlphabetic = randomName.isAlpha();

		System.assertEquals(true, isAlphabetic);

		Integer expectedLength = 15;
		System.assertEquals(expectedLength, randomName.length());
	}

	/**
	 * @description Method is use to test the generated description
	 */
	@IsTest
	private static void generateRandomDescription()
	{
		String randomDescription = CMN_DAL_SObjectDomain.generateRandomDescription();

		Boolean isAlphabetic = randomDescription.isAlpha();

		System.assertEquals(true, isAlphabetic);

		Integer expectedLength = 80;
		System.assertEquals(expectedLength, randomDescription.length());
	}

	/**
	 * @description Method is use to test the generated Email
	 */
	@IsTest
	private static void generateRandomEmail()
	{
		String randomEmail = CMN_DAL_SObjectDomain.generateRandomEmail();

		String randomEmailSuffix = randomEmail.substring(15, randomEmail.length());

		System.assertEquals(CMN_DAL_SObjectDomain.CONTACT_EMAIL_SUFFIX, randomEmailSuffix, 'Suffix incorrect');
	}

	/**
	 * @description Method is use to test the upsertion of SObject
	 */
	@IsTest
	private static void dynamicUpsertDBObjects()
	{
		Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();

		CMN_DAL_SObjectDomain.insertDBObject(newAccount);
		newAccount.Phone = REF_PHONE_NUMBER;

		Account account2 = CMN_DAL_DataFactory.newBusinessAccount();
		List<Account> objectsToUpsert = new List<Account>();
		objectsToUpsert.add(newAccount);
		objectsToUpsert.add(account2);

		Test.startTest();

		CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(objectsToUpsert, newAccount.getSObjectType(), true);

		Test.stopTest();

		Account foundAccount = CMN_DAL_Account.findById(newAccount.Id);

		System.assertEquals(newAccount.Phone, foundAccount.Phone, 'Upsert operation not successful');
	}

	/**
	 * @description Method is use to test the upsertion of SObject when it's failed
	 */
	@IsTest
	private static void upsertFailed()
	{
		Account newAccount = CMN_DAL_DataFactory.newBusinessAccount();
		newAccount.Name = null;

		List<Account> objectsToUpsert = new List<Account>();
		objectsToUpsert.add(newAccount);

		Test.startTest();

		Boolean upsertSuccessful = CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(objectsToUpsert, newAccount.getSObjectType(), false);

		Test.stopTest();

		System.assertEquals(false, upsertSuccessful, 'Upsert Operation Did not Fail');
	}

	/**
	 * @description Method is used to check if a Duplicate error thrown during a DML operation where
	 * partial successes are allowed is collected correctly
	 */
	@IsTest
	private static void collectDuplicateErrors()
	{
		CMN_Foobar__c newFoo1 = CMN_DAL_DataFactory.newFoobar();
		CMN_Foobar__c newFoo2 = CMN_DAL_DataFactory.newFoobar();
		newFoo2.Name = newFoo1.Name;

		insert newFoo1;

		Test.startTest();

		Boolean insertSuccessful = CMN_DAL_SObjectDomain.insertDBObject(newFoo2, false);

		Test.stopTest();

		System.assertEquals(false, insertSuccessful, 'Insert Operation Did not Fail due to duplicate rule');
	}

	/**
	 * @description Method is used to check if a Duplicate error thrown during a DML operation where
	 * partial successes are allowed is collected correctly
	 */
	@IsTest
	private static void checkEmptyDatabaseUpdateSucceed()
	{
		Test.startTest();

		Boolean insertSuccessful = CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject>(), false);

		Test.stopTest();

		System.assertEquals(true, insertSuccessful, 'Empty list did not insert was reported as failed');
	}

	/**
	 * @description Will check that random boolean is generated
	 */
	@IsTest
	private static void generateRandomBoolean()
	{
		Integer numberTrue = 0;
		Integer numberFalse = 0;

		Test.startTest();

		for(Integer i = 0; i < NUMBER_BOOLEANS_TO_GENERATE; i++)
		{
			Boolean randomBoolean = CMN_DAL_SObjectDomain.generateRandomBoolean();
			if(randomBoolean)
			{
				numberTrue++;
			}
			else
			{
				numberFalse++;
			}
		}

		Test.stopTest();

		System.assert((numberTrue > 0) && (numberFalse > 0), 'Boolean values not generated randomly');
	}

	@IsTest
	private static void generateMockIncrementalIds()
	{
		String id1 = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType);
		String id2 = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType);
		String id3 = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType);

		System.assertEquals(IDD1, id1);
		System.assertEquals(IDD2, id2);
		System.assertEquals(IDD3, id3);
	}

	@IsTest
	private static void testInstance()
	{
		CMN_DAL_SObjectDomain.ISObjectDomain foobarDomain = new CMN_DAL_SObjectDomain (CMN_Foobar__c.SObjectType);
		System.assertEquals(CMN_Foobar__c.SObjectType, foobarDomain.sObjectType());
	}

	/**
	 * @description Method is use to test the recordtype by developer name of SObject
	 */
	@IsTest
	private static void getRecordTypeByDeveloperName()
	{
		List<RecordType> recordTypes = CMN_DAL_RecordType.findByObjectType(Account.SObjectType);

		if(!recordTypes.isEmpty())
		{
			RecordType aRecordType = recordTypes.iterator().next();

			Test.startTest();

			Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, aRecordType.DeveloperName);

			Test.stopTest();

			System.assertEquals(aRecordType.Id, recordTypeId);
		}
	}

	/**
	 * @description Check that system handles situation where recordtype doesn't exist
	 */
	@IsTest
	private static void getRecordTypeByDeveloperNameNotFound()
	{
		Test.startTest();

		Id recordTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, CMN_DAL_SObjectDomain.generateRandomName());

		Test.stopTest();

		System.assertEquals(null, recordTypeId);
	}
}