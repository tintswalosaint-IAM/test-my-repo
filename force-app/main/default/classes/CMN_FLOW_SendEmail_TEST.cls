/*------------------------------------------------------------
Author:        Accenture
Company:       Standard Bank
Description:   Test class for CMN_FLOW_SendEmail
Test Class:    CMN_FLOW_SendEmail_TEST

History
<Date>         <Authors Name>     <Brief Description of Change>
March 2021     Accenture          Initial Version
09-02-2026     Raymond Magezi     Updated to test caching methods and improve coverage
------------------------------------------------------------*/
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_SendEmail_TEST
{
	/*------------------------------------------------------------
	 Purpose:    Create required data for the unit test
	------------------------------------------------------------*/
	@TestSetup
	private static void setup()
	{
		Contact newContact = CMN_DAL_DataFactory.newContact();
		CMN_DAL_SObjectDomain.insertDBObject(newContact);

		Case newCase = CMN_DAL_DataFactory.newCase(newContact.Id);
		CMN_DAL_SObjectDomain.insertDBObject(newCase);
	}

	/*------------------------------------------------------------
	 Purpose:    Contains the base code required to run each test with variants in parameter list
	 Parameters: toAddress - The address to send email to
	             whatId - The Id to which email should be related
	             ccAddress - Optional CC addresses
	             fileIds - Optional file attachments
	 Returns:    List of email send responses
	------------------------------------------------------------*/
	private static List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> runTest(String toAddress, Id whatId, List<String> ccAddress, List<Id> fileIds)
	{
		CMN_FLOW_SendEmail.DTO_SendEmailRequest dtoEmail = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();

		dtoEmail.toAddress = toAddress;
		dtoEmail.whatId = whatId;
		dtoEmail.ccAddress = ccAddress;
		dtoEmail.fileIds = fileIds;
		dtoEmail.orgWideEmailAddress = null;
		dtoEmail.templateUniqueName = [
				SELECT Id,
						DeveloperName
				FROM EmailTemplate
				LIMIT 1
		].DeveloperName;

		Test.startTest();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = CMN_FLOW_SendEmail.sendEmail(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> {dtoEmail});

		Test.stopTest();

		return dtoResponses;
	}

	/*------------------------------------------------------------
	 Purpose:    Check to see an email would have successfully been sent using contactId in the toAddress field
	------------------------------------------------------------*/
	@IsTest
	private static void sendMailSuccessfullyUsingContactId()
	{
		Contact newContact = CMN_DAL_Contact.getAll().iterator().next();
		Case newCase = CMN_DAL_Case.getAll().iterator().next();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Id, newCase.Id, null, null);

		Assert.isTrue(dtoResponses.iterator().next().success, 'Send Email Failed: ' + dtoResponses.iterator().next().errors);
	}

	/*------------------------------------------------------------
	 Purpose:    Check to see an email would have successfully been sent using an email in the toAddress field
	------------------------------------------------------------*/
	@IsTest
	private static void sendMailSuccessfullyUsingEmailAddress()
	{
		Contact newContact = CMN_DAL_Contact.getAll().iterator().next();
		Case newCase = CMN_DAL_Case.getAll().iterator().next();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Email, newCase.Id, null, null);

		Assert.isTrue(dtoResponses.iterator().next().success, 'Send Email Failed: ' + dtoResponses.iterator().next().errors);
	}

	/*------------------------------------------------------------
	 Purpose:    Will Test that an error is reported for putting invalid Id into targetObjectId
	------------------------------------------------------------*/
	@IsTest
	private static void failedSendMailInvalidTargetObjectId()
	{
		Case newCase = CMN_DAL_Case.getAll().iterator().next();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newCase.Id, newCase.Id, null, null);

		Assert.isFalse(dtoResponses.iterator().next().success, 'Send did not fail as expected');
	}

	/*------------------------------------------------------------
	 Purpose:    Test sending email with CC addresses
	------------------------------------------------------------*/
	@IsTest
	private static void sendMailWithCcAddress()
	{
		Contact newContact = CMN_DAL_Contact.getAll().iterator().next();
		Case newCase = CMN_DAL_Case.getAll().iterator().next();
		List<String> ccAddresses = new List<String>{newContact.Email};

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Id, newCase.Id, ccAddresses, null);

		Assert.isTrue(dtoResponses.iterator().next().success, 'Send Email with CC Failed');
	}

	/*------------------------------------------------------------
	 Purpose:    Test caching by sending multiple emails with same template
	------------------------------------------------------------*/
	@IsTest
	private static void testCachingMultipleEmails()
	{
		Contact newContact = CMN_DAL_Contact.getAll().iterator().next();
		Case newCase = CMN_DAL_Case.getAll().iterator().next();

		String templateName = [
				SELECT DeveloperName
				FROM EmailTemplate
				LIMIT 1
		].DeveloperName;
		String orgWideEmail = null;

		List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> requests = new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest>();

		for(Integer i = 0; i < 3; i++)
		{
			CMN_FLOW_SendEmail.DTO_SendEmailRequest dtoEmail = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();
			dtoEmail.toAddress = newContact.Email;
			dtoEmail.whatId = newCase.Id;
			dtoEmail.templateUniqueName = templateName;
			dtoEmail.orgWideEmailAddress = orgWideEmail;
			requests.add(dtoEmail);
		}

		Test.startTest();

		List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = CMN_FLOW_SendEmail.sendEmail(requests);

		Test.stopTest();

		Assert.areEqual(3, dtoResponses.size(), 'Should return 3 responses');
		for(CMN_FLOW_SendEmail.DTO_SendEmailResponse response : dtoResponses)
		{
			Assert.isTrue(response.success, 'All emails should succeed');
		}
	}
}