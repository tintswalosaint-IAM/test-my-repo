/**
 * This class implements batchable logic for creating and removing manual financial account share records based on changes to the access
 * restriction code on financial account records. It is triggered by the after update trigger event on financial account object.
 *
 * @ author Alex Niyonsaba (niyonsabaa@stanbic.com)
 * @ Date Nov 11th 2025
 * @ User Story : SFP-54179
 * 
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : April 28th 2026
 * @ Modification description : Updates made to resolve 'Flex Queue Jobs Limit' exception. Introduced a method executeRecordsDirect() that handles Small updates synchronously to reduce job overhead and prevent limit exhaustion.
 * @ User Story : SFP-57683
 */
public class CMN_BATCH_FinancialAccount extends sbgbase.BatchJobBase implements Database.Batchable<sObject> {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CMN_BATCH_FinancialAccount');
  private static final Integer BATCH_SIZE = 11;
  private static final String USER_COUNTRY = 'UG';
  private static final String PUBLIC_RESTRICTION_TYPE = '';

  private final List<FinServ__FinancialAccount__c> recordsToProcess;

  public CMN_BATCH_FinancialAccount() {
  }

  public CMN_BATCH_FinancialAccount(List<FinServ__FinancialAccount__c> records) {
    super();
    this.recordsToProcess = records;
  }

  public Iterable<SObject> start(Database.BatchableContext bc) {
    super.startJob(bc);
    return recordsToProcess;
  }

  public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> scope) {
    if (scope.isEmpty()) {
      return;
    }
    executeFinancialAccountManualShares(scope);
  }

  //Build the restriction map (Reduces execute complexity)
  private Map<String, List<Id>> getRestrictionToUserMap() {
    Map<String, List<Id>> restrictionToUserIds = new Map<String, List<Id>>();
    List<User> allUsers = new SEL_User().selectActiveWithFinancialAccountRestrictionCodesByCountry(USER_COUNTRY);

    for (User u : allUsers) {
      if (String.isBlank(u.CMN_FinancialAccountRestrictionCodes__c)) {
        continue;
      }

      for (String code : u.CMN_FinancialAccountRestrictionCodes__c.split(',')) {
        String trimmedCode = code.trim();
        if (!restrictionToUserIds.containsKey(trimmedCode)) {
          restrictionToUserIds.put(trimmedCode, new List<Id>());
        }
        restrictionToUserIds.get(trimmedCode).add(u.Id);
      }
    }
    return restrictionToUserIds;
  }

  //Logic for individual account shares to reduces nesting
  private List<FinServ__FinancialAccount__Share> generateSharesForAccount(
    FinServ__FinancialAccount__c fa,
    Map<String, List<Id>> restrictionMap
  ) {
    List<FinServ__FinancialAccount__Share> newShares = new List<FinServ__FinancialAccount__Share>();

    Boolean isValidForShare =
      fa.ExternalCIFCountry__c == USER_COUNTRY &&
      fa.CMN_AccessRestrictionCode__c != PUBLIC_RESTRICTION_TYPE &&
      restrictionMap.containsKey(fa.CMN_AccessRestrictionCode__c);

    if (isValidForShare) {
      for (Id userId : restrictionMap.get(fa.CMN_AccessRestrictionCode__c)) {
        newShares.add(
          new FinServ__FinancialAccount__Share(
            ParentId = fa.Id,
            UserOrGroupId = userId,
            AccessLevel = 'Read',
            RowCause = Schema.FinServ__FinancialAccount__Share.RowCause.Manual
          )
        );
      }
    }
    return newShares;
  }

  //Handles DML
  private void processDmlOperations(
    List<FinServ__FinancialAccount__Share> toDelete,
    List<FinServ__FinancialAccount__Share> toInsert
  ) {
    try {
      Schema.DescribeSObjectResult describe = FinServ__FinancialAccount__Share.SObjectType.getDescribe();
      sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();

      if (describe.isDeletable() && !toDelete.isEmpty()) {
        uow.registerDeleted(toDelete);
      }

      if (describe.isCreateable() && !toInsert.isEmpty()) {
        uow.registerNew(toInsert);
      }

      uow.commitWork();
    } catch (Exception e) {
      LOGGER.error('DML Error in CMN_BATCH_FinancialAccount: ' + e.getMessage());
    }
  }

  public void finish(Database.BatchableContext bc) {
    LOGGER.info('Financial Account Restriction codes updates processing completed successfully');
    super.finishJob(bc);
  }

  public static void run(List<FinServ__FinancialAccount__c> records) {
    Database.executeBatch(new CMN_BATCH_FinancialAccount(records), BATCH_SIZE);
  }

  public void executeRecordsDirect(List<FinServ__FinancialAccount__c> records) {
    executeFinancialAccountManualShares(records);
  }

  private void executeFinancialAccountManualShares(List<FinServ__FinancialAccount__c> scope) {
    Map<String, List<Id>> restrictionToUserIds = getRestrictionToUserMap();
    List<FinServ__FinancialAccount__Share> sharesToInsert = new List<FinServ__FinancialAccount__Share>();
    Set<Id> financialAccountIds = new Set<Id>();

    for (FinServ__FinancialAccount__c fa : scope) {
      financialAccountIds.add(fa.Id);
      sharesToInsert.addAll(generateSharesForAccount(fa, restrictionToUserIds));
    }

    List<FinServ__FinancialAccount__Share> sharesToDelete = new SEL_FinServ_FinancialAccount_Share()
      .selectManualSharesByParentId(financialAccountIds);

    processDmlOperations(sharesToDelete, sharesToInsert);
  }
}