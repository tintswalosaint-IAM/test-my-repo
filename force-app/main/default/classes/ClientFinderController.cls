public with sharing class ClientFinderController {

    // TODO: Replace with the exact DeveloperName values confirmed via
    // RecordTypeInfo debug above. Using a "contains IAM" fallback below
    // so this doesn't silently fail again if names are close but not exact.
    private static final Set<String> IAM_RECORD_TYPE_DEVELOPER_NAMES = new Set<String>{
        'IAM_Person',
        'IAM_Business'
        // e.g. add 'IAM_Liberty_Person', 'IAM_Liberty_Business' once confirmed
    };

    private static final Integer CANDIDATE_QUERY_LIMIT = 200;
    private static final Integer RESULT_LIMIT = 50;

    public class RecordTypeOption {
        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String developerName { get; set; }

        @AuraEnabled
        public Boolean isIAM { get; set; }
    }

    public class AccountSearchResult {
        @AuraEnabled
        public Id id { get; set; }

        @AuraEnabled
        public String name { get; set; }

        @AuraEnabled
        public String firstName { get; set; }

        @AuraEnabled
        public String lastName { get; set; }

        @AuraEnabled
        public String externalCIFId { get; set; }

        @AuraEnabled
        public String contactNumber { get; set; }

        @AuraEnabled
        public String email { get; set; }

        @AuraEnabled
        public String registrationNumber { get; set; }

        @AuraEnabled
        public String AccountRecordType { get; set; }

        @AuraEnabled
        public Id recordTypeId { get; set; }

    }


    /**
     * Returns all record types available to the logged-in user.
     * LWC decides whether to show Client Finder (search) or Create Form.
     */
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeOption> getAvailableRecordTypes() {

        List<RecordTypeOption> options = new List<RecordTypeOption>();

        for (Schema.RecordTypeInfo rtInfo :
            Account.SObjectType.getDescribe().getRecordTypeInfos()) {

            if (!rtInfo.isAvailable() || rtInfo.isMaster()) {
                continue;
            }

            RecordTypeOption option = new RecordTypeOption();
            option.id = rtInfo.getRecordTypeId();
            option.label = rtInfo.getName();
            option.developerName = rtInfo.getDeveloperName();
            option.isIAM = isIAMRecordType(rtInfo.getDeveloperName());

            if (!option.isIAM) {
                continue;
            }

            options.add(option);
        }

        options.sort(new RecordTypeOptionComparator());

        return options;
    }

    /**
     * Matches exact DeveloperName first; falls back to a case-insensitive
     * "starts with IAM" check so near-miss naming doesn't silently break
     * the search/create routing. Tighten this back to exact-only once
     * DeveloperNames are confirmed and the set above is accurate.
     */
    private static Boolean isIAMRecordType(String developerName) {
        if (String.isBlank(developerName)) {
            return false;
        }

        if (IAM_RECORD_TYPE_DEVELOPER_NAMES.contains(developerName)) {
            return true;
        }

        return developerName.startsWithIgnoreCase('IAM_') ||
               developerName.startsWithIgnoreCase('IAM');
    }

    @AuraEnabled
    public static List<AccountSearchResult> searchAccounts(
        String accountName,
        String firstName,
        String lastName,
        String externalCIFId,
        String contactNumber,
        String email,
        String registrationNumber,
        String recordTypeDeveloperName
    ) {



        Boolean hasSearchCriteria =
            !String.isBlank(accountName) ||
            !String.isBlank(firstName) ||
            !String.isBlank(lastName) ||
            !String.isBlank(externalCIFId) ||
            !String.isBlank(contactNumber) ||
            !String.isBlank(email) ||
            !String.isBlank(registrationNumber);

        if (!hasSearchCriteria) {
            throw new AuraHandledException('Enter at least one search criterion.');
        }

        // Broad candidate query — casts a wide net via individual field LIKE
        // filters, since SOQL can't strip whitespace inside a LIKE comparison.
        // The space-insensitive combined name match happens in-memory below.
        String nameFilter = String.isBlank(accountName) ? null : '%' + accountName.trim() + '%';
        String firstNameFilter = String.isBlank(firstName) ? null : '%' + firstName.trim() + '%';
        String lastNameFilter = String.isBlank(lastName) ? null : '%' + lastName.trim() + '%';
        String externalCIFFilter =
            String.isBlank(externalCIFId)
            ? null
            : '%' + externalCIFId.trim() + '%';
        String contactNumberFilter =
            String.isBlank(contactNumber)
            ? null
            : '%' + contactNumber.trim() + '%';
        String emailFilter = String.isBlank(email) ? null : '%' + email.trim() + '%';
        String registrationNumberFilter =
            String.isBlank(registrationNumber)
            ? null
            : '%' + registrationNumber.trim() + '%';

        List<String> filters = new List<String>();

        if (nameFilter != null) {
            filters.add('Name LIKE :nameFilter');
        }
        if (firstNameFilter != null) {
            filters.add('FirstName LIKE :firstNameFilter');
        }
        if (lastNameFilter != null) {
            filters.add('LastName LIKE :lastNameFilter');
        }
        if (externalCIFFilter != null) {
            filters.add('ExternalCIFId__c LIKE :externalCIFFilter');
        }
        if (contactNumberFilter != null) {
            filters.add('Phone LIKE :contactNumberFilter');
        }
        if (emailFilter != null) {
            filters.add('PersonEmail LIKE :emailFilter');
        }
        if (registrationNumberFilter != null) {
            filters.add('Registration_number__c LIKE :registrationNumberFilter');
        }

        // Apply record type filter so results match the selected Record Type.
        // Search includes both standard and IAM record types for the same category.
        // - IAM Person search → Person Account + IAM Person Account
        // - IAM Business search → Business Account + IAM Business Account
        if (String.isBlank(recordTypeDeveloperName)) {
            throw new AuraHandledException('A record type must be selected for search.');
        }

        Boolean isPersonSearch = recordTypeDeveloperName.toLowerCase().contains('person');

        Set<Id> matchingRecordTypeIds = new Set<Id>();
        Map<String, Schema.RecordTypeInfo> rtInfosByDevName =
            Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();

        for (String devName : rtInfosByDevName.keySet()) {
            if (isPersonSearch && devName.toLowerCase().contains('person')) {
                matchingRecordTypeIds.add(rtInfosByDevName.get(devName).getRecordTypeId());
            } else if (!isPersonSearch && devName.toLowerCase().contains('business')) {
                matchingRecordTypeIds.add(rtInfosByDevName.get(devName).getRecordTypeId());
            }
        }

        if (matchingRecordTypeIds.isEmpty()) {
            throw new AuraHandledException('No matching record types found for search.');
        }

        String soql =
            'SELECT Id, Name, FirstName, LastName, ExternalCIFId__c, Phone, ' +
            'PersonEmail, Registration_number__c, RecordTypeId, RecordType.Name ' +
            'FROM Account WHERE RecordTypeId IN :matchingRecordTypeIds';




        if (!filters.isEmpty()) {
            soql += ' AND (' + String.join(filters, ' OR ') + ')';
        }

        soql += ' ORDER BY Name LIMIT ' + CANDIDATE_QUERY_LIMIT;

        List<Account> candidates = Database.query(soql);

        // Space-insensitive combined first/last name match.
        // e.g. "John Smith", "JohnSmith", or "John  Smith" all match
        // an Account with FirstName = 'John', LastName = 'Smith'.
        Boolean hasNameSearch = !String.isBlank(firstName) || !String.isBlank(lastName);
        String normalizedSearchName = normalizeForMatch(
            (String.isBlank(firstName) ? '' : firstName) +
            (String.isBlank(lastName) ? '' : lastName)
        );

        List<AccountSearchResult> results = new List<AccountSearchResult>();

        for (Account acc : candidates) {

            if (hasNameSearch) {
                String normalizedAccountName = normalizeForMatch(
                    (acc.FirstName == null ? '' : acc.FirstName) +
                    (acc.LastName == null ? '' : acc.LastName)
                );

                if (!normalizedAccountName.contains(normalizedSearchName)) {
                    continue;
                }
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
            result.AccountRecordType = acc.RecordType != null ? acc.RecordType.Name : null;


            results.add(result);

            if (results.size() >= RESULT_LIMIT) {
                break;
            }
        }

        return results;
    }

    /**
     * Strips whitespace and lower-cases for space/case-insensitive comparisons.
     */
    private static String normalizeForMatch(String value) {
        return String.isBlank(value) ? '' : value.deleteWhitespace().toLowerCase();
    }

    public class RecordTypeOptionComparator implements Comparator<RecordTypeOption> {
        public Integer compare(RecordTypeOption a, RecordTypeOption b) {
            return a.label.compareTo(b.label);
        }
    }
}