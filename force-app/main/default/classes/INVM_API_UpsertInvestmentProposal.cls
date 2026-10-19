/**
* @description Class to handle Inbound login to update Investment proposal
* based on the Client Response through SigningHub 
* 
*
* @author Wipro
*
* @date July 2022
*/
@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public inherited sharing class INVM_API_UpsertInvestmentProposal extends CMN_API_RestBaseInbound {
    public static final String SERVICE_NAME = INVM_API_UpsertInvestmentProposal.class.getName();
    private Investment_Proposal__c invP;
    private static final String INVM_SIGNINGHUB_API_ESB_DEV = 'INVM_SigningHub_API_ESB_Dev';
    private static final String INVM_SIGNINGHUB_API_ESB_PROD = 'INVM_SigningHub_API_ESB_Prod';
    private static final String TEST_SETTING = 'CSF_API_RestOutboundExample';
    /**
* @description Initialise variable Object variables
*/
    protected override void initialise()
    {
        super.initialise();
        
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    
    /**
* @description register all the object types we want to update
*/
    protected override void setUnitOfWorksObjectTypes()
    {
        super.setUnitOfWorksObjectTypes();
        addSObjectTypes(new List<Schema.SObjectType> {Investment_Proposal__c.SObjectType});
    }
    
    /**
* @description Process the request by checking the request is valid and then finding item to upsert
*/
    protected override void processRequest()
    {
        try{
            super.processRequest();            
            DTO_Request dtoRequest = (DTO_Request)baseRequestDTO;
            if(dtoRequest.documentId != null && dtoRequest.packageId != null)
            {
                //Check to see the documentId & packageId is valid
                Investment_Proposal__c investmentProposal =INVM_DAL_InvestmentProposal.selectIPByPackageDocumentId(dtoRequest.packageId,dtoRequest.documentId);
                if(investmentProposal != null ){
                    Id invPId = investmentProposal.Id;	
                    invP = new Investment_Proposal__c();
                    invP.Id = invPId;
                    invP.INVM_PackageId__c = dtoRequest.packageId;
                    invP.INVM_DocumentId__c = dtoRequest.documentId;
                    invP.INVM_ClientResponse__c = dtoRequest.clientResponse;
                    invP.INVM_ClientComments__c = dtoRequest.strAddtionalComments;
                    invP.INVM_Status__c = INVM_Constants.RECECEIVEDRESPONSE;
                    invP.INVM_Client_RespondedDate__c = Datetime.now();
                    if(dtoRequest.clientResponse==INVM_Constants.CLIENTAPPROVERESPONSETORECORD){
                        deleteOlderInvestmentProposals(invPId); 
                    }
                    updateLead(investmentProposal, dtoRequest.clientResponse);
                    sendCustomNotificationToOwner(dtoRequest.packageId,dtoRequest.documentId, dtoRequest.clientResponse); 
                }
            }
        }catch(Exception ex){
            CMN_UTIL_Logger.error(ex, 'INVM_URL_InvestmentProposal.upsertInvestmentProposal');
            sendExceptionEmail(ex);
            throw new inboundException('Salesforce Error: '+ 'Class: INVM_API_UpsertInvestmentProposal ; Method:  processRequest ;  Cause: ' + ex.getCause() + ' ; ExceptionType: ' + ex.getTypeName() +  ' ; Line#: ' + ex.getLineNumber() +  ' ; Stack Trace: ' + ex.getStackTraceString() + ' ; Message: ' + ex.getMessage());
        }
    }
    
    /**
* @description delete all UnApproved Investment Proposal document
* @param investProId
*/
    public static void deleteOlderInvestmentProposals(Id investProId){
        list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
        for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: investProId Order by SystemModStamp desc]) {
            lstCntDocsToDelete.add(new ContentDocument(Id = iterator.ContentDocumentId));
        }
        if(!lstCntDocsToDelete.isEmpty() && lstCntDocsToDelete != null && lstCntDocsToDelete.size()>1) {
            lstCntDocsToDelete.remove(0);
            CMN_DAL_SObjectDomain.deleteDBObjects(lstCntDocsToDelete);
        }
    }
    
    /**
* @description Update lead record of associated Investment Proposal based on the client response
* @param invp
* @param strClientResponse
*/
    public static void updateLead(Investment_Proposal__c invp, String strClientResponse ){
        List<Lead> leadToUpdate = new List<Lead>();
        if (invP !=null){
            Lead updateLead = new Lead();
            updateLead.Id = invp.Lead__r.Id;
            if (strClientResponse == INVM_Constants.CLIENTAPPROVERESPONSETORECORD){
                updateLead.Status = INVM_Constants.LEADQUALIFIED;
            }
            upsert updateLead;
        }
    }
    
    /**
* @description send custom notification to investment proposal owner when client responded 
* @param packageId
* @param  documentId
* @param strClientResponse
*/
    public static void sendCustomNotificationToOwner(String packageId, String documentId, String clientResponse){
        String notiBody;
        Investment_Proposal__c invP =INVM_DAL_InvestmentProposal.selectIPByPackageDocumentId(packageId,documentId);
        Id typeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'INVM_Investment_Proposal_Client_Response_Notification'].Id;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(System.Label.INVM_ClientResponseNotificationTitle);
        notiBody = String.format(
            System.Label.INVM_ClientResponseNotificationBody,
            new List<String>{
                invP.Owner.Name,
                    invP.Lead__r.Name,
                    clientResponse,
                    invP.INVM_SentDate__c.format()
                    }
        );
        notification.setBody(notiBody);
        notification.setNotificationTypeId(typeId);
        notification.setTargetId(invP.Id);
        notification.send(new Set<String> { invP.OwnerId });
    }
    
    protected override void registerDatabaseChanges()
    {
        super.registerDatabaseChanges();
        registerChange(invP);
    }
    
    
    protected override void updateResponseDTO()
    {
        super.updateResponseDTO();
        
        DTO_Response dtoResponse = (DTO_Response)baseResponseDTO;
        
        dtoResponse.investmentProposalId = invP.Id;
        
    }
    
    
    /**
* @description The DTO representing the request being sent
*/
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        public String documentId;
        public String packageId;
        public String clientResponse;
        public String strAddtionalComments;
        protected override Type getObjectType()
        {
            return DTO_Request.class;
        }
    }
    
    /**
* @description DTO representing a successful response
*/
    @SuppressWarnings('PMD.VariableNamingConventions') // Required in non standard format for external API
    private class DTO_Response extends CMN_DTO_JsonBase
    {
        /**
* @description Investment Proposal Id, could for an existing interaction or new one
*/
        public String investmentProposalId;
    }
    
    
    public static void sendExceptionEmail(Exception e){
        String emailSubj;
        String emailBody;
        String exceptionString = 'Error Exception happend \r'+ 'Class: INVM_URL_InvestmentProposal \r Method:  upsertInvestmentProposal\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + e.getMessage();
        emailSubj = 'Salesforce and SigningHub Integration Error' ;
        emailBody = 'This message was created automatically by the mail system.\r\r\r';
        emailBody += 'Hi Team, \r\r\r';
        emailBody += 'Exception occured during Inbound Integration between SigningHub and Salesforce.\r';
        emailBody += 'Please find the detail below:\r\r';
        emailBody += exceptionString;
        emailBody += '\r\rThanks';
        
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(emailSubj);
        mail.setPlainTextBody(emailBody);
        mail.setSenderDisplayName('Salesforce and SigningHub Errors');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setToAddresses(getToAddresses());
        Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
    }
    
    public static List<String> getToAddresses(){
        String serviceName = getMetadataName();
        CMN_WebserviceSetting__mdt webServiceSetting = [SELECT Id, DeveloperName,  CMN_Path__c, CMN_NamedCredential__c,CMN_AdditionalKey__c,CMN_ClientID__c,CMN_Client_Secret__c,  INVM_CSFEndPoint__c, INVM_CSFRequestBody__c, INVM_ProposalTemplateBody__c,INVM_CSFSupportTeamEmails__c,INVM_SFSupportTeamEmails__c, INVM_SigningHubSupportTeamEmails__c, INVM_SigningHub_PingClientId__c, INVM_SigningHub_PingSecretId__c, INVM_LawtrustAuth__c FROM CMN_WebserviceSetting__mdt Where DeveloperName =: serviceName Limit 1];
        webServiceSetting = webServiceSetting == null && Test.isRunningTest() ? CMN_WebserviceSetting__mdt.getInstance(TEST_SETTING) : webServiceSetting;
        
        List<String> toAddresses = new List<String>();
        String emailAddresses;
        if(webServiceSetting != null) {
            if(webServiceSetting.INVM_SFSupportTeamEmails__c!= ''){
                emailAddresses = webServiceSetting.INVM_SFSupportTeamEmails__c;
            }
            if(webServiceSetting.INVM_SigningHubSupportTeamEmails__c!=''){
                emailAddresses = emailAddresses +',' + webServiceSetting.INVM_SigningHubSupportTeamEmails__c;
            }
            toAddresses = emailAddresses.split(',');
            
        }
        return toAddresses;
    }
    
    public static String getMetadataName() {
        if(isSandbox()) {
            return INVM_SIGNINGHUB_API_ESB_DEV;
        }
        
        return INVM_SIGNINGHUB_API_ESB_PROD;
    }
    
    /**
* @description This method determines if the Current Organization is a Sandbox or Production Instance
*
* @return Boolean isSandbox
*/
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    public class inboundException extends Exception {}    
}