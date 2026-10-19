/**
* @class Name        : INS_API_AuthRegistrationHandlerPing
* @description       : Authentication handler implementation for Direct sales agent portal Ping
* story              : SFP-53279
* @author            : Jaco de Lange
* @date              : 10-09-2025
**/
Public with sharing abstract class INS_API_AuthRegistrationHandlerPing extends INS_CTRL_AuthRegistrationHandler {
    
    // Private constant for the cell phone number key
    Private static final String keyCellPhone = 'cellnumber';
    
    // Private constant for the date of birth key
    Private static final String keyDateOfBirth = 'dateofbirth'; 
    
    // Private constant for the first name key
    Private static final String keyFirstName = 'first_name';
    
    // Private constant for the last name key
    Private static final String keyLastName = 'last_name';

    // Private constant for the ID key
    Private static final String keyId = 'id';

    Private static final String salesAgentName = 'Sales Agent Contact';
    Private static final sbgplatform.rflib_Logger LOG = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_API_AuthRegistrationHandlerPing');
    
    /**
    * @description Handles Ping specific data extraction. The response data
    *              from Ping is mostly stored as attributes in the attribute
    *              map as opposed to being set directly on the user data object.
    *
    * @param userData User data parameter that comes from the SSO provider
    *
    * @return A wrapper object that has extracted the required fields from
    * the user data object
    */
    public virtual override UserDataWrapper extractUserData(
        Auth.UserData userData
    ) {
        // Call the superclass method to get the initial user data wrapper
        UserDataWrapper userDataWrapper = super.extractUserData(userData);
        
        // Extract Ping-specific attributes from the attribute map
        Map<String, String> attributes = userData.attributeMap;
        userDataWrapper.id = attributes.get(keyId);
        
        if(attributes.get(keyFirstName) == attributes.get(keyLastName)){
            userDataWrapper.lastName = attributes.get(keyLastName);
        } else {
            userDataWrapper.firstName = attributes.get(keyFirstName);
            userDataWrapper.lastName = attributes.get(keyLastName);
        }
        
        userDataWrapper.cellphone = attributes.get(keyCellPhone);
        userDataWrapper.dateOfBirth = attributes.get(keyDateOfBirth);
        
        return userDataWrapper;
    }

    /**
    * @description Works much like the default implementation except it will also
    *              map to the custom Ping ID field on the Contact object. In other
    *              words, it will match email or Ping ID.
    *
    * @param userId User ID if existing user found on creation or update, this parameter
    *               might be <code>null</code> and is not used by the default implementation. 
    * @param userDataWrapper User data extracted from the SSO provider
    * 
    * @return Contact
    */
    public virtual override Contact findContactForUser(Id userId, UserDataWrapper userDataWrapper) {
        
        if (!Schema.sObjectType.Contact.isAccessible()) {
            LOG.error('INS_API_AuthRegistrationHandlerPing | findContactForUser | Access to Contact Object Denied');
            return null;
        }

		String email = userDataWrapper.email;
        if (email != null) {
            email = email.toLowerCase();
        }

        List<Contact> contacts = new SEL_Contact().selectByEmailandRecordTypeName(email, salesAgentName);
        
        if (contacts.isEmpty()) {
            contacts = new SEL_Contact().selectPersonContactByEmail(email);
        }
        
        if (contacts.isEmpty()) {
            LOG.error('INS_API_AuthRegistrationHandlerPing | findContactForUser | No Contact found for Email | ' + email);
            return null;
        }
        
        return contacts.get(0);
    }
}