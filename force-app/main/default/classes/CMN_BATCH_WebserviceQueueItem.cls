/**
 * @description This is batch class that calls API Factory to run web service calls asynchronously
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_BATCH_WebserviceQueueItem implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
	List<CMN_WebserviceCallQueue__c> queueItems;

	/**
	 * @description Constructor to get the List of webservice queue
	 *
	 * @param queueItems as input
	 */
	public CMN_BATCH_WebserviceQueueItem(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		this.queueItems = queueItems;
	}

	/**
	 * @description Start method of batch class
	 *
	 * @param context as input
	 *
	 * @return iterable result
	 */
	public Iterable<SObject> start(Database.BatchableContext context)
	{
		return queueItems;
	}

	/**
	 * @description Execute method of batch class
	 *
	 * @param context as input
	 * @param queueItems as input
	 */
	public void execute(Database.BatchableContext context, List<CMN_WebserviceCallQueue__c> queueItems)
	{
		CMN_FACTORY_WebserviceManager.execute(queueItems);
	}

	/**
	 * @description Finish method of batch class
	 *
	 * @param context as input
	 */
	public void finish(Database.BatchableContext context)
	{

	}
}