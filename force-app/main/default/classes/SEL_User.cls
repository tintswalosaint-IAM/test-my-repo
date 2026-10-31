/**
 * @description Selector for User object. Provides methods to query
 *              User records with various filters and conditions.
 *
 * @author Derek Hughes
 *
 * @date 13-06-2023
 *
 * @history 13-06-2023  Derek Hughes       Initial creation
 * @history 29-01-2024  Derek Hughes       Added selectActiveWithPortfoliosByCountry
 * @history 27-08-2024  Khaliq Abdul       Added getUsersByIds
 * @history 21-10-2025  Raymond Magezi     Added selectUsersWithManagersByIds (SFP-53263)
 * @history 17-10-2025  Jaco de Lange      Added selectByContactId and selectByUserName
 * @history 06-10-2025  Alex Niyonsaba     Added selectActiveWithFinancialAccountRestrictionCodesByCountry (SFP-55187)
 * @history 04-02-2026  Raymond Magezi     Fixed permission checks in selectUserById methods
 * @history 16-03-2026  Raymond Magezi     Disabled FLS on selectUsersWithManagersByIds to ensure ManagerId/Email
 *                                          always returned for hierarchy traversal - SFP-55654
 * @history 09-07-2026  Raymond Magezi     Added selectByEmail for environment-agnostic user resolution - SFP-58853
 * @history 12-07-2026  Raymond Magezi     Added selectByBaseUsername for cross-environment pattern matching - SFP-58853
 * @history 30-07-2026  Raymond Magezi     Added selectUsersWithManagerChainByIds to fetch full 5-level
 *                                          manager chain in one SOQL, replacing multi-query hierarchy
 *                                          traversal in CMN_DAL_UserManagerHierarchy - SFP-55654
 * @history 21-08-2026  Shams              Added User.Name to selectUserById for producer creation - SFP-60046
 */
