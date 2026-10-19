/**
 * @description Provides Query methods related to User object.
 * <p/>
 * Extension of the CMN_DAL_User class to support additional user calls for servicing
 * e.g. search by federation id, manager hierarchy escalation
 * <p/>
 * <p>VCCC-378</p>
 * <p>VCCC-63</p>
 *
 * @see CMN_AUTH_PingStaff
 *
 * @author Accenture, Brian Saunders (brian.saunders@standardbank.co.za)
 *
 * @date 2019, October 2020
 * ***************************************************************************
 * @Last Modified By : Raymond Magezi
 * @Last Modified On : 11-01-2025
 * @Last Modified Reason : Added getManagerByLevel invocable method for manager hierarchy escalation
 * @User Story: SFP-55654
 * ***************************************************************************
 * @Last Modified By : Raymond Magezi
 * @Last Modified On : 29-01-2026
 * @Last Modified Reason : Enhanced error handling, logging, validation, and documentation
 * @Changes:
 *   - Added errorMessage field to ManagerResult for debugging
 *   - Extracted MAX_MANAGER_LEVELS constant for configurability
 *   - Added email validation to prevent invalid email addresses
 *   - Implemented comprehensive logging using rflib
 *   - Clarified escalation level semantics (level 1 = immediate manager)
 *   - Removed unused Manager.Email field from queries
 *   - Added custom ManagerLookupException for validation errors
 */
