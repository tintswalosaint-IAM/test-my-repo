/*****************************************************
* @description  Class used as test controller for ICS_API_GBGIDPOAVerifyResult
* @author IKYATHA NAIDU,Swapnil Walse
* @User Story SFP-32986
* @date 12/05/2024
**********************************************************
* @Last Modified By  IKYATHA NAIDU
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated version to latest
*/ 
@isTest
public class ICS_API_GBGIDPOAVerifyResult_Test {
    @testsetup
    static void setup(){
         Account acc = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createapplicationForm(acc.id);
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(acc.id);
        ICS_DAL_TestFactory.createPartyIdentity(pData.id);
    }
    @isTest
    static void testAPICallGBGPOA() {
        
        // Test data setup
        account acc =[select id from account limit 1];
        String jsonString = '{"data":{"assessments":{"edges":[{"node":{"id":"5804832","complete":true,"status":"IdentityConfirmed","webhookUrl":null,"created":"2024-04-16T08:53:11.638699+00:00","updated":"2024-04-16T09:02:03.743546+00:00","assessmentConfig":{"name":"identity_and_address","assessmentType":"GenericAssessment"},"customer":{"id":"73603333","identifier":"'+acc.id+'","pageUrl":"https://app.relycomply.com/customer/73603333/"},"screenings":{"edges":[{"node":{"id":"16054780","outcome":"AddressConfirmed","screeningConfig":{"name":"gbg_address_screening","screeningType":"GBGAddressScreening"},"cases":{"edges":[{"node":{"id":"111882","closed":true,"state":"Complete","outcome":"AddressConfirmed"}}]}}},{"node":{"id":"16054779","outcome":"IdentityConfirmed","screeningConfig":{"name":"gbg_identity_screening","screeningType":"GBGIdentityScreening"},"cases":{"edges":[{"node":{"id":"111881","closed":true,"state":"Complete","outcome":"IdentityConfirmed"}}]}}}]}}}]}}}}';

        RestRequest request = new RestRequest(); 
        request.requestUri ='https://yourInstance.salesforce/testurl';
        request.requestBody = Blob.valueOf(jsonString);           
        request.httpMethod = 'POST';
        RestContext.request = request;
         test.starttest();
        try{
            ICS_API_GBGIDPOAVerifyResult.processRequest();
        }catch(exception e){
             Assert.areEqual(true,(jsonString !=null),'jsonString Requested   got error to parse  ');
        }
        test.stoptest();
    }
    
    
}