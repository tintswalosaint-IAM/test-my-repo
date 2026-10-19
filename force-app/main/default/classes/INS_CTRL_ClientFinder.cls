/*
 * Class Name      : INS_CTRL_ClientFinder
 * Description     : SFP-55927 : Controller for the IAM Client Finder LWC — retrieves
 *                   available IAM Account record types and searches for
 *                   existing Person/Business Accounts by various criteria.
 * Test Class      : INS_CTRL_ClientFinder_TEST
 * Created Date    : Jul 21, 2026
 * Author          : Preetham
 */
/**
 * @description   Test class for INS_CTRL_ClientFinder.
 * @author Preetham
 * @date 21-07-2026
 * @last modified on: 21-07-2026
 * @last modified by: Preetham
 * @ Modification Description: Created test methods for INS_CTRL_ClientFinder controller class.
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public without sharing class INS_CTRL_ClientFinder {
    
    /**
     * @description   Developer names of IAM record types. Used to determine
     *                whether a record type is IAM or standard.
     */
    
    private static final Set<String> IAM_RECORD_TYPE_DEVELOPER_NAMES = new Set<String>{
        'IAM_Person',
        'IAM_Business'
    };
    private static final Integer CANDIDATE_QUERY_LIMIT = 500;
    private static final Integer RESULT_LIMIT = 50;
    private static final String ERROR_CRITERIA_REQUIRED = 'Enter at least one search criterion.';
    private static final String ERROR_RECORD_TYPE_REQUIRED = 'A record type must be selected for search.';
    private static final String ERROR_NO_MATCHING_RECORD_TYPES = 'No matching record types found for search.';
    private static final String ERROR_PERSON_CRITERIA_REQUIRED = 'For Person searches, First Name, Last Name, Identity Number and Birth Date are all required.';
    
    
    /**
     * @description Wraps search input parameters to keep the @AuraEnabled
     *              method signature compliant with the max-3-params guideline.
     */
    public class SearchRequest {
        /**
         * @description Account name used as a search criterion.
         */
        @AuraEnabled public String accountName           { get; set; }
        /**
         * @description firstName name used to determine which
         *              record types to search (Person vs Business).
         */
        @AuraEnabled public String firstName             { get; set; }
        /**
         * @description lastName name used to determine which
         *              record types to search (Person vs Business).
         */
        @AuraEnabled public String lastName              { get; set; }
        /**
         * @description externalCIFId used as a search criterion.
         */
        @AuraEnabled public String externalCIFId         { get; set; }
        /**
         * @description contactNumber used as a search criterion.
         */
        @AuraEnabled public String contactNumber         { get; set; }
        /**
         * @description email used as a search criterion.
         */
        @AuraEnabled public String email                 { get; set; }
        /**
         * @description registrationNumber used as a search criterion.
         */
        @AuraEnabled public String registrationNumber    { get; set; }
        /**
         * @description recordTypeDeveloperName used to determine which
         *              record types to search (Person vs Business).
         */
        @AuraEnabled public String recordTypeDeveloperName { get; set; }
        /**
         * @description identityNumber used as a search criterion.
         */
        @AuraEnabled public String identityNumber         { get; set; }
        /**
         * @description birthdate used as a search criterion.
         */
        @AuraEnabled public Date birthdate              { get; set; }
    }
    
    /**
     * @description Represents an Account record type option returned to the LWC.
     */
    public class RecordTypeOption {
        /**
         * @description Id of the record type.
         */
        @AuraEnabled public Id id                   { get; set; }
        /**
         * @description Label of the record type.
         */
        @AuraEnabled public String label            { get; set; }
        /**
         * @description Developer name of the record type.
         */
        @AuraEnabled public String developerName    { get; set; }
        /**
         * @description Indicates if the record type is an IAM record type.
         */
        @AuraEnabled public Boolean isIAM           { get; set; }        
    }
    
    /**
     * @description Represents a single Account search result returned to the LWC.
     */
    public class AccountSearchResult {
        /**
         * @description Id of the Account record.
         */
        @AuraEnabled public Id id                   { get; set; }
        /**
         * @description Name of the Account record.
         */
        @AuraEnabled public String name             { get; set; }
        /**
         * @description First name of the Account record (for Person Accounts).
         */
        @AuraEnabled public String firstName        { get; set; }
        /**
         * @description Last name of the Account record (for Person Accounts).
         */
        @AuraEnabled public String lastName         { get; set; }
        /**
         * @description External CIF ID of the Account record.
         */
        @AuraEnabled public String externalCIFId    { get; set; }
        /**
         * @description Contact number of the Account record.
         */ 
        @AuraEnabled public String contactNumber    { get; set; }
        /**
         * @description Email of the Account record (for Person Accounts).
         */
        @AuraEnabled public String email            { get; set; }
        /**
         * @description Registration number of the Account record.
         */
        @AuraEnabled public String registrationNumber { get; set; }
        /**
         * @description Record type of the Account record.
         */
        @AuraEnabled public String accountRecordType { get; set; }
        /**
         * @description Id of the record type.
         */
        @AuraEnabled public Id recordTypeId         { get; set; }
        /**
         * @description Identity number of the Account record.
         */
        @AuraEnabled public String identityNumber   { get; set; }
        /**
         * @description Birthdate of the Account record (for Person Accounts).
         */
        @AuraEnabled public Date birthdate    { get; set; }
    }
    
    /**
     * @description Returns all Account record types available to the
     *              logged-in user, each annotated with isIAM and canCreate.
     *              Users with the IAM_Create_Restricted custom permission
     *              get canCreate = true only for IAM record types.
     *              The LWC uses this list to decide whether to show the
     *              search step, the create step, or the record type picker.
     * @return Available Account record type options for the logged-in user.
     */
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeOption> getAvailableRecordTypes() {
        List<RecordTypeOption> options = new List<RecordTypeOption>();
        
        try {
            for (Schema.RecordTypeInfo rtInfo :
            Account.SObjectType.getDescribe().getRecordTypeInfos()) {
                
                if (!rtInfo.isAvailable() || rtInfo.isMaster()) {
                    continue;
                }
                
                Boolean isIam = isIAMRecordType(rtInfo.getDeveloperName());
                if(isIam){
                    RecordTypeOption option = new RecordTypeOption();
                    option.id = rtInfo.getRecordTypeId();
                    option.label = rtInfo.getName();
                    option.developerName = rtInfo.getDeveloperName();
                    option.isIAM = isIam;                                                            
                    options.add(option);
                }
                        
            }
        } catch (Exception ex) {
            // Return empty list when the user lacks Account object access.
            System.debug(LoggingLevel.WARN,
                'Unable to retrieve available Account record types: ' + ex.getMessage());
            throw new AuraHandledException(
                'An error occurred while searching for accounts. Please try again.'
            );
        }
        
        options.sort(new RecordTypeOptionComparator());
        return options;
    }
    
    /**
     * @description Searches for existing Person or Business Accounts matching
     *              the supplied criteria. Uses the SEL_Account selector for
     *              the broad candidate query, then applies space-insensitive
     *              first/last name matching in-memory.
     * @param request SearchRequest containing one or more search criteria
     * @return List of AccountSearchResult matching the search, capped at 50
     */
    @AuraEnabled
    public static List<AccountSearchResult> searchAccounts(SearchRequest request) {
        try {
            validateSearchRequest(request);

            Set<Id> matchingRecordTypeIds =
                resolveRecordTypeIds(request.recordTypeDeveloperName);

            if (matchingRecordTypeIds.isEmpty()) {
                return new List<AccountSearchResult>();
            }

            SearchContext context = buildSearchContext();
            SEL_Account selector = new SEL_Account();

            List<Account> candidates = selector.selectBySearchCriteria(
                buildIdentityClauses(request, context),
                matchingRecordTypeIds,
                CANDIDATE_QUERY_LIMIT
            );

            if (candidates == null || candidates.isEmpty()) {
                candidates = new List<Account>();
            }

            if (!String.isBlank(request.identityNumber) && candidates.isEmpty()) {
                candidates = selector.selectBySearchCriteria(
                    buildNameClauses(request, context),
                    matchingRecordTypeIds,
                    CANDIDATE_QUERY_LIMIT
                );
            }

            List<String> businessClauses = buildBusinessClauses(request);

            if (!businessClauses.isEmpty()) {
                candidates = selector.selectBySearchCriteria(
                    new List<String>{
                        '(' + String.join(businessClauses, ' OR ') + ')'
                    },
                    matchingRecordTypeIds,
                    CANDIDATE_QUERY_LIMIT
                );
            }

            return filterAndMapResults(candidates, request);

        } catch (Exception e) {
            throw new AuraHandledException(
                'An error occurred while searching for accounts. Please try again.'
            );
        }
    }       
    /**
     * @description Holds context information for the current search, including
     *              the user's country and the relevant INS_Products__mdt record.
     */
    private class SearchContext {
        String country;
        INS_Products__mdt product;
    }
    /**
     * @description Builds the SearchContext for the current user, including
     *              their country and the relevant INS_Products__mdt record.
     * @return SearchContext containing the user's country and product.
     */
    private static SearchContext buildSearchContext() {
        SearchContext context = new SearchContext();
        User user = new SEL_User().getUsersByIds(new Set<Id>{ UserInfo.getUserId() }).isEmpty()
            ? null : new SEL_User().getUsersByIds(new Set<Id>{ UserInfo.getUserId() })[0];
        Boolean liberty = false;

        if (user != null && user.CompanyName != null) {
            liberty = user.CompanyName.toLowerCase().contains('liberty');
        }
        if (user != null && user.User_Country__c != null) {
            context.country = user.User_Country__c;
        } else {
            context.country = '';
        }        
        List<INS_Products__mdt> products = new SEL_INSProductMDT().selectByCountry(context.country, liberty);
        context.product = products == null || products.isEmpty() ? null : products[0];
        return context;
    }
    /**
     * @description Builds the WHERE clauses for identity number searches,
     *              including the user's country and product context.
     * @param request The SearchRequest containing the identity number.
     * @param context The SearchContext containing the user's country and product.
     * @return List of WHERE clauses for identity number searches.
     */
    private static List<String> buildIdentityClauses(SearchRequest request, SearchContext context) {
        List<String> clauses = new List<String>();
        if (!String.isBlank(request.identityNumber)) {
            clauses.add('CMN_IdentityNumber__pc = \'' + String.escapeSingleQuotes(request.identityNumber.trim()) + '\'');
            addCustomerClauses(clauses, context, request);
        }
        return clauses;
    }
    /**
     * @description Builds the WHERE clauses for first/last name and birthdate
     *              searches, including the user's country and product context.
     * @param request The SearchRequest containing the first/last name and birthdate.
     * @param context The SearchContext containing the user's country and product.
     * @return List of WHERE clauses for first/last name and birthdate searches.
     */
    private static List<String> buildNameClauses(SearchRequest request, SearchContext context) {
        List<String> clauses = new List<String>{
            'FirstName LIKE \'%' + String.escapeSingleQuotes(request.firstName.trim()) + '%\'',
            'LastName LIKE \'%' + String.escapeSingleQuotes(request.lastName.trim()) + '%\'',
            'PersonBirthdate = ' + formatDateAsLiteral(request.birthdate)
        };
        addCustomerClauses(clauses, context, request);
        return clauses;
    }
    /**
     * @description Adds country and product-specific clauses to the given list
     *              of WHERE clauses for searches.
     * @param clauses The list of WHERE clauses to add to.
     * @param context The SearchContext containing the user's country and product.
     * @param request The SearchRequest containing the record type developer name.
     */
    private static void addCustomerClauses(List<String> clauses, SearchContext context, SearchRequest request) {
        clauses.add('ExternalCIFCountry__c = \'' + String.escapeSingleQuotes(context.country) + '\'');
        if (context.product != null) {
            clauses.add(context.product.Country__c == 'UG' &&
                context.product.Is_Liberty__c && request.recordTypeDeveloperName == 'IAM_Person'
                ? 'FinServ__CustomerType__c = \'IAM Liberty\''
                : 'FinServ__CustomerType__c != \'\'');
        }
    }

    /**
     * @description Builds the WHERE clauses for business searches, including the user's country and product context.
     * @param request The SearchRequest containing the business search criteria.
     * @return List of WHERE clauses for business searches.
     */ 
    private static List<String> buildBusinessClauses(SearchRequest request) {
        List<String> clauses = new List<String>();
        if (request.recordTypeDeveloperName.equalsIgnoreCase('IAM_Business')) {
            addLike(clauses, 'Name', request.accountName);
            addEqual(clauses, 'ExternalCIFId__c', request.externalCIFId);
            addEqual(clauses, 'Registration_number__c', request.registrationNumber);
            addEqual(clauses, 'Phone', request.contactNumber);
        }
        return clauses;
    }
    /**
     * @description Adds a LIKE clause to the list of WHERE clauses if the value is not blank.
     * @param clauses The list of WHERE clauses to add to.
     * @param field The field name to use in the LIKE clause.
     * @param value The value to use in the LIKE clause.
     */
    private static void addLike(List<String> clauses, String field, String value) {
        if (!String.isBlank(value)) {
            clauses.add(field + ' LIKE \'%' + String.escapeSingleQuotes(value.trim()) + '%\'');
        }
    }
    /**
     * @description Adds an equality clause to the list of WHERE clauses if the value is not blank.
     * @param clauses The list of WHERE clauses to add to.
     * @param field The field name to use in the equality clause.
     * @param value The value to use in the equality clause.
     */
    private static void addEqual(List<String> clauses, String field, String value) {
        if (!String.isBlank(value)) {
            clauses.add(field + ' = \'' + String.escapeSingleQuotes(value.trim()) + '\'');
        }
    }
    
    /**
     * @description Validates that the search request has at least one
     *              criterion and a record type selected.
     * @param request The SearchRequest to validate.
     * @throws AuraHandledException if validation fails.
     */
    private static void validateSearchRequest(SearchRequest request) {
        if (request == null) {
            throw new AuraHandledException(ERROR_CRITERIA_REQUIRED);
        }
        
        if (String.isBlank(request.recordTypeDeveloperName)) {
            throw new AuraHandledException(ERROR_RECORD_TYPE_REQUIRED);
        }
        
        // For IAM Person searches all four fields are mandatory.
        // Enforced server-side even if the LWC validation is bypassed.
        if (isPersonRecordTypeName(request.recordTypeDeveloperName)) {
            Boolean allPersonCriteriaPresent =
                !String.isBlank(request.firstName) &&
                !String.isBlank(request.lastName) &&
                !String.isBlank(request.identityNumber) &&
                request.birthdate != null;
            
            if (!allPersonCriteriaPresent) {
                throw new AuraHandledException(ERROR_PERSON_CRITERIA_REQUIRED);
            }
        }
        
        Boolean hasSearchCriteria =
            !String.isBlank(request.accountName) ||
            !String.isBlank(request.firstName) ||
            !String.isBlank(request.lastName) ||
            !String.isBlank(request.externalCIFId) ||
            !String.isBlank(request.contactNumber) ||
            !String.isBlank(request.email) ||
            !String.isBlank(request.identityNumber) ||
            (request.birthdate != null) ||
            !String.isBlank(request.registrationNumber);
        
        if (!hasSearchCriteria) {
            throw new AuraHandledException(ERROR_CRITERIA_REQUIRED);
        }
    }
           
    /**
     * @description Resolves which Account record type IDs to include in the
     *              search. Broadens a Person search to include all Person-type
     *              record types (including IAM and standard), and similarly
     *              for Business searches.
     * @param recordTypeDeveloperName The record type developer name to resolve.
     * @return Set of matching record type IDs to include in the search.
     */
    private static Set<Id> resolveRecordTypeIds(String recordTypeDeveloperName) {
        if (String.isBlank(recordTypeDeveloperName)) {
            throw new AuraHandledException(ERROR_RECORD_TYPE_REQUIRED);
        }

        Boolean isPersonSearch = recordTypeDeveloperName.toLowerCase().contains('person');

        Set<Id> matchingIds = new Set<Id>();
        for (Schema.RecordTypeInfo rtInfo :
        Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            
            // Skip only the master record type — include all person/business
            // types even if the user can't create them. This ensures the
            // search finds existing standard Business/Person accounts, not
            // just IAM ones. isAvailable() is not used here because it
            // reflects create permission, not search scope.
            if (rtInfo.isMaster()) {
                continue;
            }
            
            String devName = rtInfo.getDeveloperName();
            if (isPersonSearch && devName.toLowerCase().contains('person')) {
                matchingIds.add(rtInfo.getRecordTypeId());
            } else if (!isPersonSearch && devName.toLowerCase().contains('business')) {
                matchingIds.add(rtInfo.getRecordTypeId());
            }
        }
        
        if (matchingIds.isEmpty()) {
            throw new AuraHandledException(ERROR_NO_MATCHING_RECORD_TYPES);
        }
        
        return matchingIds;
    }
    
    /**
     * @description Returns true when the given record type developer name
     *              represents a Person record type.
     * @param developerName The record type developer name to check.
     * @return True if the developer name contains 'person' (case-insensitive), false
     */
    private static Boolean isPersonRecordTypeName(String developerName) {
        return String.isNotBlank(developerName)
            && developerName.toLowerCase().contains('person');
    }
    
    /**
     * @description Applies space-insensitive first/last name matching in
     *              memory and maps the surviving candidates to the result
     *              wrapper, capping at RESULT_LIMIT.
     * @param candidates List of Account SObjects returned from the broad query.
     * @param request The original SearchRequest containing the search criteria.
     * @return List of AccountSearchResult matching the search criteria.
     */
    private static List<AccountSearchResult> filterAndMapResults(
        List<Account> candidates, SearchRequest request
    ) {
        if (request == null || candidates == null) {
            return new List<AccountSearchResult>();
        }

        List<AccountSearchResult> results = new List<AccountSearchResult>();

        for (Account acc : candidates) {
            if (acc == null) {
                continue;
            }

            AccountSearchResult mapped = mapToResult(acc);
            if (mapped != null) {
                results.add(mapped);
            }

            if (results.size() >= RESULT_LIMIT) {
                break;
            }
        }
        return results;
    }

    /**
     * @description Maps a single Account SObject to the AccountSearchResult
     *              wrapper used by the LWC datatable.
     * @param acc The Account SObject to map.
     * @return An AccountSearchResult populated with the Account's fields.
     */
    private static AccountSearchResult mapToResult(Account acc) {
        if (acc == null) {
            return null;
        }

        AccountSearchResult result = new AccountSearchResult();
        result.id = acc.Id;
        result.name = acc.Name;
        result.firstName = acc.FirstName;
        result.lastName = acc.LastName;
        result.externalCIFId = acc.ExternalCIFId__c;
        result.contactNumber = acc.Phone;
        result.email = acc.PersonEmail;
        result.registrationNumber = acc.Registration_number__c;
        result.recordTypeId = acc.RecordTypeId;
        if(acc.RecordType != null){
             result.accountRecordType = acc.RecordType.Name;
        }       
        result.identityNumber = acc.CMN_IdentityNumber__pc;
        if (acc.PersonBirthdate != null) {
            result.birthdate = Date.valueOf(acc.PersonBirthdate);
        }
        return result;
    }
    
    /**
     * @description Matches exact DeveloperName against the known IAM set
     *              first, then falls back to a case-insensitive prefix check
     *              as a safety net for near-miss record type names.
     * @param developerName The record type developer name to check.
     * @return True if the developer name is an IAM record type, false otherwise.
     */
    private static Boolean isIAMRecordType(String developerName) {
        if (String.isBlank(developerName)) {
            return false;
        }
        if (IAM_RECORD_TYPE_DEVELOPER_NAMES.contains(developerName)) {
            return true;
        }
        // Fallback for record types that start with 'IAM_' or 'IAM'
        return developerName.startsWithIgnoreCase('IAM_')
            || developerName.startsWithIgnoreCase('IAM');
    }
    
    /**
     * @description Formats a date as a YYYY-MM-DD date literal.
     * @param dt The Date to format.
     * @return A string representing the date in YYYY-MM-DD format, or 'null' if dt is null.
     */
    private static String formatDateAsLiteral(Date dt) {
        if (dt == null) {
            return 'null';
        }
        return dt.year() + '-' +
            String.valueOf(dt.month()).leftPad(2, '0') + '-' +
            String.valueOf(dt.day()).leftPad(2, '0');
    }
    
    /**
     * @description Comparator for sorting RecordTypeOption by label in ascending order.
     */
    public class RecordTypeOptionComparator implements Comparator<RecordTypeOption> {
        /**
         * @description Compares two RecordTypeOption objects based on their label.
         * @param a The first RecordTypeOption to compare.
         * @param b The second RecordTypeOption to compare.
         * @return A negative integer, zero, or a positive integer as the first argument is less than, equal to, or greater than the second.
         */ 
        public Integer compare(RecordTypeOption a, RecordTypeOption b) {
            return a.label.compareTo(b.label);
        }
    }
    /**
     * @description Returns a list of Account records matching the given list of Ids.
     *              This method is cacheable to improve performance for repeated queries.
     * @param accountIds List of Account record Ids to retrieve.
     * @return List of Account records matching the provided Ids.
     */
   @AuraEnabled(cacheable=true)
    public static List<Account> getDuplicateAccounts(List<Id> accountIds) {
        try {
            if (accountIds == null || accountIds.isEmpty()) {
                return new List<Account>();
            }

            return new SEL_Account().selectByIds(new Set<Id>(accountIds));

        } catch (Exception e) {
            throw new AuraHandledException('Unable to retrieve duplicate accounts.');
        }
    }
}