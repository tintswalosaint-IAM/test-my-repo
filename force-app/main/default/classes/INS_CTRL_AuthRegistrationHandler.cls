/**
* @class Name        : INS_API_AuthRegistrationHandlerPing
* @description       : Authentication handler implementation for Direct Sales Agent Portal Ping
* story              : SFP-53279
* @author            : Jaco de Lange
* @date              : 10-09-2025
**/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing abstract class INS_CTRL_AuthRegistrationHandler implements Auth.RegistrationHandler {
     private static sbgplatform.fflib_SObjectUnitOfWork uow = (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance(); 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_CTRL_AuthRegistrationHandler');

    global static final String CONTACT_NOT_FOUND = 'Contact_not_found';
    global static final String CUSTOMER_PORTAL_NETWORK_ID = 'CustomerPortal';
    protected final String EMAIL_ENCODING = 'UTF-8';
    private final static UserAccessCheckResult SUCCESS_ACCESS_CHECK = new UserAccessCheckResult();
    private final static String USER_ACCESS_CHECK_ERROR_MSG = '{0}&contactid={1}';
    @TestVisible private static final String KEY_NETWORK = 'sfdc_networkid';
    @TestVisible private DSA_Ping_Registration_Site__mdt pingRegistrationSiteTestData;
    @TestVisible private INS_User_Locale__mdt testLocale;

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

                if(foundContact.IsPersonAccount == true) {
                    user.Username = buildUsername(userResponseWrapper.email, CUSTOMER_PORTAL_NETWORK_ID);
                    user.CompanyName = 'Liberty';
                }

                verifyUserAccess(foundContact, userResponseWrapper);
                setUserDetails(user, foundContact);
               
                try {
                    uow.registerNew(user);
                    uow.commitWork();

                    updateContact(foundContact.Id, data.attributeMap);

                    return user;
                  
        } catch (Exception ex) {
            LOGGER.error('INS_CTRL_AuthRegistrationHandler | createUser | exception: ' + ex.getMessage());
            LOGGER.error('INS_CTRL_AuthRegistrationHandler | createUser | stack trace: ' + ex.getStackTraceString());
        }
        return null;
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
    * @description This method used to find profile for the user
    * @param user
    * @param foundContact
    */
    private void setUserDetails(User user, Contact foundContact) {
        List<Profile> profileId = new SEL_Profile().selectByName(foundContact.INS_SalesAgentPortalLicenseType__c);
        setContactAndProfile(user, foundContact, profileId[0].Id);
    }

    /**
     * @description Updates Ping Id in corresponding contact record
     * @param conId Id of the contact
     * @param attributes PING JSON Response information
     */
    private void updateContact(String conId, Map<String, String> attributes) {
        try {
               if (Schema.sObjectType.Contact.isAccessible() || Schema.sObjectType.Contact.isUpdateable()){
                Contact con = new Contact(Id = conId);
                if (attributes.containsKey('id')) {
                    con.Ping_Id__c = attributes.get('id');
                }
                
                updatePermissionSet(attributes.get(KEY_NETWORK), conId);   
                uow.registerDirty(con);
                uow.commitWork();
            }
        } catch (Exception ex) {
            LOGGER.error('Contact update failed | INS_CTRL_AuthRegistrationHandler | updateContact | ' + ex.getMessage() + ' | stack=' + ex.getStackTraceString());
        }
    }
    /**
     * @description Assign permission sets to the user
     * @param networkId Network ID of the site
     * @param conId Id of the contact
     */
    public void updatePermissionSet(String networkId, String conId) {
        Contact personContact;
        try {
            personContact = new SEL_Contact().selectById(conId);
        } catch (System.QueryException e) {
            LOGGER.error('INS_API_AuthRegistrationHandlerPing | updatePermissionSet | No Contact found for Id | ' + conId);
            return;
        }
        
        DSA_Ping_Registration_Site__mdt metaData;

        if (Test.isRunningTest()) {
            metaData = pingRegistrationSiteTestData;
        } else {
            String networkToUse = personContact.IsPersonAccount 
                ? CUSTOMER_PORTAL_NETWORK_ID 
                : networkId;
        
            metaData = getPingRegistrationSiteMetadata(networkToUse);
        }
        
        if (metaData == null) {
            LOGGER.error('INS_API_AuthRegistrationHandlerPing | updatePermissionSet | No Metadata found for Network | ' + networkId);
            return;
        }
        
        if (String.isBlank(metaData.INS_Comma_Separated_Permission_Set__c)) {
            LOGGER.error('INS_API_AuthRegistrationHandlerPing | updatePermissionSet | No Permission Sets configured in Metadata');
            return;
        }
        
        List<String> permissionSetNames = metaData.INS_Comma_Separated_Permission_Set__c.split(',');
        User user = getUser(conId);
        
        if (user == null) {
            LOGGER.error('INS_API_AuthRegistrationHandlerPing | updatePermissionSet | No User found for Contact | ' + conId);
            return;
        }
        
        assignPermissionSetsAsync(user.Id, permissionSetNames);
    }
     /**
     * @description Get permission sets from DSA_Ping_Registration_Site__mdt
     * @param networkId Id of ping
     */
    private static DSA_Ping_Registration_Site__mdt getPingRegistrationSiteMetadata(String networkId) {
        if(networkId==null){
            return null;
        } else{
            return new SEL_DSA_PingRegistration_Site().selectByNetworkId(networkId);
        }
    }
    /**
     * @description Get user record 
     * @param contactId
     */
    private static User getUser(String contactId) {
        List<User> users = new SEL_User().selectByContactId(contactId);
        return users.isEmpty() ? null : users[0];
    }
    @future
    private static void assignPermissionSetsAsync(Id userId, List<String> permissionSetNames) {
        try {
             List<PermissionSet> permissionSets = new SEL_PermissionSet().selectByPermissionSetNames(permissionSetNames);

            if (!permissionSets.isEmpty()) {
                List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
                for (PermissionSet ps : permissionSets) {
                    psaList.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id
                    ));
                }

                if (Schema.sObjectType.PermissionSetAssignment.isCreateable()){
                    for(PermissionSetAssignment psaRec : psaList) {
                        uow.registerNew(psaRec);   
                    }
                        uow.commitWork();
                }
            } 
        } catch (Exception ex) {
            LOGGER.error('Assign permission set failed | INS_CTRL_AuthRegistrationHandler | assignPermissionSet | ' + ex.getMessage() + ' | stack=' + ex.getStackTraceString());
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
            
            if (contact.Ping_Id__c == null) {
                updateContact(contact.Id, data.attributeMap);
            }

        verifyUserAccessForUpdate(contact);
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
        List<Contact> conRec = new SEL_Contact().selectByEmail(userDataWrapper.email);
        return conRec.isEmpty() ? null : conRec[0];
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
        user.EmailEncodingKey = EMAIL_ENCODING; 
        user.echosign_dev1__EchoSign_Allow_Delegated_Sending__c=true;
        user.echosign_dev1__EchoSign_Email_Verified__c = true;
        setUserPreferences(user);
    }
    /**
    * @description Utility to handle blank/null values from CMDT
    */
    private static String safeAssign(String value) {
        return String.isNotBlank(value) ? value : '';
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

        INS_User_Locale__mdt insUserLocale = Test.isRunningTest() ? testLocale     // @TestVisible test injection
                                    : new SEL_User_Locale_Settings().selectByCountry(Contact.External_CIF_Country__c);

        user.CompanyName = Contact.Account.Name.Contains('Liberty') ? 'Liberty' : '';

        if (insUserLocale !=null){
            // Helper to safely assign values
            user.LanguageLocaleKey = safeAssign(insUserLocale.INS_Language_Locale__c);
            user.TimeZoneSidKey = safeAssign(insUserLocale.INS_Time_Zone__c);
            user.LocaleSidKey = safeAssign(insUserLocale.INS_Locale__c);
            user.CurrencyIsoCode = safeAssign(insUserLocale.INS_Currency_Code__c);
            user.DefaultCurrencyIsoCode = safeAssign(insUserLocale.INS_Currency_Code__c);
            user.User_Country__c  = safeAssign(insUserLocale.INS_Country__c);       
        }
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
        DSA_Ping_Registration_Site__mdt pingGeneralSettings = getPingRegistrationSite(networkId);
        return pingGeneralSettings == null  ? '' : '.' + pingGeneralSettings.INS_Username_Suffix__c;
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
     * @description get the data from the user object
     * @param usernamefindUserByUsername
     * @return User
     */
    private User findUserByUsername(String username) {
        if (Schema.sObjectType.User.isAccessible()) {
            List<User> users = new SEL_User().selectByUserName(username);
       		return users.isEmpty() ? null : users[0];
        }else{
            return null;
        }
    }

    /**
     * @description get the data from the DSA_Ping_Registration_Site__mdt
     * @param networkId
     * @return DSA_Ping_Registration_Site__mdt
     */
    private DSA_Ping_Registration_Site__mdt getPingRegistrationSite(String networkId) {
       if (Schema.sObjectType.DSA_Ping_Registration_Site__mdt.isAccessible()){
           return Test.isRunningTest() ? pingRegistrationSiteTestData : new SEL_DSA_PingRegistration_Site().selectByNetworkId(networkId);
       }
       else{
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
    @SuppressWarnings('PMD.AvoidGlobalModifier')
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
    @SuppressWarnings('PMD.AvoidGlobalModifier')
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
}