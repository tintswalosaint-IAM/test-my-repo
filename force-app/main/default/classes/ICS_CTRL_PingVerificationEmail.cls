/**
* @description class used for Ping Email verification
*
* Story:SFP-36380
*
* @author Ikyatha Naidu
*
* @date May 2023
* @last modified on  : 29-02-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : SFP-36380 class used for Ping Email verification
*/
public without sharing class ICS_CTRL_PingVerificationEmail {
    private ICS_CTRL_PingVerificationEmail() {
    }
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_PingVerificationEmail');
    
    /**
* @description This method is used to query a list of email template
* @param accList 
*/
    @AuraEnabled
    public static void pingVerificationEmail(String oppId,string pCode) {         
        SEL_ApplicationForm appFormSelector = new SEL_ApplicationForm();
        List<ApplicationForm> appFormRecords = appFormSelector.selectByOpportunityId(oppId);
        Set<Id> accountIds = new Set<Id>();
        for(ApplicationForm appRec : appFormRecords) {
            accountIds.add(appRec.AccountId);
        }
        SEL_Account accSelector = new SEL_Account(); 
        List<Account> accRec = accSelector.selectByIds(accountIds);  
      
        if(pCode == 'CURR_SEA') {
            for (Account acc : accRec) {
                ICS_CTRL_SeafererSendEmail.sendEmail(acc.ID);
            }
        }else{
            ICS_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
            Map<string, string> labelInfo = (Map<string, string>) JSON.deserialize(labelData.Description__c, map<string, string>.class);
            EmailTemplate emailTemplate = [SELECT Id,Subject,Description, HtmlValue FROM EmailTemplate WHERE Name = :labelInfo.get('PingCommTemplate')];
            List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE Address=:labelInfo.get('isleOfManOrgWideAddress')];
            
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            Integer maxEmailsAllowed = Limits.getLimitEmailInvocations() - Limits.getEmailInvocations();
            
            for (Account acc : accRec) {
                if ((acc.PersonEmail != null && messages.size() < maxEmailsAllowed ) || Test.isRunningtest()){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(false);
                    
                    String emailTextBody = emailTemplate.HtmlValue;
                    emailTextBody = emailTextBody.replace('{{{Account.Name}}}', acc.Name);
                    String emailSubject = emailTemplate.Subject;
                    
                    message.setTemplateID(emailTemplate.Id); 
                    message.setWhatId(acc.Id);
                    message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
                    message.setSubject(emailSubject);
                    message.setHtmlBody(emailTextBody);
                    message.setToAddresses(new String[] { acc.PersonEmail });
                    if( !Test.isRunningtest()) {
                        messages.add(message);
                    }
                } else {
                    LOGGER.error('Email Limit got Exceeded');
                }
            }
            
            // Only send emails if we're not running a test and there are messages to send
            if (!Test.isRunningTest() && messages.size() > 0) {
               
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
                
            }
        }
        if(oppId!=null)
        {
            notifyOwner(new set<Id>{oppId});
        }
    }
    public static void notifyOwner(set<Id> oppId) 
    {
        try {
            // Fetch Notification Type ID
            List<CustomNotificationType> notificationTypes = [
                SELECT Id FROM CustomNotificationType 
                WHERE DeveloperName = 'ICS_Approval_Flow_Notifications'
            ];
                List<Opportunity> oppList = [
                SELECT Id, OwnerId,Name,Owner.FirstName,Owner.LastName
                FROM Opportunity 
                WHERE Id IN :oppId 
                
            ];
             List<Messaging.CustomNotification> notificationList = new List<Messaging.CustomNotification>();
            for(Opportunity oppRecord: oppList) {
                 Id notificationTypeId = notificationTypes[0].Id;
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setTitle('Hi '+oppRecord.Owner.FirstName+' '+oppRecord.Owner.LastName);
                notification.setBody('The following Opportunity has now been created and is assigned to yourself: '+'\n'+
                                'Opp Name: '+ oppRecord.Name+'\n'+
                                'Opp Id: '+ oppRecord.Id+ +'\n'+
                                'Thanks,');
                notification.setNotificationTypeId(notificationTypeId);
                notification.setTargetId(oppRecord.id);
                Id ownerId = oppRecord.OwnerId;
            
                if (!oppList.isEmpty()) {
                    notification.send(new set<String>{ownerId});
                }
            }
            
            
           
            // Prepare the notification type
          
        } catch (Exception e) {
            LOGGER.error(e.getmessage());
            throw new AuraHandledException(e.getmessage());   
        }
    }
    @AuraEnabled
    public static Boolean checkCountryOfNationalityOrResidence(String oppId) {
        try {
            List<ApplicationForm> appForms = [
                SELECT Id, AccountId 
                FROM ApplicationForm 
                WHERE OpportunityId = :oppId
            ];
            if (appForms.isEmpty()) {
                return false;
            }
            
            Set<Id> accountIds = new Set<Id>();
            for (ApplicationForm appForm : appForms) {
                if (appForm.AccountId != null) {
                    accountIds.add(appForm.AccountId);
                }
            }
            if (accountIds.isEmpty()) {
                return false;
            }
            
            List<PartyProfile> partyProfiles = [
                SELECT Id, Country_of_Nationality__c, Country_of_Residence__c,Second_Country_of_Nationality__c, OwnerId 
                FROM PartyProfile 
                WHERE AccountId IN :accountIds
            ];
          
            Boolean shouldNotify = false;
            Set<String> ownerIdsToNotify = new Set<String>();
            
            for (PartyProfile partyProfile : partyProfiles) {
                if (partyProfile.Country_of_Nationality__c == 'UA' || 
                    partyProfile.Country_of_Residence__c == 'UA'|| 
                    partyProfile.Second_Country_of_Nationality__c == 'UA') {
                        shouldNotify = true;
                        ownerIdsToNotify.add(partyProfile.OwnerId);
                    }
            }
            
            if (shouldNotify && !ownerIdsToNotify.isEmpty()) {
                sendCustomNotification(new Set<String>(ownerIdsToNotify), oppId);
                return true;
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
    public static void sendCustomNotification(Set<String> ownerIds, String oppId) {
        try {
            // Fetch Notification Type ID
            List<CustomNotificationType> notificationTypes = [
                SELECT Id FROM CustomNotificationType 
                WHERE DeveloperName = 'ICS_Approval_Flow_Notifications'
            ];
            
            if (notificationTypes.isEmpty()) {
                return;
            }
            
            // Prepare the notification type
            Id notificationTypeId = notificationTypes[0].Id;
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Ukraine Nationality/Residence Alert');
            notification.setBody('An applicant with Ukrainian nationality or residence has been identified.');
            notification.setNotificationTypeId(notificationTypeId);
            notification.setTargetId(oppId);
            
            if (!ownerIds.isEmpty()) {
                notification.send(ownerIds);
            }
        } catch (Exception e) {
            LOGGER.error(e.getmessage());
            throw new AuraHandledException(e.getmessage());   
        }
    }
    
}