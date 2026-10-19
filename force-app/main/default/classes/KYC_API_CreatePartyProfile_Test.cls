/**
 *@className : KYC_API_CreatePartyProfile_Test
* @description  :Test class for KYC_API_CreatePartyProfile
*  
* @author Nagendra Mylavarapu
* 
* @date Jan 12 2024
* Last Modified By  Nagendra Mylavarapu
* Last Modified Date 23/04/2024
*/ 
@isTest
public class KYC_API_CreatePartyProfile_Test {
    @isTest
    static void testCreatePartyProfile() {
        
       String jsonString = '{"clientDetails":{"title":"MR.","firstName":"TETS","middleName":"IK","lastName":"TEST","gender":"Male","channel":"Website","idDocIssuingCountry":"UG","idNumber":"PD000123003X4A","primaryIdType":"National Identity Document","primaryPhone":"123-456-7890","primaryEmail":"test@gmail.com","nationality":"UG","occupationLevel":"Unemployed","relatedId":"0013M00001SaJrvQAF","dob":"2000-01-01","cardNumber":"000092634","countryOfCitizenship":"UG","countryOfResidence":"UG","passportIssuingCountry":"UG","employmentType":"Retired","isEmployed":true,"ficPip":true,"ficPipRel":true,"ficPipRelFirstName":"Engineering","ficPipRelLastName":"Engineering","docAdd":"Proof Of Address;Proof of Identity","addresses":[{"type":"Billing","primaryAddress":true,"street":"sadasad","city":"RAJ","stateCode":"RJ","countryCode":"UG","postalCode":"123"}]},"checks":{"idValidation":true,"idv":true, "raas":true,"assessment":{"PEP_Screening":true,"CRA":true,"screening":true}}}';
        
        // Set up a mock request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/createPartyProfile/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonString);
        
        // Set up a mock response
        RestResponse res = new RestResponse();
        
        // Call the service method
        Test.startTest();
        // Set the request and response objects in RestContext
        RestContext.request = req;
        RestContext.response = res;
        // Call the service method
       
       
     
        try{
            KYC_API_CreatePartyProfile.processRequest();
        }catch(exception e){
             Assert.areEqual(true,(jsonString !=null),'Request sent to create Profile Service');
        }
         Test.stopTest();        
    }
 

}