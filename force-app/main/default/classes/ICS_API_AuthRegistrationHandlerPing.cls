/*******************************************************************
* @Name of the Class : ICS_API_AuthRegistrationHandlerPing.cls
* @description       : Authentication handler implementation for Ping
* Story              : SFP-31800
* @author            : Ikyatha Naidu
* @date              : 23-11-2023
*************************************************************** 
* @last modified on  : 29-06-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version 
*******************************************************************/

Public with sharing abstract class ICS_API_AuthRegistrationHandlerPing extends ICS_CTRL_AuthRegistrationHandler {
	
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
        }else{
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
    *               might be <code>null</code> and is not used by the default implementation. If planning to use this
    *               then implementers should check for <code>null</code> and handle accordingly.
    * @param userDataWrapper User data extracted from the SSO provider
    * 
    * @return Contact
    */
    public virtual override Contact findContactForUser(
        Id userId,
        UserDataWrapper userDataWrapper
    ) {
        // Convert email to lowercase if it's not null
        String email = userDataWrapper.email;
        if (email != null) {
            email = email.toLowerCase();
        }
        
      
        
        // Query contacts matching the email or Ping ID
        if (Schema.sObjectType.Contact.isAccessible()) {
            List<Contact> contacts = new List<Contact>();
            contacts = [
                SELECT Id, FirstName, LastName, Ping_Id__c,Email,Account.RecordType.DeveloperName
                FROM Contact
                WHERE Email = :email and Account.ExternalCIFCountry__c ='OS' and Account.recordtype.name='ICS Applicant'  LIMIT 1
            ];
            if(contacts.size()==0){
                 contacts = [
                SELECT Id, FirstName, LastName, Ping_Id__c,Email,Account.RecordType.DeveloperName
                FROM Contact
                WHERE Ping_Id__c = :userDataWrapper.id and Account.ExternalCIFCountry__c ='OS' and Account.recordtype.name='ICS Applicant'  LIMIT 1
            ];
                
            }
        
        // Return the first matching contact if found
        
              if (contacts.isEmpty()) {
                  return null;
              } else {
                  return contacts.get(0);
              }
        }
        
        // Return null if no matching contact is found
        return null;
    }
}