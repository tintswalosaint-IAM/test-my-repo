public without sharing class ICS_CTRL_DeclinedApplicantEmail {
    private ICS_CTRL_DeclinedApplicantEmail() { }

    /**
    * @description This method is used to query a list of email template
    * @param oppList
    */
    @InvocableMethod(label='MLRO Declined Opportunity' description='Send Email to MLRO User when Opportunity got declined' category='Opportunity')
    public static void queryEmailTemplate(List<String> oppList) {
        if (oppList.isEmpty()) {
            return;
        } 
        
        EmailTemplateData templateData = getEmailTemplateData();
        Opportunity opp = new SEL_Opportunity().selectById(oppList[0]);
        List<PartyScreeningSummary> sanctionedPSS = getSanctionedPartyScreeningSummaries(oppList[0]);

        // Collect all OrgWideEmailAddress IDs in one query
        List<OrgWideEmailAddress> lstEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :templateData.isleOfManAddress];
        String orgWideEmailId = lstEmailAddress.isEmpty() ? null : lstEmailAddress[0].Id;

        // Send emails for sanctioned PartyScreeningSummary records
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        for (PartyScreeningSummary pss : sanctionedPSS) {
            if (pss.IsSanctioned__c) {
                Messaging.SingleEmailMessage message = prepareEmail(templateData, opp, pss, orgWideEmailId);
                emailsToSend.add(message);
            }
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
        }
    }

    private static EmailTemplateData getEmailTemplateData() {
        Ics_CustomLabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
        EmailTemplate template = [SELECT Id, Name, Subject, Body, HtmlValue FROM EmailTemplate
                                  WHERE Name = :labelInfo.get('DeclinedApplicantAlertTemplate')];
        
        return new EmailTemplateData(template, labelInfo.get('mlroOrgWideAddress'), labelInfo.get('isleOfManOrgWideAddress'));
    }
    
    private static List<PartyScreeningSummary> getSanctionedPartyScreeningSummaries(String opportunityId) {
        Set<Id> relatedAccountIds = new Set<Id>();
        for (Applicationform app : new SEL_ApplicationForm().selectByOpportunityId(opportunityId)) {
            relatedAccountIds.add(app.AccountId);
        }
        
        Set<Id> relatedProfileIds = new Set<Id>();
        for (PartyProfile profile : new SEL_PartyProfile().selectByAccountIds(relatedAccountIds)) {
            if (profile.WorldcheckStatus__c == 'Match Confirmed - True match declined') {
                relatedProfileIds.add(profile.Id);
            }
        }
        
        return new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(relatedProfileIds);
    }

    private static Messaging.SingleEmailMessage prepareEmail(EmailTemplateData templateData, Opportunity opp, PartyScreeningSummary pss, String orgWideEmailId) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        
        String emailBody = templateData.template.HtmlValue;
        emailBody = replaceEmailPlaceholders(emailBody, opp, pss);
        
        if (orgWideEmailId != null) {
            message.setOrgWideEmailAddressId(orgWideEmailId); // Set the Org-Wide Email Address
        }
        message.setHtmlBody(emailBody);
        message.setSubject(templateData.template.Subject);
        message.setToAddresses(new String[] { templateData.mlroOrgWideAddress});
        
        return message;
    }
    
    private static String replaceEmailPlaceholders(String emailBody, Opportunity opp, PartyScreeningSummary pss) {
        Map<String, String> replacements = new Map<String, String>{
            '{{{Identity.Name}}}' => getPrimaryIdentifier(pss),
            '{{{Account.Name}}}' => getAccountName(pss),
            '{{{PartyProfile.RelatedPartyProfile}}}' => getPartyProfileId(pss),
            '{{{PartyScreeningSummary.RequestCompletionDate}}}' => getFormattedDate(pss.RequestCompletionDate),
            '{{{Opportunity.OwnerName}}}' => getOpportunityOwnerName(opp),
            '{{{PartyScreeningSummary.IsWatchlist__c}}}' => getBooleanValue(pss.IsWatchlist__c),
            '{{{PartyScreeningSummary.IsUncategorised__c}}}' => getBooleanValue(pss.IsUncategorised__c),
            '{{{PartyScreeningSummary.IsPEP__c}}}' => getBooleanValue(pss.IsPEP__c),
            '{{{PartyScreeningSummary.IsBlacklist__c}}}' => getBooleanValue(pss.IsBlacklist__c),
            '{{{PartyScreeningSummary.IsAdverseMedia__c}}}' => getBooleanValue(pss.IsAdverseMedia__c),
            '{{{PartyScreeningSummary.CategoryDescription__c}}}' => getStringValue(pss.CategoryDescription__c)
        };

        for (String key : replacements.keySet()) {
            emailBody = emailBody.replace(key, replacements.get(key));
        }

        return emailBody;
    }
    
    private static String getPrimaryIdentifier(PartyScreeningSummary pss) {
        return pss == null || pss.PartyProfile == null || pss.PartyProfile.PrimaryIdentifier == null ? '' : pss.PartyProfile.PrimaryIdentifier;
    }

    private static String getAccountName(PartyScreeningSummary pss) {
        return pss == null || pss.PartyProfile == null || pss.PartyProfile.Account == null ? '' : pss.PartyProfile.Account.Name;
    }

    private static String getPartyProfileId(PartyScreeningSummary pss) {
        return pss == null || pss.PartyProfileId == null ? '' : pss.PartyProfileId;
    }

    private static String getFormattedDate(DateTime dt) {
        return dt == null ? '' : dt.format();
    }

    private static String getOpportunityOwnerName(Opportunity opp) {
        return opp == null || opp.Owner == null ? '' : opp.Owner.Name;
    }

    private static String getBooleanValue(Boolean value) {
        return value == null ? '' : String.valueOf(value);
    }

    private static String getStringValue(String value) {
        return value == null ? '' : value;
    }

    private class EmailTemplateData {
        public EmailTemplate template;
        public String mlroOrgWideAddress;
        public String isleOfManAddress;
        
        public EmailTemplateData(EmailTemplate template, String mlroOrgWideAddress, String isleOfManAddress) {
            this.template = template;
            this.mlroOrgWideAddress = mlroOrgWideAddress;
            this.isleOfManAddress = isleOfManAddress;       
        }
    }
}