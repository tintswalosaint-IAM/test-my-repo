/**
* @description Invocable Apex action that posts the full chat transcript with timestamps
*              from a completed MessagingSession to the linked Case Feed.
*              Uses the Salesforce Connect REST API to fetch ConversationEntry data
*              since MIAW channels do not expose ConversationEntry via standard SOQL.
*              Designed to be called from a Record-Triggered Flow (async) when
*              MessagingSession.Status changes to 'Ended'.
*              Timezone is resolved dynamically from the running user's Salesforce settings
*              to support multi-region deployment.
*              <br/>PPBSF-832
*
* @author Sandile Mathe (sandile.mathe@standardbank.co.za)
* @date July 2026
*/
public without sharing class CMN_FLOW_PostChatTranscriptToCaseFeed implements Queueable, Database.AllowsCallouts {

    private static final String DATE_FORMAT = 'yyyy-MM-dd HH:mm:ss';
    private static final String TIME_FORMAT = 'HH:mm:ss';
    private static final Integer MAX_FEED_BODY_LENGTH = 9900;
    private static final String TRANSCRIPT_HEADER = '━━━ CHAT TRANSCRIPT ━━━';
    private static final String TRANSCRIPT_FOOTER = '━━━ TRANSCRIPT START  ━━━';
    private static final String SEPARATOR_LINE = '━━━━━━━━━━━━━━━━━━━━━━━';
    private static final String VALUE_NOT_AVAILABLE = 'N/A';
    private static final String TIME_NOT_AVAILABLE = '--:--:--';
    private static final String ACTOR_UNKNOWN = 'Unknown';
    private static final String CONNECT_API_PATH = '/services/data/v61.0/connect/conversation/';
    private static final String ENTRIES_SUFFIX = '/entries';
    private static final String ERROR_NO_SESSIONS = 'No valid MessagingSession IDs provided.';
    private static final String ERROR_NO_CASE_LINKED = 'No MessagingSessions with linked Cases found.';
    private static final String ERROR_CALLOUT_FAILED = 'Connect API callout failed with status: ';
    
    @TestVisible
	private static Map<Id, MessagingSession> mockSessionMap;

    private static sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_FLOW_PostChatTranscriptToCaseFeed');

    private List<Id> messagingSessionIds;

    /**
    * @description Constructor for Queueable execution.
    * @param messagingSessionIds List of MessagingSession record IDs to process
    */
    public CMN_FLOW_PostChatTranscriptToCaseFeed(List<Id> messagingSessionIds) {
        this.messagingSessionIds = messagingSessionIds;
    }

    /**
    * @description Invocable method to post chat transcript to Case Feed.
    *              Enqueues a Queueable job to allow HTTP callouts to the Connect REST API.
    *              Accepts a list of MessagingSession IDs from Flow.
    *
    * @param messagingSessionIds List of MessagingSession record IDs
    */
    @InvocableMethod(
        label='Post Chat Transcript to Case Feed'
        description='Posts the full messaging session transcript with timestamps to the linked Case feed via Connect REST API. Timezone resolved from user locale.'
        category='Messaging'
    )
    public static void postTranscriptToCaseFeed(List<Id> messagingSessionIds) {
        logger.info('postTranscriptToCaseFeed invoked with {0} session ID(s)', new List<Object>{ messagingSessionIds?.size() });

        if (messagingSessionIds == null || messagingSessionIds.isEmpty()) {
            logger.warn(ERROR_NO_SESSIONS);
            return;
        }

        System.enqueueJob(new CMN_FLOW_PostChatTranscriptToCaseFeed(messagingSessionIds));
    }

    /**
    * @description Queueable execute method. Performs the Connect REST API callout,
    *              parses the transcript, and inserts FeedItem records on the linked Case.
    * @param context QueueableContext
    */
    public void execute(QueueableContext context) {
    logger.info('Queueable execute started for {0} session(s)', new List<Object>{ messagingSessionIds.size() });

    try {
        Map<Id, MessagingSession> sessionMap = mockSessionMap != null
            ? mockSessionMap
            : getMessagingSessionsWithCase(messagingSessionIds);

        if (sessionMap.isEmpty()) {
            logger.warn(ERROR_NO_CASE_LINKED);
            return;
        }

        // ═══ FIX: Single-pass agent ID collection OUTSIDE the loop ═══
        Map<Id, List<TranscriptEntry>> sessionEntries = new Map<Id, List<TranscriptEntry>>();
        Set<Id> allAgentUserIds = new Set<Id>();

        for (MessagingSession ms : sessionMap.values()) {
            if (ms.ConversationId == null) {
                logger.warn('MessagingSession {0} has no ConversationId. Skipping.', new List<Object>{ ms.Id });
                continue;
            }


            String convIdentifier = ms.Conversation?.ConversationIdentifier;
            if (String.isBlank(convIdentifier)) {
                logger.warn('MessagingSession {0} has no ConversationIdentifier. Falling back to ConversationId.', new List<Object>{ ms.Id });
                convIdentifier = String.valueOf(ms.ConversationId);
            }
			@TestVisible
            List<TranscriptEntry> entries = fetchConversationEntries(convIdentifier);
            sessionEntries.put(ms.Id, entries);

            for (TranscriptEntry te : entries) {
                if (te.actorType == 'Agent' && String.isNotBlank(te.actorName)) {
                    try {
                        allAgentUserIds.add(Id.valueOf(te.actorName));
                    } catch (Exception e) {
                        logger.debug('Skipped non-ID actorName: {0}', new List<Object>{ te.actorName });
                    }
                }
            }
        }

        // ═══ Single SOQL query for ALL agent Users ═══
        Map<Id, User> agentMap = new Map<Id, User>();
        if (!allAgentUserIds.isEmpty()) {
            agentMap = new Map<Id, User>([
                SELECT Id, Name FROM User WHERE Id IN :allAgentUserIds LIMIT 200
            ]);
        }

        // ═══ Build transcripts using the pre-fetched agent map ═══
        List<FeedItem> feedItems = new List<FeedItem>();

        for (MessagingSession ms : sessionMap.values()) {
            List<TranscriptEntry> entries = sessionEntries.get(ms.Id);
            if (entries == null || entries.isEmpty()) {
                logger.info('No transcript entries found for session {0}.', new List<Object>{ ms.Id });
                continue;
            }

            // Replace raw identifiers
            for (TranscriptEntry te : entries) {
                if (te.actorType == 'Agent') {
                    try {
                        Id userId = Id.valueOf(te.actorName);
                        if (agentMap.containsKey(userId)) {
                            te.actorName = agentMap.get(userId).Name;
                        }
                    } catch (Exception e) {
                        logger.debug('Kept original actorName: {0}', new List<Object>{ te.actorName });
                    }
                } else if (te.actorType == 'EndUser') {
                    te.actorName = 'Customer';
                }
            }

            String transcript = buildTranscriptBody(ms, entries);
            List<String> transcriptChunks = splitTranscript(transcript);

            for (String chunk : transcriptChunks) {
                FeedItem fi = new FeedItem();
                fi.ParentId = ms.CaseId;
                fi.Body = chunk;
                fi.Type = 'TextPost';
                feedItems.add(fi);
            }
        }

        if (!feedItems.isEmpty()) {
            insert feedItems;
            logger.info('Successfully posted {0} transcript(s) to Case Feed.', new List<Object>{ feedItems.size() });
        } else {
            logger.info('No transcript entries found to post for any session.');
        }

    } catch (Exception ex) {
        logger.fatal('Queueable execute encountered an unexpected error: {0}', new List<Object>{ ex.getMessage() }, ex);
    }
}

    /*------------------------------------------------------------
    * Purpose:  Fetches conversation entries by calling the org's Connect REST API.
    *           Uses URL.getOrgDomainUrl() (auto-whitelisted)
    * Parameters: conversationId - The Conversation record ID
    * Returns:    List<TranscriptEntry> - Parsed transcript entries ordered by time
    *--------------------------------------------------------------
    */
    @TestVisible
    private List<TranscriptEntry> fetchConversationEntries(String conversationIdentifier) {
        List<TranscriptEntry> entries = new List<TranscriptEntry>();

       HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:CHNW_PPB_SE_ChatTranscriptN' + CONNECT_API_PATH + conversationIdentifier + ENTRIES_SUFFIX);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);


        if (res.getStatusCode() != 200) {
            logger.error(ERROR_CALLOUT_FAILED + '{0} - {1}', new List<Object>{ res.getStatusCode(), res.getBody() });
            return entries;
        }

        entries = parseConversationEntriesResponse(res.getBody());
        logger.info('Fetched {0} conversation entries for conversation {1}', new List<Object>{ entries.size(), conversationIdentifier  });
        return entries;
    }

    /*------------------------------------------------------------
    * Purpose:  Parses the JSON response from the Connect REST API into TranscriptEntry objects.
    * Parameters: jsonBody - Raw JSON response string
    * Returns:    List<TranscriptEntry>
    *--------------------------------------------------------------
    */
   	@TestVisible
    private List<TranscriptEntry> parseConversationEntriesResponse(String jsonBody) {
        List<TranscriptEntry> entries = new List<TranscriptEntry>();

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);

        List<Object> conversationEntries = (List<Object>) responseMap.get('conversationEntries');

        if (conversationEntries == null) {
            logger.warn('Key "conversationEntries" not found. Trying "entries"...');
            conversationEntries = (List<Object>) responseMap.get('entries');
        }
        if (conversationEntries == null) {
            logger.warn('Neither "conversationEntries" nor "entries" found in response. Available keys: {0}', new List<Object>{ responseMap.keySet() });
            return entries;
        }

        for (Object entryObj : conversationEntries) {
            Map<String, Object> entryMap = (Map<String, Object>) entryObj;

            TranscriptEntry te = new TranscriptEntry();
            te.message = (String) entryMap.get('messageText');
			te.actorName = getNestedString(entryMap, 'sender', 'subject');
            te.actorType = getNestedString(entryMap, 'sender', 'role');
            
            Object timestampObj = entryMap.get('clientTimestamp');
            if (timestampObj != null) {
                te.entryTime = DateTime.newInstance((Long) timestampObj);
            }

            if (String.isNotBlank(te.message)) {
                entries.add(te);
            }
        }

        return entries;
    }

    /*------------------------------------------------------------
    * Purpose:  Safely extracts a nested string value from a JSON map.
    * Parameters: parentMap - The parent map
    *             parentKey - Key for the nested object
    *             childKey - Key for the value within the nested object
    * Returns:    String value or null
    *--------------------------------------------------------------
    */
    private String getNestedString(Map<String, Object> parentMap, String parentKey, String childKey) {
        Object parentObj = parentMap.get(parentKey);
        if (parentObj == null) {
            return null;
        }
        if (parentObj instanceof Map<String, Object>) {
            Map<String, Object> childMap = (Map<String, Object>) parentObj;
            Object value = childMap.get(childKey);
            return value != null ? String.valueOf(value) : null;
        }
        return String.valueOf(parentObj);
    }

 
    /*------------------------------------------------------------
    * Purpose:  Resolves the running user's timezone from their Salesforce settings.
    *           Supports multi-region deployment.
    * Parameters: None
    * Returns:    String - IANA timezone ID (e.g., 'Africa/Johannesburg', 'Africa/Harare', 'Africa/Accra')
    *--------------------------------------------------------------
    */
    private static String getUserTimezone() {
        return UserInfo.getTimeZone().getID();
    }

    /*------------------------------------------------------------
    * Purpose:  Queries MessagingSessions that have a linked Case.
    * Parameters: messagingSessionIds - List of MessagingSession IDs
    * Returns:    Map of Id to MessagingSession
    *--------------------------------------------------------------
    */
    private static Map<Id, MessagingSession> getMessagingSessionsWithCase(List<Id> messagingSessionIds) {
        return new Map<Id, MessagingSession>([
            SELECT Id, CaseId, ConversationId, Conversation.ConversationIdentifier,
                   StartTime, EndTime, ChannelName, AgentType
            FROM MessagingSession
            WHERE Id IN :messagingSessionIds
            AND CaseId != null
            LIMIT 200
        ]);
    }

    /*------------------------------------------------------------
    * Purpose:  Formats the transcript body with header, dynamic timezone,
    *           timestamps per message, and footer.
    * Parameters: ms - MessagingSession record
    *             entries - List of TranscriptEntry objects (ordered by time)
    * Returns:    Formatted transcript String
    *--------------------------------------------------------------
    */
    @TestVisible
    private String buildTranscriptBody(MessagingSession ms, List<TranscriptEntry> entries) {
        String userTimezone = getUserTimezone();

        String transcript = TRANSCRIPT_HEADER + '\n';
        transcript += 'Channel: ' + (ms.ChannelName != null ? ms.ChannelName : VALUE_NOT_AVAILABLE) + '\n';
        transcript += 'Timezone: ' + userTimezone + '\n';
        transcript += 'Session Start: ' + formatDateTime(ms.StartTime, userTimezone) + '\n';
        transcript += 'Session End: ' + formatDateTime(ms.EndTime, userTimezone) + '\n';
        transcript += SEPARATOR_LINE + '\n\n';

        for (TranscriptEntry entry : entries) {
            String timestamp = formatTime(entry.entryTime, userTimezone);
            String actor = String.isNotBlank(entry.actorName) ? entry.actorName : ACTOR_UNKNOWN;
            String role = String.isNotBlank(entry.actorType) ? ' [' + entry.actorType + ']' : '';
            String message = String.isNotBlank(entry.message) ? entry.message : '';

            transcript += '[' + timestamp + '] ' + actor + role + ':\n' + message + '\n\n';
        }

        transcript += TRANSCRIPT_FOOTER;
        return transcript;
    }

    /*------------------------------------------------------------
    * Purpose:  Splits a transcript into chunks if it exceeds FeedItem body limit.
    *           Ensures no single FeedItem exceeds the 10,000 character limit.
    * Parameters: transcript - Full transcript string
    * Returns:    List<String> of transcript chunks
    *--------------------------------------------------------------
    */
    @TestVisible
    private List<String> splitTranscript(String transcript) {
        List<String> chunks = new List<String>();

        if (transcript.length() <= MAX_FEED_BODY_LENGTH) {
            chunks.add(transcript);
        } else {
            Integer startIndex = 0;
            Integer partNumber = 1;

            while (startIndex < transcript.length()) {
                Integer endIndex = Math.min(startIndex + MAX_FEED_BODY_LENGTH, transcript.length());
                String chunk = '[Part ' + partNumber + ']\n' + transcript.substring(startIndex, endIndex);
                chunks.add(chunk);
                startIndex = endIndex;
                partNumber++;
            }
        }

        return chunks;
    }

    /*------------------------------------------------------------
    * Purpose:  Formats a DateTime value using the provided timezone.
    * Parameters: dt - DateTime to format
    *             timezone - IANA timezone ID
    * Returns:    Formatted date/time string or 'N/A'
    *--------------------------------------------------------------
    */
    private static String formatDateTime(DateTime dt, String timezone) {
        if (dt == null) {
            return VALUE_NOT_AVAILABLE;
        }
        return dt.format(DATE_FORMAT, timezone);
    }

    /*------------------------------------------------------------
    * Purpose:  Formats a DateTime value to time-only using the provided timezone.
    * Parameters: dt - DateTime to format
    *             timezone - IANA timezone ID
    * Returns:    Formatted time string or '--:--:--'
    *--------------------------------------------------------------
    */
    private static String formatTime(DateTime dt, String timezone) {
        if (dt == null) {
            return TIME_NOT_AVAILABLE;
        }
        return dt.format(TIME_FORMAT, timezone);
    }

    /*------------------------------------------------------------
    * Purpose:  Inner class representing a parsed transcript entry from the Connect API response.
    *--------------------------------------------------------------
    */
    @TestVisible
    private class TranscriptEntry {
        public String message;
        public String actorName;
        public String actorType;
        public DateTime entryTime;
    }
}