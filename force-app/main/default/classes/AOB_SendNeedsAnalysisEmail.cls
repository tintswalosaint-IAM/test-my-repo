/**
 * @description       : Apex class to send Needs Analysis Email to customers
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52370
 * @date              : 02-12-2025
 **/
public without sharing class AOB_SendNeedsAnalysisEmail {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SendNeedsAnalysisEmail');
    /**
     * @description Method to Send out Emails to currently logged in User using Email template and pdf attachment
     * @author            : Madito Tsilo
 	 * @UserStory         : SFP-53079
 	 * @date              : 02-12-2025
     */
    @AuraEnabled
    public static void sendNeedsAnalysisEmail(String recipientEmail,String firstName, String lastName, String coverData) {       
        try{
            Id oweaId;
            EmailTemplate template;  
            List<EmailTemplate> templates = new INS_SEL_EmailTemplate().selectEmailTemplateByName('PLI_Send_Needs_Analysis_Email');            
            template = templates[0];       
            PLI_Email_Address__mdt metadataRecord = Test.isRunningTest()? new PLI_Email_Address__mdt(EmailAddressText__c = 'test@example.com'): PLI_Email_Address__mdt.getInstance('Email');            
            String owemail = metadataRecord.EmailAddressText__c;                        
            if(!Test.isRunningTest()){
                OrgWideEmailAddress owea = new SEL_OrgWideEmailAddress().selectOneByAddress(owemail);
                oweaId = owea.Id;
            }
            Blob pdfBlob;         
            if (Test.isRunningTest()) {
               pdfBlob = Blob.valueOf('Test PDF content');
            }else{                
                PageReference pdfPage = Page.AOB_NeedsAnalysisGeneratePDF;            
                pdfPage.getParameters().put('jsonString', coverData);
                pdfBlob = pdfPage.getContentAsPDF();
                
            }         
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);        
            String subject = template.Subject;
            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody.replace('{!Contact.FirstName}',firstName);
            htmlBody = htmlBody.replace('{!Contact.LastName}',lastName);         
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setToAddresses(new String[] { recipientEmail });
            email.setSaveAsActivity(false);        
            email.setTreatTargetObjectAsRecipient(true);
            if(oweaId != null) {           
            	email.setOrgWideEmailAddressId(oweaId);
            }
            email.setFileAttachments(
                new Messaging.EmailFileAttachment[] {
                    createPdfAttachment(pdfBlob, 'Needs_Analysis_Report.pdf')
                }
            );
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });        
        } catch (Exception e) {
          LOGGER.error(e.getMessage(),new String[]{'AOB_SendNeedsAnalysisEmail.sendNeedsAnalysisEmail',e.getMessage()},e);            
            throw new AuraHandledException('An unexpected error occurred while sending the Needs Analysis email.');
        }
    }

    private static Messaging.EmailFileAttachment createPdfAttachment(Blob pdfBlob, String filename) {
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(filename);
        attachment.setBody(pdfBlob);
        attachment.setContentType('application/pdf');
        return attachment;
    }
}