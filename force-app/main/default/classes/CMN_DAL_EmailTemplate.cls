/**
 * @description Provides Query methods related to EmailTemplate object
 *
 * @author Accenture
 *
 * @date March 2021
 */
public inherited sharing class CMN_DAL_EmailTemplate
{
	public static final String OBJECT_NAME = EmailTemplate.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_DEVELOPER_NAME = EmailTemplate.DeveloperName.getDescribe().getLocalName();

	/**
	 * @description Returns the default fields to return when querying the EmailTemplate Object
	 *
	 * @return A list of field names
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				EmailTemplate.Id.getDescribe().getLocalName(),
				FIELD_DEVELOPER_NAME,
				EmailTemplate.Name.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will retrieve on or more EmailTemplates
	 *
	 * @param uniqueNames A list of DeveloperNames for Template
	 *
	 * @return A list of EmailTemplates
	 */
	public static List<EmailTemplate> findByName(Set<String> uniqueNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_DEVELOPER_NAME, uniqueNames, getDefaultFields());
	}

	/**
	 * @description Will retrieve a random EmailTemplate
	 *
	 * @param searchTerm A term to filter (using LIKE operator) the list of items
	 *
	 * @return A random template (or null)
	 */
	@TestVisible
	private static EmailTemplate getRandomItem(String searchTerm)
	{
		return (EmailTemplate)CMN_UTIL_System.getRandomItem(CMN_DAL_Search.getAll(OBJECT_NAME, searchTerm));
	}
}