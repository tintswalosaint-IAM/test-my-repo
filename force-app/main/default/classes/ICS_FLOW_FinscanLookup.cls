/**
 * @description Allows screening callout to be invoked from flows
 * @author Gnitsevich Anton
 * @date October 2022
 */
public with sharing class ICS_FLOW_FinscanLookup {

    
    /**
     * @description Invocable method to allow screening from flows
     * @param ids List of application Ids
     */
    @InvocableMethod(
        label='Invoke Finscan Screening'
        description='Accepts application record Id to execute screening'
        category='Screening'
    )
    public static void invokeFinscanLookup(List<String> applicationIds) {
        if (applicationIds == null || applicationIds.isEmpty()) {
            throw new IllegalArgumentException('Application IDs are required.');
        }
        for (String applicationFormId : applicationIds) {
            List<String> singleApplicationFormIdList = new List<String> { applicationFormId };
            System.enqueueJob(new ICS_QUE_Finscan(singleApplicationFormIdList));
        }
    }
    
}