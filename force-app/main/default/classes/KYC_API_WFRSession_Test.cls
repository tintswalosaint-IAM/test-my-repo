/***************************************************************************************
@Name of the Class :KYC_API_WFRSession_Test
@Description :SFP-40755 Test Class for KYC_API_WFRSession.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@istest
public class KYC_API_WFRSession_Test {
@TestSetup
    static void setup() {
        PartyProfile pProfile = new PartyProfile(
            Name='Test',
            WI_IdentificationDocumentIssuingCountry__c = 'AF',
            WI_PrimaryIdentificationName__c = '1234567890'
        );
        insert pProfile;
    }
    /**
     * @description Test method for KYC_API_WFRSession
     */
    @IsTest
    static void kYCAPIWFRSessionTest() {
        PartyProfile pProfile = [SELECT Id,WI_IdentificationDocumentIssuingCountry__c,WI_PrimaryIdentificationName__c FROM PartyProfile LIMIT 1];
        Test.startTest();
        string transactionID='123456577';
         String validResponse ='{"sessionToken": "86592055-5c8a-4d33-8a3d-e748cc5c4135"}';
        KYC_API_WFRSession customerServiceCall = new KYC_API_WFRSession(validResponse, pProfile,transactionID);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_RAAS.SERVICE_NAME);
        customerServiceCall.process(obj);
        Test.stopTest();
        Assert.areEqual(200, customerServiceCall.getResponseStatusCode(),'Expected response Code 200');
    }
}