/***************************************************************************************
@name of the Class : ICS_CTRL_FecthOnboardingDetailsAI.cls
@description : used as controller for  prepoulate data in assets and income section
@author : Ikyatha Naidu
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: Updated to latest version
***************************************************************************************/
public withOUT sharing class ICS_CTRL_FecthOnboardingDetailsAI  {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_FecthOnboardingDetailsAI');
	Public static List<string> assetList = new List<string>();
    Public static List<AssessmentQuestionResponse> responseList = new List<AssessmentQuestionResponse>();
    /**
* @description Method to get record of Party Assets fund grouped by party profileId
* @param String parentId
* @param Set<String> objectNameList
* @param String sectionName
* @param List<String> typeList
* @return List<sObject>
*/
    Public static List<sObject> queryData(string parentId,set<string> objectNameList,
                                          string sectionName,List<string>typeList){
                                              LOGGER.info('Querying data for parentId: {0}, sectionName: {1}', new Object[]{parentId, sectionName});
                                              List<sObject> objectInfoList =new  List<sObject>();
                                              SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
                                              SEL_PartyAssetFunds selectorPartyAssetFunds = new SEL_PartyAssetFunds();
                                              PartyProfile profileData =new PartyProfile();
                                              profileData =selectorPartyProfile.selectByAccountAndRecordType(parentId,ICS_Constants.SBO_RECNAME);
                                              String TypeListString = String.join(typeList, ':');
                                              TypeListString = TypeListString.replace('Other' , 'Other');
                                              typeList = TypeListString.split(':');
                                              List<sobject>  assetOwnerFunds= selectorPartyAssetFunds.selectAssetFundsByRecordType(profileData.id,typeList,sectionName);
                                              objectInfoList.addall(assetOwnerFunds);
                                              return objectInfoList;
                                          }

    /**
* @description Method to get record of Assessments Quetsion response  grouped by AccountId
* @param String parentId
* @param String sectionName
* @param String screenName
* @return String
*/
    @AuraEnabled
    public static string fetchAssestListedFunds(string parentId,string screenName,string sectionName){
        LOGGER.info('Fetching asset listed funds for parentId: {0}, screenName: {1}, sectionName: {2}', new Object[]{parentId, screenName, sectionName});

         string returnResponse='';
        Map<String, Object>jsonMap =new Map<String, Object>();
        try{
        SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
        responseList = selectorAssessmentqueResponse.selectByParentIdAndSectionName(parentId,'Assets and Income');

        List<string> fundList = new List<string>();


        for(AssessmentQuestionResponse response: responseList){
            if(response.AssessmentQuestion.QuestionText == 'Select all funds assets and income*'){
                jsonMap.put('Select multi combobox of assests', response.ResponseText);
                jsonMap.put('Select multi combobox of assests:Id', response.Id);
                if(response.ResponseText != null && response.ResponseText.contains(';')){
                    fundList.addall(response.ResponseText.split(';'));
                    for(string fundKey : response.ResponseText.split(';')){
						 assetList.add(fundKey+'V');                        
                    }
                }else if(response.ResponseText != null){
                    fundList.add(response.ResponseText);
                     assetList.add(response.ResponseText+'V');
                }
            }
        }

        if(fundList.size() >0){
            
            returnResponse= fetchDynamicData(parentId,screenName,sectionName,fundList);
        }
        }catch(exception exc){
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getmessage());
        }
        return returnResponse;
    }

    /**
* @description Method to get record of Assessments Quetsion response dynamically  grouped by AccountId
* @param String parentId
* @param String sectionName
* @param String screenName
* @param List<String> typeList

* @return String
*/
    public static String fetchDynamicData(String parentId, String screenName, String sectionName, List<String> typeList) {
        LOGGER.info('Fetching dynamic data for parentId: {0}, screenName: {1}, sectionName: {2}', new Object[]{parentId, screenName, sectionName});

        Map<String, Object> jsonMap = new Map<String, Object>();
        List<String> wealthList = new List<String>();
        List<String> fundList = new List<String>();

        processAssessmentResponses(parentId, jsonMap, wealthList, fundList, typeList);

        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = processScreenFields(screenName, sectionName);
        Map<String, String> questionWithScreenNameSet = extractQuestionMap(objectWithFieldAPINames);

        List<SObject> objectInfoMap = queryAssetFunds(parentId, objectWithFieldAPINames.keySet(), wealthList, fundList);
        Map<String, List<SObject>> objectInfoMapByKey = groupObjectInfoByKey(objectInfoMap);

        return prepareJsonResponse(objectInfoMapByKey, objectWithFieldAPINames, questionWithScreenNameSet, parentId, sectionName, jsonMap);
    }

    private static void processAssessmentResponses(String parentId, Map<String, Object> jsonMap, List<String> wealthList, List<String> fundList, List<String> typeList) {
        if (typeList == null) {
            SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
            List<AssessmentQuestionResponse> responseList = selectorAssessmentqueResponse.selectByParentIdAndSectionName(parentId, 'Assets and Income');

            for (AssessmentQuestionResponse response : responseList) {
                processResponse(response, jsonMap, wealthList, fundList);
            }
        } else {
            fundList.addAll(typeList);
        }
    }

    private static void processResponse(AssessmentQuestionResponse response, Map<String, Object> jsonMap, List<String> wealthList, List<String> fundList) {
        String questionText = response.AssessmentQuestion.QuestionText;
        if (questionText == 'Select years*') {
            jsonMap.put('Select combobox', response.ResponseText);
            jsonMap.put('Select combobox:Id', response.Id);
        } else if (questionText == 'Select all assets and income*') {
            for(string wealthKey : response.ResponseText.split(';')){
                 assetList.add(wealthKey+'W');
            }
           
            processMultiSelectResponse(response, jsonMap, wealthList, 'Select multi combobox');
        } else if (questionText == 'Select all funds assets and income*') {
            for(string wealthKey : response.ResponseText.split(';')){
                 assetList.add(wealthKey+'V');
            }
            processMultiSelectResponse(response, jsonMap, fundList, 'Select multi combobox of assests');
        }else if (questionText == 'Same details as current employer') {
            jsonMap.put('Same details as current employer', response.ResponseText);
            jsonMap.put('Same details as current employer', response.Id);
        }
    }

    private static void processMultiSelectResponse(AssessmentQuestionResponse response, Map<String, Object> jsonMap, List<String> responseList, String key) {
        jsonMap.put(key, response.ResponseText);
        
        
        jsonMap.put(key + ':Id', response.Id);
        responseList.addAll(response.ResponseText.contains(';') ? response.ResponseText.split(';') : new List<String>{response.ResponseText});
    }

    private static Map<String, List<AOB_Field__c>> processScreenFields(String screenName, String sectionName) {
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
        if (String.isNotBlank(screenName) && String.isNotBlank(sectionName)) {
          List<AOB_Field__c> screenFieldList = new SEL_AOBField().selectMRITablesByParentNames(assetList, sectionName);
          Map<Id,AOB_Field__c> screenFieldMap = new Map<Id,AOB_Field__c>(screenFieldList);
          List<AOB_Field__c> childFields = new SEL_AOBField().selectFieldsByParentIds(screenFieldMap.keySet());
          if(!childFields.isEmpty() || test.isrunningtest()) {
            screenFieldList.addAll(childFields);
        }
       

        for (AOB_Field__c field : screenFieldList) {
            if (isValidField(field)) {
                addToMap(objectWithFieldAPINames, field.AOB_SFObject__c, field);
            }
        }

       
    }
    return objectWithFieldAPINames;
    }
