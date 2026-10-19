/*************************************************************
* @description SFP-51505 Class used to Send Emails
*
* @autor Ruchi Agarwal
*
* @date OCT 21 2024
***************************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 28/8/2025
* Last Modified Description: updated to latest Version
*/

public without sharing class ICS_CTRL_SeafererSendEmail {
    private ICS_CTRL_SeafererSendEmail() { }
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_PingVerificationEmail');

    /**
     * @description This method is used to query a list of email templates
     * @param accountId
     */
    @future(callout=true)
    public static void sendEmail(String accountId) {
        try {
            // Fetch email templates and URLs
            Ics_CustomLabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
            Ics_CustomLabel__mdt portalUrlData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('SBOAccountOnboardingPortalUrl');
            Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
            Map<String, Object> portalInfor = (Map<String, Object>) JSON.deserializeUntyped(portalUrlData.Description__c);

            // Fetch the first email template (Seaferer Account Email)
            EmailTemplate template = [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = :labelInfo.get('SeafererAccount')];
            
            // Fetch Opportunity and Account data
            SEL_Account accRecord = new SEL_Account();
            Account acc = accRecord.selectById(accountId);
            
            // Fetch application form for the opportunity
            ApplicationForm apf = [SELECT Id, opportunityId FROM ApplicationForm WHERE accountId = :accountId];
            SEL_Opportunity opp = new SEL_Opportunity();
            Opportunity oppRec = opp.selectById(apf.opportunityId);

            // Check remaining email invocations allowed
            Integer maxEmailsAllowed = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations();
            if (maxEmailsAllowed > 0) {
                // Prepare the main email message
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                List<OrgWideEmailAddress> lstEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :labelInfo.get('seafererOrgWideAddress')];
                if (!lstEmailAddress.isEmpty()) {
                    message.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
                }

                // Attach document to email
                 List<ContentDocument> contentDocs = [SELECT Id, Title, ContentSize, FileExtension 
                                   FROM ContentDocument 
                                   WHERE Title LIKE '%Seafarer%Factsheet%'];
                if (!contentDocs.isEmpty()) {
                // Get the latest version of the document
                List<ContentVersion> cvList = [SELECT VersionData, FileExtension 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId = :contentDocs[0].Id 
                                             AND IsLatest = true];
                    if (!cvList.isEmpty()) {
                        Blob fileData = cvList[0].VersionData;
                        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                        emlAtt.setFilename('Seafarer Factsheet.' + cvList[0].FileExtension);
                        emlAtt.setBody(fileData);
                        message.setFileAttachments(new Messaging.EmailFileAttachment[] { emlAtt });
                    }
                }

                // Set email body, subject, and other properties
                String emailHtmlBody = template.HtmlValue;
                String portalUrl = (String)portalInfor.get('link') + '?id=' + apf.Id;
                emailHtmlBody = emailHtmlBody.replace('{{{Account.Name}}}', acc.Name);
                emailHtmlBody = emailHtmlBody.replace('{{{Owner.Email}}}', oppRec.Owner.Email);
                emailHtmlBody = emailHtmlBody.replace('here', '<a href="' + portalUrl + '"> here </a>');
                message.setHtmlBody(emailHtmlBody);
                message.setTemplateId(template.Id);
                message.setToAddresses(new List<String>{acc.PersonEmail});
                message.setSubject(template.Subject);
                
                // Send email
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});        

            
            } else {
                Logger.error('Email sending limit reached. Cannot send more emails in this transaction.');
            }
        } catch (Exception e) {
            Logger.error('Error sending email: ' + e.getMessage());
        }
    }

    /**
     * @description Public method to send ID verification email - callable from LWC
     * @param accountId - The account ID to send email to
     */
    public static String sendIDVerificationEmail(String accountId) {
        try {
            // Call the future method to handle the actual email sending
            sendIDVerificationEmailFuture(accountId);
            return 'Email sending initiated successfully';
        } catch (Exception e) {
            LOGGER.error('Error initiating ID verification email: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }

    /**
     * @description Future method to handle ID verification email sending asynchronously
     * @param accountId - The account ID to send email to
     */
    @future(callout=true)
    public static void sendIDVerificationEmailFuture(String accountId) {
        try {
            // Fetch email templates and URLs
            Ics_CustomLabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
            Ics_CustomLabel__mdt portalUrlData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('SBOAccountOnboardingPortalUrl');
            Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
            Map<String, Object> portalInfor = (Map<String, Object>) JSON.deserializeUntyped(portalUrlData.Description__c);

            // Fetch Account data
            SEL_Account accRecord = new SEL_Account();
            Account acc = accRecord.selectById(accountId);
            
            // Fetch application form for the account
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
         List<ApplicationForm> applicationForm = selectorFormData.selectByAccountId(accountId);
            String portalUrl = (String)portalInfor.get('link') + '?id=' + applicationForm[0].Id;
            if(applicationForm[0].opportunity.Required_Approval_Processes__c != null && applicationForm[0].opportunity.Required_Approval_Processes__c.contains('Need Captain letter Approval;')
                        && !applicationForm[0].opportunity.Required_Approval_Processes__c.contains('Captain Letter Approval Confirmed;'+applicationForm[0].AccountId)
                            && applicationForm[0].AccountId ==  accountId) 
            {
            sendIDVerificationEmailInternal(acc, labelInfo, portalUrl);
            }
        } catch (Exception e) {
            LOGGER.error('Error sending ID verification email: ' + e.getMessage());
        }
    }

    /**
     * @description Internal method to handle the actual ID verification email sending logic
     * @param acc - Account record
     * @param labelInfo - Email template configuration
     * @param portalUrl - Portal URL for the email
     */
     private static void sendIDVerificationEmailInternal(Account acc, Map<String, String> labelInfo, String portalUrl) {
        Integer maxEmailsAllowed = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations();
        if (maxEmailsAllowed > 0) {
            EmailTemplate idVerificationTemplate = [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = :labelInfo.get('OnlineSeafererAccount')];
            
            Messaging.SingleEmailMessage idVerificationMessage = new Messaging.SingleEmailMessage();
            List<OrgWideEmailAddress> lstEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :labelInfo.get('seafererOrgWideAddress')];
            if (!lstEmailAddress.isEmpty()) {
                idVerificationMessage.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            }
            List<ContentDocument> cdlList = [SELECT Id, Title, ContentSize, FileExtension 
                                   FROM ContentDocument 
                                   WHERE Title LIKE '%Captain%Letter%' limit 1];
                if (!cdlList.isEmpty()) {
                    List<ContentVersion> cvList = [SELECT VersionData, FileExtension FROM ContentVersion WHERE ContentDocumentId = :cdlList[0].Id AND IsLatest = true];
                    if (!cvList.isEmpty()) {
                        Blob fileData = cvList[0].VersionData;
                        Messaging.EmailFileAttachment emlAtt = new Messaging.EmailFileAttachment();
                        emlAtt.setFilename('Captains Letter.' + cvList[0].FileExtension);
                        emlAtt.setBody(fileData);
                        idVerificationMessage.setFileAttachments(new Messaging.EmailFileAttachment[] { emlAtt });
                    }
                }
            idVerificationMessage.setTargetObjectId(acc.PersonContactId);
            idVerificationMessage.setUseSignature(false);
            idVerificationMessage.setBccSender(false);
            idVerificationMessage.setSaveAsActivity(false);
            
            // Set the body and subject for the second email
            String idVerificationEmailBody = idVerificationTemplate.HtmlValue;
            idVerificationEmailBody = idVerificationEmailBody.replace('{{{Account.Name}}}', acc.Name); 
            idVerificationEmailBody = idVerificationEmailBody.replace('{{{Owner.Email}}}', acc.Owner.Email); 
            idVerificationEmailBody = idVerificationEmailBody.replace('here', '<a href="' + portalUrl + '"> here </a>');  // Replace 'here' with link
            
            idVerificationMessage.setHtmlBody(idVerificationEmailBody);
            idVerificationMessage.setTemplateId(idVerificationTemplate.Id);
            idVerificationMessage.setToAddresses(new List<String>{acc.PersonEmail});
            idVerificationMessage.setSubject(idVerificationTemplate.Subject);
            
            // Send the second email
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{idVerificationMessage});
        } else {
            LOGGER.error('Email sending limit reached. Cannot send more emails in this transaction.');
        }
    }
}