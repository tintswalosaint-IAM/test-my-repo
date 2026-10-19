/**
 * @description DOC_QUEUE_SyncDocuments used for calling API to sync documents
 * 
 * <p></p>
 * 
 * @author Salesforce
 *
 * @date 2020
 */

public class DOC_BATCH_SyncDocuments implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
    
    public String documentsList;
    public List<id> documentIds;
    public DOC_BATCH_SyncDocuments(List<id> documents){
        documentsList='(';
        for(string docId:documents){
        	documentsList+='\''+docId+'\''+',';
        }
        documentsList=documentsList.removeEnd(',')+')';
        documentIds = documents;
    }
	
	/**
	 * @description Start method of batch class
	 *
	 * @param context as input
	 *
	 * @return iterable result
	 */
    public Database.QueryLocator start(Database.BatchableContext BC) {  
        
        String query = 'SELECT Id, Name FROM DOC_Document__c where id IN '+documentsList;
        return Database.getQueryLocator(query);
    }
     

	/**
	 * @description Execute method of batch class
	 *
	 * @param context as input
	 * @param queueItems as input
	 */
	public void execute(Database.BatchableContext context, List<DOC_Document__c> docItems)
	{      
		for(DOC_Document__c doc: docItems){
			DOC_SRV_Document.syncFileNet(doc.id); 
		}
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param context as input
	 */
	public void finish(Database.BatchableContext context)
	{
		List<DOC_Document__c> docItems = [SELECT Id, Name, AOB_Application__c, DOC_DocumentGUID__c 
											FROM DOC_Document__c 
											WHERE Id 
											IN:documentIds
										];
		if(!Test.isRunningTest()){
        	system.enqueueJob(new DOC_SetConditionQueueableJob(docItems));
		}
	}
}