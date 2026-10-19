/**
* @description Class to handle generate investment proposal template using CSF integration 
*
* @author Wipro
*
* @date July 2022
*/
public class INVM_CSF_DocumentGeneration {
    
    private static final String CSF_API_ESB_ACCESS_TOKEN_Dev = 'CSF_API_ESB_ACCESS_TOKEN_DEV';
    private static final String CSF_API_ESB_ACCESS_TOKEN_PROD = 'CSF_API_ESB_ACCESS_TOKEN_PROD';
    Private static String InvestmentProposalId;
    Private static String ProposedRiskMandate;
    Private static String LeadName;
    Private static String errType; 
    private static final String TEST_SETTING = 'CSF_API_RestOutboundExample';
    @TestVisible static  String stringError;
    /**
* @description call CSF service to generate investment proposal template
*
* @param recordId
* 
*/
    
    @AuraEnabled   
    public static void callCSFServiceToGeneratePDF(Id recordId){
        try{
            
            List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{recordID});
            if(lstInvProp.size()>0){
                InvestmentProposalId = lstInvProp[0].Id;
                ProposedRiskMandate = lstInvProp[0].INVM_ProposedRiskMandate__c;
                LeadName = lstInvProp[0].Lead__r.Name;    
                String docTitle = lstInvProp[0].INVM_ProposedRiskMandate__c +'_' +lstInvProp[0].Lead__r.Name + '_' + Datetime.now().format('yyyy-MM-dd HH:mm');
                CMN_DTO_AuthenticationResponse accessResponse = INVM_CSF_API_DocumentGeneration.getAccessToken('document prod write');
                if(accessResponse != null ){
                    String accessToken = accessResponse.access_token;
                    HttpResponse responseCSFTemplate = INVM_CSF_API_DocumentGeneration.getDocumentTemplate(accessToken,lstInvProp);
                    if(responseCSFTemplate!= null){
                        String strBase64 = parseCSFResponse(responseCSFTemplate.getBody());
                        if(saveInvestmentProposalToFile(strBase64,docTitle,lstInvProp[0].Id)){
                            updateInvestmentProposalRecord(docTitle,lstInvProp[0].Id); 
                            updateLeadRecord(lstInvProp[0].INVM_LeadId__c);
                        }  
                    }
                }
            }
        }catch (Exception e) {
            CMN_UTIL_Logger.error(e, 'CSF_DocumentGeneration.callCSFServiceToGeneratePDF');
            if(!test.isRunningTest()){
                throw new AuraHandledException('Error Exception happend \r'+ 'Class: CSF_DocumentGeneration \r Method:  callCSFServiceToGeneratePDF\r'+'Investment Proposal Id: '+ InvestmentProposalId + '\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + e.getMessage()); 
            }			
        }
    }
    
    /**
* @description update lead to nurturing when template generated successfully
*
* @param leadId
* 
*/
    public static void updateLeadRecord(Id leadId)
    {
        List<Lead> leadToUpdate = new List<Lead>();
        Lead lead = new Lead();
        lead.Id = leadId;
        lead.Status = INVM_Constants.LEADNURTURING;
        leadToUpdate.add(lead);
        CMN_DAL_SObjectDomain.updateDBObjects(leadToUpdate);
    }
    
