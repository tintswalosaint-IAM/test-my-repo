/**
* @description Class to send investment proposal template using signinghub 
*
* @author Wipro
*
* @date July 2022
*/
public with sharing class INVM_SigningHub_SendInvestmentProposal {
    Private static String InvestmentProposalId;
    //Private static String errType='';
    private static final String INVM_SigningHub_API_ESB_Dev = 'INVM_SigningHub_API_ESB_Dev';
    private static final String INVM_SigningHub_API_ESB_Prod = 'INVM_SigningHub_API_ESB_Prod';
    private static final String TEST_SETTING = 'CSF_API_RestOutboundExample';    
    /**
* @description call signingHub service to send investment proposal template
*
* @param recordId
* 
*/
    @AuraEnabled 
    public static void callSHServiceToSendInvestmentProposal(Id recordId){
        try{
            CMN_DTO_AuthenticationResponse accessResponse = INVM_SigningHub_API_SendInvProposal.getAccessToken('document prod write'); 
            String accessToken = accessResponse.access_token;
            
            InvestmentProposalId = recordId;
            String responseBody = INVM_SigningHub_API_SendInvProposal.sendInvestmentProposal(accessToken,recordId).getBody();
            INVM_CreatePackageAPIResponse apiResponse = INVM_CreatePackageAPIResponse.parse(responseBody);
            try{
                if(apiResponse == null){
                    throw new OtherException('Issue with SigningHub API, returning null response');
                }
            }catch(BaseException e){
                CMN_UTIL_Logger.error(e, 'INVM_SigningHub_SendInvestmentProposal.callSHServiceToSendInvestmentProposal');
                throw new AuraHandledException('Error Exception happend \r'+ 'Class: INVM_SigningHub_SendInvestmentProposal \r Method:  callSHServiceToSendInvestmentProposal\r'+'Investment Proposal Id: '+ InvestmentProposalId + '\r ExceptionType: ' + e.getTypeName() +  '\rMessage: Error in getting access token' );
            }
            if  (apiResponse != null && apiResponse.shareDocumentResponses != null && apiResponse.uploadDocumentResponses != null){
                updateInvestmentProposalRecord(apiResponse.shareDocumentResponses[0].packageId,apiResponse.uploadDocumentResponses[0].documentId, recordId );
            }
        }catch (Exception e) {
            CMN_UTIL_Logger.error(e, 'INVM_SigningHub_SendInvestmentProposal.callSHServiceToSendInvestmentProposal');
            if(!test.isRunningTest()){
                 throw new AuraHandledException('Error Exception happend \r'+ 'Class: INVM_SigningHub_SendInvestmentProposal \r Method:  callSHServiceToSendInvestmentProposal\r'+'Investment Proposal Id: '+ InvestmentProposalId + '\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + e.getMessage()); 
            }
           
        }
    }
    
    /**
* @description update investment proposal record with package id and document id received from signingHub API 
*
* @param packageId unique package id from signinghub
* @param documentId unique document id from signinghub
* @param investmentProposalId Investment Proposal Id
* 
*/
    
    public static void updateInvestmentProposalRecord(String packageId, String documentId, Id investmentProposalId){
        
        List<Investment_Proposal__c> investProposalToUpdate = new List<Investment_Proposal__c>();
        Set<Id> investProposalId = new Set<Id>();
        investProposalId.add(investmentProposalId);
        investProposalToUpdate = INVM_DAL_InvestmentProposal.selectByIds(investProposalId);
        
        List<Investment_Proposal__c> investmentProposalToUpdate = new List<Investment_Proposal__c>();
        
        for (Investment_Proposal__c InvestProposalRecord : investProposalToUpdate) {
            InvestProposalRecord.INVM_SentDate__c = Datetime.now();
            InvestProposalRecord.INVM_DocumentId__c = documentId;
            InvestProposalRecord.INVM_PackageId__c = packageId;
            InvestProposalRecord.INVM_Status__c = INVM_Constants.SENTFORAPPROVAL;
            investmentProposalToUpdate.add(InvestProposalRecord);
        }
        CMN_DAL_SObjectDomain.updateDBObjects(investmentProposalToUpdate);
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
            
            emailSubj = 'Salesforce and SigningHub Integration Error' ;
            emailBody = 'This message was created automatically by the mail system.\r\r\r';
            emailBody += 'Hi Team, \r\r\r';
            emailBody += 'Exception occured while sending Investment Proposal Document through SigningHub.\r';
            emailBody += 'Please find the detail below:\r\r';
            emailBody += exceptionString;
            emailBody += '\r\rThanks';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(emailSubj);
            mail.setPlainTextBody(emailBody);
            mail.setSenderDisplayName('Salesforce and SigningHub Integration Error');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setToAddresses(getToAddresses());
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }catch(Exception e){
            CMN_UTIL_Logger.error(e, 'INVM_SigningHub_SendInvestmentProposal.sendExceptionEmail');
            if(!test.isRunningTest()){
                throw new AuraHandledException('Error Exception happend \r'+ 'Class: INVM_SigningHub_SendInvestmentProposal \r Method:  sendExceptionEmail\r'+'Investment Proposal Id: '+ InvestmentProposalId + '\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + e.getMessage()); 
            }
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
            if(webServiceSetting.INVM_SigningHubSupportTeamEmails__c!=''){
                emailAddresses = emailAddresses +',' + webServiceSetting.INVM_SigningHubSupportTeamEmails__c;
            }
            toAddresses = emailAddresses.split(',');
            
        }
        return toAddresses;
    }
    
    public static String getMetadataName() {
        if(isSandbox()) {
            return INVM_SigningHub_API_ESB_Dev;
        }
        
        return INVM_SigningHub_API_ESB_Prod;
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
* @description get errors before sending investment proposal template to client
*
* @param recordId
*  
*/
    @AuraEnabled 
    public static string getSendingErrors(Id recordId){
        List<ContentVersion> cv;
        List<Investment_Proposal__c> lstInvProp = INVM_DAL_InvestmentProposal.selectByIds(new Set<Id>{recordID});
        if(lstInvProp.size() == 1){
            Investment_Proposal__c invp = lstInvProp[0];
            if(invp.Lead__r.Email == null){
                return System.Label.INVM_LeadEmailEmpty;              
            }
            
            if(invp.Lead__r.Status == INVM_Constants.LEADQUALIFIED){
                return String.format(System.Label.INVM_LeadQualified,
                                     new List<String>{'Send'});
            }
            
            if(invp.Lead__r.Status == INVM_Constants.UNQUALIFIED){
                return String.format(System.Label.INVM_LeadUnqualified,
                                     new List<String>{'Send'});
            }
            
            list<ContentDocument> lstCntDocs = new list<ContentDocument>();
            
            for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId Order by SystemModStamp desc]) {
                lstCntDocs.add(new ContentDocument(Id = iterator.ContentDocumentId));
            }
            
            if(lstCntDocs.size()==0){
                return System.Label.INVM_NoInvestmentProposalGenerated;
                
            }else{
                ContentDocumentLink docLink = [SELECT ID,ContentDocument.CreatedDate,ContentDocumentId, LinkedEntityId , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =:recordId Order by  ContentDocument.CreatedDate Desc Limit 1];
                if(docLink!= null){
                    cv = [SELECT ContentDocumentId,VersionData,Title  from ContentVersion where ContentDocumentId =: docLink.ContentDocumentId order by CreatedDate DESC];
                }
                if(cv!= null && cv.size()==1){
                    String fileTitle = cv[0].Title;
                    if(fileTitle != invp.INVM_LatestInvestmentProposal__c){
                        return System.Label.INVM_LatestFileNotAvailable;
                        
                    }
                    if(fileTitle == invp.INVM_LatestInvestmentProposal__c && invp.INVM_Status__c ==INVM_Constants.SENTFORAPPROVAL){
                        return System.Label.INVM_InvestmentProposalSent;
                    }
                    if(fileTitle == invp.INVM_LatestInvestmentProposal__c && invp.INVM_Status__c ==INVM_Constants.RECECEIVEDRESPONSE){
                        return System.Label.INVM_ConsentReceived;
                    }
                }
            }
        }
        
        
        return '';
    }
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
}