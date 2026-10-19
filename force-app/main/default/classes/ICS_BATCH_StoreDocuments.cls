/**
 * @description Batch class to store documents
 * @author Gnitsevich Anton
 * @date January 2023
 */
public with sharing class ICS_BATCH_StoreDocuments implements Database.Batchable<ICS_FLOW_StoreDocuments.Requests>, Database.AllowsCallouts {
    
    /**
    * @description  Content Version & Linked Entity ID to be sent to DSX
    */ 
    private final List<ICS_FLOW_StoreDocuments.Requests> request;

    /**
     * @description Constructor for Batch Class
     * @param request Object containing Content Version & Linked Entity ID to be sent to DSX
     */
    public ICS_BATCH_StoreDocuments(List<ICS_FLOW_StoreDocuments.Requests> request) {
        this.request = request;
    }

    /**
     * @description Start Method for Batch Class
     * @param bc Database.BatchableContext
     * @return List containing Content Version & Linked Entity ID to be sent to DSX
     */
    public List<ICS_FLOW_StoreDocuments.Requests> start(Database.BatchableContext bc) {
        return request;
    }
    
    /**
     * @description Execute Method for Batch Class
     * @param bc Database.BatchableContext
     * @param scope List<ICS_FLOW_StoreDocuments.Requests> scope
     */
    public void execute(Database.BatchableContext bc, List<ICS_FLOW_StoreDocuments.Requests> scope) {

        for(ICS_FLOW_StoreDocuments.Requests request: scope){
			ICS_CTRL_Documents.storeDocuments(request.linkedEntityIds, 'DSX', request.contentVersion);
        }
    }
    
    /**
     * @description Finish Method for Batch Class
     * @param bc Database.BatchableContext
     */
    public void finish(Database.BatchableContext bc) {


    }
}