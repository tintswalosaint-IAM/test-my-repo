/**
 * @description       : This methos is used for Trigger Handler class
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 23-04-2024
 * @last modified by  : Nagendra Mylavarapu
**/
public without sharing class SVC_TRH_PartyIdentityVerification extends CMN_TRH_BaseObject {
    private static Set<Id> partyIdentityVerificationIds = new Set<Id>();
    public Static Map<String,String> srcToTrgPIVMap = new Map<String,String>{'Id Validation'=>'WFR','WFR'=>'Success'};
    private static sbgplatform.fflib_SObjectUnitOfWork uow = new sbgplatform.fflib_SObjectUnitOfWork(new List<SObjectType> { PartyIdentityVerification.SObjectType, PartyScreeningSummary.SObjectType });
    private Static String success = 'Success';
    private Static String completed = 'Completed';

    /**
        * @description This method is called prior to execution of a BEFORE Trigger. 
        * Use this to cache any data required into maps prior execution of the Trigger.
        **/
        public override void bulkBefore() {
            set<Id> partyProfileIds = new set<Id>();
            for(SObject pivRec:Trigger.new){
                partyProfileIds.add((Id)pivRec.get('partyProfileId'));
            }
            Map<Id, PartyProfile> kycPartyProfiles = new SEL_PartyProfile().selectByIdsandRecordType(partyProfileIds,'Know_Your_Customer');    
            if (Trigger.isInsert) {
                for (SObject pivRec : Trigger.new) {
                    if(kycPartyProfiles.containskey((Id)pivRec.get('partyProfileId'))){
                        pivRec.put('VerificationRequestDate',system.now());
                    }
                }
            }
            bulkUpdateBefore(kycPartyProfiles);
        }

        private void bulkUpdateBefore(Map<Id, PartyProfile> kycPartyProfiles){
            if (Trigger.isUpdate) {
                for (Integer i = 0; i < Trigger.new.size(); i++) {
                    if (kycPartyProfiles.containskey((Id)Trigger.new[i].get('partyProfileId')) && Trigger.old[i].get('Status') != Trigger.new[i].get('Status') && Trigger.new[i].get('Status') == completed) {
                    	Trigger.new[i].put('RequestCompletionDate',DateTime.now());
                    }
                }
            }
        }
    
        /**
        * @description This method is called prior to execution of a AFTER Trigger. 
        * Use this to cache any data required into maps prior execution of the Trigger.
        **/
        public override void bulkAfter() {
            if (Trigger.isUpdate) {
                Map<Id,Id> partyProfileIds = new Map<Id,Id>();
                partyIdentityVerificationIds.addAll(((Map<Id, PartyIdentityVerification>)Trigger.newMap).keySet());
                partyProfileIds = fetchPPIdsFromMap(((Map<Id, PartyIdentityVerification>)Trigger.newMap).values());
                fetchInProgressPPIdsFromMap(((Map<Id, PartyIdentityVerification>)Trigger.newMap).values());
                if(!partyProfileIds.isEmpty()){
                    Map<Id, Map<String,PartyIdentityVerification>> pp2PIVMap = fetchAllPIVData(partyProfileIds.keySet());
                    prepareNextPIVData(pp2PIVMap, partyProfileIds);
                }
            }
        }
    
    private Map<Id,Id> fetchPPIdsFromMap(List<PartyIdentityVerification> partyIdentityVerifications){
        Map<Id,Id> retVal = new Map<Id,Id>();
        Map<Id, PartyIdentityVerification> trgNM = (Map<Id, PartyIdentityVerification>)Trigger.newMap;
        
        for(PartyIdentityVerification pivRec:partyIdentityVerifications){
            PartyIdentityVerification newPIVRec = trgNM.get(pivRec.Id);
            if( newPIVRec.Status==completed){
                retVal.put(piVRec.partyProfileId,piVRec.Id);
            }
        }
        return filterKycPartyProfileIds(retVal);
    }
    
    private Map<Id,Id> filterKycPartyProfileIds(Map<Id,Id> partyProfileIds){
        Map<Id, PartyProfile> kycPartyProfiles = new SEL_PartyProfile().selectByIdsandRecordType(partyProfileIds.keyset(),'Know_Your_Customer');
        for(Id partyProfileId: partyProfileIds.keyset()){
            if(!kycPartyProfiles.containskey(partyProfileId)){
                partyProfileIds.remove(partyProfileId);
            }
        }
        return partyProfileIds;
    }
    
    private Map<Id,Id> fetchInProgressPPIdsFromMap(List<PartyIdentityVerification> partyIdentityVerifications){
        Map<Id,Id> retVal = new Map<Id,Id>();
        Map<Id, PartyIdentityVerification> trgNM = (Map<Id, PartyIdentityVerification>)Trigger.newMap;
        
        for(PartyIdentityVerification pivRec:partyIdentityVerifications){
            PartyIdentityVerification newPIVRec = trgNM.get(pivRec.Id);
            if(newPIVRec.Status=='In Progress' && newPIVRec.name == 'WFR'){
                retVal.put(piVRec.partyProfileId,piVRec.Id);
            }
        }
        return filterKycPartyProfileIds(retVal);
    }

    @TestVisible
    private Map<Id, Map<String,PartyIdentityVerification>> fetchAllPIVData(Set<Id> partyProfileIds){
        Map<Id, Map<String,PartyIdentityVerification>> retVal = new Map<Id, Map<String,PartyIdentityVerification>>();
        List<PartyIdentityVerification> partyIdentityVerifications = new SEL_PartyIdentityVerification().selectByPartyProfileIds(new set<Id>(partyProfileIds));
        for(PartyIdentityVerification pivRec:partyIdentityVerifications){
            Map<String,PartyIdentityVerification> pivRecMap = new Map<String,PartyIdentityVerification>();
            if(retVal.containsKey(pivRec.PartyProfileId)){
                pivRecMap = retVal.get(pivRec.PartyProfileId);
            }
            pivRecMap.put(pivRec.Name,pivRec);
            retVal.put(pivRec.PartyProfileId,pivRecMap);
        }
        return retVal;
    }

    public String getNxtPIVName(Map<String,PartyIdentityVerification> pp2PIVMap,String nxtPIVName){
        if(nxtPIVName != success){
            if(!pp2PIVMap.keySet().contains(nxtPIVName) || pp2PIVMap.get(nxtPIVName).Status==completed ){
                nxtPIVName = getNxtPIVName(pp2PIVMap,srcToTrgPIVMap.get(nxtPIVName));
            }
        }
        return nxtPIVName;
    }
    @TestVisible
    private void prepareNextPIVData(Map<Id, Map<String,PartyIdentityVerification>> pp2PIVMap, Map<Id,Id> partyProfileIds){
        List<PartyIdentityVerification> pIVFinal = new List<PartyIdentityVerification>();
        Set<Id> lstPPIds = new Set<Id>();
        lstPPIds.addAll(partyProfileIds.keySet());
        List<PartyScreeningSummary> existingPSS = new SEL_PartyScreeningSummary().selectBysetpartyProfileIds(lstPPIds);
        preparePSSMap(existingPSS);
        for(Id ppId: pp2PIVMap.keySet()){
            Id changedPIVid = partyProfileIds.get(ppId);
            PartyIdentityVerification pivFromTrigger = (PartyIdentityVerification)Trigger.newMap.get(changedPIVid);
            String nxtPIVName = getNxtPIVName(pp2PIVMap.get(ppId),srcToTrgPIVMap.get(pivFromTrigger.Name));
            if (!((pivFromTrigger.Status == 'completed' && pivFromTrigger.Result == 'Rejected') || nxtPIVName == 'success')) {
                pIVFinal = processInprogressRecords(pp2PIVMap.get(ppId).values(),nxtPIVName,pIVFinal);
            }
        }
        KYC_SRV_PartyIdentityVerification.newInstance().savePartyIdentityVerification(pIVFinal, uow);
        uow.commitWork();
    }
    
    @TestVisible
    private static List<PartyIdentityVerification> processInprogressRecords(List<PartyIdentityVerification> lstPSS,String nxtPIVName,List<PartyIdentityVerification> pIVFinal){
        for(PartyIdentityVerification pivRec: lstPSS){
            if(pivRec.Name==nxtPIVName && nxtPIVName!=success){
                pivRec.Status='In Progress';
                pIVFinal.add(pivRec);
            }
        }
        return pIVFinal;
    }
    
   

    @TestVisible
    private static Map<Id,PartyScreeningSummary> preparePSSMap(List<PartyScreeningSummary> lstPSS){
        Map<Id,PartyScreeningSummary> retVal = new Map<Id,PartyScreeningSummary>();
        for(PartyScreeningSummary pssRec: lstPSS){
            retVal.put(pssRec.partyProfileId,pssRec);
        }
        return retVal;
    }
    
}