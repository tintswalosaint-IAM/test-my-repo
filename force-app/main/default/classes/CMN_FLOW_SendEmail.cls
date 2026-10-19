/*------------------------------------------------------------
Author:        Accenture
Company:       Standard Bank
Description:   Invokable method for sending emails from Flow with activity logging.
               Allows email sending where activity logging is required.
Test Class:    CMN_FLOW_SendEmail_TEST

History
<Date>         <Authors Name>     <Brief Description of Change>
27-03-2025     Muriuki Gatuguti   SFP-47723 - Set signature to false when sending emails
04-02-2026     Raymond Magezi     Added static caching to reduce SOQL queries
------------------------------------------------------------*/
public without sharing class CMN_FLOW_SendEmail
{
	private static Map<String, EmailTemplate> templateCache = new Map<String, EmailTemplate>();
	private static Map<String, OrgWideEmailAddress> orgWideEmailCache = new Map<String, OrgWideEmailAddress>();

	private CMN_FLOW_SendEmail() {}

	/*------------------------------------------------------------
	 Purpose:    Sends emails based on variables received and saves as Activity in feed
	 Parameters: dtoEmails - List of email request DTOs to be processed
	 Returns:    List of DTO_SendEmailResponse indicating success/failure for each email
	------------------------------------------------------------*/
	@InvocableMethod(Label='Send Email and Log an Activity' Description='Will use the SingleEmailMessage class to send an email with a template and ensure activity is logged')
	public static List<DTO_SendEmailResponse> sendEmail(List<DTO_SendEmailRequest> dtoEmails)
	{
		cacheTemplatesAndOrgWideEmails(dtoEmails);
		List<Messaging.SingleEmailMessage> mailsToSend = buildEmailMessages(dtoEmails);
		List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(mailsToSend, false);
		return processEmailResults(sendEmailResults);
	}

	/*------------------------------------------------------------
	 Purpose:    Caches uncached templates and org-wide email addresses
	 Parameters: dtoEmails - List of email requests
	------------------------------------------------------------*/
	private static void cacheTemplatesAndOrgWideEmails(List<DTO_SendEmailRequest> dtoEmails)
	{
		Set<String> templateNames = new Set<String>();
		Set<String> orgWideEmailAddresses = new Set<String>();

		for(DTO_SendEmailRequest dtoEmail : dtoEmails)
		{
			if (!templateCache.containsKey(dtoEmail.templateUniqueName)) {
				templateNames.add(dtoEmail.templateUniqueName);
			}
			if (!orgWideEmailCache.containsKey(dtoEmail.orgWideEmailAddress)) {
				orgWideEmailAddresses.add(dtoEmail.orgWideEmailAddress);
			}
		}

		if (!templateNames.isEmpty()) {
			for (EmailTemplate et : CMN_DAL_EmailTemplate.findByName(templateNames)) {
				templateCache.put(et.DeveloperName, et);
			}
		}

		if (!orgWideEmailAddresses.isEmpty()) {
			for (OrgWideEmailAddress owa : CMN_DAL_OrgWideEmailAddress.findByName(orgWideEmailAddresses)) {
				orgWideEmailCache.put(owa.Address, owa);
			}
		}
	}

	/*------------------------------------------------------------
	 Purpose:    Builds email messages from request DTOs
	 Parameters: dtoEmails - List of email requests
	 Returns:    List of SingleEmailMessage objects
	------------------------------------------------------------*/
	private static List<Messaging.SingleEmailMessage> buildEmailMessages(List<DTO_SendEmailRequest> dtoEmails)
	{
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

		for(DTO_SendEmailRequest dtoEmail : dtoEmails)
		{
			Messaging.SingleEmailMessage rendered = Messaging.renderStoredEmailTemplate(templateCache.get(dtoEmail.templateUniqueName)?.Id, null, dtoEmail.whatId, Messaging.AttachmentRetrievalOption.METADATA_ONLY);
			Messaging.SingleEmailMessage newMail = new Messaging.SingleEmailMessage();
			newMail.setSubject(rendered.getSubject());
			newMail.setHtmlBody(rendered.getHtmlBody());
			newMail.setPlainTextBody(rendered.getPlainTextBody());
			newMail.setWhatId(dtoEmail.whatId);
			newMail.setToAddresses(new List<String> {dtoEmail.toAddress});
			if (dtoEmail.ccAddress != null && !dtoEmail.ccAddress.isEmpty()) {
				newMail.setCcAddresses(dtoEmail.ccAddress);
			}
			newMail.setOrgWideEmailAddressId(orgWideEmailCache.get(dtoEmail.orgWideEmailAddress)?.Id);
			newMail.setSaveAsActivity(true);
			newMail.setUseSignature(false);

			if(dtoEmail.fileIds != null)
			{
				newMail.setEntityAttachments(dtoEmail.fileIds);
			}

			mailsToSend.add(newMail);
		}

		return mailsToSend;
	}

	/*------------------------------------------------------------
	 Purpose:    Processes email send results and logs errors
	 Parameters: sendEmailResults - Results from Messaging.sendEmail
	 Returns:    List of DTO_SendEmailResponse
	------------------------------------------------------------*/
	private static List<DTO_SendEmailResponse> processEmailResults(List<Messaging.SendEmailResult> sendEmailResults)
	{
		List<DTO_SendEmailResponse> dtoResponses = new List<DTO_SendEmailResponse>();

		for(Messaging.SendEmailResult sendEmailResult : sendEmailResults)
		{
			DTO_SendEmailResponse dtoResponse = new DTO_SendEmailResponse();
			dtoResponse.success = sendEmailResult.success;

			if(!sendEmailResult.success)
			{
				dtoResponse.errors = buildErrorMessage(sendEmailResult.errors);
			}

			dtoResponses.add(dtoResponse);
		}

		return dtoResponses;
	}

	/*------------------------------------------------------------
	 Purpose:    Builds error message from send email errors
	 Parameters: sendEmailErrors - List of errors from send result
	 Returns:    Concatenated error message string
	------------------------------------------------------------*/
	private static String buildErrorMessage(List<Messaging.SendEmailError> sendEmailErrors)
	{
		String errors = CMN_UTIL_String.EMPTY;

		for(Messaging.SendEmailError sendEmailError : sendEmailErrors)
		{
			errors = String.isBlank(errors) ? errors + sendEmailError.message : errors + CMN_UTIL_String.LF + sendEmailError.message;
			CMN_UTIL_Logger.error(sendEmailError.message, 'CMN_FLOW_SendEmail/sendEmail');
		}

		return errors;
	}

	/**
	 * @description DTO to initiate a send email request
	 */
	public class DTO_SendEmailRequest
	{
		/**
		 * @description A list of email addresses or object IDs of contacts, leads, and users
		 * you're sending the email to. Max size: 4,000 bytes. Max total of toAddresses,
		 * ccAddresses, and bccAddresses per email is 150.
		 * All recipients in these three fields count against the limit for email sent using Apex or the API.
		 */
		@InvocableVariable(Label='To Address' Description='The ID of the contact, lead, or user to which the email will be sent. The ID you specify sets the context and ensures that merge fields in the template contain the correct data. If no ID is available send the email address of the recipient' Required=false)
		public String toAddress;

		@InvocableVariable(Label='CC Address' Description='The ID of the contact, lead, or user to which the email will be sent in cc.' Required=false)
		public List<String> ccAddress;

		@InvocableVariable(Label='Template Unique Name' Description='The unique name of the template that will be used to generate the email' Required=true)
		public String templateUniqueName;

		@InvocableVariable(Label='Org Wide Email Address' Description='Will define the org wide email address to use as the from for the email' Required=true)
		public String orgWideEmailAddress;

		/**
		 * @description If you specify a contact for the targetObjectId field, you can specify
		 * an optional whatId as well. This helps to further ensure that merge fields in the
		 * template contain the correct data.
		 * <p/>
		 * The value must be one of the following types:
		 * Account
		 * Asset
		 * Campaign
		 * Case
		 * Contract
		 * Opportunity
		 * Order
		 * Product
		 * Solution
		 * Custom
		 */
		@InvocableVariable(Label='Related To ID' Description='An Object Id that can be related the email' Required=true)
		public Id whatId;

		@InvocableVariable(Label='List of Attachment Identifiers' Description='List of Attachment Identifiers to add Files as attachments to the email' Required=false)
		public List<Id> fileIds;
	}

	public class DTO_SendEmailResponse
	{
		@InvocableVariable(Label='Send Successful' Description='Indicates whether the email was successfully submitted for delivery (true) or not (false). Even if isSuccess is true, it does not mean the intended recipients received the email, as there could have been a problem with the email address or it could have bounced or been blocked by a spam blocker.' Required=true)
		public Boolean success;
		@InvocableVariable(Label='Errors' Description='A List of errors encountered when attempting to do the send email' Required=false)
		public String errors;
	}
}