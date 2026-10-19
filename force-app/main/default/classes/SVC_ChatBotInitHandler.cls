/**
 * @description Handles initialization of chatbot sessions with support for WhatsApp and LiveChat
 * 
 * @changes Added private constructor to prevent instantiation and address UseSingleton code smell
 * @changes Added WITH SECURITY_ENFORCED to all SOQL queries to enforce Field Level Security
 * @changes Implemented SessionProcessor pattern for better separation of concerns
 * @changes Added comprehensive input validation and error handling
 * @changes Added utility methods for phone number and email validation
 * @changes Added test seam for MessagingSession to support unit testing
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 * 
 * @lastModifiedBy Raymond Magezi (magezir2@stanbic.com)
 *
 * @date Oct 14th 2021
 * 
 * @lastModifiedDate July 08th 2025
 */
public with sharing class SVC_ChatBotInitHandler {
    // Test seam for bypassing MessagingSession queries in tests
    @TestVisible
    private static MessagingSession testMessagingSession;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_ChatBotInitHandler');
    
    // Private constructor to prevent instantiation
    private SVC_ChatBotInitHandler() {}

    // Top-level constants (public for access, static final for immutability)
    public static final String WHATSAPP_IMAGE_PLACEHOLDER = '*Please see the image below:* \n';
    public static final String LIVECHAT_IMAGE_PLACEHOLDER = 'IMAGELINK:';
    public static final String WHATSAPP_BOLD_TAGS = '*';
    public static final String HTML_BOLD_TAGS = '<b>';
    public static final String WHATSAPP_CHANNEL = 'WhatsApp';
    public static final String LIVECHAT_CHANNEL = 'LiveChat';
    public static final String DEFAULT_ERROR = 'System error occurred';

    // Input/Output classes
    public class ChatBotInput {
        @InvocableVariable(required=true) public Id routableId;
    }

    public class ChatBotOutput {
        @InvocableVariable(required=true) public String imageLinkPlaceholder;
        @InvocableVariable(required=true) public String startBoldTag;
        @InvocableVariable(required=true) public String endBoldTag;
        @InvocableVariable(required=true) public Boolean isWhatsAppChannel;
        @InvocableVariable(required=false) public String name;
        @InvocableVariable(required=false) public String firstName;
        @InvocableVariable(required=false) public String lastName;
        @InvocableVariable(required=false) public String email;
        @InvocableVariable(required=false) public String userEmail;
        @InvocableVariable(required=false) public String phone;
        @InvocableVariable(required=false) public String errorMessage;
        @InvocableVariable(required=false) public String channelType;
    }

    /**
     * @description Initialize chatbot with custom variables based on routable object type
     * @param inputs List of ChatBotInput containing routable IDs for LiveChat or WhatsApp sessions
     * @return List of ChatBotOutput with initialized chatbot variables and channel-specific settings
     */
    @InvocableMethod(Label='Init Chatbot' description='Initialize chatbot with custom variables')
    public static List<ChatBotOutput> init(List<ChatBotInput> inputs) {
        LOGGER.warn('Chatbot initialization started');
        if (inputs == null || inputs.isEmpty()) {
            LOGGER.warn('No input parameters provided');
            return createErrorResponse('No input parameters provided');
        }

        try {
            return new SessionProcessor().process(inputs);
        } catch (SecurityException ex) {
            LOGGER.error('Security exception during initialization: ' + ex.getMessage(), ex);
            return createErrorResponse('Insufficient permissions: ' + ex.getMessage());
        } catch (IllegalArgumentException ex) {
            LOGGER.error('Invalid argument during initialization: ' + ex.getMessage(), ex);
            return createErrorResponse('Invalid input: ' + ex.getMessage());
        } catch (Exception ex) {
            LOGGER.error('Unexpected error during initialization: ' + ex.getMessage(), ex);
            return createErrorResponse(DEFAULT_ERROR + ': ' + formatExceptionMessage(ex));
        }
    }

    /**
     * @description Inner class responsible for processing chatbot session inputs and generating appropriate outputs
     */
    private class SessionProcessor {
        private ChatBotOutput result;
        private List<Id> messageRoutableIds;
        private List<Id> chatRoutableIds;

        /**
         * @description Process chatbot inputs and classify them by object type
         * @param inputs List of ChatBotInput to process
         * @return List of ChatBotOutput with processed results
         */
        public List<ChatBotOutput> process(List<ChatBotInput> inputs) {
            LOGGER.warn('Processing ' + inputs.size() + ' chatbot inputs');
            this.result = new ChatBotOutput();
            this.messageRoutableIds = new List<Id>();
            this.chatRoutableIds = new List<Id>();
            
            // Classify and validate inputs
            for (ChatBotInput input : inputs) {
                if (input.routableId == null) {
                    throw new IllegalArgumentException('Routable ID cannot be null');
                }
                Schema.SObjectType objectType = input.routableId.getSobjectType();
                if (objectType == LiveChatTranscript.SObjectType) {
                    setupChannelSettings(false);
                    chatRoutableIds.add(input.routableId);
                } else if (objectType == MessagingSession.SObjectType) {
                    setupChannelSettings(true);
                    messageRoutableIds.add(input.routableId);
                } else {
                    throw new IllegalArgumentException('Unsupported routable object type: ' + objectType);
                }
            }
            
            // Process sessions
            if (!messageRoutableIds.isEmpty()) {
                processWhatsApp();
            }
            if (!chatRoutableIds.isEmpty()) {
                processLiveChat();
            }
            
            return new List<ChatBotOutput>{result};
        }
        
        /**
         * @description Configure channel-specific settings for WhatsApp or LiveChat
         * @param isWhatsApp Boolean indicating if this is a WhatsApp channel
         */
        private void setupChannelSettings(Boolean isWhatsApp) {
            result.isWhatsAppChannel = isWhatsApp;
            if (isWhatsApp) {
                result.imageLinkPlaceholder = WHATSAPP_IMAGE_PLACEHOLDER;
                result.startBoldTag = WHATSAPP_BOLD_TAGS;
                result.endBoldTag = WHATSAPP_BOLD_TAGS;
                result.channelType = WHATSAPP_CHANNEL;
            } else {
                result.imageLinkPlaceholder = LIVECHAT_IMAGE_PLACEHOLDER;
                result.startBoldTag = HTML_BOLD_TAGS;
                result.endBoldTag = HTML_BOLD_TAGS;
                result.channelType = LIVECHAT_CHANNEL;
            }
        }
        
        /**
         * @description Process WhatsApp messaging sessions and extract contact information
         */
        private void processWhatsApp() {
            if (!Schema.sObjectType.MessagingSession.isAccessible() || !Schema.sObjectType.MessagingEndUser.isAccessible()) {
                throw new SecurityException('Insufficient access to MessagingSession or MessagingEndUser');
            }
            
            List<MessagingSession> sessions = Test.isRunningTest() && testMessagingSession != null ? 
                new List<MessagingSession>{testMessagingSession} : 
                [SELECT Id, MessagingEndUser.Name FROM MessagingSession WHERE Id IN :messageRoutableIds WITH SECURITY_ENFORCED LIMIT 1];
            
            if (sessions.isEmpty()) {
                LOGGER.warn('No WhatsApp session found for IDs: ' + messageRoutableIds);
                result.errorMessage = 'No WhatsApp session found';
                return;
            }
            
            String phoneNumber = extractPhoneNumber(sessions[0].MessagingEndUser.Name);
            if (isValidPhoneNumber(phoneNumber)) {
                result.phone = phoneNumber;
                Contact matchingContact = findContactByPhone(phoneNumber);
                if (matchingContact != null) {
                    setContactData(matchingContact);
                }
            } else {
                result.errorMessage = 'Invalid phone number format';
            }
        }
        
        /**
         * @description Process LiveChat transcripts and populate chatbot variables
         */
        private void processLiveChat() {
            if (!Schema.sObjectType.LiveChatTranscript.isAccessible() || !Schema.sObjectType.Contact.isAccessible()) {
                throw new SecurityException('Insufficient access to LiveChatTranscript or Contact');
            }
            
            List<LiveChatTranscript> transcripts = [
                SELECT Id, CaseId, SVC_FirstName__c, SVC_LastName__c, 
                       SVC_Phone__c, SVC_Email__c, Contact.Name, Contact.Email 
                FROM LiveChatTranscript 
                WHERE Id IN :chatRoutableIds
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            if (transcripts.isEmpty()) {
                LOGGER.warn('No LiveChat transcript found for IDs: ' + chatRoutableIds);
                result.errorMessage = 'No LiveChat transcript found';
                return;
            }
            
            LiveChatTranscript transcript = transcripts[0];
            result.firstName = transcript.SVC_FirstName__c;
            result.lastName = transcript.SVC_LastName__c;
            
            if (isValidPhoneNumber(transcript.SVC_Phone__c)) {
                result.phone = transcript.SVC_Phone__c;
            }
            
            if (isValidEmail(transcript.SVC_Email__c)) {
                result.userEmail = transcript.SVC_Email__c;
                result.email = result.userEmail;
            }
            
            if (transcript.Contact != null) {
                result.name = transcript.Contact.Name;
                if (String.isBlank(result.email) && isValidEmail(transcript.Contact.Email)) {
                    result.email = transcript.Contact.Email;
                    result.userEmail = transcript.Contact.Email;
                }
            }
        }
        
        /**
         * @description Populate chatbot output with contact information
         * @param contact Contact record to extract data from
         */
        @TestVisible
        private void setContactData(Contact contact) {
            result.name = contact.Name;
            result.firstName = contact.FirstName;
            result.lastName = contact.LastName;
            
            if (isValidEmail(contact.Email)) {
                result.email = contact.Email;
                result.userEmail = contact.Email;
            }
            
            if (isValidPhoneNumber(contact.Phone)) {
                result.phone = contact.Phone;
            }
        }
    }
    
    /**
     * @description Extract phone number from WhatsApp name format
     * @param whatsappName WhatsApp name containing phone number (e.g., 'whatsapp:+1234567890')
     * @return Cleaned phone number without WhatsApp prefix and plus sign
     */
    @TestVisible
    private static String extractPhoneNumber(String whatsappName) {
        return String.isBlank(whatsappName) ? '' : whatsappName.replace('whatsapp:', '').replace('+', '');
    }
    
    /**
     * @description Find Contact record by phone number
     * @param phoneNumber Phone number to search for
     * @return Contact record if found, null otherwise
     */
    @TestVisible
    private static Contact findContactByPhone(String phoneNumber) {
        if (String.isBlank(phoneNumber) || !Schema.sObjectType.Contact.isAccessible()) {
            return null;
        }
        
        try {
            List<Contact> contacts = [
                SELECT Id, Name, FirstName, LastName, Email, Phone
                FROM Contact
                WHERE Phone = :phoneNumber
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            return contacts.isEmpty() ? null : contacts[0];
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * @description Create standardized error response for chatbot initialization failures
     * @param errorMessage Error message to include in response
     * @return List containing single ChatBotOutput with error details
     */
    @TestVisible
    private static List<ChatBotOutput> createErrorResponse(String errorMessage) {
        ChatBotOutput errorResult = new ChatBotOutput();
        errorResult.errorMessage = errorMessage;
        errorResult.isWhatsAppChannel = false;
        errorResult.imageLinkPlaceholder = '';
        errorResult.startBoldTag = '';
        errorResult.endBoldTag = '';
        return new List<ChatBotOutput>{errorResult};
    }

    /**
     * @description Format exception message with additional context for debugging
     * @param ex Exception to format
     * @return Formatted error message with exception details and line number
     */
    public static String formatExceptionMessage(Exception ex) {
        return 'Initialization failed: ' + ex.getMessage() + ' at line ' + ex.getLineNumber();
    }

    /**
     * @description Validate phone number format and length
     * @param phone Phone number string to validate
     * @return True if phone number contains more than 5 digits, false otherwise
     */
    public static Boolean isValidPhoneNumber(String phone) {
        return !String.isBlank(phone) && phone.replaceAll('[^0-9]', '').length() > 5;
    }

    /**
     * @description Validate email address format using regex pattern
     * @param email Email address string to validate
     * @return True if email matches valid format, false otherwise
     */
    public static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        return Pattern.compile(emailRegex).matcher(email).matches();
    }
}