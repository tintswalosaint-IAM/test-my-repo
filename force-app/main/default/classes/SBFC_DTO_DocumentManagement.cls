/**
 * @description       : SFP-54443 - Controller class for Document Specific logic
 * @author            : Amlendu Bajpai
 * @group             : 
get  * @last modified on  : 04-18-2026
 * @last modified by  : Amlendu Bajpai
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   03-14-2026   Amlendu Bajpai   Initial Version
**/
public with sharing class SBFC_DTO_DocumentManagement {


    /**
    * @description application document wrapper class
    */
    public class DTO_ApplicationDocument {
        /**
         * @description applicationDocumentId
         */
        @AuraEnabled
        public String applicationDocumentId;
        /**
         * @description fileNetId
         */
        @AuraEnabled
        public String fileNetId;
        /**
         * @description sbGuid
         */
        @AuraEnabled
        public String sbGuid;
        /**
         * @description documentLabel
         */
        @AuraEnabled
        public String documentLabel;
        /**
         * @description documentStatus
         */
        @AuraEnabled
        public String documentStatus;
        /**
         * @description documentType
         */
        @AuraEnabled
        public String documentType;
        /**
         * @description partyName
         */
        @AuraEnabled
        public String partyName;
        /**
         * @description partyGuid
         */
        @AuraEnabled
        public String partyGuid;
        /**
         * @description partyBpId
         */
        @AuraEnabled
        /**
         * @description partyBpId
         */
        public String partyBpId;
        /**
         * @description partyIdentityNumber
         */
        @AuraEnabled
        public String partyIdentityNumber;
        /**
         * @description contentStream
         */
        @AuraEnabled
        public String contentStream;
        /**
         * @description mandatoryFileNotes
         */
        @AuraEnabled 
        public String mandatoryFileNotes;
        /**
         * @description SignHubDocumentId
         */
        @AuraEnabled 
        public String signHubDocumentId;

        
        /**
        * @description constructor
        * @author Amlendu Bajpai | 06-22-2026 
        **/
        public DTO_ApplicationDocument() { }
        
    }

}