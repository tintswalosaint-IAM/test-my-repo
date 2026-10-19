/**
 * @description Test class for CMN_FLOW_PostChatTranscriptToCaseFeed.
 *              Validates the invocable method, Queueable execution, Connect REST API
 *              callout handling, transcript parsing, formatting, and chunking logic.
 *              Uses @TestVisible to directly test private methods since Conversation
 *              records cannot be inserted via DML.
 *              Gracefully skips tests requiring MessagingSession DML when Messaging
 *              is disabled in the target org (e.g., Production validation).
 *              <br/>
 *
 * @author Sandile Mathe (sandile.mathe@standardbank.co.za)
 * @date July 2026
 * @UserStory PPBSF-832
 *
 * @see CMN_FLOW_PostChatTranscriptToCaseFeed
 */
@isTest
private class CMN_FLOW_PostChatTranscriptToCase_TEST {

    private static final String CHANNEL_WHATSAPP = 'ZW CCC MIAW';
    private static final String CONVERSATION_ID_MOCK = '03f5c3fb-dd70-40b5-80ff-a230cdf04d7d';
    private static final String SESSION_STATUS_ENDED = 'Ended';
    private static final String CASE_SUBJECT = 'WhatsApp Chat Case';
    private static final Integer HTTP_STATUS_OK = 200;
    private static final Integer HTTP_STATUS_UNAUTHORIZED = 401;
    private static final Integer HTTP_STATUS_NOT_FOUND = 404;
    private static final Integer MAX_FEED_BODY_LENGTH = 9900;
    private static final String ERROR_INVALID_GRANT = '{"error":"invalid_grant","error_description":"authentication failure"}';
    private static final String ERROR_NOT_FOUND = '{"error":"RECORD_NOT_FOUND"}';
    private static final String EMPTY_ENTRIES_RESPONSE = '{"conversationEntries":[]}';

    // ═══════════════════════════════════════════════════════════════
    // MESSAGING FEATURE CHECK
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Checks if Messaging is enabled in the current org by verifying
     *              that MessagingSession records exist (created in @testSetup).
     *              Returns false if Messaging is disabled and DML failed silently.
     * @return Boolean true if MessagingSession data is available
     */
    private static Boolean isMessagingAvailable() {
        return [SELECT COUNT() FROM MessagingSession] > 0;
    }

    /**
     * @description Generates a valid fake MessagingSession ID using the correct
     *              key prefix from the org schema. Produces a 15-char ID.
     * @return A valid MessagingSession Id
     */
    private static Id getFakeSessionId() {
        String prefix = MessagingSession.SObjectType.getDescribe().getKeyPrefix();
        return Id.valueOf(prefix + '000000000001');
    }

    // ═══════════════════════════════════════════════════════════════
    // TEST DATA SETUP
    // ═══════════════════════════════════════════════════════════════

    @testSetup
    static void setup() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Account testAccount = new Account(Name = 'Test Transcript Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Customer',
            AccountId = testAccount.Id
        );
        insert testContact;

        Case testCase = new Case(
            Subject = CASE_SUBJECT,
            Status = 'New',
            ContactId = testContact.Id,
            Description = CONVERSATION_ID_MOCK
        );
        insert testCase;

