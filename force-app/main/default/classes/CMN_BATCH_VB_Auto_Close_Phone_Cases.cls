/**
 * @description       : Batch class to Auto Close Case that has been opened for the last 60  days.
 * @author            : Sandile Mathe
 * @group             : Voice Branch
 * @Created on        : 06-03-2025
**/
@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it used the batch job base class
global without sharing class CMN_BATCH_VB_Auto_Close_Phone_Cases extends sbgbase.BatchJobBase implements Database.Batchable<sObject>, Schedulable, Database.Stateful  {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_BATCH_VB_Auto_Close_Phone_Cases..class.getName());
    
    @TestVisible
    private static final String JOB_NAME = 'Auto Close Phone-to-Case Cases';

    private Id generalEnquiryServiceTypeId;

    // Counters to be able to report the results in the final Log
    private Integer totalBatches = 0;
    private Integer totalRecords = 0;
    private Integer errorCount = 0;
    
    global CMN_BATCH_VB_Auto_Close_Phone_Cases() {
        Super();
        List<SVC_ServiceType__c> serviceType = [SELECT Id FROM SVC_ServiceType__c WHERE Name = 'General Enquiry' AND SVC_Active__c = true LIMIT 1];

         if (!serviceType.isEmpty()) {
             
         this.generalEnquiryServiceTypeId = serviceType[0].Id;
             
       } else {
           
           	//Throw Exception and log it when Service type is not found, since Cases cannot be closed when Service type is Null.
           	LOGGER.error('"General Enquiry" Service Type not found or not active.');
        	throw new BatchableException('"General Enquiry" Service Type not found or not active.');
      }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

		String query = 'SELECT Id, SVC_ReasonForBreach__c, Status, amazonconnect__AC_Contact_Id__c, Origin, AccountId, Case_Owner_Country__c, CreatedDate  FROM Case ' +
                         'WHERE amazonconnect__AC_Contact_Id__c != null ' +
                         'AND Origin = \'Phone\' ' +
                         'AND Case_Owner_Country__c = \'ZA\' ' +
                         'AND Status = \'New\' ' +
                         'AND CreatedDate <= N_DAYS_AGO:60' +
                         'ORDER BY AccountId NULLS LAST';

		return Database.getQueryLocator(query);

}
    
   public void execute(Database.BatchableContext bc, List<Case> scope) {
       
        totalRecords += scope.size();
        totalBatches++;
        Integer errors = 0;

       try{
           
           List<Case> casesToUpdate = new List<Case>();
           
           for (Case c : scope) {

            if (c.AccountId != null) {
              
             c.Status = 'Closed';
             c.SVC_RootCauseResolution__c = 'Auto Closed due to case being automatically created through Amazon Connect Phone to Case, SR logged on Customer1st';
             c.SVC_ServiceType__c = generalEnquiryServiceTypeId;
             c.SVC_RootCause__c = 'Case actioned on Customer 1st'; 

             if (c.SVC_ReasonForBreach__c != null) {

                c.SVC_ReasonForBreach__c = 'Other';
             }

            casesToUpdate.add(c);
          }

          }
           
           
         if (!casesToUpdate.isEmpty()) {

			Database.SaveResult[] results = Database.update(casesToUpdate, false);
               for (Integer i = 0; i < results.size(); i++) {
                    if (!results[i].isSuccess()) {
                        errorCount++;
                        errors++;
                    }
    			}
          }
           
           if (errors==0) {
                LOGGER.debug('execute: Case Updated succesfully');
            }
            else {
                LOGGER.error('execute: Errors updating Cases: ' + errors + ' error(s) occured.');
            }

       }catch(Exception ex){
           LOGGER.fatal('execute: Unhandled exception', ex);
           finishBatch(bc, scope.size(), scope.size(),  'Unhandled exception:' + ex.getMessage());
           throw ex;
       }
       
       finishBatch(bc, scope.size(), errors, errors>0 ? errors + ' error(s) occured.' : '');

}
    
    /**
    * @description Wraps up the process by logging the results
    * @author Sandile Mathe | 06-03-2025 
    * @param bc 
    **/
    public void finish(Database.BatchableContext BC) {

           String finalMessage = 'Processed '+totalRecords+' in '+totalBatches+' batches with ' +
            ' There were ' + errorCount +' error(s).';

        LOGGER.info(finalMessage);

        super.finishJob(bc, finalMessage);

 }
      /**
    * @description Wraps up the process by logging the result and stats
    * @author Sandile Mathe | 06-03-2025 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CMN_BATCH_VB_Auto_Close_Phone_Cases());
    }
    
    public class BatchableException extends Exception {}

}