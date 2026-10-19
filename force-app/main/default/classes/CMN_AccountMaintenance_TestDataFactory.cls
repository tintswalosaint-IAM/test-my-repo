/**
 * Base Test Factory class for use with Account Maintenance classes:
 * 
 * 1. CMN_BATCH_AccountMaintenance
 * 2. CMN_SRV_AccountOwnerUpdate
 * 3. CMN_SRV_AccountTeamUpdate
 *
 * @author Dhiraj Kumar (CloudSmiths)
 * @Create Date: 23/11/2023
 */
@IsTest
public with sharing class CMN_AccountMaintenance_TestDataFactory {

    private Boolean shouldInsert;

    /**
    * @description Default Constructor
    **/
    public CMN_AccountMaintenance_TestDataFactory() {
        this.shouldInsert = true;
    }

    /**
    * @description Constructor
    * @param shouldInsert 
    **/
    public CMN_AccountMaintenance_TestDataFactory(Boolean shouldInsert) {
        this.shouldInsert = shouldInsert;
    }

    /**
    * @description Utility method to insert new records
    * @param recordsToInsert 
    * @return List<SObject> 
    **/
    public List<SObject> insertRecords(List<SObject> recordsToInsert) {
        if (this.shouldInsert) {
            insert recordsToInsert;
        }
        return recordsToInsert;
    }

    /**
    * @description Crate Persion Accounts with specific record type
    * @author Derek Hughes | 30-01-2024 
    * @param numberOfRecords 
    * @param recordTypeId 
    * @return List<Account> 
    **/
    public List<Account> createPersonAccounts(Integer numberOfRecords, Id recordTypeId) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            accounts.add(
                new Account(
                    FirstName = 'Jane',
                    LastName = 'Doe - ' + i,
                    RecordTypeId = recordTypeId,
                    VIPIndicator__c = true,
                    RelationshipMgrCode__c = 'XBWER' + i,
                    ExternalCIFCountry__c = 'GH'
                )
            );
        }
        return insertRecords(accounts);
    }

    
    /**
    * @description Build a single new user for a specific profile
    * @author Derek Hughes | 30-01-2024 
    * @param profileId 
    * @return User 
    **/
    public User createUser(Id profileId) {
        Integer randomNumber =(integer) (math.random() * 100000.0);
        return new User(
            ProfileId = profileId,
            LastName = 'Doe',
            FirstName = 'Jane',
            Email = 'janedoe@sbg.com',
            Username = 'janedoe@sbg.com' + randomNumber,
            CommunityNickname = 'janesbg' + randomNumber,
            CompanyName = 'SBG',
            Title = 'Volunteer',
            Alias = 'aob',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            isActive = true
        );
    }

    /**
    * @description Create Account Team Members with the specified attributes
    * @author Derek Hughes | 30-01-2024 
    * @param user 
    * @param roleName 
    * @param accounts 
    * @return List<AccountTeamMember> 
    **/
    public List<AccountTeamMember> createAccountTeamMembers(Id user, String roleName, List<Account> accounts) {
        List<AccountTeamMember> members = new List<AccountTeamMember>();
        for (Account account :accounts) {
            members.add(
                new AccountTeamMember(
                    AccountId = account.Id,
                    UserId = user,
                    TeamMemberRole = roleName,
                    AccountAccessLevel = 'Edit',
                    OpportunityAccessLevel = 'Edit',
                    CaseAccessLevel = 'Edit',
                    ContactAccessLevel = 'Edit'
                )
            );
        }
        return insertRecords(members);
    }

    /**
    * @description Create test users with specified attributes
    * @author Derek Hughes | 30-01-2024 
    * @param numberOfRecords 
    * @param profileId 
    * @param aeCode 
    * @param portfolioCode 
    * @param roleName 
    * @return List<User> 
    **/
    @SuppressWarnings('PMD.ExcessiveParameterList') 
    public List<User> createUsers(
        Integer numberOfRecords,
        Id profileId,
        String aeCode,
        String portfolioCode,
        String roleName
    ) {
        List<User> users = new List<User>();
        for (Integer i = 0; i < numberOfRecords; i++) {
            User user = this.createUser(profileId);
            user.RM_AE_Code__c = aeCode + i;
            user.Portfolio_Role_Name__c = roleName;
            user.Portfolio_Codes__c = portfolioCode + i;
            user.User_Country__c = 'GH';
            user.User_Country__c = 'GH';
            user.isActive = true;
            users.add(user);
        }
        return insertRecords(users);
    }
}