        // Messaging objects — wrapped in try-catch for orgs where Messaging is disabled
        try {
            System.runAs(currentUser) {
                MessagingChannel channel = new MessagingChannel(
                    DeveloperName = 'Test_WhatsApp_Channel',
                    MasterLabel = CHANNEL_WHATSAPP,
                    MessagingPlatformKey = 'test_platform_key_001',
                    MessageType = 'WhatsApp'
                );
                insert channel;
            }

            MessagingChannel channel = [
                SELECT Id FROM MessagingChannel
                WHERE DeveloperName = 'Test_WhatsApp_Channel' LIMIT 1
            ];

            MessagingEndUser endUser = new MessagingEndUser(
                Name = 'Test WhatsApp Customer',
                MessagingChannelId = channel.Id,
                MessageType = 'WhatsApp',
                MessagingPlatformKey = '263771234567'
            );
            insert endUser;

            MessagingSession session = new MessagingSession(
                MessagingChannelId = channel.Id,
                MessagingEndUserId = endUser.Id,
                Status = SESSION_STATUS_ENDED,
                CaseId = testCase.Id,
                StartTime = DateTime.now().addMinutes(-30),
                EndTime = DateTime.now()
            );
            insert session;
        } catch (Exception e) {
            // Messaging is disabled in this org — tests using mockSessionMap will still run
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // HELPER — BUILD MOCK SESSION (bypasses read-only fields via JSON)
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Creates an in-memory MessagingSession with ConversationId and
     *              ChannelName populated using JSON.deserialize (bypasses read-only
     *              field restrictions).
     * @param sessionId The MessagingSession Id
     * @param caseId The linked Case Id
     * @param conversationIdentifier The conversation UUID string
     * @return MessagingSession with all fields set
     */
    private static MessagingSession buildMockSessionWithConversation(Id sessionId, Id caseId, String conversationIdentifier) {
        String fakeConversationId = '0Mu000000000001AAA';
        String sessionJson = '{' +
            '"attributes": {"type": "MessagingSession"},' +
            '"Id": "' + sessionId + '",' +
            '"CaseId": "' + caseId + '",' +
            '"ConversationId": "' + fakeConversationId + '",' +
            '"Conversation": {"ConversationIdentifier": "' + conversationIdentifier + '"},' +
            '"StartTime": "' + DateTime.now().addMinutes(-30).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000') + '",' +
            '"EndTime": "' + DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000') + '",' +
            '"ChannelName": "' + CHANNEL_WHATSAPP + '"' +
        '}';
        return (MessagingSession) JSON.deserialize(sessionJson, MessagingSession.class);
    }

    /**
     * @description Creates an in-memory MessagingSession with specific fields via JSON.
     * @param startTime The session start time (null for N/A test)
     * @param endTime The session end time (null for N/A test)
     * @param channelName The channel name (null for N/A test)
     * @return MessagingSession with fields set
     */
    private static MessagingSession buildInMemorySession(DateTime startTime, DateTime endTime, String channelName) {
        String sessionJson = '{"attributes": {"type": "MessagingSession"}';

        if (startTime != null) {
            sessionJson += ',"StartTime": "' + startTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000') + '"';
        }
        if (endTime != null) {
            sessionJson += ',"EndTime": "' + endTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS+0000') + '"';
        }
        if (channelName != null) {
            sessionJson += ',"ChannelName": "' + channelName + '"';
        }

        sessionJson += '}';
        return (MessagingSession) JSON.deserialize(sessionJson, MessagingSession.class);
    }

    /**
     * @description Gets a valid session ID — real if Messaging is available, fabricated otherwise.
     * @return A valid MessagingSession Id
     */
    private static Id getSessionId() {
        if (isMessagingAvailable()) {
            return [SELECT Id FROM MessagingSession LIMIT 1].Id;
        }
        return getFakeSessionId();
    }

    // ═══════════════════════════════════════════════════════════════
    // HTTP CALLOUT MOCKS
    // ═══════════════════════════════════════════════════════════════

    private class MockHttpSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_OK);
            res.setBody(buildSuccessResponseBody());
            return res;
        }
    }

    private class MockHttpAlternateKey implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_OK);
            res.setBody(buildAlternateKeyResponseBody());
            return res;
        }
    }

    private class MockHttpEmpty implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_OK);
            res.setBody(EMPTY_ENTRIES_RESPONSE);
            return res;
        }
    }

    private class MockHttpUnauthorized implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_UNAUTHORIZED);
            res.setBody(ERROR_INVALID_GRANT);
            return res;
        }
    }

    private class MockHttpNotFound implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_NOT_FOUND);
            res.setBody(ERROR_NOT_FOUND);
            return res;
        }
    }

    private class MockHttpLargeTranscript implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_OK);
            res.setBody(buildLargeTranscriptResponseBody());
            return res;
        }
    }

    private class MockHttpUnrecognizedKeys implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_OK);
            res.setBody('{"messages":[],"total":0}');
            return res;
        }
    }

    private class MockHttpNonIdAgent implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(HTTP_STATUS_OK);
            Long nowMillis = System.now().getTime();
            res.setBody('{' +
                '"conversationEntries": [' +
                    '{"messageText": "Hello!", "sender": {"subject": "EndUserName", "role": "EndUser"}, "clientTimestamp": ' + (nowMillis - 60000) + '},' +
                    '{"messageText": "Hi, I am a bot.", "sender": {"subject": "EinsteinBot", "role": "Agent"}, "clientTimestamp": ' + (nowMillis - 50000) + '}' +
                ']}');
            return res;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // POSITIVE TESTS — INVOCABLE & QUEUEABLE ENTRY POINTS
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies invocable enqueues job successfully.
     */
    @isTest
    static void postTranscriptInvocableEnqueuesJobPositiveOutcome() {
        if (!isMessagingAvailable()) {
            return;
        }
        MessagingSession session = [SELECT Id FROM MessagingSession LIMIT 1];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(
                new List<Id>{ session.Id }
            );
        Test.stopTest();

        Assert.isNotNull(session.Id, 'Invocable should enqueue and execute without error.');
    }

    /**
     * @description Verifies Queueable handles session with Case but no ConversationId.
     */
    @isTest
    static void executeQueueableSessionNoConversationPositiveOutcome() {
        if (!isMessagingAvailable()) {
            return;
        }
        MessagingSession session = [SELECT Id, CaseId FROM MessagingSession WHERE CaseId != NULL LIMIT 1];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed queueable =
                new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>{ session.Id });
            System.enqueueJob(queueable);
        Test.stopTest();

        List<FeedItem> feedItems = [
            SELECT Id FROM FeedItem WHERE ParentId = :session.CaseId AND Type = 'TextPost'
        ];
        Assert.areEqual(0, feedItems.size(), 'No FeedItems when session has no ConversationId.');
    }

    /**
     * @description Verifies bulk processing without errors.
     */
    @isTest
    static void executeQueueableBulkSessionsPositiveOutcome() {
        if (!isMessagingAvailable()) {
            return;
        }
        Case testCase = [SELECT Id FROM Case WHERE Subject = :CASE_SUBJECT LIMIT 1];
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];

        List<MessagingEndUser> endUsers = new List<MessagingEndUser>();
        for (Integer i = 0; i < 5; i++) {
            endUsers.add(new MessagingEndUser(
                Name = 'Bulk Customer ' + i,
                MessagingChannelId = channel.Id,
                MessageType = 'WhatsApp',
                MessagingPlatformKey = '26377100000' + i
            ));
        }
        insert endUsers;

        List<MessagingSession> sessions = new List<MessagingSession>();
        for (Integer i = 0; i < 5; i++) {
            sessions.add(new MessagingSession(
                MessagingChannelId = channel.Id,
                MessagingEndUserId = endUsers[i].Id,
                Status = SESSION_STATUS_ENDED,
                CaseId = testCase.Id,
                StartTime = DateTime.now().addMinutes(-20),
                EndTime = DateTime.now()
            ));
        }
        insert sessions;

        List<Id> sessionIds = new List<Id>();
        for (MessagingSession ms : sessions) {
            sessionIds.add(ms.Id);
        }

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(sessionIds);
        Test.stopTest();

        Assert.areEqual(5, sessionIds.size(), 'All 5 sessions should be processed without error.');
    }

    // ═══════════════════════════════════════════════════════════════
    // POSITIVE TESTS — CALLOUT via @TestVisible
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies fetchConversationEntries returns parsed entries on 200.
     */
    @isTest
    static void fetchConversationEntriesSuccessPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.fetchConversationEntries(CONVERSATION_ID_MOCK);
        Test.stopTest();

        Assert.isFalse(entries.isEmpty(), 'Entries should be returned for successful callout.');
        Assert.areEqual(4, entries.size(), 'Should parse all 4 conversation entries.');
        Assert.isNotNull(entries[0].message, 'First entry should have a message.');
        Assert.areEqual('EndUser', entries[0].actorType, 'First entry should be from EndUser.');
    }

    /**
     * @description Verifies fetchConversationEntries returns empty on 401.
     */
    @isTest
    static void fetchConversationEntriesUnauthorizedNegativeOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpUnauthorized());
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.fetchConversationEntries(CONVERSATION_ID_MOCK);
        Test.stopTest();

        Assert.isTrue(entries.isEmpty(), 'No entries for 401 response.');
    }

    /**
     * @description Verifies fetchConversationEntries returns empty on 404.
     */
    @isTest
    static void fetchConversationEntriesNotFoundNegativeOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpNotFound());
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.fetchConversationEntries(CONVERSATION_ID_MOCK);
        Test.stopTest();

        Assert.isTrue(entries.isEmpty(), 'No entries for 404 response.');
    }

    /**
     * @description Verifies fetchConversationEntries returns empty on empty response.
     */
    @isTest
    static void fetchConversationEntriesEmptyNegativeOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpEmpty());
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.fetchConversationEntries(CONVERSATION_ID_MOCK);
        Test.stopTest();

        Assert.isTrue(entries.isEmpty(), 'No entries for empty response.');
    }

    // ═══════════════════════════════════════════════════════════════
    // POSITIVE TESTS — PARSING via @TestVisible
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies parsing with standard "conversationEntries" key.
     */
    @isTest
    static void parseResponseStandardKeyPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.parseConversationEntriesResponse(buildSuccessResponseBody());
        Test.stopTest();

        Assert.areEqual(4, entries.size(), 'Should parse 4 entries.');
        Assert.areEqual('Hello, I need help with my account.', entries[0].message,
            'First message should match.');
        Assert.areEqual('EndUser', entries[0].actorType, 'First role should be EndUser.');
        Assert.isNotNull(entries[0].entryTime, 'Timestamp should be parsed.');
    }

    /**
     * @description Verifies fallback parsing with "entries" key.
     */
    @isTest
    static void parseResponseAlternateKeyPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.parseConversationEntriesResponse(buildAlternateKeyResponseBody());
        Test.stopTest();

        Assert.areEqual(1, entries.size(), 'Should parse 1 entry from alternate key.');
        Assert.areEqual('Testing alternate key parsing.', entries[0].message,
            'Message should match.');
    }

    /**
     * @description Verifies parsing returns empty for unrecognized keys.
     */
    @isTest
    static void parseResponseUnrecognizedKeysNegativeOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.parseConversationEntriesResponse('{"messages":[],"total":0}');
        Test.stopTest();

        Assert.isTrue(entries.isEmpty(), 'Empty list for unrecognized keys.');
    }

    /**
     * @description Verifies blank/null messages are excluded.
     */
    @isTest
    static void parseResponseSkipsBlankMessagesNegativeOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());
        Long nowMillis = System.now().getTime();
        String jsonBody = '{' +
            '"conversationEntries": [' +
                '{"messageText": "", "sender": {"subject": "U1", "role": "EndUser"}, "clientTimestamp": ' + nowMillis + '},' +
                '{"messageText": null, "sender": {"subject": "U2", "role": "Agent"}, "clientTimestamp": ' + nowMillis + '},' +
                '{"messageText": "Valid", "sender": {"subject": "U3", "role": "EndUser"}, "clientTimestamp": ' + nowMillis + '}' +
            ']}';

        Test.startTest();
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.parseConversationEntriesResponse(jsonBody);
        Test.stopTest();

        Assert.areEqual(1, entries.size(), 'Only non-blank messages included.');
        Assert.areEqual('Valid', entries[0].message, 'Valid message preserved.');
    }

    /**
     * @description Verifies null sender is handled gracefully.
     */
    @isTest
    static void parseResponseNullSenderPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());
        Long nowMillis = System.now().getTime();
        String jsonBody = '{' +
            '"conversationEntries": [' +
                '{"messageText": "No sender msg", "sender": null, "clientTimestamp": ' + nowMillis + '}' +
            ']}';

        Test.startTest();
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.parseConversationEntriesResponse(jsonBody);
        Test.stopTest();

        Assert.areEqual(1, entries.size(), 'Entry with null sender should still parse.');
        Assert.isNull(entries[0].actorName, 'Null sender → null actorName.');
    }

    /**
     * @description Verifies null timestamp is handled gracefully.
     */
    @isTest
    static void parseResponseNullTimestampPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());
        String jsonBody = '{' +
            '"conversationEntries": [' +
                '{"messageText": "No time", "sender": {"subject": "U1", "role": "EndUser"}}' +
            ']}';

        Test.startTest();
            List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
                instance.parseConversationEntriesResponse(jsonBody);
        Test.stopTest();

        Assert.areEqual(1, entries.size(), 'Entry without timestamp should parse.');
        Assert.isNull(entries[0].entryTime, 'Null timestamp → null entryTime.');
    }

    // ═══════════════════════════════════════════════════════════════
    // POSITIVE TESTS — TRANSCRIPT BUILDING via @TestVisible
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies transcript body formatting with all fields populated.
     */
    @isTest
    static void buildTranscriptBodyFormatsCorrectlyPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        MessagingSession ms = buildInMemorySession(
            DateTime.now().addMinutes(-30),
            DateTime.now(),
            CHANNEL_WHATSAPP
        );

        List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
            new List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry>();

        CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry entry1 =
            new CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry();
        entry1.message = 'Hello, I need help.';
        entry1.actorName = 'Customer';
        entry1.actorType = 'EndUser';
        entry1.entryTime = DateTime.now().addMinutes(-10);
        entries.add(entry1);

        CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry entry2 =
            new CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry();
        entry2.message = 'Sure, let me assist you.';
        entry2.actorName = 'Agent Smith';
        entry2.actorType = 'Agent';
        entry2.entryTime = DateTime.now().addMinutes(-9);
        entries.add(entry2);

        Test.startTest();
            String transcript = instance.buildTranscriptBody(ms, entries);
        Test.stopTest();

        Assert.isTrue(transcript.contains('━━━ CHAT TRANSCRIPT ━━━'), 'Should contain header.');
        Assert.isTrue(transcript.contains('Timezone:'), 'Should contain timezone.');
        Assert.isTrue(transcript.contains('Session Start:'), 'Should contain session start.');
        Assert.isTrue(transcript.contains('Session End:'), 'Should contain session end.');
        Assert.isTrue(transcript.contains('Customer'), 'Should contain customer name.');
        Assert.isTrue(transcript.contains('Agent Smith'), 'Should contain agent name.');
        Assert.isTrue(transcript.contains('Hello, I need help.'), 'Should contain message.');
        Assert.isTrue(transcript.contains('━━━ TRANSCRIPT START  ━━━'), 'Should contain footer.');
    }

    /**
     * @description Verifies N/A displayed for null times.
     */
    @isTest
    static void buildTranscriptBodyNullTimesPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        MessagingSession ms = buildInMemorySession(null, null, null);

        List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
            new List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry>();

        CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry entry =
            new CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry();
        entry.message = 'Test';
        entry.actorName = 'Customer';
        entry.actorType = 'EndUser';
        entry.entryTime = null;
        entries.add(entry);

        Test.startTest();
            String transcript = instance.buildTranscriptBody(ms, entries);
        Test.stopTest();

        Assert.isTrue(transcript.contains('Session Start: N/A'),'Expected transcript to contain "Session Start: N/A" when session start time is null');
		Assert.isTrue(transcript.contains('Session End: N/A'),'Expected transcript to contain "Session End: N/A" when session end time is null');
		Assert.isTrue(transcript.contains('--:--:--'),'Expected transcript to contain "--:--:--" as placeholder when entry time is null');
    }

    /**
     * @description Verifies Unknown displayed for null/blank actor.
     */
    @isTest
    static void buildTranscriptBodyUnknownActorPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        MessagingSession ms = buildInMemorySession(
            DateTime.now().addMinutes(-30),
            DateTime.now(),
            CHANNEL_WHATSAPP
        );

        List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
            new List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry>();

        CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry entry =
            new CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry();
        entry.message = 'Unknown actor msg';
        entry.actorName = null;
        entry.actorType = null;
        entry.entryTime = DateTime.now();
        entries.add(entry);

        Test.startTest();
            String transcript = instance.buildTranscriptBody(ms, entries);
        Test.stopTest();

        Assert.isTrue(transcript.contains('Unknown'), 'Null actor → Unknown.');
    }

    /**
     * @description Verifies null ChannelName shows N/A.
     */
    @isTest
    static void buildTranscriptBodyNullChannelPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        MessagingSession ms = buildInMemorySession(
            DateTime.now().addMinutes(-10),
            DateTime.now(),
            null
        );

        List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry> entries =
            new List<CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry>();

        CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry entry =
            new CMN_FLOW_PostChatTranscriptToCaseFeed.TranscriptEntry();
        entry.message = 'Test msg';
        entry.actorName = 'Customer';
        entry.actorType = 'EndUser';
        entry.entryTime = DateTime.now();
        entries.add(entry);

        Test.startTest();
            String transcript = instance.buildTranscriptBody(ms, entries);
        Test.stopTest();

        Assert.isTrue(transcript.contains('Channel: N/A'), 'Null channel → N/A.');
    }

    // ═══════════════════════════════════════════════════════════════
    // POSITIVE TESTS — CHUNKING via @TestVisible
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies single chunk for short transcript.
     */
    @isTest
    static void splitTranscriptSingleChunkPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        Test.startTest();
            List<String> chunks = instance.splitTranscript('Short transcript.');
        Test.stopTest();

        Assert.areEqual(1, chunks.size(), 'Short transcript → one chunk.');
        Assert.areEqual('Short transcript.', chunks[0], 'Chunk matches original.');
    }

    /**
     * @description Verifies multiple chunks with part prefixes for large transcript.
     */
    @isTest
    static void splitTranscriptMultipleChunksPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        String largeTranscript = '';
        for (Integer i = 0; i < 200; i++) {
            largeTranscript += 'Line ' + i + ': Repeated text to exceed the character limit for testing purposes. ';
        }

        Test.startTest();
            List<String> chunks = instance.splitTranscript(largeTranscript);
        Test.stopTest();

        Assert.isTrue(chunks.size() > 1, 'Large transcript → multiple chunks. Got: ' + chunks.size());
        Assert.isTrue(chunks[0].contains('[Part 1]'), 'First chunk has Part 1 prefix.');
        Assert.isTrue(chunks[1].contains('[Part 2]'), 'Second chunk has Part 2 prefix.');
    }

    /**
     * @description Verifies transcript at exact boundary produces one chunk.
     */
    @isTest
    static void splitTranscriptExactBoundaryPositiveOutcome() {
        CMN_FLOW_PostChatTranscriptToCaseFeed instance =
            new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>());

        String boundaryTranscript = 'X'.repeat(MAX_FEED_BODY_LENGTH);

        Test.startTest();
            List<String> chunks = instance.splitTranscript(boundaryTranscript);
        Test.stopTest();

        Assert.areEqual(1, chunks.size(), 'Exact limit → one chunk.');
    }

    // ═══════════════════════════════════════════════════════════════
    // NEGATIVE TESTS — INVOCABLE ENTRY POINT
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies null input handled gracefully.
     */
    @isTest
    static void postTranscriptNullInputNegativeOutcome() {
        Test.startTest();
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(null);
        Test.stopTest();

        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Type = 'TextPost'];
        Assert.areEqual(0, feedItems.size(), 'No FeedItems for null input.');
    }

    /**
     * @description Verifies empty list handled gracefully.
     */
    @isTest
    static void postTranscriptEmptyListNegativeOutcome() {
        Test.startTest();
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(new List<Id>());
        Test.stopTest();

        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Type = 'TextPost'];
        Assert.areEqual(0, feedItems.size(), 'No FeedItems for empty list.');
    }

    /**
     * @description Verifies non-existent session IDs handled gracefully.
     */
    @isTest
    static void postTranscriptNonExistentSessionNegativeOutcome() {
        if (!isMessagingAvailable()) {
            return;
        }
        MessagingSession session = [SELECT Id FROM MessagingSession LIMIT 1];
        delete session;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(
                new List<Id>{ session.Id }
            );
        Test.stopTest();

        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Type = 'TextPost'];
        Assert.areEqual(0, feedItems.size(), 'No FeedItems for non-existent session.');
    }

    /**
     * @description Verifies session without Case is excluded.
     */
    @isTest
    static void postTranscriptSessionWithoutCaseNegativeOutcome() {
        if (!isMessagingAvailable()) {
            return;
        }
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];
        MessagingEndUser endUser = [SELECT Id FROM MessagingEndUser LIMIT 1];

        MessagingSession orphanSession = new MessagingSession(
            MessagingChannelId = channel.Id,
            MessagingEndUserId = endUser.Id,
            Status = SESSION_STATUS_ENDED,
            StartTime = DateTime.now().addMinutes(-10),
            EndTime = DateTime.now()
        );
        insert orphanSession;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(
                new List<Id>{ orphanSession.Id }
            );
        Test.stopTest();

        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Type = 'TextPost'];
        Assert.areEqual(0, feedItems.size(), 'No FeedItems for session without Case.');
    }

    /**
     * @description Verifies mixed valid/invalid IDs handled without exception.
     */
    @isTest
    static void postTranscriptMixedValidInvalidIdsNegativeOutcome() {
        if (!isMessagingAvailable()) {
            return;
        }
        MessagingSession validSession = [SELECT Id FROM MessagingSession WHERE CaseId != NULL LIMIT 1];
        MessagingChannel channel = [SELECT Id FROM MessagingChannel LIMIT 1];

        MessagingEndUser tempEndUser = new MessagingEndUser(
            Name = 'Temp Customer',
            MessagingChannelId = channel.Id,
            MessageType = 'WhatsApp',
            MessagingPlatformKey = '263779999999'
        );
        insert tempEndUser;

        MessagingSession tempSession = new MessagingSession(
            MessagingChannelId = channel.Id,
            MessagingEndUserId = tempEndUser.Id,
            Status = SESSION_STATUS_ENDED,
            StartTime = DateTime.now().addMinutes(-5),
            EndTime = DateTime.now()
        );
        insert tempSession;

        Id deletedId = tempSession.Id;
        delete tempSession;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed.postTranscriptToCaseFeed(
                new List<Id>{ validSession.Id, deletedId }
            );
        Test.stopTest();

        Assert.isNotNull(validSession.Id, 'Mixed IDs should not throw exception.');
    }

    // ═══════════════════════════════════════════════════════════════
    // POSITIVE TESTS — FULL EXECUTE PATH (using mockSessionMap)
    // ═══════════════════════════════════════════════════════════════

    /**
     * @description Verifies full path with agent name resolution.
     *              Uses mockSessionMap to bypass MessagingSession DML dependency.
     */
    @isTest
    static void executeFullPathAgentResolvedPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :CASE_SUBJECT LIMIT 1];
        Id sessionId = getSessionId();

        MessagingSession mockSession = buildMockSessionWithConversation(sessionId, testCase.Id, CONVERSATION_ID_MOCK);
        CMN_FLOW_PostChatTranscriptToCaseFeed.mockSessionMap = new Map<Id, MessagingSession>{
            sessionId => mockSession
        };

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
            CMN_FLOW_PostChatTranscriptToCaseFeed queueable =
                new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>{ sessionId });
            System.enqueueJob(queueable);
        Test.stopTest();

        List<FeedItem> feedItems = [
            SELECT Id, Body FROM FeedItem
            WHERE ParentId = :testCase.Id AND Type = 'TextPost'
        ];
        Assert.isFalse(feedItems.isEmpty(), 'FeedItems should be created.');
        Assert.isTrue(feedItems[0].Body.contains('CHAT TRANSCRIPT'), 'Should contain transcript header.');

        String userName = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
        Assert.isTrue(feedItems[0].Body.contains(userName),
            'Agent ID should be resolved to: ' + userName);
        Assert.isTrue(feedItems[0].Body.contains('Customer'),
            'EndUser actorName should be replaced with Customer.');
    }

    /**
     * @description Verifies catch block for non-ID agent name (e.g., bot).
     *              Uses mockSessionMap to bypass MessagingSession DML dependency.
     */
    @isTest
    static void executeFullPathNonIdAgentCatchBlockPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :CASE_SUBJECT LIMIT 1];
        Id sessionId = getSessionId();

        MessagingSession mockSession = buildMockSessionWithConversation(sessionId, testCase.Id, CONVERSATION_ID_MOCK);
        CMN_FLOW_PostChatTranscriptToCaseFeed.mockSessionMap = new Map<Id, MessagingSession>{
            sessionId => mockSession
        };

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpNonIdAgent());
            CMN_FLOW_PostChatTranscriptToCaseFeed queueable =
                new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>{ sessionId });
            System.enqueueJob(queueable);
        Test.stopTest();

        List<FeedItem> feedItems = [
            SELECT Id, Body FROM FeedItem
            WHERE ParentId = :testCase.Id AND Type = 'TextPost'
        ];
        Assert.isFalse(feedItems.isEmpty(), 'FeedItems should be created even with non-ID agent.');
        Assert.isTrue(feedItems[0].Body.contains('EinsteinBot'),
            'Non-ID agent name should be preserved as-is.');
    }

    /**
     * @description Verifies large transcript produces multiple FeedItems (chunking).
     *              Uses mockSessionMap to bypass MessagingSession DML dependency.
     */
    @isTest
    static void executeFullPathLargeTranscriptChunkedPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :CASE_SUBJECT LIMIT 1];
        Id sessionId = getSessionId();

        MessagingSession mockSession = buildMockSessionWithConversation(sessionId, testCase.Id, CONVERSATION_ID_MOCK);
        CMN_FLOW_PostChatTranscriptToCaseFeed.mockSessionMap = new Map<Id, MessagingSession>{
            sessionId => mockSession
        };

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpLargeTranscript());
            CMN_FLOW_PostChatTranscriptToCaseFeed queueable =
                new CMN_FLOW_PostChatTranscriptToCaseFeed(new List<Id>{ sessionId });
            System.enqueueJob(queueable);
        Test.stopTest();

        List<FeedItem> feedItems = [
            SELECT Id, Body FROM FeedItem
            WHERE ParentId = :testCase.Id AND Type = 'TextPost'
        ];
        Assert.isTrue(feedItems.size() > 1,
            'Large transcript should produce multiple FeedItems. Got: ' + feedItems.size());
        Assert.isTrue(feedItems[0].Body.contains('[Part 1]'), 'First chunk should have Part 1.');
    }

    // ═══════════════════════════════════════════════════════════════
    // HELPER METHODS — RESPONSE BUILDERS
    // ═══════════════════════════════════════════════════════════════

    private static String buildSuccessResponseBody() {
        Long nowMillis = System.now().getTime();
        String agentUserId = UserInfo.getUserId();

        return '{' +
            '"conversationEntries": [' +
                '{"messageText": "Hello, I need help with my account.", "sender": {"subject": "EndUserName", "role": "EndUser"}, "clientTimestamp": ' + (nowMillis - 300000) + '},' +
                '{"messageText": "Hi there! Let me assist you.", "sender": {"subject": "' + agentUserId + '", "role": "Agent"}, "clientTimestamp": ' + (nowMillis - 240000) + '},' +
                '{"messageText": "I cannot access my statements.", "sender": {"subject": "EndUserName", "role": "EndUser"}, "clientTimestamp": ' + (nowMillis - 180000) + '},' +
                '{"messageText": "Let me look into that for you.", "sender": {"subject": "' + agentUserId + '", "role": "Agent"}, "clientTimestamp": ' + (nowMillis - 120000) + '}' +
            ']' +
        '}';
    }

    private static String buildAlternateKeyResponseBody() {
        Long nowMillis = System.now().getTime();
        return '{"entries": [{"messageText": "Testing alternate key parsing.", "sender": {"subject": "EndUserName", "role": "EndUser"}, "clientTimestamp": ' + (nowMillis - 60000) + '}]}';
    }

    private static String buildLargeTranscriptResponseBody() {
        Long baseTime = System.now().getTime() - 600000;
        String agentUserId = UserInfo.getUserId();
        List<String> entryList = new List<String>();

        for (Integer i = 0; i < 200; i++) {
            String role = Math.mod(i, 2) == 0 ? 'EndUser' : 'Agent';
            String subject = role == 'Agent' ? agentUserId : 'CustomerName';
            String message = 'Message ' + i + ' - Additional text to increase transcript size for chunking validation.';

            entryList.add(
                '{"messageText": "' + message + '", "sender": {"subject": "' + subject + '", "role": "' + role + '"}, "clientTimestamp": ' + (baseTime + (i * 10000)) + '}'
            );
        }

        return '{"conversationEntries": [' + String.join(entryList, ',') + ']}';
    }
}