/**
 * @description : Wrapper class to hold payload for Document Repository
 * @author : Jaco de Lange
 * @last modified on : 11-11-2024
**/
public class INS_UTIL_DocumentRequest {

    @AuraEnabled public INS_UTIL_DocumentInfo info;

    public INS_UTIL_DocumentRequest() {
        this.info = new INS_UTIL_DocumentInfo();
        this.info.DocumentIdentification = new List<DocumentIdentification>();
    }

    public class INS_UTIL_DocumentInfo {
        public String DocumentName{get;set;}
        public String DocumentType{get;set;}
        public String DocumentStream{get;set;}
        public List<DocumentIdentification> DocumentIdentification{get;set;}

        public INS_UTIL_DocumentInfo() {
            this.DocumentIdentification = new List<DocumentIdentification>();
        }

        public INS_UTIL_DocumentInfo setName(String name) {
            this.DocumentName = name;
            return this;
        }

        public INS_UTIL_DocumentInfo setType(String documentType) {
            this.DocumentType = documentType;
            return this;
        }

        public INS_UTIL_DocumentInfo setStream(String documentStream) {
            this.DocumentStream = documentStream;
            return this;
        }

        public INS_UTIL_DocumentInfo addIdentification(DocumentIdentification documentIdentification) {
            this.DocumentIdentification.add(documentIdentification);
            return this;
        }
    }

    public class DocumentIdentification {
        public String DocumentIdentificationType;
        public String DocumentIdentificationValue;

        public DocumentIdentification(String idType, String idValue) {
            this.DocumentIdentificationType = idType;
            this.DocumentIdentificationValue = idValue;
        }
    }

    public INS_UTIL_DocumentRequest setDocumentInfo(INS_UTIL_File file, blob fileData) {
       this.info.setName(file.name);
       this.info.setType(file.mimeType);
       this.info.setStream(EncodingUtil.base64Encode(fileData));
       return this;
    }

    public INS_UTIL_DocumentRequest setDocumentIdentification(INS_UTIL_Taxonomy taxonomy) {
        this.info.addIdentification(new DocumentIdentification('ENTY_TYPE', taxonomy.entityType));
        this.info.addIdentification(new DocumentIdentification('BPID', taxonomy.bpId));
        this.info.addIdentification(new DocumentIdentification('DocumentTitle', taxonomy.name));
        this.info.addIdentification(new DocumentIdentification('DocumentType', taxonomy.documentTypeId));
        return this;
    }

    public INS_UTIL_DocumentRequest setDocumentIdentification(String idType, String idValue) {
        this.info.addIdentification(new DocumentIdentification(idType, idValue));
        return this;
    }

    public String serializeDocument(INS_UTIL_DocumentInfo info) {
        return JSON.serialize(info);
    }
}