public inherited sharing class SEL_User extends sbgplatform.fflib_SObjectSelector {
  /**
   * @description Implementation method for Application Object as part of fflib framweork
   * @return Schema.SObjectType
   **/
  public override Schema.SObjectType getSObjectType() {
    return User.sObjectType;
  }
  /**
   * @description Returns list of User fields
   *
   * @return list of SObjectField
   */
  public override List < SObjectField > getSObjectFieldList() {
    return new List < Schema.SObjectField > {
      User.Name,
      User.Username,
      User.Email,
      User.Country,
      USer.User_Country__c,
      User.FirstName,
      User.LastName,
      User.MobilePhone,
      User.Phone,
      User.ProfileId,
      User.UserRoleId,
      User.RM_AE_Code__c,
      User.Portfolio_Role_Name__c,
      User.Portfolio_Codes__c,
      User.CompanyName,
      User.EmployeeNumber,
      User.Id,
      User.ManagerId,
      User.CMN_FinancialAccountRestrictionCodes__c
      
    };
  }

  /**
   * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
   * and inject a mock instead of this class or to switch out this class for a new version.
   * @return SEL_User
   */
  public static SEL_User newInstance() {
    return (SEL_User) ORG_Application.selector.newInstance(User.SObjectType);
  }

  /**
   * @description Selects users based on a set of Ids
   * @author Derek Hughes | 13-06-2023
   * @param ids
   * @return List<User>
   **/
  public List < User > selectUsersByIds(Set < Id > ids) {
    return Database.query(
      newQueryFactory(false, false, true)
      .selectField('Profile.Name')
      .selectField('Contact.AccountId')
      .selectField('CompanyName')
      .setCondition('Id IN :ids')
      .toSOQL()
    );
  }

  /**
   * @description Selects users with their ManagerId based on a set of Ids
   * @author Raymond Magezi | 04-02-2026  
   * @param ids Set of user Ids
   * @return List<User> List of users with ManagerId field
   **/
  public List < User > selectUsersWithManagersByIds(Set < Id > ids) {
    return Database.query(
      newQueryFactory(false, false, false)
      .selectField('ManagerId')
      .selectField('Email')
      .setCondition('Id IN :ids')
      .toSOQL()
    );
  }

  /**
   * @description Selects users that are in a specific Group
   * @author Derek Hughes | 13-06-2023
   * @param groupName
   * @return List<User>
   **/
  public List < User > selectUsersByGroup(String groupName) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =:groupName)')
      .toSOQL()
    );
  }
  /**
   * @description Select users By Name
   * @author Ikyatha Naidu| 12-04-2025
   * @param customerName
   * @return User
   **/
  public User selectByName(String customerName) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('Name =: customerName ')
      .toSOQL()
    );
  }
  /**
   * @description Gets all the users for specific countires that are active and have portfolio codes
   * @author Derek Hughes | 29-01-2024 
   * @param countries 
   * @return List<User> 
   **/
  public List < User > selectActiveWithPortfoliosByCountry(Set < String > countries) {

    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('IsActive = true ' +
        ' AND (RM_AE_Code__c != \'\' OR (Portfolio_Role_Name__c != \'\' AND Portfolio_Codes__c != \'\') ) ' +
        ' AND User_Country__c IN :countries')
      .toSOQL()
    );
  }
  /**
   * @description Gets all the users based on id
   * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za) | 27-08-2024 
   * @param ids 
   * @return List<User> 
   **/
  public List < User > getUsersByIds(Set < Id > ids) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('Id IN :ids')
      .toSOQL()
    );
  }
  /**
   * @description Selects a user by their ID
   * @author Rahul.Mamidala@standardbank.co.za | 28-04-2025
   * @param userId The ID of the user to retrieve
   * @return List<User> List containing the user record
   **/
  public User selectUserById(Id userId) {
    sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    fieldQueryFactory.setCondition('Id = :userId');
    fieldQueryFactory.selectField('Name');
    fieldQueryFactory.selectField('EmployeeNumber');
    fieldQueryFactory.selectField('ContactId');
    fieldQueryFactory.selectField('Contact.AccountId');
    fieldQueryFactory.selectField('RM_AE_Code__c');
    fieldQueryFactory.setLimit(1);
    return Database.query(fieldQueryFactory.toSOQL());
  }

  /**
   * @description Selects a user by their IDS
   * @param userIds 
   * @return List<User> List containing the user record
   **/
  public List < User > selectUserById(Set < Id > userIds) {
    return Database.query(
      newQueryFactory(false, false, true)
      .selectField('EmployeeNumber')
      .setCondition('Id IN :userIds')
      .toSOQL()
    );
  }

  /**
   * @description Selects a user by their EmployeeNumber
   * @param pNumbers 
   * @return Map<String, User>
   **/
  public Map < String, User > selectUserByEmployeeNumber(Set < String > pNumbers) {
    Map < String, User > result = new Map < String, User > ();

    for (User u : Database.query(
      newQueryFactory(false, false, true)
      .selectField('EmployeeNumber')
      .setCondition('EmployeeNumber IN :pNumbers')
      .toSOQL()
    )) {
      if (!String.isBlank(u.EmployeeNumber)) {
        result.put(u.EmployeeNumber, u);
      }
    }

    return result;
  }
    
    
    
    /**
   * @description Selects a user by their EmployeeNumber
   * @param pNumbers 
   * @return Map<String, User>
   **/
  public Map < String, User > selectByUserEmail(Set < String > emails) {
    Map < String, User > result = new Map < String, User > ();

    for (User u : Database.query(
      newQueryFactory(false, false, true)
      .selectField('email')
      .setCondition('email IN :emails')
      .toSOQL()
    )) {
      if (!String.isBlank(u.email)) {
        result.put(u.email, u);
      }
    }

    return result;
  }  

  /**
   * @description Selects users by Contact Id
   * @author Ridhima Saxena | 05-06-2025
   * @param contactId The Contact Id to search for
   * @return List<User> List of users associated with the contact
   **/
  public List < User > selectByContactId(String contactId) {
    return Database.query(
      newQueryFactory(false, false, false)
      .setCondition('ContactId = :contactId')
      .toSOQL()
    );
  }

  /**
   * @description Gets all the users for specific county that are active and have Financial account restriction codes
   * @author Alex Niyonsaba | 06 Oct 2025
   * @param country
   * @return List<User> 
   **/
  public List < User > selectActiveWithFinancialAccountRestrictionCodesByCountry(String userCountry) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('CMN_FinancialAccountRestrictionCodes__c != null AND User_Country__c =: userCountry AND IsActive = TRUE')
      .toSOQL()
    );
  }
  /**
   * @description Selects users by username
   * @author Jaco de Lange | 09-10-2025
   * @param username
   * @return List<User>
   **/
  public List < User > selectByUserName(String username) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('username =:username')
      .toSOQL()
    );
  }

  /**
   * @description Selects active user by email address
   * @author Raymond Magezi | 09-07-2026
   * @param email Email address to match
   * @return List<User>
   **/
  public List < User > selectByEmail(String email) {
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('Email = :email AND IsActive = true')
      .toSOQL()
    );
  }

  /**
   * @description Selects active users matching a base username pattern across environments.
   *              Appends wildcard internally to match sandbox suffixes dynamically.
   * @author Raymond Magezi | 12-07-2026
   * @param baseUsername The base production username (e.g., 'sbgdatauser@standardbank.co.za')
   * @return List<User>
   **/
  public List < User > selectByBaseUsername(String baseUsername) {
    baseUsername += '%';
    return Database.query(
      newQueryFactory(false, false, true)
      .setCondition('Username LIKE :baseUsername AND IsActive = true')
      .toSOQL()
    );
  }

  /**
   * @description Selects seed users with their full 5-level manager chain populated via
   *              parent relationship traversal in a single SOQL query. Used by
   *              CMN_DAL_UserManagerHierarchy to collapse what was previously up to 6
   *              separate queries (1 seed + 5 level queries) into 1 per batch chunk.
   *              FLS disabled (false) to ensure ManagerId and Email are always returned
   *              regardless of running user permissions.
   * @author Raymond Magezi
   * @param ids Set of seed user Ids (case owners)
   * @return List<User> with nested Manager chain fields populated
   **/
  public List < User > selectUsersWithManagerChainByIds(Set < Id > ids) {
    return Database.query(
      newQueryFactory(false, false, false)
      .selectField('ManagerId')
      .selectField('Manager.Id')
      .selectField('Manager.Email')
      .selectField('Manager.ManagerId')
      .selectField('Manager.Manager.Id')
      .selectField('Manager.Manager.Email')
      .selectField('Manager.Manager.ManagerId')
      .selectField('Manager.Manager.Manager.Id')
      .selectField('Manager.Manager.Manager.Email')
      .selectField('Manager.Manager.Manager.ManagerId')
      .selectField('Manager.Manager.Manager.Manager.Id')
      .selectField('Manager.Manager.Manager.Manager.Email')
      .selectField('Manager.Manager.Manager.Manager.ManagerId')
      .selectField('Manager.Manager.Manager.Manager.Manager.Id')
      .selectField('Manager.Manager.Manager.Manager.Manager.Email')
      .setCondition('Id IN :ids')
      .toSOQL()
    );
  }
}