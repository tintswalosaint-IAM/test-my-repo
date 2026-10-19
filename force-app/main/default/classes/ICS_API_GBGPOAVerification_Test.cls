/**
* @description SFP-32986 Class used as test class for ICS_API_GBGPOAVerification
*  
* @author Ikyatha Naidu
* 
* @date 11/05/2024
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated to latest version
*/
@isTest
public class ICS_API_GBGPOAVerification_Test {
     @TestSetup
    static void setupTestData() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
		commUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];       
        PartyProfile profileData =  ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.AccountId);
        ICS_DAL_TestFactory.createPartyProfileAddress(profileData.Id, 'Residential Address', Date.today(), null);
        ICS_DAL_TestFactory.createPointPhone(commUser.contact.AccountId);
    }
     @isTest
    static void callAddressVerification() {
       
        User commUser =[select id,name,contact.AccountId from User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile profileData =[Select id from PartyProfile where accountId=:commUser.Contact.AccountId];
        
        Assert.areEqual(true,(commUser !=null),'Community User created');
        Test.startTest();
        system.runas(commUser){
            ICS_API_GBGPOAVerification customerServiceCall = new ICS_API_GBGPOAVerification(profileData.id);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GBGPOAVerification.SERVICE_NAME,profileData.id);
            customerServiceCall.process(obj);
        }
        Test.stopTest();
    }
    @isTest
    static void callAddressVerificationNegativeScenario() {
        User commUser =[select id,name,contact.AccountId from User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile profileData =[Select id from PartyProfile where accountId=:commUser.Contact.AccountId];
        Assert.areEqual(true, (commUser != null), 'Community User created');

        Test.startTest();
        System.runAs(commUser) {
            // Mock failure response
            ICS_API_GBGPOAVerification.ICS_API_GBGPOAVerificationMock mock = new ICS_API_GBGPOAVerification.ICS_API_GBGPOAVerificationMock('ICS_API_GBGPOAVerification','FAILURE');
            Test.setMock(HttpCalloutMock.class, mock);

            ICS_API_GBGPOAVerification customerServiceCall = new ICS_API_GBGPOAVerification(profileData.Id);
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_GBGPOAVerification.SERVICE_NAME, profileData.Id);
            customerServiceCall.process(obj);
            
        }
        Test.stopTest();
    }
    
    
    
}