/***************************************************************************************
@name of the Class : ICS_CTRL_ContinueWithApplicationEmail.cls
@Story:SFP-34724
@description :class used as controller for  SBO-UK Communication Feature to Send emails details
@author : Ridhima Saxena
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 26-08-2024
@modification description: Updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_ContinueWithApplicationEmail {
    private ICS_CTRL_ContinueWithApplicationEmail() {

    }
     /**
     * @description This method is used to query a list of email template
     * @param partyProfileList
     */
    @InvocableMethod
    public static void queryEmailTemplate(List<String> partyProfileList) {

        Ics_CustomLabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Ics_CustomLabel__mdt portalUrlData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('SBOAccountOnboardingPortalUrl');
        Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
        Map<String, Object> portalInfor = (Map<String, Object>) JSON.deserializeUntyped(portalUrlData.Description__c);
        EmailTemplate template = [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = :labelInfo.get('ContinueWithApplicationTemplate')];
        SEL_PartyProfile partyProfileRecord = new SEL_PartyProfile();
        PartyProfile pp = partyProfileRecord.selectById(partyProfileList[0]);
        SEL_Account accRecord = new SEL_Account();
        Account acc = accRecord.selectById(pp.AccountId);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE Address=:labelInfo.get('isleOfManOrgWideAddress')];
        message.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
        message.setTargetObjectId(acc.PersonContactId);
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        String emailHtmlBody = template.HtmlValue;
        String portalUrl = (String)portalInfor.get('link');
        portalUrl += 'dashboard';
        emailHtmlBody = emailHtmlBody.replace('{{{Account.Name}}}',acc.Name);
        emailHtmlBody = emailHtmlBody.replace('here', '<a href="' + portalUrl + '"> here </a>');

        String emailSubject = template.Subject;
        message.setHtmlBody(emailHtmlBody);
        message.setTemplateId(template.Id);
        message.setWhatId(acc.Id);
        message.setSubject(emailSubject);
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
        Messaging.sendEmail(messages);
    }
}