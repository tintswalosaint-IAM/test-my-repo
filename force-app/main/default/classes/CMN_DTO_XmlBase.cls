/**
* MIT License
*
* Copyright (c) 2018 Piotr Kożuchowski https://github.com/amorek/Apex-Opensource-Library
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

/**
 * @description Dom.XmlNode wrapper for automatic serialization/deserialization of class structures to/from XML.
 * To use this class, you have to recreate XML tree structure as class structure and each class should extend XmlNode.
 * Each class will have to implement registerXML() class and register all children as either text node, child node or list node.
 *
 * @see CMN_DTO_XmlBase_TEST for usage.
 * @see Dom.XmlNode
 *
 * @author Piotr Kożuchowski
 */
public abstract class CMN_DTO_XmlBase extends CMN_DTO_Base
{
	private static final String ERROR_CHILD_CLASS_NOT_PUBLIC = 'Child class is not public.';
	private static final String WARN_CHILD_NODE_NOT_FOUND = 'Unable to find child node with name "{0}", namespace "{1}" and prefix "{2}"';

	private transient Dom.XmlNode xmlNode;
	private transient NodeContext context;

	/**
	 * @description Enum indicates if the node is being created to either serialize (to XML) or de-serialize XML
	 */
	public enum NodeContext
	{
		SERIALIZATION,
		DESERIALIZATION
	}

	/**
	 * @description Override this method to register all text nodes and child nodes under current node.
	 *
	 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
	 */
	protected abstract void registerXML(NodeContext aNodeContext);

	/**
	 * @description Will deserialise the string and return a populated instance of CMN_DTO_Base ¬should not be called, but rather root node should be used
	 * Implemented to override base class
	 *
	 * @param dtoString A String in a format the DTO understands
	 *
	 * @return Deserialized DTO
	 */
	public virtual override CMN_DTO_Base deserialize(String dtoString)
	{
		return this;
	}

