/***************************************************************************************
@Name of the Class :KYC_DTO_Checks_Test
@Description :SFP-40755 Test Class for KYC_DTO_Checks.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_DTO_Checks_Test {
    /**
    * @description test method for KYC_DTO_Checks Constructor
    */
    @IsTest
    static void constructorTest() {
        Test.startTest();
        KYC_DTO_Checks checks = new KYC_DTO_Checks();
        Test.stopTest();
        Assert.areEqual(false, checks.idValidation, 'idValidation should be initialized to false');
        Assert.areEqual(false, checks.idv, 'idv should be initialized to false');
        Assert.areEqual(false, checks.raas, 'raas should be initialized to false');
        Assert.areEqual(false, checks.documentUpload, 'documentUpload should be initialized to false');
    }
    /**
    * @description test method for KYC_DTO_Checks IdValidationProperty
    */
    @IsTest
    static void idValidationPropertyTest() {
        Test.startTest();
        KYC_DTO_Checks checks = new KYC_DTO_Checks();
        checks.idValidation = true;
        Test.stopTest();
        Assert.areEqual(true, checks.idValidation, 'idValidation should be set to true');
        checks.idValidation = false;
        Assert.areEqual(false, checks.idValidation, 'idValidation should be set to false');
    }
    /**
    * @description test method for KYC_DTO_Checks IdvProperty
    */
    @IsTest
    static void idvPropertyTest() {
        Test.startTest();
        KYC_DTO_Checks checks = new KYC_DTO_Checks();
        Test.stopTest();
        checks.idv = true;
        Assert.areEqual(true, checks.idv, 'idv should be set to true');
        checks.idv = false;
        Assert.areEqual(false, checks.idv, 'idv should be set to false');
    }
    /**
    * @description test method for KYC_DTO_Checks RaasProperty
    */
    @IsTest
    static void RaasPropertyTest() {
        Test.startTest();
        KYC_DTO_Checks checks = new KYC_DTO_Checks();
        Test.stopTest();
        checks.raas = true;
        Assert.areEqual(true, checks.raas, 'raas should be set to true');
        checks.raas = false;
        Assert.areEqual(false, checks.raas, 'raas should be set to false');
    }
     /**
    * @description test method for KYC_DTO_Checks DocumentUploadProperty
    */
    @IsTest
    static void DocumentUploadPropertyTest() {
        Test.startTest();
        KYC_DTO_Checks checks = new KYC_DTO_Checks();
        Test.stopTest();
        checks.documentUpload = true;
        Assert.areEqual(true, checks.documentUpload, 'documentUpload should be set to true');
        checks.documentUpload = false;
        Assert.areEqual(false, checks.documentUpload, 'documentUpload should be set to false');
    }
}