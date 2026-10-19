/**
 * @description Provides Query methods related to CMN_WebserviceSetting__mdt Custom Metadata object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_WebserviceSetting
{
	private static Map<String, SObject> webserviceMap;
	private static final String FIELD_DEVELOPER_NAME = CMN_WebserviceSetting__mdt.DeveloperName.getDescribe().getLocalName();
	private static final String TEST_SETTING = 'CMN_API_RestOutboundExample';

	/**
	 * @description This method is use to get the list of metadata for custom settings, this method is
	 *              running a query rather than metadata instance methods as  we  may have some fields
	 *              with more than 255 characters.
	 *
	 * @param serviceName The web service for which we want to retrieve metadata
	 *
	 * @return relevant service settings
	 */
	public static CMN_WebserviceSetting__mdt getMetadata(String serviceName)
	{
		if(webserviceMap == null)
		{
			List<CMN_WebserviceSetting__mdt> allSettings = CMN_DAL_Search.getAll(CMN_WebserviceSetting__mdt.SObjectType);
			webserviceMap = CMN_UTIL_System.convertListToSingleUpperStringMap(allSettings, FIELD_DEVELOPER_NAME);
		}

		CMN_WebserviceSetting__mdt setting = (CMN_WebserviceSetting__mdt)webserviceMap.get(CMN_UTIL_String.upperCase(serviceName));

		setting = setting == null && Test.isRunningTest() ? CMN_WebserviceSetting__mdt.getInstance(TEST_SETTING) : setting;

		return setting;
	}
}