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
 * @description Test class for the CMN_DTO_XmlBase class and it's related methods, this test class used the
 *              user profile metadata as an example
 *
 * @see CMN_DTO_XmlBase for usage.
 *
 * @author Piotr Kożuchowski
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_DTO_XmlBase_TEST
{
	private final static String NAMESPACE = 'http://soap.sforce.com/2006/04/metadata';
	private final static String PREFIX = CMN_UTIL_String.EMPTY;
	private final static String REGEX_REMOVE_XML_WHITESPACE = '>(\\s)*<';

	// Sample XML used to inject an attribute
	private final static String XML_MISSING_ATTRIBUTES = '<?xml version="1.0" encoding="UTF-8"?>'
			+ '<SampleRootNode>'
			+ '    <sampleNode>Sample Value</sampleNode>'
			+ '</SampleRootNode>';

	// Full Valid XML payload
	private final static String VALID_PROFILE_XML = '<?xml version="1.0" encoding="UTF-8"?>'
			+ '<Profile xmlns="http://soap.sforce.com/2006/04/metadata">'
			+ '    <classAccesses>'
			+ '        <apexClass>AccountSelector</apexClass>'
			+ '        <enabled>true</enabled>'
			+ '    </classAccesses>'
			+ '    <classAccesses>'
			+ '        <apexClass>AccountTriggerHandler</apexClass>'
			+ '        <enabled>true</enabled>'
			+ '    </classAccesses>'
			+ '    <custom>false</custom>'
			+ '    <fieldPermissions>'
			+ '        <editable>false</editable>'
			+ '        <field>Log__c.ApexClass__c</field>'
			+ '        <readable>false</readable>'
			+ '    </fieldPermissions>'
			+ '    <fieldPermissions>'
			+ '        <editable>false</editable>'
			+ '        <field>Log__c.LoggingLevel__c</field>'
			+ '        <readable>false</readable>'
			+ '    </fieldPermissions>'
			+ '    <fieldPermissions>'
			+ '        <editable>false</editable>'
			+ '        <field>Log__c.Message__c</field>'
			+ '        <readable>false</readable>'
			+ '    </fieldPermissions>'
			+ '    <layoutAssignments>'
			+ '        <layout>Account-Account Layout</layout>'
			+ '    </layoutAssignments>'
			+ '    <layoutAssignments>'
			+ '        <layout>LogRetention__mdt-Logging Setting Layout</layout>'
			+ '    </layoutAssignments>'
			+ '    <objectPermissions>'
			+ '        <allowCreate>true</allowCreate>'
			+ '        <allowDelete>true</allowDelete>'
			+ '        <allowEdit>true</allowEdit>'
			+ '        <allowRead>true</allowRead>'
			+ '        <modifyAllRecords>true</modifyAllRecords>'
			+ '        <object>Log__c</object>'
			+ '        <viewAllRecords>true</viewAllRecords>'
			+ '    </objectPermissions>'
			+ '    <objectPermissions>'
			+ '        <allowCreate>true</allowCreate>'
			+ '        <allowDelete>true</allowDelete>'
			+ '        <allowEdit>true</allowEdit>'
			+ '        <allowRead>true</allowRead>'
			+ '        <modifyAllRecords>true</modifyAllRecords>'
			+ '        <object>LoggingEvent__e</object>'
			+ '        <viewAllRecords>true</viewAllRecords>'
			+ '    </objectPermissions>'
			+ '    <pageAccesses>'
			+ '        <apexPage>TestPage</apexPage>'
			+ '        <enabled>true</enabled>'
			+ '    </pageAccesses>'
			+ '    <tabVisibilities>'
			+ '        <tab>Log__c</tab>'
			+ '        <visibility>DefaultOn</visibility>'
			+ '    </tabVisibilities>'
			+ '    <tabVisibilities>'
			+ '        <tab>Test</tab>'
			+ '        <visibility>DefaultOn</visibility>'
			+ '    </tabVisibilities>'
			+ '    <userLicense>Salesforce</userLicense>'
			+ '    <userPermissions>'
			+ '        <enabled>true</enabled>'
			+ '        <name>ActivateContract</name>'
			+ '    </userPermissions>'
			+ '    <userPermissions>'
			+ '        <enabled>true</enabled>'
			+ '        <name>ActivateOrder</name>'
			+ '    </userPermissions>'
			+ '    <userPermissions>'
			+ '        <enabled>true</enabled>'
			+ '        <name>ActivitiesAccess</name>'
			+ '    </userPermissions>'
			+ '    <typesNode stringAttribute="1234" dateAttribute="2021-01-13" datetimeAttribute="1994-11-05T08:15:30.000Z">'
			+ '   		<sampleDate>2021-01-13</sampleDate>'
			+ '			<sampleDateTime>1994-11-05T08:15:30.000Z</sampleDateTime>'
			+ '			<sampleLong>2147483648</sampleLong>'
			+ '			<sampleInteger>1972</sampleInteger>'
			+ '			<sampleDecimal>49.40</sampleDecimal>'
			+ ' 		<sampleDouble>3.14159</sampleDouble>'
			+ '    </typesNode>'
			+ '</Profile>';

	/**
	 * @description Test class to assert that an XML string is deserialized to ProfileNode class.
	 */
	@IsTest
	private static void deserialize()
	{
		DTO_Profile profileNode = new DTO_Profile();
		profileNode.deserialize(VALID_PROFILE_XML);
		String expectedJson = '{"userPermissions":[{"name":"ActivateContract","enabled":true},{"name":"ActivateOrder","enabled":true},{"name":"ActivitiesAccess","enabled":true}],"userLicense":"Salesforce","typesNode":{"stringAttribute":"1234","sampleLong":2147483648,"sampleInteger":1972,"sampleDouble":3.14159,"sampleDecimal":49.40,"sampleDateTime":"1994-11-05T08:15:30.000Z","sampleDate":"2021-01-13","datetimeAttribute":"1994-11-05T08:15:30.000Z","dateAttribute":"2021-01-13"},"tabVisibilities":[{"visibility":"DefaultOn","tab":"Log__c"},{"visibility":"DefaultOn","tab":"Test"}],"pageAccesses":[{"enabled":true,"apexPage":"TestPage"}],"objectPermissions":[{"viewAllRecords":true,"object_x":"Log__c","modifyAllRecords":true,"allowRead":true,"allowEdit":true,"allowDelete":true,"allowCreate":true},{"viewAllRecords":true,"object_x":"LoggingEvent__e","modifyAllRecords":true,"allowRead":true,"allowEdit":true,"allowDelete":true,"allowCreate":true}],"layoutAssignments":[{"layout":"Account-Account Layout"},{"layout":"LogRetention__mdt-Logging Setting Layout"}],"fieldPermissions":[{"readable":false,"field":"Log__c.ApexClass__c","editable":false},{"readable":false,"field":"Log__c.LoggingLevel__c","editable":false},{"readable":false,"field":"Log__c.Message__c","editable":false}],"custom":false,"classAccesses":[{"enabled":true,"apexClass":"AccountSelector"},{"enabled":true,"apexClass":"AccountTriggerHandler"}]}';
		String actualJson = JSON.serialize(profileNode);
		System.assertEquals(expectedJson, actualJson, 'Deserialization failed as DTO was not correctly populated.');
	}

	/**
	 * @description Test method to test that the ProfileNode is serialized back to the XML string.
	 */
	@IsTest
	private static void serialize()
	{
		DTO_Profile profileNode = new DTO_Profile();
		profileNode.deserialize(VALID_PROFILE_XML);
		String actualXmxl = profileNode.serialize();
		String expectedXml = VALID_PROFILE_XML.replaceAll(REGEX_REMOVE_XML_WHITESPACE, '><');
		System.assertEquals(expectedXml, actualXmxl, 'Serialization failed as XML does not match original.');
	}

	/**
	 * @description Test method to cover and assert the insertion of a null list
	 */
	@IsTest
	private static void registerNullChildren()
	{
		Boolean nullExceptionCaught = false;
		DTO_RootNodeList rootNodeList = new DTO_RootNodeList();
		try
		{
			rootNodeList.deserialize(XML_MISSING_ATTRIBUTES);
		}
		catch(NullPointerException expectedScriptError)
		{
			nullExceptionCaught = true;
		}

		System.assertEquals(nullExceptionCaught, true, 'Expected script thrown exception not caught');

	}
	/**
	 * @description A DTO root node structure representing a list element
	 */
	public class DTO_RootNodeList extends CMN_DTO_XmlBase.DTO_XmlRootNode
	{
		public List<DTO_SampleNode> sampleListNodes;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			registerRootNode('SampleRootNode', NAMESPACE, PREFIX);
			sampleListNodes = (List<DTO_SampleNode>)registerTextNode(String.class, 'sampleListNodes', NAMESPACE, PREFIX, sampleListNodes);
			registerChildren(sampleListNodes, 'sampleListNodes', NAMESPACE, PREFIX);
		}
	}

	/**
	 * @description A DTO class to represent an empty node for testing null children.
	 */
	public class DTO_SampleNode extends CMN_DTO_XmlBase
	{
		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
		}
	}

	/**
	 * @description The DTO root node for the sample profile xml that includes all of the possible different data types
	 */
	public class DTO_TypesNode extends CMN_DTO_XmlBase
	{
		public String stringAttribute;
		public Date dateAttribute;
		public Datetime datetimeAttribute;
		public Date sampleDate;
		public Datetime sampleDateTime;
		public Long sampleLong;
		public Integer sampleInteger;
		public Decimal sampleDecimal;
		public Double sampleDouble;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			stringAttribute = registerStringAttribute('stringAttribute', stringAttribute);
			dateAttribute = registerDateAttribute('dateAttribute', dateAttribute);
			datetimeAttribute = registerDatetimeAttribute('datetimeAttribute', datetimeAttribute);
			sampleDate = registerDateNode('sampleDate', NAMESPACE, PREFIX, sampleDate);
			sampleDateTime = registerDatetimeNode('sampleDateTime', NAMESPACE, PREFIX, sampleDateTime);
			sampleLong = registerLongNode('sampleLong', NAMESPACE, PREFIX, sampleLong);
			sampleInteger = registerIntegerNode('sampleInteger', NAMESPACE, PREFIX, sampleInteger);
			sampleDecimal = registerDecimalNode('sampleDecimal', NAMESPACE, PREFIX, sampleDecimal);
			sampleDouble = registerDoubleNode('sampleDouble', NAMESPACE, PREFIX, sampleDouble);
		}
	}

	/**
	 * @description The DTO of the profile Root Element (Must extend XmlRootNode)
	 **/
	public class DTO_Profile extends CMN_DTO_XmlBase.DTO_XmlRootNode
	{
		public Boolean custom;
		public String userLicense;

		/*It's important to have all nodes initialized. Otherwise they will be omitted.*/
		public List<DTO_ClassAccess> classAccesses = new List<DTO_ClassAccess>();
		public List<DTO_FieldPermission> fieldPermissions = new List<DTO_FieldPermission>();
		public List<DTO_ObjectPermission> objectPermissions = new List<DTO_ObjectPermission>();
		public List<DTO_TabVisibility> tabVisibilities = new List<DTO_TabVisibility>();
		public List<DTO_LayoutAssignment> layoutAssignments = new List<DTO_LayoutAssignment>();
		public List<DTO_PageAccess> pageAccesses = new List<DTO_PageAccess>();
		public List<DTO_UserPermission> userPermissions = new List<DTO_UserPermission>();
		public DTO_TypesNode typesNode = new DTO_TypesNode();

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			registerRootNode('Profile', NAMESPACE, PREFIX);
			registerChildren(classAccesses, 'classAccesses', NAMESPACE, PREFIX);
			custom = registerBooleanNode('custom', NAMESPACE, PREFIX, custom);
			registerChildren(fieldPermissions, 'fieldPermissions', NAMESPACE, PREFIX);
			registerChildren(layoutAssignments, 'layoutAssignments', NAMESPACE, PREFIX);
			registerChildren(objectPermissions, 'objectPermissions', NAMESPACE, PREFIX);
			registerChildren(pageAccesses, 'pageAccesses', NAMESPACE, PREFIX);
			registerChildren(tabVisibilities, 'tabVisibilities', NAMESPACE, PREFIX);
			userLicense = registerStringNode('userLicense', NAMESPACE, PREFIX, userLicense);
			registerChildren(userPermissions, 'userPermissions', NAMESPACE, PREFIX);
			registerChild(typesNode, 'typesNode', NAMESPACE, PREFIX);
		}
	}

	/**
	 * @description The DTO representing the class access in the profile XML
	 */
	public class DTO_ClassAccess extends CMN_DTO_XmlBase
	{
		public String apexClass;
		public Boolean enabled;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			apexClass = registerStringNode('apexClass', NAMESPACE, PREFIX, apexClass);
			enabled = registerBooleanNode('enabled', NAMESPACE, PREFIX, enabled);
		}
	}

	/**
	 * @description The DTO representing the field permissions in the profile XML
	 */
	public class DTO_FieldPermission extends CMN_DTO_XmlBase
	{
		public String field;
		public Boolean editable;
		public Boolean readable;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			editable = registerBooleanNode('editable', NAMESPACE, PREFIX, editable);
			field = registerStringNode('field', NAMESPACE, PREFIX, field);
			readable = registerBooleanNode('readable', NAMESPACE, PREFIX, readable);
		}
	}

	/**
	 * @description The DTO representing the object permissions in the profile XML
	 */
	public class DTO_ObjectPermission extends CMN_DTO_XmlBase
	{
		public String object_x;
		public Boolean allowCreate;
		public Boolean allowDelete;
		public Boolean allowEdit;
		public Boolean allowRead;
		public Boolean modifyAllRecords;
		public Boolean viewAllRecords;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			allowCreate = registerBooleanNode('allowCreate', NAMESPACE, PREFIX, allowCreate);
			allowDelete = registerBooleanNode('allowDelete', NAMESPACE, PREFIX, allowDelete);
			allowEdit = registerBooleanNode('allowEdit', NAMESPACE, PREFIX, allowEdit);
			allowRead = registerBooleanNode('allowRead', NAMESPACE, PREFIX, allowRead);
			modifyAllRecords = registerBooleanNode('modifyAllRecords', NAMESPACE, PREFIX, modifyAllRecords);
			object_x = registerStringNode('object', NAMESPACE, PREFIX, object_x);
			viewAllRecords = registerBooleanNode('viewAllRecords', NAMESPACE, PREFIX, viewAllRecords);
		}
	}

	/**
	 * @description The DTO representing the page access in the profile XML
	 */
	public class DTO_PageAccess extends CMN_DTO_XmlBase
	{
		public String apexPage;
		public Boolean enabled;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			apexPage = registerStringNode('apexPage', NAMESPACE, PREFIX, apexPage);
			enabled = registerBooleanNode('enabled', NAMESPACE, PREFIX, enabled);
		}
	}

	/**
	 * @description A representation of the available visibility setting options to denote accessibility.
	 */
	public enum TabVisibility
	{
		DefaultOn,
		DefaultOff,
		Hidden
	}

	/**
	 * @description The DTO representing the tab visibility in the profile XML
	 */
	public class DTO_TabVisibility extends CMN_DTO_XmlBase
	{
		public String tab;
		public TabVisibility visibility;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			tab = registerStringNode('tab', NAMESPACE, PREFIX, tab);
			visibility = (TabVisibility)registerTextNode(TabVisibility.class, 'visibility', NAMESPACE, PREFIX, visibility);
		}
	}

	/**
	 * @description The DTO representing the layout assignments in the profile XML
	 */
	public class DTO_LayoutAssignment extends CMN_DTO_XmlBase
	{
		public String layout;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			layout = registerStringNode('layout', NAMESPACE, PREFIX, layout);
		}
	}

	/**
	 * @description The DTO representing the user permissions in the profile XML
	 */
	public class DTO_UserPermission extends CMN_DTO_XmlBase
	{
		public Boolean enabled;
		public String name;

		/**
		 * @description Override this method to register all text nodes and child nodes under current node.
		 *
		 * @param aNodeContext Indicates if this node is being registed for Serialization or Deserialization
		 */
		protected override void registerXML(CMN_DTO_XmlBase.NodeContext aNodeContext)
		{
			enabled = registerBooleanNode('enabled', NAMESPACE, PREFIX, enabled);
			name = registerStringNode('name', NAMESPACE, PREFIX, name);
		}
	}

}