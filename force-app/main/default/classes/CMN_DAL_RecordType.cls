/**
 * @description Provides Queries related to RecordType object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_RecordType
{
	public static final String OBJECT_NAME = 'RecordType';
	private static final String FIELD_SOBJECT_TYPE = 'SobjectType';

  /**
   * @description Method to return the List of Record Type
   *
   * @return list of all record types
   */
  public static List<RecordType> getAll() {
    return [
      SELECT Id, DeveloperName, SobjectType, Name, Description
      FROM RecordType
      LIMIT :CMN_DAL_SObjectDomain.LIMIT_NUMBER_OF_RECORDS
    ];
  }

	/**
	 * @description Method use to get the set of fields of SObject
	 *
	 * @return A list of commonly queried Record Type fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				RecordType.BusinessProcessId.getDescribe().getLocalName(),
				RecordType.Description.getDescribe().getLocalName(),
				RecordType.DeveloperName.getDescribe().getLocalName(),
				RecordType.Id.getDescribe().getLocalName(),
				RecordType.IsActive.getDescribe().getLocalName(),
				RecordType.IsPersonType.getDescribe().getLocalName(),
				RecordType.Name.getDescribe().getLocalName(),
				RecordType.NamespacePrefix.getDescribe().getLocalName(),
				FIELD_SOBJECT_TYPE
		};
	}

	/**
	 * @description Will retrieve a RecordType based on Id
	 *
	 * @param recordTypeId Id of the object
	 *
	 * @return Null or Item
	 */
	public static RecordType findById(Id recordTypeId)
	{
		return (RecordType)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, recordTypeId, getDefaultFields());
	}

	/**
	 * @description This method is use to return the list of Record Type by Object
	 *
	 * @param objectType the object type to use
	 *
	 * @return A list of items
	 */
	@TestVisible
	private static List<RecordType> findByObjectType(SObjectType objectType)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_SOBJECT_TYPE, new Set<String> {objectType.getDescribe().getLocalName()}, getDefaultFields());
	}

}