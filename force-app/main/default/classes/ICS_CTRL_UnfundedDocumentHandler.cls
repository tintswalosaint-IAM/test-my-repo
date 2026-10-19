/***********************************************************
* @description SFP-34727 Controller Class used to process request from Azure and send an email to customer
* @author Ikyatha Naidu
* @date 10/10/2024
******************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 10/10/2024
* Last Modified Description: Initial Version
*/
@restResource(urlMapping='/ICS_CreateUnfundedDocument/*')
global without sharing class ICS_CTRL_UnfundedDocumentHandler {
            public static final String SERVICE_NAME = ICS_CTRL_UnfundedDocumentHandler.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_UnfundedDocumentHandler');

    // Constants
    private static final String SUCCESS_STATUS = 'Success';
    private static final String ERROR_STATUS = 'Error';

    /**
    * @description Wrapper class for incoming REST requests containing a list of document requests
    */
    public class RequestWrapper {
        public List<DocumentRequest> requests { get; set; }
    }

    /**
    * @description Individual document request containing document content and type
    */
    public class DocumentRequest {
        public String Document { get; set; }
        public String DocumentType { get; set; }
    }

    /**
    * @description Response class for REST API containing status, error message, and document ID
    */
    public class Response {
        String status;
        String errorMessage;
        String documentId;
    }

    /**
    * @description Private constructor to prevent instantiation
    */
    private ICS_CTRL_UnfundedDocumentHandler() {}

    /**
    * @description Map of days to email template names, loaded from custom metadata
    * @return Map<Integer, String> Map of days to template names
    */
    @TestVisible
    private static map<integer,string> emailTemplates {
        get {
            Map<integer,string> fundedTemplates = new Map<integer,string>();
            try {
                ics_customlabel__mdt metaDataInfo = [SELECT DeveloperName, Description__c FROM ics_customlabel__mdt WHERE DeveloperName = 'ICS_UnfundedTemplates' LIMIT 1];
                Map<string,string> labelInfo = (Map<string,string>)json.deserialize(metaDataInfo.Description__c, map<string,string>.class);
                for(String days : labelInfo.keyset()){
                    fundedTemplates.put(integer.valueof(days),labelInfo.get(days));
                }
                return fundedTemplates;
            }catch(Exception e){
                LOGGER.error('Error in emailTemplates' + e.getMessage());
                return null;
            }
        }
        set;
    }

    /**
    * @description Main REST endpoint handler for processing document requests
    * @return String JSON serialized list of Response objects
    */
    @HttpPOST
    global static string responseCall() {
        List<Response> responses = new List<Response>();
        try {
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            RequestWrapper wrapper = (RequestWrapper)JSON.deserialize(requestBody, RequestWrapper.class);

        if(wrapper != null && wrapper.requests != null) {
            DocumentRequest reqData = wrapper.requests[0];
                Response resp = new Response();
                try {
                    Id conDocId = createContentVersion(reqData.Document, reqData.DocumentType);
                    extractFileData(conDocId);
                    resp.status = SUCCESS_STATUS;
                    resp.documentId = conDocId;
                     createCallLog(SERVICE_NAME, requestBody, JSON.serialize(resp), true);
                } catch (Exception e) { 
                    resp.status = ERROR_STATUS; resp.errorMessage = e.getMessage();
                    createCallLog(SERVICE_NAME, requestBody, e.getMessage(), false);
                }
                responses.add(resp);
        }
    } catch(JSONException je) {
        Response resp = new Response();
        resp.status = ERROR_STATUS;
        resp.errorMessage = 'Invalid JSON format: ' + je.getMessage();
        responses.add(resp);
        RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
        createCallLog(SERVICE_NAME,requestBody, je.getMessage(), false);
    } catch(Exception e) {
        Response resp = new Response();
        resp.status = ERROR_STATUS;
        resp.errorMessage = 'Error processing request: ' + e.getMessage();
        RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
        createCallLog(SERVICE_NAME,requestBody, e.getMessage(), false);
        responses.add(resp);
    }
        return JSON.serialize(responses);
    }

    /**
    * @description Creates a ContentVersion record from base64 encoded document data
    * @param document Base64 encoded document content
    * @param documentType Type/name of the document
    * @return Id ContentDocumentId of the created ContentVersion
    */
    private static Id createContentVersion(String document, String documentType) {
        ContentVersion contVer = new ContentVersion(
            VersionData = EncodingUtil.base64Decode(document),
            Title = documentType,
            ContentLocation = 's',
            PathOnClient = documentType
        );
        Insert contVer;
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contVer.Id].ContentDocumentId;
    }

    /**
    * @description Processes the content of a document and sends emails based on business rules
    * @param contentDocumentId ID of the ContentDocument to process
    */
    @TestVisible
    private static void extractFileData(String contentDocumentId) {
        List<String> gbSplitValues = getContentVersionData(contentDocumentId);
        Map<String, Date> bpNumMap = parseBPNumMap(gbSplitValues);
        Map<String, Account> accountEmailIds = getAccountsForBPNums(bpNumMap.keySet());
        Id orgWideEmailAddressId = getOrgWideEmailAddressId();
		Map<String, Id> templateMap=getEmailTemplateMap();
        Map<Integer, String> emailTemplatesMap = emailTemplates;
        for (String bpNum : accountEmailIds.keySet()) {
            processAccount(accountEmailIds.get(bpNum), bpNumMap.get(bpNum), orgWideEmailAddressId,templateMap,emailTemplatesMap);
        }
    }

    /**
    * @description Retrieves and splits content version data
    * @param contentDocumentId ID of the ContentDocument
    * @return List<String> Split content data
    */
    private static List<String> getContentVersionData(String contentDocumentId) {
        ContentVersion cv = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
        return cv.VersionData.toString().split('GB');
    }

    /**
    * @description Parses BP numbers and dates from split content data
    * @param gbSplitValues List of split content values
    * @return Map<String, Date> Map of BP numbers to their associated dates
    */
    private static Map<String, Date> parseBPNumMap(List<String> gbSplitValues) {
        Map<String, Date> bpNumMap = new Map<String, Date>();
        for(Integer i = 1; i < gbSplitValues.size() ; i++) {
              String gb = gbSplitValues[i];
            if (String.isNotBlank(gb)) {
                List<String> parts = gb.split('~');
                if (parts.size() > 4) {
                    bpNumMap.put(parts[4].trim(), stringToDate(parts[3]));
                }
            }
        }
        return bpNumMap;
    }

    /**
    * @description Retrieves Financial Accounts based on BP numbers
    * @param bpNums Set of BP numbers to query
    * @return Map<String, Account> Map of BP numbers to Financial Account records
    */
    private static Map<String, Account> getAccountsForBPNums(Set<String> bpNums) {
        Map<String, Account> accountMap = new Map<String, Account>();
        for(Account account : [
            SELECT id, ExternalCIFId__c, PersonEmail, PersonContactId FROM Account
            WHERE ExternalCIFId__c IN :bpNums
        ]) {
            accountMap.put(account.ExternalCIFId__c, account);
        }
        return accountMap;
    }

    /**
    * @description Retrieves org-wide email address ID from custom metadata
    * @return Id Organization-wide email address ID
    */
    @TestVisible
    private static Id getOrgWideEmailAddressId() {
        try{
        ICS_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :labelInfo.get('isleOfManOrgWideAddress') LIMIT 1];
        return orgWideEmail.Id;
        }catch(exception e){
            LOGGER.error('Error in getOrgWideEmailAddressId' + e.getMessage()); 
            return null;
        }
    }

    /**
    * @description Retrieves set of email template developer names from emailTemplates map
    * @return Set<String> Set of template developer names
    */
    private static set<String> getEmailTemplateDeveloperNames() {
        set<String> developerNames = new Set<String>();
        developerNames.addall(emailTemplates.values());
        return developerNames;
    }

    /**
    * @description Creates a map of template names to template IDs
    * @return Map<String, Id> Map of template names to their IDs
    */
    private static Map<String, Id> getEmailTemplateMap() {
        Map<String, Id> templateMap = new Map<String, Id>();
        for (EmailTemplate template : [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE name IN :getEmailTemplateDeveloperNames()]) {
            templateMap.put(template.name, template.Id);
        }
        return templateMap;
    }

    /**
    * @description Processes an account record and sends appropriate email based on account age
    * @param account Financial Account record to process
    * @param accountDate Date to calculate account age from
    * @param orgWideEmailAddressId Organization-wide email address ID to use
    */
    @TestVisible
    private static void processAccount(Account account, Date accountDate, Id orgWideEmailAddressId,Map<String, Id> templateMap,  Map<Integer, String> emailTemplatesMap) {
        Integer daysSinceAccountOpened = accountDate.daysBetween(System.today());
        for (integer days : emailTemplatesMap.keyset()) {
            if (daysSinceAccountOpened == days) {
                sendEmail(
                    account.PersonEmail,
                    templateMap.get(emailTemplatesMap.get(days)),
                    account.id,
                    orgWideEmailAddressId,
                    account.PersonContactId
                );
                break;
            }
        }
    }

    /**
    * @description Converts a string in format YYYYMMDD to a Date
    * @param dateString String date in format YYYYMMDD
    * @return Date Converted date
    */
    @TestVisible
    private static Date stringToDate(String dateString) {
        Integer year = Integer.valueOf(dateString.substring(0, 4));
        Integer month = Integer.valueOf(dateString.substring(4, 6));
        Integer day = Integer.valueOf(dateString.substring(6, 8));
        return Date.newInstance(year, month, day);
    }

    /**
    * @description Sends an email using the specified template and parameters
    * @param recipientEmail Email address to send to
    * @param templateId ID of the email template to use
    * @param whatId ID of the record to associate the email with
    * @param orgWideEmailAddressId Organization-wide email address ID to send from
    * @param targetId ID of the target Contact
    */
    @TestVisible
    private static void sendEmail(String recipientEmail, Id templateId, Id whatId, Id orgWideEmailAddressId, String targetId) {
        try {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { recipientEmail });
        mail.setTemplateId(templateId);
        mail.setWhatId(whatId);
        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        mail.setTargetObjectId(targetId);
            if(!test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        } catch(exception e) {
            LOGGER.error('Error in sendEmail' + e.getMessage());
        }
    }
    public static void createTask(string whatIdVal,string whoIdVal){
        Task ts = new Task();
        ts.Subject = 'test1';
        ts.TaskSubtype = 'Email';
        ts.ActivityDate = Date.today();
        ts.Description =  'emailtest1';
        ts.WhatID      =  whatIdVal;
        ts.WhoID       =  whoIdVal;
        ts.Status = 'Completed';
        insert ts;
    }

          @TestVisible
    private static void createCallLog(String serviceName, String request, string response,Boolean isSuccess) {
        try {
             CMN_WebserviceCallQueue__c queueItem = new CMN_WebserviceCallQueue__c();
        queueItem.CMN_Service__c = serviceName;
        if(isSuccess){
            queueItem.CMN_StatusCode__c = '200';
            queueItem.CMN_Status__c='Completed';
        }else{
            queueItem.CMN_StatusCode__c = '500';
            queueItem.CMN_Status__c='Failed';
        }
         Integer maxSize =131072;
             if(request.length() > maxSize ){
                    request = request.substring(0, maxSize);
            }

            if(response.length() > maxSize ){
                    response = response.substring(0, maxSize);
            }

        queueItem.CMN_Response__c=response;
        queueItem.CMN_Request__c=request;
            insert queueItem;
        } catch (Exception e) {
            LOGGER.error('Failed to create call log', new String[]{ 
                SERVICE_NAME, e.getMessage() }, e);
        }
    }
}