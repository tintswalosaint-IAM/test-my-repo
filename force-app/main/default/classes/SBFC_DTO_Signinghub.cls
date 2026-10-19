/**
 * @description       : SFP-54443 - DTO class for creating payload for lawTrust document upload
 * @author            : Amlendu Bajpai
 * @group             : 
 * @last modified on  : 05-14-2026
 * @last modified by  : Amlendu Bajpai
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-13-2026   Amlendu Bajpai   Initial Version
**/
public with sharing class SBFC_DTO_Signinghub {
    
    /**
     * @description Request data transformation object
     */
    public class DTO_Request {
        public String channelId;
        public DTO_AddPackageRequest addPackageRequest;
        public List<DTO_UploadDocumentRequests> uploadDocumentRequests;
        public Boolean shareDocument;
        public DTO_AddSignerToWorkflowRequest addSignerToWorkflowRequest;

        public List<DTO_StoreDocumentReqBos> storeDocumentReqBos;
		public String packageId;        
    } 
    
    /**
     * @description storeDocumentReqBos data transformation object
     */
    public class DTO_StoreDocumentReqBos{
		public Boolean evidenceDocumentReport;
		public String signingHubDocumentId;
	}

    /**
     * @description documents data transformation object
     */
    public class DTO_Documents{
		public String statusDescription;
		public String sbGuide;
		public String fnGuide;
		public String status;
	}

    /**
     * @description Request data transformation object
     */
    public class DTO_Response {
        public String status;
        public String statusDescription;
        public DTO_AddPackageResponse addPackageResponse;
        public List<DTO_UploadDocumentResponses> uploadDocumentResponses;
        public DTO_AddSignerToWorkFlowResponse addSignerToWorkFlowResponse;
        public List<DTO_ShareDocumentResponses> shareDocumentResponses;
        public Object updateWorkflowUserAuthenticationResponse;
        public Object integrationLinkResponse;
        public String traceId;

        public String packageId;
        public List<DTO_Documents> documents;
    }

    /* @description AddSignatureField response data transformation object
    */
   public class DTO_AddSignatureFieldResponses {
       public String fieldName;
       public String message;
   }

   /**
    * @description UploadDocument response data transformation object
    */
   public class DTO_UploadDocumentResponses {
       public String documentId;
       public String message;
       public List<DTO_AddSignatureFieldResponses> addSignatureFieldResponses;
   }

   /**
    * @description ShareDocument response data transformation object
    */
   public class DTO_ShareDocumentResponses {
       public String packageId;
       public List<String> documents;
   }

   /**
    * @description AddPackage response data transformation object
    */
   public class DTO_AddPackageResponse {
       public String packageId;
       public String workflowMode;
       public String workflowType;
   }

   /**
    * @description addSignerToWorkflow response data transformation object
    */
   public class DTO_AddSignerToWorkFlowResponse {
       public String status;
       public String statusDescription;
   }

    /**
     * @description package request data transformation object
     */
    public class DTO_AddPackageRequest {
        public String packageName;
        public String workflowMode;
        public String workflowType;
    }

    /**
     * @description customer property request data transformation object
     */
    public class DTO_CustomerProperty {
        public String bpid;
        public String identityNumber;
        public String initial;
        public String surNameOrCompanyName;
    }

    /**
     * @description sms request data transformation object
     */
    public class DTO_SmsOtp {
        public Boolean enabled;
        public String mobileNumber;
    }

    /**
     * @description document property data transformation object
     */
    public class DTO_DocumentPropertyBo {
        public DTO_CustomerProperty customerProperty;
        public DTO_TaxonomyProperty taxonomyProperty;
    }

    /**
     * @description dimension request data transformation object
     */
    public class DTO_Dimension {
        public Integer width;
        public Integer height;
        public Integer x;
        public Integer y;
    }

    /**
     * @description taxonomy request data transformation object
     */
    public class DTO_TaxonomyProperty {
        public String documentType;
    }

    /**
     * @description workflow request data transformation object
     */
    public class DTO_AddSignerToWorkflowRequest {
        public List<DTO_SignerToWorkFlows> signerToWorkFlows;
    }

    /**
     * @description authentication request data transformation object
     */
    public class DTO_Authentication {
        public DTO_SmsOtp smsOtp;
        public Boolean enabled;
    }

    /**
     * @description signer request data transformation object
     */
    public class DTO_SignerToWorkFlows {
        public String userEmail;
        public String username;
        public String role;
        public String emailNotification;
        public Integer signingOrder;
    }

    /**
     * @description documentrequest data transformation object
     */
    public class DTO_UploadDocumentRequests {
        public String fileName;
        public String convertDocument;
        public String source;
        public String contentStreams;
        public String templateId;
        public List<DTO_AddOrAssignFieldRequests> addOrAssignFieldRequests;
        public Boolean storeContext;
        public DTO_DocumentPropertyBo documentPropertyBo;
    }

    /**
     * @description field request data transformation object
     */
    public class DTO_AddOrAssignFieldRequests {
        public String fieldMethod;
        public String validationRule;
        public Integer order;
        public Integer pageNo;
		public String value;
        public DTO_Dimension dimension;
        public DTO_Authentication authentication;
        public String placeholder;

        public String fieldType;
        public String type;
        public Double maxLength;
        public DTO_Font font;

    }

    /**
     * @description font data transformation object
     */
    public class DTO_Font {
        public Double embedded_size;
        public Double size;
        public String name;

    }
}