/**
 * @description Updates client name on DSX after BP number update 
 * @author Sizwe November
 * @date March 2024
 */
public with sharing class ICS_FLOW_UpdateClientNumber {


     /**
 	* @description ICS_FLOW_UpdateClientNumber constructor
 	*/
     private ICS_FLOW_UpdateClientNumber() {

     }
    
    /**
     * @description Invocable method to update client number from flows
     * @param  requestList List of Invocable Variables
     * @return List<ID> List of response status code 
     */
    @InvocableMethod(
        label='Update Client Number in DSX'
        description='Accepts account record Id & ExternalCIFId__c to update the client number in DSX'
         category='DSXDocumentStorage'
    )
    public static List<ID> invokeUpdateClientNumber(List<Requests> requestList) {
        String clientNumber = requestList[0].clientNumber;
        String accountId = requestList[0].accountId;
        
		List<ID> responseDSXList = new List<ID>();
        Id jobId;
        
        if(String.IsNotBlank(clientNumber)){
			jobId = ICS_CTRL_Documents.updateClientNumber(accountId, clientNumber, 'DSX');
            responseDSXList.add(jobId);
        }
        return responseDSXList;
    }
    
    
    /** 
     * @description Request class with Invocable Variable received from the ICS DSX Update Client Number flow
    */   
    public class Requests {
        
      /**
       * @description  Client Number/ BP Id
       */  
      @InvocableVariable(label = 'ExternalCIFId')
      public String clientNumber;
      /**
       * @description  Salesforce Account id
       */  
	  @InvocableVariable(label = 'accountId')
      public String accountId;
    }
    
}