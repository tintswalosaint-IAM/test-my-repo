/**
 * Contains a context-specific methods that are automatically called when the User trigger is executed
 *
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 10th 2020
 *
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : Sept 16th 2025
 * @ Modification description : Updates made to handle User's CMN_FinancialAccountRestrictionCodes__c changes and Insert
 *  or revoke FinServ__FinancialAccount__Share records based on these changes.
 * @ User Story : SFP-52102
 *
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : Nov 11th 2025
 * @ Modification description : Updates made to fix Limit Exception issue, this issue has been addressed by using bulkAfter() and Batch Apex.
 * @ User Story : SFP-54179
 * 
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : April 28th 2026
 * @ Modification description : Updates made to resolve 'Flex Queue Jobs Limit' exception. Optimized record processing to trigger only when restriction codes change. 
 * Implemented a hybrid execution strategy: small updates are handled synchronously, while large batches remain asynchronous to minimize unnecessary job creation.
 * @ User Story : SFP-57683
 */

public with sharing class AOB_TRH_User extends CMN_TRH_BaseObject {
  private final List<User> newUsers = new List<User>();
  private final Set<Id> aobUserIds = new Set<Id>();
  private final Set<Id> contactIds = new Set<Id>();

  private final String EXTERNAL_USER_PROFILE = AOB_Utils.getAppSettingByLabel(AOB_Constants.PROFILE);
  private final Profile externalUserProfile = [SELECT Id FROM profile WHERE Name = :EXTERNAL_USER_PROFILE];
  private static Boolean alreadyQueued = false;

  public override void bulkAfter() {
    super.bulkAfter();

    //After Insert trigger handler logic for AOB
    if (Trigger.isAfter && Trigger.isInsert) {
      List<User> users = (List<User>) Trigger.new;
      for (User newUser : users) {
        if (newUser.profileId == externalUserProfile.Id) {
          newUsers.add(newUser);
          aobUserIds.add(newUser.id);
          contactIds.add(newUser.contactId);
        }
      }
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
      List<User> users = (List<User>) Trigger.new;

      //After Update Trigger handler logic for AOB
      for (User user : users) {
        if (user.profileId == externalUserProfile.Id) {
          aobUserIds.add(user.id);
          contactIds.add(user.contactId);
        }
      }

      //After Update Trigger handler logic for financial account data restrictions.
      List<User> recordsToProcess = new List<User>();

      for (User user : users) {
        User oldUser = (User) Trigger.oldMap.get(user.Id);

        // Only process if the restriction codes changed
        if (user.CMN_FinancialAccountRestrictionCodes__c != oldUser.CMN_FinancialAccountRestrictionCodes__c) {
          recordsToProcess.add(user);
        }
      }

      if (recordsToProcess.isEmpty()) {
        return;
      }

      // For small sets, execute synchronously
      if (recordsToProcess.size() <= 4) {
        new CMN_BATCH_User().executeRecordsDirect(recordsToProcess);
      }
      /* For large sets, execute asynchronously.
      Context check to prevent firing a batch if we are already in a batch/future context & Recursion check to ensure we only run this 
      once per transaction. */
      else if (!System.isBatch() && !System.isFuture() && !alreadyQueued) {
        //If all guards pass, execute only users with changed restriction codes, asynchronously
        alreadyQueued = true;
        CMN_BATCH_User.run(recordsToProcess);
      }
    }
  }

  public override void andFinally() {
    super.andFinally();
    AOB_SRV_UserManagement.assignPermissionSet(newUsers, aobUserIds, contactIds);
  }
}