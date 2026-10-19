/**
 * @description Data Access Layer SOQL related to the ContentFolder Object,
 * this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date March 2021
 */
public with sharing class CMN_DAL_ContentFolder
{
	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Content Folder fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentFolder.Id.getDescribe().getLocalName(),
				ContentFolder.Name.getDescribe().getLocalName(),
				ContentFolder.ParentContentFolderId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Returns list of ContentFolders by name
	 *
	 * @param folderNames List of Folder names
	 *
	 * @return List of Content Folders
	 */
	public static List<ContentFolder> findContentFoldersByName(Set<String> folderNames)
	{
		return CMN_DAL_SObjectSelector.findByField(ContentFolder.SObjectType.getDescribe().getLocalName(), ContentFolder.Name.getDescribe().getLocalName(), folderNames, getDefaultFields());
	}

	/**
	 * @description Returns all Content Folders that are a subdirectory of a specified
	 * parent folder
	 *
	 * @param parentContentFolderId Id of parent ContentFolder
	 *
	 * @return List of Content Folders
	 */
	public static List<ContentFolder> findContentFoldersByParentContentFolderId(Id parentContentFolderId)
	{
		return CMN_DAL_SObjectSelector.findByField(ContentFolder.SObjectType.getDescribe().getLocalName(), ContentFolder.ParentContentFolderId.getDescribe().getLocalName(), new Set<String> {parentContentFolderId}, getDefaultFields());
	}
}