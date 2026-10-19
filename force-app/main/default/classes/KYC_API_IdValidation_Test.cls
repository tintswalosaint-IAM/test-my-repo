/***************************************************************************************
@Name of the Class :KYC_API_IdValidation_Test
@Description :SFP-32817 Test Class for KYC_API_IdValidation
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
Public class KYC_API_IdValidation_Test {
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
     * @description Test method for KYC_API_IdValidation_Test
     */
    @IsTest
    static void testKYC_API_IdValidation() {
        PartyProfile pProfile = [SELECT Id,WI_IdentificationDocumentIssuingCountry__c,WI_PrimaryIdentificationName__c FROM PartyProfile LIMIT 1];
        Test.startTest();
        String mockJsonBody = '{ "AssessmentType": "IdentityVerification", "Result": "success", "ResultReason": "", "Error": 0 }';
        KYC_API_IdValidation kycValidation = new KYC_API_IdValidation(mockJsonBody, pProfile);
        kycValidation.process(CMN_DAL_DataFactory.newWebserviceQueue(KYC_API_IdValidation.SERVICE_NAME));    
        KYC_API_IdValidation.DTO_Response result=(KYC_API_IdValidation.DTO_Response)kycValidation.baseResponseDTO;
        Test.stopTest();
        Assert.areEqual(null,result.response,'expected value null');
    }
}