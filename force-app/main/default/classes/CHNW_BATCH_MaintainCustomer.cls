/**
 * @description       : Batch class to Maintain Customer - Assign AE Code by Branch (round‑robin)
 * @author            : Muvhuso
 * @group             : PPB Maintain Customer
 * @last modified on  : February 2026
 * SFP : SFP-50264 , SFP-50267 , SFP-50266 , SFP-50268
**/

@SuppressWarnings('PMD.AvoidGlobalModifier') 
// global is required for this class as it used the batch job base class
global class CHNW_BATCH_MaintainCustomer extends sbgbase.BatchJobBase
    implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable,Database.Stateful {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger(CHNW_BATCH_MaintainCustomer.class.getName());

    /**
    * @description Start the batch process for all qualifiying accounts
    * @param bc 
    * @return Database.QueryLocator 
    **/
        
    global Database.QueryLocator start(Database.BatchableContext bc) {

        super.startJob(bc);
        LOGGER.info('Batch process started (Assign AE by Branch)');

        String query = 'SELECT Id, BillingState, CMN_BPGUID__pc ,FinServ__MarketingSegment__c, RelationshipMgrCode__c,CMN_AccountHoldingBranch__pc ' +
               'FROM Account ' +
               'WHERE (RelationshipMgrCode__c = null AND ExternalCIFCountry__c = \'ZA\' AND CMN_AccountHoldingBranch__pc != \'\')' +
               'AND Id IN (SELECT FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c ' +
               'WHERE Name IN ( ' +
                    '\'SIGNATURE BANKING CURRENT ACCOUNT\', ' +
                    '\'PRIVATE BANKING CURRENT ACCOUNT\', ' +
                    '\'SPECIAL BANKING CHEQUE ACCOUNT\', ' +
                    '\'STAFF PRIVATE BANKING CURRENT\', ' +
                    '\'STAFF SPECIAL PRIVATE BANKING CURRENT\', ' +
                    '\'PRIVATE BANKING PLUS CURRENT ACCOUNT\', ' +
                    '\'PRIVATE BANKING CURRENT ACCOUNT\', ' +
                    '\'STAFF PRIVATE BANKING PLUS CURRENT ACCOUNT\', ' +
                    '\'PRIVATE BANKING ONE ACCOUNT\' ' +
                ')' +
            ')';
        return Database.getQueryLocator(query);
    }

   
	/**
 	* @description Batch execute method. Processes a chunk of Accounts, loads valid branch codes,
 	*  retrieves AE codes, and assigns them using round-robin load balancing.
 	*
 	* @param bc     – BatchableContext for the running batch job.
 	* @param scope  – List<Account> records included in this batch chunk.
 	*
 	* @return void
 	*/

    global void execute(Database.BatchableContext bc, List<Account> scope) {
        
		LOGGER.debug('Batch chunk size = ' + scope.size());

    	try {
        	Set<String> branches = collectBranchCodes(scope);
        	if (branches.isEmpty()) {
            	LOGGER.warn('No branch codes found in this scope.');
            	return;
        	}

        Map<String, List<String>> branchToAeCodes = loadAECodesByBranch(branches);
        LOGGER.debug('Distinct branches: ' + branches.size() +
                     ' | Branches with AE Codes: ' + branchToAeCodes.size());

        if (branchToAeCodes.isEmpty()) {
            LOGGER.warn('No AE Codes found in reference data for these branches.');
            return;
        }

        assignAECodes(scope, branchToAeCodes);

    	} catch (Exception ex) {
        	LOGGER.fatal('execute: Unhandled exception', ex);
        	finishBatch(bc, scope.size(), scope.size(),
                    'Unhandled exception: ' + ex.getMessage());
    	}

    }

    /**
    * @description finish the batch process 
    * @param bc 
    **/
    global void finish(Database.BatchableContext BC) {

        AsyncApexJob job = [
            SELECT Id, NumberOfErrors, JobItemsProcessed
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()
            LIMIT 1
        ];

        String message =
            'Jobs failed: ' + job.NumberOfErrors +
            '; Items processed: ' + job.JobItemsProcessed;

        super.finishJob(BC, message);
    }

    /*
     * @description Schedule Entry Point
     * @param sc
     **/
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CHNW_BATCH_MaintainCustomer());
    }

    /*
     * @description Helper: Load AE Codes from Reference Data
     * @param branches
     * @return Map<String, List<String>>
     **/
    private static Map<String, List<String>> loadAECodesByBranch(Set<String> branches) {

        Map<String, List<String>> output = new Map<String, List<String>>();

        if (branches.isEmpty()) {return output;}
       		 try{
                 List<AOB_ReferencedData__c> referenceData = [SELECT AOB_Code__c , AOB_Value__c  FROM AOB_ReferencedData__c WHERE AOB_Value__c IN :branches];
                 
                 for (AOB_ReferencedData__c row : referenceData) {
            			String branch  = (String) row.AOB_Value__c;
            			String aeCode  = (String) row.AOB_Code__c;
             
            			if (String.isBlank(branch) || String.isBlank(aeCode)) {continue;}

            				if (!output.containsKey(branch)) {
                				output.put(branch, new List<String>());
            				}

            			output.get(branch).add(aeCode);
        		}

        		// Keep assignment deterministic
        		for (String key : output.keySet()) {
            		output.get(key).sort();
        		}
             }catch(Exception ex){
 				LOGGER.Error('Exception has occurred method : loadAECodesByBranch ' + ex);
             }
        return output;
    }
    /**
 	* @description Extracts and normalizes branch codes from the batch scope.
 	*              Only non-blank, trimmed values are returned.
 	*
 	* @param scope – List<Account> records from the batch chunk.
 	*
 	* @return Set<String> – Unique, non-blank branch codes.
 	*/
    private Set<String> collectBranchCodes(List<Account> scope) {
        
    	Set<String> branches = new Set<String>();
    	for (Account acc : scope) {
        	String branch = (String) acc.CMN_AccountHoldingBranch__pc;
        	if (String.isNotBlank(branch)) {
            	branches.add(branch.trim());
        	}
    	}
    	return branches;
 	}
    
        
	/**
 	* @description Assigns AE Codes to Accounts using round-robin load-balancing.
 	*              Ensures each branch cycles through its AE Code list in sequence.
 	*
 	* @param scope            – List<Account> records from the batch chunk.
 	* @param branchToAeCodes  – Map<String, List<String>> mapping branch -> list of AE Codes.
 	*
 	* @return void
 	*/

    private void assignAECodes(List<Account> scope,Map<String, List<String>> branchToAeCodes) {

    	Map<String, Integer> branchIndexTracker = new Map<String, Integer>();

   	 	for (Account acc : scope) {

        	String branchCode = (String) acc.CMN_AccountHoldingBranch__pc;
        	if (String.isBlank(branchCode)) {continue;}

        	branchCode = branchCode.trim();
        	List<String> aeList = branchToAeCodes.get(branchCode);

        	if (aeList == null || aeList.isEmpty()) {continue;}

        	Integer currentIndex;

			if (branchIndexTracker.containsKey(branchCode)) {
    			currentIndex = branchIndexTracker.get(branchCode);
			} else {
    			currentIndex = 0;
			}
      
        	Integer selectedIdx = Math.mod(currentIndex, aeList.size());
        	String selectedAE = aeList[selectedIdx];

        	branchIndexTracker.put(branchCode, currentIndex + 1);

        	doCallout(selectedAE, acc);
    	}
	}
    
	/**
 	* @description Executes the external API call to update the customer’s RM code.
 	*              Any callout exceptions are handled and logged safely.
 	*
 	* @param selectedAE – String AE Code selected for the Account.
 	* @param acc        – Account record to update.
 	*
 	* @return void
 	*/

    private void doCallout(String selectedAE, Account acc) {
    	try {
        	CMN_API_UpdateCustomerDetails cmn = new CMN_API_UpdateCustomerDetails();
        	cmn.updateCustomeRM(selectedAE, acc.CMN_BPGUID__pc);
    	} catch (Exception calloutEx) {
        	LOGGER.fatal(
            	'Callout failed for account: ' + acc.Id +
            	' | AE Code: ' + selectedAE +
            	' | BP GUID: ' + acc.CMN_BPGUID__pc +
            	' | Error: ' + calloutEx.getMessage()
        	);
    	}
	}

}