/**
 * @description SFP-5420 - Controller for Chatbot requests
 *
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 * 
 * @lastModifiedBy Raymond Magezi (magezir2@stanbic.com)
 *
 * @date Sep 24th 2021
 * 
 * @lastModifiedDate July 07th 2025
 */
public with sharing class SVC_ChatBotHandler {
    
    /**
     * @description Private constructor to prevent instantiation
     */
    private SVC_ChatBotHandler() {}
    
    private static final String CHATBOT_ORIGIN = 'Chatbot';
    private static final String WHATSAPP_ORIGIN = 'WhatsApp';
    private static final String DEFAULT_PRIORITY = 'High';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_ChatBotHandler');
    private static final String QUEUE_CCC_UGANDA = 'UG_CCC_live_chat_cases';
    private static final String QUEUE_WHATSAPP = 'UG_CCC_Whatsapp_case';
    private static final String QUEUE_CCC_LS = 'LS_CCC_Chat';
    private static final String QUEUE_CCC_LS_Whatsapp = 'SVC_LS_CCC';
    private static final String QUEUE_Prestige_LS = 'SVC_LS_Prestige_Banking';
    private static final String QUEUE_TZ_VOICE_BRANCH_INBOUND = 'SVC_TZ_Voice_Branch_Inbound';
    private static final String SUBJECT_WHATSAPP_QUERY = 'WhatsApp service request';
    private static final String SUBJECT_WHATSAPP_AGENT = 'Transfer from WhatsApp';
    private static final String DESCRIPTION_WHATSAPP_AGENT = 'The case was created through a WhatsApp.';

    /**
     * @description Wrapper class with input params to the createCase method
     */
    public class ChatBotTempInput {
        @InvocableVariable(required=true)
        public String queueApiName;

        @InvocableVariable(required=true)
        public String caseSubject;

        @InvocableVariable(required=true)
        public String caseDescription;

        @InvocableVariable(required=true)
        public Id routableId;

        @InvocableVariable(required=false)
        public String branch;

        @InvocableVariable(required=false)
        public String userEmail;

        @InvocableVariable(required=false)
        public String userName;
        /**Lesotho**/
        @InvocableVariable(required=false)
        public String Email;

        /**Lesotho**/
        @InvocableVariable(required=false)
        public String fullname;

    }

    /**
     * @description Wrapper class with output result from the createCase method
     */
    public class ChatBotTempOutput {
        @InvocableVariable(required=false)
        public String caseNumber;

        @InvocableVariable(required=false)
        public String errorMessage;
    }

    /**
     * @description Create a case on chatbot request
     * @param input Input params that come from a chatbot
     * @return On success - Case Number, on failure - error message
     */
    @InvocableMethod(Label ='Create Case' description='Allows to create a case')
    public static List<ChatBotTempOutput> createCase(List<ChatBotTempInput> input) {
        LOGGER.warn('Case creation initiated via ChatBot');
        ChatBotTempOutput result = new ChatBotTempOutput();
        try {
            LOGGER.warn('Processing ' + input.size() + ' case creation requests');
            CaseProcessingData data = prepareInputData(input);
            List<Case> cases = processCaseCreation(data);
            if (!Schema.sObjectType.Case.isCreateable()) {
                LOGGER.error('Insufficient permissions to create Case records');
                throw new AuraHandledException('You do not have permission to create Case records.');
            }
            LOGGER.warn('Inserting ' + cases.size() + ' cases');
            insert cases;
            updateRelatedRecords(data, cases);
            handleSurveyAndResult(data.inputQueueApiNames, cases, result);
            LOGGER.warn('Case creation completed successfully. Case Number: ' + result.caseNumber);
        } catch (Exception ex) {
            LOGGER.error('Error in case creation: ' + ex.getMessage(), ex);
            result.errorMessage = ex.getMessage();
        }
        return new List<ChatBotTempOutput>{result};
    }
    
    private class CaseProcessingData {
        public List<Id> chatRoutableIds;
        public List<Id> messageRoutableIds;
        public List<String> inputQueueApiNames;
        public Map<String, Id> queueIdByDevName;
        public Map<Id, LiveChatTranscript> transcriptById;
        public Map<Id, MessagingSession> messageById;
        public List<ChatBotTempInput> input;
    }
    
    private static CaseProcessingData prepareInputData(List<ChatBotTempInput> input) {
        CaseProcessingData data = new CaseProcessingData();
        data.chatRoutableIds = new List<Id>();
        data.messageRoutableIds = new List<Id>();
        data.inputQueueApiNames = new List<String>();
        data.input = input;
        data.transcriptById = new Map<Id, LiveChatTranscript>();
        data.messageById = new Map<Id, MessagingSession>();
        
        List<String> queueApiNames = new List<String>{QUEUE_WHATSAPP,QUEUE_Prestige_LS,QUEUE_CCC_LS_Whatsapp,QUEUE_CCC_LS};
        
        for (ChatBotTempInput chatBotInput : input) {
            categorizeInput(chatBotInput, data, queueApiNames);
        }
        
        data.queueIdByDevName = getQueueMapping(queueApiNames);
        return data;
    }
    
    private static void categorizeInput(ChatBotTempInput chatBotInput, CaseProcessingData data, List<String> queueApiNames) {
        if (chatBotInput.routableId.getSobjectType() == Schema.LiveChatTranscript.SObjectType) {
            data.chatRoutableIds.add(chatBotInput.routableId);
        } else if (chatBotInput.routableId.getSobjectType() == Schema.MessagingSession.SObjectType) {
            data.messageRoutableIds.add(chatBotInput.routableId);
        }
        
        if (!String.isEmpty(chatBotInput.queueApiName)) {
            queueApiNames.add(chatBotInput.queueApiName);
            data.inputQueueApiNames.add(chatBotInput.queueApiName);
        }
    }
    
    private static Map<String, Id> getQueueMapping(List<String> queueApiNames) {
        Map<String, Id> queueIdByDevName = new Map<String, Id>();
        for (Group item : [
                SELECT Id, DeveloperName
                FROM Group
                WHERE Type = 'Queue'
                    AND DeveloperName IN :queueApiNames
                WITH USER_MODE
            ]) {
                queueIdByDevName.put(item.DeveloperName, item.Id);
        }
        return queueIdByDevName;
    }
    
    private static List<Case> processCaseCreation(CaseProcessingData data) {
        List<Case> cases = new List<Case>();
        
        if (data.chatRoutableIds.isEmpty()) {
            // Process messaging sessions
            if (!data.messageRoutableIds.isEmpty()) {
                data.messageById = new Map<Id, MessagingSession>([
                    SELECT Id, CaseId, MessagingEndUser.Name,ChannelName
                    FROM MessagingSession
                    WHERE Id IN :data.messageRoutableIds
                    WITH USER_MODE
                ]);
                cases.addAll(generateWhatsappCases(data.messageById, data.input, data.queueIdByDevName));
            }
        } else {
            // Process chat transcripts
            data.transcriptById = new Map<Id, LiveChatTranscript>([
                SELECT Id, CaseId, SVC_FirstName__c, SVC_LastName__c, SVC_Phone__c, SVC_Email__c
                FROM LiveChatTranscript
                WHERE Id IN :data.chatRoutableIds
                WITH USER_MODE
            ]);
            cases.addAll(generateChatbotCases(data.transcriptById, data.input, data.queueIdByDevName));
        }
        
        return cases;
    }
    
    private static void updateRelatedRecords(CaseProcessingData data, List<Case> cases) {
        Integer index = 0;
        for (LiveChatTranscript transcript : data.transcriptById.values()) {
            transcript.CaseId = cases[index].Id;
            index++;
        }
        update data.transcriptById.values();
        
        for (MessagingSession message : data.messageById.values()) {
            message.CaseId = cases[index].Id;
            index++;
        }
        update data.messageById.values();
    }
    
    private static void handleSurveyAndResult(List<String> inputQueueApiNames, List<Case> cases, ChatBotTempOutput result) {
        Case caseRec = [Select Id, SVC_SurveyURL__c, OwnerId, CaseNumber FROM Case WHERE Id IN :cases WITH USER_MODE LIMIT 1];
        
        if (caseRec != null && isLesothoQueue(inputQueueApiNames)) {
            createSurveyInvitation(caseRec);
        }
        
        result.caseNumber = caseRec.CaseNumber;
    }
    
    private static Boolean isLesothoQueue(List<String> inputQueueApiNames) {
        return inputQueueApiNames.contains('LS_CCC_Chat') ||
               inputQueueApiNames.contains('LS_CCC_Live_Chat_Cases') ||
               inputQueueApiNames.contains('LS_CCC_LiveChat');
    }

    /**
     * @description Prepare and insert case for chatbot
     * @param transcriptById Chat transcript for chatbot
     * @param input Input params that come from a chatbot
     * @param queueIdByDevName queue from chatbot
     * @return case record
     */
    private static List<Case> generateChatbotCases(Map<Id, LiveChatTranscript> transcriptById, List<ChatBotTempInput> input, Map<String, Id> queueIdByDevName) {
        LOGGER.warn('Generating chatbot cases for ' + input.size() + ' inputs');
        List<Case> cases = new List<Case>();
        for (ChatBotTempInput chatBotInput : input) {
            if (!transcriptById.containsKey(chatBotInput.routableId)) {
                LOGGER.warn('Transcript not found for routable ID: ' + chatBotInput.routableId);
                continue;
            }
            String description = 'First Name: ' + transcriptById.get(chatBotInput.routableId)?.SVC_FirstName__c
                + '\nLast Name: ' + transcriptById.get(chatBotInput.routableId)?.SVC_LastName__c
                + '\nEmail: ' + chatBotInput.Email
                + '\nPhone: ' + transcriptById.get(chatBotInput.routableId)?.SVC_Phone__c
                + '\nDescription: ' + chatBotInput.caseDescription;

            cases.add(
                new Case (
                    OwnerId = queueIdByDevName.containsKey(chatBotInput.queueApiName) ? queueIdByDevName.get(chatBotInput.queueApiName) : null,
                    Subject = chatBotInput.caseSubject,
                    Description = description,
                    Priority = DEFAULT_PRIORITY,
                    Origin = CHATBOT_ORIGIN,
                    SuppliedEmail = chatBotInput.Email,/**Lesotho**/
                    SuppliedName = chatBotInput.fullname,/**Lesotho**/
                    SVC_Branch__c = chatBotInput.branch
                )
            );
        }
        return cases;
    }

    /**
     * @description Prepare and insert case for whatsapp
     * @param messageById messaging session for whatsapp
     * @param input Input params that come from a whatsapp
     * @param queueIdByDevName queue from chatbot
     * @return case record
     */
    private static List<Case> generateWhatsappCases(Map<Id, MessagingSession> messageById, List<ChatBotTempInput> input, Map<String, Id> queueIdByDevName) {
        LOGGER.warn('Generating WhatsApp cases for ' + input.size() + ' inputs');
        List<Case> cases = new List<Case>();
        for (ChatBotTempInput chatBotInput : input) {
            if (!messageById.containsKey(chatBotInput.routableId)) {
                LOGGER.warn('Messaging session not found for routable ID: ' + chatBotInput.routableId);
                continue;
            }
            
            String description = buildWhatsappDescription(chatBotInput, messageById);
            processWhatsappQueueAssignment(chatBotInput, messageById);
            description += getWhatsappDescriptionSuffix(chatBotInput);
            
            cases.add(createWhatsappCase(chatBotInput, description, queueIdByDevName));
        }
        return cases;
    }
    
    private static String buildWhatsappDescription(ChatBotTempInput chatBotInput, Map<Id, MessagingSession> messageById) {
        return 'Name: ' + chatBotInput.userName
            + '\nEmail: ' + chatBotInput.userEmail
            + '\nPhone: ' + messageById.get(chatBotInput.routableId)?.MessagingEndUser.Name.replace('whatsapp:', '')
            + '\nPlease review the related MessagingSession record:'
            + '\n' + URL.getOrgDomainUrl().toExternalForm() + '/' + chatBotInput.routableId;
        }
    
    private static void processWhatsappQueueAssignment(ChatBotTempInput chatBotInput, Map<Id, MessagingSession> messageById) {
        if (chatBotInput.queueApiName == QUEUE_CCC_UGANDA) {
            processUgandaQueueAssignment(chatBotInput);
        } else if (chatBotInput.queueApiName == QUEUE_CCC_LS) {
            processLesothoQueueAssignment(chatBotInput, messageById);
        }
    }
    
    private static void processUgandaQueueAssignment(ChatBotTempInput chatBotInput) {
        chatBotInput.queueApiName = QUEUE_WHATSAPP;
        chatBotInput.caseSubject = String.isBlank(chatBotInput.branch) ? SUBJECT_WHATSAPP_AGENT : SUBJECT_WHATSAPP_QUERY;
    }
    
    private static void processLesothoQueueAssignment(ChatBotTempInput chatBotInput, Map<Id, MessagingSession> messageById) {
        String channelName = messageById.get(chatBotInput.routableId).ChannelName;
        
        if (chatBotInput.branch == 'chat') {
            chatBotInput.caseSubject = SUBJECT_WHATSAPP_AGENT;
            assignLesothoQueue(chatBotInput, channelName);
        } else if (chatBotInput.branch == 'Query') {
            chatBotInput.caseSubject = SUBJECT_WHATSAPP_QUERY;
            assignLesothoQueue(chatBotInput, channelName);
        }
    }
    
    private static void assignLesothoQueue(ChatBotTempInput chatBotInput, String channelName) {
        if (channelName == Label.SVC_LSCCCWhatsappNumber) {
            chatBotInput.queueApiName = QUEUE_CCC_LS_Whatsapp;
        } else if (channelName == Label.SVC_PrestigeQueueWhatsappNumber) {
            chatBotInput.queueApiName = QUEUE_Prestige_LS;
        }
    }
    
    private static String getWhatsappDescriptionSuffix(ChatBotTempInput chatBotInput) {
        if (chatBotInput.caseSubject == SUBJECT_WHATSAPP_AGENT) {
            return '\nDescription: ' + DESCRIPTION_WHATSAPP_AGENT;
        }
        return '\nDescription: ' + chatBotInput.caseDescription;
    }
    
    private static Case createWhatsappCase(ChatBotTempInput chatBotInput, String description, Map<String, Id> queueIdByDevName) {
        return new Case(
            OwnerId = queueIdByDevName.containsKey(chatBotInput.queueApiName) ? queueIdByDevName.get(chatBotInput.queueApiName) : null,
            Subject = chatBotInput.caseSubject,
            Description = description,
            Priority = DEFAULT_PRIORITY,
            Origin = WHATSAPP_ORIGIN,
            SuppliedEmail = (chatBotInput.queueApiName == QUEUE_TZ_VOICE_BRANCH_INBOUND) ? chatBotInput.Email : '',
            SVC_Branch__c = chatBotInput.branch
        );
    }

    /**
     * @description Prepare Survey invitation for case
     * @param caseRec case record created for bot
     */
    private static void createSurveyInvitation(Case caseRec){
		Survey surveyRec = [select Id, Name from Survey where Name = 'Lesotho Customer Feedback' WITH USER_MODE LIMIT 1];
		Network networdRec = [select id, Name from Network where name = 'Customer Survey' WITH USER_MODE LIMIT 1];
		SurveyInvitation surveyInviteRec = new SurveyInvitation ();
		surveyInviteRec.Name = 'Customer Survey';
		surveyInviteRec.OptionsAllowGuestUserResponse = true;
		surveyInviteRec.SVC_Case__c = caseRec.Id;
		surveyInviteRec.SurveyId = surveyRec.Id;
		surveyInviteRec.CommunityId = networdRec.Id;
		if (!Schema.sObjectType.SurveyInvitation.isCreateable()) {
			throw new AuraHandledException('You do not have permission to create SurveyInvitation records.');
		}
		insert surveyInviteRec;
        caseRec.SVC_SurveyURL__c = [select Id, InvitationLink from SurveyInvitation where Id =: surveyInviteRec.Id WITH USER_MODE LIMIT 1].InvitationLink;
        if (!Schema.sObjectType.Case.isUpdateable()) {
			throw new AuraHandledException('You do not have permission to update Case records.');
		}
        update caseRec;
   }

}