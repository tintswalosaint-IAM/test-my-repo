/**
 * @description       : DTO class for Template rest response
 * User Story		  : SFP-31300
 * @author            : Aliaksei Koval
 * @last modified on  : 06-24-2025
 * @last modified by  : Aliaksei Koval
**/
public with sharing class SVC_DTO_TemplateServiceRestResponse {
    
    public class Output_document {
		@InvocableVariable
		public String content_stream;
		public List<Errors> document_properties;
		@InvocableVariable 
		public String file_name;
		@InvocableVariable 
		public String document_title;
		public String mime_type;
		public Object document_class_id;
		public Object object_store;
	}

	public class Errors {
	}

	public List<Errors> errors;
	public String status;
	public String status_description;
	@InvocableVariable 
	public Output_document output_document;
	public Object document_fields;
	public Template template;
	public Object request_id;
	public String sb_guid;
    @InvocableVariable
	public String cntt_url;

	public class Template {
		public List<Errors> errors;
		public String adapterId;
		public String channelId;
		public String contentType;
		public String ecmContentType;
		public String description;
		public String docType;
		public String ecmDocType;
		public String documentClass;
		public String entityType;
		public Object ecmEntityType;
		public String infoType;
		public String ecmInfoType;
		public Object inputContentStream;
		public String objectStore;
		public String outputMimeTypes;
		public String outputObjectStore;
		public Object repositoryDocId;
		public String repositoryId;
		public String sbGuid;
		public String templateDefId;
		public String templateName;
		public String version;
	}
}