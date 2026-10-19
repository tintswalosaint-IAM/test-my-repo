/**
 * @description       : Test class for BAS_DTO_EventAlertsResponse and ALL its related sub-classes 
 * @author            : Sandile Mathe
 * @group             : Personalisation
 * @created On        : 13-05-2024
**/

@isTest
public class BAS_DTO_EventAlertsResponse_Test {
@isTest
    static void testEventAlertsProperties() {
        Test.startTest();
        // Arrange: Create an instance of DTO Class and set properties
        BAS_DTO_EventAlertsResponse myInstance = new BAS_DTO_EventAlertsResponse();
        String expectedDetail = 'Test Detail';
        String expectedEventContent = 'Test Event Content';
        String expectedEventDetails = 'Test Event Details';
        String expectedAccountId = '0014556656858973';
        String expectedPortfolioCode ='0046DC2';
        Date expectedEventLoadDate = Date.today(); 
        String expectedClientName ='ZA01519079219';
        
        myInstance.detail = expectedDetail;
        myInstance.eventContent = expectedEventContent;
        myInstance.eventDetails = expectedEventDetails;
        myInstance.accountId = expectedAccountId;
        myInstance.portfolioCode = expectedPortfolioCode;
        myInstance.eventLoadDate = expectedEventLoadDate;
        myInstance.clientName = expectedClientName;
        myInstance.eventType ='FRAUD_ALERT';
        myInstance.eventId = '9';
        myInstance.aeNumber ='0046DC2';
        myInstance.bpid = '1519079219';
        
		Test.stopTest();
        
        //No actions needed as we are testing property assignments
        
        //Verify the properties are set correctly
        Assert.areEqual(expectedDetail, myInstance.detail, 'Detail should be set correctly');
        Assert.areEqual(expectedEventContent, myInstance.eventContent, 'EventContent should be set correctly');
        Assert.areEqual(expectedEventDetails, myInstance.eventDetails, 'EventDetails should be set correctly');
        Assert.areEqual(expectedAccountId, myInstance.accountId, 'AccountId should be set correctly');
        
        Assert.areEqual(expectedPortfolioCode, myInstance.portfolioCode, 'PortfolioCode should be set correctly');
        Assert.areEqual(expectedEventLoadDate, myInstance.eventLoadDate, 'eventLoadDate should be set correctly');
        Assert.areEqual(expectedClientName, myInstance.clientName, 'clientName should be set correctly');
        Assert.areEqual('FRAUD_ALERT', myInstance.eventType, 'eventType should be set correctly');
        
        Assert.areEqual('9', myInstance.eventId, 'eventId should be set correctly');
        Assert.areEqual('0046DC2', myInstance.aeNumber, 'aeNumber should be set correctly');
        Assert.areEqual('1519079219', myInstance.bpid, 'bpid should be set correctly');
    }
}