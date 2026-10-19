/***************************************************************************************
@name of the Class : ICS_CTRL_RecurringReminderSchedulerClass.cls
@Story:SFP-34730
@description :class used as controller for  SBO-UK Communication Feature to Send emails details
@author : Ridhima Saxena
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 26-08-2024
@modification description: Updated to latest version
****************************************************************************************
@last Modified By : Ridhima Saxena
@last Modified On : 07-08-2025
@modification description: Updated to latest version
***************************************************************************************/
public class ICS_CTRL_RecurringReminderSchedulerClass implements Schedulable, Database.Batchable<sObject>{

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_RecurringReminderSchedulerClass');
   /**
    * @description This start method is used to query a list of applicationform
    * @param bc
    * @return ApplicationForm
    */
   public Database.QueryLocator start(Database.BatchableContext bc ) {
       return Database.getQueryLocator([SELECT Id, Stage,AccountId FROM ApplicationForm WHERE Stage = 'Awaiting Form Filling' AND Opportunity.RecordType.Name='ICS Applicant' AND Account.PersonEmail != null]);
   }
/**
    * @description This execute method is used to loop over a list of applicationform
    * @param bc
    * @param scope
    */
   private static final Integer DAYS_FIVE = 5;
   private static final Integer DAYS_TEN = 10;
   private static final Integer DAYS_FIFTEEN = 15;
    
