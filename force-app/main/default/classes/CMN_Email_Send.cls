/**
* @description Class for sending email upon successful creation of account in bank
* @author Ruchi Agrawal
* Story Number- SFP-24628
* @date May 2023
*/
public without sharing class CMN_Email_Send {
    /**
* @description method to Display name
*/
    private static final String DISPLAY_NAME = 'Stanbic Customer Care';
    
    /**
* @description method to send email template
* @param appliactionParticipant
* @param emailOtp
*/
    public static void sendEmailWithTemplate(Application_Participant__c appliactionParticipant, String emailOtp) {
        
        if(appliactionParticipant!=null) {
            Messaging.SingleEmailMessage mail =  new  Messaging.SingleEmailMessage(); 
            String[] toAddress = new String[]{appliactionParticipant.CNGCU_Email__c }; 
                mail.SetToAddresses(toAddress);
            mail.setSubject('Hi '+ appliactionParticipant.CNGCU_First_Name__c +', Please verify your identity in Standard Bank');
            String emailTemplate = 'Dear '+ appliactionParticipant.CNGCU_First_Name__c + ' , <br/><br/>'
                + 'Please use (' + emailOTP +') OTP  to complete your new Bank Account sign up procedure. Note the OTP is valid for 1 minute<br/><br/>'
                + '<br/> *** This is a System-Generated Email. Please do not respond. <br/><br/>'
                + 'For any queries kindly contact us on below address. <br/><br/> '
                + 'Thanks & Regards, <br/> Enterprise Direct <br/> Email: enterprisedirectug@stanbic.com<br/>	Contact: 0312226600';
            
            mail.setSaveAsActivity(false);
            mail.setWhatId(appliactionParticipant.id);// This is the Application participant ID
            mail.setHtmlBody(emailTemplate);  
            List<OrgWideEmailAddress> emailAddressList = [SELECT Id, IsAllowAllProfiles FROM OrgWideEmailAddress 
                                                          WHERE DisplayName = :DISPLAY_NAME 
                                                          ORDER BY LastModifiedDate DESC
                                                          LIMIT 1
                                                         ];
            if(emailAddressList.isEmpty() == false) {
                mail.setOrgWideEmailAddressId(emailAddressList[0].Id);
            } else {
                mail.setSenderDisplayName('Stanbic Bank Support');
            }
            Messaging.SendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
    
    /**
* @description method to send email template
* @param applicationList
*/
    
    public static void sendEmailTemplateWithTemplate(List<Application__c> applicationList) {
        
        if(applicationList.isEmpty() == false) {
            Messaging.SingleEmailMessage mail =  new  Messaging.SingleEmailMessage();
           
            EmailTemplate emailTemp = [SELECT id, Subject, Body From EmailTemplate Where DeveloperName = 'AOB_Notify_User_Upon_Account_Creation_Successful'];
            mail.setTemplateId(emailTemp.id);
        
            String[] sendingTocAdd = new String[]{applicationList[0].CNGCU_CSEmail__c};   
                mail.SetToAddresses(sendingTocAdd);
            mail.setHtmlBody('Hello Standard Bank User');     
            mail.setReplyTo(userinfo.getUserEmail());
            mail.setTargetObjectId(applicationList[0].AOB_Lead__c);
            mail.setSaveAsActivity(false);
            mail.setWhatId(applicationList[0].id);
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            emailList.add(mail);
            if(emailList.isEmpty() == false) {
                Messaging.sendEmail(emailList);
            } 
        }
    }
}