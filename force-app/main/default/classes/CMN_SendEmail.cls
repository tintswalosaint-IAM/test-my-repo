/**
 * @description       : Class to Send Email(Banker Centaur) 
 * @author            : Sandile Mathe
 * @group             : PER: Personalisation
 * @Created on        : 02-06-2024
**/
public class CMN_SendEmail {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_SendEmail..class.getName());
    
    //String Contants
    Private static final String DISPLAY_NAME = 'Standard Bank';
    
    @AuraEnabled
    public static void sendEmail(String accountId, String subject, String body,String eventId) {
            try {
                    Account account = [SELECT PersonContactId FROM Account WHERE Id = :accountId LIMIT 1]; 
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(account.PersonContactId);
                    email.setReplyTo(UserInfo.getUserEmail());
                    email.setSenderDisplayName(DISPLAY_NAME);
                    email.setSubject(subject);
                    email.setPlainTextBody(body);
                    email.setHTMLBody(body); 

                //Send Email
                Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

                //Make API call to update event after the Email was sent
                if (result[0].isSuccess()) {

                    sendEventUpdateAsync(eventId, body); 

                }
                
                else{
                    
                    throw new AuraHandledException('Email Sending failed: ' +  result[0].getErrors()[0].getMessage());           
                } 
   
               } catch (Exception ex) {
                  LOGGER.fatal('An unexpected error occurred while sending the email: ' + ex.getMessage());
                  throw new AuraHandledException('An unexpected error occurred while sending the email: ' + ex.getMessage());
        }
        
    }
    
    // @future method for asynchronous callout
    @future(callout=true)
    public static void sendEventUpdateAsync(String eventId, String body) {
        try{
                PER_API_BAS_Feedback_Service bas = new PER_API_BAS_Feedback_Service();
                bas.sendEventUpdate(eventId, body);
            
        }catch(Exception e){
            LOGGER.fatal('An unexpected error occurred during API call: ' + e.getMessage());
            throw new ServiceException('Error during API call: ' + e.getMessage());
        }
  
 }
     private class ServiceException extends Exception {}
    
}