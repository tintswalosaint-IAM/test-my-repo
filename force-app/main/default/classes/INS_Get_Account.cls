/**
 * @description       : Selector Class for Account Entity (fflib Pattern)
 * @author            : Shamsul Arifeen
 * @last modified on  : 08-03-2026
 * user story         : SFP-26933
 * Modification       : Jaco de Lange - Added person account record type id condition to selectAccountByName.
 * LastModification   : SFP-46847: Irshad - Added query condition to check for prospectPersonAccount Record Type
 * Modification       : Jaco de Lange - SFP-59700 - Add 'IAM Liberty' as customer type differentiator.
 * @last modified on  : 03-08-2026
 * 
 **/
public without sharing class INS_Get_Account extends sbgplatform.fflib_SObjectSelector {

    private static Set<String> fields = new Set<String>{
        'Id',
        'IsDeleted',
        'MasterRecordId',
        'LastName',
        'FirstName',
        'PersonBirthdate',
        'MiddleName',
        'Suffix',
        'Name',
        'RecordTypeId',
        'CMN_IdentityNumber__pc',
        'FinServ__CustomerType__c'
    };

    /**
    * @description Implementation method for Account Object as part of fflib framework
    * @author Shamsul Arifeen
    * @return Schema.SObjectType
    **/
    public override Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    /**
    * @description Method to get list of fields
    * @author Shamsul Arifeen
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.IsDeleted,
            Account.MasterRecordId,
            Account.LastName,
            Account.FirstName,
            Account.PersonBirthdate,
            Account.MiddleName,
            Account.Suffix,
            Account.Name,
            Account.RecordTypeId,
            Account.CMN_IdentityNumber__pc,
            Account.FinServ__CustomerType__c
        };
    }

    /**
    * @description  : Method to fetch list of Accounts based on Account Name and Date of Birth and Identity Number
    * @param : firstName,  lastName, dateOfBirth, identityNumber
    * @return : List<Account>
    **/
    public List<Account> selectAccountByName(String firstName, String lastName, Date dateOfBirth, 
                                           String identityNumber, String customerType, String country) {
        List<Account> accountsToReturn = new List<Account>();
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        
        String queryCondition;
        String personAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        String prospectPersonAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account - Prospect').getRecordTypeId();
        
        // First query: Search by identityNumber condition
        if (!String.isBlank(customerType)) {
            queryCondition = 'CMN_IdentityNumber__pc =: identityNumber AND FinServ__CustomerType__c =: customerType AND ExternalCIFCountry__c = :country AND (RecordTypeId =: personAccRecTypeId OR RecordTypeId =: prospectPersonAccRecTypeId)';
        } else {
            queryCondition = 'CMN_IdentityNumber__pc =: identityNumber AND FinServ__CustomerType__c != \'IAM Liberty\' AND ExternalCIFCountry__c = :country AND (RecordTypeId =: personAccRecTypeId OR RecordTypeId =: prospectPersonAccRecTypeId)';
        }
        fieldQueryFactory.setCondition(queryCondition);
        fieldQueryFactory.selectFields(fields);
        accountsToReturn = Database.query(fieldQueryFactory.toSOQL());
        system.debug('accountsToReturn=='+accountsToReturn);
        if (accountsToReturn.size() > 0) {
            return accountsToReturn;
        } else {
            // Second query: Search by name and date of birth
            if (!String.isBlank(customerType)) {
                queryCondition = 'FirstName =: firstName AND LastName =: lastName AND PersonBirthdate =: dateOfBirth ' +
                                 'AND ExternalCIFCountry__c = :country AND FinServ__CustomerType__c =: customerType AND (RecordTypeId =: personAccRecTypeId OR RecordTypeId =: prospectPersonAccRecTypeId)';
            } else {
                queryCondition = 'FirstName =: firstName AND LastName =: lastName AND PersonBirthdate =: dateOfBirth ' +
                                 'AND ExternalCIFCountry__c = :country AND FinServ__CustomerType__c != \'IAM Liberty\' AND (RecordTypeId =: personAccRecTypeId OR RecordTypeId =: prospectPersonAccRecTypeId)';
            }
            fieldQueryFactory.setCondition(queryCondition);
            fieldQueryFactory.selectFields(fields);
            accountsToReturn = Database.query(fieldQueryFactory.toSOQL());
            system.debug('accountsToReturnelse=='+accountsToReturn);
        }
        
        return accountsToReturn;
    }

    /* @description  : Method to fetch list of Accounts based on Account Name and Date of Birth
    * @param : List<GetCustomer>
    * @return : List<Account>
    **/
    @InvocableMethod(Label = 'Get customer from salesforce'
    Description = 'Get customer from salesforce')
    public static List<AccountResponse> selectAccountByNameFromFlow(List<GetCustomer> customerWrapper) {
        AccountResponse searchedAccount = new AccountResponse();
        list<Account> accounts = New INS_Get_Account().selectAccountByName(customerWrapper[0].firstName.trim(), customerWrapper[0].lastName.trim(), customerWrapper[0].dateOfBirth, customerWrapper[0].identityNumber, customerWrapper[0].customerType, customerWrapper[0].userCountry);
        if(accounts.size() > 0){
            searchedAccount.accountFound = true;
            searchedAccount.accountId = accounts[0].Id;
            searchedAccount.accountRecordTypeId = accounts[0].RecordTypeId;
        }else{
            searchedAccount.accountFound = false;
        }
        return new List<AccountResponse>{
            searchedAccount
        };
    }

    /**
     * @description : Wrapper Class to pass in the selectAccountByNameFromFlow.
     * @author : Shams Ul Arifeen
     **/
    public class GetCustomer {
        @InvocableVariable(label = 'First Name')
        public String firstName;
        @InvocableVariable(label = 'Last Name')
        public String lastName;
        @InvocableVariable(label = 'Date of birth')
        public Date dateOfBirth;
        @InvocableVariable(label = 'Identity Number')
        public String identityNumber;
        @InvocableVariable(label = 'Customer Type')
        public String customerType;
        @InvocableVariable(label = 'User Country')
        public String userCountry;
    }

    /* @description : Wrapper Class for searched account to pass back to flow.
    * @author  : Shams Ul Arifeen
    **/
    public class AccountResponse {
        @InvocableVariable(label = 'Account Id')
        public String accountId;
        @InvocableVariable(label = 'Account Found')
        public Boolean accountFound;
        @InvocableVariable(label = 'Account Record Type Id')
        public String accountRecordTypeId;
    }

}