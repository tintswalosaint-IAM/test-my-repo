/**
* @description After update of lead trigger handler
*
* 
*
* @author Wipro
*
* @date July 2022
*/

public without sharing class INVM_TRG_Lead extends CMN_TRH_BaseObject
{
    /**
* @description After update handler
*
* @param oldSo - Old Lead
* @param so - New (Updated) Lead
*/
    public override void afterUpdate(SObject oldSo, SObject so)
    {
        super.afterUpdate(oldSo, so);
        onChangeLeadStatus((Lead)oldSo, (Lead)so); 
    } 
    
    
    /**
* @description After update handler
*
* @param oldSo - Old Lead
* @param so - New (Updated) Lead
*/
    public override void beforeUpdate(SObject oldSo, SObject so)
    {
        super.beforeUpdate(oldSo, so);
        
        Boolean callURL = String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('services/apexrest');
        Id LeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId();
        Lead lead = (Lead)so;
        if(callURL)
        {
            return;
        }else{
            if(LeadRecordTypeId == lead.RecordTypeId ){
                restrictStatus((Lead)oldSo, (Lead)so);
            }
        }    
        
    }
    
    /**
* @description method on change of lead status to UnQualified
*
* @param oldLead
* @param newLead
*/
    private void restrictStatus(Lead oldLead, Lead newLead)
    {
        String strQualifiedErrMessage = '';
        String strUnqualifiedErrMessage = '';
        Boolean isIPGenerated = true;
        if((oldLead.status != newLead.status))
        {
            Investment_Proposal__c invp = INVM_DAL_InvestmentProposal.selectIPByLead(oldLead.Id);
            if(invp.INVM_GeneratedOn__c == null){
                isIPGenerated = false;
                strQualifiedErrMessage = 'A lead cannot be qualified because an investment proposal has not been generated.';
                strUnqualifiedErrMessage = 'A lead cannot be unqualified because an investment proposal has not been generated.';           
            }           
            if(oldLead.Status == INVM_Constants.LEADQUALIFIED && newLead.Status != INVM_Constants.LEADQUALIFIED){
                newLead.Status.addError(System.Label.INVM_LeadStatusAlreadyQualified); 
            }else if(newLead.Status == INVM_Constants.LEADNEW){
                newLead.Status.addError(System.Label.INVM_RestrictLeadStatusToNew);    
            }else if(oldLead.Status != INVM_Constants.LEADQUALIFIED && newLead.Status == INVM_Constants.LEADQUALIFIED && isIPGenerated == false){
                newLead.Status.addError(strQualifiedErrMessage);
                
            }else if(oldLead.Status != INVM_Constants.UNQUALIFIED && newLead.Status == INVM_Constants.UNQUALIFIED && isIPGenerated == false){
                newLead.Status.addError(strUnqualifiedErrMessage);
            }
            
        }    
        
    }
    
    
    /**
* @description method on change of lead status to UnQualified
*
* @param oldLead
* @param newLead
*/
    private void onChangeLeadStatus(Lead oldLead, Lead newLead)
    {
        if((oldLead.status != newLead.status) && (newLead.status == INVM_Constants.UNQUALIFIED) 
           && newLead.Status == INVM_Constants.UNQUALIFIED && Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId() == newLead.RecordTypeId)
        {
            deleteAllInvestmentProposals(newLead, false);
        }else if(newLead.Status == INVM_Constants.LEADQUALIFIED && Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('INVM_LeadRecordType').getRecordTypeId() == newLead.RecordTypeId)
        {
            deleteAllInvestmentProposals(newLead, true);
        }
        
    }
    
    /**
* @description delete all Investment Proposal associated with lead
*
* 
* @param newLead
*/
    private void deleteAllInvestmentProposals(Lead newLead, boolean expectApproved)
    {
        
        Id leadId = newLead.Id;
        Investment_Proposal__c invP =  INVM_DAL_InvestmentProposal.selectIPByLead(leadId);
        deleteDocuments(invP.Id, expectApproved);
        updateInvestmentProposal(invP.Id, expectApproved,invP.INVM_GeneratedOn__c);
    }
    /**
* @description delete all Investment Proposal associated with Investment Proposal
*
* 
* @param investProId
*/
    public static void deleteDocuments(Id investProId , boolean expectApproved){
        try{
            list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
            
            for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: investProId Order by SystemModStamp desc]) {
                lstCntDocsToDelete.add(new ContentDocument(Id = iterator.ContentDocumentId));
            }
            
            if(!lstCntDocsToDelete.isEmpty() && lstCntDocsToDelete != null && lstCntDocsToDelete.size()>0) {       
                if(expectApproved){
                    lstCntDocsToDelete.remove(0);
                }
                Database.delete(lstCntDocsToDelete, false);   
            }   
            
        }catch(Exception e){
            CMN_UTIL_Logger.error(e, 'INVM_TRG_Lead.deleteDocuments');
            if (!System.Test.isRunningTest()){
                throw new AuraHandledException('Error Exception happend \r'+ 'Class: INVM_TRG_Lead \r Method:  deleteDocuments\r'+ '\r Cause: ' + e.getCause() + '\r ExceptionType: ' + e.getTypeName() +  '\rLine#: ' + e.getLineNumber() +  '\rStack Trace: ' + e.getStackTraceString() + '\rMessage: ' + e.getMessage()); 
            }
        }
    }  
    
    
    /**
* @description update investment proposal record when lead status is Unqualified
*
* 
* @param investProId
*/
    public static void updateInvestmentProposal(Id investProId, Boolean expectApproved, DateTime InvestmentProposalGeneratedDate)
    {
        List<Investment_Proposal__c> invpToUpdate = new List<Investment_Proposal__c>();
        Investment_Proposal__c invP = new Investment_Proposal__c();
        Boolean callFromRestAPI = String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('services/apexrest');
        invP.Id = investProId;
        if(expectApproved != true ){
        	invp.INVM_PackageId__c = '';
        	invp.INVM_DocumentId__c='';
            invP.INVM_GeneratedOn__c = null;
            invp.INVM_Status__c = null;
            invp.INVM_SentDate__c= null;
            invp.INVM_Client_RespondedDate__c = null;
            invp.INVM_ClientComments__c = '';
            invp.INVM_ClientResponse__c='';
            invp.INVM_LatestInvestmentProposal__c = '';
        }else if(!callFromRestAPI && InvestmentProposalGeneratedDate!= null){
            invp.INVM_Status__c = INVM_Constants.RECECEIVEDRESPONSE;
            invp.INVM_ClientResponse__c= INVM_Constants.CLIENTAPPROVERESPONSETORECORD ;
            invp.INVM_Client_RespondedDate__c = date.today();
            invp.INVM_ClientComments__c = INVM_Constants.CLIENTAPPROVERESPONSETORECORD + ' by Investment Manager manually based on client confirmation.';
            invp.INVM_Status__c = INVM_Constants.RECECEIVEDRESPONSE;
        }
        invpToUpdate.add(invp);
        CMN_DAL_SObjectDomain.updateDBObjects(invpToUpdate);      
    }
}