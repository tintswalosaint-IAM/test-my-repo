/**
 * @description Scheduled job to retry failed Lead integrations
 *              Runs every 30 minutes (via two separate jobs) to find leads 
 *              with 500 errors and re-send them to Dotsure
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-22
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-09-17   Raja Arsalan    Initial Version
 * 2026-09-22   Raja Arsalan    Split into two jobs (0th and 30th minute) 
 *                              because Salesforce doesn't support sub-hourly cron
 **/
public class INS_SCHED_LeadIntegrationRetry implements Schedulable {
    
    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_SCHED_LeadIntegrationRetry.class.getName());
    
    // ✅ Two jobs — Salesforce doesn't support '0,30' in cron
    @TestVisible
    private static final String JOB_NAME_1 = 'INS_LeadIntegrationRetry_Hourly';
    @TestVisible
    private static final String JOB_NAME_2 = 'INS_LeadIntegrationRetry_HalfHourly';
    
    // ✅ Job 1: Every hour at 0th minute
    @TestVisible
    private static final String CRON_1 = '0 0 * * * ?';
    
    // ✅ Job 2: Every hour at 30th minute
    @TestVisible
    private static final String CRON_2 = '0 30 * * * ?';
    
    @TestVisible
    private static Boolean forceException = false;
    
    /**
     * @description Schedules two jobs to run at 0th and 30th minute of every hour
     * @return List of Job IDs
     **/
    public static List<String> scheduleJob() {
        List<String> jobIds = new List<String>();
        
        // Job 1: 0th minute
        jobIds.add(System.schedule(
            JOB_NAME_1, 
            CRON_1, 
            new INS_SCHED_LeadIntegrationRetry()
        ));
        
        // Job 2: 30th minute
        jobIds.add(System.schedule(
            JOB_NAME_2, 
            CRON_2, 
            new INS_SCHED_LeadIntegrationRetry()
        ));
        
        return jobIds;
    }
    
    /**
     * @description Execute method - Queries failed leads and retries integration
     * @param sc SchedulableContext
     **/
    public void execute(SchedulableContext sc) {
        LOGGER.info('INS_SCHED_LeadIntegrationRetry : Start');
        
        try {
            // ✅ Force exception for test coverage
            if (Test.isRunningTest() && forceException) {
                throw new INS_SchedRetryException('Simulated exception for coverage');
            }
            
            List<Lead> leadsToRetry = new SEL_Lead().selectByIdsForRetry();
            
            if (leadsToRetry.isEmpty()) {
                LOGGER.info('No leads to retry');
                return;
            }
            
            LOGGER.info('Found ' + leadsToRetry.size() + ' leads to retry');
            
            Map<Id, String> leadToSystemMap = new Map<Id, String>();
            for (Lead lead : leadsToRetry) {
                leadToSystemMap.put(lead.Id, 'Dotsure');
            }
            
            Database.executeBatch(new INS_Batch_LeadIntegration(leadToSystemMap), 20);
            
            LOGGER.info('Batch initiated with ' + leadToSystemMap.size() + ' leads');
            
        } catch (Exception ex) {
            LOGGER.error('INS_SCHED_LeadIntegrationRetry Exception: ' + ex.getMessage(), ex);
        }
    }
    
    /**
     * @description Custom exception for testing
     **/
    public class INS_SchedRetryException extends Exception {}
}