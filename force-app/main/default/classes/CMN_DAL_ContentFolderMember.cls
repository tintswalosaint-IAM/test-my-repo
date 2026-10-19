/**
 * @description Data Access Layer SOQL related to the ContentFolderMember Object,
 * this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date March 2021
 */
public inherited sharing class CMN_DAL_ContentFolderMember
{
	/**
	 * @description The default fields to query from the ContentFolderMember Object
	 *
	 * @return A list of ContentFolderMember fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentFolderMember.ChildRecordId.getDescribe().getLocalName(),
				ContentFolderMember.Id.getDescribe().getLocalName(),
				ContentFolderMember.ParentContentFolderId.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Will retrieve content folder members in a workspace using folder name
	 *
	 * @param workspaceIds set of workspace ids to check
	 * @param folderIds set of folder ids to look for files in
	 *
	 * @return A list of members
	 */
	public static List<ContentFolderMember> findMembersByFoldersInWorkspaces(Set<Id> workspaceIds, Set<Id> folderIds)
	{
		return
		[
				SELECT
						ChildRecordId,
						ParentContentFolderId
				FROM ContentFolderMember
				WHERE
				ParentContentFolderId IN :folderIds
				AND ChildRecord.ParentId IN :workspaceIds
				WITH SECURITY_ENFORCED
		];
	}

	/**
	 * @description Will retrieve content folder member by file id
	 *
	 * @param fileId ContentDocumentId of file
	 *
	 * @return A Content Folder Member object
	 */
	public static ContentFolderMember findFolderMembersByChildRecordId(Id fileId)
	{
		return (ContentFolderMember)CMN_DAL_SObjectSelector.findByField(ContentFolderMember.SObjectType, ContentFolderMember.ChildRecordId, fileId, getDefaultFields(), true);
	}

}