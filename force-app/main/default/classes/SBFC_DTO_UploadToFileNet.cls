/**
 * @description       : SFP-58317 - Data transformation class for request body of upload files 
 * @author            : Amlendu Bajpai
 * @group             : 
 * @last modified on  : 04-19-2026
 * @last modified by  : Amlendu Bajpai
**/
public with sharing class SBFC_DTO_UploadToFileNet {
   
    /*
    *@description UploadFiles transformation REQUEST
    */
    public class DTO_Request {
        public String sourceRequestId;
        public String channelId;
        public DTO_Documents documents;
    } 

    /*
    *@description UploadFiles transformation RESPONSE
    */
    public class DTO_Response {
        public String sourceRequestId;
        public String channelId;
        public DTO_Documents documents;
    }

    /*
    *@description Documents transformation object
    */
    public class DTO_Documents {
        public String contentStream;
        public DTO_CreateDocumentPropertyBo createDocumentPropertyBo;
        public String fileName;
        public String documentTitle;
        public String mimeType;

        public String status;
        public String statusDescription;
        public String sbGuide;
        public String fnGuide;
    }

    /*
    *@description CreateDocumentPropertyBo transformation object
    */
    public class DTO_CreateDocumentPropertyBo {
        public DTO_CustomerProperty customerProperty;
        public DTO_TaxonomyProperty taxonomyProperty;
    }

    /*
    *@description CustomerProperty transformation object
    */
    public class DTO_CustomerProperty {
        public String bpid;
        public String identityNumber;
        public String initial;
        public String surNameOrCompanyName;
    }

    /*
    *@description TaxonomyProperty transformation object
    */
    public class DTO_TaxonomyProperty {
        public Integer documentType;
    }

}