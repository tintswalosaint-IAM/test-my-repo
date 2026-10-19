/**
* @description This class is used as call the CIPA api
* @author Dayakar 
* @date Jan 5th 2021
* @last modified on  : 03-08-2023
* @last modified by  : Ramya Gurram
* @ Modification Description : added  AOB_Director__c=true  for select query to check cipa validation for only directors
*/

public without sharing class AOB_BOTS_UTIL_CIPAIntegration {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_GetAccessToken');
    PUBLIC STATIC String mockCompanyStatus;
    
    /**
* @description This method is used as call the cipa api
 * @param applicationId
* @author Dayakar 
* @date Jan 5th 2021
* @return cipa status
*/
    
    @auraEnabled(cacheable=false)
    public static Map<String, String> makeCallout(String applicationId){
        String retVal;
        String cinVal;
        Application__c app=[select id,AOB_RegistrationNumber__c from Application__c where Id=:applicationId];
        cinVal=app.AOB_RegistrationNumber__c;
        AOB_BOTS_API_CIPAIntegration customerServiceCall = new AOB_BOTS_API_CIPAIntegration(cinVal);
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_BOTS_API_CIPAIntegration.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        Map<String, String> cipaValidation = new Map<String, String>();
        if(customerServiceCall.getResponseStatusCode()==200){
            List<Object> results = (List<Object>) JSON.deserializeUntyped(customerServiceCall.getResponseBody());
            retVal = JSON.serialize(results[0]);
            Map<String,Object> attributes; 
            if(!String.isEmpty(retVal)){
                attributes = (Map<String,Object>)JSON.deserializeuntyped(retVal);
                cipaValidation=validate(attributes,applicationId);
            }
            
        }else{
            cipaValidation.put('status','null');
            cipaValidation.put('IsDirectorDetailsSuccess','false');
            
        }
        
        return cipaValidation;
    }
    
    /**
* @description This method is used as call the cipa validate api
 * @param cipaResponseMap
  * @param applicationid
* @author Dayakar 
* @date Jan 5th 2021
* @return cipa status
*/
    
    @auraEnabled(cacheable=false)
    public static Map<String, String> validate(Map<String,Object> cipaResponseMap,string applicationid){
        Map<String, String> ciparesponse= new Map<String, String>();
        List<Application_Participant__c> participants = [select id,AOB_FullName__c,AOB_Director__c,Application__c from Application_Participant__c where Application__c=:applicationid and AOB_Director__c=true];
        String retVal;
        Map<String,Object> domTree = (Map<String,Object>)JSON.deserializeuntyped(JSON.serialize(cipaResponseMap.get('domainTree')));
        Map<String,Object> attributes = (Map<String,Object>)JSON.deserializeuntyped(JSON.serialize(domTree.get('attributes')));
        String companyStatus = (String)attributes.get('Status');
        ciparesponse.put('status',companyStatus);
        String successStatus = Test.isRunningTest()?mockCompanyStatus:Label.AOB_BOTS_CIPA_SuccessStatus;
        retVal='false';
        if(companyStatus=='registered'){
            List<AOB_BOTS_WRP_CIPAResponse> directors = (List<AOB_BOTS_WRP_CIPAResponse>)JSON.deserialize(JSON.serialize(domTree.get('directors')),List<AOB_BOTS_WRP_CIPAResponse>.class);
            for(AOB_BOTS_WRP_CIPAResponse dirRec : directors){
                for(Application_Participant__c participant : participants){
                    if(participant.AOB_FullName__c==dirRec.names[0].attributes.FullName){
                        retVal='true';
                    }else{
                        retVal='false';
                    }
                }
            }
        }
        if(retVal=='true'){
            Application_Participant__c appRec = [select id,AOB_Stage__c,AOB_TECH_OTPATTEMS__c,AOB_Retry_Count__c,Application__c,CNGCU_Phone__c ,AOB_Signatory__c,AOB_KeyContactPerson__c,CNGCU_Email__c from Application_Participant__c where Application__c=:applicationId and AOB_Signatory__c=true and AOB_KeyContactPerson__c=true Limit 1];
            appRec.AOB_Stage__c='CIPA Verified';
            update appRec;
        }if(retVal=='false'){
            Application__c appid=[select id,Status__c,AOB_Lead__c from Application__c where id=:applicationId];
            Lead ld=[Select id,AOB_Status__c from Lead where id=:appid.AOB_Lead__c];
            ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_ACQ' Limit 1].Queue.Id;
            ld.OwnerId = queueId;
            ld.AOB_Status__c='CIPA - Director details Mismatch';
            appid.Status__c='Cancelled';
            update ld;
            
        }
        if(companyStatus=='cancelled'){
            Application__c appid=[select id,Status__c,AOB_Lead__c from Application__c where id=:applicationId];
            Lead ld=[Select id,AOB_Status__c from Lead where id=:appid.AOB_Lead__c];
            ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_ACQ' Limit 1].Queue.Id;
            ld.OwnerId = queueId;
            ld.AOB_Status__c='CIPA - Company Cancelled';
            appid.Status__c='Cancelled';
            update ld;
            update appid;
            
        }if(companyStatus=='removed'){
            Application__c appid=[select id,Status__c,AOB_Lead__c from Application__c where id=:applicationId];
            Lead ld=[Select id,AOB_Status__c from Lead where id=:appid.AOB_Lead__c];
            ID queueId = [SELECT Queue.Id FROM queuesobject WHERE queue.name='AOB_Bots_BCC_ACQ' Limit 1].Queue.Id;
            ld.OwnerId = queueId;
            ld.AOB_Status__c='CIPA - Company Removed';
            appid.Status__c='Cancelled';
            update ld;
            update appid;
            
        }
        ciparesponse.put('IsDirectorDetailsSuccess',retVal);
        
        return ciparesponse;
    }
}