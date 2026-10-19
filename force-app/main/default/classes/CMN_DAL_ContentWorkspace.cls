/**
 * @description Data Access Layer SOQL related to the ContentWorkspace Object,
 * this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date March 2021
 */
public with sharing class CMN_DAL_ContentWorkspace
{
	/**
	 * @description Will provide a list of the default ContentWorkspace fields
	 *
	 * @return List of Fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentWorkspace.Description.getDescribe().getLocalName(),
				ContentWorkspace.DeveloperName.getDescribe().getLocalName(),
				ContentWorkspace.Id.getDescribe().getLocalName(),
				ContentWorkspace.IsRestrictContentTypes.getDescribe().getLocalName(),
				ContentWorkspace.IsRestrictLinkedContentTypes.getDescribe().getLocalName(),
				ContentWorkspace.Name.getDescribe().getLocalName(),
				ContentWorkspace.NamespacePrefix.getDescribe().getLocalName(),
				ContentWorkspace.RootContentFolderId.getDescribe().getLocalName(),
				ContentWorkspace.ShouldAddCreatorMembership.getDescribe().getLocalName(),
				ContentWorkspace.TagModel.getDescribe().getLocalName(),
				ContentWorkspace.WorkspaceImageId.getDescribe().getLocalName(),
				ContentWorkspace.WorkspaceType.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will retrieve ContentWorkspace based on name
	 *
	 * @param workspaceName The name of the workspace
	 *
	 * @return Either null or a Workspace
	 */
	public static ContentWorkspace findWorkspaceByName(String workspaceName)
	{
		return (ContentWorkspace)CMN_DAL_SObjectSelector.findByName(ContentWorkspace.SObjectType, workspaceName, getDefaultFields());
	}
	/**
	 * @description Will retrieve ContentWorkspace based on the Name
	 *
	 * @param names
	 *
	 * @return Either null or a Workspace
	 */
	public static List<ContentWorkspace> findWorkspacesByName(Set<String> names)
	{
		return CMN_DAL_SObjectSelector.findByField(ContentWorkspace.SObjectType.getDescribe().getLocalName(), ContentWorkspace.Name.getDescribe().getLocalName(), names, getDefaultFields());
	}

	/**
	 * @description Will retrieve ContentWorkspace based on an Id
	 *
	 * @param workspaceIds the ids of the workspaces
	 *
	 * @return Either null or a Workspace
	 */
	public static List<ContentWorkspace> findWorkspaceById(Set<Id> workspaceIds)
	{
		return CMN_DAL_SObjectSelector.findById(ContentWorkspace.SObjectType, workspaceIds, getDefaultFields());
	}
}