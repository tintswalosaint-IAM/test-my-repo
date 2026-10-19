/**
 * @description Class has base methods that can be used to test the account search result
 *
 * @see CMN_DAL_Search @story VCCC-378
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DAL_Search_TEST
{
	private static final String NAME = CMN_DAL_SObjectDomain.generateRandomName();

	/**
	 * @description To test the search result from Object
	 */
	@IsTest
	private static void soslSearch()
	{
		CMN_Foobar__c foobar1 = CMN_DAL_DataFactory.newFoobar();

		foobar1.Name = NAME;
		CMN_Foobar__c foobar2 = CMN_DAL_DataFactory.newFoobar();
		foobar2.Name = NAME;
		CMN_Foobar__c foobar3 = CMN_DAL_DataFactory.newFoobar();
		foobar3.Name = NAME;

		CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject>
		{
				foobar1,
				foobar2,
				foobar3
		});

		Test.setFixedSearchResults(new List<String>
		{
				foobar1.Id,
				foobar2.Id,
				foobar3.Id
		});

		String term = '{' + NAME + '}';

		CMN_DAL_Search.SOSLSearchParameters parameters = new CMN_DAL_Search.SOSLSearchParameters(CMN_Foobar__c.SObjectType, CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS, term);
		parameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		parameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);
		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.SetCondition(CMN_DAL_SObjectDomain.FIELD_NAME, CMN_SOQL_Query.Operator.INX, new List<String> {NAME}));

		parameters.searchConditions.add(andCondition);

		Test.startTest();

		CMN_DAL_Search.SearchResponse response = CMN_DAL_Search.soslSearch(parameters);
		List<SObject> objects = CMN_DAL_Search.soslSearch(CMN_Foobar__c.SObjectType, CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS, term);

		Test.stopTest();

		System.assertNotEquals(null, response);
		System.assertEquals(3, response.itemList.size());
		System.assertEquals(response.itemList.size(), objects.size());
	}

	/**
	 * @description : To test the search result from foobar by name
	 */
	@IsTest
	private static void getAllByName()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getAll(CMN_DAL_Foobar.SOBJECT_NAME, newFoobar.Name);

		Test.stopTest();

		System.assert (!foobars.isEmpty(), 'No Foobars retrieved by Name.');
	}

	/**
	 * @description To test the search result from Foo Object
	 */
	@IsTest
	private static void getAll()
	{
		insert CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getAll(CMN_Foobar__c.SObjectType);

		Test.stopTest();

		System.assert (!foobars.isEmpty(), 'No Foobars retrieved.');
	}

	/**
	 * @description To test the search result from Foo Object
	 */
	@IsTest
	private static void getAllWithFields()
	{
		insert CMN_DAL_DataFactory.newFoobar();

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getAll(CMN_Foobar__c.SObjectType, CMN_DAL_Foobar.SOBJECT_FIELDS);

		Test.stopTest();

		System.assert (!foobars.isEmpty(), 'No Foobars retrieved.');
	}

	/**
	 * @description To test the search result from Foo by Id
	 */
	@IsTest
	private static void getAllById()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.findAllByAnyValue(CMN_DAL_Foobar.SOBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_ID, newFoobar.Id);

		Test.stopTest();

		System.assert (!foobars.isEmpty(), 'No Foobars retrieved by Id.');
	}

	/**
	 * @description To test the search result from insert Foo in the page
	 */
	@IsTest
	private static void findByNamePaged()
	{
		//Insert 2 items; but by setting page size to 1, we expect only to retrieve one of them
		CMN_Foobar__c newFoobar1 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar1;

		CMN_Foobar__c newFoobar2 = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar2;

		Test.startTest();

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.SOBJECT_NAME);

		//Setting page to true will ensure that we do paging
		searchParameters.paged = true;
		searchParameters.pageSize = 1;
		searchParameters.resultItemType = CMN_DAL_Search.ResultRow.class;
		searchParameters.searchFields.clear();
		searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.SetCondition(CMN_DAL_SObjectDomain.FIELD_NAME, CMN_SOQL_Query.Operator.INX, new List<String> {newFoobar1.Name, newFoobar2.Name}));

		searchParameters.searchConditions.add(andCondition);

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.getObjects(searchParameters);

		Test.stopTest();

		System.assertEquals(false, foobars.isEmpty(), 'No Foobars retrieved by Name.');
		System.assertEquals(1, foobars.size(), 'Invalid number of Foobars retrieved.');
	}

	/**
	 * @description Will test that objects can be randomly retrieved
	 */
	@IsTest
	private static void findRandomRecordByRecordTypeId()
	{
		List<CMN_Foobar__c> foobars = new List<CMN_Foobar__c>();

		//Ensure that we create enough items so that finding them randomly returns different items and not the same one
		for(Integer i = 0; i < 50; i++)
		{
			foobars.add(CMN_DAL_DataFactory.newFoobar());
		}

		insert foobars;

		Test.startTest();

		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Foobar.SOBJECT_NAME);

		//Setting page to true will ensure that we do paging
		searchParameters.randomSingle = true;
		searchParameters.enforceSecurity = false;
		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		searchParameters.searchFields.clear();
		searchParameters.selectFields = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};
		searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(CMN_DAL_SObjectDomain.FIELD_RECORD_TYPE_ID, CMN_SOQL_Query.Operator.EQUALS, foobars.iterator().next().RecordTypeId));

		searchParameters.searchConditions.add(andCondition);

		List<CMN_Foobar__c> foundFoobars = CMN_DAL_Search.getObjects(searchParameters);

		System.assertEquals(false, foundFoobars.isEmpty(), 'No foobars retrieved by RecordTypeId.');
		System.assertEquals(1, foundFoobars.size(), 'Invalid number of foobars retrieved.');

		CMN_Foobar__c fooResult1 = foundFoobars.iterator().next();

		Test.stopTest();

		CMN_Foobar__c fooResult2 = (CMN_Foobar__c)CMN_DAL_Search.getObjects(searchParameters).iterator().next();

		System.assertNotEquals(fooResult1.Id, fooResult2.Id, 'The same item retrieved, expecting random retrieval');
	}

	/**
	 * @description To test the search result scenario from insert Foo in the page with related object
	 */
	@IsTest
	private static void getAllIncludingRelatedObject()
	{
		CMN_Foobar__c newFoobar = CMN_DAL_DataFactory.newFoobar();
		insert newFoobar;

		Test.startTest();

		List<CMN_Foobar__c> foobars = CMN_DAL_Search.findAllById(CMN_DAL_Foobar.SOBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_ID, newFoobar.Id, true);

		Test.stopTest();

		System.assert (!foobars.isEmpty(), 'No Foobars retrieved by Id.');
	}

}