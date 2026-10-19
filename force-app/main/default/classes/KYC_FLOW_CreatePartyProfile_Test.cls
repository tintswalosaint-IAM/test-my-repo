/***************************************************************************************
@Name of the Class :public with sharing class KYC_FLOW_CreatePartyProfile_Test 
@Description :SFP-40755 Test Class for KYC_FLOW_CreatePartyProfile.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
@IsTest
public class KYC_FLOW_CreatePartyProfile_Test {
    /**
    * @description This method used to test processKYC method
    */
    @IsTest
    public static void processKYC_Test(){
        List<KYC_DTO_FlowCreatePartyProfile> clientDataList= new  List<KYC_DTO_FlowCreatePartyProfile>();
        String requestData='{"clientDetails":{"title":"Mr.","firstName":"IGA","middleName":null,"lastName":"KAGGWA","gender":"Male","channel":"Website","idDocIssuingCountry":"Uganda","idNumber":"CF000121003X3A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"Santhosh.amisthapuram@cloud23.io","nationality":"Uganda","isEmployed":true,"occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UGANDA","countryOfResidence":"UGANDA","passportIssuingCountry":"UGANDA","employmentType":"Retired","ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"USA","stateCode":"UG","countryCode":"UG","postalCode":"908"}]},"checks":{"idValidation":true,"idv":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
        KYC_DTO_FlowCreatePartyProfile requestBody = (KYC_DTO_FlowCreatePartyProfile) JSON.deserializeStrict(
            requestData, KYC_DTO_FlowCreatePartyProfile.class
        );
        clientDataList.add(requestBody);
        Test.startTest();
        new KYC_FLOW_CreatePartyProfile();
        List<KYC_DTO_ClientWrapper.Response> response =KYC_FLOW_CreatePartyProfile.processKYC(clientDataList);
        Test.stopTest();
        Assert.areEqual(200, response[0].responseCode,'Expected Status Code 200');
        
    }
    
}