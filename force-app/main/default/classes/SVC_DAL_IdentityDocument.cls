/**
 * @description Data Access Layer SOQL related to the IdentityDocument Object, this is common class to be used across applications
 *
 * @see IdentityDocument
 *
 * @author Accenture
 *
 * @date Apr 2021
 */
public inherited sharing class SVC_DAL_IdentityDocument
{
	public static final String OBJECT_NAME = IdentityDocument.SObjectType.getDescribe().getLocalName();
	public static final String FIELD_RELATED_ENTITY_ID = IdentityDocument.RelatedLegalEntityId.getDescribe().getLocalName();
	/**
	 * @description A list of the common IdentityDocument fields to query
	 *
	 * @return A set of fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				IdentityDocument.ExpirationDate.getDescribe().getLocalName(),
				IdentityDocument.Id.getDescribe().getLocalName(),
				IdentityDocument.IdDocumentType.getDescribe().getLocalName(),
				IdentityDocument.IssueDate.getDescribe().getLocalName(),
				FIELD_RELATED_ENTITY_ID,
				IdentityDocument.Name.getDescribe().getLocalName(),
				IdentityDocument.RelatedLegalEntityId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will return one or more Identity Documents based on Name
	 *
	 * @param name The name against which to query
	 *
	 * @return One or more documents
	 */
	public static List<IdentityDocument> findByName(String name)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_NAME, new Set<String> {name}, getDefaultFields());
	}

	/**
	 * @description Will return all the Identity Documents in the system using default fields
	 *
	 * @return A list of Identity Documents
	 */
	@TestVisible
	private static List<IdentityDocument> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}

}