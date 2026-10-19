/**
 * @description Public class to as part of post copy script for users to make admins in sandboxes
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public inherited sharing class CMN_DAL_UsersToEnable {
  /**
   * @description This method is use to get the list of all profiles and users in CMN_SPC_UsersToEnable__c
   *
   * @return List
   */
  public static List<CMN_SPC_UsersToEnable__c> getAll() {
    return CMN_DAL_Search.getAll(CMN_SPC_UsersToEnable__c.SObjectType);
  }

  /**
   * @description This method is used to return a single record
   *
   * @return List
   */
  @TestVisible
  private static CMN_SPC_UsersToEnable__c getUsername() {
    List<CMN_SPC_UsersToEnable__c> users = [
      SELECT
        Id,
        Name,
        CMN_SPC_EnableProfileName__c,
        CMN_SPC_EnableUsername__c,
        SetupOwnerId
      FROM CMN_SPC_UsersToEnable__c
      WHERE CMN_SPC_EnableUsername__c != NULL
      LIMIT :CMN_DAL_SObjectDomain.LIMIT_NUMBER_OF_RECORDS
    ];
    return users.isEmpty() ? null : users[0];
  }
}