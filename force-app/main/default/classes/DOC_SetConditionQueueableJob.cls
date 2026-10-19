/**
 * @description DOC_SetConditionQueueableJob used for calling Set condition API to sync SAP
 * 
 * <p></p>
 * 
 * @author aessbai@salesforce.com
 *
 * @date 2021
 */
 public with sharing class DOC_SetConditionQueueableJob implements Queueable,Database.AllowsCallouts {
    
    private Set<Id> documentIds = new Set<Id>();  
    private List<DOC_Document__c> documentToProcess = new List<DOC_Document__c>();
    private Integer counter=0;
    
    public DOC_SetConditionQueueableJob(List<DOC_Document__c> documentToProcess) { 
        this.documentToProcess = documentToProcess;
    }  
    public void execute(QueueableContext context) {
        try {         
            for(integer j=0; j < documentToProcess.size(); j++){
                if(documentToProcess.get(j).DOC_DocumentGUID__c != null){
                    DOC_SRV_SetConditions.setConditions(documentToProcess.get(j).AOB_Application__c);
                    documentToProcess.remove(j);
                } 
            }           
            if (!documentToProcess.isEmpty()) {
                List<DOC_Document__c> docItems = [SELECT Id, Name, AOB_Application__c, DOC_DocumentGUID__c 
                                                  FROM DOC_Document__c 
                                                  WHERE Id 
                                                  IN:documentToProcess
                                                 ];
                if(this.counter <=5){
                    DOC_SetConditionQueueableJob instance = new DOC_SetConditionQueueableJob(docItems);
                    instance.counter= (counter+1);
                    System.enqueueJob(instance);
                }
            }
        } catch(System.CalloutException e) {
            CMN_UTIL_Logger.error(e, 'SetConditionQueueableJob');
        } 
    }
}