/***************************************************************************************
@Name of the Class :KYC_DTO_ProfileRequest_Test
@Description :SFP-40755 Test Class for KYC_DTO_ProfileRequest.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_DTO_ProfileRequest_Test {
    /**
    * @description test method for KYC_DTO_ProfileRequest Constructor
    */
    @IsTest
    static void ConstructorTest() {
        Test.startTest();
        KYC_DTO_ProfileRequest request = new KYC_DTO_ProfileRequest();
        Test.stopTest();
        Assert.isNotNull(request.checks, 'Checks should be initialized in the constructor');
    }
    /**
    * @description test method for KYC_DTO_ProfileRequest ClientDetailsAssignment
    */
    @IsTest
    static void clientDetailsAssignmentTest() {
        KYC_DTO_ProfileRequest request = new KYC_DTO_ProfileRequest();
        KYC_DTO_ClientDetails clientDetails = new KYC_DTO_ClientDetails();
        Test.startTest();
        request.clientDetails = clientDetails;
        Test.stopTest();
        Assert.isNotNull(request.clientDetails, 'Client details should not be null');
    }
    /**
    * @description test method for KYC_DTO_ProfileRequest ChecksAssignment
    */
    @IsTest
    static void ChecksAssignmentTest() {
        KYC_DTO_ProfileRequest request = new KYC_DTO_ProfileRequest();
        KYC_DTO_Checks newChecks = new KYC_DTO_Checks();
        Test.startTest();
        request.checks = newChecks;
        Test.stopTest();
        Assert.isNotNull(request.checks, 'Checks should not be null');
    }
}