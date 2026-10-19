/**
 * @description Class to test the retrieving ContentVersionIds email functionality in CMN_FLOW_ContentVersion
 *
 * @see CMN_FLOW_ContentVersion.getListOfContentVersionIdsFromLibraryFolder
 *
 * @author Accenture
 *
 * @date March 2021
 */
@IsTest(SeeAllData=false IsParallel=false)
private class CMN_FLOW_ContentVersion_TEST
{
	private static CMN_DAL_SObjectUnitOfWork work = new CMN_DAL_SObjectUnitOfWork(new List<Schema.SObjectType>
	{
			ContentWorkspace.SObjectType, ContentFolder.SObjectType, ContentVersion.SObjectType
	});

	private static final String LIBRARY_NAME = 'testLib';

	/**
	 * @description Returns the library created in setup()
	 *
	 * @return ContentWorkspace or fails test
	 */
	private static ContentWorkspace getLibrary()
	{
		ContentWorkspace testLibrary = CMN_DAL_ContentWorkspace.findWorkspaceByName(LIBRARY_NAME);
		System.assertNotEquals(null, testLibrary, 'Did not find the correct library, check setup().');

		ContentFolder fol = CMN_DAL_DataFactory.newContentFolder(testLibrary.RootContentFolderId);
		work.registerNew(fol);

		return testLibrary;
	}

	/**
	 * @description Returns the library created in setup()
	 *
	 * @param numberOfFolders Number of folders to create in library
	 *
	 * @return ContentWorkspace or fails test
	 */
	private static ContentWorkspace getLibrary(Integer numberOfFolders)
	{
		ContentWorkspace testLibrary = CMN_DAL_ContentWorkspace.findWorkspaceByName(LIBRARY_NAME);
		System.assertNotEquals(null, testLibrary, 'Did not find the correct library, check setup().');

		List<ContentFolder> folders = CMN_DAL_DataFactory.newContentFolders(numberOfFolders, testLibrary.RootContentFolderId);
		work.registerNew(folders);

		return testLibrary;
	}

	/**
	 * @description Returns the folder created in setup()
	 *
	 * @param testLibrary the library that was created in setup
	 *
	 * @return ContentFolder or fails test
	 */
	private static ContentFolder getFolder(ContentWorkspace testLibrary)
	{
		List<ContentFolder> folders = CMN_DAL_ContentFolder.findContentFoldersByParentContentFolderId(
				testLibrary.RootContentFolderId
		);
		System.assertEquals(1, folders.size(), 'Folder not created');
		ContentFolder folder = folders.iterator().next();
		System.assertEquals(folder.ParentContentFolderId, testLibrary.RootContentFolderId, 'Folder not linked to library.');

		return folder;
	}

	/**
	 * @description Generates multiple new content version documents in the library
	 * created in setup()
	 *
	 * @param testLibrary the library created in setup()
	 * @param numberOfDocs number of required docs
	 */
	private static void createContentVersion(ContentWorkspace testLibrary, Integer numberOfDocs)
	{
		List<ContentVersion> docs = CMN_DAL_DataFactory.newContentVersions(numberOfDocs, testLibrary.Id);
		work.registerNew(docs);
	}

	/**
	 * @description Generates a new content version document in the library
	 * created in setup()
	 *
	 * @param testLibrary the library created in setup()
	 */
	private static void createContentVersion(ContentWorkspace testLibrary)
	{
		ContentVersion doc = CMN_DAL_DataFactory.newContentVersion();
		work.registerNew(doc, ContentVersion.FirstPublishLocationId, testLibrary);
	}

	/**
	 * @description Fail the test if no content version documents are found
	 */
	private static void assertNoContentVersions()
	{
		List<ContentVersion> contentVersions = CMN_DAL_ContentVersion.getAll();
		System.assertEquals(0, contentVersions.size());
	}

	/**
	 * @description Get the content version created
	 *
	 * @return content version document or fails test
	 */
	private static ContentVersion getContentVersion()
	{
		List<ContentVersion> contentVersions = CMN_DAL_ContentVersion.getAll();
		System.assertEquals(1, contentVersions.size());
		ContentVersion contentVersion = contentVersions.iterator().next();

		return contentVersion;
	}

	/**
	 * @description Returns the document associated with a ContentVersion
	 *
	 * @param contentVersion The content version document
	 *
	 * @return ContentDocument or fails test
	 */
	private static ContentDocument getDocument(ContentVersion contentVersion)
	{
		List<ContentDocument> contentDocuments = CMN_DAL_ContentDocument.getContentDocumentsById(new Set<Id>
		{
				contentVersion.ContentDocumentId
		});
		System.assertEquals(1, contentDocuments.size());

		ContentDocument document = contentDocuments.iterator().next();
		System.assertNotEquals(null, document.ParentId);

		return document;
	}

	/**
	 * @description Fails test if the document has not been linked to a library
	 *
	 * @param document Content document
	 */
	private static void assertDocumentInContentWorkspace(ContentDocument document)
	{
		List<ContentWorkspace> contentWorkspaces = CMN_DAL_ContentWorkspace.findWorkspaceById(new Set<Id>
		{
				document.ParentId
		});
		System.assertEquals(1, contentWorkspaces.size());
	}

