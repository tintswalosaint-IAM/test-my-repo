/**
 * @description SFP-5420 - Methods for the LWC svcContactLookup component
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 *
 * @date Sep 7th 2021
 */
public with sharing class SVC_ContactLookup {
    
    /**
     * @description Get contacts related to the Case or LiveChatTranscript objects
     * @param recordId Id of the Case OR LiveChatTranscript record
     * @return Wrapper class with list of contacts in the result property
     */
    @AuraEnabled(cacheable=true)
    public static DataResponse getContacts(Id recordId) {
        DataResponse result;
        String contactId;
        List<Contact> contacts = new List<Contact>();
        List<DataContact> matchedContacts = new List<DataContact>();
        try {
            List<LiveChatTranscript> records = [
                SELECT Id, ContactId, CaseId, SVC_FirstName__c, SVC_LastName__c, SVC_Phone__c, SVC_Email__c 
                FROM LiveChatTranscript 
                WHERE Id = :recordId
                    OR CaseId = :recordId
            ];
            if (recordId.getSobjectType() == Case.SObjectType) {
                contactId = [SELECT Id, ContactId FROM Case WHERE Id = :recordId].ContactId;
            }
            if (!records.isEmpty()) {
                if (String.isNotBlank(records[0].SVC_LastName__c)) {
                    List<List<SObject>> searchList = [
                        FIND :records[0].SVC_LastName__c IN ALL FIELDS 
                        RETURNING Contact(Id, Name, Email, Phone) LIMIT 20
                    ];
                    for (List<Contact> arr : searchList) {
                        contacts = arr;
                    }
                }
                matchedContacts.add(
                    new DataContact(records[0])
                );
            } else if (contactId != null) {
                contacts = [
                    SELECT Id, Name, Email, Phone 
                    FROM Contact
                    WHERE Id = :contactId
                ];
            }
            
            for (Contact item : contacts) {
                matchedContacts.add(
                    new DataContact(
                        item, 
                        item.Id == (recordId.getSobjectType() == Case.SObjectType ? contactId : records[0].ContactId)
                    )
                );
            }
            //add prepopulated new contact that should be hidden on UI
            result = new DataResponse(matchedContacts);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Get contacts matching the search string
     * @param search matching string
     * @return Wrapper class with list of contacts in the result property
     */
    @AuraEnabled(cacheable=true)
    public static DataResponse findContacts(String search) {
        DataResponse result;
        try {
            List<List<SObject>> searchList = [
                FIND :search IN ALL FIELDS 
                RETURNING Contact(Id, Name, Email, Phone) LIMIT 20
            ];
            List<DataContact> matchedContacts = new List<DataContact>();
            for (List<Contact> arr : searchList) {
                for (Contact item : arr) {
                    matchedContacts.add(
                        new DataContact(item, false)
                    );
                }
            }
            result = new DataResponse(matchedContacts);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Set specific value in the field ContactId for the Case or LiveChatTranscript object
     * @param recordId Id of the Case OR LiveChatTranscript record
     * @param contactId Id of the Contact OR null
     * @return Wrapper class with response
     */
    @AuraEnabled(cacheable=false)
    public static DataResponse updateContact(Id recordId, Id contactId) {
        DataResponse result;
        try {
            List<LiveChatTranscript> records = [
                SELECT Id, ContactId, CaseId 
                FROM LiveChatTranscript 
                WHERE Id = :recordId
                    OR CaseId = :recordId
            ];
            if (!records.isEmpty()) {
                records[0].ContactId = contactId;
                update records[0];
            }
            if (recordId.getSobjectType() == Case.SObjectType) {
                update new Case(
                    Id = recordId,
                    ContactId = contactId
                );
            } else if (records[0].CaseId != null) {
                update new Case(
                    Id = records[0].CaseId,
                    ContactId = contactId
                );
            }
            result = new DataResponse(true);
        } catch (Exception ex) {
            result = new DataResponse(ex);
        }
        return result;
    }

    /**
     * @description Wrapper class with response to LWC component 
     */
    public class DataResponse {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String stack;
        @AuraEnabled
        public String result;

        /**
         * @description Wrapper constructor
         * @param ex exception record
         */
        public DataResponse(Exception ex) {
            this.isSuccess = false;
            this.message = ex.getMessage();
            this.stack = ex.getStackTraceString();
        }

        /**
         * @description Wrapper constructor
         * @param result output object
         */
        public DataResponse(Object result) {
            this.isSuccess = true;
            this.result = JSON.serialize(result);
        }
    }

    /**
     * @description Wrapper class with Contact data
     */
    public class DataContact {
        public String id;
        public String name;
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public Boolean selected;
        public Boolean isHidden;
        
        /**
         * @description Wrapper constructor
         * @param record input contact
         * @param selected is this contact will selected on UI
         */
        public DataContact(Contact record, Boolean selected) {
            this.id = record.Id;
            this.name = record.Name;
            this.email = record.Email == null ? 'Email' : record.Email;
            this.phone = record.Phone == null ? 'Phone' : record.Phone;
            this.selected = selected;
        }

        /**
         * @description Wrapper constructor
         * @param transcript based on this record, generates a contact
         */
        public DataContact(LiveChatTranscript transcript) {
            this.firstName = transcript.SVC_FirstName__c;
            this.lastName = transcript.SVC_LastName__c;
            this.email = transcript.SVC_Email__c;
            this.phone = transcript.SVC_Phone__c;
            this.isHidden = true;
        }
    }

}