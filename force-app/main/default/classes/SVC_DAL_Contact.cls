/**
 * @description Data Access Layer SOQL and DML updates related to the Contact Object, this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date January 2021
 */
public inherited sharing class SVC_DAL_Contact
{
	private static final String FIELD_EXTERNAL_CIF_ID = CMN_DAL_Account.OBJECT_NAME + CMN_UTIL_String.DOT + SVC_DAL_Account.FIELD_EXTERNAL_CIF_ID;
	private static final String FIELD_EXTERNAL_CIF_UUID = CMN_DAL_Account.OBJECT_NAME + CMN_UTIL_String.DOT + SVC_DAL_Account.FIELD_EXTERNAL_CF_UUID;
	public static final String OBJECT_NAME = Contact.SObjectType.getDescribe().getLocalName();

	/**
	 * @description A list of the common contact fields to query
	 *
	 * @return A set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		Set<String> defaultFields = new Set<String>();

		defaultFields.addAll(new Set<String>
		{
				 FIELD_EXTERNAL_CIF_ID,
				 FIELD_EXTERNAL_CIF_UUID,
				 'AccountId',
				  'AssistantName',
				  'AssistantPhone',
				  'Birthdate',
				  'CMN_BPGUID__c',
				  'CMN_CustomerBPID__c',
				  'CMN_IdentityNumber__c',
				  'Department',
				  'Description',
				  'Email',
				  'EmailBouncedDate',
				  'FirstName',
				  'HomePhone',
				  'Id',
				  'LastName',
				  'MobilePhone',
				  'Name',
				  'OwnerId',
				  'Phone',
				  'RecordTypeId',
				  'Salutation',
				  'Title'
		});

		return defaultFields;
	}

	/**
	 * @description Will query contact object with given ids
	 *
	 * @param contactIds A list of Contact ids
	 *
	 * @return A List of found contacts
	 */
	public static List<Contact> findById(Set<Id> contactIds)
	{
		return CMN_DAL_SObjectSelector.findById(Contact.SObjectType, contactIds, getDefaultFields());
	}

	/**
	 * @description Will query contact using their Id
	 *
	 * @param contactId Salesforce Id of the contact
	 *
	 * @return either Null or a Contact
	 */
	public static Contact findById(Id contactId)
	{
		List<Contact> contacts = findById(new Set<Id>
		{
				contactId
		});

		return contacts.isEmpty() ? null : contacts.iterator().next();
	}

	/**
	 * @description Will return a Contact (which must be a person account) based on external Id (sitting on account object)
	 *
	 * @param externalCfId A unique identifier on the Account Object
	 *
	 * @return Found Contact, if duplicates are found null is returned
	 *
	 * @see Account.ExternalCIFId__c
	 */
	public static Contact findByExternalCfId(String externalCfId)
	{
		return (Contact)CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_EXTERNAL_CIF_ID, externalCfId, getDefaultFields(), false);
	}

	/**
	 * @description Will return all the contacts in the system using default fields
	 *
	 * @return A list of contacts
	 */
	@TestVisible
	private static List<Contact> getAll()
	{
		return CMN_DAL_Search.getAll(Contact.SObjectType, getDefaultFields());
	}
}