@testVisible
    private static boolean isValidField(AOB_Field__c field) {
        if (field.AOB_SFObject__c == null) {
            return false;
        }
        if (field.AOB_SFObject__c.equals(ICS_Constants.ASSESSMENTTEXT)) {
            return false;
        }

        Set<String> invalidTypes = new Set<String>{'Lookup', 'Empty', 'MasterDetail'};

        return !invalidTypes.contains(field.AOB_Type__c);
    }

    private static void addToMap(Map<String, List<AOB_Field__c>> lookupMap, String key, AOB_Field__c value) {
        if (lookupMap.containsKey(key)) {

            lookupMap.get(key).add(value);
        } else {
            lookupMap.put(key, new List<AOB_Field__c>{value});
        }
    }

    private static Map<String, String> extractQuestionMap(Map<String, List<AOB_Field__c>> objectWithFieldAPINames) {
        Map<String, String> questionMap = new Map<String, String>();
        for (List<AOB_Field__c> fields : objectWithFieldAPINames.values()) {
            for (AOB_Field__c field : fields) {
                if(field.AOB_Label__c == null && field.AOB_SFObject__c == null){  continue;}
                else  {
                    if(field.AOB_Label__c == field.Name){ questionMap.put(field.Name,field.Name);
              }else{questionMap.put(field.AOB_Label__c,field.Name);}
                }
            }
        }
        return questionMap;
    }

    private static List<SObject> queryAssetFunds(String parentId, Set<String> objectTypes, List<String> wealthList, List<String> fundList) {
        List<SObject> objectInfoMap = new List<SObject>();
        if (!wealthList.isEmpty()) {
            objectInfoMap.addAll(queryData(parentId, objectTypes, 'Wealth', wealthList));
        }
        if (!fundList.isEmpty()) {
            objectInfoMap.addAll(queryData(parentId, objectTypes, 'Funds', fundList));
        }
        return objectInfoMap;
    }

    private static Map<String, List<SObject>> groupObjectInfoByKey(List<SObject> objectInfoMap) {
        Map<String, List<SObject>> objectInfoMapByKey = new Map<String, List<SObject>>();
        for (SObject objData : objectInfoMap) {
            Party_Assets_Funds__c assetFund = (Party_Assets_Funds__c)objData;
            String typeValue = assetFund.Type__c == 'Other' ? 'Other':assetFund.Type__c;
            String key = typeValue + ':' + (assetFund.recordtype.Name == 'Source of Funds' ? 'Funds' : 'Wealth');

            if (objectInfoMapByKey.containsKey(key)) {
                objectInfoMapByKey.get(key).add(objData);
            } else {
                 objectInfoMapByKey.put(key, new List<SObject>{objData});
            }
        }
        return objectInfoMapByKey;
    }
    @AuraEnabled
    public static string fetchAdditionalBussinessOwners(string assetId){
        try {
        sel_partyprofile profileSelector= new sel_partyprofile();
        List<partyprofile> profileList= profileSelector.selectByPartyAssetFund(assetId);
        List<Object> jsonArray = new List<Object>();
        if(assetId != '' && assetId != null){
        
            for(partyprofile pData : profileList ){
                jsonArray.add(generateOwnershipJson(pData,assetId));
            }
         }
         return JSON.serialize(jsonArray);
    }catch(exception e) {
        LOGGER.error(e.getmessage());
        throw new AuraHandledException(e.getmessage());
    }
    }
    public static  Map<String, Object> generateOwnershipJson(PartyProfile profile,string assetId) {
        Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('Id', profile.Id);
        // Basic Profile Information
        jsonMap.put('First Name', profile.FirstName);
        jsonMap.put('Middle Name', profile.MiddleName);
        jsonMap.put('Surname', profile.LastName);
        jsonMap.put('Title', profile.Person_Title__c);
        jsonMap.put('PartyProfileId', assetId);
        
        // Format date of birth
        if(profile.Birthdate__c != null) {
            String formattedDate = profile.Birthdate__c.year() + '-' + 
                String.valueOf(profile.Birthdate__c.month()).leftPad(2, '0') + '-' + 
                String.valueOf(profile.Birthdate__c.day()).leftPad(2, '0');
            jsonMap.put('Date of birth', formattedDate);
        }
        
        jsonMap.put('Gender', profile.Gender);
        
        // Location Information
        jsonMap.put('Town/City of Birth', profile.Town_City_of_Birth__c);
        jsonMap.put('Country of Birth', profile.CountryofBirth);
        jsonMap.put('Primary Country of Nationality', profile.Country_of_Nationality__c);
        jsonMap.put('Secondary Country of Nationality', profile.Second_Country_of_Nationality__c);
        // Marital Status
        if(profile.WI_MaritialStatus__c != null) {
            Map<String, String> reverseMaritalStatusMap = new Map<String, String>();
            for(String key : ICS_CTRL_FetchTrustDataProcessor.getMaritalStatusMap().keySet()) {
                reverseMaritalStatusMap.put(
                    ICS_CTRL_FetchTrustDataProcessor.getMaritalStatusMap().get(key), 
                    key
                );
                
            }
            String MaritalStatusUpperCase = profile.WI_MaritialStatus__c.toUpperCase();
            jsonMap.put('Marital Status', reverseMaritalStatusMap.get(MaritalStatusUpperCase));
        }
        
        // Former/Maiden Name Logic
        String formerMaidenStatus = determineFormerMaidenStatus(profile);
        jsonMap.put('Former Name or Maiden NameFFF', formerMaidenStatus);
        
        // Other Names Logic
        if(profile.Has_different_First_Middle_Family_Name__c != null) {
            List<String> otherNamesList = new List<String>();
            Map<String, String> nameFieldMap = new Map<String, String>{
                'Different_First_Name__c' => 'OtherFirstName',
                    'Different_Middle_Name__c' => 'OtherMiddleName',
                    'Different_Last_Name__c' => 'OtherSurname'
                    };

                        for (String field : nameFieldMap.keySet()) {
                            if (String.isNotBlank((String)profile.get(field))) {
                                otherNamesList.add(nameFieldMap.get(field));
                            }
    
                        }

            jsonMap.put('Other NameFFF', otherNamesList.isEmpty() ? 'None' : String.join(otherNamesList, ';'));
        }
        // Names Details
        jsonMap.put('Former Name', profile.Former_Name__c);
        jsonMap.put('Maiden Name', profile.Maiden_Name__c);
        jsonMap.put('Other First Name', profile.Different_First_Name__c);
        jsonMap.put('Other Middle Name', profile.Different_Middle_Name__c);
        jsonMap.put('Other Surname', profile.Different_Last_Name__c);
        
        // Business Information
        if(profile.Percentage_of_Business__c != null) {
            jsonMap.put('Percentage of the business owned', profile.Percentage_of_Business__c);
        }
        return jsonMap;
    }
    
    private static String determineFormerMaidenStatus(PartyProfile profile) {
        Boolean hasFormerName = profile.Has_Former_Name__c == 'Yes';
        Boolean hasMaidenName = profile.Maiden_Name__c == 'Yes';
        
        if(hasFormerName && hasMaidenName) {
             return 'FormerAndMaiden';
        }
        if(hasFormerName && !hasMaidenName) {
            return 'FormerName';
        }
        if(hasMaidenName && !hasFormerName) {
        return 'MaidenName';
        }
        if(!hasMaidenName && !hasFormerName) {
            return 'None';
        }
        return null;
    }
    

    private static String prepareJsonResponse(Map<String, List<SObject>> objectInfoMapByKey, Map<String, List<AOB_Field__c>> objectWithFieldAPINames,
                                              Map<String, String> questionWithScreenNameSet, String parentId, String sectionName, Map<String, Object> jsonMap) {
                                                  Map<String, Object> mergedMap = new Map<String, Object>(jsonMap);
                                                  for (String typeKey : objectInfoMapByKey.keySet()) {
                                                      String category = typeKey.split(':')[1];
                                                      String typeName = typeKey.split(':')[0] + (category == 'Wealth' ? 'W' : 'V');

                                                      List<String> singleJSON = ICS_CTRL_PrepareJSON.prepareJSON(objectInfoMapByKey.get(typeKey), objectWithFieldAPINames,
                                                                                                                 questionWithScreenNameSet, parentId, sectionName, new Set<String>());
                                                      String jsonResponse = '[' + String.join(singleJSON, ',') + ']';
                                                      mergedMap.put('"' + typeName + '"', (Object)jsonResponse);
                                                  }
                                                  mergedMap.put('objectName', 'Party_asset_Funds__c');

                                                  String normalJsonString = JSON.serialize(mergedMap).replace('\\', '').replace('""', '\"').replace('"[', '[').replace(']"', ']');
                                                  return '[' + normalJsonString + ']';
                                              }

}