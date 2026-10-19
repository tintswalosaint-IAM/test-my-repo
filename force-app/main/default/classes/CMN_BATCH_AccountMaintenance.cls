/**
 * Created by Łukasz Kojzar on 12.10.2022.
 * SFP-18188
 * @description Batch process for performing maintenance tasks on CHNW Account records
 * Updates to owners based on RM AE Code and Account's RM Code
 * 
 * 2023-06-13   Derek Hughes        Control which country accounts are process with MDT settings
 *                                  Added LOGGER and improved error handling and reporting
 *                                  Refactor code and add comments
 * 
 * 2023-08-24   Karabo Machubeni    Extract the core logic and transfer to the Helper Class 'CMN_SRV_AccountOwnerUpdate'
 *                                  Update the execute method to reference the CMN_SRV_AccountOwnerUpdate
 * 
 * 2024-01-15   Derek Hughes        Convert to use Batch Job Scheduler.  Must be global and have a default constuctor
 * 
 * 2024-01      Dhiraj Pratapati    SFP-32348 Add RM Assistnat to account teams automatically, some refactoring and restructing to optimise code
 * 
 */

@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it used the batch job base class
global without sharing class CMN_BATCH_AccountMaintenance extends sbgbase.BatchJobBase implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CMN_BATCH_AccountMaintenance..class.getName());

    private static final String CRON = '0 3 4 ? * * *'; // 4:03AM every day

    @TestVisible
    private static final String JOB_NAME = 'Account Maintenance (reassigning Accounts)';

    // Counters to be able to report the results in the final Log
    private Integer totalBatches = 0;
    private Integer totalRecords = 0;
    private Integer updatedOwners = 0;
    private Integer teamMembersAdded = 0;
    private Integer teamMembersDeleted = 0;
    private Integer errorCount = 0;

    private Set<String> countryCodes = new Set<String>();

     /**
    * @description Default contructor is required for the batch manager to instantiate this class
    * @author Derek Hughes | 15-01-2024 
    **/
    global CMN_BATCH_AccountMaintenance() {
        super();
    }

    /**
    * @description Start the batch be selecting elgible accounts using the RM settings to determine whcih countries to include
    * @author Łukasz Kojzar | 12-10-2022 
    * @param bc 
    * @return Iterable 
    **/
    public Iterable<sObject> start(Database.BatchableContext bc) {

        super.startJob(bc);

        countryCodes = DMN_RelationshipManagementSettings.getCountriesForOwnerAndTeams();

        LOGGER.info('Batch process started: Countries to be processed: '+countryCodes);

        return Database.getQueryLocator([
                SELECT
                Id,
                        Owner.RM_AE_Code__c,
                        Owner.IsActive,
                        RelationshipMgrCode__c
            FROM
                Account
                WHERE
                        ExternalCIFCountry__c IN :countryCodes
                ORDER BY Owner.RM_AE_Code__c
        ]);
    }

    /**
    * @description Main processing of each batch of account records
    * @author Łukasz Kojzar | 12-10-2022 
    * @param bc 
    * @param scope 
    **/
    public void execute(Database.BatchableContext bc, List<sObject> scope) {  
        
        totalRecords += scope.size();
        totalBatches++;
        Integer errors = 0;
        
        try {
          
            DMN_User userDomain = new DMN_User();
            SEL_User userSelector = new SEL_User();
            List<User> users = userSelector.selectActiveWithPortfoliosByCountry(countryCodes);
            Map<String, Set<Id>> codeToUserIds = userDomain.getCodeToUserIds(users);

            LOGGER.debug('execute: users.size='+users.size());

            CMN_SRV_AccountOwnerUpdate.Result ownerUpdateResult = CMN_SRV_AccountOwnerUpdate.processAccounts((List<Account>) scope);

            CMN_SRV_AccountTeamUpdate.Result teamUpdateResult = new CMN_SRV_AccountTeamUpdate()
                .setUsers(codeToUserIds)
                .process((List<Account>)scope);

            errors += (ownerUpdateResult.errors + teamUpdateResult.errors);
            updatedOwners += ownerUpdateResult.ownersUpdated;
            teamMembersAdded += teamUpdateResult.teamMembersAdded;
            teamMembersDeleted += teamUpdateResult.teamMembersDeleted;
            errorCount += errors;

            if (errors==0) {
                LOGGER.debug('execute: Update succesful');
            }
            else {
                LOGGER.error('execute: Errors updating accounts: ' + errors + ' error(s) occured.');
            }
        }
        catch (Exception ex) {
            LOGGER.fatal('execute: Unhandled exception', ex);
            finishBatch(bc, scope.size(), scope.size(),  'Unhandled exception:' + ex.getMessage());
            throw ex;
        }

        finishBatch(bc, scope.size(), errors, errors>0 ? errors + ' error(s) occured.' : '');
        
    }

    /**
    * @description Wraps up the process by logging the result and stats
    * @author Derek Hughes | 14-06-2023 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        String finalMessage = 'Processed '+totalRecords+' in '+totalBatches+' batches with ' + 
            updatedOwners + ' owners updates' + 
            ' and ' + teamMembersAdded + ' team member(s) added' +
            ' and ' + teamMembersDeleted + ' team member(s) deleted.' +
            ' There were ' + errorCount +' error(s).';

        LOGGER.info(finalMessage);

        super.finishJob(bc, finalMessage);

    }
    
     /**
    * @description Wraps up the process by logging the result and stats
    * @author Derek Hughes | 14-06-2023 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CMN_BATCH_AccountMaintenance());
    }

    /**
    * @description method to run the batch job 
    * @param batchSize
    */
    public static void run(Integer batchSize) {
        Database.executeBatch(new CMN_BATCH_AccountMaintenance(), batchSize); 
    }

    /**
    * @description method to schedule the batch job 
    * @param jobName
    */
    public static void scheduleMe(String jobName) {
        jobName = String.IsBlank(jobName)?JOB_NAME:jobName;
        CMN_BATCH_AccountMaintenance batchToSchedule = new CMN_BATCH_AccountMaintenance();
        System.schedule(jobName, CRON, batchToSchedule);
    }

    /**
    * @description method to unschedule the batch job 
    * @param jobName
    */
    public static void unscheduleMe(String jobName) {
        jobName = String.IsBlank(jobName)?JOB_NAME:jobName;
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];
        System.abortJob(ct.Id);
    }

}