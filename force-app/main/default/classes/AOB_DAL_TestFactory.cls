/**
 * @description Used to create Data, mostly for unit tests
 *
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 9th 2020
 */
@isTest
public with sharing class AOB_DAL_TestFactory {
  /**
   * @description This method is use to create a community user, The profile that should be linked to the new user
   * @return A user that Is/not inserted
   */
  public static User createCommunityUser() {
    UserRole userrole = [SELECT Id, DeveloperName FROM UserRole LIMIT 1];

    User adminUser = [
      SELECT Id, UserRoleId
      FROM User
      WHERE id = :UserInfo.getUserId()
      LIMIT 1
    ];
    if (String.isBlank(adminUser.UserRoleId)) {
      adminUser.UserRoleId = userRole.Id;
      update adminUser;
    }
    User user;
    System.runAs(adminUser) {
      String extUserProfile = AOB_Utils.getAppSettingByLabel(
        AOB_Constants.PROFILE
      );
      //get Profile
      Profile profile = [
        SELECT id
        FROM Profile
        WHERE name = :extUserProfile
      ];

      //Insert User
      String uniqueName = getUniqueName();

      string accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('IndustriesIndividual')
        .getRecordTypeId();
      Account account = new Account(
        Name = 'TestACC',
        AOB_CommerceSiteId__c = 'SB-COZA',
        AOB_TECH_CCCustomerId__c = 'XXX',
        RecordTypeId = accountRT,
        phone='+27823309876' ,
        ExternalCIFUUID__c = 'RandonBPGUID'
      );
      insert account;

      Contact contact = new Contact(
        LastName = 'test',
        Email = uniqueName + '@test.org',
        firstName = 'testFirstName',
        AccountId = account.Id
      );
      insert contact;
      user = new User(
        lastName = 'test',
        email = uniqueName + '@test.org',
        Username = uniqueName + '@test.org',
        ProfileId = profile.Id,
        EmailEncodingKey = 'ISO-8859-1',
        Alias = uniqueName.substring(18, 23),
        TimeZoneSidKey = 'America/Los_Angeles',
        LocaleSidKey = 'en_US',
        LanguageLocaleKey = 'en_US',
        UserPermissionsKnowledgeUser = true,
        contactId = contact.id,
        FederationIdentifier = 'FederationIdentifier' + uniqueName
      );
      insert user;
    }
    return user;
  }

  /**
   * @description Get the unique name to be user for Email, Username of the created user
   * @return A unique Name
   */
  public static string getUniqueName() {
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(' ', '')
      .replace(':', '')
      .replace('-', '');
    Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
    String uniqueName = orgId + dateString + randomInt;

    return uniqueName;
  }
  /**
   * @description This method is use to get the user with profile, The profile that should be linked to the new user
   * @param profileName
   * @param doInsert
   * @return A user that Is/not inserted
   */
  public static User createUser(String profileName, Boolean doInsert) {
    User result = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id,
      LastName = 'LastName',
      FirstName = 'FirstName',
      Email = 'aob@sb.com',
      Username = 'aob@sb.com' + System.currentTimeMillis(),
      CommunityNickname = 'aob' + System.currentTimeMillis(),
      CompanyName = 'aob',
      Title = 'Volunteer',
      Alias = 'aob',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      isActive = true
    );

    if (doInsert) {
      insert result;
    }
    return result;
  }

  /**
   * @description This method is used to query for app setting metadata Type
   * @param category
   * @return List
   */
  public static List<AOB_AppSettings__mdt> loadAppSettings(String category) {
    List<AOB_AppSettings__mdt> appSettings = [
      SELECT MasterLabel, AOB_Value__c
      FROM AOB_AppSettings__mdt
      WHERE AOB_Category__c = :category
    ];
    return appSettings;
  }
  /**
   * @description This method is used to query for country metadata Type
   * @return List
   */
  public static List<AOB_Country_Settings__mdt> loadCountrySettings() {
    List<AOB_Country_Settings__mdt> currencies = [
      SELECT
        MasterLabel,
        AOB_CallCenterPhoneNumber__c,
        AOB_Code__c,
        AOB_Commerce_Cloud_URL__c,
        AOB_Country__c,
        AOB_Currency__c,
        AOB_CurrencyCode__c,
        AOB_PermissionSet__c
      FROM AOB_Country_Settings__mdt
    ];
    return currencies;
  }
  /**
   * @description This method is used to create a new application
   * @param currentScreen
   * @param previousScreen
   * @param currentScreenNum
   * @param numOfScreens
   * @return AOB_Application__c
   */
  public static AOB_Application__c createApplication(
    String currentScreen,
    String previousScreen,
    Integer currentScreenNum,
    Integer numOfScreens
  ) {
    User communityUser = [
      SELECT id, contactId, accountId
      FROM User
      WHERE id = :UserInfo.getUserId()
    ];
    Account acc = [SELECT id FROM account WHERE id = :communityUser.accountId];
    AOB_Application__c newApplication = new AOB_Application__c(
      AOB_CurrentScreen__c = currentScreen,
      AOB_PreviousScreen__c = previousScreen,
      AOB_TECH_CurrentScreenNum__c = currentScreenNum,
      AOB_TECH_NumOfScreens__c = numOfScreens,
      AOB_Customer__c = acc.id
    );
    insert newApplication;
    return newApplication;
  }
  /**
   * @description This method is used to create a new application (without params)
   * @return AOB_Application__c
   */
  public static AOB_Application__c createApplication() {
    User communityUser = [
      SELECT id, contactId
      FROM User
      WHERE id = :UserInfo.getUserId()
    ];
    Account acc = [
      SELECT id
      FROM account
      WHERE
        id IN (
          SELECT accountId
          FROM contact
          WHERE id = :communityUser.contactId
        )
    ];
    AOB_Application__c newApplication = new AOB_Application__c();
    newApplication.AOB_Customer__c = acc.id;
    insert newApplication;
    return newApplication;
  }
  /**
   * @description create application with default values
   * @param conId
   * @return application
   */
  public static AOB_Application__c createDefaultApplications(Id conId) {
    List<Contact> contact = [
      SELECT AccountId, Id
      FROM Contact
      WHERE Id = :conId
      LIMIT 1
    ];
    AOB_application__c app = new AOB_application__c();
    app.AOB_CurrentScreen__c = AOB_Constants.FLOW_BEFORE_WE_BEGIN;
    app.AOB_TECH_CurrentScreenNum__c = 5;
    app.AOB_TECH_FlowNames__c = 'AOB_BeforeWeBegin,AOB_WebFaceRecognition,AOB_PersonalDetails,AOB_CardPersonalisation,AOB_CardDetails,AOB_CardFinalOffer,AOB_OTP,AOB_DocumentUpload';
    app.AOB_PreviousScreen__c = AOB_Constants.FLOW_PERSONAL_DETAIL;
    app.AOB_TECH_CurrentScreenNum__c = 1;
    app.AOB_BasketId__c = '34567890';
    app.AOB_Contact__c = conId;
    app.AOB_TECH_CCConfirmationLink__c = 'test.com';
    app.AOB_Customer__c = contact[0].AccountId;
    app.AOB_TECH_OrderNo__c = '1223';
    insert app;
    return app;
  }
  /**
   * @description This method is used to create a new product
   * @param name
   * @param productCode
   * @return Product2
   */
  public static Product2 createProduct(String name, String productCode) {
    Product2 newProduct = new Product2(Name = name);
    newProduct.ProductCode = productCode;
    newProduct.ExternalId = productCode;
    newProduct.AOB_ProductCategory__c = 'Credit Card';
    newProduct.AOB_MinimumMonthlyRepayment__c = 3;
    insert newProduct;
    return newProduct;
  }
  /**
   * @description This method is used to create a new product insurance
   * @param parentProduct
   * @param product
   * @return InsuranceProduct
   */
  public static AOB_InsuranceProduct__c createInsuranceProduct(
    product2 parentProduct,
    product2 product
  ) {
    AOB_InsuranceProduct__c newProduct = new AOB_InsuranceProduct__c();
    newProduct.AOB_Insurance__c = product.id;
    newProduct.AOB_Product__c = parentProduct.id;
    insert newProduct;
    return newProduct;
  }
  /**
   * @description This method is used to create a new product final offer
   * @param prId
   * @param offerId
   * @return ProductFinalOffer
   */
  public static AOB_ProductFinalOffer__c createProductFinalOffer(
    Id prId,
    Id offerId
  ) {
    AOB_ProductFinalOffer__c newProduct = new AOB_ProductFinalOffer__c();
    newProduct.AOB_FinalOffer__c = offerId;
    newProduct.AOB_Product__c = prId;
    insert newProduct;
    return newProduct;
  }
  /**
   * @description This method is used to create a new product final offer
   * @param screen
   * @return ProductFinalOffer
   */
  public static AOB_FinalOffer__c createFinalOffers(String screen) {
    AOB_FinalOffer__c offer = new AOB_FinalOffer__c();
    offer.AOB_APIName__c = 'loanTermTotalServiceFees';
    offer.AOB_Is_Currency__c = true;
    offer.AOB_Unit__c = '';
    offer.AOB_Screen__c = screen;
    offer.AOB_Is_Right__c = false;
    offer.AOB_InsuranceRelated__c = false;
    offer.AOB_Description__c = 'test';
    offer.AOB_Detail__c = 'test';
    offer.AOB_Helptext__c = '';
    offer.AOB_Label__c = 'Total monthly service fees over {loanTerm:duration} months';
    offer.AOB_Order__c = 2;
    offer.AOB_ParentLevel1__c = 'loanDetailsRs';
    offer.AOB_ParentLevel2__c = 'fees';
    offer.AOB_Section__c = 'See more';
    insert offer;
    return offer;
  }
  /**
   * @description This method is used to create a new product
   * @param prId
   * @param plan
   * @return Product2
   */
  public static AOB_ProductOption__c createProductOption(Id prId, String plan) {
    AOB_ProductOption__c pr = new AOB_ProductOption__c();
    pr.AOB_Product__c = prId;
    pr.AOB_InsurancePlanID__c = plan;
    insert pr;
    return pr;
  }
  /**
   * @description This method is used to create a new AOB_RequiredDocument__c record
   * @param productId
   * @param description
   * @param helpText
   * @param order
   * @return AOB_RequiredDocument__c
   */
  public static AOB_RequiredDocument__c createRequiredDocument(
    Id productId,
    String description,
    String helpText,
    Integer order
  ) {
    AOB_RequiredDocument__c requiredDocument = new AOB_RequiredDocument__c(
      AOB_Product__c = productId,
      AOB_Description__c = description,
      AOB_HelpText__c = helpText,
      AOB_Order__c = order
    );
    insert requiredDocument;
    return requiredDocument;
  }
  /**
   * @description This method is used to create a new AOB_ProductQualifications__c record
   * @param productId
   * @param description
   * @param helpText
   * @param order
   * @return AOB_ProductQualifications__c
   */
  public static AOB_ProductQualifications__c createProductQualification(
    Id productId,
    String description,
    String helpText,
    Integer order
  ) {
    AOB_ProductQualifications__c productQualification = new AOB_ProductQualifications__c(
      AOB_Product__c = productId,
      AOB_Description__c = description,
      AOB_HelpText__c = helpText,
      AOB_Order__c = order
    );
    insert productQualification;
    return productQualification;
  }
  /**
   * @description This method is used to create a new application line item
   * @param productId
   * @param applicationId
   * @return AOB_ApplicationLineItem__c
   */
  public static AOB_ApplicationLineItem__c createApplicationLineItem(
    Id productId,
    Id applicationId
  ) {
        AOB_ApplicationLineItem__c newApplicationLineItem = new AOB_ApplicationLineItem__c(
          AOB_Product__c = productId,
          AOB_Application__c = applicationId
        //  AOB_TECH_CCInsuranceID__c = '',
        //  AOB_HasInsurance__c = false,
        //  AOB_ProductOption__c = ''
        );
        insert newApplicationLineItem;
        return newApplicationLineItem;
  }
  /**
   * @description This method is used to create a new person account
   * @return account
   */
  public static Account createPersonAccount() {
    RecordType personAccountRT = [
      SELECT Id
      FROM RecordType
      WHERE
        Name = :AOB_Constants.PERSON_ACCOUNT
        AND SObjectType = :AOB_Constants.ACCOUNT
    ];
    Account acc = new Account();
    acc.FirstName = 'test';
    acc.LastName = 'test';
    acc.AOB_CommerceSiteId__c = 'SB-COZA';
    acc.personEmail = 'test@test.com';
    acc.RecordType = personAccountRT;
    insert acc;
    return acc;
  }
  /**
   * @description     genericObjectCreation: Created a record of the provided Object with the provided field values
   * @param objectName
   * @param values
   * @return True if the Record is created and Error otherwise
   */
  public static sObject genericObjectCreation(
    string objectName,
    Map<string, object> values
  ) {
    Map<String, Schema.SObjectType> mobjects = Schema.getGlobalDescribe();
    sObject n = mobjects.get(objectName).newSObject();
    for (string fieldName : values.keyset()) {
      n.put(fieldName, values.get(fieldName));
    }
    return n;
  }
}