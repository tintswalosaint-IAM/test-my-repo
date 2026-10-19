/***************************************************************************************
@Name of the Class :KYC_API_RAAS_Test
@Description :SFP-40755 Test Class for KYC_API_RAAS.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@istest
public class KYC_API_RAAS_Test {
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
     * @description Test method for KYC_API_RAAS
     */
    @IsTest
    static void KYCAPIRAASTest() {
        PartyProfile pProfile = [SELECT Id,WI_IdentificationDocumentIssuingCountry__c,WI_PrimaryIdentificationName__c FROM PartyProfile LIMIT 1];
        Test.startTest();
        string transactionID='123456577';
        String validResponse ='{"assessmentResult":{"assessmentId":"001","status":"Completed","result":"Fulfilled","screeningResults":[{"screeningId":"006","screeningType":"Sanction Status","screeningName":"AssessmentType","result":"Approved"},{"screeningId":"018","screeningType":"Prominent Influential Persons (PIP)","screeningName":"AssessmentType","result":"No"},{"screeningId":"019","screeningType":"CRA","screeningName":"AssessmentType","result":"No"}]}}';
        KYC_API_RAAS customerServiceCall = new KYC_API_RAAS(validResponse, pProfile,transactionID);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_RAAS.SERVICE_NAME);
        customerServiceCall.process(obj);
        Test.stopTest();
        Assert.areEqual(200, customerServiceCall.getResponseStatusCode(),'Expected response Code 200');
    }
}