/*
 * Class Name      : IAM_CTRL_ClientFinder
 * Description     : SFP-55927 : Controller for the IAM Client Finder LWC — retrieves
 *                   available IAM Account record types and searches for
 *                   existing Person/Business Accounts by various criteria.
 * Test Class      : IAM_CTRL_ClientFinder_TEST
 * Created Date    : Jul 21, 2026
 * Author          : Preetham
 */
public inherited sharing class IAM_CTRL_ClientFinder {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final Set<String> IAM_RECORD_TYPE_DEVELOPER_NAMES = new Set<String>{
        'IAM_Person',
        'IAM_Business'
    };
    private static final Integer CANDIDATE_QUERY_LIMIT = 200;
    private static final Integer RESULT_LIMIT = 50;
    private static final String ERROR_CRITERIA_REQUIRED = 'Enter at least one search criterion.';
    private static final String ERROR_RECORD_TYPE_REQUIRED = 'A record type must be selected for search.';
    private static final String ERROR_NO_MATCHING_RECORD_TYPES = 'No matching record types found for search.';

    // =========================================================================
    // INNER WRAPPER CLASSES
    // =========================================================================

    /**
     * @description Wraps search input parameters to keep the @AuraEnabled
     *              method signature compliant with the max-3-params guideline.
     */
    public class SearchRequest {
        @AuraEnabled public String accountName           { get; set; }
        @AuraEnabled public String firstName             { get; set; }
        @AuraEnabled public String lastName              { get; set; }
        @AuraEnabled public String externalCIFId         { get; set; }
        @AuraEnabled public String contactNumber         { get; set; }
        @AuraEnabled public String email                 { get; set; }
        @AuraEnabled public String registrationNumber    { get; set; }
        @AuraEnabled public String recordTypeDeveloperName { get; set; }
    }

    /**
     * @description Represents an Account record type option returned to the LWC.
     */
    public class RecordTypeOption {
        @AuraEnabled public Id id                   { get; set; }
        @AuraEnabled public String label            { get; set; }
        @AuraEnabled public String developerName    { get; set; }
        @AuraEnabled public Boolean isIAM           { get; set; }
    }

    /**
     * @description Represents a single Account search result returned to the LWC.
     */
    public class AccountSearchResult {
        @AuraEnabled public Id id                   { get; set; }
        @AuraEnabled public String name             { get; set; }
        @AuraEnabled public String firstName        { get; set; }
        @AuraEnabled public String lastName         { get; set; }
        @AuraEnabled public String externalCIFId    { get; set; }
        @AuraEnabled public String contactNumber    { get; set; }
        @AuraEnabled public String email            { get; set; }
        @AuraEnabled public String registrationNumber { get; set; }
        @AuraEnabled public String accountRecordType { get; set; }
        @AuraEnabled public Id recordTypeId         { get; set; }
    }

    // =========================================================================
    // PUBLIC @AURENABLED METHODS
    // =========================================================================

    /**
     * @description Returns all IAM Account record types available to the
     *              logged-in user. The LWC uses this list to decide whether
     *              to show the search step or jump directly to record creation.
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

                if (!isIAMRecordType(rtInfo.getDeveloperName())) {
                    continue;
                }

                RecordTypeOption option = new RecordTypeOption();
                option.id = rtInfo.getRecordTypeId();
                option.label = rtInfo.getName();
                option.developerName = rtInfo.getDeveloperName();
                option.isIAM = true;
                options.add(option);
            }
        } catch (Exception ex) {
            // Return empty list when the user lacks Account object access.
            // The LWC handles an empty list gracefully by skipping the
            // search step and falling through to the default create flow.
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
        validateSearchRequest(request);

        // Build LIKE filter clauses for the candidate query
        List<String> filterClauses = buildFilterClauses(request);

        // Determine which record type IDs to search
        Set<Id> matchingRecordTypeIds = resolveRecordTypeIds(request.recordTypeDeveloperName);

        // Broad candidate query via the selector layer
        SEL_Account selector = new SEL_Account();
        List<Account> candidates = selector.selectBySearchCriteria(
            filterClauses, matchingRecordTypeIds, CANDIDATE_QUERY_LIMIT
        );

        // In-memory name normalization for space/case-insensitive matching
        return filterAndMapResults(candidates, request);
    }

    // =========================================================================
    // PRIVATE HELPERS
    // =========================================================================

    /**
     * @description Validates that the search request has at least one
     *              criterion and a record type selected.
     */
    private static void validateSearchRequest(SearchRequest request) {
        if (request == null) {
            throw new AuraHandledException(ERROR_CRITERIA_REQUIRED);
        }

        if (String.isBlank(request.recordTypeDeveloperName)) {
            throw new AuraHandledException(ERROR_RECORD_TYPE_REQUIRED);
        }

        Boolean hasSearchCriteria =
            !String.isBlank(request.accountName) ||
            !String.isBlank(request.firstName) ||
            !String.isBlank(request.lastName) ||
            !String.isBlank(request.externalCIFId) ||
            !String.isBlank(request.contactNumber) ||
            !String.isBlank(request.email) ||
            !String.isBlank(request.registrationNumber);

        if (!hasSearchCriteria) {
            throw new AuraHandledException(ERROR_CRITERIA_REQUIRED);
        }
    }

    /**
     * @description Builds a list of LIKE filter clauses from the search
     *              request input. Each non-blank criterion adds one clause.
     */
    private static List<String> buildFilterClauses(SearchRequest request) {
        List<String> clauses = new List<String>();

        if (!String.isBlank(request.accountName)) {
            clauses.add('Name LIKE \'%' + String.escapeSingleQuotes(request.accountName.trim()) + '%\'');
        }
        if (!String.isBlank(request.firstName)) {
            clauses.add('FirstName LIKE \'%' + String.escapeSingleQuotes(request.firstName.trim()) + '%\'');
        }
        if (!String.isBlank(request.lastName)) {
            clauses.add('LastName LIKE \'%' + String.escapeSingleQuotes(request.lastName.trim()) + '%\'');
        }
        if (!String.isBlank(request.externalCIFId)) {
            clauses.add('ExternalCIFId__c LIKE \'%' + String.escapeSingleQuotes(request.externalCIFId.trim()) + '%\'');
        }
        if (!String.isBlank(request.contactNumber)) {
            clauses.add('Phone LIKE \'%' + String.escapeSingleQuotes(request.contactNumber.trim()) + '%\'');
        }
        if (!String.isBlank(request.email)) {
            clauses.add('PersonEmail LIKE \'%' + String.escapeSingleQuotes(request.email.trim()) + '%\'');
        }
        if (!String.isBlank(request.registrationNumber)) {
            clauses.add('Registration_number__c LIKE \'%' + String.escapeSingleQuotes(request.registrationNumber.trim()) + '%\'');
        }

        return clauses;
    }

    /**
     * @description Resolves which Account record type IDs to include in the
     *              search. Broadens a Person search to include all Person-type
     *              record types (including IAM and standard), and similarly
     *              for Business searches.
     */
    private static Set<Id> resolveRecordTypeIds(String recordTypeDeveloperName) {
        Boolean isPersonSearch = recordTypeDeveloperName.toLowerCase().contains('person');

        Set<Id> matchingIds = new Set<Id>();
        for (Schema.RecordTypeInfo rtInfo :
            Account.SObjectType.getDescribe().getRecordTypeInfos()) {

            if (!rtInfo.isAvailable() || rtInfo.isMaster()) {
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
     * @description Applies space-insensitive first/last name matching in
     *              memory and maps the surviving candidates to the result
     *              wrapper, capping at RESULT_LIMIT.
     */
    private static List<AccountSearchResult> filterAndMapResults(
        List<Account> candidates, SearchRequest request
    ) {
        Boolean hasNameSearch = !String.isBlank(request.firstName)
            || !String.isBlank(request.lastName);

        String normalizedSearchName = '';
        if (hasNameSearch) {
            normalizedSearchName = normalizeForMatch(
                (String.isBlank(request.firstName) ? '' : request.firstName) +
                (String.isBlank(request.lastName) ? '' : request.lastName)
            );
        }

        List<AccountSearchResult> results = new List<AccountSearchResult>();

        for (Account acc : candidates) {
            // Space-insensitive combined first/last name filter
            if (hasNameSearch) {
                String normalizedAccountName = normalizeForMatch(
                    (acc.FirstName == null ? '' : acc.FirstName) +
                    (acc.LastName == null ? '' : acc.LastName)
                );
                if (!normalizedAccountName.contains(normalizedSearchName)) {
                    continue;
                }
            }

            results.add(mapToResult(acc));

            if (results.size() >= RESULT_LIMIT) {
                break;
            }
        }

        return results;
    }

    /**
     * @description Maps a single Account SObject to the AccountSearchResult
     *              wrapper used by the LWC datatable.
     */
    private static AccountSearchResult mapToResult(Account acc) {
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
        result.accountRecordType = acc.RecordType != null
            ? acc.RecordType.Name
            : null;
        return result;
    }

    /**
     * @description Matches exact DeveloperName against the known IAM set
     *              first, then falls back to a case-insensitive prefix check
     *              as a safety net for near-miss record type names.
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
     * @description Strips all whitespace and lowercases the value for
     *              space- and case-insensitive string comparison.
     */
    private static String normalizeForMatch(String value) {
        return String.isBlank(value) ? '' : value.deleteWhitespace().toLowerCase();
    }

    // =========================================================================
    // COMPARATOR
    // =========================================================================

    /**
     * @description Sorts RecordTypeOption instances alphabetically by label.
     */
    public class RecordTypeOptionComparator implements Comparator<RecordTypeOption> {
        public Integer compare(RecordTypeOption a, RecordTypeOption b) {
            return a.label.compareTo(b.label);
        }
    }
}