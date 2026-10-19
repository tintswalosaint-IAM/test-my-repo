/**
 * @description Class tests CMN_DAL_Foobar and demonstrates how to use CMN_DAL_Search more advanced soql methods
 *
 * @see CMN_DAL_Foobar @story VCCC-378
 *
 * @author Accenture
 *
 * @date 2020
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_Foobar_TEST
{
	/**
	 * @description setup foobar records for below tests
	 *
	 * @return foobar child record with parent lookup reference
	 */
	private static CMN_Foobar__c setup()
	{
		CMN_Foobar__c parent = CMN_DAL_DataFactory.newFoobar();

		insert parent;

		CMN_Foobar__c child = CMN_DAL_DataFactory.newFoobar();
		child.CMN_Lookup__c = parent.Id;

		insert child;

		return child;
	}

	@IsTest
	private static void getAll()
	{
		setup();

		Test.startTest();

		List<CMN_Foobar__c> records = CMN_DAL_Foobar.getAll();

		System.assert(records.size() > 0);

		Test.stopTest();
	}

	@IsTest
	private static void selectByIds()
	{
		CMN_Foobar__c record = setup();

		Test.startTest();

		List<CMN_Foobar__c> records = CMN_DAL_Foobar.selectByIds(new Set<Id> {record.Id});

		System.assertEquals(record.Id, records.iterator().next().Id);

		Test.stopTest();
	}

	@IsTest
	private static void selectByIdsFields()
	{
		CMN_Foobar__c record = setup();

		Test.startTest();

		List<CMN_Foobar__c> records = CMN_DAL_Foobar.selectByIdsFields(new Set<Id> {record.Id}, CMN_DAL_Foobar.SOBJECT_FIELDS);

		System.assertEquals(record.Id, records.iterator().next().Id);

		Test.stopTest();
	}

	@IsTest
	private static void soqlMultipleCriteria()
	{
		CMN_Foobar__c record = setup();

		Test.startTest();

		List<CMN_Foobar__c> records = CMN_DAL_Foobar.selectByMultipleCriteria(new List<Id> {record.Id}, CMN_DAL_Foobar.SOBJECT_FIELDS);

		System.assertEquals(record.Id, records.iterator().next().Id);

		Test.stopTest();
	}

	@IsTest
	private static void queryLocatorAll()
	{
		setup();

		Test.startTest();

		Database.QueryLocator locator = CMN_DAL_Foobar.queryLocatorAll();

		CMN_Foobar__c returned = (CMN_Foobar__c)locator.iterator().next();

		System.assert(returned != null);

		Test.stopTest();
	}

	@IsTest
	private static void queryAggregateAll()
	{
		setup();

		Test.startTest();

		/* group by id will always return single record for this foobar test */
		List<AggregateResult> aggregateResults = CMN_DAL_Foobar.queryAggregateAll();

		AggregateResult result = aggregateResults.get(0);

		System.assert(result != null);

		System.assertEquals(result.get('expr0'), 1);

		Test.stopTest();
	}

	@IsTest
	private static void innerSelectQuery()
	{
		CMN_Foobar__c record = setup();

		Test.startTest();

		List<CMN_Foobar__c> results = CMN_DAL_Foobar.selectWithChildSelect (new Set<Id> {record.CMN_Lookup__c});

		System.assert(results != null);

		System.assertEquals(results.iterator().next().Id, record.CMN_Lookup__c);

		Test.stopTest();
	}

	@IsTest
	private static void whereInSelectQuery()
	{
		CMN_Foobar__c record = setup();

		Test.startTest();

		List<CMN_Foobar__c> results = CMN_DAL_Foobar.selectWithChildBasedOnLookupWhereIn(new Set<Id> {record.CMN_Lookup__c});

		System.assert(results.size() == 1);

		System.assertEquals(results.iterator().next().Id, record.CMN_Lookup__c);

		Test.stopTest();
	}

	@IsTest
	private static void whereNotInSelectQuery()
	{
		CMN_Foobar__c record = setup();

		Test.startTest();

		List<CMN_Foobar__c> results = CMN_DAL_Foobar.selectWithChildBasedOnLookupWhereNotIn (new Set<Id> {record.CMN_Lookup__c});

		System.assert(results.size() == 0);

		Test.stopTest();
	}
}