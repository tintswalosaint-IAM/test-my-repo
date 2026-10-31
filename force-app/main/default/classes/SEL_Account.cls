/**
* @description Class for Selector Class for Account Entity
*
* Story:SFP-36380
*
* @author Ikyatha Naidu
*
* @date May 2022
* @last modified on  : 15-07-2025
* @last modified by  : Karabo Machubeni
* @ Modification Description :SFP-36380, used new field signing arrangement SBO UK {29-02-2024 - Ikyatha Naidu}
							 :SFP-51234, amened the fields set to include W&I relevant fields for account owner assignment
*
* @last modified on  : 2026-06-15
* @last modified by  : Shams
* @ Modification Description :SFP-58522, added selectByIdentityNumbersAndRecordType and
*                              selectByNameDobAndRecordType for two-step beneficiary account search
*
*@LastModifiedReason : SFP-55759 - Added the following Account fields to the
*                      selector method to support the Moonstone
*                      Disclosure implementation:
*                      OwnerId, CMN_IdentityNumber__pc,
*
*@LastModified by : Gigyasu Jain
*Group : SBFC
*Last Modified Date : 15-07-2026
*/

 
public inherited sharing class SEL_Account extends sbgplatform.fflib_SObjectSelector {
    /**
   * @description declaration of fields
   * */
    private static Set<String> fields = new Set<String>{
            'Id','Name','FirstName','LastName','Date_of_Birth__c','Passport_Number__c',
            'Identification_Number__c','AOB_IdentityNumber__c','Salutation','FinServ__CountryOfBirth__pc','Second_Country_of_Nationality__c','CMN_CustomerBPID__pc','CMN_CustomerBPID__c',
            'ICS_Country_of_Nationality__c','Identification_or_Passport_Number__c','Different_FirstName__c','Different_LastName__c',
            'Different_MiddleName__c','Alternative_Phone__c','lastName','MiddleName','ICS_Country_of_Residence__c',
            'Former_Names_Maiden_Name__c','Former_Name__c','Maiden_Name__c','FinServ__Gender__pc','Phone','PersonTitle',
            'PersonBirthdate','ICS_Country_Code__c','PersonEmail','FinServ__MaritalStatus__pc','Town_City_of_Birth__c',
            'PersonContactId','SVC_AccountBalance__c','FinServ__CustomerID__c','createddate','accountnumber','FinServ__CustomerType__c',
            'CurrencyIsoCode','Sort_Code__c','ExternalCIFCountry__c','ExternalCIFId__c', 'RecordTypeId','Relationship_between_business__c',
            'SVC_Country__c','PersonMailingAddress','WI_Jurisdiction__c','Owner','Owner.Email',
            'FinServ__PrimaryAddressIsMailing__pc','Registration_Number__c','Company_Address__c',
            'Date_of_Incorporation__c','FinServ__MailingAddress__pc','WI_Address__c','percentage_of_the_Business_which_owned__c','GUID__c'
            ,'CMN_IdentityNumber__pc','ExternalIdentifier__c','RelationshipMgrCode__c','OwnerId','VIPIndicator__c','ExternalSystemId__c','ExternalCIFCountry__c',
            'Owner.IsActive', 'Owner.RM_AE_Code__c', 'NatureofBusiness__c', 'FinServ__CurrentEmployer__pc','WI_VisaPermitExpiryDate__pc',
            'Staff_Indicator__c','Gross_Income__c','PersonMailingCountry',
            'FinServ__BranchCode__c','FinServ__BranchName__c','PersonMailingPostalCode','PersonMailingStreet','PersonIndividualId'
    };


    /**
* @description Implementation method for Account Object as part of fflib framweork
* @return Schema.SObjectType
*/
    public override Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Account.Id,
                Account.firstName,
                Account.lastName,
                Account.PersonBirthdate,
                Account.ExternalCIFCountry__c,
                Account.ExternalCIFId__c
        };
    }

    /**
     * @description Method to fetch Account based on Parameters
    * @param accountId
    * @return Account
     **/
    public Account selectById(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountId == null){
            return null;
        } else{
            fieldQueryFactory.setCondition('id = :accountId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Method to fetch list of Account based on Parameters
    * @param ids
    * @return List<Account>
     **/
    public List<Account> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(ids == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('id IN :ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    public List<Account> selectByIdsWoSharing(Set<Id> ids) {
        return new NoAccountSharing().selectByIds(this, ids);
    }

    /**
    * @description Method to check Existing list of Account based on Parameters for SBO UK OnBoarding Feature
    * @param jsonData
    * @return List<Account>
    **/
    public List<Account> selectByFirstLastNameBirthday(String jsonData) {
        // Deserialize the JSON data
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        // Extract birthdate components
        Integer birthYear = Integer.valueOf(((String) parsedJson.get('birthDate')).split('-')[0]);
        Integer birthMonth = Integer.valueOf(((String) parsedJson.get('birthDate')).split('-')[1]);
        Integer birthDay = Integer.valueOf(((String) parsedJson.get('birthDate')).split('-')[2]);
        // Extract and convert firstName and lastName to lowercase for comparison
        String firstName = ((String) parsedJson.get('firstName')).trim().toLowerCase();
        String lastName = ((String) parsedJson.get('lastName')).trim().toLowerCase();
        // Create birthdate from components
        Date personBirthDate = Date.newInstance(birthYear, birthMonth, birthDay);
        // Initialize query factory
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        String cifCountry = 'OS'; // Hardcoded value for CIF country

        if(cifCountry != null){
            if(firstName != null && lastName != null && personBirthDate != null ) {
                fieldQueryFactory.setCondition('firstName = :firstName AND lastName = :lastName AND PersonBirthdate = :personBirthDate AND ExternalCIFCountry__c = :cifCountry');
            }
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select Accounts for a set of External Identifiers
    * @author Raymond Magezi | 18-11-2024
    * @param accountIdentityNumbers Set of account identity numbers to match against CMN_IdentityNumber__pc
    * @return List<Account>
    **/

    public List<Account> selectByPersonIdentityNumber(Set<String> accountIdentityNumbers) {
        if(!Schema.SobjectType.Account.isaccessible()){
            return null;
        }

        final List<Account> accounts = [
                SELECT Id, ExternalIdentifier__c, CMN_IdentityNumber__pc,VIPIndicator__c,PersonIndividualId, Name
                FROM Account
                WHERE CMN_IdentityNumber__pc IN :accountIdentityNumbers
        ];

        return accounts;
    }

    /**
    * @description Bulk lookup of Person Accounts whose CMN_IdentityNumber__pc matches any value
    *              in the supplied set, restricted to a specific Account record type.
    *              Used as Step 1 of the two-step beneficiary account search — mirrors the pattern
    *              in INS_Get_Account.selectAccountByName().
    * @author Shams | 2026-06-15
    * @param identityNumbers Set of national identity number values to match against CMN_IdentityNumber__pc
    * @param accountRecordTypeId RecordTypeId used to restrict results to a specific Account record type
    * @return List<Account> Account records whose identity number is in the supplied set
    * User Story : SFP-58522
    **/
    public List<Account> selectByIdentityNumbersAndRecordType(Set<String> identityNumbers, Id accountRecordTypeId) {
        sbgplatform.fflib_QueryFactory accountQueryFactory = newQueryFactory(false, false, false);
        accountQueryFactory.setCondition('CMN_IdentityNumber__pc IN :identityNumbers AND RecordTypeId = :accountRecordTypeId');
        accountQueryFactory.selectFields(fields);
        String soqlQuery = String.escapeSingleQuotes(accountQueryFactory.toSOQL());
        return Database.query(soqlQuery);
    }

    /**
    * @description Per-member fallback lookup of Person Accounts by first name, last name, and date of birth,
    *              restricted to a specific Account record type. Used as Step 2 of the two-step beneficiary
    *              account search for members whose identity number was not found in Step 1 — mirrors the
    *              pattern in INS_Get_Account.selectAccountByName().
    * @author Shams | 2026-06-15
    * @param firstName Account FirstName field value to filter on
    * @param lastName Account LastName field value to filter on
    * @param dateOfBirth Account PersonBirthdate field value to filter on
    * @param accountRecordTypeId RecordTypeId used to restrict results to a specific Account record type
    * @return List<Account> Account records matching the supplied name and date of birth
    * User Story : SFP-58522
    **/
    public List<Account> selectByNameDobAndRecordType(String firstName, String lastName,
                                                      Date dateOfBirth, Id accountRecordTypeId) {
        sbgplatform.fflib_QueryFactory accountQueryFactory = newQueryFactory(false, false, false);
        accountQueryFactory.setCondition(
            'FirstName = :firstName AND LastName = :lastName ' +
            'AND PersonBirthdate = :dateOfBirth AND RecordTypeId = :accountRecordTypeId'
        );
        accountQueryFactory.selectFields(fields);
        String soqlQuery = String.escapeSingleQuotes(accountQueryFactory.toSOQL());
        return Database.query(soqlQuery);
    }

    /**
    * @description Method to fetch relation shipName  of Account based on Parameters
    * @param relationshipName
    * @return List<Account>
    **/
    public List<Account> selectByRelationship(String relationshipName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Relationship_between_business__c =: relationshipName');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
        * @description Method list of Account based on id
        * @param accountId
        * @return List<Account>
        **/
    public List<Account> selectByAccountId(Id accountId) {
        sbgplatform.fflib_QueryFactory accountQueryFactory = newQueryFactory();

        accountQueryFactory.selectField('Id');


        accountQueryFactory.subselectQuery('Opportunities')
                .selectField('Id');


        accountQueryFactory
                .selectField('PersonContactId');

        accountQueryFactory.setCondition('Id = :accountId');

        String safeQuery = String.escapeSingleQuotes(accountQueryFactory.toSOQL());
        return (List<Account>) Database.query(safeQuery);
    }

    /**
     * @description Method list of Account based on External Idnetifier
     * @param accountIdentityNumbers
     * @return List<Account>
     **/
    public List<Account> selectByPersonExternalIdentifier(Set<String> accountIdentityNumbers) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ExternalIdentifier__c IN :accountIdentityNumbers');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Method to fetch Account with Opportunities by Identity Number
     * @author Michal Orawiec | 15-10-2025
     * @param idNumber String
     * @return Account with related Opportunities
     */
    public List<Account> selectByIdentityNumberWithOpportunities(String idNumber) {
        return selectByIdentityNumberWithOpportunities(idNumber, null);
    }

    /**
     * @description Method to fetch Account with Opportunities by Identity Number and customer type
     * @param idNumber String
     * @param customerType String
     * @return Account with related Opportunities
     */
    public List<Account> selectByIdentityNumberWithOpportunities(String idNumber, String customerType) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, true);

        // Set condition for identity number
        String condition = 'CMN_IdentityNumber__pc = :idNumber';
        if (String.isNotBlank(customerType)) {
            condition += ' AND FinServ__CustomerType__c = :customerType';
        }
        queryFactory.setCondition(condition);

        // Select Account fields
        queryFactory.selectFields(new List <String>{
                'PersonEmail', 'PersonMobilePhone', 'FinServ__Gender__pc', 'CMN_IdentityNumber__pc'
        })
                .setLimit(1);

        // Add subquery for Opportunities
        queryFactory.subselectQuery('Opportunities')
                .selectFields(new List <String>{
                        'Id', 'Name', 'INS_OnboardingStep__c', 'Total_Cover_Amount__c', 'Total_Monthly_Premium__c', 'StageName'
                })
                .setCondition('IsClosed = FALSE')
                .setOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING)
                .setLimit(1);

        String query = String.escapeSingleQuotes(queryFactory.toSOQL());
        return Database.query(query);
    }

    /**
   * @description Method to fetch Account based on Id with PersonIndividualId
   * @author Michal Orawiec | 15-10-2025
   * @param accountId String
   * @return Account
   **/
    public Account selectByIdWithPersonIndividualId(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountId == null){
            return null;
        } else{
            fieldQueryFactory.setCondition('id = :accountId');
        }
        fieldQueryFactory.selectField('PersonIndividualId');
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Method to fetch Accounts based on a set of Ids including PersonIndividualId
     * @author Shams Arifeen | 2026-06-26
     * @user story SFP-58864
     * @param ids Set<Id>
     * @return List<Account>
     **/
    public List<Account> selectByIdsWithPersonIndividualId(Set<Id> ids) {
        if (ids == null || ids.isEmpty()) {
            return new List<Account>();
        }
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN :ids');
        fieldQueryFactory.selectField('PersonIndividualId');
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
     * @description Method to fetch FSC Person Account based on PersonEmail
     * @param email String email to match against PersonEmail
     * @return List<Account>
     **/
    public List<Account> selectPersonAccountByEmail(String email) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('IsPersonAccount = true AND PersonEmail = :email');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Method to fetch Account with additional fields for servicing records
     * @author Michal Orawiec
     * @date 15-10-2025
     * @param accountId String Account ID to fetch
     * @return Account Account record with servicing fields
     **/
    public Account selectByIdWithServicingFields(String accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountId == null){
            return null;
        } else{
            fieldQueryFactory.setCondition('id = :accountId');
        }
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.selectFields(new List<String>{
                'PersonMobilePhone',
                'ShippingStreet',
                'ShippingCity',
                'ShippingState',
                'ShippingPostalCode',
                'ShippingCountry',
                'Citizenship__c',
                'EmploymentStatus__c',
                'NatureofBusiness__c',
                'FinServ__CurrentEmployer__pc',
                'Source_of_Funds__c',
                'Source_of_Funds_Type__c',
                'EmploymentIndustry__c',
                'FinServ__Occupation__pc',
                'BillingStreet',
                'BillingCity',
                'BillingPostalCode',
                'BillingCountry',
                'FirstName',
                'LastName',
                'FinServ__Gender__pc'
        });
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Searches Accounts by dynamic LIKE filter clauses and
     *              record type IDs. Used by IAM_CTRL_ClientFinder to cast
     *              a wide candidate net before in-memory refinement.
     *              Note: filterClauses are pre-escaped by the caller;
     *              String.escapeSingleQuotes is intentionally omitted here
     *              to avoid double-escaping the embedded LIKE values.
     * @author Preetham | 2026-07-21
     * @param filterClauses List of pre-built, escaped LIKE conditions
     *                      (e.g. "Name LIKE '%John%'")
     * @param recordTypeIds Set of Account RecordTypeIds to restrict results to
     * @param queryLimit    Maximum number of Accounts to return
     * @return List<Account> Matching Account records
     */
    public List<Account> selectBySearchCriteria(
        List<String> filterClauses, Set<Id> recordTypeIds, Integer queryLimit
    ) {
        if (filterClauses == null || filterClauses.isEmpty()
            || recordTypeIds == null || recordTypeIds.isEmpty()) {
            return new List<Account>();
        }
        System.debug('Record Type IDs for search: ' + recordTypeIds);

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);

        // Build the combined condition: filter clauses OR'd together,
        // then AND'd with the record type restriction via bind variable
        String combinedFilter = '(' + String.join(filterClauses, ' AND ') + ')';
        fieldQueryFactory.setCondition(
            combinedFilter + ' AND RecordTypeId IN :recordTypeIds'
        );

        fieldQueryFactory.selectFields(new List<String>{
            'Id', 'Name', 'FirstName', 'LastName', 'ExternalCIFId__c',
            'Phone', 'PersonEmail', 'Registration_number__c',
            'RecordTypeId', 'RecordType.Name', 'CMN_IdentityNumber__pc', 'PersonBirthdate'
        });
        fieldQueryFactory.setOrdering('Name', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
        fieldQueryFactory.setLimit(queryLimit);

        // Values in filterClauses are already escaped; skip final escape
        // to prevent double-escaping that would break the LIKE patterns
        System.debug('Query is ' + fieldQueryFactory.toSOQL());
        return Database.query(fieldQueryFactory.toSOQL());
    }

    private without sharing class NoAccountSharing {
        /**
         * @description Returns Accounts by IDs without sharing.
         * @param accountSelector Account selector instance
         * @param ids Set of Account IDs
         * @return List<Account>
         */
        public List<Account> selectByIds(SEL_Account accountSelector, Set<Id> ids) {
            return accountSelector.selectByIds(ids);
        }
    }
}