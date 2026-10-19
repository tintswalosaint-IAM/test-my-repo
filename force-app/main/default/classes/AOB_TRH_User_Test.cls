/**
 * @description Test class is use to test the base object methods that support the TRH_User
 interface
 *
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 10th 2020

 * @ Last Modified By : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Modification description : Updated to add a testHandleRestrictionChanges_AddAndRemove test method
 * and Improving Code coverage of AOB_TRH_User class
 * @ User Story : SFP-52102

 * @ Last Modified By : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Modification description : Updates made to improve Code coverage of AOB_TRH_User class
 * @ User Story : SFP-54179
 * 
 * @ Last Modified By  : Alex Niyonsaba(niyonsabaa@stanbic.com)
 * @ Last Modified On  : April 29th 2026
 * @ Modification description : Updates made to increase the class's test coverage.
 * @ User Story : SFP-57683
 */
@IsTest
private class AOB_TRH_User_Test {
  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_TRH_User_Test');
  private static final String CLASS_NAME = 'Class: AOB_TRH_User_Test';
  /**
   * @description To test the TRH_User on insertion
   */
  @IsTest
  private static void testCreateUser() {
    Test.startTest();
    User user = AOB_DAL_TestFactory.createCommunityUser();
    Test.stopTest();
    String EXTERNAL_USER_PERMISSION = AOB_Utils.getAppSettingByLabel(AOB_Constants.PERMISSION);
    PermissionSet customerPerm = [SELECT Id FROM PermissionSet WHERE Name =: EXTERNAL_USER_PERMISSION];

    PermissionSetAssignment permission = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId =: customerPerm.Id AND
      AssigneeId =: user.id
    ];
    Assert.areEqual(customerPerm.id, permission.PermissionSetId, 'The permission assigned successfuly');
  }

  @isTest
  static void testHandleRestrictionChanges_AddAndRemove() {
    try {
      Test.startTest();
      // Step 1: Create FA with restriction "001"
      FinServ__FinancialAccount__c fa = createTestFA('001', 'UG');

      // Step 2: Create User with restriction code "002" (so initially no share with "001")
      User u = createTestUser('002', 'UG');

      // Simulate trigger context: update user to include "001"
      User uToUpdate = [
        SELECT Id, CMN_FinancialAccountRestrictionCodes__c, User_Country__c,
        ProfileId FROM User WHERE Id =: u.Id
      ];
      uToUpdate.CMN_FinancialAccountRestrictionCodes__c = '001,002';
      update uToUpdate; // should invoke afterUpdate -> handleRestrictionChanges

      // Step 3: Now remove "001" from the user's codes
      uToUpdate = [SELECT Id, CMN_FinancialAccountRestrictionCodes__c FROM User WHERE Id =: u.Id];
      uToUpdate.CMN_FinancialAccountRestrictionCodes__c = '002'; // removed "001"
      update uToUpdate;

      // Verify that the share for "001" was deleted
      Integer remainingShares = [
        SELECT Count()
        FROM FinServ__FinancialAccount__Share WHERE ParentId =: fa.Id AND UserOrGroupId =: u.Id
      ];
      Assert.areEqual(0, remainingShares, 'Expected share deleted when code removed');
      Test.stopTest();
    } catch (Exception e) {
      LOGGER.error(e.getMessage(), new String[] {
        CLASS_NAME,
        'Method: handleFinancialAccountSharing'
      }, e);
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static User createTestUser(String codes, String country) {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'
      LIMIT 1
    ];

    User u = new User(FirstName = 'Test', LastName = 'User' + Math.random(),
      Alias = 'tst' + Math.mod(Crypto.getRandomInteger(), 1000),
      Email = 'test' + Math.random() + '@test.com',
      Username = 'test' + Math.random() + '@test.com', ProfileId = p.Id, TimeZoneSidKey = 'GMT',
      LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US',
      CMN_FinancialAccountRestrictionCodes__c = codes, User_Country__c = country, IsActive = true);
    insert u;
    return u;
  }

  private static FinServ__FinancialAccount__c createTestFA(String restrictionCode, String country) {
    // Create two Accounts for primary/joint owner (to bypass validation rule)
    Account primaryAcc = new Account(Name = 'Primary Acc ' + Math.random());
    Account jointAcc = new Account(Name = 'Joint Acc ' + Math.random());
    insert new List < Account > {
      primaryAcc,
      jointAcc
    };

    FinServ__FinancialAccount__c fa =
      new FinServ__FinancialAccount__c(Name = 'Test FA ' + Math.random(),
        ExternalCIFCountry__c = country, CMN_AccessRestrictionCode__c = restrictionCode,
        FinServ__PrimaryOwner__c = primaryAcc.Id, FinServ__JointOwner__c = jointAcc.Id);
    insert fa;
    return fa;
  }
  
  @isTest
  static void testAfterUpdateTrigger_Bulkified() {
    String NEW_TEST_RESTRICTION_ACCESS_CODE = '999';
    Test.startTest();
    List<User> usersToUpdate = new List<User>();

    for(Integer i = 0; i < 5; i++){
       User u = createTestUser('002', 'UG');
       u.CMN_FinancialAccountRestrictionCodes__c = NEW_TEST_RESTRICTION_ACCESS_CODE;
       usersToUpdate.add(u);
    }

    update usersToUpdate;
    Test.stopTest();

    Assert.areEqual(NEW_TEST_RESTRICTION_ACCESS_CODE, usersToUpdate[0].CMN_FinancialAccountRestrictionCodes__c);
  }  
}