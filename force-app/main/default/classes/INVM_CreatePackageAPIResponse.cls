public class INVM_CreatePackageAPIResponse {
	public class UploadDocumentResponses {
		public String documentId;
		public Object message;
		public List<AddSignatureFieldResponse> addSignatureFieldResponse;
	}

	public class ShareDocumentResponses {
		public String packageId;
		public List<String> documents;
	}

	public class AddSignerToWorkFlowResponses {
		public String status;
		public String statusDescription;
	}

	public String status;
	public Object statusDescription;
	public AddPackageResponse addPackageResponse;
	public List<UploadDocumentResponses> uploadDocumentResponses;
	public AddSignerToWorkFlowResponses addSignerToWorkFlowResponses;
	public List<ShareDocumentResponses> shareDocumentResponses;
	public Object updateWorkflowUserAuthenticationResponse;
	public Object integrationLinkResponse;

	public class AddSignatureFieldResponse {
	}

	public class AddPackageResponse {
		public String packageId;
		public String workflowMode;
		public String workflowType;
	}

	
	public static INVM_CreatePackageAPIResponse parse(String json) {
     	return (INVM_CreatePackageAPIResponse) System.JSON.deserialize(json, INVM_CreatePackageAPIResponse.class);
	}
}