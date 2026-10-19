/**
 * @description       : DTO class for Template rest request
 * User Story		  : SFP-31300
 * @author            : Aliaksei Koval
 * @last modified on  : 06-24-2025
 * @last modified by  : Aliaksei Koval
**/
public with sharing class SVC_DTO_TemplateServiceRestRequest {

    public List<Template> template;
	public List<Merge_fields> merge_fields;
	public String output_mime_type;
	public boolean is_store_after_generate;
	public boolean is_include_output_file;
	public Document_properties document_properties;
	public String channel_id;
	
	public class Template {
		public String channelId;
		public String templateDefId;
	}

	public class Merge_fields {
		public String key;
		public String type;
		public List<Fields> fields;
	}

	public class Fields {
		public List<Fields> fields;
		public String type;
		public String key;
		public String value;
	}

	public class Document_properties {
		public CustomerProperty customerProperty;
	}

	public class CustomerProperty {
		public String bpid;
		public String identityNumber;
		public String initial;
		public String surNameOrCompanyName;
	}
}