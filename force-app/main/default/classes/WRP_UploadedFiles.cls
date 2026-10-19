/**
 * @description       : Wrapper for passing values
 * @author            : Nagendra Mylavarapu
 * @group             : SBG Insurance
 * @last modified on  : 06-10-2024
 * @last modified by  : Dhiraj Prajapati (CloudSmiths)
**/

public with sharing class WRP_UploadedFiles {

   public WRP_UploadedFiles() {}

   public class DocumentIdentification {
        @InvocableVariable(label = 'Document Identification Type')
        public String DocumentIdentificationType;
        @InvocableVariable(label = 'Document Identification Value')
        public String DocumentIdentificationValue;
    }

    public class DocumentDetails {
        @InvocableVariable(label = 'ID')
        public String id;
        @InvocableVariable(label = 'Name')
        public String name;
        @InvocableVariable(label = 'MIME Type')
        public String mimeType;
        @InvocableVariable(label = 'Content Version ID')
        public String contentVersionId;
        @InvocableVariable(label = 'Read-Only')
        public Boolean readOnly;
        @InvocableVariable(label = 'Related Record ID')
        public String relatedRecordId;
        @InvocableVariable(label = 'Country')
        public String country;
        @InvocableVariable(label = 'Document Type')
        public String documentType;
        @InvocableVariable(label = 'Document Identification')
        public List<DocumentIdentification> documentIdentification;
    }
}