/**
 * @description Comprehensive test class for SVC_ChatBotInitHandler covering WhatsApp and LiveChat initialization scenarios
 * 
 * @changes Implemented test seam pattern using SVC_ChatBotInitHandler.testMessagingSession for effective mocking
 * @changes Added comprehensive WhatsApp scenarios test covering contact matching and phone validation
 * @changes Added LiveChat scenarios test with contact association and field population
 * @changes Added error handling tests for null inputs, empty inputs, and invalid object types
 * @changes Added utility methods testing for phone extraction, validation, and contact search
 * @changes Enhanced test coverage from 71% to target 85%+ using effective test seam approach
 * @changes Added comprehensive method descriptions for better maintainability
 * @changes Cleaned up code with proper documentation and removed debug statements
 * 
 * @author Alexandr Goryachko (alexandr.goryachko@standardbank.co.za)
 * @modified Raymond Magezi - Enhanced with best practices
 * @date Oct 14th 2021
 * @updated July 08th 2025
 */
@isTest
public class SVC_ChatBotInitHandler_TEST {
    private static final String WHATSAPP_PREFIX = 'whatsapp:';
    private static final String TEST_EMAIL = 'test@example.com';
    private static final String TEST_PHONE = '+256700110110';
    private static final String TEST_PHONE_CLEAN = '256700110110';
    private static final String TEST_FIRST_NAME = 'Test';
    private static final String TEST_LAST_NAME = 'User';
    private static final String PHONE_LITERAL = '256700110110';
    private static final String BAD_PHONE = '123';
    private static final String INVALID_INPUT_MSG = 'Invalid input';
    private static final String AT_EXAMPLE_COM = '@example.com';
    private static final String TEST_ACCOUNT_NAME = 'Test Account';



    /**
     * @description Test comprehensive WhatsApp scenarios including contact matching, phone validation, and session handling
     * Covers multiple test cases: valid contact match, no contact match, invalid phone format, and session not found
     */
    @isTest
    private static void testWhatsAppScenarios() {
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Phone = TEST_PHONE_CLEAN,
            Email = TEST_EMAIL,
            FirstName = TEST_FIRST_NAME,
            LastName = TEST_LAST_NAME
        );
        insert testContact;
        
        Test.startTest();
        
        // Test Case 1: Valid WhatsApp session with matching contact
        MessagingEndUser mockEndUser1 = new MessagingEndUser();
        mockEndUser1.Name = WHATSAPP_PREFIX + TEST_PHONE;
        MessagingSession mockSession1 = new MessagingSession();
        mockSession1.Id = '0Mw000000000000AAA';
        mockSession1.MessagingEndUser = mockEndUser1;
        SVC_ChatBotInitHandler.testMessagingSession = mockSession1;
        
