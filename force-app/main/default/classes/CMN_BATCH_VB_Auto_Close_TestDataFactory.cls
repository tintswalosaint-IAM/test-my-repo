/**
 * @description       : Test Data Factory for CMN_BATCH_VB_Auto_Close_Phone_Cases_Test
 * @author            : Sandile Mathe
 * @group             : Voice Branch
 * @Created on        : 06-03-2025
**/
public with sharing class CMN_BATCH_VB_Auto_Close_TestDataFactory {

 /**
     * Creates a test Account
     * @return Account Id
     */
    public static Id createTestAccount() {
        // Check if the user has permission to create an Account
    if (!Schema.sObjectType.Account.isCreateable()) {
        return null;
    }

    // Create the Account record
    Account newAccount = new Account(Name = 'Test Account');

    // Perform a safe insert with error handling
    Database.SaveResult result = Database.insert(newAccount, false); 

    if (result.isSuccess()) {
        return result.getId();
    } 

    // Return null if insertion fails
    return null;
    }

    /**
     * Creates a test Service Type
     * @return Service Type Id
     */
    public static Id createTestServiceType() {
         // Check if the user has permission to create SVC_ServiceType__c records
    if (!Schema.sObjectType.SVC_ServiceType__c.isCreateable()) {
        return null;
    }

    // Create the Service Type record
    SVC_ServiceType__c serviceType = new SVC_ServiceType__c(
        Name = 'General Enquiry',
        SVC_Active__c = true
    );

    // Safe insert with error handling
    Database.SaveResult result = Database.insert(serviceType, false);

    if (result.isSuccess()) {
        return result.getId();
    } 

    // Return null if insertion fails
    return null;
    }

    /**
     * Creates a list of test Cases
     * @param count Number of cases to create
     * @param accountId Account Id to associate with the Cases
     * @return List of Case records
     */
    public static List<Case> createTestCases(Integer count, Id accountId) {
      // Check if the user has create permission on Case
    if (!Schema.sObjectType.Case.isCreateable()) {
        return new List<Case>();
    }

    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < count; i++) {
        cases.add(new Case(
            Status = 'New',
            Origin = 'Phone',
            SVC_ReasonForBreach__c = 'Login Issues',
            amazonconnect__AC_Contact_Id__c = 'Contact Channel 02345' + i,
            AccountId = accountId,
            Case_Owner_Country__c = 'ZA'
        ));
    }

    // Perform a safe insert
    Database.SaveResult[] results = Database.insert(cases, false);

    // Log any errors
    List<Case> insertedCases = new List<Case>();
    for (Integer j = 0; j < results.size(); j++) {
        if (results[j].isSuccess()) {
            insertedCases.add(cases[j]);
        } 
    }

    return insertedCases;
    }
    
    
    public static  user insertTestUser() {
       // Check if the user has read access to Profile
    if (!Schema.sObjectType.Profile.isAccessible()) {
        return null;
    }

    // Query the Profile securely
    Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

    // Check if the user has permission to create User records
    if (!Schema.sObjectType.User.isCreateable()) {
        return null;
    }

    // Create a test user
    User testUser = new User(
        Alias = 'testuser',
        Email = 'testuser@test.test',
        EmailEncodingKey = 'UTF-8',
        LastName = 'Test User',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US',
        ProfileId = profile.Id,
        TimeZoneSidKey = 'Europe/Berlin',
        Username = 'test.user.dev@stdb.chnwlsdev',
        RM_AE_Code__c = '0046385'
    );

    // Perform a safe insert
    Database.SaveResult result = Database.insert(testUser, false);

    if (result.isSuccess()) {
        return testUser;
    } 
    return null;
    }

    // This method is key for our Case DML exception test
    public static Case createCaseForDMLException(Id accountId) {
        Case c = new Case(
            Subject = 'Test exception',
            SVC_CustomerIdNumber__c = 'This supposed to cause an error, this text field has a limit of thirteen characters.',
            Description = 'This case is meant to fail DML due to validation.',
            Status = 'New',
            Origin = 'Web',
            AccountId = accountId
        );
        return c; 
    }

}