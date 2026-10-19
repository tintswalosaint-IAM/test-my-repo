/**
 * @description Provides Query methods related to Group
 *
 * @author Accenture
 *
 * @date May 2021
 */
public inherited sharing class CMN_DAL_Group
{
	public static final String OBJECT_NAME = Group.SObjectType.getDescribe().getLocalName();
	private static final String FIELD_EMAIL = Group.Email.getDescribe().getLocalName();

	public enum GroupType
	{
		QUEUE, ROLE
	}

	/**
	 * @description A list of the common Group fields to query
	 *
	 * @return A set of fields
	 */
	public static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				Group.Name.getDescribe().getLocalName(),
				Group.Email.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Method to return a list of Groups by Id
	 *
	 * @param groupIds The groupIds to be used when filtering the group list
	 *
	 * @return List of Groups
	 */
	public static List<Group> findById(Set<Id> groupIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, groupIds, getDefaultFields());
	}

	/**
	 * @description Method to return a list of Groups by Email
	 *
	 * @param email The email to search
	 *
	 * @return List of Groups
	 */
	public static List<Group> findByEmail(String email)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_EMAIL, new Set<String> {email}, getDefaultFields());
	}

}