	/**
	 * @description Will serialize the current dto in to txt, should not be called, but rather root node should be used
	 * Implemented to override base class
	 *
	 * @return DTO in a serialized format
	 */
	public virtual override String serialize()
	{
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description This method is required to clean up node and parent after work is done.
	 * It significantly reduces required heap size (by half).
	 *
	 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
	 */
	private void registerXML_internal(NodeContext aNodeContext)
	{
		context = aNodeContext;
		registerXML(aNodeContext);
		xmlNode = null;
	}

	/**
	 * @description During serialization:
	 * Creates child xml node with given nodeName; namespace and prefix will be set to null
	 * <p/>
	 * During deserialization:
	 * Finds child node element of given nodeName and namespace in current node.
	 *
	 * @param childNode XmlNode implementation
	 * @param nodeName Name of child node.
	 */
	protected void registerChild(CMN_DTO_XmlBase childNode, String nodeName)
	{
		registerChild(childNode, nodeName, null, CMN_UTIL_String.EMPTY);
	}

	/**
	 * @description During serialization:
	 * Creates child xml node with given nodeName, namespace and prefix.
	 * <p/>
	 * During deserialization:
	 * Finds child node element of given nodeName and namespace in current node.
	 *
	 * @param childNode XmlNode implementation
	 * @param nodeName Name of child node.
	 * @param namespace Namespace of child node.
	 * @param prefix Prefix of child node. (Serialization phase only)
	 */
	protected void registerChild(CMN_DTO_XmlBase childNode, String nodeName, String namespace, String prefix)
	{
		if(childNode != null)
		{
			childNode.xmlNode = context == NodeContext.SERIALIZATION ? xmlNode.addChildElement(nodeName, namespace, prefix) : xmlNode.getChildElement(nodeName, namespace);

			if(childNode.xmlNode == null)
			{
				CMN_UTIL_Logger.warn(String.format(WARN_CHILD_NODE_NOT_FOUND, new List<String> {nodeName, namespace, prefix}), 'CMN_DTO_Xmlbase/registerChild');
			}
			else
			{
				childNode.registerXML_internal(context);
			}
		}
	}

	/**
	 * @description Serialization Phase:
	 * Registers each child node in given list as direct child of this node.
	 * <p/>
	 * Deserialization Phase:
	 * Searches through children of deserialized node for children with given name and namespace and deserialize found nodes.
	 *
	 * @param childNodes List of nodes to register. (required in both phases)
	 * @param name Name of the child nodes to search for. (Deserialization phase only)
	 * @param namespace Namespace of the child nodes to search for. (Deserialization phase only)
	 * @param prefix Prefix of the created child nodes. (Serialization phase only)
	 */
	protected void registerChildren(List<CMN_DTO_XmlBase> childNodes, String name, String namespace, String prefix)
	{
		Type childType = CMN_UTIL_System.getListItemType(childNodes);

		if(childType == null)
		{
			CMN_UTIL_Logger.error(ERROR_CHILD_CLASS_NOT_PUBLIC, 'CMN_DTO_XmlBase/registerChildren');
			throw new TypeException(ERROR_CHILD_CLASS_NOT_PUBLIC);
		}

		registerChildren(childNodes, name, namespace, prefix, CMN_UTIL_System.getListItemType(childNodes));
	}

	/**
	 * @description Serialization Phase:
	 * Registers each child node in given list as direct child of this node.
	 * <p/>
	 * Deserialization Phase:
	 * Searches through children of deserialized node for children with given name and namespace and deserialize found nodes.
	 *
	 * @param childNodes List of nodes to register. (required in both phases)
	 * @param name Name of the child nodes to search for. (Deserialization phase only)
	 * @param namespace Namespace of the child nodes to search for. (Deserialization phase only)
	 * @param prefix Prefix of the created child nodes. (Serialization phase only)
	 * @param childType Type of the children. Children must extend XmlNode and have no-args constructor. (Deserialization phase only)
	 */
	protected void registerChildren(List<CMN_DTO_XmlBase> childNodes, String name, String namespace, String prefix, Type childType)
	{
		if(childNodes != null)
		{
			if(context == NodeContext.SERIALIZATION)
			{
				for(CMN_DTO_XmlBase childNode : childNodes)
				{
					registerChild(childNode, name, namespace, prefix);
				}
			}
			else
			{
				for(Dom.XmlNode childDomNode : xmlNode.getChildElements())
				{
					String childNamespace = childDomNode.getNamespace();
					String childName = childDomNode.getName();

					if(childName == name && childNamespace == namespace)
					{
						CMN_DTO_XmlBase childNode = (CMN_DTO_XmlBase)childType.newInstance();
						childNode.xmlNode = childDomNode;
						childNode.registerXML_internal(context);

						childNodes.add(childNode);
					}
				}
			}
		}
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Boolean type
	 */
	protected Boolean registerBooleanNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Boolean)registerTextNode(Boolean.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Double type
	 */
	protected Double registerDoubleNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Double)registerTextNode(Double.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Decimal type
	 */
	protected Decimal registerDecimalNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Decimal)registerTextNode(Decimal.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Integer type
	 */
	protected Integer registerIntegerNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Integer)registerTextNode(Integer.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Long type
	 */
	protected Long registerLongNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Long)registerTextNode(Long.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Datetime type
	 */
	protected Datetime registerDatetimeNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Datetime)registerTextNode(Datetime.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with Date type
	 */
	protected Date registerDateNode(String name, String namespace, String prefix, Object anObject)
	{
		return (Date)registerTextNode(Date.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object with string type
	 */
	protected String registerStringNode(String name, String namespace, String prefix, Object anObject)
	{
		return (String)registerTextNode(String.class, name, namespace, prefix, anObject);
	}

	/**
	 * @description During serialization:
	 * Creates text node in current element with given text anObject.
	 * <p/>
	 * During deserialization:
	 * Returns anObject of text node specified by given name and namespace.
	 *
	 * @param valueType Text node anObject will be automatically parsed to this type.
	 * Possible values: String,Double,Decimal,Integer,Long,Date,Datetime,Boolean, Any enum type (for any other, returns String)
	 * Required in deserialization.
	 * @param name Text node name.
	 * @param namespace Text node namespace.
	 * @param prefix Text node prefix (only in serialization phase).
	 * @param anObject This anObject will be parsed to String, escaped and placed in created text node. (Only in serialization phase).
	 *
	 * @return Object - The serialized object
	 */
	@TestVisible
	protected Object registerTextNode(Type valueType, String name, String namespace, String prefix, Object anObject)
	{
		if(context == NodeContext.SERIALIZATION)
		{
			if(anObject != null)
			{
				Dom.XmlNode childNode = xmlNode.addChildElement(name, namespace, prefix);
				String textValue = convertObjectToNodeValue(anObject);
				childNode.addTextNode(textValue);
			}

			return anObject;
		}
		else
		{
			Dom.XmlNode textNode = xmlNode.getChildElement(name, namespace);
			String nodeValue = textNode == null ? CMN_UTIL_String.EMPTY : textNode.getText();
			return convertNodeValueToType(valueType, nodeValue);
		}
	}

	/**
	 * @description Invokes registerAttribute with null key namespace and anObject namespace, presets required type to "Ddate"
	 *
	 * @param key - The key of the attribute to register
	 * @param anObject - The object on which the attribute will be added
	 *
	 * @return The Date value of the attribute
	 */
	protected Date registerDateAttribute(String key, Object anObject)
	{
		return (Date)registerAttribute(Date.class, key, anObject);
	}

	/**
	 * @description Invokes registerAttribute with null key namespace and anObject namespace, presets required type to "Datetime"
	 *
	 * @param key - The key of the attribute to register
	 * @param anObject - The object on which the attribute will be added
	 *
	 * @return The Datetime value of the attribute
	 */
	protected Datetime registerDatetimeAttribute(String key, Object anObject)
	{
		return (Datetime)registerAttribute(Datetime.class, key, anObject);
	}

	/**
	 * @description Invokes registerAttribute with null key namespace and anObject namespace, presets required type to "String"
	 *
	 * @param key - The key of the attribute to register
	 * @param anObject - The object on which the attribute will be added
	 *
	 * @return The string value of the attribute
	 */
	protected String registerStringAttribute(String key, Object anObject)
	{
		return (String)registerAttribute(String.class, key, anObject);
	}

	/**
	 * @description Invokes registerAttribute with null key namespace and anObject namespace.
	 *
	 * @param valueType Type - The type of the attribute to register
	 * @param key - The key of the attribute to register
	 * @param anObject - The object on which the attribute will be added
	 *
	 * @return The registered Attribute
	 */
	@TestVisible
	protected Object registerAttribute(Type valueType, String key, Object anObject)
	{
		return registerAttribute(valueType, key, anObject, null, null);
	}

	/**
	 * @description Serialization Phase:
	 * Sets attribute on XML Node.
	 * <p/>
	 * Deserialization Phase:
	 * Returns attribute from deserialized node.
	 *
	 * @param valueType Attribute anObject will be automatically parsed to this type. (Deserialization phase only)
	 * @param key Attribute key
	 * @param anObject Attribute anObject
	 * @param keyNamespace Namespace of the attribute's key. (Serialization phase only)
	 * @param valueNamespace Namespace of the attribute's anObject. (Serialization phase only)
	 *
	 * @return Serialization: returns passed anObject. Deserialization: returns attribute's anObject.
	 */
	protected Object registerAttribute(Type valueType, String key, Object anObject, String keyNamespace, String valueNamespace)
	{
		if(context == NodeContext.SERIALIZATION)
		{
			String textValue = convertObjectToNodeValue(anObject);
			xmlNode.setAttributeNs(key, textValue, keyNamespace, valueNamespace);
			return anObject;
		}
		else
		{
			String attributeValue = xmlNode.getAttributeValue(key, keyNamespace);
			return convertNodeValueToType(valueType, attributeValue);
		}
	}

	/**
	 * @description Will take an object and convert into text taking into consideration the type of the object
	 *
	 * @param anObject A primitive object type
	 *
	 * @return A string with type in the correct format
	 */
	private String convertObjectToNodeValue(Object anObject)
	{
		if(anObject != null)
		{
			if(anObject instanceof Date)
			{
				return CMN_UTIL_Date.dateToIso8601String((Date)anObject);
			}
			else if(anObject instanceof Datetime)
			{
				return CMN_UTIL_Date.dateTimeToIso8601String((Datetime)anObject);
			}
			else
			{
				return String.valueOf(anObject).escapeXml();
			}
		}

		return null;
	}

	/**
	 * @description Method to parse a string value from an Node and return it's type
	 *
	 * @param requiredType - The type of the return object
	 * @param nodeValue - The text value from a node
	 *
	 * @return Value of the text node child specified by name and namespace.
	 * Value is parsed to given primitive or enum type, or returned as String if type is not supported.
	 */
	private Object convertNodeValueToType(Type requiredType, String nodeValue)
	{
		if(String.isNotBlank(nodeValue))
		{
			if(requiredType == String.class)
			{
				return nodeValue;
			}
			if(requiredType == Double.class)
			{
				return Double.valueOf(nodeValue);
			}
			if(requiredType == Decimal.class)
			{
				return Decimal.valueOf(nodeValue);
			}
			if(requiredType == Integer.class)
			{
				return Integer.valueOf(nodeValue);
			}
			if(requiredType == Long.class)
			{
				return Long.valueOf(nodeValue);
			}
			if(requiredType == Date.class)
			{
				return CMN_UTIL_Date.iso8601StringToDate(nodeValue);
			}
			if(requiredType == Datetime.class)
			{
				return CMN_UTIL_Date.iso8601StringToDateTime(nodeValue);
			}
			if(requiredType == Boolean.class)
			{
				return CMN_UTIL_Boolean.stringToBoolean(nodeValue);
			}

			/*Attempt to cast string anObject to Enum. This is only possible through JSON deserialization to List<Enums>*/
			try
			{
				List<Object> enums = (List<Object>)JSON.deserialize('["' + nodeValue + '"]', Type.forName('List<' + requiredType + '>'));
				return enums.iterator().hasNext() ? enums.iterator().next() : null;
			}
			catch(Exception error)
			{
				CMN_UTIL_Logger.error(error, 'CMN_DTO_XmlBase/parseStringValue');
			}

			return nodeValue;
		}
		return null;
	}

	/**
	 * @description Unique kind of XML Node which is restricted only for top most node - a root node
	 * This implementation can convert all class hierarchy into a Dom document and deserialize Dom Document into
	 * class hierarchy.
	 */
	public abstract class DTO_XmlRootNode extends CMN_DTO_XmlBase
	{
		private transient Dom.Document document;

		/**
		 * @description Suppresses null values when serializing Apex objects
		 *
		 * @return XML string
		 */
		public override String serialize()
		{
			context = NodeContext.SERIALIZATION;
			registerXML_internal(context);
			//Calling base class to ensure code coverage
			return super.serialize() + document.toXmlString();
		}

		/**
		 * @description Will deserialise the string and return pointer to current class
		 *
		 * @param dtoString A XML string
		 *
		 * @return Deserialized DTO
		 */
		public override CMN_DTO_Base deserialize(String dtoString)
		{
			//Calling base class to ensure code coverage
			CMN_DTO_Base dtoBase = super.deserialize(dtoString);

			context = NodeContext.DESERIALIZATION;

			document = new Dom.Document();
			document.load(dtoString);
			xmlNode = document.getRootElement();
			registerXML_internal(context);

			return dtoBase;
		}

		/**
		 * @description Will register the root node for the XML Dom
		 *
		 * @param nodeName The name of the root node
		 * @param namespace The namespace of the root node (if exists)
		 * @param prefix The element prefix for the root node (if exists)
		 */
		protected void registerRootNode(String nodeName, String namespace, String prefix)
		{
			if(context == NodeContext.SERIALIZATION)
			{
				document = new Dom.Document();
				xmlNode = document.createRootElement(nodeName, namespace, prefix);
			}
		}
	}
}