	/**
	 * @description Moves ContentDocument to ContentFolder.
	 * NB: ONLY use between Test.Start and Test.Stop
	 *
	 * @param folder ContentFolder to move document into
	 * @param document Document to move
	 */
	private static void moveFileToFolder(ContentFolder folder, ContentDocument document)
	{
		ContentFolderMember contentFolderMember = CMN_DAL_ContentFolderMember.findFolderMembersByChildRecordId(document.Id);
		System.assertNotEquals(null, contentFolderMember);
		contentFolderMember.ParentContentFolderId = folder.Id;

		update contentFolderMember;
	}

	/**
	 * @description Assigns ContentDocument to ContentFolder. Use update statement
	 * on the file afterwards to move the file to the assigned folder.
	 *
	 * @param folder ContentFolder to move document into
	 * @param document Document to move
	 *
	 * @return document with folder assignment
	 */
	private static ContentDocument moveFileToFolderNoUpdate(ContentFolder folder, ContentDocument document)
	{
		ContentFolderMember contentFolderMember = CMN_DAL_ContentFolderMember.findFolderMembersByChildRecordId(document.Id);
		System.assertNotEquals(null, contentFolderMember);
		contentFolderMember.ParentContentFolderId = folder.Id;

		return document;
	}

	/**
	 * @description Setup function for test class. Creates ContentWorkspace library
	 * used in all tests.
	 */
	@TestSetup
	private static void setup()
	{
		ContentWorkspace lib = CMN_DAL_DataFactory.newContentWorkspace(LIBRARY_NAME);
		work.registerNew(lib);
		work.commitWork();
	}

	/**
	 * @description Tests if the created Content Documents are found in a library folder
	 * using getListOfContentVersionIdsFromLibraryFolder and that the Ids of those
	 * documents are returned
	 */
	@IsTest
	private static void findMembersInLibraryFolder()
	{
		ContentWorkspace testLibrary = getLibrary();
		createContentVersion(testLibrary);

		Test.startTest();
		work.commitWork();
		ContentFolder folder = getFolder(testLibrary);
		ContentVersion contentVersion = getContentVersion();
		ContentDocument document = getDocument(contentVersion);
		assertDocumentInContentWorkspace(document);
		moveFileToFolder(folder, document);
		Test.stopTest();

		CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest dtoRequest = new CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest();
		dtoRequest.folderName = folder.Name;
		dtoRequest.libraryName = testLibrary.Name;

		List<List<Id>> listOfIds = CMN_FLOW_ContentVersion.getListOfContentVersionIdsFromLibraryFolder
				(
						new List<CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest>
						{
								dtoRequest
						}
				);

		System.assertEquals(1, listOfIds.size());
		List<Id> ids = listOfIds.iterator().next();
		System.assertEquals(1, ids.size());
		System.assertEquals(contentVersion.Id, ids.iterator().next());
	}

	/**
	 * @description Tests if the created Content Documents are found in a library folder
	 * using getListOfContentVersionIdsFromLibraryFolder and that the Ids of those
	 * documents are returned
	 */
	@IsTest
	private static void findMultipleMembersAcrossLibraryFolders()
	{
		Integer numberOfDocs = CMN_DAL_SObjectDomain.generateRandomInteger(2, 5);
		Integer numberOfFolders = numberOfDocs;
		ContentWorkspace testLibrary = getLibrary(numberOfFolders);
		createContentVersion(testLibrary, numberOfDocs);

		Test.startTest();
		work.commitWork();
		List<ContentFolder> folders = CMN_DAL_ContentFolder.findContentFoldersByParentContentFolderId(
				testLibrary.RootContentFolderId
		);
		List<ContentVersion> contentVersions = CMN_DAL_ContentVersion.getAll();
		List<ContentDocument> contentDocuments = CMN_DAL_ContentDocument.getContentDocumentsFromContentVersions(contentVersions);

		System.assert(folders.size() == contentDocuments.size());
		List<CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest> requests = new List<CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest>();

		for(Integer i = 0; i < folders.size(); i++)
		{
			ContentFolder folder = folders.get(i);
			ContentDocument contentDocument = contentDocuments.get(i);
			contentDocuments.set(i, moveFileToFolderNoUpdate(folder, contentDocument));

			CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest dtoRequest = new CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest();
			dtoRequest.folderName = folder.Name;
			dtoRequest.libraryName = testLibrary.Name;
			requests.add(dtoRequest);
		}

		update contentDocuments;
		Test.stopTest();

		List<List<Id>> listOfIds = CMN_FLOW_ContentVersion.getListOfContentVersionIdsFromLibraryFolder(requests);

		System.assertEquals(numberOfDocs, listOfIds.size());
	}

	/**
	 * @description Tests that no Content Documents are found in a library folder
	 * using getListOfContentVersionIdsFromLibraryFolder when no documents have been created
	 * in that folder
	 */
	@IsTest
	private static void noMembersFoundInFolder()
	{
		ContentWorkspace testLibrary = getLibrary();

		Test.startTest();
		work.commitWork();
		ContentFolder folder = getFolder(testLibrary);
		assertNoContentVersions();
		Test.stopTest();

		CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest req = new CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest();
		req.folderName = folder.Name;
		req.libraryName = testLibrary.Name;

		List<List<Id>> listOfIds = CMN_FLOW_ContentVersion.getListOfContentVersionIdsFromLibraryFolder(
				new List<CMN_FLOW_ContentVersion.DTO_FilesInLibraryFolderRequest>
				{
						req
				}
		);

		System.assertEquals(1, listOfIds.size());
		List<Id> ids = listOfIds.iterator().next();
		System.assertEquals(0, ids.size());
	}
}