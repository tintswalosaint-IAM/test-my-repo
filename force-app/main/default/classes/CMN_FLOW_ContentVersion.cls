/**
 * @description Flow Class containing invocable methods to access ContentVersion identifiable documents.
 * This class can be used in any flow
 *
 * @author Accenture
 *
 * @date March 2021
 */
public inherited sharing class CMN_FLOW_ContentVersion
{
	/**
	 * @description Returns a list of ContentVersion ids of documents located in a specified library folder.
	 *
	 * @param dtoRequests List of DTO_FilesInLibraryFolderRequest containing pairs of workspace and folder names
	 *
	 * @return A list of ContentVersion Ids
	 */
	@InvocableMethod(Label='Get File Ids From Library Folder' Description='Gets ContentVersionIds of documents stored in a specified folder, from a specified library')
	public static List<List<Id>> getListOfContentVersionIdsFromLibraryFolder(List<DTO_FilesInLibraryFolderRequest> dtoRequests)
	{
		// key: library name, value: list of folder names
		Map<String, List<String>> libraryFolders = new Map<String, List<String>>();

		for(DTO_FilesInLibraryFolderRequest workspaceFolder : dtoRequests)
		{
			String libraryName = workspaceFolder.libraryName;
			String folderName = workspaceFolder.folderName;
			if(libraryFolders.containsKey(libraryName))
			{
				libraryFolders.get(libraryName).add(folderName);
			}
			else
			{
				libraryFolders.put(libraryName, new List<String>
				{
						folderName
				});
			}
		}

		List<List<Id>> fileIdsList = new List<List<Id>>();
		Map<String, Map<String, List<ContentVersion>>> contentVersionMap = CMN_DAL_ContentVersion.findContentVersionsByWorkspaceFolders(libraryFolders);
		for(DTO_FilesInLibraryFolderRequest request : dtoRequests)
		{
			List<ContentVersion> listForRequest = contentVersionMap.get(request.libraryName).get(request.folderName);
			fileIdsList.add(new List<Id>(CMN_UTIL_System.extractListIds(listForRequest)));
		}

		return fileIdsList;
	}

	/**
	 * @description DTO used to provide the library and folder names to the invocable method
	 */
	public class DTO_FilesInLibraryFolderRequest
	{
		@InvocableVariable(Label='Library Name' Description='Name of the library the folder is located in' Required=true)
		public String libraryName;
		@InvocableVariable(Label='Folder Name' Description='Name of the folder the files are located in' Required=true)
		public String folderName;
	}
}