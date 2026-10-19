/**
* @description Class is called from a class (INS_CozaLeadAPICallout) When Experience Lead Api is failed to create a record in SAP and sends an email and a salesforce notification to relevant users
* @author Raja Arsalan (raja.arsalan@standardbank.co.za)
* @date Sept 2023
*/
public with sharing class INS_CozaLeadAPIErrorHandler {
    
    /**
* @description       : Invokable method called from a flow (Lead_Allocate_Send_leads_to_dialer_via_API) to send data to SAP.
* @author            : Raja Arsalan (Raja.Arsalan@standardbank.co.za)
* @param leadIds
**/
    @InvocableMethod(label='Send Email and custom notification')
    public static void sendEmailandNotification(List<String> leadIds) {
        sendErrorEmailToTechTeam(leadIds);
        sendNotificationToTechTeam(leadIds);
    }
    
    /**
* @description    :  method for sending email to tech team if lead is not created on SAP
* @param leadIds
**/
    public static void sendErrorEmailToTechTeam(List<String> leadIds){
        
        List<User> recpUsers = getGroupMembers();
        try{
            
            if(recpUsers != null && recpUsers.size() > 0)
            {
                list<string> toAddressesList = new list<string>();
                for(user usr : recpUsers )
                {
                    toAddressesList.add(usr.Email);
                }
                list<lead> thisLead = New SEL_Lead().selectLeadByRecId(leadIds[0]);
                List<EmailTemplate> emailTemplate = new INS_SEL_EmailTemplate().selectEmailTemplateByName('Lead_Failed_Notification');
                
                if(emailTemplate != null && emailTemplate.size() > 0)
                {
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddressesList);
                    mail.setTargetObjectId(userinfo.getuserid());// This is the leadRec id
                    mail.setSaveAsActivity(false);
                    mail.setWhatId(thisLead[0].id);// This is the App ID
                    mail.setTemplateId(emailTemplate[0].id);
                    emailList.add(mail);
                    if(!emailList.isEmpty()){
                        Messaging.sendEmail(emailList);
                    }  
                }  
            }  
        }
        catch(exception ex){
            throw ex;
        }
        
        
        
    } 
    
    
    
    /**
* @description    :  method for sending Custom notification to tech team if lead is not created on SAP
* @param          leadIds
**/     
    public static void sendNotificationToTechTeam(List<String> leadIds){
        set<string> recipientsIds = new set<string>();
        List<User> recpUsers = getGroupMembers();
        try{
            if(recpUsers != null && recpUsers.size() > 0)
            {
                for(user usr : recpUsers )
                {
                    recipientsIds.add(usr.Id);
                }
                
                string recordUrl = URL.getOrgDomainURL().toExternalForm()+'/'+leadIds[0];
                string targetId = leadIds[0];
                
                List<CustomNotificationType> notificationType = new INS_SEL_CustomNotification().selectNotificationTypeById('Lead_Failure');
                // Create a new custom notification
                
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                
                // Set the contents for the notification
                notification.setTitle('Lead failed to create');
                notification.setBody('This is to notify that the following lead is not created is SAP: '+ recordUrl);
                
                // Set the notification type and target
                notification.setNotificationTypeId(notificationType[0].Id);
                notification.setTargetId(targetId);      
                
                notification.send(recipientsIds);
            }
        }
        catch(exception ex){
            throw ex;
        }
        
        
    }
    
    
    
    
    
    private static List<User> getGroupMembers() {
        
        Map<String, INS_Coza_Leads_Tech_Team__mdt> metadataMap = INS_Coza_Leads_Tech_Team__mdt.getAll();
        List<User> recpUsers = new List<User>();
        if (!metadataMap.isEmpty()) {
            INS_Coza_Leads_Tech_Team__mdt firstMetadataRecord = metadataMap.values()[0];
            String labelField = firstMetadataRecord.MasterLabel;
            
            recpUsers = new SEL_User().selectUsersByGroup(labelField);  
        }
        return recpUsers;
    }
    
    
    
}