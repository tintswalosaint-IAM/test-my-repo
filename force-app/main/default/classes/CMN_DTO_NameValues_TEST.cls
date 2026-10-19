/**
 * @description Test the behaviour of Shared DTO class for name value pairs
 *
 * @see CMN_DTO_NameValues
 *
 * @author Accenture
 *
 * @date December 2020
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DTO_NameValues_TEST
{
	/**
	 * @description Tests that the overloaded constructor (taking a map) works as expected
	 */
	@IsTest
	private static void checkAllCode()
	{
		Map<String, String> nameValueMap = new Map<String, String>
		{
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName(),
				CMN_DAL_SObjectDomain.generateRandomName() => CMN_DAL_SObjectDomain.generateRandomName()

		};

		Test.startTest();

		CMN_DTO_NameValues dtoNameValues = new CMN_DTO_NameValues(nameValueMap);

		Test.stopTest();

		System.assertEquals(nameValueMap.size(), dtoNameValues.items.size(), 'DTO not initialised correctly');

		for(String key : nameValueMap.keySet())
		{
			System.assertEquals(true, dtoNameValues.exists(key.toUpperCase()), 'Expected item to exist');

			List<String> valueList = dtoNameValues.getAll(key);
			System.assertEquals(1, valueList.size(), 'Incorrect number of values returned');
			System.assertEquals(nameValueMap.get(key), valueList[0], 'Incorrect value returned');
			System.assertEquals(nameValueMap.get(key), dtoNameValues.getFirst(key), 'Incorrect value returned');
		}

		System.assertEquals(true, dtoNameValues.allExists(nameValueMap.keySet()), 'Expected method to match all items');
	}

}