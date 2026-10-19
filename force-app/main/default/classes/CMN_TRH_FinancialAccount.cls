/**
 * Contains a context-specific methods that are automatically called when the Financial Account trigger is executed
 *
 * @ author Alex Niyonsaba (niyonsabaa@stanbic.com)
 *
 * @ Date Aug 13th 2025
 * @ User Story : SFP-52104
 *
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : Nov 11th 2025
 * @ Modification description : Updates made to fix Limit Exception issue, this issue has been addressed by using bulkAfter() and Batch Apex.
 * @ User Story : SFP-54179
 * 
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : April 28th 2026
 * @ Modification Description: Updates made to resolve 'Flex Queue Jobs Limit' exception via the following:
 * - Records are now processed only if restriction codes have changed.
 * - Small updates are handled synchronously, while large batches are queued asynchronously to reduce job overhead.
 * - Added a safety buffer to evaluate system load/concurrency before initiating new background jobs.
 * @ User Story : SFP-57683
 */
public with sharing class CMN_TRH_FinancialAccount extends CMN_TRH_BaseObject {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CMN_TRH_FinancialAccount');

  private static Boolean alreadyQueued = false;
  public override void bulkAfter() {
    super.bulkAfter();

    if (Trigger.isAfter && Trigger.isUpdate) {
      List<FinServ__FinancialAccount__c> recordsToProcess = new List<FinServ__FinancialAccount__c>();
      for (FinServ__FinancialAccount__c fa : (List<FinServ__FinancialAccount__c>) Trigger.new) {
        FinServ__FinancialAccount__c oldFa = (FinServ__FinancialAccount__c) Trigger.oldMap.get(fa.Id);

        // Only process if the access restriction code changed and isn't blank
        if (
          fa.CMN_AccessRestrictionCode__c != oldFa.CMN_AccessRestrictionCode__c &&
          String.isNotBlank(fa.CMN_AccessRestrictionCode__c)
        ) {
          recordsToProcess.add(fa);
        }
      }

      if (recordsToProcess.isEmpty()) {
        return;
      }

      // Small sets: Execute synchronously
      if (recordsToProcess.size() <= 10) {
        new CMN_BATCH_FinancialAccount().executeRecordsDirect(recordsToProcess);
      }
      //Large sets: Execute asynchronously
      /*Context check to prevent firing a batch if we are already in a batch/future context & Recursion check to ensure we only run this
       once per transaction. */
      else if (!System.isBatch() && !System.isFuture() && !alreadyQueued) {
        //Query the status of the FlexQueue
        Integer activeJobs = [
          SELECT COUNT()
          FROM AsyncApexJob
          WHERE Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
        ];

        // Use 60 active jobs as a buffer to leave room for other critical system jobs.
        if (activeJobs > 70) {
          LOGGER.debug('FlexQueue is near limit (' + activeJobs + '). Skipping batch execution.');
          return;
        }

        //If all guards pass, execute only restricted financial accounts, asynchronously
        alreadyQueued = true;
        CMN_BATCH_FinancialAccount.run(recordsToProcess);
      }
    }
  }
}