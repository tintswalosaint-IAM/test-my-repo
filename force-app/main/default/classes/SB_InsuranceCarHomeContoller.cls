/**
* @author            : Hasrat Mohammad
* @description       : Class to save data from omniscript to salesforce
* @date 			 : 31/10/2024
* @testclass 		 : SB_InsuranceCarHomeContoller_TEST
**/

global with sharing class SB_InsuranceCarHomeContoller implements omnistudio.VlocityOpenInterface{
    
    
    /**
* @purpose       : Method to be invoked by omniscript to create records.
* @parameter     : methodName,inputMap,outMap,options
* @return        : result 
**/    
    private static final sbgplatform.rflib_Logger logger = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SB_InsuranceCarHomeContoller');
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        Boolean result = true;
        
        try{
            if('convertLead'.equals(methodName)){   
                
                outMap = convertLead((String)inputMap.get('recordId'),inputMap,outMap);
                system.debug('outMap' + outMap);
            }

        } catch(Exception ex){           
            result = false;
            logger.error('SB_InsuranceCarHomeContoller : invokeMethod : Unhandled Exception '+ ex.getMessage() + ' Line Exception '+ ex.getLineNumber() + ' Stack trace: ' + ex.getStackTraceString());
        }
        system.debug('result: ' + result);
        return result;	      
    }
    

    
    
    /**
* @purpose       : Method to convert the lead
* @parameter     : recordId,inputMap,outMap
* @return        : outMap 
**/   
    public static Map<String, Object> convertLead(String recordId, Map<String, Object> inputMap,Map<String, Object> outMap){
        Lead lead = null;
        String objectApiName = ((Id)recordId)?.getSObjectType()?.getDescribe()?.getName();
        
        if('Lead'.equalsIgnoreCase(objectApiName)){
            lead = new SEL_Lead().selectLeadByLeadId(recordId);
            outMap = isLeadContext(lead,inputMap,outMap);
            system.debug('outMap : ' + outMap);
        }
        else if('Account'.equalsIgnoreCase(objectApiName)){
            List<Lead> leadList = new SEL_Lead().selectLeadByAccountId(recordId);
            
            if(leadList != null && !leadList.isEmpty() ){
                lead = leadList.get(0);
            }            
            outMap = isAccountContext(lead,inputMap,outMap);
            system.debug('outMap : ' + outMap);
        }
        return outMap;
    }
    
    /**
* @purpose       : Method to check if lead is converted
* @parameter     : lead,inputMap,outMap
* @return        : outMap 
**/   
    public static Map<String, Object> isLeadContext(Lead lead,Map<String, Object> inputMap,Map<String, Object> outMap){
        if(lead != null && String.isNotBlank(lead?.Id) && lead?.IsConverted == false){
            outMap = convertLeadRecord(lead,inputMap,outMap);
        }
        else if(lead?.IsConverted == true){
            outMap.put('AccountRecId', lead?.FinServ__RelatedAccount__c);
            SEL_Opportunity opportunitySelector = new SEL_Opportunity();
            Id opportunityRecId = opportunitySelector.getOpportunityIdByLeadId(lead.Id);
            outMap.put('OpportunityRecId',opportunityRecId);
        }
        system.debug('outMap : ' + outMap);
        return outMap;
    }
    
    /**
* @purpose       : Method to check if omniscript pass an account id
* @parameter     : lead,inputMap,outMap
* @return        : outMap 
**/   
    public static Map<String, Object> isAccountContext(Lead lead,Map<String, Object> inputMap,Map<String, Object> outMap){
        String accountId = (String)inputMap.get('recordId');
        
        if(lead != null && String.isNotBlank(lead?.Id) && lead?.IsConverted == false){
            outMap = convertLeadRecord(lead,inputMap,outMap);
        }
        else if(lead?.IsConverted == true){                
            outMap.put('AccountRecId', lead?.FinServ__RelatedAccount__c);
            SEL_Opportunity opportunitySelector = new SEL_Opportunity();
            Opportunity opportunityRecId = opportunitySelector.getOpenOpportunityByLeadId(lead.Id,'General','%Car and Home Insurance%');
            if(opportunityRecId == null && String.isNotBlank(accountId)){
                outMap = SB_InsuranceCarHomeHelper.createOpportunityFromAccount(accountId,outMap);
            }
            else{
            	outMap.put('OpportunityRecId',opportunityRecId?.Id);
            }
        }
        else if(lead == null && String.isNotBlank(accountId)){
            outMap = SB_InsuranceCarHomeHelper.createOpportunityFromAccount(accountId,outMap);
        }
        
        return outMap;
    }
    
    /**
* @purpose       : Method to convert the lead record
* @parameter     : lead,inputMap,outMap
* @return        : outMap 
**/  
    public static Map<String, Object> convertLeadRecord(Lead lead,Map<String, Object> inputMap,Map<String, Object> outMap){
        lead.FinServ__RelatedAccount__c = checkAccountId(lead,lead.FinServ__RelatedAccount__c, inputMap);
        lead.Description = leadDescription(lead,(String)inputMap.get('referrerFName'),(String)inputMap.get('referrerLName'));
        
        Lead leadUpdate = new Lead(Id = lead.Id,
                                   FinServ__RelatedAccount__c = lead.FinServ__RelatedAccount__c,
                                   Description = lead.Description 
                                  );
        
        Database.update(leadUpdate, AccessLevel.USER_MODE);
        
        String opportunityId = checkOpportunity(lead,(String)inputMap.get('referrerId'),(String)inputMap.get('leadSource'));
        
        if(String.isNotBlank(lead.FinServ__RelatedAccount__c) && 
           String.isNotBlank(lead.Id) &&
           String.isNotBlank(opportunityId)
          ){
              SB_InsuranceCarHomeHelper.createApplicationForm(lead.FinServ__RelatedAccount__c,lead.Id,opportunityId);
          }
        Database.LeadConvert leadconvert = new database.LeadConvert();
        Database.LeadConvertResult leadConversionResult;
        
        leadconvert.setLeadId(lead.Id);
        leadconvert.setAccountId(lead.FinServ__RelatedAccount__c);
        leadconvert.setOpportunityId(opportunityId);
        leadconvert.setDoNotCreateOpportunity(false);
        leadconvert.setConvertedStatus('Qualified');
        
        leadConversionResult = SB_InsuranceCarHomeHelper.convertLead(leadconvert);
        outMap.put('AccountRecId', leadConversionResult.getAccountId());
        outMap.put('OpportunityRecId', leadConversionResult.getOpportunityId());
        
        system.debug('outMap : ' + outMap);
        return outMap;
    }
    
    /**
* @purpose       : Method to update description of the lead
* @parameter     : lead,referrerFName,referrerLName
* @return        : leadDesc 
**/      
    public static String leadDescription(Lead lead,String referrerFName,String referrerLName){
        String leadDesc = leadDescriptionUpdateExternalReferrer(referrerFName,referrerLName); 
        
        if(String.isNotBlank(lead.Description) && String.isNotBlank(leadDesc)){
            lead.Description = lead.Description + ', ' + leadDesc;
        }
        else if(String.isBlank(lead.Description)){
            lead.Description = leadDesc;
        }
        
        return leadDesc;
    }
    
    /**
* @purpose       : Method to update description of the lead based on referrername
* @parameter     : referrerFName,referrerLName
* @return        : leadDesc 
**/    
    public static String leadDescriptionUpdateExternalReferrer(String referrerFName,String referrerLName){
        String leadDesc = ''; 
        if(String.isNotBlank(referrerFName) && String.isNotBlank(referrerLName)){
            leadDesc = 'External Referrer: ' + referrerFName + ', ' + referrerLName;
        }
        else if(String.isNotBlank(referrerFName)){
            leadDesc = 'External Referrer: ' + referrerFName;
        }
        else if(String.isNotBlank(referrerLName)){
            leadDesc = 'External Referrer: ' + referrerLName;
        }
        return leadDesc;
    }
    
    /**
* @purpose       : check to determine if it has account associated
* @parameter     : lead,accountId
* @return        : accountId 
**/  
    
    public  static String checkAccountId(Lead lead,String accountId, Map<String, Object> inputMap){
        if(String.isBlank(accountId)){
            accountId = SB_InsuranceCarHomeHelper.createAccount(lead,inputMap);
        }
        return accountId;
    }
    /**
* @purpose       : check to determine if opportunity has to be created or updated.
* @parameter     : lead,referrerId,leadSource
* @return        : opportunityId 
**/  
    public static String checkOpportunity(Lead lead,String referrerId,String leadSource){
        String opportunityId = '';
        SEL_Opportunity opportunitySelector = new SEL_Opportunity();
        Opportunity openOpportunity = opportunitySelector.getOpenOpportunityByLeadId(lead.Id,'General','%Car and Home Insurance%');
        
        if(String.isNotBlank(openOpportunity?.Id)){
            opportunityId = checkOpportunityMapping(openOpportunity,referrerId,leadSource);
        }
        else {
            opportunityId = SB_InsuranceCarHomeHelper.createOpportunityLead(lead,referrerId,leadSource);
        }
        return opportunityId;
    }
    /**
* @purpose       : check to determine if opportunity requires updates
* @parameter     : lead,referrerId,leadSource
* @return        : opportunityId 
**/ 
    @testVisible
    private static String checkOpportunityMapping(Opportunity opportunity,String referrerId,String leadSource){
        Boolean updateOpp = false;
        if(String.isNotBlank(referrerId)){
            opportunity.FinServ__ReferredByUser__c = referrerId; 
            updateOpp = true;
        }
        if(String.isNotBlank(leadSource)){
            opportunity.LeadSource = leadSource;
            updateOpp = true;
        }
        if(updateOpp == true){
            Database.update(opportunity, AccessLevel.USER_MODE);
        }
        return opportunity.Id;
    }
    

}