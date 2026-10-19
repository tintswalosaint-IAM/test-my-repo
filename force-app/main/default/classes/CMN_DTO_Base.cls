/**
 * @description Class use to store the JSON content and generates indented content using the pretty-print format.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing virtual class CMN_DTO_Base
{
	/**
	 * @description Will serialize the current dto in to txt
	 *
	 * @return DTO in a serialized format
	 */
	public virtual String serialize()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Will deserialise the string and return a populated instance of CMN_DTO_Base
	 *
	 * @param dtoString A String in a format the DTO understands
	 *
	 * @return Deserialized DTO
	 */
	public virtual CMN_DTO_Base deserialize(String dtoString)
	{
		return this;
	}

	/**
	 * @description Populate the object using the triggerObjectId to get relevant data
	 *
	 * @param triggeringObjectId as input
	 */
	public virtual void populate(Id triggeringObjectId)
	{

	}

	/**
	 * @description Populate the object using the triggerObjectId to get relevant data
	 *
	 * @param triggeringObjectId as input
	 * @param dtoRequestParameters A list of name values that can be used to change the query or the population of the request DTO
	 */
	public virtual void populate(Id triggeringObjectId, CMN_DTO_NameValues dtoRequestParameters)
	{
		populate(triggeringObjectId);
	}

	/**
	 * @description Will transform the DTO provided into the current dto, its up to the class to check the type being passed an transform appropriately
	 *
	 * @param dtoBase Input dto for transformation
	 */
	public virtual void transform(CMN_DTO_Base dtoBase)
	{

	}

}