        SVC_ChatBotInitHandler.ChatBotInput input1 = new SVC_ChatBotInitHandler.ChatBotInput();
        input1.routableId = mockSession1.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> result1 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input1});
        
        // Test Case 2: Valid phone number but no matching contact in database
        MessagingEndUser mockEndUser2 = new MessagingEndUser();
        mockEndUser2.Name = WHATSAPP_PREFIX + '+8888888888';
        MessagingSession mockSession2 = new MessagingSession();
        mockSession2.Id = '0Mw000000000001AAA';
        mockSession2.MessagingEndUser = mockEndUser2;
        SVC_ChatBotInitHandler.testMessagingSession = mockSession2;
        
        SVC_ChatBotInitHandler.ChatBotInput input2 = new SVC_ChatBotInitHandler.ChatBotInput();
        input2.routableId = mockSession2.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> result2 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input2});
        
        // Test Case 3: Invalid phone number format (too short)
        MessagingEndUser mockEndUser3 = new MessagingEndUser();
        mockEndUser3.Name = WHATSAPP_PREFIX + BAD_PHONE;
        MessagingSession mockSession3 = new MessagingSession();
        mockSession3.Id = '0Mw000000000002AAA';
        mockSession3.MessagingEndUser = mockEndUser3;
        SVC_ChatBotInitHandler.testMessagingSession = mockSession3;
        
        SVC_ChatBotInitHandler.ChatBotInput input3 = new SVC_ChatBotInitHandler.ChatBotInput();
        input3.routableId = mockSession3.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> result3 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input3});
        
        // Test Case 4: MessagingSession not found scenario
        SVC_ChatBotInitHandler.testMessagingSession = null;
        SVC_ChatBotInitHandler.ChatBotInput input4 = new SVC_ChatBotInitHandler.ChatBotInput();
        input4.routableId = '0Mw000000000003AAA';
        List<SVC_ChatBotInitHandler.ChatBotOutput> result4 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input4});
        
        Test.stopTest();
        
        // Verify results for all test cases
        // Test Case 1: Successful contact match
        Assert.areEqual(null, result1[0].errorMessage, 'Should not have error for valid contact match');
        Assert.areEqual(true, result1[0].isWhatsAppChannel, 'Should identify as WhatsApp channel');
        Assert.areEqual(TEST_PHONE_CLEAN, result1[0].phone, 'Should extract and clean phone number');
        Assert.areEqual(TEST_FIRST_NAME + ' ' + TEST_LAST_NAME, result1[0].name, 'Should populate contact name');
        
        // Test Case 2: No contact match
        Assert.areEqual('8888888888', result2[0].phone, 'Should extract phone number even without contact match');
        Assert.areEqual(null, result2[0].name, 'Should not have contact name when no match found');
        
        // Test Case 3: Invalid phone format
        Assert.areEqual('Invalid phone number format', result3[0].errorMessage, 'Should return error for invalid phone');
        
        // Test Case 4: Session not found
        Assert.areEqual('No WhatsApp session found', result4[0].errorMessage, 'Should return error when session not found');
    }
    
    /**
     * @description Test LiveChat transcript scenarios with contact association and field population
     * Covers standard contact association, scenarios without contact, and email fallback functionality
     */
    @isTest
    private static void testLiveChatScenarios() {
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Phone = TEST_PHONE_CLEAN,
            Email = TEST_EMAIL,
            FirstName = TEST_FIRST_NAME,
            LastName = TEST_LAST_NAME
        );
        insert testContact;
        
        LiveChatVisitor newVisitor = new LiveChatVisitor();
        insert newVisitor;
        
        Test.startTest();
        
        // Test Case 1: Standard LiveChat transcript with associated contact
        LiveChatTranscript transcript1 = new LiveChatTranscript(
            ContactId = testContact.Id,
            AccountId = testAccount.Id,
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = String.valueOf(System.UUID.randomUUID()),
            SVC_FirstName__c = TEST_FIRST_NAME,
            SVC_LastName__c = TEST_LAST_NAME,
            SVC_Phone__c = TEST_PHONE,
            SVC_Email__c = TEST_EMAIL
        );
        insert transcript1;
        
        SVC_ChatBotInitHandler.ChatBotInput input1 = new SVC_ChatBotInitHandler.ChatBotInput();
        input1.routableId = transcript1.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> result1 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input1});
        
        // Test Case 2: LiveChat transcript without contact and invalid phone data
        LiveChatTranscript transcript2 = new LiveChatTranscript(
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = String.valueOf(System.UUID.randomUUID()),
            SVC_FirstName__c = 'NoContact',
            SVC_LastName__c = 'User',
            SVC_Phone__c = BAD_PHONE
        );
        insert transcript2;
        
        SVC_ChatBotInitHandler.ChatBotInput input2 = new SVC_ChatBotInitHandler.ChatBotInput();
        input2.routableId = transcript2.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> result2 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input2});
        
        // Test Case 3: Contact email fallback when transcript email is blank
        Contact contactWithEmail = new Contact(
            FirstName = 'Email',
            LastName = 'Contact',
            Email = 'other@example.com',
            Phone = '256700110120'
        );
        insert contactWithEmail;
        
        LiveChatTranscript transcript3 = new LiveChatTranscript(
            ContactId = contactWithEmail.Id,
            AccountId = testAccount.Id,
            LiveChatVisitorId = newVisitor.Id,
            ChatKey = String.valueOf(System.UUID.randomUUID()),
            SVC_FirstName__c = 'Email',
            SVC_LastName__c = 'Contact',
            SVC_Phone__c = '256700110120'
        );
        insert transcript3;
        
        SVC_ChatBotInitHandler.ChatBotInput input3 = new SVC_ChatBotInitHandler.ChatBotInput();
        input3.routableId = transcript3.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> result3 = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{input3});
        
        Test.stopTest();
        
        // Verify results for all LiveChat test cases
        // Test Case 1: Standard LiveChat with contact
        Assert.areEqual(null, result1[0].errorMessage, 'Should not have error for valid LiveChat');
        Assert.areEqual(false, result1[0].isWhatsAppChannel, 'Should identify as LiveChat channel');
        Assert.areEqual(TEST_FIRST_NAME, result1[0].firstName, 'Should populate first name from transcript');
        Assert.areEqual(TEST_EMAIL, result1[0].email, 'Should populate email from transcript');
        
        // Test Case 2: LiveChat without contact
        Assert.areEqual('NoContact', result2[0].firstName, 'Should populate first name from transcript fields');
        Assert.areEqual(null, result2[0].phone, 'Should not populate phone for invalid format');
        Assert.areEqual(null, result2[0].email, 'Should not populate email when blank');
        
        // Test Case 3: Contact email fallback
        Assert.areEqual('other@example.com', result3[0].email, 'Should use contact email as fallback');
        Assert.areEqual('Email Contact', result3[0].name, 'Should populate contact name');
    }
    
    /**
     * @description Test error handling for null inputs, empty inputs, and invalid object types
     * Validates proper error message generation and graceful handling of edge cases
     */
    @isTest
    private static void testErrorScenariosAndUtilities() {
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Phone = TEST_PHONE_CLEAN,
            Email = TEST_EMAIL,
            FirstName = TEST_FIRST_NAME,
            LastName = TEST_LAST_NAME
        );
        insert testContact;
        
        Test.startTest();
        
        // Test various error scenarios to ensure proper error handling
        List<SVC_ChatBotInitHandler.ChatBotOutput> nullResult = SVC_ChatBotInitHandler.init(null);
        List<SVC_ChatBotInitHandler.ChatBotOutput> emptyResult = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>());
        
        SVC_ChatBotInitHandler.ChatBotInput invalidInput = new SVC_ChatBotInitHandler.ChatBotInput();
        invalidInput.routableId = testAccount.Id;
        List<SVC_ChatBotInitHandler.ChatBotOutput> invalidResult = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{invalidInput});
        
        SVC_ChatBotInitHandler.ChatBotInput nullIdInput = new SVC_ChatBotInitHandler.ChatBotInput();
        nullIdInput.routableId = null;
        List<SVC_ChatBotInitHandler.ChatBotOutput> nullIdResult = SVC_ChatBotInitHandler.init(new List<SVC_ChatBotInitHandler.ChatBotInput>{nullIdInput});
        
        Test.stopTest();
        
        // Verify that appropriate error messages are returned for each scenario
        Assert.isTrue(nullResult[0].errorMessage.contains('No input parameters provided'), 'Should handle null input gracefully');
        Assert.isTrue(emptyResult[0].errorMessage.contains('No input parameters provided'), 'Should handle empty input gracefully');
        Assert.isTrue(invalidResult[0].errorMessage.contains(INVALID_INPUT_MSG), 'Should handle invalid object type');
        Assert.isTrue(nullIdResult[0].errorMessage.contains(INVALID_INPUT_MSG), 'Should handle null routable ID');
    }



    /**
     * @description Test all utility helper methods including phone extraction, validation, and contact search
     * Validates extractPhoneNumber, isValidPhoneNumber, isValidEmail, findContactByPhone, formatExceptionMessage, and createErrorResponse methods
     */
    @isTest
    private static void testUtilityMethods() {
        // Setup test data to support contact search functionality testing
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            Phone = TEST_PHONE_CLEAN,
            Email = TEST_EMAIL,
            FirstName = TEST_FIRST_NAME,
            LastName = TEST_LAST_NAME
        );
        insert testContact;
        
        // Test all utility methods with various input scenarios
        
        // Test phone number extraction functionality
        Assert.areEqual(PHONE_LITERAL, SVC_ChatBotInitHandler.extractPhoneNumber('whatsapp:+256700110110'), 'Should extract clean phone number');
        Assert.areEqual('', SVC_ChatBotInitHandler.extractPhoneNumber(''), 'Should handle empty input');
        
        // Test phone number validation functionality
        Assert.areEqual(true, SVC_ChatBotInitHandler.isValidPhoneNumber(PHONE_LITERAL), 'Should validate correct phone number');
        Assert.areEqual(false, SVC_ChatBotInitHandler.isValidPhoneNumber(BAD_PHONE), 'Should reject invalid phone number');
        
        // Test email validation functionality
        Assert.areEqual(true, SVC_ChatBotInitHandler.isValidEmail('test' + AT_EXAMPLE_COM), 'Should validate correct email format');
        Assert.areEqual(false, SVC_ChatBotInitHandler.isValidEmail('invalid-test'), 'Should reject invalid email format');
        
        // Test contact search functionality
        Contact found = SVC_ChatBotInitHandler.findContactByPhone(TEST_PHONE_CLEAN);
        Assert.areNotEqual(null, found, 'Should find existing contact by phone number');
        Assert.areEqual(null, SVC_ChatBotInitHandler.findContactByPhone('999999999999'), 'Should return null for non-existent phone');
        
        // Test exception message formatting
        try {
            Integer.valueOf('invalid');
        } catch (Exception ex) {
            String msg = SVC_ChatBotInitHandler.formatExceptionMessage(ex);
            Assert.isTrue(msg.contains('Initialization failed:'), 'Should format exception message properly');
        }
        
        // Test error response creation
        List<SVC_ChatBotInitHandler.ChatBotOutput> errorResult = SVC_ChatBotInitHandler.createErrorResponse('Test error');
        Assert.areEqual('Test error', errorResult[0].errorMessage, 'Should create error response with correct message');
        Assert.areEqual(false, errorResult[0].isWhatsAppChannel, 'Error response should default to non-WhatsApp channel');
    }

}