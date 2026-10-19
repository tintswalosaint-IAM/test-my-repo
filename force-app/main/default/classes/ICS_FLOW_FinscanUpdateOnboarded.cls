/**
 * @description Allows Finscan Update Client call to be invoked from flows (onboarding completed)
 * @author Gnitsevich Anton
 * @date August 2023
 */
public with sharing class ICS_FLOW_FinscanUpdateOnboarded {
    /**
	* @description ICS_FLOW_FinscanUpdateOnboarded constructor
	*/
     @TestVisible
     private ICS_FLOW_FinscanUpdateOnboarded() {
 
     }
    
    /**
     * @description Invocable method to allow Finscan update client (onboarding completed) call
     * @param ids List of account Ids
     */
    @InvocableMethod(
        label='Invoke Finscan Update Onboarded'
        description='Accepts account record Id to execute Finscan update client (onboarding completed)'
        category='Screening'
    )
    public static void invokeFinscanUpdateOnboarded(List<String> ids) {
        System.enqueueJob(new ICS_QUE_Finscan(ids, 'onboarded'));
    }
}