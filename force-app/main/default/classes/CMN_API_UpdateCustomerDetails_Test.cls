/**
 * @description       : Test class for MN_API_UpdateCustomerDetails 
 * @author            : Muvhuso Nekhubvi
 * @group             : PPB
 * @last modified on  : January 2026
**/

@SuppressWarnings('PMD.Integration_to_use_API_Framework_Two')
@isTest(seeAllData=false)
private class CMN_API_UpdateCustomerDetails_Test {

    @IsTest
    static void test_successful_update() {
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new UpdateCustomerAECodeMockResponse());

        Test.startTest();
        CMN_API_UpdateCustomerDetails cmn = new CMN_API_UpdateCustomerDetails();
        CMN_DTO_CustomerRMChangeResponse response = cmn.updateCustomeRM('0046X17', '45537a43-7a37-40f7-00000ab6f52b');     
        Test.stopTest();
        Assert.areNotEqual(null, response, 'Response object should not be null');

    }
    
    
	@IsTest
	static void test_update_api_error_response() {

    	sbgplatform.ApiService.setMock(
        	HttpCalloutMock.class,
        	new UpdateCustomerEmptyBodyMockResponse()
    	);

    	Test.startTest();
    		CMN_API_UpdateCustomerDetails cmn = new CMN_API_UpdateCustomerDetails();
    		CMN_DTO_CustomerRMChangeResponse response = cmn.updateCustomeRM('0046X17', '45537a43-7a37-40f7-00000ab6f52b');
    	Test.stopTest();

    	Assert.areEqual(null, response,'Response should be null when API returns non-200 status');
    } 

    
    /**
     * @description mocks a response returned from the update customer API API
     */
    public class UpdateCustomerAECodeMockResponse implements HttpCalloutMock {

        /**
         * @description Inner Method for Mock Class
         * @param request HTTP Request Object
         * @return HttpResponse response
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(sbgplatform.ApiService.HTTP_OK);
           
			response.setBody('{ "customer": {'
        		+ '  "uuid": "45537a43-7a37-40f7-0000-00000ab6f52b",'
        		+ '  "customer_type": "1",'
        		+ '  "customer_typeX": "INDIVIDUAL",'
        		+ '  "residenceCountry": "ZA",'
        		+ '  "relManager": "0046X18",'
        		+ '  "personDetails": {'
        		+ '      "firstName": "STATHAM",'
        		+ '      "lastName": "JASON",'
        		+ '      "initials": "S",'
        		+ '      "dob": "1985-06-13",'
        		+ '      "gender": "1",'
        		+ '      "genderX": "MALE",'
        		+ '      "title": "041",'
        		+ '      "titleX": "MR",'
        		+ '      "maritalStatus": "2",'
        		+ '      "maritalStatusX": "MARRIED",'
        		+ '      "citizenshipCountry": "ZA",'
        		+ '      "nationality": "ZA",'
        		+ '      "countryOfBirth": "ZA",'
        		+ '      "homeOwnership": "12",'
        		+ '      "homeOwnershipX": "OTHER",'
        		+ '      "qualification": "0100",'
        		+ '      "qualificationX": "COMM",'
        		+ '      "maritalPropertyRegime": "W",'
        		+ '      "maritalPropertyRegimeX": "COMMON LAW SPOUSE"'
        		+ '  },'
        		+ '  "compliance": ['
        		+ '       { "compRole": "02", "compRoleX": "CUSTOMER", "complianceStatus": "N", "complianceStatusX": "OUTSTANDING", "verifiedBy": "KYC_ENGINE" }'
        		+ '  ]'
        		+ '} }');
        	return response;
        }
    }
    
    
	public class UpdateCustomerEmptyBodyMockResponse implements HttpCalloutMock {
    	public HttpResponse respond(HttpRequest request) {
        	HttpResponse response = new HttpResponse();
        	response.setStatusCode(200);
        	response.setBody('');

        	return response;
    	}
	}

}