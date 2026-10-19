public class DOC_API_GetDocument_DTO {

	public class ContentStream {
		public Integer contentLength;
		public String mimeType;
		public String fileName;
		public String content;
	}

	public class Data_Z {
		public String serviceStatus;
		public String key;
		public String step;
		public Boolean reset;
		public Data data;
		public Object actions;
	}

	public String status;
	public Data_Z data;

	

	public class Items {
		public String objectTypeId;
		public String value;
	}

	public class GetDocumentDetailsOutput {
		public DocumentDetails documentDetails;
		public ContentStream contentStream;
	}

	public class Data {
		public GetDocumentDetailsOutput getDocumentDetailsOutput;
	}

	public class Selected {
	}

	public class Properties {
		public List<Selected> selected;
		public List<Items> items;
	}

	public class DocumentDetails {
		public String objectId;
		public String serverName;
		public String repositoryId;
		public String objectTypeId;
		public String name;
		public String contentURL;
		public String creationDate;
		public String createdBy;
		public String lastModificationDate;
		public String lastModifiedBy;
		public String versionLabel;
		public Boolean isLatestVersion;
		public Boolean isMajorVersion;
		public Boolean isLatestMajorVersion;
		public Object checkinComment;
		public Properties properties;
	}

	
	public static DOC_API_GetDocument_DTO parse(String json) {
		return (DOC_API_GetDocument_DTO) System.JSON.deserialize(json, DOC_API_GetDocument_DTO.class);
	}
}