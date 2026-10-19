/**
 * @description Class for sending email upon successful creation of account in bank
 * @author Jagadish Thummala
 * @date June 2022
 */
public without sharing class AOB_Email_send {
   private AOB_Email_send(){}
    public static void sendEmailTemplateWithTemplate(List<Application__c> applicationList) { }
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_Email_send');

    /**
     * @description Sends welcome pack email with attachments to the applicant
     * @param applicationList List of Application__c records
     * @param welcomePackDocList List of ContentVersion documents for the welcome pack
     */
    public static void sendWelcomePack(List<Application__c> applicationList, List<ContentVersion> welcomePackDocList) {
        if (applicationList == null || applicationList.isEmpty() || welcomePackDocList == null || welcomePackDocList.isEmpty()) {
            return;
        }

        List<ContentVersion> updatedWelcomePack = addStaticResourcesToWelcomePack(welcomePackDocList);
        Messaging.SingleEmailMessage mail = buildEmail(applicationList[0], updatedWelcomePack);
        sendEmail(mail);
    }

    /**
     * @description Adds static resources to the welcome pack document list
     * @param welcomePackDocList List of ContentVersion documents
     * @return Updated list of ContentVersion documents
     */
    private static List<ContentVersion> addStaticResourcesToWelcomePack(List<ContentVersion> welcomePackDocList) {
        Map<String, Blob> staticResourceBodies = fetchStaticResources();
        Map<String, String> resourceDescriptions = getResourceDescriptions();

        for (String resourceName : resourceDescriptions.keySet()) {
            Blob resourceBody = staticResourceBodies.get(resourceName);
            if (resourceBody != null) {
                String description = resourceDescriptions.get(resourceName);
                ContentVersion contentVersion = new ContentVersion(
                    Title = description,
                    Description = description,
                    VersionData = resourceBody
                );
                if (Test.isRunningTest()) {
                ContentVersion testContentVersion = new ContentVersion(
                    Title = 'Test ' + description,
                    Description = 'Test ' + description,
                    PathOnClient = 'TestDocument.pdf',
                    VersionData = Blob.valueOf('Test Content Data')
                );
                welcomePackDocList.add(testContentVersion);
                } else {
                    welcomePackDocList.add(contentVersion);
                }
            }
        }
        return welcomePackDocList;
    }

    /**
     * @description Fetches static resources by name
     * @return Map of static resource names to their Blob bodies
     */
    private static Map<String, Blob> fetchStaticResources() {
        List<String> staticResourceNames = new List<String>{
            'AOB_Uganda_TC_AccountOpening', 
            'AOB_Uganda_TC_ElectronicBanking', 
            'AOB_Uganda_TC_ATM_Card', 
            'User_Guide_to_login'
        };
        Map<String, Blob> staticResourceBodies = new Map<String, Blob>();
        List<StaticResource> staticResources = [
            SELECT Id, Name, Body 
            FROM StaticResource 
            WHERE Name IN :staticResourceNames 
            
        ];
        for (StaticResource resource : staticResources) {
            staticResourceBodies.put(resource.Name, resource.Body);
        }
        return staticResourceBodies;
    }

    /**
     * @description Provides descriptions for static resources
     * @return Map of resource names to their descriptions
     */
    private static Map<String, String> getResourceDescriptions() {
        return new Map<String, String>{
            'AOB_Uganda_TC_AccountOpening' => 'T&C AccountOpening',
            'AOB_Uganda_TC_ElectronicBanking' => 'T&C ElectronicBanking',
            'AOB_Uganda_TC_ATM_Card' => 'T&C ATM Card',
            'User_Guide_to_login' => 'User Guide to login'
        };
    }

    /**
     * @description Builds the email message with attachments
     * @param app Application__c record
     * @param emailTemplate Email template to use
     * @param welcomePackDocList List of ContentVersion documents
     * @return Configured SingleEmailMessage
     */
    private static Messaging.SingleEmailMessage buildEmail(Application__c app , List<ContentVersion> welcomePackDocList) {
        List<Lead> leadList =new SEL_Lead().selectLeadByRecId(app.AOB_Lead__c);
        PPB_Static_values__mdt emailConfig = [
				SELECT Value__c
				FROM PPB_Static_values__mdt
				WHERE DeveloperName = 'Stanbic_Customer_Care_Email' 
				LIMIT 1
			];
        String customerCareEmail = emailConfig.Value__c;  
        List<OrgWideEmailAddress> emailAddressList = [SELECT Id, IsAllowAllProfiles FROM OrgWideEmailAddress 
                WHERE Address = :customerCareEmail 
                LIMIT 1
            ]; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[]{ leadList[0].Email};
        mail.SetToAddresses(toAddress);
        mail.setTargetObjectId(leadList[0].Id);
        mail.setSubject('Welcome Pack for Your Application');
        mail.setHtmlBody(buildEmailBody(app));
        mail.setFileAttachments(createEmailAttachments(welcomePackDocList));
        if(emailAddressList.isEmpty() == false) {
                mail.setOrgWideEmailAddressId(emailAddressList[0].Id);
            } else {
                mail.setSenderDisplayName('Stanbic Bank Support');
            }
        return mail;
    }

    /**
     * @description Builds the HTML body for the email
     * @param app Application__c record
     * @param emailTemplate Email template
     * @return HTML body string
     */
    private static String buildEmailBody(Application__c app) {
        String accountNumber = String.isNotBlank(app.AOB_Account_Number__c) ? app.AOB_Account_Number__c : '';
        return '<p>Dear Customer,</p>' +
               '<p>Attached is your welcome pack containing important documents for your application.</p>' +
               '<p>Username: ' + String.escapeSingleQuotes(accountNumber) + '</p>' +
               '<p>Best regards,<br>Standard Bank Team</p>';
    }

    /**
     * @description Creates email attachments from ContentVersion documents
     * @param welcomePackDocList List of ContentVersion documents
     * @return List of email attachments
     */
    private static List<Messaging.EmailFileAttachment> createEmailAttachments(List<ContentVersion> welcomePackDocList) {
        Map<String, String> fileTypeToMimeType = new Map<String, String>{
            'PDF' => 'application/pdf',
            'JPEG' => 'image/jpeg',
            'JPG' => 'image/jpeg',
            'PNG' => 'image/png',
            'TEXT' => 'text/plain'
        };
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (ContentVersion cv : welcomePackDocList) {
            if (cv.VersionData != null) {
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setBody(cv.VersionData);
                attachment.setFileName(cv.Title + '.pdf');
                String mimeType = fileTypeToMimeType.get(cv.FileType) == null ? 'application/octet-stream' : fileTypeToMimeType.get(cv.FileType) ;
                attachment.setContentType(mimeType);
                attachments.add(attachment);
            } 
        }
        return attachments;
    }

    /**
     * @description Sends the email and handles any exceptions
     * @param mail The email message to send
     */
    private static void sendEmail(Messaging.SingleEmailMessage mail) {
        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        } catch (Exception e) {
            LOGGER.error('AOB_Email_send.sendEmail: Failed to send email'+e.getMessage());
        }
    }
}