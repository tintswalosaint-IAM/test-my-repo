/*
 ***************************************************************************************
 @Name of the Class :KYC_SRV_DocUpload_Request
 @Description :SFP-52092:Created
 @Author :Irshad 
 @Created Date :12/08/2025
 ***************************************************************************************/

public class KYC_SRV_DocUpload_Request{
	public cls_documentIdentification[] documentIdentification;
	public cls_documentDateTime documentDateTime;
	public String documentName;	//ID Document
	public String documentType;	//Identification
	public String documentFormatType;	//pdf
	public cls_documentRepositoryLocation documentRepositoryLocation;
	public cls_partyReference partyReference;
	public String documentStatus;	// Success, Failed
	public String documentStatusMessage;	//Document Uploaded Successfully, Document Upload Failed
	public cls_documentValidityPeriod documentValidityPeriod;
	public String documentStream; // blob file	
    public String documentDirectoryId;	//1230961905762304
	public class cls_documentIdentification {
		public String documentIdentificationType;	//DocumentUUID
		public String documentIdentificationValue;	//059ed44a-b58a-466d-9192-9a4c24c0f06c
		public String documentVersion;	//1
	}
	public class cls_documentDateTime {
		public String documentDateTimeType;	//UploadedDateTime
		public String documentDateTime;	//2025-01-28T13:34:29
	}
	public class cls_documentRepositoryLocation {
		public String documentRepositoryName;	//
		public String documentURL;	//documents/464981/file
	}
	public class cls_partyReference {
		public String partyIdentificationType;	//CustomerId
		public String partyIdentificationValue;	//194172920
		public String countryofIssue;	//
		public String firstName;	//Themba
		public String lastName;	//Shezi
	}
	public class cls_documentValidityPeriod {
		public String fromDateTime;	//2025-01-28T13:34:29
		public String toDateTime;	//2027-01-28T13:34:29
	}
	public static KYC_SRV_DocUpload_Request parse(String json){
		return (KYC_SRV_DocUpload_Request) System.JSON.deserialize(json, KYC_SRV_DocUpload_Request.class);
	}

}