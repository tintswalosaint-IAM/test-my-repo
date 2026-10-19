/**
 * @description       : DTO Class for SMS rest response
 * @User Story        : SFP-35988
 * @author            : Aliaksei Koval
 * @last modified on  : 06-20-2025
 * @last modified by  : Aliaksei Koval
**/
@SuppressWarnings('sf:TooManyFields') //We can not control the number of fields in a DTO
public with sharing class SVC_DTO_SMSRestResponse {
    public String requestId;
    public String externalReference;
    public String requestStatus;
    public List<Message> messages;
    
    @SuppressWarnings('sf:VariableDeclarationHidesAnother') //We can not control field names in a DTO
    public class Message {
        public List<Recipient> recipients;
        public String subject;
        public String messageBody;
        public List<String> attachments;
        public String messageId;
        public List<String> messageFields;
        public String messageTemplateId;
        public String requestStatus;
        public String storedMessage;
        public String messageStore;
        public String storeMessage;
        public String externalReferenceId;
        public String completeTime;
        public String queueTime;
        public Sender sender;
        public MessagingProvider messagingProvider;
    }

    public class Recipient {
        public String recipientName;
        public String recipientId;
        public List<String> emailAdresses;
        public List<String> phoneNumbers;
        public List<String> properties;
    }

    public class Sender {
        public String senderName;
        public String senderId;
        public String emailAdress;
        public String signature;
        public List<String> properties;
    }

    public class MessagingProvider {
        public String providerId;
        public String providerDescription;
        public String componentName;
        public List<String> providerProperties;
        public String consumerId;
    }
}