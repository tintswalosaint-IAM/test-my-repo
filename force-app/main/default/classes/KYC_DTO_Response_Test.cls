/***************************************************************************************
@Name of the Class :KYC_DTO_Response_Test
@Description :SFP-40755 Test Class for KYC_DTO_Response.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
* Modified by Irshad to cover the main class.
****************************************************************************************/

@isTest
public class KYC_DTO_Response_Test {

    /**
     * @description test method for KYC_DTO_Response with error scenario
     */   
    @IsTest
    static void KYC_DTO_Response_WithErrorTest() {
        Test.startTest();
        Map<String, Object> jsonRes = new Map<String, Object>{
            'error' => new Map<String, Object>{
                'errorCode' => '400'
            }
        };
        String response = 'Mock Error Response';
        KYC_DTO_Response dtoResponse = new KYC_DTO_Response(jsonRes, response);
        Test.stopTest();
        Assert.areEqual('Failed', dtoResponse.status);
        Assert.areEqual(
            'We are currently experiencing technical difficulties with processing your request. Please try again later. If the problem persists, please contact us (Error code 400)', 
            dtoResponse.responseErrorMessage
        );
    }

    /**
     * @description test method for KYC_DTO_Response success scenario without kraInformation
     */ 
    @IsTest
    static void KYC_DTO_Response_SuccessTest() {
        Test.startTest();
        Map<String, Object> jsonRes = new Map<String, Object>();
        String response = 'Mock Success Response';
        KYC_DTO_Response dtoResponse = new KYC_DTO_Response(jsonRes, response);
        Test.stopTest();
        Assert.areEqual('Success', dtoResponse.status);
        Assert.areEqual(response, dtoResponse.response);
        Assert.areEqual('', dtoResponse.responseErrorMessage);
    }

    /**
     * @description test method for KYC_DTO_Response with status and error code
     */ 
    @IsTest
    static void KYC_DTO_Response_WithStatusAndCodeTest() {
        Test.startTest();
        String status = 'Failed';
        Integer responseCode = 500;
        KYC_DTO_Response dtoResponse = new KYC_DTO_Response(status, responseCode);
        Test.stopTest();
        Assert.areEqual('Failed', dtoResponse.status);
        Assert.areEqual(
            'Technical errors were experienced during the verification process, please re-try by accessing the same link. (Error code: 500)', 
            dtoResponse.responseErrorMessage
        );
    }

    /**
     * @description test method for KYC_DTO_Response.getErrorMessage
     */ 
    @IsTest
    static void GetErrorMessageTest() {
        Test.startTest();
        String errorMessage400 = KYC_DTO_Response.getErrorMessage('400');
        String errorMessage500 = KYC_DTO_Response.getErrorMessage('500');
        Test.stopTest();
        Assert.areEqual(
            'Technical errors were experienced during the verification process, please re-try by accessing the same link. (Error code: 500)', 
            errorMessage500
        );
        Assert.areEqual(
            'We are currently experiencing technical difficulties with processing your request. Please try again later. If the problem persists, please contact us (Error code 400)', 
            errorMessage400
        );
    }

    /**
     * @description test method for kraInformation with VALID ID
     */
    @IsTest
    static void KYC_DTO_Response_WithKraInformation_ValidIdTest() {
        Test.startTest();
        Map<String, Object> kraInfo = new Map<String, Object>{
            'StatusMessage' => 'VALID ID',
            'KraPin' => 'A123456789B'
        };
        Map<String, Object> jsonRes = new Map<String, Object>{
            'kraInformation' => kraInfo,
            'TransactionId' => 'TXN123456'
        };
        String response = 'Mock Success Response';
        KYC_DTO_Response dtoResponse = new KYC_DTO_Response(jsonRes, response);
        Test.stopTest();
        Assert.areEqual('Success', dtoResponse.status);
        Assert.areEqual('Accepted', dtoResponse.kraStatusMessage);
        Assert.areEqual('A123456789B', dtoResponse.kraPin);
        Assert.areEqual('TXN123456', dtoResponse.kraTransactionId);
    }

    /**
     * @description test method for kraInformation with Invalid ID
     */
    @IsTest
    static void KYC_DTO_Response_WithKraInformation_InvalidIdTest() {
        Test.startTest();
        Map<String, Object> kraInfo = new Map<String, Object>{
            'StatusMessage' => 'Invalid ID'
        };
        Map<String, Object> jsonRes = new Map<String, Object>{
            'kraInformation' => kraInfo,
            'TransactionId' => 'TXN654321'
        };
        String response = 'Mock Success Response';
        KYC_DTO_Response dtoResponse = new KYC_DTO_Response(jsonRes, response);
        Test.stopTest();
        Assert.areEqual('Success', dtoResponse.status);
        Assert.areEqual('Rejected', dtoResponse.kraStatusMessage);
        Assert.areEqual(null, dtoResponse.kraPin);
        Assert.areEqual('TXN654321', dtoResponse.kraTransactionId);
    }
}