/**
 * @description Provides Query methods related to ContentVersion object
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_ContentVersion
{
	private final static String OBJECT_NAME = ContentVersion.SObjectType.getDescribe().getLocalName();

	/**
	 * @description The default fields to query from the ContentVersion Object
	 *
	 * @return A list of ContentVersion¬ fields
	 */
	private static Set<String> getDefaultFields()
	{
		return new Set<String>
		{
				ContentVersion.Checksum.getDescribe().getLocalName(),
				ContentVersion.ContentBodyId.getDescribe().getLocalName(),
				ContentVersion.ContentDocumentId.getDescribe().getLocalName(),
				ContentVersion.ContentLocation.getDescribe().getLocalName(),
				ContentVersion.ContentSize.getDescribe().getLocalName(),
				ContentVersion.ContentUrl.getDescribe().getLocalName(),
				ContentVersion.Description.getDescribe().getLocalName(),
				ContentVersion.ExternalDataSourceId.getDescribe().getLocalName(),
				ContentVersion.ExternalDocumentInfo1.getDescribe().getLocalName(),
				ContentVersion.ExternalDocumentInfo2.getDescribe().getLocalName(),
				ContentVersion.FeaturedContentBoost.getDescribe().getLocalName(),
				ContentVersion.FeaturedContentDate.getDescribe().getLocalName(),
				ContentVersion.FileExtension.getDescribe().getLocalName(),
				ContentVersion.FileType.getDescribe().getLocalName(),
				ContentVersion.FirstPublishLocationId.getDescribe().getLocalName(),
				ContentVersion.Id.getDescribe().getLocalName(),
				ContentVersion.IsAssetEnabled.getDescribe().getLocalName(),
				ContentVersion.IsDeleted.getDescribe().getLocalName(),
				ContentVersion.IsLatest.getDescribe().getLocalName(),
				ContentVersion.IsMajorVersion.getDescribe().getLocalName(),
				ContentVersion.NegativeRatingCount.getDescribe().getLocalName(),
				ContentVersion.Origin.getDescribe().getLocalName(),
				ContentVersion.OwnerId.getDescribe().getLocalName(),
				ContentVersion.PathOnClient.getDescribe().getLocalName(),
				ContentVersion.PositiveRatingCount.getDescribe().getLocalName(),
				ContentVersion.PublishStatus.getDescribe().getLocalName(),
				ContentVersion.RatingCount.getDescribe().getLocalName(),
				ContentVersion.ReasonForChange.getDescribe().getLocalName(),
				ContentVersion.SharingOption.getDescribe().getLocalName(),
				ContentVersion.SharingPrivacy.getDescribe().getLocalName(),
				ContentVersion.SystemModstamp.getDescribe().getLocalName(),
				ContentVersion.TagCsv.getDescribe().getLocalName(),
				ContentVersion.TextPreview.getDescribe().getLocalName(),
				ContentVersion.Title.getDescribe().getLocalName(),
				ContentVersion.VersionData.getDescribe().getLocalName(),
				ContentVersion.VersionNumber.getDescribe().getLocalName()
		};
	}
	/**
	 * @description Queries ContentVersion for all the times linked to the given firstPublishLocationId
	 *
	 * @param firstPublishLocationId ID of the location where the version was first published.
	 *
	 * @return List of Content Version; note this only queries for latest version
	 */
	@TestVisible
	private static List<ContentVersion> findByFirstPublishLocationId(Id firstPublishLocationId)
	{
		return
		[
				SELECT
						ContentBodyId,
						ContentDocumentId,
						ContentLocation,
						ContentSize,
						ContentUrl,
						Description,
						FileExtension,
						FileType,
						Id,
						PathOnClient,
						Title,
						VersionData
				FROM ContentVersion
				WHERE FirstPublishLocationId = :firstPublishLocationId
				AND IsLatest = TRUE
		];
	}

	/**
	 * @description Will attrieve the Latest Content Version for given Content Documents
	 *
	 * @param contentDocumentIds Content Document Ids
	 *
	 * @return A list of Content Versions
	 */
	public static List<ContentVersion> findLatestByContentDocumentId(Set<Id> contentDocumentIds)
	{
		return
		[
				SELECT
						Checksum,
						ContentBodyId,
						ContentDocumentId,
						ContentLocation,
						ContentSize,
						ContentUrl,
						Description,
						FileExtension,
						FileType,
						FirstPublishLocationId,
						Id,
						IsLatest,
						Origin,
						OwnerId,
						PathOnClient,
						TagCsv,
						TextPreview,
						Title,
						VersionData,
						VersionNumber
				FROM ContentVersion
				WHERE ContentDocumentId = :contentDocumentIds
				AND IsLatest = TRUE
				AND IsDeleted = FALSE
		];
	}

	/**
	 * @description Returns ContentVersion documents in a specified library (ContentWorkspace)
	 * that are in a specified folder name
	 *
	 * @param libraryFolders Map of library and folder names. The key is the name of the library,
	 * and the value is a list of folder names in that library.
	 *
	 * @return Map of library-folder maps. The first key level will be the library name, and the values
	 * are folder-contentversion maps. The second key level will be the folder name, and the values are
	 * a list of all content versions contained in that folder.
	 */
	public static Map<String, Map<String, List<ContentVersion>>> findContentVersionsByWorkspaceFolders(Map<String, List<String>> libraryFolders)
	{
		Set<String> folders = new Set<String>();
		for(String libraryName : libraryFolders.keySet())
		{
			folders.addAll(libraryFolders.get(libraryName));
		}
		List<ContentFolder> folderObjects = CMN_DAL_ContentFolder.findContentFoldersByName(folders);
		List<ContentWorkspace> libraryObjects = CMN_DAL_ContentWorkspace.findWorkspacesByName(libraryFolders.keySet());

		Set<Id> folderIds = CMN_UTIL_System.extractListIds(folderObjects);
		Set<Id> libraryIds = CMN_UTIL_System.extractListIds(libraryObjects);

		List<ContentFolderMember> files = CMN_DAL_ContentFolderMember.findMembersByFoldersInWorkspaces(libraryIds, folderIds);
		List<ContentDocument> contentDocuments = CMN_DAL_ContentDocument.getContentDocumentsById(new Set<Id>(CMN_DAL_ContentDocument.getContentDocumentIdsByContentFolderMember(files)));
		List<ContentVersion> contentVersions = findLatestByContentDocumentId(CMN_UTIL_System.extractListIds(contentDocuments));

		Map<String, Map<String, List<ContentVersion>>> documentList = new Map<String, Map<String, List<ContentVersion>>>();

		for(String libraryName : libraryFolders.keySet())
		{
			for(String folderName : libraryFolders.get(libraryName))
			{
				// Find the docs belonging to the library
				List<ContentWorkspace> lib = (List<ContentWorkspace>)CMN_UTIL_System.findWhere(libraryObjects, ContentWorkspace.Name.getDescribe().getLocalName(), libraryName);
				ContentWorkspace library = lib.isEmpty() ? new ContentWorkspace() : lib.iterator().next();
				List<ContentDocument> retrievedDocs = (List<ContentDocument>)CMN_UTIL_System.findWhere(contentDocuments, ContentDocument.ParentId.getDescribe().getLocalName(), library.Id);

				// Find the contentfolder members (link to docs) belonging to the folder
				List<ContentFolder> folderList = (List<ContentFolder>)CMN_UTIL_System.findWhere(folderObjects, ContentFolder.Name.getDescribe().getLocalName(), folderName);
				List<ContentFolderMember> folderMembers = (List<ContentFolderMember>)CMN_UTIL_System.findWhereIn(files, ContentFolderMember.ParentContentFolderId.getDescribe().getLocalName(), new List<Id>(CMN_UTIL_System.extractListIds(folderList)));
				Set<String> folderMemberDocIds = CMN_UTIL_System.extractSetValues(folderMembers, ContentFolderMember.ChildRecordId.getDescribe().getLocalName());

				// Find all the docs in folder belonging to the library
				retrievedDocs = CMN_UTIL_System.findWhereIn(retrievedDocs, ContentDocument.Id.getDescribe().getLocalName(), new List<String>(folderMemberDocIds));
				List<ContentVersion> retrievedContentVersions = CMN_UTIL_System.findWhereIn(contentVersions, ContentVersion.ContentDocumentId.getDescribe().getLocalName(), new List<Id>(CMN_UTIL_System.extractListIds(retrievedDocs)));

				if(documentList.containsKey(libraryName))
				{
					if(!documentList.get(libraryName).containsKey(folderName))
					{
						documentList.get(libraryName).put(folderName, retrievedContentVersions);
					}
					else
					{
						IllegalArgumentException e = new IllegalArgumentException();
						e.setMessage('Multiple folders with the same name requested from the same library.\nThe use of this function assumes that the folder is a direct child of the library or that the folder name is unique to other folders in the same request.');
						throw e;
					}
				}
				else
				{
					Map<String, List<ContentVersion>> folderMap = new Map<String, List<ContentVersion>>();
					folderMap.put(folderName, retrievedContentVersions);
					documentList.put(libraryName, folderMap);
				}
			}
		}

		return documentList;
	}

	/**
	 * @description Will retrieve all content versions
	 *
	 * @return A list of Content Versions
	 */
	@TestVisible
	private static List<ContentVersion> getAll()
	{
		return CMN_DAL_Search.getAll(OBJECT_NAME, getDefaultFields());
	}
}