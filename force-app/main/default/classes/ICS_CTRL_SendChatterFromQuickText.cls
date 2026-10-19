/**
 * @Name of the Class : ICS_CTRL_SendChatterFromQuickText
 * @description SFP-34745 Controller used for Chatter Notification with reduced complexity
 * @author IKYATHA NAIDU
 * @date 11/01/2024
 * @ last modified on  : 01/07/2024
 * @ last modified by  : IKYATHA NAIDU
 * @ Last Modified By 		: Tushar Walse
 * @ Last Modified On 		: 23-10-2025
 * @ Modification description : SFP-53496 Risk Rating Challenge issues - Include comment value to be replaced in the quicktext template
 */
public with sharing class ICS_CTRL_SendChatterFromQuickText {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_SendChatterFromQuickText');
    
    private static final String CHATTER_NOTIFICATION_TEMPLATE = 'ICS Send Chatter Post Notification';
    
    private ICS_CTRL_SendChatterFromQuickText(){}
    
    // Request and Response wrapper classes remain unchanged
    public class RequestParam {
        @InvocableVariable public String parentId;
        @InvocableVariable public String quickTextId;
        @InvocableVariable public Boolean action;
        @InvocableVariable public Boolean email;
        @InvocableVariable public String comment;
    }
    
    public class ResponseParam {
        @InvocableVariable public String ResponseText;
        @InvocableVariable public String GroupId;
    }
    
    /**
     * @description Entry point for processing QuickText templates
     */
    @InvocableMethod(label='Process Selected Template')
    public static List<ResponseParam> processSelectedTemplate(List<RequestParam> params) {
        LOGGER.info('Starting processSelectedTemplate with {0} params', new Object[]{params.size()});
        
        if (params.isEmpty() || !params[0].action) {
            LOGGER.info('No action required, returning empty list');
            return new List<ResponseParam>();
        }
        
        RequestParam param = params[0];
        ResponseParam response = processQuickText(param);
        return new List<ResponseParam>{response};
    }
    
    /**
     * @description Processes a single QuickText request
     */
    private static ResponseParam processQuickText(RequestParam param) {
        Map<String, String> processedData = fetchQuickTextData(
            new List<String>{param.quickTextId}, 
            param.parentId, 
            param.email
        );
        
        ResponseParam response = new ResponseParam();
        response.ResponseText = processedData.get('message');
        response.ResponseText = response.ResponseText?.replace('Motivation for risk rating change:', 'Motivation for risk rating change: ' + param.comment);
        response.GroupId = processedData.get('groupId');
        return response;
    }
    
    /**
     * @description Fetches and processes QuickText data
     */
    private static Map<String, String> fetchQuickTextData(List<String> quickTextIds, String recordId, Boolean emailAction) {
        LOGGER.debug('Fetching QuickText data for IDs: {0}', new Object[]{quickTextIds});
        
        QuickTextDataWrapper dataWrapper = new QuickTextDataWrapper(quickTextIds, recordId);
        String messageBody = processMessageBody(dataWrapper);
        
        if (emailAction && String.isNotBlank(dataWrapper.groupId)) {
            sendGroupEmails(new List<String>{dataWrapper.groupId});
        }
        
        return new Map<String, String>{
            'message' => messageBody,
            'groupId' => dataWrapper.groupId
        };
    }
    
    /**
     * @description Wrapper class to hold related data for QuickText processing
     */
    private class QuickTextDataWrapper {
        public QuickText quickText;
        public Account account;
        public Opportunity opportunity;
        public PartyProfileRisk profileRisk;
        public CollaborationGroup colGroup;
        public PartyProfile profile;
        public String groupId;
        
        public QuickTextDataWrapper(List<String> quickTextIds, String recordId) {
            initializeData(quickTextIds, recordId);
        }
        
        private void initializeData(List<String> quickTextIds, String recordId) {
            quickText = [SELECT Id, Name, Message FROM QuickText WHERE Id IN :quickTextIds LIMIT 1];
            
            SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
            List<PartyProfile> profiles = selectorPartyProfile.selectByIds(new Set<Id>{recordId});
          	  profile=profiles[0];
            if (!profiles.isEmpty()) {
                SEL_Account selectorAccount = new SEL_Account();
                account = selectorAccount.selectById(profiles[0].AccountId);
                
                SEL_Opportunity selectorOpportunity = new SEL_Opportunity();
                List<Opportunity> opportunities = selectorOpportunity.selectByAccountId(account.Id);
                if (!opportunities.isEmpty()) {
                    opportunity = opportunities[0];
                }
                
                List<PartyProfileRisk> risks = [SELECT Id, OverridenRiskCategory 
                                              FROM PartyProfileRisk 
                                              WHERE PartyProfileId = :profiles[0].Id 
                                              LIMIT 1];
                if (!risks.isEmpty()) {
                    profileRisk = risks[0];
                }
                
                String groupName = quickText.Message.substringBetween('[', ']');
                if (String.isBlank(groupName)) {
                    return;
                }
                    List<CollaborationGroup> groups = [SELECT Id, Name 
                                                     FROM CollaborationGroup 
                                                     WHERE Name = :groupName 
                                                     LIMIT 1];
                    if (!groups.isEmpty()) {
                        colGroup = groups[0];
                        groupId = colGroup.Id;
                    }
                
            }
        }
    }
    
    /**
     * @description Processes the message body with placeholders
     */
    private static String processMessageBody(QuickTextDataWrapper data) {
        if (data.quickText == null || String.isBlank(data.quickText.Message)) {
            return '';
        }
        
        String messageBody = data.quickText.Message;
        messageBody = replacePlaceholders(messageBody, data);
        
        List<Messaging.RenderEmailTemplateBodyResult> renderResults = 
            Messaging.renderEmailTemplate(null, data.account.Id, new List<String>{messageBody});
        
        return renderResults[0].getMergedBody();
    }
    
    /**
     * @description Replaces placeholders in the message body
     */
    private static String replacePlaceholders(String messageBody, QuickTextDataWrapper data) {
        if (data.account != null) {
           	string residenceCountry=getPicklistLabel('PartyProfile','Country_of_Residence__c',data.profile.Country_of_Residence__c);
            string nationalityCountry=getPicklistLabel('PartyProfile','Country_of_Nationality__c',data.profile.Country_of_Nationality__c);
            messageBody = messageBody.replace('{!PartyProfile.FirstName}', data.account.FirstName);
            messageBody = messageBody.replace('{!PartyProfile.LastName}', data.account.LastName);
            messageBody = messageBody.replace('{!PartyProfile.DateOfBirth}', String.valueOf(data.account.PersonBirthdate));
            messageBody = messageBody.replace('{!PartyProfile.Gender}', data.account.FinServ__Gender__pc);
            messageBody = messageBody.replace('{!PartyProfile.Country_of_Residence__c}',ResidenceCountry);
            messageBody = messageBody.replace('{!PartyProfile.Country_of_Nationality__c}',nationalityCountry);
        }
        
       
        
        if (data.colGroup != null) {
            messageBody = messageBody.replace('[' + data.colGroup.Name + ']', '');
        }
        
        if (data.opportunity != null && messageBody.contains('{{{opportunityLink}}}')) {
            messageBody = messageBody.replace('{{{opportunityLink}}}', 
                                           System.URL.getOrgDomainUrl().toExternalForm() + '/' + data.opportunity.Id);
        }
        
        return messageBody;
    }
    
    /**
     * @description Sends emails to group members
     */
    private static void sendGroupEmails(List<String> groupIds) {
        List<CollaborationGroupMember> members = [SELECT Id, Member.Email, MemberId 
                                                FROM CollaborationGroupMember 
                                                WHERE CollaborationGroupId IN :groupIds];
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate 
                                WHERE Name = :CHATTER_NOTIFICATION_TEMPLATE LIMIT 1];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (CollaborationGroupMember member : members) {
            emails.add(createEmailMessage(member, template.Id));
        }
        
        sendEmailBatch(emails);
    }
    
    /**
     * @description Creates an email message for a group member
     */
    private static Messaging.SingleEmailMessage createEmailMessage(CollaborationGroupMember member, Id templateId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{member.Member.Email});
        email.setTemplateId(templateId);
        email.setTargetObjectId(member.MemberId);
        email.setSaveAsActivity(false);
        return email;
    }
    
    /**
     * @description Sends a batch of emails with error handling
     */
    private static void sendEmailBatch(List<Messaging.SingleEmailMessage> emails) {
        try {
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
                LOGGER.info('Emails sent successfully to {0} recipients', new Object[]{emails.size()});
            }
        } catch (Exception e) {
            LOGGER.error('Failed to send emails. Error: {0}', new Object[]{e.getMessage()});
        }
    }
    
      /**
     * Get picklist label for a given field API name and picklist value
     * @param objectName - API name of the object (e.g., 'Account')
     * @param fieldName - API name of the picklist field (e.g., 'Industry')
     * @param picklistValue - API name of the picklist value
     * @return Label of the picklist value
     */
    public static String getPicklistLabel(String objectName, String fieldName, String picklistValue) {
        // Get the describe result for the object
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        
        // Get the field map for the object
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
        
        // Get the field describe result
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
        
        // Get the list of picklist entries
        List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
        
        // Find the matching picklist entry and return its label
        for(Schema.PicklistEntry entry : picklistValues) {
            if(entry.getValue() == picklistValue) {
                return entry.getLabel();
            }
        }
        
        return null; // Return null if no matching value is found
    }
    
}