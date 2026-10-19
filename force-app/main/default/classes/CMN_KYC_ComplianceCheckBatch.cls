/***************************************************************************************
@Name of the Class :CMN_KYC_ComplianceCheckBatch
@Description : SFP-32973 class is used to Call Raas API for ComplianceCheck
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
global without sharing class CMN_KYC_ComplianceCheckBatch extends sbgbase.BatchJobBase implements Database.Batchable <sObject>,Database.AllowsCallouts,Database.Stateful{
    private static string recId = Schema.getGlobalDescribe().get('PartyProfile').getDescribe().getRecordTypeInfosByDeveloperName().get('Know_Your_Customer').getRecordTypeId();
    
        
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, PartyProfileId, ScreeningRequestDate, Status, ScreeningDecision, ScreenedBy, RequestCompletionDate  FROM PartyScreeningSummary WHERE Status = 'Completed' and CreatedDate =LAST_N_DAYS:30 and  ScreeningDecision ='On Hold' and PartyProfile.RecordTypeId = :recId]);
    }
    
    public void execute(Database.BatchableContext bContext,List<PartyScreeningSummary> scope){
        for(PartyScreeningSummary partyScreeningSummary : scope){
            KYC_SRV_GetRAASResults.getRassCall(partyScreeningSummary.PartyProfileId);
        }
    }

    public void finish(Database.BatchableContext bContext){

        List<AsyncApexJob> jobs = [SELECT Id, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob  WHERE Id =: bContext.getJobId()];
        String message = 'A number of jobs failed during batch execution: ' + jobs[0].NumberOfErrors + '; total jobs processed: ' + jobs[0].JobItemsProcessed;
        super.finishJob(bContext,message);
    }

}