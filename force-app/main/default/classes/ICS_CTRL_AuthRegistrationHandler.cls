/**
 * @Name of the Class: ICS_CTRL_AuthRegistrationHandler
 * @description Controller for SBO-UK PING Feature
 * @author Ikyatha Naidu, Swapnil Walse
 * @date 04/11/2023
 * @last modified on: 23/03/2024
 * @last modified by: Ikyatha Naidu
 * @Modification Description: SFP-31800 class used to create a user in Salesforce and update PINGId in Salesforce
 * 
 * @Last Modified By  : Ridhima Saxena   
 * @Last Modified On  :   04-06-2025
 * @Last Modified Reason  : Updated updateContact method to Route AccountID
 * Story: SFP-49696 
 */
global without sharing abstract class ICS_CTRL_AuthRegistrationHandler implements Auth.RegistrationHandler {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_AuthRegistrationHandler');

    protected final String TIME_ZONE_SID = 'Africa/Johannesburg';
    protected final String EMAIL_ENCODING = 'UTF-8';
    global final String CONTACT_NOT_FOUND = 'Contact_not_found';
    private final static UserAccessCheckResult SUCCESS_ACCESS_CHECK = new UserAccessCheckResult();
    private final static String USER_ACCESS_CHECK_ERROR_MSG = '{0}&contactid={1}';
    @TestVisible private static final String KEY_NETWORK = 'sfdc_networkid';
    @TestVisible private SBO_Ping_Registration_Site__mdt pingRegistrationSiteTestData;

    /**
     * @description Creates a User object for the specified portal using Ping user information
     * @param portalId Id of the portal configured with this provider
     * @param data User data received from auth provider
     * @return User record for creation
     */
    public User createUser(Id portalId, Auth.UserData data) {
        UserDataWrapper userResponseWrapper = extractUserData(data);
        User user = prepareUser(userResponseWrapper);
        Contact foundContact = findContactForUser(user.Id, userResponseWrapper);

        if (foundContact == null) {
            handleContactNotFound();
        }

        verifyUserAccess(foundContact, userResponseWrapper);
        setUserDetails(user, foundContact, userResponseWrapper);
        updateContact(foundContact.Id, data.attributeMap);
        ICS_CTRL_SeafererSendEmail.sendIDVerificationEmail(foundContact.AccountId);
        sel_user userSelector = new sel_user();
        User userInfo = userSelector.selectByName('Standard Bank Isle of Man Limited');
         UserShare userShare = new UserShare();
            userShare.UserId = userInfo.Id;         // The user being shared
            userShare.UserOrGroupId = user.Id;  // The user to share with
            userShare.UserAccessLevel = 'Read'; // 'Read' or 'Edit'
            userShare.RowCause = Schema.UserShare.RowCause.Manual; // Manual sharing
            
            // Insert the sharing record
             Database.insert(userShare, false);
        return user;
    }
     /**
    * @description prepare data to a User object for the specified portal using Ping user information
    * @param userResponseWrapper
    * @return User
    */
    private User prepareUser(UserDataWrapper userResponseWrapper) {
        User user = new User();
        prepareUserData(user, userResponseWrapper);
        User existingUser = findUserByUsername(user.Username);
        if (existingUser != null) {
            user.Id = existingUser.Id;
        }
        return user;
    }
 /**
     * @description this method used to handling exception and throw an error.
     */
    private void handleContactNotFound() {

        throw new Auth.AuthProviderPluginException(CONTACT_NOT_FOUND);
    }
        /**
    * @description This method used to verify user access based on return data from ping response
    * @param foundContact
    * @param userResponseWrapper
    */
    private void verifyUserAccess(Contact foundContact, UserDataWrapper userResponseWrapper) {
        UserAccessCheckResult userAccessCheckResult = verifyUserAccessForCreate(foundContact, userResponseWrapper);
        if (!userAccessCheckResult.success) {
            throw new Auth.AuthProviderPluginException(userAccessCheckResult.errorMessage);
        }
    }
	 /**
    * @description This method used to checking account record type and finding the user
    * @param user
    * @param foundContact
    * @param userResponseWrapper
    */
    private void setUserDetails(User user, Contact foundContact, UserDataWrapper userResponseWrapper) {

        Id foundProfile = findProfileForUser(user, userResponseWrapper, foundContact.Account.RecordType.DeveloperName);
        setContactAndProfile(user, foundContact, foundProfile);
    }

    /**
     * @description Updates Ping Id in corresponding contact record
     * @param conId Id of the contact
     * @param attributes PING JSON Response information
     */
    public void updateContact(String conId, Map<String, String> attributes) {
        try {
               if (Schema.sObjectType.Contact.isAccessible() || Schema.sObjectType.Contact.isUpdateable()){
                Contact con = new Contact(Id = conId);
                if (attributes.containsKey('id')) {
                    con.Ping_Id__c = attributes.get('id');
                }
                SEL_Contact contactSelector = new SEL_Contact();
                Contact contactWithAccount= contactSelector.selectById(conId);
              
				if (con.Ping_Id__c != null) {
                    ICS_API_UpdatePINGQueuable.updatePermissionSet(contactWithAccount.AccountId, attributes.get(KEY_NETWORK));
                  System.enqueueJob(new ICS_API_UpdatePINGQueuable(contactWithAccount.AccountId, con.Ping_Id__c));
                 
                }
               update con;
            }
        } catch (Exception exc) {
            LOGGER.error(exc.getMessage(), 'Error occurred in update of contact with ping: method(updateContact)');
        }
    }

    /**
     * @description Updates the specified user's information
     * @param userId Id of the existing user to update
     * @param portalId Id of the portal configured with this provider
     * @param data User data received from auth provider
     */
    public void updateUser(Id userId, Id portalId, Auth.UserData data) {
        UserDataWrapper userDataWrapper = extractUserData(data);
        Contact contact = findContactForUser(userId, userDataWrapper);
         SEL_Account accRecord = new SEL_Account();
            Account acc = accRecord.selectById(contact.AccountId);
            
            // Fetch application form for the account
        SEL_ApplicationForm selectorFormData = new SEL_ApplicationForm();
         List<ApplicationForm> applicationForm = selectorFormData.selectByAccountId(acc.Id);
            if(applicationForm[0].opportunity.Required_Approval_Processes__c != null && applicationForm[0].opportunity.Required_Approval_Processes__c.contains('Need Captain letter Approval;')
                        && !applicationForm[0].opportunity.Required_Approval_Processes__c.contains('Captain Letter Approval Confirmed;'+applicationForm[0].AccountId)
                            && applicationForm[0].AccountId ==  acc.Id) 
            {
                ICS_CTRL_SeafererSendEmail.sendIDVerificationEmail(acc.Id);
            }
        if (contact.Ping_Id__c == null) {
            updateContact(contact.Id, data.attributeMap);
        }

        verifyUserAccessForUpdate(contact);
        updateUserData(userId, userDataWrapper);
        updateContact(contact.Id, data.attributeMap);
		
    }



    /**
     * @description Extracts user data from Auth.UserData
     * @param userData User data from the SSO provider
     * @return UserDataWrapper
     */
    global virtual UserDataWrapper extractUserData(Auth.UserData userData) {
        return new UserDataWrapper(userData);
    }

    /**
     * @description Finds Contact for the given user
     * @param userId User Id
     * @param userDataWrapper User data wrapper
     * @return Contact
     */
    global virtual Contact findContactForUser(Id userId, UserDataWrapper userDataWrapper) {
        if (!Schema.sObjectType.Contact.isAccessible())  {
            throw new Auth.AuthProviderPluginException('Insufficient permissions to access Contact records');

        }
        string email=userDataWrapper.email;
        String queryString = 'SELECT Id,Email,Ping_Id__c, Account.RecordType.DeveloperName,AccountId FROM Contact WHERE Email = :email LIMIT 1';

        // Execute the query
        List<Contact> contacts = Database.query(queryString);

        return contacts.isEmpty() ? null : contacts[0];
    }

    /**
     * @description Finds Profile for the user
     * @param user User
     * @param userDataWrapper User data wrapper
     * @param isIfa Boolean indicating if it's an IFA user
     * @return Profile Id
     */
    global virtual Id findProfileForUser(User user, UserDataWrapper userDataWrapper, string recordTypeName) {
        try {
             if (Schema.sObjectType.Profile.isAccessible()) {
            SBO_Ping_Registration_Site__mdt pingRegistrationSite = getPingRegistrationSite(userDataWrapper.networkId);
            String profileName =pingRegistrationSite.Profile__c;
            if(recordTypeName =='IFA'){
                profileName=pingRegistrationSite.IFA_Profile__c;
            }
            return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
             }else{
                 return null;
             }
        } catch (Exception e) {
        	return null;
        }
    }

    /**
     * @description Prepares User object mapping
     * @param user User to prepare
     * @param userResponseWrapper User response wrapper
     */
    global virtual void prepareUserData(User user, UserDataWrapper userResponseWrapper) {
        String lastnameValue;
        if (userResponseWrapper.lastName == null) {
            lastnameValue = 'lastName';
        } else {
            lastnameValue = userResponseWrapper.lastName;
        }
        user.Email = userResponseWrapper.Email;
        user.LastName = lastnameValue;
        user.FirstName = userResponseWrapper.firstName;
        user.Username = buildUsername(userResponseWrapper.email,userResponseWrapper.networkid);
        user.Alias = buildAlias(userResponseWrapper.firstName, lastnameValue);
        user.LanguageLocaleKey = UserInfo.getLanguage();
        user.EmailEncodingKey = EMAIL_ENCODING;
        user.LocaleSidKey = UserInfo.getLocale();
        user.TimeZoneSidKey = TIME_ZONE_SID;
        user.echosign_dev1__EchoSign_Allow_Delegated_Sending__c=true;
        user.echosign_dev1__EchoSign_Email_Verified__c = true;
       setUserPreferences(user);
    }
 /**
     * @description Prepares User object mapping
     * @param user User to prepare
     */
    private void setUserPreferences(User user) {
        user.UserPreferencesDisableBookmarkEmail = true;
        user.UserPreferencesDisableAllFeedsEmail = true;
        user.UserPreferencesDisableFollowersEmail = true;
        user.UserPreferencesDisableLaterCommentEmail = true;
        user.UserPreferencesDisableLikeEmail = true;
        user.UserPreferencesDisableMentionsPostEmail = true;
        user.UserPreferencesDisableMessageEmail = true;
        user.UserPreferencesDisableProfilePostEmail = true;
        user.UserPreferencesDisableSharePostEmail = true;
        user.UserPreferencesDisCommentAfterLikeEmail = true;
        user.UserPreferencesDisMentionsCommentEmail = true;
        user.UserPreferencesDisProfPostCommentEmail = true;
        user.UserPreferencesHideChatterOnboardingSplash = true;
    }

    /**
     * @description Sets Contact and Profile Id for the user
     * @param user User
     * @param contact Contact
     * @param profileId Profile Id
     */
    global virtual void setContactAndProfile(User user, Contact contact, Id profileId) {
        user.ContactId = contact.Id;
        user.ProfileId = profileId;
    }
        /**
    * @description this method is used to assigning Username
    * @param email
    * @param networkId
    * @return String
    */
    private String buildUsername(string email,string networkId) {
        return email + lookupSuffix(networkId);
    }
	 /**
    * @description this method is used to assigning Username Suffix to the username
    * @param networkId
    * @return String
    */
    private String lookupSuffix(string networkId) {
        SBO_Ping_Registration_Site__mdt pingGeneralSettings = getPingRegistrationSite(networkId);
        return pingGeneralSettings == null  ? '' : '.' + pingGeneralSettings.Username_Suffix__c;
    }
 /**
    * @description this method is used to assigning alias with  first name and last name
    * @param firstName
    * @param lastName
    * @return String
    */
    @TestVisible
    private String buildAlias(String firstName, String lastName) {
        string alias;
        if(firstName == null){
            alias=lastName;
        }else{
            alias= firstName.left(1)+lastName;
        }
        return alias.left(8).toLowerCase();
    }
        /**
    * @description this method is used to update user date
    * @param userId
    * @param userDataWrapper
    */
    @TestVisible
    private void updateUserData(Id userId, UserDataWrapper userDataWrapper) {
        String lastnameValue;
        if (userDataWrapper.lastName == null) {
            lastnameValue = 'lastName';
        } else {
            lastnameValue = userDataWrapper.lastName;
        }
         if (Schema.sObjectType.User.isUpdateable()){
        update new User(Id = userId, FirstName = userDataWrapper.firstName, LastName = lastnameValue, Email = userDataWrapper.email);
       
        }
    }
/**
     * @description get the data from the user object
     * @param usernamefindUserByUsername
     * @return User
     */
    private User findUserByUsername(String username) {
        if (Schema.sObjectType.User.isAccessible()) {
        List<User> users = [SELECT Id, Username FROM User WHERE Username = :username LIMIT 1];
       		 return users.isEmpty() ? null : users[0];
        }else{
            return null;
        }
    }


/**
     * @description get the data from the SBO_Ping_Registration_Site__mdt
     * @param networkId
     * @return SBO_Ping_Registration_Site__mdt
     */
    private SBO_Ping_Registration_Site__mdt getPingRegistrationSite(String networkId) {
       if (Schema.sObjectType.SBO_Ping_Registration_Site__mdt.isAccessible()){
        return Test.isRunningTest() ? pingRegistrationSiteTestData :
               [SELECT Profile__c, IFA_Profile__c,Username_Suffix__c FROM SBO_Ping_Registration_Site__mdt WHERE Network_Id__c = :networkId];
                   }else{
                       return null;
                   }
    }

    /**
     * @description Verify access for Create
     * @param contact Contact
     * @param userDataWrapper User data wrapper
     * @return UserAccessCheckResult
     */
    global abstract UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper);

    /**
     * @description Verify access for update
     * @param contact Contact
     * @return UserAccessCheckResult
     */
    global abstract UserAccessCheckResult verifyUserAccessForUpdate(Contact contact);

    /**
     * @description User Access Check Result class
     */
    global class UserAccessCheckResult {
        global final Boolean success;
        global final String errorMessage;
	 /**
     * @description this method User Access Check Result
     * @param errorMessage
     */
        private UserAccessCheckResult(String errorMessage) {
            this.success = false;
            this.errorMessage = errorMessage;
        }
	 /**
     * @description this method check Result class
     */
        public UserAccessCheckResult() {
            this.success = true;
            this.errorMessage = null;
        }
    }

    /**
     * @description Default success result
     * @return UserAccessCheckResult
     */
    global UserAccessCheckResult userAccessCheckSuccess() {
        return SUCCESS_ACCESS_CHECK;
    }

    /**
     * @description Creates a failure result with an error message
     * @param message Error message
     * @return UserAccessCheckResult
     */
    global UserAccessCheckResult userAccessCheckFailure(String message) {
        return new UserAccessCheckResult(message);
    }

    /**
     * @description Creates a failure result with an error message and contact ID
     * @param message Error message
     * @param contactId Contact ID
     * @return UserAccessCheckResult
     */
    global UserAccessCheckResult userAccessCheckFailure(String message, Id contactId) {
        return new UserAccessCheckResult(String.format(USER_ACCESS_CHECK_ERROR_MSG, new List<Object>{message, contactId}));
    }

    /**
     * @description User Data Wrapper class
     */
    global class UserDataWrapper {
        global String networkId {get; set;}
        global String email {get; set;}
        global String cellPhone {get; set;}
        global String dateOfBirth {get; set;}
        global String firstName {get; set;}
        global String lastName {get; set;}
        global String id {get; set;}
        global String sub {get; set;}

        public UserDataWrapper(Auth.UserData userData) {
            this.networkId = userData.attributeMap.get(KEY_NETWORK);
            this.id = userData.identifier;
            this.firstName = userData.firstName;
            this.lastName = userData.lastName;
            this.email = userData.email;
        }
    }

    
    /**
     * @description Private method to get user record based on contact Id
     */
    private static User getUser(String contactId) {
        List<User> users = [SELECT Id FROM User WHERE ContactId = :contactId LIMIT 1];
        return users.isEmpty() ? null : users[0];
    }
}