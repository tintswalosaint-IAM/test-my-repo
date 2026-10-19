/**
 * @description Ping Registration handler to create User and it's related person account
 *
 * <p>DBP-1106</p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 3th 2020
 */
global with sharing class AOB_PingRegistrationHandler implements Auth.RegistrationHandler {
  private static final String EXTERNAL_USER_PROFILE = AOB_Utils.getAppSettingByLabel(
    AOB_Constants.PROFILE
  );
  private static final String SERVICE_NAME = AOB_PingRegistrationHandler.class
    .getName();

  /**
   * @description Create the User - A required method to implement the Handler Interface
   * @param portalId  - Id of the Community
   * @param data - Auth Provider user data describing the User to create
   * @return User that has been initialized
   */
  global User createUser(Id portalId, Auth.UserData data) {
    Profile p = [SELECT Id FROM profile WHERE Name = :EXTERNAL_USER_PROFILE];
    Id contactId;
    String federationId;
    List<User> users = new List<User>();
    //check if the unique identifier is already assigne to a user
    System.Debug('PingRegHandler createUser data: ' + data);
     System.Debug('PingRegHandler createUser portalId: ' + portalId);  
    System.debug('PingRegHandler federationId : ' + data.attributeMap.get(AOB_Constants.ID_STRING));  
    if (data.attributeMap.containsKey(AOB_Constants.ID_STRING)) {
      federationId = data.attributeMap.get(AOB_Constants.ID_STRING);
      users = [
        SELECT Id, federationIdentifier, isActive, ContactId
        FROM User
        WHERE federationIdentifier = :federationId AND isActive = TRUE
      ];
    }
    //if new User
    if (users.isEmpty()) {
      User user = new User();
      data.attributeMap.containsKey(AOB_Constants.ID_STRING);
      user = AOB_SRV_UserManagement.createUser(data.attributeMap, user, p);
      Account newPersonAccount = AOB_SRV_UserManagement.createPersonAccount(
        data.attributeMap
      );
        if (newPersonAccount != null) {
        Contact c = [
          SELECT AccountId, Id
          FROM Contact
          WHERE AccountId = :newPersonAccount.Id
        ];
          user.contactId = c.Id;
        
      }
        return user;
        
    } else {
      User userToUpdate = new User(Id = users[0].Id);
      //get the related Account
      Account acc = new Account();
      if (!string.isBlank(users[0].ContactId)) {
        Contact cont = [
          SELECT Id, AccountId
          FROM Contact
          WHERE Id = :users[0].ContactId
        ];
        acc = new Account(Id = cont.AccountId);
      }
      //update the User & related account
      updateUser(userToUpdate, acc, data.attributeMap);
      return userToUpdate;
    }
  }
  /**
   * @description Update the user
   * @param userId
   * @param portalId
   * @param data
   */
  global void updateUser(Id userId, Id portalId, Auth.UserData data) {
    //Debug Ping Issues
   /* System.debug('PingRegHandler**updateUser**Auth.UserData: ' + data);
    System.debug('PingRegHandler**updateUser**userId: ' + userId);*/

    Account newPersonAccount;
    User u = [
      SELECT FirstName, LastName, Email, contactId
      FROM User
      WHERE id = :userId
    ];
   /*System.debug('PingRegHandler**updateUser**u: ' + u);*/
    List<Account> accs = [
      SELECT
        ExternalCIFUUID__c,
        ExternalCIFId__c,
        AOB_CommerceSiteId__c,
        FirstName,
        LastName,
        PersonEmail,
        recordTypeId
      FROM Account
      WHERE PersonContactId = :u.contactId
    ];
    /*System.debug('PingRegHandler**updateUser**accs: ' + accs);*/
    if (accs.isEmpty()) {
      newPersonAccount = AOB_SRV_UserManagement.createPersonAccount(
        data.attributeMap
      );
      if (newPersonAccount != null) {
        Contact c = [
          SELECT AccountId, Id
          FROM Contact
          WHERE AccountId = :newPersonAccount.Id
        ];
        u.contactId = c.id;
      }
      updateUser(u, null, data.attributeMap);
    } else {
      updateUser(u, accs[0], data.attributeMap);
    }
  }
  /**
   * @description Update the user
   * @param userToUpdate
   * @param acc
   * @param attributes
   */
  public void updateUser(
    User userToUpdate,
    Account acc,
    Map<String, String> attributes
  ) {

    if (attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
      userToUpdate.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
    }
    if (attributes.containsKey(AOB_Constants.PING_FIRST_NAME)) {
      userToUpdate.FirstName = attributes.get(AOB_Constants.PING_FIRST_NAME);
    }
    if (attributes.containsKey(AOB_Constants.PING_EMAIL)) {
      userToUpdate.Email = attributes.get(AOB_Constants.PING_EMAIL);
    }
    //update userToUpdate;
    //update related Account
    System.debug('FRANCO:' + attributes + ' ' + acc);
    if (acc != null || Test.isRunningTest()) {
      if (attributes.containsKey(AOB_Constants.PING_BPID)) {
        acc.ExternalCIFId__c = attributes.get(AOB_Constants.PING_BPID);
      }
        System.debug('FRANCO BEFORE');
      if (attributes.containsKey(AOB_Constants.PING_BPGUID)) {
        String bpGUID = String.valueOf(attributes.get(AOB_Constants.PING_BPGUID));
        if (bpGUID != NULL) acc.ExternalCIFUUID__c = AOB_Utils.formatGUID(bpGUID);
      }
      if (attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
        acc.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
      }
      if (attributes.containsKey(AOB_Constants.PING_FIRST_NAME)) {
        acc.FirstName = attributes.get(AOB_Constants.PING_FIRST_NAME);
      }
      if (attributes.containsKey(AOB_Constants.NATIONAL_ID)) {
        acc.AOB_IdentityNumber__c = attributes.get(AOB_Constants.NATIONAL_ID);
      }
      if (attributes.containsKey(AOB_Constants.CUSTOMER_CC)) {
        acc.AOB_TECH_CCCustomerId__c = attributes.get(
          AOB_Constants.CUSTOMER_CC
        );
      }
      update (acc);
    }
  }
}