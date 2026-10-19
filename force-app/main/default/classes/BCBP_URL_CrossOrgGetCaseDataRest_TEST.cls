/***************************************************************************************
@Name of the Component : BCBP_URL_CrossOrgGetCaseDataRest_TEST
@Description : Test class for BCBP_URL_CrossOrgGetCaseDataRest
@Author : Siarhei Maroz
@Created Date : 17 July 2025
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 29 July 2025
@Modification description: this class was created to test coverage of methods for BCBP_URL_CrossOrgGetCaseDataRest class
 User Story: BCBSFSA-290 | BCBSFSA-291
/***************************************************************************************
@Last Modified By : Siarhei Maroz
@Last Modified On : 06 October 2025
@Modification description: added test method for addCaseComment
 User Story: BCBSFSA-429 | BCBSFSA-641
***************************************************************************************/
@IsTest(SeeAllData=false)
private class BCBP_URL_CrossOrgGetCaseDataRest_TEST {

	//variable for keeping case subjects for test cases
	private static final String CASE_SUBJECT = 'Test Case';
	//variable for keeping email address for test cases
	private static final String SUPPLIED_EMAIL = 'test@test.com';

	private static final String REQUEST_URL = '/services/apexrest/crossOrgGetCaseData/';
	private static final String METHOD_PUT = 'PUT';
	private static final String METHOD_GET = 'GET';

	/**
    * @description Test method for BCBP_URL_CrossOrgGetCaseDataRest.getCase
    */
	@isTest
	private static void testGetCase() {
		Case newCase = new Case(
				Subject = CASE_SUBJECT,
				SuppliedEmail = SUPPLIED_EMAIL
		);
		insert newCase;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = REQUEST_URL + newCase.Id; //Request URL
		req.httpMethod = METHOD_GET;

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			BCBP_DTO_CaseResponse caseResponse = BCBP_URL_CrossOrgGetCaseDataRest.getCase();
		Test.stopTest();

		Assert.areEqual(caseResponse.message, 'Case retrieved successfully', 'Failed to retrieve case: Error ');
	}
    
    /**
    * @description Test method for checking failure behavior of BCBP_URL_CrossOrgGetCaseDataRest.addCaseComment
    */
	@isTest
	private static void testAddCaseCommentFailure() {
		Case newCase = new Case(
				Subject = CASE_SUBJECT,
				SuppliedEmail = SUPPLIED_EMAIL
		);
		insert newCase;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = REQUEST_URL; //Request URL
		req.httpMethod = METHOD_PUT;

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
		BCBP_DTO_CaseResponse caseResponse = BCBP_URL_CrossOrgGetCaseDataRest.addCaseComment();
		Test.stopTest();

		Assert.areNotEqual(caseResponse.message, 'Case updated successfully', 'Failed to update case: Error ');
	}

	/**
    * @description Test method for checking failure behavior of BCBP_URL_CrossOrgGetCaseDataRest.getCase
    */
	@isTest
	private static void testGetCaseFailure() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = REQUEST_URL; //Request URL
		req.httpMethod = METHOD_GET;

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			BCBP_DTO_CaseResponse caseResponse = BCBP_URL_CrossOrgGetCaseDataRest.getCase();
		Test.stopTest();

		Assert.areNotEqual(caseResponse.message, 'Case retrieved successfully', 'Failed to retrieve case: Error ');
	}
    
    /**
    * @description Test method for BCBP_URL_CrossOrgGetCaseDataRest.addCaseComment
    */
	@isTest
	private static void testAddCaseComment() {
		Case newCase = new Case(
				Subject = CASE_SUBJECT,
				SuppliedEmail = SUPPLIED_EMAIL
		);
		insert newCase;

		BCBP_DTO_CaseRequest caseData = new BCBP_DTO_CaseRequest();
		caseData.id = newCase.Id;
		caseData.Description = 'Test Comment';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = REQUEST_URL; //Request URL
		req.httpMethod = METHOD_PUT;
		req.requestBody = Blob.valueOf(JSON.serialize(caseData));

		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
		BCBP_DTO_CaseResponse caseResponse = BCBP_URL_CrossOrgGetCaseDataRest.addCaseComment();
		Test.stopTest();

		Assert.areEqual(caseResponse.message, 'Case updated successfully', 'Failed to update case: Error ');
	}
}