public inherited sharing abstract class CMN_DAL_User {
    // prevent instantiation on an all-static utility class
    private CMN_DAL_User() {}
  // ========================================
  // CONSTANTS
  // ========================================
  
  public static final String EMAIL_INVALID = '.invalid';
  public static final String OBJECT_NAME = User.SObjectType.getDescribe().getLocalName();
  public static final String FIELD_ID = User.Id.getDescribe().getLocalName();
  public static final String FIELD_IS_ACTIVE = User.IsActive.getDescribe().getLocalName();
  public static final String FIELD_PROFILE_NAME = 'Profile.Name';
  public static final String FIELD_USER_NAME = User.Username.getDescribe().getLocalName();
  public static final String FIELD_AE_CODE = User.RM_AE_Code__c.getDescribe().getLocalName();
  


  // ========================================
  // FIELD SELECTION METHODS
  // ========================================

  /**
   * @description Method use to get the set of fields of SObject
   *
   * @return A list of commonly queried User fields
   */
  @TestVisible
  private static Set<String> getDefaultUserFields() {
    return new Set<String>{
      'AboutMe',
      'AccountId',
      'Address',
      'Alias',
      'BadgeText',
      'City',
      'CommunityNickname',
      'CompanyName',
      'ContactId',
      'Country',
      'Department',
      'DigestFrequency',
      'Division',
      'Email',
      'EmailEncodingKey',
      'EmployeeNumber',
      'Extension',
      'Fax',
      'FederationIdentifier',
      'FirstName',
      'FullPhotoUrl',
      'Id',
      'IsActive',
      'LanguageLocaleKey',
      'LastName',
      'Latitude',
      'LocaleSidKey',
      'Longitude',
      'ManagerId',
      'MobilePhone',
      'Name',
      'OutOfOfficeMessage',
      'Phone',
      'PostalCode',
      'Profile.Name',
      'ProfileId',
      'RM_AE_Code__c',
      'SenderEmail',
      'SenderName',
      'Signature',
      'State',
      'SystemModstamp',
      'TimeZoneSidKey',
      'Title',
      'UserRoleId',
      'UserType',
      'Username'
    };
  }

  // ========================================
  // QUERY METHODS
  // ========================================

  /**
   * @description Method to return a list of users by Id
   *
   * @param userIds The userIds to be used when filtering the user list
   *
   * @return List of Users
   */
  public static List<User> findByUserId(Set<Id> userIds) {
    return CMN_DAL_SObjectSelector.findById(
      OBJECT_NAME,
      FIELD_ID,
      userIds,
      getDefaultUserFields()
    );
  }

  /**
   * @description Method to return User based on Id
   *
   * @param userId The Id to be used when finding the user
   *
   * @return Single User
   */
  public static User findByUserId(Id userId) {
    List<User> foundUsers = findByUserId(new Set<Id>{ userId });
    // Simplified ternary-style logic with direct boolean expression
    return foundUsers.isEmpty() ? null : foundUsers[0];
  }

  /**
   * @description Will get the details for the currently logged in user
   *
   * @return A fully populated User object
   */
  public static User getCurrentUser() {
    return CMN_DAL_User.findByUserId(UserInfo.getUserId());
  }

  /**
   * @description Will a list of users that are active, will use a default set of fields to retrieve
   *
   * @param profileName The profile name that user should have
   * @param fieldNames The fields to return for the user object
   * @param random Will return a random active user for the given profile if set to true
   *
   * @return User object
   */
  public static List<User> findActiveByProfileName(
    String profileName,
    Set<String> fieldNames,
    Boolean random
  ) {
    return findActiveByProfileNameInternal(profileName, fieldNames, random);
  }

  /**
   * @description Internal helper method to find active users by profile name
   * @param profileName The profile name that user should have
   * @param fieldNames The fields to return for the user object
   * @param random Will return a random active user for the given profile if set to true
   * @return List of User objects
   */
  private static List<User> findActiveByProfileNameInternal(
    String profileName,
    Set<String> fieldNames,
    Boolean random
  ) {
    CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(
      OBJECT_NAME
    );

    searchParameters.randomSingle = random;
    searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
    searchParameters.searchFields.clear();

    //We're expecting the fields to be separated by a comma
    searchParameters.selectFields = fieldNames;

    CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

    andCondition.add(
      new CMN_SOQL_Query.FieldCondition(
        FIELD_PROFILE_NAME,
        CMN_SOQL_Query.Operator.EQUALS,
        profileName
      )
    );
    andCondition.add(
      new CMN_SOQL_Query.FieldCondition(
        FIELD_IS_ACTIVE,
        CMN_SOQL_Query.Operator.EQUALS,
        true
      )
    );

    searchParameters.searchConditions.add(andCondition);

    return CMN_DAL_Search.getObjects(searchParameters);
  }

  /**
   * @description Will retrieve an random user that's active, will use a default set of fields to retrieve
   *
   * @param profileName The profile name that user should have
   *
   * @return User object
   */
  public static User findRandomActiveByProfileName(String profileName) {
    return findRandomActiveByProfileName(profileName, getDefaultUserFields());
  }

  /**
   * @description Will retrieve an random user that's active, will retrieve fields requested
   *
   * @param profileName The profile name that user should have
   * @param fieldNames The fields to return for the user object
   *
   * @return User object
   */
  public static User findRandomActiveByProfileName(
    String profileName,
    Set<String> fieldNames
  ) {
    List<User> users = findActiveByProfileName(profileName, fieldNames, true);
    return users.isEmpty() ? null : users[0];
  }

  /**
   * @description This method is use to get the List of users by username
   *
   * @param userNames The usernames to search against
   *
   * @return List of User
   */
  public static List<User> findByUsername(Set<String> userNames) {
    return CMN_DAL_SObjectSelector.findByField(
      OBJECT_NAME,
      FIELD_USER_NAME,
      userNames,
      getDefaultUserFields()
    );
  }

  /**
   * @description This method is use to get the List of users by profile name
   *
   * @param profileNames A list of profile names
   *
   * @return Found users for the given profiles
   */
  public static List<User> findByProfileName(Set<String> profileNames) {
    return CMN_DAL_SObjectSelector.findByField(
      OBJECT_NAME,
      FIELD_PROFILE_NAME,
      profileNames,
      getDefaultUserFields()
    );
  }

  /**
   * @description Checks if current user is admin
   *
   * @return Boolean is admin or not
   */
  public static Boolean isCurrentUserSystemAdmin() {
    return isCurrentUserSystemAdminInternal();
  }

  /**
   * @description Internal helper method to check if current user is admin
   * @return Boolean is admin or not
   */
  private static Boolean isCurrentUserSystemAdminInternal() {
    final List<User> users = [
      SELECT Id, Name
      FROM User
      WHERE
        Id = :UserInfo.getUserId()
        AND Profile.Name = :CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
    ];
    return users != null && !users.isEmpty();
  }

  /**
   * @description Method to return the user federation Id
   *
   * @param federationId as input
   *
   * @return user if found
   */
  public static User findUserByFederationId(String federationId) {
    return findByField(User.FederationIdentifier, federationId, false);
  }

  /**
   * @description Method to return the user
   *
   * @param userField as input
   * @param fieldValue as input
   * @param mustBeUnique as input
   *
   * @return User if found
   */
  private static User findByField(
    SObjectField userField,
    String fieldValue,
    Boolean mustBeUnique
  ) {
    return (User) CMN_DAL_SObjectSelector.findByField(
      User.SObjectType,
      userField,
      fieldValue,
      getDefaultUserFields(),
      mustBeUnique
    );
  }

  /**
   * @description Method to return a list of users by AE Code
   *
   * @param aeCodes AE Codes of users
   *
   * @return List of Users
   */
  public static List<User> findByAECode(Set<String> aeCodes) {
    return CMN_DAL_SObjectSelector.findByField(
      OBJECT_NAME,
      FIELD_AE_CODE,
      aeCodes,
      getDefaultUserFields()
    );
  }

  /**
   * @description Returns a list of all users
   *
   * @return Boolean List of users
   */
  public static List<User> getAllBankerUsers() {
    return [
      SELECT Id, Name, Username
      FROM User
      WHERE Profile.Name = :CMN_DAL_Profile.PROFILE_BANKER_USER
    ];
  }

  // ========================================
  // MANAGER HIERARCHY METHODS (Delegated)
  // ========================================

  /**
   * @description Gets managers at specified levels in hierarchy.
   * @deprecated Use CMN_DAL_UserManagerHierarchy.getManagerByLevel instead
   * @param requests List of ManagerRequest
   * @return List of ManagerResult
   */
  public static List<ManagerResult> getManagerByLevel(List<ManagerRequest> requests) {
    return CMN_DAL_UserManagerHierarchy.getManagerByLevel(requests);
  }

  // ========================================
  // INNER CLASSES
  // ========================================

  /**
   * @description Input wrapper for getManagerByLevel invocable method
   */
  public class ManagerRequest {
    /**
     * @description The User ID of the case owner (or starting point in hierarchy)
     */
    @InvocableVariable(
      label='Owner User ID'
      description='The User ID to start the manager lookup from'
      required=true
    )
    public Id ownerId;

    /**
     * @description The number of levels to escalate up the manager hierarchy.
     * Level 1 = immediate manager, Level 2 = manager\'s manager, etc.
     * Must be between 1 and MAX_MANAGER_LEVELS (currently 5).
     */
    @InvocableVariable(
      label='Escalation Level'
      description='Number of levels up the hierarchy (1=immediate manager, 2=manager\'s manager, etc.)'
      required=true
    )
    public Integer escalationLevel;
  }

  /**
   * @description Output wrapper for getManagerByLevel invocable method
   */
  public class ManagerResult {
    /**
     * @description The User ID of the manager found at the specified level.
     * Will be null if manager not found.
     */
    @InvocableVariable(
      label='Manager User ID'
      description='The User ID of the manager at the specified level (null if not found)'
    )
    public Id managerId;

    /**
     * @description The email address of the manager found at the specified level.
     * Will be null if manager not found or has invalid email.
     */
    @InvocableVariable(
      label='Manager Email'
      description='The email address of the manager (null if not found or invalid)'
    )
    public String managerEmail;

    /**
     * @description Error message explaining why manager lookup failed.
     * Will be null if lookup was successful.
     */
    @InvocableVariable(
      label='Error Message'
      description='Explanation of why manager lookup failed (null if successful)'
    )
    public String errorMessage;
  }

  /**
   * @description Custom exception for manager lookup validation errors
   */
  public class ManagerLookupException extends Exception {}
}