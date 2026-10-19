/**
 * @Name of the Class : ICS_UTIL_AppFormDataProvider.cls
 * @description: class used to fetch data and data on to the UI
 * @Author Ikyatha Naidu
 * @Date 01/06/2024
 * @Last Modified On  : 25/08/2024
 * @Last Modified By  : Ikyatha Naidu
 * @Modification Description : Initial Version
 *  ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 18-06-2025
 * @Modification description : SFP-50276
 ***************************************************************************************
 */
public without sharing class ICS_UTIL_AppFormDataProvider {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_UTIL_AppFormDataProvider');

    public Opportunity opportunityRecord;
    public Map<String, Id> recordTypes;
    public Map<Id, ApplicationForm> applicationRecords;
    public Map<Id, Account> accountRecords;
    public List<ContactPointAddress> addressRecords;
    public List<ContactPointPhone> PhoneRecords;
    public List<FinServ__Employment__c> employmentRecords;
    public List<AssetsAndIncomes__c> assetsRecords;
    public List<PartyProfile> partyProfileRecords;
    public PartyProfile partyProfileRecordByType;
    public PartyProfile partyProfileRecordByTypeadd;
    public List<Party_Assets_Funds__c> partyAssets;
    public List<Party_Assets_Funds__c> partyBusinessAssets;
    public List<AssessmentQuestionResponse> assessmentQuestions;
    public List<IdentityDocument> identityDocumentRecords;

    public List<PartyProfileAddress> partyProfileAddressRecords;
    List<String> typeList = new List<String>();

    public ICS_UTIL_AppFormDataProvider(Id recordId) {
        fetch(recordId);
    }
     public ICS_UTIL_AppFormDataProvider() {

    }

    /**
     * @description Method which starts fetching the data from the database
     * @param recordId Opportunity record Id
     */
    public void fetch(Id recordId) {
        opportunityRecord = fetchOpportunity(recordId);
        recordTypes = fetchRecordTypes();
        applicationRecords = fetchApplications(recordId);

        Set<Id> applicationIds = applicationRecords.keySet();
        Set<Id> accountIds = new Set<Id>();
        for(Id applicationId : applicationIds) {
            accountIds.add(applicationRecords.get(applicationId).AccountId);
        }
        accountRecords = fetchPersonAccounts(accountIds);
        List<PartyProfile> pDataList=[select id from PartyProfile where accountId in: accountIds and recordtype.Name='ICS Party Profile'];
        PartyProfile pData=pDataList[0];
        addressRecords = fetchAddresses(accountIds);
        PhoneRecords=fetchPhone(accountIds);

        employmentRecords = fetchEmployment(accountIds);
        assetsRecords = fetchAssets(applicationIds);
        Set<Id> partyAddressIds = new Set<Id>();
        partyProfileRecords = fetchPartyProfiles(accountIds);
        identityDocumentRecords = fetchIdentityDocuments(accountIds);
        partyProfileRecordByType = fetchPartyProfileByAccountAndRecType(accountIds);
        partyProfileRecordByTypeadd = fetchPartyProfileByAccountAndRecTypeAdd(accountIds);
        assessmentQuestions = fetchAssessmentQuestions(accountIds);
        for(PartyProfile partyAddrId : partyProfileRecords){
            partyAddressIds.Add(partyAddrId.Id);
        }
        if(partyProfileRecordByType != null && partyProfileRecordByType.Id != null) {
            partyAddressIds.Add(partyProfileRecordByType.Id);
        }
        partyProfileAddressRecords = fetchPartyProfileAddresses(partyAddressIds);
        partyAssets = fetchPartyAssets(pData.Id);
        for(Party_Assets_Funds__c pf :partyAssets ) {
            typeList.add(pf.Type__c);

        }
        partyBusinessAssets = fetchPartyAssetFunds(pData.Id,typeList);
    }

    /**
     * @description Method is used to get a map of countries api name/label matches
     * @return a map of country api name => country label
     */
    public static Map<String, String> getCountryValueMap() {
        String objectName = 'ContactPointAddress';
        String fieldPath = 'Country__c';

        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);

        if (SObjectTypeObj == null) {
            LOGGER.error('Failed to find sObject (country value map)');
            return null;
        }

        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Map<String, Schema.SObjectField> objFields = DescribeSObjectResultObj.fields.getMap();
        Schema.SObjectField fieldObj = objFields.get(fieldPath);

        if (fieldObj == null) {
            LOGGER.error('Failed to find a field (country value map)');
            return null;
        }

        Schema.DescribeFieldResult fieldDesc = fieldObj.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldDesc.getPicklistValues();
        Map<String, String> result = new Map<String, String>();

        for (Schema.PicklistEntry option: picklistEntries) {
            result.put(option.getValue(), option.getLabel());
        }
        return result;
    }

    /**
     * @description Method is used to get a list of all fields within an object represented as a string
     * @param objectName API name of the object
     * @return String of object fields separated by comma
     */
    private String getObjectFields(String objectName) {
        List<String> fields = new List<String>(
            Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().keySet()
        );
        return String.join(fields, ',');
    }

    /**
     * @description Method is used to get the opportunity record
     * @param recordId Opportunity record Id
     * @return Opportunity record
     */
    private Opportunity fetchOpportunity(Id recordId) {

        Opportunity opp= new Opportunity();
        sel_Applicationform formSelector = new sel_applicationform();
        List<Applicationform>formInfo = formSelector.selectByAccountId(recordID);
        if(formInfo.size()>0){
            SEL_Opportunity queryRecord = new SEL_Opportunity();
            opp = queryRecord.selectById(formInfo[0].opportunityId);
        }

        return opp;
    }

    /**
     * @description Method is used to get a map of ApplicationForm related to the opportunity
     * @param recordId Opportunity record Id
     * @return Map of ApplicationForm where keys are ids of the ApplicationForm
     */
    private Map<Id, ApplicationForm> fetchApplications(Id recordId) {
        SEL_ApplicationForm queryRecord = new SEL_ApplicationForm();

        List<ApplicationForm> records = queryRecord.selectByAccountId(recordId);
        Map<Id, ApplicationForm> result = new Map<Id, ApplicationForm>();
        for(ApplicationForm record: records) {
            result.put(record.Id, record);
        }
        return result;
    }

    /**
     * @description Method is used to get related accounts
     * @param accountIds Set of account ids
     * @return Map of accounts where keys are ids of the accounts
     */
    @TestVisible
    private Map<Id, Account> fetchPersonAccounts(Set<Id> accountIds) {
        SEL_Account queryRecord = new SEL_Account();
        List<Account> records = queryRecord.selectByIds(accountIds);
        Map<Id, Account> result = new Map<Id, Account>();
        for(Account record: records) {
            result.put(record.Id, record);
        }
        return result;
    }

    /**
     * @description Method is used to get related address records
     * @param accountIds Set of account ids
     * @return List of address records related to accounts
     */
    public List<ContactPointAddress> fetchAddresses(Set<Id> accountIds) {
        String fields = getObjectFields('ContactPointAddress');
        String query = 'SELECT '+fields+' FROM ContactPointAddress WHERE ParentId = :accountIds';
        List<ContactPointAddress> records = Database.query(query);
        return records;
    }
    public List<ContactPointPhone> fetchPhone(Set<Id> accountIds) {
        String fields = getObjectFields('ContactPointPhone');
        String query = 'SELECT '+fields+' FROM ContactPointPhone WHERE ParentId IN :accountIds';
        List<ContactPointPhone> records = Database.query(query);
        return records;
    }
   Public List<PartyProfileAddress> fetchPartyProfileAddresses(Set<Id> partyAddressIds){
        String fields = getObjectFields('PartyProfileAddress');
        String query = 'SELECT '+fields+' FROM PartyProfileAddress WHERE PartyProfileId in :partyAddressIds';
        List<PartyProfileAddress> records = Database.query(query);
        return records;
    }
    Public List<Party_Assets_Funds__c> fetchPartyAssets(Id partyId){
        // String ASSET_TYPE = 'Trust';
        String fields = getObjectFields('Party_Assets_Funds__c');
        String query = 'SELECT '+fields+' FROM Party_Assets_Funds__c WHERE Party_Profile__c = :partyId  ';
        // AND Type__c=:ASSET_TYPE
        List<Party_Assets_Funds__c> records = Database.query(query);
        return records;
    }


    Public List<Party_Assets_Funds__c> fetchPartyAssetsAdditionAccount(Id partyId){
        String fields = getObjectFields('Party_Assets_Funds__c');
        Id recordTypeId=Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Additional Accounts').getRecordTypeId();
        String query = 'SELECT '+fields+' FROM Party_Assets_Funds__c WHERE Party_Profile__c = :partyId and recordTypeId=:recordTypeId';
        List<Party_Assets_Funds__c> records = Database.query(query);
        return records;
    }

    /**
     * @description Method is used to get related employment records
     * @param accountIds Set of account ids
     * @return List of employment records related to accounts
     */
    public List<FinServ__Employment__c> fetchEmployment(Set<Id> accountIds) {
        SEL_Employment queryRecord = new SEL_Employment();
        return queryRecord.selectByAccountIds(accountIds);
    }

    /**
     * @description Method is used to get related assets and income records
     * @param accountIds Set of application ids
     * @return List of assets and income records related to application
     */
    private List<AssetsAndIncomes__c> fetchAssets(Set<Id> applicationIds) {
        String fields = getObjectFields('AssetsAndIncomes__c');
        String query = 'SELECT '+fields+' FROM AssetsAndIncomes__c WHERE Application__c = :applicationIds';
        List<AssetsAndIncomes__c> records = Database.query(query);
        return records;
    }

    /**
     * @description Method is used to get related party profile records
     * @param accountIds Set of account ids
     * @return List of party profile records related to account
     */
    public List<PartyProfile> fetchPartyProfiles(Set<Id> accountIds) {
        SEL_PartyProfile queryRecord = new SEL_PartyProfile();
        return queryRecord.selectByAccountIds(accountIds);
    }

    public PartyProfile fetchPartyProfileByAccountAndRecType(Set<Id> accountIds) {
        SEL_PartyProfile queryRecord = new SEL_PartyProfile();
        String accId = new List<Id>(accountIds)[0];
        return queryRecord.selectByAccountAndRecordType(accId, 'ICS_PartyProfile');
    }
    public PartyProfile fetchPartyProfileByAccountAndRecTypeAdd(Set<Id> accountIds) {
        SEL_PartyProfile queryRecord = new SEL_PartyProfile();
        String accId = new List<Id>(accountIds)[0];
        return queryRecord.selectByAccountAndRecordType(accId, 'ICS_Additional_Business_Owner');
    }
    /**
     * @description Method is used to get related party asset funds records
     * @param partyProfileId Set of account ids
     * @return List of party asset fund records related to partyprofileId
     */

    public List<Party_Assets_Funds__c> fetchPartyAssetFunds(String partyProfileId,List<string> typeList) {
        SEL_PartyAssetFunds queryRecord = new SEL_PartyAssetFunds();
        return queryRecord.selectByPartyProfileTypeList(partyProfileId,typeList);
    }
    public List<AssessmentQuestionResponse> fetchAssessmentQuestions(Set<Id> accountIds) {
        String fields = getObjectFields('AssessmentQuestionResponse');
        String query = 'SELECT ' + fields +
                        ',AssessmentQuestion.Id, AssessmentQuestion.Name' +
                        ' FROM AssessmentQuestionResponse ' +
                      'WHERE Assessment.AccountId IN :accountIds ORDER BY CreatedDate ASC' ;
        List<AssessmentQuestionResponse> records = Database.query(query);
        return records;
    }

    /**
         * @description Method is used to get related identity document records
         * @param accountIds Set of account ids
         * @return List of identity document records related to accounts
         */
        public List<IdentityDocument> fetchIdentityDocuments(Set<Id> accountIds) {
             SEL_IdentityDocument identityDocuments = new SEL_IdentityDocument();
            return identityDocuments.selectByAccountIds(accountIds);
        }


    /**
     * @description Method is used to get record types
     * @return Map of record types ids
     */
    private Map<String, Id> fetchRecordTypes() {
        Map<String, Id> result = new Map<String, Id>();
        Set<String> objects = new Set<String>{
            'Opportunity',
            'ApplicationForm',
            'Account',
            'ContactPointAddress',
            'FinServ__Employment__c',
            'AssetsAndIncomes__c',
            'PartyProfile',
            'PartyProfileAddress',
            'ContactPointEmail',
            'ContactPointPhone',
                'Party_Assets_Funds__c'
        };
        if (!RecordType.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException('Insufficient permissions to access RecordType');
        }
        List<RecordType> recordTypes = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = :objects];
        for (RecordType type : recordTypes) {
            result.put(type.SobjectType+'_'+type.DeveloperName, type.Id);
        }
        return result;
    }
}