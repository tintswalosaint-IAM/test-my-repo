/***************************************************************************************
@Name of the Class :KYC_DTO_InboundDocumentUplod
@Description : SFP-38773 The REST Web Service DTO with Wrappers to update document
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date oct 08 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public with sharing class KYC_DTO_InboundDocumentUplod {

    /**
     * @description class to format API Request structure
     */
    public class KYC_WRP_DocReq {
        public String base64Attachment;
        public String title;

    }
    
    public class KYC_WRP_Req {
        public String uniqueIdentifier;
        public List<KYC_WRP_DocReq> documentList;
        public String identityNumber;
        public Boolean livenessFRMatch;
        public Double livenessFRScore;
        public List<String> errorFields;
        private Map<String, Object> toMap() {
           return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(this));
        }
        public Boolean hasNullField() {
            Boolean isNotValid = false;
            errorFields = new List<String>();
            for (String curr : this.toMap().keySet()) {
                if(curr!='identityNumber'){
                    if (this.toMap().get(curr) == null) {
                        isNotValid = true;
                        errorFields.add(curr + ' is null');
                    } else if(String.valueOf(this.toMap().get(curr)) ==''){
                        isNotValid = true;
                        errorFields.add(curr + ' is empty');
                    }                    
                }
            }
            return isNotValid;
        }
    }

    public class KYC_WRP_DocRes{
        public Integer responseCode;
        public String status;
        public String message;
    }

}