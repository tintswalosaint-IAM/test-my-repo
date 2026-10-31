/*
 * Class Name      : INS_CTRL_CustomerSearch
 * Description     : OmniStudio Remote Action class used to search
 *                   for existing customers on the experience site
 *                   for guest users who do not have direct access
 *                   to Account and related objects.
 * Test Class      : INS_CTRL_CustomerSearch_TEST
 * Created Date    : Mar 18, 2026
 * Author          : Irshad Alam
 * User Story      : SFP-55635
 * LastModified    : Resolved input data for coutry, it will get value from Omni
 **/
public without sharing class INS_CTRL_CustomerSearch implements Callable {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_SEARCH_CUSTOMER = 'seachCustomer';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_CustomerSearch');

    // =========================================================================
    // MAIN CALLABLE ENTRY METHOD
    // =========================================================================

    public Object call(String actionType, Map<String, Object> args) {

        Map<String, Object> inputMap  = (Map<String, Object>) args.get('input');
        Map<String, Object> outputMap = (Map<String, Object>) args.get('output');

        if (outputMap == null) {
            outputMap = new Map<String, Object>();
        }

        if (actionType != ACTION_SEARCH_CUSTOMER) {
            throw new AuraHandledException('Unsupported action: ' + actionType);
            
        }

        return searchCustomer(inputMap, outputMap);
    }

    // =========================================================================
    // SEARCH CUSTOMER
    // =========================================================================

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> searchCustomer(
        Map<String, Object> inputMap,
        Map<String, Object> outputMap
    ) {
        try {
            if (outputMap == null) {
                outputMap = new Map<String, Object>();
            }

            SearchRequest request = new SearchRequest(inputMap);            
            String validationError = request.validate();
            if (validationError != null) {
                return buildErrorResponse(outputMap, validationError);
            }

            return executeSearch(request, outputMap);

        } catch (Exception ex) {
            LOGGER.error('INS_CTRL_CustomerSearch.searchCustomer', ex); 
            throw new AuraHandledException('Error searching for customer: ' + ex.getMessage());
            
        }
    }

    // =========================================================================
    // SEARCH EXECUTION
    // =========================================================================

    private static Map<String, Object> executeSearch(
        SearchRequest request,
        Map<String, Object> outputMap
    ) {
        List<Account> accountsToReturn;

        try {
            accountsToReturn = new INS_Get_Account().selectAccountByName(
                request.firstName,
                request.lastName,
                request.dateOfBirth,
                request.identityNumber,
                request.customerType,
                request.country
            );
        } catch (Exception ex) {
            
            return buildErrorResponse(outputMap, 'Error searching for customer: ' + ex.getMessage());
        }
       
        outputMap.put('existingAccount', buildExistingAccountNode(accountsToReturn));
        return outputMap;
    }

    private static Map<String, Object> buildExistingAccountNode(List<Account> accounts) {
        Map<String, Object> existingAccount = new Map<String, Object>();

        if (accounts == null || accounts.isEmpty()) {
            existingAccount.put('CustomerFound', false);
            return existingAccount;
        }

        existingAccount.put('CustomerFound',       true);
        existingAccount.put('existingAccountId',           accounts[0].Id);            
        return existingAccount;
    }

    // =========================================================================
    // PRIVATE HELPERS
    // =========================================================================
    private static Map<String, Object> buildErrorResponse(
        Map<String, Object> outputMap,
        String errorMessage
    ) {
        outputMap.put('success',      false);
        outputMap.put('errorMessage', errorMessage);
        return outputMap;
    }

    // =========================================================================
    // REQUEST WRAPPER
    // =========================================================================

    private class SearchRequest {

        public String firstName;
        public String lastName;
        public String dobStr;
        public String identityNumber;
        public String customerType;
        public Date   dateOfBirth;
        public String country;

        private final Boolean hasInput;
        private final Boolean hasPersonalInformation;

        public SearchRequest(Map<String, Object> inputMap) {
            hasInput = inputMap != null;
            System.debug('inputMap=='+ JSON.serialize(inputMap));
            Map<String, Object> personalInformation = hasInput
                ? (Map<String, Object>) inputMap.get('PersonalInformation')
                : null;

            hasPersonalInformation = personalInformation != null;
            if (hasPersonalInformation) {
                firstName      = (String) personalInformation.get('FirstName');
                lastName       = (String) personalInformation.get('LastName');
                dobStr         = (String) personalInformation.get('OS_DateOfBirth');
                identityNumber = (String) personalInformation.get('IdNumber');
                customerType   = (String) inputMap.get('CustomerType');
                country        = (String) inputMap.get('Country');
            }
        }

        public String validate() {
            if (!hasInput) {
                return 'Input is required.';
            }
            if (!hasPersonalInformation) {
                return 'PersonalInformation is required.';
            }

            String blankFieldError = firstBlankFieldError();
            if (blankFieldError != null) {
                return blankFieldError;
            }

            return parseDateOfBirth();
        }

        private String firstBlankFieldError() {
            if (String.isBlank(firstName)) {
                return 'First Name is required.';
            }
            if (String.isBlank(lastName)) {
                return 'Last Name is required.';
            }
            if (String.isBlank(dobStr)) {
                return 'Date of Birth is required.';
            }
            return null;
        }

        private String parseDateOfBirth() {
            try {
                dateOfBirth = Date.valueOf(dobStr);
                return null;
            } catch (Exception ex) {
                return 'Invalid Date of Birth format. Expected YYYY-MM-DD.';
            }
        }
    }
}