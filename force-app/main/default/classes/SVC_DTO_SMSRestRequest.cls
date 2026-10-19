/**
 * @description       : DTO class for SMS rest request
 * @User Story        : SFP-35988
 * @author            : Aliaksei Koval
 * @last modified on  : 06-20-2025
 * @last modified by  : Aliaksei Koval
**/
public with sharing class SVC_DTO_SMSRestRequest {
    public String externalReference;
    public String consumerId;
    public List<Message> messages;

    public class Message {
        public String messageBody;
        public String externalReferenceId;
        public List<Recipient> recipients;
        public MessagingProvider messagingProvider;
    }

    public class Recipient {
        public List<String> phoneNumbers;
        public String recipientName;
    }

    public class MessagingProvider {
        public String providerId;
    }
}