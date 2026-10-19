/**
 * @description Allows resetting stored documents' retention date from flows
 * @author Gnitsevich Anton
 * @date August 2023
 */
public with sharing class ICS_FLOW_ResetRetention {
    
    
     /**
 	* @description ICS_FLOW_ResetRetention constructor
 	* @param boundary  
 	*/
    private ICS_FLOW_ResetRetention() {
    }
    
    /**
     * @description Invocable method to allow update retention date from flows
     * @param  requestList List of Invocable Variables
     * @return List<Integer> List of response status code 
     */
    @InvocableMethod(
        label='Reset Retention Date'
        description='Accepts opportunity record Id to reset storage retention date'
         category='DSXDocumentStorage'
    )
    public static  List<Integer> invokeResetRetentionDate(List<Requests> requestList) {

	   Set<Id> accountIds = new Set<Id>(new List<Id>(requestList[0].accountIds));
       List<Integer> resetRetentionDateResponseList = new List<Integer>();

        for (Id accountId : accountIds) {
			resetRetentionDateResponseList.add(ICS_CTRL_Documents.resetRetentionDates(accountId, 'DSX'));
        }

        return  resetRetentionDateResponseList;
    }
    
    /**
     * @description Request class with Invocable Variable received from the ICS DSX Document flow
    */   
    public class Requests {
      
        /**
       * @description  Salesforce Account ids
       */  
      @InvocableVariable(label = 'accountIds')
      public List<Id> accountIds;
    }
    

}