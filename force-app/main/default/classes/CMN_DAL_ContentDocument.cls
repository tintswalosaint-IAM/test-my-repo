/**
 * @description Data Access Layer SOQL related to the ContentDocument Object,
 * this is common class to be used across applications
 *
 * @author Accenture
 *
 * @date March 2021
 */
public with sharing class CMN_DAL_ContentDocument
{
	/**
	 * @description Will return base fields to return on a query
	 *
	 * @return A list of Content Document fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentDocument.ArchivedById.getDescribe().getLocalName(),
				ContentDocument.ArchivedDate.getDescribe().getLocalName(),
				ContentDocument.ContentAssetId.getDescribe().getLocalName(),
				ContentDocument.ContentModifiedDate.getDescribe().getLocalName(),
				ContentDocument.ContentSize.getDescribe().getLocalName(),
				ContentDocument.CreatedById.getDescribe().getLocalName(),
				ContentDocument.CreatedDate.getDescribe().getLocalName(),
				ContentDocument.Description.getDescribe().getLocalName(),
				ContentDocument.FileExtension.getDescribe().getLocalName(),
				ContentDocument.FileType.getDescribe().getLocalName(),
				ContentDocument.Id.getDescribe().getLocalName(),
				ContentDocument.IsArchived.getDescribe().getLocalName(),
				ContentDocument.IsDeleted.getDescribe().getLocalName(),
				ContentDocument.LastModifiedById.getDescribe().getLocalName(),
				ContentDocument.LastModifiedDate.getDescribe().getLocalName(),
				ContentDocument.LastReferencedDate.getDescribe().getLocalName(),
				ContentDocument.LastViewedDate.getDescribe().getLocalName(),
				ContentDocument.LatestPublishedVersionId.getDescribe().getLocalName(),
				ContentDocument.OwnerId.getDescribe().getLocalName(),
				ContentDocument.ParentId.getDescribe().getLocalName(),
				ContentDocument.PublishStatus.getDescribe().getLocalName(),
				ContentDocument.SharingOption.getDescribe().getLocalName(),
				ContentDocument.SharingPrivacy.getDescribe().getLocalName(),
				ContentDocument.SystemModstamp.getDescribe().getLocalName(),
				ContentDocument.Title.getDescribe().getLocalName()
		};
	}

	/**
	 * @description Returns content document Ids related to content folder members
	 *
	 * @param contentFolderMembers List of content folder members
	 *
	 * @return List of content document Ids
	 */
	public static List<Id> getContentDocumentIdsByContentFolderMember(List<ContentFolderMember> contentFolderMembers)
	{
		return CMN_UTIL_System.extractListValues(contentFolderMembers, ContentFolderMember.ChildRecordId.getDescribe().getLocalName());
	}

	/**
	 * @description Returns content documents by Ids
	 *
	 * @param contentDocumentIds Set of ContentDocument Ids
	 *
	 * @return List of ContentDocuments
	 */
	public static List<ContentDocument> getContentDocumentsById(Set<Id> contentDocumentIds)
	{
		return CMN_DAL_SObjectSelector.findById(ContentDocument.SObjectType.getDescribe().getLocalName(), contentDocumentIds, getDefaultFields());
	}

	/**
	 * @description Returns content documents by Ids
	 *
	 * @param contentVersions List of ContentVersions
	 *
	 * @return List of ContentDocuments
	 */
	public static List<ContentDocument> getContentDocumentsFromContentVersions(List<ContentVersion> contentVersions)
	{
		return getContentDocumentsById(CMN_UTIL_System.extractListIds(contentVersions, ContentVersion.ContentDocumentId.getDescribe().getLocalName()));
	}
}