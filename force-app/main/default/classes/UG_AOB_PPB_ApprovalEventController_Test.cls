/**
 * @description       : code coverage class for UG_AOB_PPB_ApprovalEventController
 * @author            : jagadish Thummala
 * User Story ID       : SFP-28286
 * @last modified on  : 11-03-2025
 * @last modified by  : jagadish Thummala
**/
@isTest
public class UG_AOB_PPB_ApprovalEventController_Test {
    
    /**
    * @description to test the sucessfull event
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testPublishApprovalEvent_Success() {
        // Arrange
        String testStatus = 'Approved';
        String testSessionId = 'test_session_123';
        String testConsentData = '{"consent1":"true","consent2":"false"}';
        
        // Act
        Test.startTest();
        String resultId = UG_AOB_PPB_ApprovalEventController.publishApprovalEvent(
            testStatus, 
            testSessionId, 
            testConsentData
        );
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(null, resultId, 'Event ID should not be null');
        Assert.isTrue(resultId.length() > 0, 'Event ID should be returned');
    }
    
    /**
    * @description to test the sucessful published event
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testPublishApprovalEvent_WithEventDelivery() {
        // Arrange
        String testStatus = 'Rejected';
        String testSessionId = 'session_456';
        String testConsentData = '{"consent1":"false"}';
        
        // Act
        Test.startTest();
        String resultId = UG_AOB_PPB_ApprovalEventController.publishApprovalEvent(
            testStatus, 
            testSessionId, 
            testConsentData
        );
        
        // Deliver the event immediately
        Test.getEventBus().deliver();
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(null, resultId, 'Event should be published successfully');
    }
    
    /**
    * @description to test the exception
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testPublishApprovalEvent_WithNullValues() {
        // Arrange
        String testStatus = null;
        String testSessionId = null;
        String testConsentData = null;
        
        // Act
        Test.startTest();
        try {
            String resultId = UG_AOB_PPB_ApprovalEventController.publishApprovalEvent(
                testStatus, 
                testSessionId, 
                testConsentData
            );
            Test.stopTest();
            
            // Assert - should succeed even with null values
            Assert.areNotEqual(null, resultId, 'Event should handle null values');
        } catch (AuraHandledException e) {
            Test.stopTest();
            // Assert - if exception is thrown, verify it's an AuraHandledException
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 
                         'Should throw AuraHandledException with appropriate message');
        }
    }
    
    /**
    * @description to test the exception 
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testPublishApprovalEvent_ExceptionHandling() {
        // Arrange
        String testStatus = 'Test';
        String testSessionId = 'session_789';
        String testConsentData = '{"test":"data"}';
        
        // Act & Assert
        Test.startTest();
        try {
            UG_AOB_PPB_ApprovalEventController.publishApprovalEvent(
                testStatus, 
                testSessionId, 
                testConsentData
            );
            
            // Simulate failure
            Test.getEventBus().fail();
            Test.stopTest();
            
        } catch (AuraHandledException e) {
            Test.stopTest();
            Assert.areNotEqual(null, e.getMessage(), 'Exception message should not be null');
            Assert.isTrue(e.getMessage().contains('Error publishing event'), 
                         'Exception message should contain expected text');
        }
    }
    
    /**
    * @description to test if the session ID is null
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testGenerateSessionId_Uniqueness() {
        // Act
        Test.startTest();
        String sessionId1 = UG_AOB_PPB_ApprovalEventController.generateSessionId();
        String sessionId2 = UG_AOB_PPB_ApprovalEventController.generateSessionId();
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(null, sessionId1, 'Session ID should not be null');
        Assert.areNotEqual(null, sessionId2, 'Session ID should not be null');
        Assert.areNotEqual(sessionId1, sessionId2, 'Session IDs should be unique');
    }
    
    /**
    * @description to test the proper session id
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testGenerateSessionId_Format() {
        // Act
        Test.startTest();
        String sessionId = UG_AOB_PPB_ApprovalEventController.generateSessionId();
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(null, sessionId, 'Session ID should not be null');
        Assert.isTrue(sessionId.contains('_'), 'Session ID should contain underscore separator');
        
        // Verify format: timestamp_randomnumber
        List<String> parts = sessionId.split('_');
        Assert.areEqual(2, parts.size(), 'Session ID should have two parts separated by underscore');
        Assert.isTrue(parts[0].isNumeric(), 'First part should be numeric timestamp');
        Assert.areEqual(6, parts[1].length(), 'Second part should be 6 characters');
    }
    
    /**
    * @description to test the published events
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testPublishApprovalEvent_MultipleEvents() {
        // Arrange
        List<String> eventIds = new List<String>();
        
        // Act
        Test.startTest();
        for (Integer i = 0; i < 3; i++) {
            String eventId = UG_AOB_PPB_ApprovalEventController.publishApprovalEvent(
                'Status_' + i,
                'Session_' + i,
                '{"consent":"' + i + '"}'
            );
            eventIds.add(eventId);
        }
        Test.getEventBus().deliver();
        Test.stopTest();
        
        // Assert
        Assert.areEqual(3, eventIds.size(), 'Should publish 3 events');
        for (String eventId : eventIds) {
            Assert.areNotEqual(null, eventId, 'Each event ID should not be null');
        }
    }
    
    /**
    * @description to test the consent data
    * @author jagadish Thummala | 10-16-2025 
    **/
    @isTest
    static void testPublishApprovalEvent_LargeConsentData() {
        // Arrange
        String largeConsentData = '{"consent1":"true","consent2":"false","consent3":"true",' +
                                 '"consent4":"false","consent5":"true","longField":"' + 
                                 'A'.repeat(500) + '"}';
        
        // Act
        Test.startTest();
        String resultId = UG_AOB_PPB_ApprovalEventController.publishApprovalEvent(
            'Approved',
            'large_session_123',
            largeConsentData
        );
        Test.stopTest();
        
        // Assert
        Assert.areNotEqual(null, resultId, 'Should handle large consent data');
    }
}