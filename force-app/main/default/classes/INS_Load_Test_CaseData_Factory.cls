/*------------------------------------------------------------
Author:        Kenneth Dlamini
Company:       Salesforce
Description:   Test data factory for Insurance Case test classes.
               Creates users, accounts, cases, and service types
               for use in @TestSetup methods.
Test Class:    N/A (test utility)

02-06-2025     Kenneth Dlamini    Initial version
14-07-2026     Given Khupai       SFP-46473 Refactored for TSR
                                  standards compliance
------------------------------------------------------------*/
@IsTest
public inherited sharing class INS_Load_Test_CaseData_Factory {

    private static final String DEFAULT_EMAIL_DOMAIN = '@test.standardbank.co.za';
    private static final String DEFAULT_LOCALE = 'en_US';
    private static final String DEFAULT_LANGUAGE = 'en_ZA';
    private static final String DEFAULT_TIMEZONE = 'Africa/Johannesburg';
    private static final String DEFAULT_ENCODING = 'UTF-8';
    private static final String DEFAULT_COUNTRY = 'ZA';
    private static final String DEFAULT_CURRENCY = 'ZAR';

    /*------------------------------------------------------------
    *   Purpose:  Creates and inserts a test User with System
    *             Administrator profile.
    *   Parameters: userIndex — unique index to avoid duplicate usernames
    *   Returns:    User — the inserted User record
    *--------------------------------------------------------------*/
    public static User createTestUser(Integer userIndex) {
        User testUser = new User(
            Username = userIndex + 'salesforceoffers1' + DEFAULT_EMAIL_DOMAIN,
            FirstName = 'TestFirst' + userIndex,
            LastName = 'TestLast' + userIndex,
            Email = userIndex + 'salesforceoffers1' + DEFAULT_EMAIL_DOMAIN,
            Alias = String.valueOf(userIndex).left(3) + 'SFO',
            CommunityNickname = 'TestNick' + userIndex,
            TimeZoneSidKey = DEFAULT_TIMEZONE,
            LocaleSidKey = DEFAULT_LOCALE,
            EmailEncodingKey = DEFAULT_ENCODING,
            ProfileId = [SELECT Id FROM Profile WHERE Name = :CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN LIMIT 1].Id,
            LanguageLocaleKey = DEFAULT_LANGUAGE
        );
        insert testUser;
        return testUser;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates and inserts a Person Account test record.
    *   Parameters: aTestUser — the owning User
    *   Returns:    Account — the inserted Account record
    *--------------------------------------------------------------*/
    public static Account createTestAccount(User aTestUser) {
        Id personAccountRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();

        Account testAccount = new Account(
            Active__c = 'true',
            FirstName = 'SalesforceTestAccount',
            LastName = 'SalesforceTest',
            PersonEmail = 'salesforcetestaccount1001' + DEFAULT_EMAIL_DOMAIN,
            SVC_Country__c = DEFAULT_COUNTRY,
            RecordTypeId = personAccountRtId,
            OwnerId = aTestUser.Id
        );
        insert testAccount;
        return testAccount;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates and inserts a test Case record.
    *   Parameters: aTestUser      — the owning User
    *               aTestAccount   — the parent Account
    *               subject        — Case subject
    *               description    — Case description
    *               businessHoursId — Business Hours record ID
    *   Returns:    Case — the inserted Case record
    *--------------------------------------------------------------*/
    public static Case createTestCase(
        User aTestUser,
        Account aTestAccount,
        String subject,
        String description,
        String businessHoursId
    ) {
        Case testCase = new Case(
            Status = 'New',
            BusinessHoursId = businessHoursId,
            Origin = 'Email',
            Subject = subject,
            Description = description,
            CurrencyIsoCode = DEFAULT_CURRENCY,
            Case_Owner_Country__c = DEFAULT_COUNTRY,
            AccountId = aTestAccount.Id,
            OwnerId = aTestUser.Id
        );
        insert testCase;
        return testCase;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates and inserts a test Service Type record.
    *   Returns:    SVC_ServiceType__c — the inserted record
    *--------------------------------------------------------------*/
    public static SVC_ServiceType__c createServiceType() {
        SVC_ServiceType__c svType = new SVC_ServiceType__c(
            SVC_Active__c = true,
            SVC_Description__c = 'Test Service Type 01',
            SVC_Category__c = 'SVC_ServiceRequest',
            SVC_SubCategory__c = 'Request',
            Name = 'Insurance: Test Service - Refunds'
        );
        insert svType;
        return svType;
    }
}