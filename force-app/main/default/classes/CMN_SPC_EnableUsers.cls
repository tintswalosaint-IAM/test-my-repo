/**
 * @description public class update user emails and profiles in sandbox
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_SPC_EnableUsers extends CMN_SPC_BaseWorker {
  private static final String ERROR_NO_USERS_FOUND = 'No User Names or Profiles found to enable';

  /**
   * @description Exception used by Post Copy Worker Factory when attempting to execute workers
   */
  public class EnableUserException extends Exception {
  }

  /**
   * @description Method update the users email and profiles from CMN_DAL_UsersToEnable list
   */
  protected override void internalRun() {
    enableUsers(findUsersToEnable());
  }

  /**
   * @description Will read the Custom setting and determine if there are any users that need to be enabled
   *
   * @return A list of users to enable
   */
  private List<User> findUsersToEnable() {
    //get all the users or profiles that are listed in the custom setting
    List<CMN_SPC_UsersToEnable__c> usersToEnableSettings = CMN_DAL_UsersToEnable.getAll();

    if (usersToEnableSettings.isEmpty()) {
      throw new EnableUserException(ERROR_NO_USERS_FOUND);
    }

    Set<String> userNames = CMN_UTIL_System.extractSetValues(
      usersToEnableSettings,
      CMN_SPC_UsersToEnable__c.CMN_SPC_EnableUsername__c.getDescribe()
        .getLocalName()
    );
    Set<String> profileNames = CMN_UTIL_System.extractSetValues(
      usersToEnableSettings,
      CMN_SPC_UsersToEnable__c.CMN_SPC_EnableProfileName__c.getDescribe()
        .getLocalName()
    );

    //Removing null values because when querying users with a profile name of null it returns automated process users
    userNames.remove(null);
    profileNames.remove(null);

    List<User> usersToEnable = new List<User>();

    if (!userNames.isEmpty()) {
      Set<String> additionalUserNames = new Set<String>();

      //If this has been setup, make sure we append the Sandbox name assuming it isn't there already
      //This will most likely always be the case when cloning a sandbox or copying production
      for (String userName : userNames) {
        if (
          String.isNotBlank(userName) &&
          !userName.endsWith(context.sandboxName())
        ) {
          additionalUserNames.add(userName + '.' + context.sandboxName());
        }
      }

      userNames.addAll(additionalUserNames);

      usersToEnable.addAll(CMN_DAL_User.findByUsername(userNames));
    }

    if (!profileNames.isEmpty()) {
      usersToEnable.addAll(CMN_DAL_User.findByProfileName(profileNames));
    }

    return usersToEnable;
  }

  /**
   * @description Will enable all the users in the list provided
   *
   * @param usersToEnable A list of users to enable
   */
  private void enableUsers(List<User> usersToEnable) {
    if (!usersToEnable.isEmpty()) {
      Set<Id> userIDs = CMN_UTIL_System.extractListIds(usersToEnable);

      //Ensure that we don't try and modify the current user (running this worker) as things like changing profile Id will throw an exception
      userIDs.remove(UserInfo.getUserId());

      usersToEnable = CMN_DAL_User.findByUserId(userIDs);

      List<User> usersEmailsToUpdate = new List<User>();

      for (User userRecord : usersToEnable) {
        if (userRecord.Email.contains(CMN_DAL_User.EMAIL_INVALID)) {
          userRecord.Email = userRecord.Email.remove(
            CMN_DAL_User.EMAIL_INVALID
          );
          usersEmailsToUpdate.add(userRecord);
        }
      }

      //First update emails, as next section Activates users and their may not be enough licenses
      CMN_DAL_SObjectDomain.updateDBObjects(usersEmailsToUpdate);

      List<User> usersToActivate = new List<User>();

      for (User userRecord : usersToEnable) {
        Boolean updateRecord = false;

        if (userRecord.IsActive == false) {
          userRecord.IsActive = true;
          updateRecord = true;
        }

        if (updateRecord) {
          usersToActivate.add(userRecord);
        }
      }

      //Update the records that its possible to do as there may not be enough licenses
      CMN_DAL_SObjectDomain.updateDBObjects(usersToActivate, false);
    }
  }
}