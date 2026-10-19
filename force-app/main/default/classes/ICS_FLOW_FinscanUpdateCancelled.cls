/**
 * @description Allows Finscan Update Client call to be invoked from flows (onboarding cancelled)
 * @author Gnitsevich Anton
 * @date August 2023
 */
public with sharing class ICS_FLOW_FinscanUpdateCancelled {
    /**
	* @description ICS_FLOW_FinscanUpdateCancelled constructor
	*/
     private ICS_FLOW_FinscanUpdateCancelled() {
 
     }
    
    /**
     * @description Invocable method to allow Finscan update client (onboarding cancelled) call
     * @param ids List of opportunity Ids
     */
    @InvocableMethod(
        label='Invoke Finscan Update Cancelled'
        description='Accepts opportunity record Id to execute Finscan update client (onboarding cancelled)'
        category='Screening'
    )
    public static void invokeFinscanUpdateCancelled(List<String> ids) {
        SEL_ApplicationForm applicationSelector = new SEL_ApplicationForm();
        List<ApplicationForm> applications = applicationSelector.selectByOpportunityIds(ids);
        List<String> accountIds = new List<String>();
        for (ApplicationForm application : applications) {
            accountIds.add(application.AccountId);
        }
        
        if (!accountIds.isEmpty()) {
            ICS_QUE_Finscan queueableJob = new ICS_QUE_Finscan(accountIds, 'cancelled');
            System.enqueueJob(queueableJob);
        }
    }
}