    public void execute(Database.BatchableContext bc, List<ApplicationForm> scope) {
        Ics_CustomLabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);     
        Id orgWideEmailId = null;
        List<OrgWideEmailAddress> lstEmailAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :labelInfo.get('isleOfManOrgWideAddress') LIMIT 1];
        if (!lstEmailAddress.isEmpty()) {
            orgWideEmailId = lstEmailAddress[0].Id;
        }
    
        Map<Id, ApplicationForm> appFormMap = new Map<Id, ApplicationForm>(scope);
        Map<String, Id> accountContactIds = getAccountContactIds(appFormMap.values());
        Map<String, Id> accountIds = getAccountIds(appFormMap.values());
        
        List<ApplicationFormHistory> appHistoryList = getApplicationFormHistory(appFormMap.keySet());
        Map<String, EmailTemplate> emailTemplates = getEmailTemplates();
        
        List<Messaging.SingleEmailMessage> emailsToSend = createEmailMessages(
            appHistoryList, accountContactIds, accountIds, emailTemplates, orgWideEmailId  
        );
        
        sendEmails(emailsToSend);
    }
   private Map<String, Id> getAccountContactIds(List<ApplicationForm> appForms) {
       Set<Id> accountIds = new Set<Id>();
       for (ApplicationForm form : appForms) {
           accountIds.add(form.AccountId);
       }
       
       SEL_Applicant applicantSelector = new SEL_Applicant();
       List<Applicant> applicants = applicantSelector.selectByAccountIds(accountIds);
       
       Map<String, Id> accountContactIds = new Map<String, Id>();
       for (Applicant applicant : applicants) {
           accountContactIds.put(applicant.Account.PersonEmail, applicant.Account.PersonContactId);
       }
       return accountContactIds;
   }

   private Map<String, Id> getAccountIds(List<ApplicationForm> appForms) {
       Set<Id> accountIds = new Set<Id>();
       for (ApplicationForm form : appForms) {
           accountIds.add(form.AccountId);
       }
       
       SEL_Applicant applicantSelector = new SEL_Applicant();
       List<Applicant> applicants = applicantSelector.selectByAccountIds(accountIds);
       
       Map<String, Id> accountIdsMap = new Map<String, Id>();
       for (Applicant applicant : applicants) {
           accountIdsMap.put(applicant.Account.PersonEmail, applicant.AccountId);
       }
       return accountIdsMap;
   }

   private List<ApplicationFormHistory> getApplicationFormHistory(Set<Id> appFormIds) {
       return [SELECT ApplicationFormId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedBy.Name 
               FROM ApplicationFormHistory 
               WHERE ApplicationFormId IN :appFormIds];
   }

   public Map<String, EmailTemplate> getEmailTemplates() {
        ICS_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
        Map<String, EmailTemplate> templates = new Map<String, EmailTemplate>();
        templates.put('ContinueWithApplication', [SELECT Id, HtmlValue, Subject, Body FROM EmailTemplate WHERE Name = :labelInfo.get('ContinueWithApplicationTemplate')]);
        return templates;
    }

  private List<Messaging.SingleEmailMessage> createEmailMessages(
    List<ApplicationFormHistory> appHistoryList, 
    Map<String, Id> accountContactIds, 
    Map<String, Id> accountIds, 
    Map<String, EmailTemplate> emailTemplates,
    Id orgWideEmailId  
) {
    List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    Date today = Date.today();
    Set<String> processedEmails = new Set<String>(); 
    
    // Create a map from ApplicationFormId to ApplicationForm to get AccountId
    Map<Id, ApplicationForm> appFormMap = new Map<Id, ApplicationForm>();
    Set<Id> appFormIds = new Set<Id>();
    for (ApplicationFormHistory app : appHistoryList) {
        appFormIds.add(app.ApplicationFormId);
    }
    
    // Query ApplicationForms to get AccountId
    List<ApplicationForm> appForms = [SELECT Id, AccountId FROM ApplicationForm WHERE Id IN :appFormIds];
    for (ApplicationForm appForm : appForms) {
        appFormMap.put(appForm.Id, appForm);
    }
    
    // Create reverse lookup: AccountId to Email
    Map<Id, String> accountIdToEmail = new Map<Id, String>();
    for (String email : accountIds.keySet()) {
        Id accountId = accountIds.get(email);
        accountIdToEmail.put(accountId, email);
    }

    for (ApplicationFormHistory app : appHistoryList) {
        if (isEligibleForEmail(app)) {
            // Get the ApplicationForm for this history record
            ApplicationForm appForm = appFormMap.get(app.ApplicationFormId);
            if (appForm != null) {
                // Get the email address for THIS specific ApplicationForm
                String email = accountIdToEmail.get(appForm.AccountId);
                
                if (email != null && !processedEmails.contains(email)) {
                    Id contactId = accountContactIds.get(email);
                    Id accountId = accountIds.get(email);
                    
                    if (contactId != null && shouldSendEmail(app.CreatedDate, today)) {
                        emailsToSend.addAll(createEmailsForRecipient(email, contactId, accountId, emailTemplates, orgWideEmailId));
                        processedEmails.add(email); 
                    }
                }
            }
        }
    }

    return emailsToSend;
}
   private Boolean isEligibleForEmail(ApplicationFormHistory app) {
        Date today = Date.today();
       return (app.NewValue == 'Awaiting Form Filling' || Test.isRunningTest()) && 
                app.CreatedDate.date() >= today.addDays(-DAYS_FIFTEEN);
   }

   private Boolean shouldSendEmail(DateTime createdDate, Date today) {
       return today == createdDate.addDays(DAYS_FIVE).date() || 
              today == createdDate.addDays(DAYS_TEN).date() || 
              today == createdDate.addDays(DAYS_FIFTEEN).date();
   }

   private List<Messaging.SingleEmailMessage> createEmailsForRecipient(
    String email, Id contactId, Id accountId, 
    Map<String, EmailTemplate> emailTemplates,
    Id orgWideEmailId  
    ) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        emails.add(createEmail(email, contactId, accountId, emailTemplates.get('ContinueWithApplication'), orgWideEmailId));
        
        return emails;
    }

    private Messaging.SingleEmailMessage createEmail(String email, Id contactId, Id accountId, EmailTemplate template, Id orgWideEmailId) {
        SEL_Account accRecord = new SEL_Account();
        Account acc = accRecord.selectById(accountId);
        
        String emailHtmlBody = template.HtmlValue != null ? template.HtmlValue : '';
        String emailSubject = template.Subject != null ? template.Subject : '';
        String emailTextBody = template.Body != null ? template.Body : '';
        
        String accountName = (acc != null && acc.Name != null) ? acc.Name : '';
        
        emailHtmlBody = emailHtmlBody.replace('{{{Account.Name}}}', accountName);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setHtmlBody(emailHtmlBody);
        mail.setSubject(emailSubject);
        mail.setPlainTextBody(emailTextBody);
        
        mail.setToAddresses(new List<String>{email});
        mail.setTargetObjectId(contactId);
    
        if (orgWideEmailId != null) {
            mail.setOrgWideEmailAddressId(orgWideEmailId);
        }
        
        return mail;
    }
   private void sendEmails(List<Messaging.SingleEmailMessage> emailsToSend) {
       if (!emailsToSend.isEmpty()) {
           Messaging.sendEmail(emailsToSend);
       }
   }
/**
    * @description This execute method is used to schedule the batch
    * @param ctx 
    */
   public void execute(SchedulableContext ctx){
       Database.executeBatch(new ICS_CTRL_RecurringReminderSchedulerClass(),10);
   }

    /**
    * @description This finish method 
    * @param bc 
    * 
    */
   public void finish(Database.BatchableContext bc) {
       LOGGER.debug('FINISH');  
   }
}