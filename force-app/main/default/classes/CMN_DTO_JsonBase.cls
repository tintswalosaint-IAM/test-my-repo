/**
 * @description Data Transfer Object that can serialize and deserialize JSON
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date April 2021
 */
public inherited sharing virtual class CMN_DTO_JsonBase extends CMN_DTO_Base
{
	/**
	 * @description The Type of the DTO used when deserializing the class (must be implemented on decendant classes)
	 *
	 * @return Class of the DTO
	 */
	protected virtual Type getObjectType()
	{
		String className = CMN_UTIL_System.getTypeName(this);

		if(className.equalsIgnoreCase(CMN_DTO_JsonBase.class.getName()))
		{
			return CMN_DTO_JsonBase.class;
		}

		throw new JSONException('To deserialize this DTO you must implement getObjectType()');
	}

	/**
	 * @description Will deserialise the string and return an instance of the class specified in "getObjectType"
	 *
	 * @param dtoString A JSON string
	 *
	 * @return Deserialized DTO
	 *
	 * @see CMN_DTO_JsonBase.getObjectType
	 */
	public override CMN_DTO_Base deserialize(String dtoString)
	{
		//This line is to ensure base code is covered
		CMN_DTO_Base dtoBase = super.deserialize(dtoString);
		dtoBase = (CMN_DTO_Base)JSON.deserialize(dtoString, getObjectType());
		return dtoBase;
	}
	/**
	 * @description Suppresses null values when serializing Apex objects
	 *
	 * @return JSON string
	 */
	public override String serialize()
	{
		//This line is to ensure base code is covered
		String jsonString = super.serialize();
		return jsonString + JSON.serializePretty(this, true);
	}
}