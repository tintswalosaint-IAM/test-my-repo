/*
 * Class Name      : INS_CTRL_SearchEmployee
 * Description     : OmniStudio Remote Action class used to search
 *                   for an assisting employee (User) or referrer
 *                   Contact by email on the experience site.
 *                   Guest user profile requires read access on
 *                   Account/Contact and create access on Contact.
 * Test Class      : INS_CTRL_SearchEmployee_TEST
 * Created Date    : Mar 18, 2026
 * Author          : Irshad Alam
 * User Story      : SFP-55635
 **/
public without sharing class INS_CTRL_SearchEmployee implements Callable {

    private static final String ACCOUNT_NAME = 'External Referrer IAM AR Generic Account';
    private static final String CLIENT_CONTACT_RT_DEV_NAME = 'SVC_Client';

    public Object call(String actionType, Map<String, Object> args) {

        if (actionType != 'SearchEmployee') {
            throw new AuraHandledException('Unsupported action: ' + actionType);
        }

        Map<String, Object> input  = (Map<String, Object>) args.get('input');
        Map<String, Object> output = (Map<String, Object>) args.get('output');
        return searchEmployee(input, output);
    }

    /**
     * @description : Searches for an internal User by email; falls back to a
     *                referrer Contact under the generic referrer Account,
     *                creating the Contact when none exists.
     * @return      : output map containing assistedUserId or assistedContactId
     * @author Irshad | 06-03-2026
     */
    @AuraEnabled(cacheable=false)
    public static Object searchEmployee(Map<String, Object> input, Map<String, Object> output) {
        try {
            String email = (String) input.get('Email');

            List<User> users = new SEL_User().selectByEmail(email);
            if (users != null && !users.isEmpty()) {
                output.put('assistedUserId', users[0].Id);
                return output;
            }

            checkObjectAccess();

            Id accountId = getReferrerAccountId();
            Id contactId = searchContactByEmail(email, accountId);

            if (contactId == null) {
                Contact contact = buildContact(input, accountId);
                insert contact;
                contactId = contact.Id;
            }

            output.put('assistedContactId', contactId);
            return output;

        } catch (Exception ex) {
            throw new AuraHandledException('Employee search failed: ' + ex.getMessage());
        }
    }

    /**
     * @description : Verifies the running user (guest profile) has the object
     *                permissions this action relies on.
     */
    private static void checkObjectAccess() {
        if (!Schema.SObjectType.Account.isAccessible()
            || !Schema.SObjectType.Contact.isAccessible()
            || !Schema.SObjectType.Contact.isCreateable()) {
            throw new AuraHandledException(
                'Insufficient permissions to search or create referrer contacts.');
        }
    }

    /**
     * @description : Retrieves the generic referrer Account id.
     */
    private static Id getReferrerAccountId() {
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE Name = :ACCOUNT_NAME
            LIMIT 1
        ];
        if (accounts.isEmpty()) {
            throw new AuraHandledException('Referrer account not found: ' + ACCOUNT_NAME);
        }
        return accounts[0].Id;
    }

    /**
     * @description : Searches for a Contact with matching email under the given Account.
     * @return      : Contact Id, or null when no match exists
     * @author Irshad | 06-03-2026
     */
    public static Id searchContactByEmail(String email, Id accountId) {
        List<Contact> contacts = [
            SELECT Id
            FROM Contact
            WHERE Email = :email
            AND AccountId = :accountId
            LIMIT 1
        ];
        return contacts.isEmpty() ? null : contacts[0].Id;
    }

    /**
     * @description : Builds a referrer Contact under the generic referrer Account.
     * @author Irshad | 06-03-2026
     */
    public static Contact buildContact(Map<String, Object> input, Id accountId) {
        Id contactRecordType = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get(CLIENT_CONTACT_RT_DEV_NAME)
            .getRecordTypeId();

        String firstName   = (String) input.get('FirstName');
        String mobilePhone = (String) input.get('MobilePhone');

        Contact contact      = new Contact();
        contact.Email        = (String) input.get('Email');
        contact.FirstName    = String.isBlank(firstName) ? '' : firstName;
        contact.LastName     = (String) input.get('LastName');
        contact.AccountId    = accountId;
        contact.MobilePhone  = String.isBlank(mobilePhone) ? '' : mobilePhone;
        contact.RecordTypeId = contactRecordType;
        return contact;
    }
}