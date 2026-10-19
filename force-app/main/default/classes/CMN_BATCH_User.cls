/**
 * This class implements batchable logic for creating and removing manual financial account share records based on changes to the restriction codes
 * on user records. It is triggered by the after update trigger event on user object.
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
public class CMN_BATCH_User extends sbgbase.BatchJobBase implements Database.Batchable<sObject> {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory()
    .createLogger('CMN_BATCH_User');

  private static final Integer BATCH_SIZE = 5;
  private final List<User> recordsToProcess;

  public CMN_BATCH_User() {
  }

  public CMN_BATCH_User(List<User> records) {
    super();
    this.recordsToProcess = records;
  }

  public Iterable<SObject> start(Database.BatchableContext bc) {
    super.startJob(bc);
    return recordsToProcess;
  }

  public void execute(Database.BatchableContext bc, List<User> scope) {
    if (scope.isEmpty()) {
      return;
    }
    executeFinancialAccountManualShares(scope);
  }

  //Maps restriction codes to the Sets of User IDs that possess them.
  private Map<String, Set<Id>> mapUsersByRestriction(List<User> scope) {
    Map<String, Set<Id>> restrictionToUserIds = new Map<String, Set<Id>>();
    for (User user : scope) {
      List<String> codes = CMN_UserUtil.splitAndTrimCommaSeperatedCodes(user.CMN_FinancialAccountRestrictionCodes__c);
      for (String code : codes) {
        if (!restrictionToUserIds.containsKey(code)) {
          restrictionToUserIds.put(code, new Set<Id>());
        }
        restrictionToUserIds.get(code).add(user.Id);
      }
    }
    return restrictionToUserIds;
  }

  //Queries Financial Accounts and maps them by their Access Restriction Code.
  private Map<String, Set<Id>> mapFinancialAccountsByRestriction(String country, Set<String> codes) {
    Map<String, Set<Id>> restrictionToFaIds = new Map<String, Set<Id>>();
    List<FinServ__FinancialAccount__c> financialAccounts = new SEL_FinServ_FinancialAccount()
      .searchRestricetdFinancialAcountsByCountry(country, codes);

    for (FinServ__FinancialAccount__c ffa : financialAccounts) {
      String code = ffa.CMN_AccessRestrictionCode__c;
      if (!restrictionToFaIds.containsKey(code)) {
        restrictionToFaIds.put(code, new Set<Id>());
      }
      restrictionToFaIds.get(code).add(ffa.Id);
    }
    return restrictionToFaIds;
  }

  //Cross-references Users and Financial Accounts to build Share records.
  private List<FinServ__FinancialAccount__Share> buildShares(Map<String, Set<Id>> userMap, Map<String, Set<Id>> faMap) {
    List<FinServ__FinancialAccount__Share> shares = new List<FinServ__FinancialAccount__Share>();
    for (String code : userMap.keySet()) {
      if (!faMap.containsKey(code)) {
        continue;
      }

      for (Id userId : userMap.get(code)) {
        for (Id faId : faMap.get(code)) {
          shares.add(
            new FinServ__FinancialAccount__Share(
              ParentId = faId,
              UserOrGroupId = userId,
              AccessLevel = 'Read',
              RowCause = Schema.FinServ__FinancialAccount__Share.RowCause.Manual
            )
          );
        }
      }
    }
    return shares;
  }

  private Set<Id> getUserIds(List<User> scope) {
    return new Map<Id, User>(scope).keySet();
  }

  //Handles the deletion of old shares and insertion of new ones.
  private void processDml(
    List<FinServ__FinancialAccount__Share> toInsert,
    List<FinServ__FinancialAccount__Share> toDelete
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
      LOGGER.error('DML Error in CMN_BATCH_User: ' + e.getMessage());
    }
  }

  public void finish(Database.BatchableContext bc) {
    LOGGER.info('Users\' Financial Account Restriction codes updates processing completed successfully');
    super.finishJob(bc);
  }

  public static void run(List<User> records) {
    Database.executeBatch(new CMN_BATCH_User(records), BATCH_SIZE);
  }

  public void executeRecordsDirect(List<User> records) {
    executeFinancialAccountManualShares(records);
  }

  private void executeFinancialAccountManualShares(List<User> scope) {
    Map<String, Set<Id>> restrictionToUserIds = mapUsersByRestriction(scope);
    String userCountry = scope[0].User_Country__c;

    Map<String, Set<Id>> restrictionToFaIds = mapFinancialAccountsByRestriction(
      userCountry,
      restrictionToUserIds.keySet()
    );

    List<FinServ__FinancialAccount__Share> sharesToInsert = buildShares(restrictionToUserIds, restrictionToFaIds);
    List<FinServ__FinancialAccount__Share> sharesToDelete = new SEL_FinServ_FinancialAccount_Share()
      .selectManualSharesByUserId(getUserIds(scope));

    processDml(sharesToInsert, sharesToDelete);
  }
}