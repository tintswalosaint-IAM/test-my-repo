/***************************************************************************************
@name of the Class : ICS_CTRL_FecthOnboardingDetails.cls
@description :class used as controller for  SBO-UK ApplicationForm Feature to fetch onboarding details
@author : Ikyatha Naidu
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: Updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_FecthOnboardingDetails {
    Public static final Map<string,string>fetchIdMap = new Map<String,String>();
    Public static  Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
    Public static    Map<String, List<AOB_Field__c>> tableFieldMap = new Map<String, List<AOB_Field__c>>();
    Public static    Map<String, String> quetionWithScreenNameSet = new Map<String, String>();
    Public static    Set<String> tableScreenFields = new Set<String>();
    Public static  Map<string,object>existingDataMap =new Map<string,object>();
    Public static Map<string,List<AssessmentQuestionResponse>>responseAssessmentMap = new Map<string,List<AssessmentQuestionResponse>>();

    Public static List<AssessmentQuestionResponse> responseList = new List<AssessmentQuestionResponse>();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GBG');



    /**
* @description To retrieve custom label metadata based on the provided developer name.
* @param developerName The developer name of the custom label.
* @return The custom label metadata.
*/
    @testVisible
    @AuraEnabled(cacheable=true)
    public static ics_customlabel__mdt getLandingPageJSON(String developerName) {
        try {
            // Check if the user has access to the custom metadata type
            if (!ics_customlabel__mdt.SObjectType.getDescribe().isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access ics_customlabel__mdt.');
            }

            // Check if the user has access to the specific fields
            if (!ics_customlabel__mdt.DeveloperName.getDescribe().isAccessible() ||
                !ics_customlabel__mdt.Description__c.getDescribe().isAccessible()) {
                    throw new AuraHandledException('Insufficient permissions to access required fields on ics_customlabel__mdt.');
                }

            ics_customlabel__mdt icsMetadata = [SELECT DeveloperName, Description__c
                                                FROM ics_customlabel__mdt
                                                WHERE DeveloperName = :developerName
                                                WITH SECURITY_ENFORCED
                                                LIMIT 1];

            if (icsMetadata == null) {
                throw new AuraHandledException('No metadata found for the given developer name: ' + developerName);
            }
				return icsMetadata;
        } catch (Exception exc) {LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description To query data based on the specified parent ID and object names.
* @param parentId The identifier of the parent record.
* @param objectNameList  set containing the names of the objects to query.
* @param sectionName The name of the section.
* @return List of sObjects containing the queried data.
*/
    public static List<sObject> queryData(string parentId, set<string> objectNameList, string sectionName) {
        List<sObject> objectInfoList = new List<sObject>();
        Map<String, List<SObject>> dataMap = new Map<String, List<SObject>>();

        PartyProfile profileData = queryPartyProfile(parentId);

        if (profileData != null && sectionName != 'Business Ownership') {
            objectInfoList.add(profileData);

        }

        queryStandardObjects(parentId, objectNameList, dataMap,sectionName);


        queryPartyProfileAddress(profileData, objectNameList, sectionName, dataMap);
        queryPartyAssetsFunds(profileData, sectionName, objectNameList, dataMap);

        processDataMap(objectNameList, dataMap, objectInfoList);

        return objectInfoList;
    }



    private static void queryStandardObjects(String parentId, Set<String> objectNameList, Map<String, List<SObject>> dataMap,string sectionName) {
        if (objectNameList.contains('Account')) {
            dataMap.put('Account', new List<SObject>{new SEL_Account().selectById(parentId)});
        }
        if (objectNameList.contains('ContactPointPhone')) {
            dataMap.put('ContactPointPhone', new SEL_ContactPointPhone().selectByParentId(parentId));
        }
        if (objectNameList.contains('ContactPointEmail')) {
            dataMap.put('ContactPointEmail', new List<SObject>{new SEL_ContactPointEmail().selectByParentId(parentId)});
        }
        if (objectNameList.contains('IdentityDocument')) {
            dataMap.put('IdentityDocument', new SEL_IdentityDocument().selectByAccountId(parentId));
        }
        if (objectNameList.contains('Applicant')) {
            dataMap.put('Applicant', [SELECT id, Other_Surname__c, Other_Names__c, Other_First_Name__c,
                                      Other_Middle_Name__c, role, AccountId, ApplicationFormId
                                      FROM applicant WHERE accountid = :parentId]);
        }
        if (objectNameList.contains('FinServ__Employment__c')) {
            dataMap.put('FinServ__Employment__c', new SEL_Employment().selectByParentIdAndSectionName(parentId, sectionName));
        }
    }

    private static void queryPartyProfileAddress(PartyProfile profileData, Set<String> objectNameList, String sectionName, Map<String, List<SObject>> dataMap) {

        if (objectNameList.contains('PartyProfileAddress') && profileData != null) {
            SEL_PartyProfileAddress selector = new SEL_PartyProfileAddress();
            List<SObject> addresses = new List<SObject>();

            switch on sectionName {
                when 'Current Residential Address' {
                    addresses.addAll(selector.selectCurrentAddressByPartyProfileId(profileData.id));
                }
                when 'Previous Residential Address' {
                    addresses.addAll(selector.selectCurrentAddressByPartyProfileId(profileData.id));
                    addresses.addAll(selector.selectPreviousAddressByPartyProfileId(profileData.id));
                }
                when 'Selected Account' {
                    addresses.addAll(selector.selectByPartyProfileType(profileData.id, 'Other'));
                }
                when 'Correspondence Address' {
                    addresses.addAll(selector.selectCorrespondanceAddressByPartyProfileId(profileData.id));
                }
                when 'Applicant\'s Current Residential Address' {
                   addresses.addAll(selector.selectCurrentAddressByPartyProfileId(profileData.id));
                }
                 when 'Applicant\'s Previous Residential Address' {
                    addresses.addAll(selector.selectCurrentAddressByPartyProfileId(profileData.id));
                    addresses.addAll(selector.selectPreviousAddressByPartyProfileId(profileData.id));
                }
                when 'Applicant\'s Correspondence Address' {
                    addresses.addAll(selector.selectCorrespondanceAddressByPartyProfileId(profileData.id));
                }
            }

            dataMap.put('PartyProfileAddress', addresses);

        }
    }
	@TestVisible
    private static void queryPartyAssetsFunds(PartyProfile profileData, String sectionName, Set<String> objectNameList, Map<String, List<SObject>> dataMap) {
        if (profileData != null) {
            SEL_PartyAssetFunds selector = new SEL_PartyAssetFunds();
            SEL_PartyProfile profileSelector = new SEL_PartyProfile();

            switch on sectionName {
                when 'Business Ownership' {
                    if (objectNameList.contains('Party_Assets_Funds__c')) {
                        dataMap.put('Party_Assets_Funds__c', selector.selectAssetFundsByRecordType(profileData.id, new List<String>{'Ownership/shares in business'}, 'Wealth'));
                    }
                    if (objectNameList.contains('PartyProfile')) {
                        dataMap.put('BusinessOwnerPartyProfile', profileSelector.selectBusinessOwnerByPartyProfileId(profileData.id));
                    }
                }
                when 'Other Business Interests' {
                    dataMap.put('OtherBusinessInterests', selector.selectByPartyProfileType(new Set<Id>{profileData.id}, 'Wealth in Country', new List<String>{'Other Business Interests'}));
                }
                when 'Initial Deposit' {
                    dataMap.put('InitialDeposit', selector.selectDepositInfoByPartyProfileIds(new Set<Id>{profileData.id}));
                }
                when 'Bank Details' {
                    dataMap.put('BankDetails', selector.selectAssetFundsByRecordType(profileData.id, new List<String>{'Bank Account'}, 'PrimaryAdditional'));
                }
                when 'Additional Bank Accounts' {
                    dataMap.put('AdditionalBankAccounts', selector.selectAssetFundsByRecordType(profileData.id, new List<String>{'Bank Account'}, 'Additional'));
                }
            }
        }
    }

    private static void processDataMap(Set<String> objectNameList, Map<String, List<SObject>> dataMap, List<SObject> objectInfoList) {
        for (String objectName : objectNameList) {
            objectName = objectName.contains('table:') ? objectName.split(':')[1] : objectName;
            if (dataMap.containsKey(objectName)) {
                objectInfoList.addAll(dataMap.get(objectName));
            }
        }
        List<String> specialCases = new List<String>{'BusinessOwnerPartyProfile', 'OtherBusinessInterests', 'InitialDeposit', 'BankDetails', 'AdditionalBankAccounts'};
            for (String specialCase : specialCases) {
                if (dataMap.containsKey(specialCase)) {
                    objectInfoList.addAll(dataMap.get(specialCase));
                }
            }
    }

    /**
* @description To query data based on the specified parent ID, object names, and section name.
* @param parentId The identifier of the parent record.
* @param objNames Set containing the names of the objects to query.
* @param sectionName The name of the section.
* @return Map of string key-value pairs containing the queried data.
*/
    public static Map<String, String> queryDataWithObject(String parentId, Set<String> objNames, String sectionName) {

        Map<String, String> mapWithObjectIds = new Map<String, String>();

        PartyProfile profileData = queryPartyProfile(parentId);

        for (String objectName : objNames) {
            String objectId = queryObjectId(objectName, parentId, profileData, sectionName);

                mapWithObjectIds.put(objectName, objectId);


        }


            mapWithObjectIds.put('PartyProfile', profileData.Id);


        return mapWithObjectIds;
    }

    private static String queryObjectId(String objectName, String parentId, PartyProfile profileData, String sectionName) {
        switch on objectName {
            when 'Account' {
                return queryAccount(parentId);
            }
            when 'ContactPointPhone' {
                return queryContactPointPhone(parentId);
            }
            when 'ContactPointEmail' {
                return queryContactPointEmail(parentId);
            }

            when 'PartyProfileAddress' {
                return queryPartyProfileAddress(profileData, sectionName);
            }
            when 'IdentityDocument' {
                return queryIdentityDocument(parentId);
            }
            when 'Applicant' {
                return queryApplicant(parentId);
            }
            when else {
                return null;
            }
        }
    }


    private static PartyProfile queryPartyProfile(String parentId) {
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        return selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
    }

    private static String queryAccount(String parentId) {
        SEL_Account selectorAccountInfo = new SEL_Account();
        Account accData = selectorAccountInfo.selectById(parentId);
        return accData.id;
    }

    private static String queryContactPointPhone(String parentId) {
        SEL_ContactPointPhone selectorContactPoint = new SEL_ContactPointPhone();
        List<ContactPointPhone> phoneDataList = selectorContactPoint.selectByParentId(parentId);
        return String.join(new List<Id>(new Map<Id, ContactPointPhone>(phoneDataList).keySet()), ':');
    }

    private static String queryContactPointEmail(String parentId) {
        SEL_ContactPointEmail selectorContactEmail = new SEL_ContactPointEmail();
        ContactPointEmail emailData = selectorContactEmail.selectByParentId(parentId);
        return emailData.id;
    }

    private static String queryPartyProfileAddress(PartyProfile profileData, String sectionName) {
        SEL_PartyProfileAddress selectorPartyProfileAddress = new SEL_PartyProfileAddress();
        List<PartyProfileAddress> addressList;

        if (sectionName == 'Current Residential Address') {
            addressList = selectorPartyProfileAddress.selectCurrentAddressByPartyProfileId(profileData.id);
        } else if (sectionName == 'Previous Residential Address') {
            addressList = selectorPartyProfileAddress.selectPreviousAddressByPartyProfileId(profileData.id);
        } else {
            addressList = selectorPartyProfileAddress.selectByPartyProfileType(profileData.id, 'Correspondence Address');
        }

        return String.join(new List<Id>(new Map<Id, PartyProfileAddress>(addressList).keySet()), ':');
    }

    private static String queryIdentityDocument(String parentId) {
        SEL_IdentityDocument selectorIdentityDocument = new SEL_IdentityDocument();
        List<IdentityDocument> identityDocList = selectorIdentityDocument.selectByAccountId(parentId);
        return String.join(new List<Id>(new Map<Id, IdentityDocument>(identityDocList).keySet()), ':');
    }

    private static String queryApplicant(String parentId) {
        List<Applicant> applicantData = [SELECT Id FROM Applicant WHERE AccountId = :parentId];
        return String.join(new List<Id>(new Map<Id, Applicant>(applicantData).keySet()), ':');
    }

    /**
* @description To fetch fields for the specified screen name and section name.
* @param screenName The name of the screen.
* @param sectionName The name of the section.
* @return List of AOB_Field__c records representing the fields for the specified screen and section.
*/
    Public static List<AOB_Field__c> fetchAobFields(string screenName,string sectionName){
        ICS_CTRL_PreAppFormCreator.fetchScreenFields(screenName);

        List<String>   screenNamesList = new List<string>();
        List<AOB_Field__c> screenFieldList = new List<AOB_Field__c>();
        Set<Id> sectionIds=new Set<Id>();
        screenNamesList.add(screenName);
        for(AOB_ScreenSection__c  section : new SEL_AOBSection().selectSectionsByScreenNameList(screenNamesList)){
            if(section.Name == sectionName ){
                sectionIds.add(section.id);
            }
        }


        for(AOB_Field__c fieldData:new SEL_AOBField().selectFieldsBySection(sectionIds)){

            if(fieldData.AOB_SFField__c !=null || fieldData.AOB_SFObject__c == 'Assessment'){
                screenFieldList.add(fieldData);
            }
        }
        return screenFieldList;
    }

    /**
* @description To fetch dynamic data based on the provided parent ID, screen name, and section name.
* @param parentId The ID of the parent record.
* @param screenName The name of the screen.
* @param sectionName The name of the section.
* @return A string containing the fetched dynamic data.
*/
    public static String fetchDynamicData(String parentId, String screenName, String sectionName, String type) {

        List<AOB_Field__c> screenFieldList = fetchAobFields(screenName, sectionName);
        processScreenFields(screenFieldList, objectWithFieldAPINames, tableFieldMap, quetionWithScreenNameSet, tableScreenFields, type, sectionName);


        List<String> singleJSON = processRegularFields(parentId, objectWithFieldAPINames, quetionWithScreenNameSet, sectionName);

        List<String> tableJSON = processTableFields(parentId, tableFieldMap, sectionName, tableScreenFields);
        return combineJSONResults(singleJSON, tableJSON);
    }

    private static void processScreenFields(List<AOB_Field__c> screenFieldList,
                                            Map<String, List<AOB_Field__c>> objectWithFieldAPINames,
                                            Map<String, List<AOB_Field__c>> tableFieldMap,
                                            Map<String, String> quetionWithScreenNameSet,
                                            Set<String> tableScreenFields,
                                            String type,
                                            String sectionName) {

                                                for (AOB_Field__c field : screenFieldList) {
                                                    if (isValidField(field)) {
                                                        processField(field, objectWithFieldAPINames, tableFieldMap, tableScreenFields, type, sectionName);


                                                    } else if (sectionName == 'Previous Employment Details' || sectionName == 'Applicant\'s Previous Employment Details' ) {
                                                        addPreviousEmploymentDetails(quetionWithScreenNameSet);
                                                    } else {
                                                        processQuestionField(field, quetionWithScreenNameSet, type);
                                                    }
                                                }
                                            }

    private static boolean isValidField(AOB_Field__c field) {
        if (field.AOB_SFObject__c == null) {
            return false;
        }

        if (field.AOB_SFObject__c.equals(ICS_Constants.ASSESSMENTTEXT)) {
            return false;
        }

        String fieldType = field.AOB_Type__c;
        List<String> invalidTypes = new List<String>{'Lookup', 'Empty', 'MasterDetail'};

        return !invalidTypes.contains(fieldType);
    }

    private static void processField(AOB_Field__c field,
                                     Map<String, List<AOB_Field__c>> objectWithFieldAPINames,
                                     Map<String, List<AOB_Field__c>> tableFieldMap,
                                     Set<String> tableScreenFields,
                                     String type,
                                     String sectionName) {

                                          if (field.AOB_SFObject__c.contains('table:')) {
                                             processTableField(field, tableFieldMap, tableScreenFields);
                                         }
                                         else if (type != 'TableData' || sectionName.contains('Previous') || sectionName == 'Other Business Interests') {
                                             addToMap(objectWithFieldAPINames, field.AOB_SFObject__c, field);

                                         }

                                     }

    private static void addToMap(Map<String, List<AOB_Field__c>> lookupMap, String key, AOB_Field__c value) {
        if (lookupMap.containsKey(key)) {
            lookupMap.get(key).add(value);

        } else {
            lookupMap.put(key, new List<AOB_Field__c>{value});
        }
    }

    private static void processTableField(AOB_Field__c field,
                                          Map<String, List<AOB_Field__c>> tableFieldMap,
                                          Set<String> tableScreenFields) {
                                              field.AOB_SFObject__c = field.AOB_SFObject__c.split(':')[1];
                                              addToMap(tableFieldMap, field.AOB_SFObject__c, field);
                                              tableScreenFields.add(field.Name);

                                          }
	@TestVisible
    private static void addPreviousEmploymentDetails(Map<String, String> quetionWithScreenNameSet) {
        quetionWithScreenNameSet.put('Bonuses/Commissions received per annumCurrency', 'Bonuses/Commissions received per annumCurrency');
        quetionWithScreenNameSet.put('Gross Annual SalaryCurrency', 'Gross Annual SalaryCurrency');
    }

    private static void processQuestionField(AOB_Field__c field,
                                             Map<String, String> quetionWithScreenNameSet,
                                             String type) {
                                                 if (field.AOB_Label__c != null && field.AOB_SFObject__c != null && type != 'TableData') {
                                                 	String key = field.AOB_Label__c;
                                                    if (field.AOB_Label__c.equals(field.Name)) {
                                                        key = field.Name;
                                                    }
                                                    quetionWithScreenNameSet.put(key, field.Name);
                                                 }
                                             }

    private static List<String> processRegularFields(String parentId,
                                                     Map<String, List<AOB_Field__c>> objectWithFieldAPINames,
                                                     Map<String, String> quetionWithScreenNameSet,
                                                     String sectionName) {
                                                         if (objectWithFieldAPINames.keySet().isEmpty() && quetionWithScreenNameSet.keySet().isEmpty()) {
                                                             return new List<String>();
                                                         }
                                                         List<SObject> objectInfoMap = queryData(parentId, objectWithFieldAPINames.keySet(), sectionName);
                                                         return ICS_CTRL_PrepareJSON.prepareJSON(objectInfoMap, objectWithFieldAPINames, quetionWithScreenNameSet, parentId, sectionName, new Set<String>());
                                                     }

    private static List<String> processTableFields(String parentId,
                                                   Map<String, List<AOB_Field__c>> tableFieldMap,
                                                   String sectionName,
                                                   Set<String> tableScreenFields) {
                                                       if (tableFieldMap.keySet().isEmpty()) {
                                                           return new List<String>();
                                                       }
                                                       List<SObject> objectInfoMap = queryData(parentId, tableFieldMap.keySet(), sectionName);
                                                       return ICS_CTRL_PrepareJSON.prepareJSON(objectInfoMap, tableFieldMap, new Map<String, String>(), parentId, sectionName, tableScreenFields);
                                                   }

    private static String combineJSONResults(List<String> singleJSON, List<String> tableJSON) {


        if (tableJSON.isEmpty()) {
            return '[' + String.join(singleJSON, ',') + ']';
        } else if (singleJSON.isEmpty()) {
            return '[' + String.join(tableJSON, ',') + ']';
        } else {
            return '[' + String.join(singleJSON, ',') + ',' + String.join(tableJSON, ',') + ']';
        }
    }

    /**
* @description To check if the applicant associated with the provided parent ID is a joint applicant or not.
* @param parentId The ID of the parent record.
* @return JSON string indicating whether the applicant is a joint applicant and if they are primary.
*/
    @AuraEnabled
    Public static string checkisJoint(string parentId){
        string isJoint='false';
        string isPrimary='false';
        String jsonString ='';
        try{
        Applicant appData = [select id,role from applicant where accountid=:parentId ];
        if(appData == null){
            isJoint = 'false';
            isPrimary ='false';
        }
        if(appData.role =='Primary Applicant' ){
            isJoint = 'true';
            isPrimary ='true';
        }
        if(appData.role =='Co-Applicant'){
            isJoint = 'true';
            isPrimary ='false';
        }
        if(appData.role =='Guarantor'){
            isJoint = 'false';
            isPrimary ='false';
        }

        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('isPrimary',isPrimary );
        jsonGen.writeStringField('isJoint', isJoint);

        jsonGen.writeEndObject();

        // Get the JSON string
       jsonString = jsonGen.getAsString();
        }catch(exception exc){
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getmessage());
        }
        return jsonString;
    }

    /**
* @description To fetch assessment question response data for the specified set of questions, parent ID, and section name.
* @param questionSet Set of question identifiers.
* @param parentId The ID of the parent record.
* @param sectionName The name of the section.
* @return Map containing assessment question response data with question text as the key.
*/
    @AuraEnabled
    public static Map<string,AssessmentQuestionResponse> fetchQuetsionReposneData(string parentId,
                                                                                  string sectionName){

                                                                                      Map<string,AssessmentQuestionResponse> responseQuestionsMap = new Map<string,AssessmentQuestionResponse>();
                                                                                      try{
                                                                                          string sName='';
                                                                                          if(sectionName.contains(':')){
                                                                                              sName = sectionName.split(':')[0];
                                                                                          }
                                                                                          
                                                                                          if(responseAssessmentMap.containskey(sectionName)||responseAssessmentMap.containskey(sName)){
                                                                                              List<AssessmentQuestionResponse>responseList = new List<AssessmentQuestionResponse>();
                                                                                              if(responseAssessmentMap.containskey(sectionName)){
                                                                                                  responseList =   responseAssessmentMap.get(sectionName);
                                                                                              }
                                                                                              if( responseAssessmentMap.containskey(sName) ){
                                                                                                  responseList.addall(responseAssessmentMap.get(sName));
                                                                                              }
                                                                                              for(AssessmentQuestionResponse response: responseList){
                                                                                                  responseQuestionsMap.put(response.AssessmentQuestion.Name,response);
                                                                                              }
                                                                                          }
                                                                                      }catch(exception exc){
                                                                                          LOGGER.error(exc.getmessage());
                                                                                          throw new AuraHandledException(exc.getmessage());
                                                                                      }
                                                                                      return responseQuestionsMap;
                                                                                  }
    /**
* @description To fetch assessment question response data for the specified set of questions, parent ID, and section name.
* @param questionSet Set of question identifiers.
* @param parentId The ID of the parent record.
* @param sectionName The name of the section.
* @return Map containing assessment question response data with question text as the key.
*/
    @AuraEnabled
    public static List<AssessmentQuestionResponse> fetchQuetsionReposneDataWithAccountId(string parentId,
                                                                                         string sectionName){
                                                                                             list<AssessmentQuestionResponse>  responseData= new  list<AssessmentQuestionResponse>();
                                                                                             SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
                                                                                             list<AssessmentQuestionResponse>  finalData = new  list<AssessmentQuestionResponse>();
                                                                                             try{
                                                                                             responseData = selectorAssessmentqueResponse.selectByParentId(parentId);

                                                                                             for(AssessmentQuestionResponse responseNameData: responseData){
                                                                                                 if(responseNameData.Name.contains(sectionName)){
                                                                                                     finalData.add(responseNameData);
                                                                                                 }
                                                                                             }
                                                                                             }catch(exception exc){
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getmessage());
        }
                                                                                             return finalData;

                                                                                         }


    /**
* @description To calculate the difference between two dates in days and returns the result as a string.
* @param startDate The starting date.
* @param endDate The ending date.
* @return String representation of the difference between the start and end dates in days.
*/
    public static string checkDateDifference(Date startDate, Date endDate ){
        if(startDate == null ){
            return '';
        }
        else{
            if(endDate ==null){
                endDate =date.today();
            }
            Integer monthsBetween = startDate.monthsBetween(endDate);
            return monthsBetween/12 + ' Years and '+Math.mod(monthsBetween,12)+' Months';
        }
    }
}