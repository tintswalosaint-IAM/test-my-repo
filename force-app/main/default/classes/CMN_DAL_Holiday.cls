/**
 * @description Data Access Layer SOQL and DML updates related to the Holiday Object, this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class CMN_DAL_Holiday implements Cache.CacheBuilder
{
	public static final String OBJECT_NAME = Holiday.SObjectType.getDescribe().getLocalName();
	public static final String PICK_RECURS_YEARLY = 'RecursYearly';

	/**
	 * @description Used to query a list of holidays from cache
	 *
	 * @param cachedDate The cache key
	 *
	 * @return A list of holidays
	 */
	public Object doLoad(String cachedDate)
	{
		List<Holiday> holidays = (List<Holiday>)getAll();
		return holidays;
	}

	/**
	 * @description A list of the common holiday fields to query
	 *
	 * @return A set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Holiday.Id.getDescribe().getLocalName(),
				Holiday.Name.getDescribe().getLocalName(),
				Holiday.ActivityDate.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will return all the holidays in the system using default fields
	 *
	 * @return A list of holidays
	 */
	public static List<Holiday> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}