/***************************************************************************************
@Name of the Component : BCBP_URL_CrossOrgCasesRest_TEST
@Description : Test class for BCBP_URL_CrossOrgCasesRest
@Author : Siarhei Maroz
@Created Date : 17 July 2025
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 29 July 2025
@Modification description: this class was created to test coverage of methods for BCBP_URL_CrossOrgCasesRest class
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 06 October 2025
@Modification description: removed BCBP_DTO_CaseRequest type to separated class
 User Story: BCBSFSA-429 | BCBSFSA-641
***************************************************************************************/
@IsTest(SeeAllData=false)
private class BCBP_URL_CrossOrgCasesRest_TEST {

	//variable for keeping case subjects for test cases
	private static final String CASE_SUBJECT = 'Test Case';
	//variable for keeping email address for test cases
	private static final String SUPPLIED_EMAIL = 'test@test.com';

	/**
    * @description Test method for BCBP_URL_CrossOrgCasesRest.createCase
    */
	@isTest
	private static void testCreateCase() {

		BCBP_DTO_CaseRequest caseRequest = new BCBP_DTO_CaseRequest();
		caseRequest.subject = CASE_SUBJECT;
		caseRequest.email = SUPPLIED_EMAIL;
		caseRequest.customFields = new Map<String, Object>();

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/crossOrgCases'; //Request URL
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(JSON.serialize(caseRequest));

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			BCBP_DTO_CaseResponse caseResponse = BCBP_URL_CrossOrgCasesRest.createCase();
		Test.stopTest();

		Assert.areEqual(caseResponse.message, 'Case created successfully', 'Case created successfully');
	}

	/**
    * @description Test method for checking failure behavior of BCBP_URL_CrossOrgCasesRest.createCase
    */
	@isTest
	private static void testCreateCaseFailure() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/crossOrgCases'; //Request URL
		req.httpMethod = 'POST';

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			BCBP_DTO_CaseResponse caseResponse = BCBP_URL_CrossOrgCasesRest.createCase();
		Test.stopTest();

		Assert.areEqual(caseResponse.message, 'Failed to create case: Argument cannot be null.', 'Error: Failed to create case: Argument cannot be null.');
	}

	/**
    * @description Test method for BCBP_URL_CrossOrgCasesRest.getCasesBySuppliedEmail
    */
	@isTest
	private static void testGetCasesBySuppliedEmail() {
		Case newCase = new Case(
			Subject = CASE_SUBJECT,
			SuppliedEmail = SUPPLIED_EMAIL
		);
		insert newCase;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/crossOrgCases/' + newCase.SuppliedEmail; //Request URL
		req.httpMethod = 'GET';

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			List<BCBP_DTO_CaseResponse> caseResponseList = BCBP_URL_CrossOrgCasesRest.getCasesBySuppliedEmail();
		Test.stopTest();

		Assert.areEqual(caseResponseList[0].message, 'Case retrieved successfully', 'Case retrieved successfully');
	}

	/**
    * @description Test method for checking failure behavior of BCBP_URL_CrossOrgCasesRest.getCasesBySuppliedEmail
    */
	@isTest
	private static void testGetCasesBySuppliedEmailFailure() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/services/apexrest/crossOrgCases/'; //Request URL
		req.httpMethod = 'GET';

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			List<BCBP_DTO_CaseResponse> caseResponseList = BCBP_URL_CrossOrgCasesRest.getCasesBySuppliedEmail();
		Test.stopTest();

		Assert.areEqual(caseResponseList[0].message, 'Failed to retrieve cases: Email parameter is required', 'Error: Failed to retrieve cases: Email parameter is required');
	}
}