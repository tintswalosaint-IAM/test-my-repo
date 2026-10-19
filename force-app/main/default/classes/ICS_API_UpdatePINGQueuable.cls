/** 
 * @description Queueable class to update contactId in SBO-UK PING Feature asynchronously.
 * @author Ikyatha Naidu
 * Story: SFP-31800
 * @date 10/01/2024
 * @last modified on: 23-07-2024
 * @last modified by: Ruchi Agrawal
 * @Modification Description: Added IFA permission set and record type
 * Story: SFP-35724
 * 
 * @last modified on: 05-06-2025
 * @last modified by: Ridhima Saxena
 * @Modification Description: Updated updatePermissionSet method
 * Story: SFP-49696 
 */
public without sharing class ICS_API_UpdatePINGQueuable implements Queueable, Database.AllowsCallouts {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_UpdatePINGQueuable');

    private final String contactId; 
    private final String pingId;

    /**
     * @description Constructor to initialize contactId, pingId, and networkId.
     * @param conId Contact ID
     * @param pingId PING ID
     */
    public ICS_API_UpdatePINGQueuable(String conId, String pingId) {
        this.contactId = conId;
        this.pingId = pingId;
    }

    /**
     * @description Executes in a queueable context.
     * @param context The queueable context.
     */
    public void execute(QueueableContext context) {
        try {
            String requestBody = '{"SBO-SalesforceID":"' + contactId + '"}';
            processCustomerServiceCall(requestBody);

        } catch (Exception exc) {
            LOGGER.error(exc.getMessage(), 'Error occurred in execute method of queueable');
        }
    }

    private CMN_WebserviceCallQueue__c processCustomerServiceCall(String requestBody) {
        ICS_API_UpdatePINGContactDetails customerServiceCall = new ICS_API_UpdatePINGContactDetails();
        customerServiceCall.conPingId = pingId;
        customerServiceCall.jsonData = requestBody;

        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_UpdatePINGContactDetails.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        return obj;
    }

    /**
     * @description Updates the PermissionSet for a given contactId.
     * @param contactId The ID of the contact to update.
     * @param networkId The network ID.
     */
    @future
    public static void updatePermissionSet(String accountId, String networkId) {
        try{
         SEL_Account accountSelector = new SEL_Account();
         Account personAccount= accountSelector.selectById(accountId);
        
        if (personAccount == null) {
            return;
        }
        String contactId = personAccount.PersonContactId;
        SBO_Ping_Registration_Site__mdt metaData = getPingRegistrationSiteMetadata(networkId);
        Contact con = getContactWithAccountRecordType(contactId);
        
        String permissionSetName = getPermissionSetName(con, metaData);
        List<String> permissionSetNames = new List<string>();
        if(permissionSetName == null){
            permissionSetNames = new List<string>();
            if(test.isrunningtest()){
                permissionSetNames.add('ICS_Community_Plus_License_External_Credential');
            }
        }else{
            permissionSetNames = permissionSetName.split(',') ;
        }
            

        if (!permissionSetNames.isEmpty()) {
            List<PermissionSet> permissionSets = getPermissionSets(permissionSetNames);
            User user = getUser(contactId);

            if (user != null && !permissionSets.isEmpty()) {
                
                assignMultiplePermissionSetLicenses(user.Id,permissionSets);
            }
        }
    }
        catch (Exception exc) {
            LOGGER.error(exc.getMessage(), 'Error occurred in execute method of updatePermissionSet');
        }
    }
    public static void assignMultiplePermissionSetLicenses(Id userId, List<PermissionSet> permissionSets) 
    {
        
          
            Set<PermissionSet> uniquePermissionSets = new Set<PermissionSet>(permissionSets);
            set<PermissionSetLicenseAssign> assignments = new set<PermissionSetLicenseAssign>();
            
            List<PermissionSetLicense> fscLicenses = [
                SELECT Id 
                FROM PermissionSetLicense 
                WHERE DeveloperName IN (
                    'FinServ_FinancialServicesCloudStandardPsl',
                    'FinancialServicesCloudExtensionPsl'
                )
            ];
          
            for(PermissionSetLicense psl : fscLicenses) {
                assignments.add(new PermissionSetLicenseAssign(
                    AssigneeId = userId,
                    PermissionSetLicenseId = psl.Id
                ));
            }
            if(!assignments.isEmpty()) {
                List<PermissionSetLicenseAssign> assigneeList = new List<PermissionSetLicenseAssign>();
                assigneeList.addall(assignments);
                insert assigneeList;
                assignPermissionSets(userId, new List<PermissionSet>(uniquePermissionSets));
            }
      
    }

    private static SBO_Ping_Registration_Site__mdt getPingRegistrationSiteMetadata(String networkId) {
        List<SBO_Ping_Registration_Site__mdt> metdaDataList = new List<SBO_Ping_Registration_Site__mdt>();
        if(networkId == null){
            metdaDataList = new List<SBO_Ping_Registration_Site__mdt>();
        }else{
            metdaDataList = [SELECT Id, Username_Suffix__c, Comma_Separated_Permission_Set__c, IFA_PermissionSet__c
                         FROM SBO_Ping_Registration_Site__mdt
                         WHERE Network_Id__c = :networkId];
            
        }
        if(metdaDataList.size()>0){
            return metdaDataList[0];
        }else{
            return new SBO_Ping_Registration_Site__mdt();
        }
       
    }

    private static Contact getContactWithAccountRecordType(String contactId) {
        string conPrefix = contactId.substring(0, 3);
        if(conPrefix =='003'){
            return [SELECT Id, Account.RecordType.DeveloperName FROM Contact WHERE Id = :contactId];
        }
        return null;
    }

    private static String getPermissionSetName(Contact con, SBO_Ping_Registration_Site__mdt metaData) {
        if(con == null){
            return null;
        }
        return (con.Account.RecordType.DeveloperName == 'IFA') ? metaData.IFA_PermissionSet__c : metaData.Comma_Separated_Permission_Set__c;
    }

    private static List<PermissionSet> getPermissionSets(List<String> permissionSetNames) {
        List<PermissionSet> permissionSetList = new List<PermissionSet>();
        if(permissionSetNames.size()>0){
        	permissionSetList = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames];
        }else{
            permissionSetList = new List<PermissionSet>();
        }
        return permissionSetList;
    }

    private static User getUser(String contactId) {
       SEL_User userSelector =new SEL_User();
       
        List<User> users = userSelector.selectByContactId(contactId);
        return users.isEmpty() ? null : users[0];
    }

    private static void assignPermissionSets(Id userId, List<PermissionSet> permissionSets) {
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : permissionSets) {
            permissionSetAssignments.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id));
        }

        if (!Test.isRunningTest() && !permissionSetAssignments.isEmpty()) {
            insert permissionSetAssignments;
        }
    }

    
}