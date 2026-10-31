/**
* @description         : Batch job to update leads for sending to Connex. 
*                        Runs every 30 minutes for normal leads, and once in the evening 
*                        for expiring leads. Supports scheduling and callouts.
* @LastModified        : Raja Arsalan
* @author              : Raja Arsalan
* @UserStory           : SFP-59623
* @LastModifiedReason  : Modified the class to process maximum of 10 leads per batch. 

**/
//INS_SRV_DiallerLeadResponse
global with sharing class INS_BATCH_ConnexLead extends sbgbase.BatchJobBase implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {

    private static final sbgplatform.rflib_Logger LOGGER = 
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(INS_BATCH_ConnexLead.class.getName());

    public static final String CRON1 = '0 0 * * * ?'; 
    public static final String CRON2 = '0 30 * * * ?';
    @TestVisible private static final String JOB_NAME  = 'ScheduledAndFailedLeadsToDialer';
    @TestVisible private static final String JOB_NAME2 = 'ScheduledAndFailedLeadsToDialer2'; 


    private Boolean expireLeads = false;      
    private List<String> expiredStatuses;     
    private String leadType;                  
    private String productFamily;             
    private Datetime leadDate;                    
    private List<Id> explicitLeadIds = new list<Id>();
    //new expressed interest change flag to determine if this batch is for expressed interest change leads or not. 
    //Expressed interest change leads have a populated reference number and require a different processing flow. 
     private Boolean isExpressedInterestChanged = false;

    private Integer totalBatches = 0;
    private Integer totalRecords = 0;

    public INS_BATCH_ConnexLead() {
        super();
    }

    /**
* @description Constructor to initialize batch job parameters.
* Used for both regular and expiring lead batches.
*
* @param expireLeads
* @param expiredStatuses
* @param leadType
* @param productFamily
* @param leadDate
* @param explicitLeadIds
*/

   public INS_BATCH_ConnexLead(
    Boolean expireLeads,
    List<String> expiredStatuses,
    String leadType,
    String productFamily,
    Datetime leadDate,
    List<Id> explicitLeadIds
) {
    this(
        expireLeads,
        expiredStatuses,
        leadType,
        productFamily,
        leadDate,
        explicitLeadIds,
        false
    );
}
    // constructor parameters
    public INS_BATCH_ConnexLead(
        Boolean expireLeads, 
        List<String> expiredStatuses, 
        String leadType, 
        String productFamily,
        Datetime leadDate,  
        List<Id> explicitLeadIds,
        Boolean isExpressedInterestChanged //new
    ) {
        // assignments
        this.expireLeads = expireLeads;
        this.expiredStatuses = expiredStatuses;
        this.leadType = leadType;
        this.productFamily = productFamily;
        this.leadDate = leadDate;
        this.explicitLeadIds = explicitLeadIds;
        this.isExpressedInterestChanged = isExpressedInterestChanged;

    }

    /**
* @description      : Entry point for batch job. Selects the leads to process 
*                     based on provided parameters (expireLeads, explicitLeadIds, or date filters).
* @param bc         : Batchable context used for tracking execution state.
* @return           : Iterable list of Lead records to be processed in batches.
* @author           : Raja Arsalan
*/

    global Iterable<Lead> start(Database.BatchableContext bc) {
        super.startJob(bc);

        List<Lead> leadsToProcess = new List<Lead>();          

        if (expireLeads) {
            leadsToProcess = new SEL_Lead()
                .selectLeadsToExpire(expiredStatuses, 'Retro', leadType, productFamily);
        } else if (explicitLeadIds == null) {
            INS_DTO_LeadSearchCriteria c = new INS_DTO_LeadSearchCriteria();
            c.leadType      = leadType;
            c.productFamily = productFamily;
            c.connexDate    = leadDate;
            c.isReport      = false;
            c.searchKey        = null;
            c.startDate        = null;
            c.endDate          = null;
            c.campaignName     = null;
            c.campaignSourceId = null;

            leadsToProcess = new SEL_Lead().selectLeadsByDtoSearchCriteria(c);

        } else {
            leadsToProcess = new SEL_Lead().selectDialerLeadsByRecIds(explicitLeadIds);
        }
        return leadsToProcess;
    }

    /**
* @description      : Executes the batch logic for each scope of leads. 
*                     Divides leads into new and existing ones based on reference number
*                     and sends them for processing via the Connex API utility class.
* @param bc         : Batchable context reference.
* @param scope      : List of Lead records processed in this batch chunk.
*/


    global void execute(Database.BatchableContext bc, List<Lead> scope) {

        LOGGER.debug('Batch Execute - Scope Size: ' + scope.size());
        totalRecords += scope.size();
        totalBatches++;

        // ── ROUTING DECISION ──────────────────────────────────────────────────
        // isExpressedInterestChanged is set by INS_UTIL_LeadTrigger when a lead's
        // Expressed_Interest_Product__c changed and it already has a dialler reference
        // number. Those leads need a two-step flow: expire the old dialler record (PUT)
        // then re-create under the new queue (POST). This branch runs that flow and
        // returns early so these leads never enter the newLeads/updateLeads split below.
        // ─────────────────────────────────────────────────────────────────────
        if (isExpressedInterestChanged) {
            INS_UTIL_ConnexLeads.processExpressedInterestChangedLeads(scope);
            return;
        }

        // Normal flow: classify leads by whether they already have a dialler reference.
        // No ref# → new to the dialler → POST to create.
        // Has ref# → already in dialler → PUT to update or expire.
        List<Lead> newLeads = new List<Lead>();
        List<Lead> updateLeads = new List<Lead>();
        
        for (Lead l : scope) {
            if (String.isBlank(l.Referred_System_Reference_Number__c) && l.Status != 'Unqualified') {
                newLeads.add(l);
            } else if (!String.isBlank(l.Referred_System_Reference_Number__c)) {
                updateLeads.add(l);
            }
        }

        LOGGER.debug('Create Lead IDs: ' + new Map<Id, Lead>(newLeads).keySet());
        LOGGER.debug('Update Lead IDs: ' + new Map<Id, Lead>(updateLeads).keySet());

        INS_UTIL_ConnexLeads.processLeadscallout(newLeads, updateLeads, expireLeads);
    }

    /**
* @description      : Finalizes the batch execution. Logs total processed leads 
*                     and batches, then marks the batch as complete in job tracking.
* @param bc         : Batchable context reference for finish execution.
* @author           : Raja Arsalan
*/

    global void finish(Database.BatchableContext bc) {
        String finalMessage = 'Processed ' + totalRecords + ' leads in ' + totalBatches + ' batches';
        super.finishJob(bc, finalMessage);
    }


    /**
* @description      : Entry point for scheduled execution. Determines whether 
*                     to run normal or expiring lead batch based on flag and metadata settings.
* @param sc         : Schedulable context reference for scheduled execution tracking.
* @author           : Raja Arsalan
*/

    public void execute(SchedulableContext sc) {
        INS_Insurance_Lead_Settings__mdt settings = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');

        if (this.expireLeads) {
            INS_BATCH_ConnexLead batchToRun = new INS_BATCH_ConnexLead(
                true,
                this.expiredStatuses,
                this.leadType,
                this.productFamily,
                null,
                null
            );
            Database.executeBatch(batchToRun, 10);
        } else {
            INS_BATCH_ConnexLead batchToRun = new INS_BATCH_ConnexLead(
                false,
                null,
                settings.INS_LeadType__c,
                settings.INS_ProductFamily__c,
                settings.INS_LeadDate__c,
                null
            );
            Database.executeBatch(batchToRun, 10);
        }
    }

    /**
* @description      : Schedules the batch job to run twice hourly for 
*                     normal leads and triggers an evening run for expiring leads.
*                     Fetches configuration from custom metadata.
* @author           : Raja Arsalan
*/

    public static void scheduleMe() {
        INS_Insurance_Lead_Settings__mdt settings = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');

        INS_BATCH_ConnexLead batchToSchedule = new INS_BATCH_ConnexLead(
            false,
            null,
            settings.INS_LeadType__c,
            settings.INS_ProductFamily__c,
            settings.INS_LeadDate__c,
            null
        );

        System.schedule(JOB_NAME, CRON1, batchToSchedule);
        System.schedule(JOB_NAME2, CRON2, batchToSchedule);
        scheduleLeadsExpiry();
    } 

    /**
* @description      : Schedules the evening batch job specifically to 
*                     process and send expiring leads to Connex.
*                     Reads expiration statuses and configuration from custom metadata.
* @author           : Raja Arsalan
*/

    public static void scheduleLeadsExpiry() {
        String eveningCron = '0 15 22 * * ?';

        INS_Insurance_Lead_Settings__mdt settings = INS_Insurance_Lead_Settings__mdt.getInstance('Dialer_Leads');

        List<String> expiredLeadStatuses = new List<String>();
        if (!String.isBlank(settings.INS_ExpiredLeadStatuses__c)) {
            expiredLeadStatuses = settings.INS_ExpiredLeadStatuses__c.split(';');
        }

        INS_BATCH_ConnexLead eveningBatch = new INS_BATCH_ConnexLead(
            true,
            expiredLeadStatuses,
            settings.INS_LeadType__c,
            settings.INS_ProductFamily__c,
            null,
            null
        );

        System.schedule('EveningScheduledLeadsToDialer', eveningCron, eveningBatch);
    }
}