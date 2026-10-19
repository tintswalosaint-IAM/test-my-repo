/**
* @description SFP-32986 Class used as test class KYC_API_CreatePartyProfileResultHandler
*  
* @author IKYATHA NAIDU
* 
* @date 11/05/2024
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated to latest version and implemented @TestSetup
*/
@isTest
public class KYC_API_CreatePartyProfileResultHan_Test {
     /**
     * @description Test method for setupTestData
     */
    @TestSetup
    static void setupTestData() {
        Account testAccount = KYC_TestDataFactory.createAccount();
        PartyProfile profileData = KYC_TestDataFactory.createPartyProfile(testAccount.Id);
        KYC_TestDataFactory.createPartyIdentity(profileData.Id);
    }
     /**
     * @description Test method for ProcessKycTestFailure
     */
    @IsTest
    static void testProcessKycTestFailure() {
        String iString = '{"clientDetails":,{"title":"MR.","firstName":"TETS","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
        
        Test.startTest();
        KYC_API_CreatePartyProfileResultHandler handler = new KYC_API_CreatePartyProfileResultHandler();
        KYC_DTO_ClientWrapper.Response dtoResponse = (KYC_DTO_ClientWrapper.Response) JSON.deserialize(handler.responseCall(iString), KYC_DTO_ClientWrapper.Response.class);
        Test.stopTest();
        
        Assert.areEqual('Failed', dtoResponse.status, 'Expected status to be Failed due to JSON exception');
    }
    /**
     * @description Test method for ProcessKycTestSuccess
     */
    @IsTest
    static void testProcessKycTestSuccess() {
        String iString = '{"clientDetails":{"title":"Mr.","firstName":"IGA","middleName":null,"lastName":"KAGGWA","gender":"Male","channel":"Website","idDocIssuingCountry":"Uganda","idNumber":"CF000121003X3A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"nagendra.mylavarapu@cloud23.io","nationality":"Uganda","isEmployed":true,"occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UGANDA","countryOfResidence":"UGANDA","passportIssuingCountry":"UGANDA","employmentType":"Retired","ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"USA","stateCode":"UG","countryCode":"UG","postalCode":"908"}]},"checks":{"idValidation":true,"idv":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
        Test.startTest();
        KYC_API_CreatePartyProfileResultHandler handler = new KYC_API_CreatePartyProfileResultHandler();
        KYC_DTO_ClientWrapper.Response dtoResponse = (KYC_DTO_ClientWrapper.Response) JSON.deserialize(handler.responseCall(iString), KYC_DTO_ClientWrapper.Response.class);
        Test.stopTest();
        Assert.areEqual('Success', dtoResponse.status, 'Expected status to be Success');
    }
     /**
     * @description Test method for tProcessKycTestNegFailure
     */
    @IsTest
    static void testProcessKycTestNegFailure() {
        String iString = null;
        Test.startTest();
        KYC_API_CreatePartyProfileResultHandler handler = new KYC_API_CreatePartyProfileResultHandler();
        KYC_DTO_ClientWrapper.Response dtoResponse = (KYC_DTO_ClientWrapper.Response) JSON.deserialize(handler.responseCall(iString), KYC_DTO_ClientWrapper.Response.class);
        Test.stopTest();
        Assert.areEqual('Failed', dtoResponse.status, 'Expected status to be Failed due to null input');
    }
}