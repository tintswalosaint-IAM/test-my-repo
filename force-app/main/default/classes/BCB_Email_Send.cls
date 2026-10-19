/***************************************************************************************
@Name of the Class : BCB_Email_Send
@description       : Class for sending email upon successful creation of account in bank.
@Author            : Ruchi Agrawal 
@Date              : May 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 03-04-2024
@Modification Description : SFP-37302
***************************************************************************************/
public without sharing class BCB_Email_Send {
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
 @AuraEnabled  
public static void sendEmailTemplateWithTemplate(String applicationParticipant) {
    
    if (applicationParticipant != null) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<Application_Participant__c> participantList = new SEL_ApplicationParticipant().selectApplicationParticpantById(applicationParticipant);
        List<Application__c> applicationList = new SEL_Application().selectAppsById(participantList[0].Application__c);
      
        EmailTemplate emailTemp = [SELECT id, Subject, Body FROM EmailTemplate WHERE DeveloperName = 'AOB_Notify_User_Upon_Account_Creation_Successful'];
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
        String[] sendingToAddresses = new String[]{participantList[0].CNGCU_Email__c};
        mail.setToAddresses(sendingToAddresses);
        mail.setReplyTo(UserInfo.getUserEmail());
        mail.setTargetObjectId(applicationList[0].AOB_Lead__c);
        mail.setSaveAsActivity(false);
        mail.setWhatId(participantList[0].id);
        mail.setTemplateID(emailTemp.Id); 
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        emailList.add(mail);
        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList);
        }
    }
}

}