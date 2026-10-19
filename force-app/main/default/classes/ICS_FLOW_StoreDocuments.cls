/**
 * @description Allows invoking process to store documents from flows
 * @author Gnitsevich Anton
 * @date March 2023
 */
public with sharing class ICS_FLOW_StoreDocuments {

        /**
 	* @description ICS_FLOW_StoreDocuments constructor
 	*/
     private ICS_FLOW_StoreDocuments() {
     }

    /**
    * @description Request class with Invocable Variable received from the ICS DSX Document Storage flow
    */   
    public class Requests {

       /**
       * @description  Salesforce Linked Entity ids
       */
	  @InvocableVariable(label = 'linkedEntityIds')
      public Id linkedEntityIds;
        
        /**
       * @description  Salesforce Content Version
       */
	  @InvocableVariable(label = 'contentVersion')
       public ContentVersion contentVersion;
    }
    
    /**
     * @description Invocable method to allow storing from flows
     * @param requestList List of Invocable Variables
     */
    @InvocableMethod(
        label='Store Documents'
        description='Accepts application form list, opportunity and account record Id to send related onboarding documents to DSX storage'
        category='DSXDocumentStorage'
    )
    public static void invokeStoreDocuments(List<Requests> requests) {
        
        if((requests[0].contentVersion.DocumentType__c == 'Mandate/Application Form' && !requests[0].contentVersion.Title.contains('signed') && 'Account' == requests[0].linkedEntityIds.getSobjectType().getDescribe().getName())|| 
            	(requests[0].contentVersion.DocumentType__c != 'Mandate/Application Form' && String.IsNotBlank(requests[0].contentVersion.DocumentType__c))){
    		 	Database.executeBatch(new ICS_BATCH_StoreDocuments(requests), 1);
        }
    }   
}