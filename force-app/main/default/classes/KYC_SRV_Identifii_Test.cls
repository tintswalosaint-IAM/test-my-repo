/***************************************************************************************
@Name of the Class :KYC_SRV_Identifii_Test
@Description :SFP-40755 Test Class for KYC_SRV_Identifii
@Author :Dayakar 
@Created Date :OCT 14 2024
***************************************************************************************
* Last Modified By : Initital Version
* Last Modified Date :Initital Version
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_SRV_Identifii_Test {
    
    /**
     * @description Test method for KYC_SRV_Identifii.documentCallout
     */
    @IsTest
    private static void documentCalloutTest() {
        Test.startTest(); 
        new KYC_SRV_Identifii();
        KYC_SRV_Identifii.KYC_DTO_Response identifiiResponse = KYC_SRV_Identifii.documentCallout('5d1a3657-646c-4184-811e-f972591d80b9');
        Test.stopTest();
        Assert.areEqual(200, identifiiResponse.responseCode, 'The expected value should match the Document API response Code');
    }

}