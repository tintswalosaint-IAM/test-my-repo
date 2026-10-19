/*------------------------------------------------------------
 * Class Name      : INS_CustomerSearchRemoteAction
 * Description     : OmniStudio Remote Action class used to search
 *                   for existing customers on the experience site
 *                   for guest users who do not have direct access
 *                   to Account and related objects.
 *                   Used by OmniScript Remote Action, Integration
 *                   Procedures, and OmniStudio integrations.
 * Test Class      : INS_CustomerSearchRemoteAction_Test
 * user Story      :Initial creation (SFP-55635)
 */
global without sharing class INS_CustomerSearchRemoteAction implements Callable {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_SEARCH_CUSTOMER = 'seachCustomer';

    // =========================================================================
    // MAIN CALLABLE ENTRY METHOD
    // =========================================================================

    /*------------------------------------------------------------
     *  Purpose:    Main entry point for OmniStudio Remote Action.
     *              Delegates to the appropriate handler method
     *              based on the actionType argument.
     *  Parameters: actionType - the name of the action to invoke
     *              args       - map containing 'input' and 'output' sub-maps
     *  Returns:    Object - the populated outputMap or an error response
     *  Throws:     AuraHandledException - for unsupported action types
     *------------------------------------------------------------*/
    global Object call(String actionType, Map<String, Object> args) {

        System.debug(LoggingLevel.DEBUG,
            'INS_CustomerSearchRemoteAction.call(): actionType=' + actionType
            + ' | args=' + args
        );

        Map<String, Object> inputMap  = (Map<String, Object>) args.get('input');
        Map<String, Object> outputMap = (Map<String, Object>) args.get('output');

        // Guard: ensure outputMap is never null so helpers can always write to it
        if (outputMap == null) {
            outputMap = new Map<String, Object>();
        }

        try {

            if (actionType == ACTION_SEARCH_CUSTOMER) {
                Object result = searchCustomer(inputMap, outputMap);
                System.debug(LoggingLevel.DEBUG,
                    'INS_CustomerSearchRemoteAction.call(): result=' + result
                );
                return result;
            }

            throw new AuraHandledException('Unsupported action: ' + actionType);

        } catch (AuraHandledException ex) {
            // Re-throw AuraHandledExceptions — these are intentional and already
            // carry a user-facing message; swallowing them hides logic errors.
            throw ex;

        } catch (Exception ex) {
            // Unexpected runtime errors (NullPointerException, TypeException, etc.)
            // are logged and returned as a structured error so OmniScript can branch.
            System.debug(LoggingLevel.ERROR,
                'INS_CustomerSearchRemoteAction.call() - Unexpected error: '
                + ex.getMessage()
                + ' | Stack: ' + ex.getStackTraceString()
            );
            return buildErrorResponse(outputMap, ex.getMessage());
        }
    }

    // =========================================================================
    // SEARCH CUSTOMER
    // =========================================================================

    /*------------------------------------------------------------
     *  Purpose:    Searches for an existing Account record matching
     *              the supplied personal information and country of
     *              the running user.  Returns CustomerFound=true and
     *              the Account Id when a match is found, or
     *              CustomerFound=false when no record is returned.
     *  Parameters: inputMap  - must contain 'PersonalInformation' sub-map
     *                          with FirstName, LastName, OS_DateOfBirth,
     *                          IdNumber keys, and 'CustomerType' key
     *              outputMap - populated with 'existingAccount' containing
     *                          CustomerFound, ContextId, accountRecordTypeId
     *  Returns:    Map<String, Object> - the populated outputMap
     *------------------------------------------------------------*/
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> searchCustomer(
        Map<String, Object> inputMap,
        Map<String, Object> outputMap
    ) {

        

        // ---------------------------------------------------------------------
        // INPUT VALIDATIONS
        // ---------------------------------------------------------------------

        if (inputMap == null) {
            return buildErrorResponse(outputMap, 'Input is required.');
        }

        Map<String, Object> personalInformation =
            (Map<String, Object>) inputMap.get('PersonalInformation');

        if (personalInformation == null) {
            return buildErrorResponse(outputMap, 'PersonalInformation is required.');
        }

        // ---------------------------------------------------------------------
        // READ INPUT VALUES
        // ---------------------------------------------------------------------

        String firstName      = (String) personalInformation.get('FirstName');
        String lastName       = (String) personalInformation.get('LastName');
        String dobStr         = (String) personalInformation.get('OS_DateOfBirth');
        String identityNumber = (String) personalInformation.get('IdNumber');
        String customerType   = (String) inputMap.get('CustomerType');

        if (customerType == null) {
            customerType = '';
        }

        // ---------------------------------------------------------------------
        // FIELD VALIDATIONS
        // ---------------------------------------------------------------------

        if (String.isBlank(firstName)) {
            return buildErrorResponse(outputMap, 'First Name is required.');
        }

        if (String.isBlank(lastName)) {
            return buildErrorResponse(outputMap, 'Last Name is required.');
        }

        if (String.isBlank(dobStr)) {
            return buildErrorResponse(outputMap, 'Date of Birth is required.');
        }

        // ---------------------------------------------------------------------
        // RESOLVE RUNNING USER COUNTRY
        // ---------------------------------------------------------------------

        String country = resolveUserCountry();

        // ---------------------------------------------------------------------
        // PARSE DATE OF BIRTH
        // ---------------------------------------------------------------------

        Date dateOfBirth;

        try {
            dateOfBirth = Date.valueOf(dobStr);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR,
                'INS_CustomerSearchRemoteAction.searchCustomer() - Date parse error: '
                + ex.getMessage()
            );
            return buildErrorResponse(outputMap, 'Invalid Date of Birth format. Expected YYYY-MM-DD.');
        }

        // ---------------------------------------------------------------------
        // SEARCH ACCOUNT
        // ---------------------------------------------------------------------

        List<Account> accountsToReturn = new List<Account>();

        try {
            accountsToReturn = new INS_Get_Account().selectAccountByName(
                firstName,
                lastName,
                dateOfBirth,
                identityNumber,
                customerType,
                country
            );
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR,
                'INS_CustomerSearchRemoteAction.searchCustomer() - Account search error: '
                + ex.getMessage()
                + ' | Stack: ' + ex.getStackTraceString()
            );
            return buildErrorResponse(outputMap, 'Error searching for customer: ' + ex.getMessage());
        }

        // ---------------------------------------------------------------------
        // PREPARE RESPONSE
        // ---------------------------------------------------------------------

        Map<String, Object> existingAccount = new Map<String, Object>();

        if (accountsToReturn.size() > 0) {

            existingAccount.put('CustomerFound',        true);
            existingAccount.put('ContextId',            accountsToReturn[0].Id);
            existingAccount.put('accountRecordTypeId',  accountsToReturn[0].RecordTypeId);

        } else {

            existingAccount.put('CustomerFound', false);
        }

        // ---------------------------------------------------------------------
        // SUCCESS RESPONSE
        // ---------------------------------------------------------------------

        outputMap.put('existingAccount', existingAccount);

        System.debug(LoggingLevel.DEBUG,
            'INS_CustomerSearchRemoteAction.searchCustomer(): outputMap=' + outputMap
        );

        return outputMap;
    }

    // =========================================================================
    // PRIVATE HELPERS
    // =========================================================================

    /*------------------------------------------------------------
     *  Purpose:    Retrieves the User_Country__c field value for
     *              the currently running user via SEL_User.
     *  Returns:    String - country value; empty string when not set
     *------------------------------------------------------------*/
    private static String resolveUserCountry() {

        Set<Id> userIds = new Set<Id>{ UserInfo.getUserId() };

        List<User> users = new SEL_User().getUsersByIds(userIds);

        if (users.isEmpty()) {
            System.debug(LoggingLevel.WARN,
                'INS_CustomerSearchRemoteAction.resolveUserCountry() - '
                + 'No user record found for Id: ' + UserInfo.getUserId()
            );
            return '';
        }

        String country = users[0].User_Country__c;

        System.debug(LoggingLevel.DEBUG,
            'INS_CustomerSearchRemoteAction.resolveUserCountry(): country=' + country
        );

        return country != null ? country : '';
    }

    /*------------------------------------------------------------
     *  Purpose:    Builds a standardised error response for
     *              OmniScript consumption.
     *  Parameters: outputMap    - the map to write error fields into
     *              errorMessage - human-readable description of the failure
     *  Returns:    Map<String, Object> - the populated outputMap
     *                                   with success=false
     *------------------------------------------------------------*/
    private static Map<String, Object> buildErrorResponse(
        Map<String, Object> outputMap,
        String errorMessage
    ) {
        System.debug(LoggingLevel.DEBUG,
            'INS_CustomerSearchRemoteAction.buildErrorResponse(): errorMessage='
            + errorMessage
        );

        outputMap.put('success',      false);
        outputMap.put('errorMessage', errorMessage);

        System.debug(LoggingLevel.DEBUG,
            'INS_CustomerSearchRemoteAction.buildErrorResponse(): outputMap='
            + outputMap
        );

        return outputMap;
    }
}