    /**
* @description email error notification
*
* @param exceptionString
* 
*/
    @AuraEnabled
    public static void sendExceptionEmail(String exceptionString){
        try{
            String emailSubj;
            String emailBody;
            String sBody;
            stringError = exceptionString;
            emailSubj = 'Salesforce and CSF Integration Error' ;
            emailBody = 'This message was created automatically by the mail system.\r\r\r';
            emailBody += 'Hi Team, \r';
            emailBody += 'An exception occurred while generating the investment proposal document through CSF.\r';
            emailBody += 'Please find the details below:\r\r';
            emailBody += exceptionString;
            emailBody += '\r\rPlease note: for more details, please login into Salesforce and view the app log records.';
            emailBody += '\r\rThanks';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(emailSubj);
            mail.setPlainTextBody(emailBody);
            mail.setSenderDisplayName('Salesforce and CSF Integration Error');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setToAddresses(getToAddresses());
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(Exception e){
            CMN_UTIL_Logger.error(e, 'INVM_CSF_DocumentGeneration.sendExceptionEmail');
        }
    }
    
    /**
* @description fetch email addresses to send error notification email
*
* 
*/
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
            if(webServiceSetting.INVM_CSFSupportTeamEmails__c!=''){
                emailAddresses = emailAddresses +',' + webServiceSetting.INVM_CSFSupportTeamEmails__c;
            }
            toAddresses = emailAddresses.split(',');
        }
        return toAddresses;
    }
    
    public static String getMetadataName() {
        if(isSandbox()) {
            return CSF_API_ESB_ACCESS_TOKEN_Dev;
        }
        
        return CSF_API_ESB_ACCESS_TOKEN_PROD;
    }
    
    /**
* @description This method determines if the Current Organization is a Sandbox or Production Instance
*
* @return Boolean isSandbox
*/
    public static Boolean isSandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    /**
* @description update investment proposal record with generated template file name
*
* @param fileTitle
* @param parentId
* 
*/
    
    
    
    public static void updateInvestmentProposalRecord(String fileTitle, Id parentId){
        List<Investment_Proposal__c> investmentProposalToUpdate = new List<Investment_Proposal__c>();
        Investment_Proposal__c invP = new Investment_Proposal__c();
        invP.Id = parentId;
        invP.INVM_GeneratedOn__c = Datetime.now();
        invp.INVM_Status__c = INVM_Constants.STATUSGENERATED;
        invp.INVM_SentDate__c= null;
        invp.INVM_PackageId__c = '';
        invp.INVM_DocumentId__c='';
        invp.INVM_LatestInvestmentProposal__c  = fileTitle;
        invp.INVM_ClientResponse__c='';
        invp.INVM_ClientComments__c='';
        invp.INVM_Client_RespondedDate__c = null;
        
        investmentProposalToUpdate.add(invp);  
        CMN_DAL_SObjectDomain.updateDBObjects(investmentProposalToUpdate);
    }
    
    /**
* @description parse CSF API reposon
*
* @param strCSFResponse
* 
*/
    public static String parseCSFResponse(string strCSFResponse){
        Dom.Document doc = new Dom.Document();  
        doc.load(strCSFResponse);  
        Dom.XMLNode rootElement = doc.getRootElement();  
        for ( Dom.XMLNode childElement : rootElement.getChildElements() ) {
            if(childElement.getName() =='Data' && childElement.getText() != ''){
                return childElement.getText();
            }
            for (Dom.XMLNode detailElement : childElement.getChildElements()){
                if(detailElement.getName() =='Data' && detailElement.getText() != ''){
                    return detailElement.getText();
                }
                for (Dom.XMLNode detailElement1 : detailElement.getChildElements()){
                    if(detailElement1.getName() =='Data' && detailElement1.getText() != ''){
                        return detailElement1.getText();
                    }
                }
            } 
        }
        return '';
    }
    
    
    /**
* @description save pdf base64 string to Investment Proposal's Notes & Attachment related list
*
* @param strBase64
* @param docTitle
* @param parentId
* return boolean
*/
    public static boolean saveInvestmentProposalToFile(String strBase64, String docTitle, Id parentId){
        try{
            Blob fileABlob = EncodingUtil.base64Decode(strBase64);
            ContentVersion contentVersion1 = new ContentVersion(
                Title = docTitle,
                PathOnClient = docTitle + '.pdf',
                VersionData = fileABlob,
                origin = 'H',
                IsMajorVersion = true,
                FirstPublishLocationId  = userinfo.getUserId()
            );
            
            insert contentVersion1;
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion1.Id].ContentDocumentId;
            ContentDocumentLink conDocLink = New ContentDocumentLink(
                LinkedEntityId = parentId,
                ContentDocumentId = conDoc,
                shareType = 'V'
            );
            
            insert conDocLink;
            return true;
            
        }catch(Exception e){
            CMN_UTIL_Logger.error(e, 'CSF_DocumentGeneration.saveInvestmentProposalToFile');
        }
        return false;
    }
    
    /**
* @description get errors before generating template
*
* @param recordId
*  
*/
    @AuraEnabled 
    public static string getSendingErrors(Id recordId){
        String strValidationError;
        List<ContentVersion> cv;
        List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{recordID});
        if(lstInvProp.size() == 1){
            Investment_Proposal__c invp = lstInvProp[0];
            list<ContentDocument> lstCntDocs = new list<ContentDocument>();
            for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId WITH SECURITY_ENFORCED Order by SystemModStamp desc]) {
                lstCntDocs.add(new ContentDocument(Id = iterator.ContentDocumentId));
            }
            
            if(invP.INVM_RespondedDate__c != null && invP.LastModifiedDate == invP.INVM_RespondedDate__c.addSeconds(1)){
                 return 'Please make changes in Investment Proposal record, before generate investment proposal';
            }
            if(invP.LastModifiedDate == invP.INVM_GeneratedOn__c ) {
                return 'Please make changes in Investment Proposal record, before generate investment proposal';
            }else if(invP.INVM_InvestmentObjective__c == null){
            	return System.Label.INVM_IP_ValidationError;
        	}else if(invp.Lead__r.Status == INVM_Constants.UNQUALIFIED){
                
                return String.format(System.Label.INVM_LeadUnqualified,
                                     new List<String>{'Generate'});
            }else if(invp.Lead__r.Status == INVM_Constants.LEADQUALIFIED){
                return String.format(System.Label.INVM_LeadQualified,
                                     new List<String>{'Generate'});
                
            }else if(lstCntDocs.size()>0){
                ContentDocumentLink docLink = [SELECT ID,ContentDocument.CreatedDate,ContentDocumentId, LinkedEntityId , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =:recordId Order by  ContentDocument.CreatedDate Desc Limit 1];
                if(docLink!= null){
                    cv = [SELECT ContentDocumentId,VersionData,Title  from ContentVersion where ContentDocumentId =: docLink.ContentDocumentId order by CreatedDate DESC];
                }
                if(cv!= null && cv.size() == 1 && cv[0].Title == invp.INVM_LatestInvestmentProposal__c && invp.INVM_Status__c == INVM_Constants.SENTFORAPPROVAL){
                    return System.Label.INVM_IP_SentForApproval; 
                } 
            }
        }
        return '';
    }    
    
}