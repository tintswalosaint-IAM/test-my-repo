/**
 * Contains the user functions
 * 
 * <p></p> 
 * 
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 * 
 * @date Nov 9th 2020
 */
public with sharing class AOB_SRV_UserManagement {	
    public static final String SERVICE_NAME = AOB_SRV_UserManagement.class.getName();
    /**
    * Assign permission set to the Customer 
    * @param attributes - the provided context for the User
    */
    public static void assignPermissionSet(List<User> users,Set<Id> userIds,Set<Id> contactIds) { 
        String EXTERNAL_USER_PERMISSION = AOB_Utils.getAppSettingByLabel(AOB_Constants.PERMISSION);
        Map<Id,boolean> id2hasPermission = new  Map<Id,boolean>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        PermissionSet customerPerm = [SELECT Id 
                                      FROM PermissionSet 
                                      WHERE Name =:EXTERNAL_USER_PERMISSION];
        for(PermissionSetAssignment permission:[SELECT Id,AssigneeId
                                                FROM PermissionSetAssignment
                                                WHERE PermissionSetId =:customerPerm.Id 
                                                AND AssigneeId IN :userIds]){                                   
          id2hasPermission.put(permission.AssigneeId,true);
        }
        for(user u:users){
            if(!id2hasPermission.containsKey(u.Id)){
                userIdSet.add(u.id);
            }   
        }
        addPermission(userIdSet,customerPerm.id);
    }
    /**
    * add permission set assignement to the customer user
    * @param permissionList - the user and the permission id 
    */
    @future
    public static void addPermission(Set<Id> userIdSet, Id p){               
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        // Add fields as per your requirement...
        for(Id uId : userIdSet){
            PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = uId,PermissionSetId = p);
            permissionSetList.add(psa);       
        }    
        if(!permissionSetList.isEmpty()){
            insert permissionSetList;
        }
    }
    /**
    * Create a Person Account
    * @param attributes - the provided context for the User
    */
    public static Account createPersonAccount(Map<String, String> attributes){
        RecordType personAccountRT =  [SELECT Id 
                                       FROM RecordType 
                                       WHERE Name =:AOB_Constants.PERSON_ACCOUNT 
                                       AND SObjectType =:AOB_Constants.ACCOUNT];     

        String OwnerId = AOB_Utils.getAppSettingByLabel(AOB_Constants.OWNER);  
        Account newPersonAccount = new Account();   
        if(attributes.containsKey(AOB_Constants.COMMERCE_SITE_ID)){ 
            newPersonAccount.AOB_CommerceSiteId__c = attributes.get(AOB_Constants.COMMERCE_SITE_ID);            
            AOB_Country_Settings__mdt setting = AOB_Utils.getCountrySetting(newPersonAccount.AOB_CommerceSiteId__c);
            // build an Entreprise External Id DBP-2068
            if(setting != null && attributes.get(AOB_Constants.PING_BPID) != null){
                newPersonAccount.ExternalIdentifier__c = setting.AOB_CountryAbr__c + setting.AOB_SystemId__c + attributes.get(AOB_Constants.PING_BPID);
            }
            if(newPersonAccount.ExternalIdentifier__c != null){
                List<Account> accs = [SELECT Id,ExternalCIFCountry__c,ExternalSystemId__c 
                                        FROM Account 
                                        WHERE ExternalIdentifier__c =:newPersonAccount.ExternalIdentifier__c
                                        AND recordTypeId =:personAccountRT.id
                                    ];
                newPersonAccount.id = !accs.isEmpty() ? accs[0].id : null;
            }
            if(setting != null){
                newPersonAccount.AOB_Currency__c = setting.AOB_Currency__c;
                newPersonAccount.ExternalCIFCountry__c = setting.AOB_CountryAbr__c;
                newPersonAccount.ExternalSystemId__c = setting.AOB_SystemId__c;
            }
        }
        if(String.isNotBlank(OwnerId)){
            newPersonAccount.OwnerId = OwnerId;
        }
        if(attributes.containsKey(AOB_Constants.PING_BPID)) {
            newPersonAccount.ExternalCIFId__c = attributes.get(AOB_Constants.PING_BPID);
        }
        if(attributes.containsKey(AOB_Constants.PING_BPGUID) && attributes.get(AOB_Constants.PING_BPGUID) != null) {
            newPersonAccount.ExternalCIFUUID__c = AOB_Utils.formatGUID(attributes.get(AOB_Constants.PING_BPGUID));
        } 
        if(attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
            newPersonAccount.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_FIRST_NAME)) {
            newPersonAccount.FirstName = attributes.get(AOB_Constants.PING_FIRST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_EMAIL)) {
            newPersonAccount.personEmail = attributes.get(AOB_Constants.PING_EMAIL);
        }
        if(attributes.containsKey(AOB_Constants.NATIONAL_ID)) {
            newPersonAccount.AOB_IdentityNumber__c = attributes.get(AOB_Constants.NATIONAL_ID);
        } 
        if(attributes.containsKey(AOB_Constants.CUSTOMER_CC)) {
            newPersonAccount.AOB_TECH_CCCustomerId__c = attributes.get(AOB_Constants.CUSTOMER_CC);
        }
        if(attributes.containsKey(AOB_Constants.PHONE)) {
            newPersonAccount.Phone = attributes.get(AOB_Constants.PHONE);
        } 
        if(attributes.containsKey(AOB_Constants.PING_SUB)) {
            if(newPersonAccount.LastName == null){
                newPersonAccount.LastName = attributes.get(AOB_Constants.PING_SUB).replace('@','');
            }
            if(newPersonAccount.personEmail == null){
                newPersonAccount.personEmail = attributes.get(AOB_Constants.PING_SUB);
            }
        }
        newPersonAccount.RecordTypeId = personAccountRT.id;
        upsert newPersonAccount;
        return newPersonAccount; 
    } 
    /**
    * Create a Person Account
    * @param attributes - the provided context for the User
    */
    public static Account updatePersonAccount(Map<String, String> attributes, Account newPersonAccount){
        
        if(attributes.containsKey(AOB_Constants.PING_BPID)) {
            newPersonAccount.ExternalCIFId__c = attributes.get(AOB_Constants.PING_BPID);
        }
        if(attributes.containsKey(AOB_Constants.PING_BPGUID) && attributes.get(AOB_Constants.PING_BPGUID) != null) {
            newPersonAccount.ExternalCIFUUID__c = AOB_Utils.formatGUID(attributes.get(AOB_Constants.PING_BPGUID));
        } 
        if(attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
            newPersonAccount.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_FIRST_NAME)) {
            newPersonAccount.FirstName = attributes.get(AOB_Constants.PING_FIRST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_EMAIL)) {
            newPersonAccount.personEmail = attributes.get(AOB_Constants.PING_EMAIL);
        }
        if(attributes.containsKey(AOB_Constants.NATIONAL_ID)) {
            newPersonAccount.AOB_IdentityNumber__c = attributes.get(AOB_Constants.NATIONAL_ID);
        } 
        if(attributes.containsKey(AOB_Constants.CUSTOMER_CC)) {
            newPersonAccount.AOB_TECH_CCCustomerId__c = attributes.get(AOB_Constants.CUSTOMER_CC);
        }
        if(attributes.containsKey(AOB_Constants.PHONE)) {
            newPersonAccount.Phone = attributes.get(AOB_Constants.PHONE);
        } 
        return newPersonAccount; 
    } 
    /**
    * Create and initialize the User but don't save it yet
    * @param attributes - the provided User context from Ping
    * @param p - the Profile we are going to assign to this user
    * @return User that has been initialized but not Saved
    */ 
    public static User createUser(Map<String, String> attributes,User u,Profile p) {  
        if(attributes.containsKey(AOB_Constants.ID_STRING)) {
            u.federationIdentifier = attributes.get(AOB_Constants.ID_STRING);
        }
        if(attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
            u.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_FIRST_NAME)) {
            u.FirstName = attributes.get(AOB_Constants.PING_FIRST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_EMAIL)) {
            u.Email = attributes.get(AOB_Constants.PING_EMAIL);
        }
        String alias = '';
        if(attributes.containsKey(AOB_Constants.PING_SUB) && attributes.get(AOB_Constants.PING_SUB) != null){
            if(u.LastName == null){
                u.LastName = attributes.get(AOB_Constants.PING_SUB).replace('@','');
            }
            if(attributes.get(AOB_Constants.PING_SUB).contains('@')){
                u.username = attributes.get(AOB_Constants.PING_SUB).substringbefore('@')+'@'+AOB_Constants.SANDBOX_SUFIX;
                alias = attributes.get(AOB_Constants.PING_SUB);
                if(u.Email == null){
                    u.Email = attributes.get(AOB_Constants.PING_SUB);
                }
            }else{
                u.username = attributes.get(AOB_Constants.PING_SUB)+ '@'+AOB_Constants.SANDBOX_SUFIX;
                alias = attributes.get(AOB_Constants.PING_FIRST_NAME)+attributes.get(AOB_Constants.PING_LAST_NAME);
            }
            
        }else{
            alias = attributes.get(AOB_Constants.PING_FIRST_NAME) + attributes.get(AOB_Constants.PING_LAST_NAME);
            u.username = attributes.get(AOB_Constants.PING_EMAIL);
        }
        if(![select id from user where username=:u.username].isEmpty()){
            Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
            u.username=u.username.substringbefore('@')+randomInt+'@'+AOB_Constants.SANDBOX_SUFIX;
        }
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8); 
        }
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = AOB_Constants.UTF8;
        u.timeZoneSidKey = AOB_Constants.TIME_ZONE;
        u.profileId = p.Id;
        return u;
    }
    
}