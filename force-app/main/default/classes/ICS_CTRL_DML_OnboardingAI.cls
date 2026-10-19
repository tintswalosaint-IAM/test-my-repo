/***************************************************************************************
* @name : ICS_CTRL_DML_OnboardingAI
* @description : Controller class for inserting Assets and Income section in ApplicationForm
* This class handles the processing of onboarding data, including parsing JSON,
* processing question responses, and inserting/updating various SObjects related to
* assets and income.
* @Story : SFP-30236
* @author : Ikyatha Naidu
* @date : 10/03/2024
* @last modified on : 20-04-2025
* @last modified by : Ikyatha Naidu
* @Modification Description : Updated to latest version, added logging, and refactored for better maintainability
***************************************************************************************/
public without sharing class ICS_CTRL_DML_OnboardingAI {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_DML_OnboardingAI');

    public static Map<String,List<String>> lookupFields = new Map<String,List<String>>();
    public static Map<String,String> linkedMap = new Map<String,String>();
    public static Map<String,AssessmentQuestionResponse> responseDataMap = new Map<String,AssessmentQuestionResponse>();
    public static Map<String,String> questionsResponseMap = new Map<String,String>();
    public static Map<String,List<AOB_Field__c>> objectWithFieldAPINames = new Map<String,List<AOB_Field__c>>();
    public static Map<String,Map<String,List<AOB_Field__c>>> objectWithFieldAPIWealthNames = new Map<String,Map<String,List<AOB_Field__c>>>();
    public static Map<String,List<AOB_Field__c>> tableFieldMap = new Map<String,List<AOB_Field__c>>();
    public static Map<String, Object> sectionFieldData = new Map<String, Object>();
    public static Map<String,String> identityDocuData = new Map<String,String>();
    public static Map<String,String> assessmentQuestionResponse = new Map<String,String>();
    public static Map<String,String> countryCodeMap = new Map<String,String>();
    public static List<SObject> insertSObjList = new List<SObject>();
    public static List<AOB_Field__c> assessObjList = new List<AOB_Field__c>();
    public static List<SObject> updateSObjList = new List<SObject>();
    public static Map<String,String> masterDetailMap = new Map<String,String>();
    public static List<CurrencyType> currencyTypes = new List<CurrencyType>();
    public static String wealthDetailsAmount = '';
    public static Account accountInfo;
	Public static map<integer,List<Object>> additionalOwnersMap = new map<integer,List<Object>>();
    
    private ICS_CTRL_DML_OnboardingAI(){

    }

    /**
     * @description Main method to process onboarding data
     * @param jsonString The JSON data to process
     * @param screenName Name of the screen
     * @param sectionName Name of the section
     * @param parentId Parent record ID
     * @param assessmentScreenData List of assessment screen fields
     */
    public static void processData(String jsonString, String screenName, String sectionName, String parentId, List<AOB_Field__c> assessmentScreenData) {
        LOGGER.info('Processing data for section: {0}', new Object[]{sectionName});
        if(String.isNotBlank(jsonString)) {
            parseJSON(jsonString, sectionName, parentId, assessmentScreenData);
        } else {
            LOGGER.warn('Empty JSON string provided for processing');
        }
    }

    /**
     * @description Parses JSON and initiates processing
     */
    public static void parseJSON(String jsonData, String sectionName, String parentId, List<AOB_Field__c> assessmentScreenData) {
        try {
            Map<String, Object> jsonDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
            sectionFieldData = jsonDataMap;
            checkRecords(jsonDataMap,parentId);
            SEL_Account accSelector = new SEL_Account();
            accountInfo = accSelector.selectById(parentId);     
            List<String> wealthList = new List<String>();
            Set<String> objectList = new Set<String>();
            Set<String> objectFieldList = new Set<String>();
            List<AssessmentQuestionResponse> responseData = new List<AssessmentQuestionResponse>();
            Map<String,List<Object>> wealthJSONMap = new Map<String,List<Object>>();

            Map<String,AssessmentQuestionResponse> assResponseMap = getAssessmentResponseMap(parentId);
            Map<String,String> questionMap = getQuestionMap();
            currencyTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType LIMIT 500];

            processQuestionResponses(jsonDataMap, questionMap, assResponseMap, responseData, wealthList, parentId);
            if(!responseData.isEmpty() && !Test.isRunningTest()) {
                upsert responseData;
            }

            processWealthData(jsonDataMap, wealthList, wealthJSONMap);

            if(!wealthList.isEmpty()) {
                processScreenFields(sectionName, wealthList, objectList, objectFieldList, assessmentScreenData);
                linkedMap = ICS_CTRL_FecthOnboardingDetails.queryDataWithObject(parentId, objectList, sectionName);

                for(String wealthKey : wealthList) {
                    if(objectWithFieldAPINames.containsKey(wealthKey) && wealthJSONMap.containsKey(wealthKey)) {
                        wealthDetailsAmount = '';
                        insertData(parentId, wealthKey, wealthJSONMap.get(wealthKey),
                        objectWithFieldAPINames.get(wealthKey), objectFieldList, sectionName);
                    }
                }
            }
        } catch(Exception e) {
            LOGGER.error('Error in parseJSON: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new CustomException('Error processing data: ' + e.getMessage(),e);
        }
    }

    /**
     * @description delete records
     */

        private static void checkRecords(Map<String, Object> jsonDataMap, String parentId) {
            processAssets(jsonDataMap, parentId, 'Select multi combobox of assests', 'Select all funds assets and income*', 'Source of Funds');
            processAssets(jsonDataMap, parentId, 'Select multi combobox', 'Select all assets and income*', 'Wealth in Country');
        }
    
        private static void processAssets(Map<String, Object> jsonDataMap, String parentId, String comboboxKey, String assessmentName, String assetType) {
            String selectedAssets = (String) jsonDataMap.get(comboboxKey);
            if (String.isEmpty(selectedAssets)) {
                return;
            }
            String responseValue = getResponseValue(parentId, assessmentName);
            if (String.isEmpty(responseValue)) {
                return;
            }

            List<String> selectedAssetsList = selectedAssets.split(';');
            List<String> responseValueList = responseValue.split(';');
            Set<String> selectValueSet = new Set<String>(selectedAssetsList);
            List<String> missingAssets = new List<String>();
            for (String asset : responseValueList) {
                if (!selectValueSet.contains(asset)) {
                    missingAssets.add(asset);
                }
            }
            if (!missingAssets.isEmpty()) {
                deletePartyAssets(parentId, missingAssets, assetType);
            } 
        }
    
        private static String getResponseValue(String accountId, String assessmentName) {
            SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
            List<AssessmentQuestionResponse> responseList = selectorAssessmentqueResponse.selectByAccountIdAndAssessmentName(accountId, assessmentName);
    
            if (responseList == null || responseList.isEmpty()) {
                return '';
            }
            Map<String, AssessmentQuestionResponse> assResponseMap = new Map<String, AssessmentQuestionResponse>();
            for (AssessmentQuestionResponse responseInfo : responseList) {
                assResponseMap.put(responseInfo.AssessmentQuestion.Name, responseInfo);
            }
    
            return assResponseMap?.get(assessmentName)?.ResponseText ?? '';
        }
    
        private static void deletePartyAssets(String parentId, List<String> missingAssets, String assetType) {
            SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
            PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
            SEL_PartyAssetFunds selectorPartyAssetFunds = new SEL_PartyAssetFunds();
            List<Party_Assets_Funds__c> assetsToDelete = selectorPartyAssetFunds.selectByPartyProfileBulkTypewithRecordAssests(profileData.Id, missingAssets, assetType, false);

            if (!assetsToDelete.isEmpty()) {
                delete assetsToDelete;
            } 
        }
    
    
    /**
     * @description Gets assessment response map for a parent ID
     */
    private static Map<String,AssessmentQuestionResponse> getAssessmentResponseMap(String parentId) {
        SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responseList = selectorAssessmentqueResponse.selectByParentIdAndSectionName(parentId,'Assets and Income');
        Map<String,AssessmentQuestionResponse> assResponseMap = new Map<String,AssessmentQuestionResponse>();
        if(responseList != null) {
            for(AssessmentQuestionResponse responseInfo: responseList){
                assResponseMap.put(responseInfo.AssessmentQuestion.Name, responseInfo);
            }
        }
        return assResponseMap;
    }

    /**
     * @description Gets question map
     */
    private static Map<String,String> getQuestionMap() {
        Map<String,String> questionMap = new Map<String,String>();
        for(AssessmentQuestion assQuestion: [SELECT Id, Name, ActiveVersionId, QuestionText
                                           FROM AssessmentQuestion
                                           WHERE Name IN ('Select all assets and income*','Select all funds assets and income*','Select years*')]) {
            questionMap.put(assQuestion.Name, assQuestion.ActiveVersionId);
        }
        return questionMap;
    }

    /**
     * @description Processes question responses
     */
    private static void processQuestionResponses(Map<String, Object> jsonDataMap, Map<String,String> questionMap,
                                               Map<String,AssessmentQuestionResponse> assResponseMap,
                                               List<AssessmentQuestionResponse> responseData, List<String> wealthList,
                                               String parentId) {
        sel_assesment selectorAssInfo = new sel_assesment();
        List<Assessment> assDataList = selectorAssInfo.SelectByAccountId(parentId);

        for(String key : questionMap.keySet()) {
            processQuestionResponse(key, jsonDataMap, assResponseMap, responseData, assDataList, questionMap);
            if(key == 'Select all assets and income*' || key == 'Select all funds assets and income*' || key == 'Same details as current employer') {
                processWealthList(key, jsonDataMap, assResponseMap, wealthList);
            }
        }
    }

    /**
     * @description Processes a single question response
     */
    private static void processQuestionResponse(String key, Map<String, Object> jsonDataMap,
                                              Map<String,AssessmentQuestionResponse> assResponseMap,
                                              List<AssessmentQuestionResponse> responseData,
                                              List<Assessment> assDataList, Map<String,String> questionMap) {
        if(key == 'Select all assets and income*' || key == 'Select all funds assets and income*' || key == 'Select years*' || key == 'Same details as current employer') {
            AssessmentQuestionResponse ass = new AssessmentQuestionResponse();

            if(assResponseMap.containsKey(key)){
                ass.Id = (String)assResponseMap.get(key).Id;
                String question = getQuestionMapping(key);
                if(jsonDataMap.containsKey(question)){
                    ass.ResponseText = (String) jsonDataMap.get(question);
                    responseData.add(ass);
                }
            } else {
                AssessmentQuestionResponse responseInfo = new AssessmentQuestionResponse();
                String question = getQuestionMapping(key);
                if(jsonDataMap.containsKey(question)){
                    responseInfo.ResponseText = (String) jsonDataMap.get(question);
                    responseInfo.AssessmentId = assDataList[0].Id;
                    responseInfo.AssessmentQuestionId = questionMap.get(key);
                    responseInfo.Name = 'Assets and Income';
                    responseData.add(responseInfo);
                }
            }
        }
    }

    /**
     * @description Gets question mapping
     */
    private static String getQuestionMapping(String key) {
        switch on key {
            when 'Select years*' { return 'Select combobox'; }
            when 'Select all assets and income*' { return 'Select multi combobox'; }
             when 'Same details as current employer' { return 'Same details as current employer'; }
            when 'Select all funds assets and income*' { return 'Select multi combobox of assests'; }
            when else { return ''; }
        }
    }

    /**
     * @description Processes wealth list
     */
    private static void processWealthList(String key, Map<String, Object> jsonDataMap,
                                        Map<String,AssessmentQuestionResponse> assResponseMap,
                                        List<String> wealthList) {
        List<String> typeList = new List<String>();
        String question = (key == 'Select all assets and income*') ? 'Select multi combobox' : 'Select multi combobox of assests';

        if(jsonDataMap.containsKey(question)){
            String questionData = (String)jsonDataMap.get(question);
            if(String.isNotBlank(questionData)) {
                typeList.addAll(questionData.split(';'));
            }
        } else if(assResponseMap.containsKey(key)){
            String responseText = assResponseMap.get(key).ResponseText;
            if(String.isNotBlank(responseText)) {
                if(responseText.contains(';')) {
                    typeList.addAll(responseText.split(';'));
                } else {
                    typeList.add(responseText);
                }
            }
        }

        String suffix = (key == 'Select all assets and income*') ? 'W' : 'V';
        for(String asset : typeList) {
            wealthList.add(asset + suffix);
        }
    }

                /**
                 * @description Processes wealth data
                 */
private static void processWealthData(Map<String, Object> jsonDataMap, 
                List<String> wealthList,
                Map<String,List<Object>> wealthJSONMap) {
                try {
                for(String key : wealthList) {
                processWealthKey(key, jsonDataMap, wealthJSONMap);
                }
                } catch(Exception e) {
                LOGGER.error('Error in processWealthData: ' + e.getMessage() + '\n' + e.getStackTraceString());
                throw new CustomException('Error processing wealth data: ' + e.getMessage(), e);
                }
                }

 private static void processWealthKey(String key, 
                Map<String, Object> jsonDataMap,
                Map<String,List<Object>> wealthJSONMap) {
                if (!isValidWealthData(jsonDataMap, key)) {
                return;
                }

                List<Object> objList = (List<Object>)jsonDataMap.get(key);
                wealthJSONMap.put(key, objList);
                processAdditionalOwners(objList);
                }

private static boolean isValidWealthData(Map<String, Object> jsonDataMap, String key) {
                return jsonDataMap.containsKey(key) && 
                jsonDataMap.get(key) instanceof List<Object>;
                }

private static void processAdditionalOwners(List<Object> objList) {
                for(Integer i = 0; i < objList.size(); i++) {
                if (!(objList[i] instanceof Map<String, Object>)) {
                continue;
                }

                Map<String, Object> objMap = (Map<String, Object>)objList[i];
                processOwnersList(objMap, i);
                }
                }

private static void processOwnersList(Map<String, Object> objMap, Integer index) {
                String ownersKey = 'Addtional Business Owners';
                if (!hasValidOwnersList(objMap, ownersKey)) {
                return;
                }

                List<Object> ownersList = (List<Object>)objMap.get(ownersKey);
                if (!ownersList.isEmpty()) {
                additionalOwnersMap.put(index, ownersList);
                }
                }

private static boolean hasValidOwnersList(Map<String, Object> objMap, String ownersKey) {
                return objMap.containsKey(ownersKey) && 
                objMap.get(ownersKey) instanceof List<Object>;
                }

    /**
     * @description Processes screen fields
     */
    private static void processScreenFields(String sectionName, List<String> wealthList, Set<String> objectList,
                                          Set<String> objectFieldList, List<AOB_Field__c> assessmentScreenData) {
        List<AOB_Field__c> screenFieldList = new SEL_AOBField().selectMRITablesByParentNames(wealthList, sectionName);
        Map<Id,AOB_Field__c> screenFieldMap = new Map<Id,AOB_Field__c>(screenFieldList);

        List<AOB_Field__c> childFields = new SEL_AOBField().selectFieldsByParentIds(screenFieldMap.keySet());
                                          
        if(!childFields.isEmpty()) { screenFieldList.addAll(childFields); }

        assessObjList = assessmentScreenData;
        for(AOB_Field__c field : screenFieldList) {
            processScreenField(field, objectList, objectFieldList);
        }
    }

    /**
     * @description Processes a single screen field
     */
    private static void processScreenField(AOB_Field__c field, Set<String> objectList, Set<String> objectFieldList) {
        processObjectAndField(field, objectFieldList);
        processLookupField(field, objectList);
    }

    /**
     * @description Processes object and field
     */
    private static void processObjectAndField(AOB_Field__c field, Set<String> objectFieldList) {
        if(field.AOB_SFObject__c == null || field.AOB_SFField__c == null) {
            return;
        }

        updateObjectWithFieldAPINames(field);
        objectFieldList.add(field.AOB_SFObject__c);
    }

    /**
     * @description Updates object with field API names
     */
    private static void updateObjectWithFieldAPINames(AOB_Field__c field) {
        if(objectWithFieldAPINames.containsKey(field.AOB_Parent__r.Name)) {
            objectWithFieldAPINames.get(field.AOB_Parent__r.Name).add(field);
        } else {
            objectWithFieldAPINames.put(field.AOB_Parent__r.Name, new List<AOB_Field__c>{field});
        }
        updateChildFieldMap(field);
    }

    private static void updateChildFieldMap(AOB_Field__c field) {
        if(field.AOB_Parent__r == null || (field.AOB_Parent__r != null && field.AOB_Parent__r.AOB_Parent__c == null)) {
            return;
        }
        if(objectWithFieldAPINames.containsKey(field.AOB_Parent__r.AOB_Parent__r.Name)) {
            objectWithFieldAPINames.get(field.AOB_Parent__r.AOB_Parent__r.Name).add(field);
        } else {
            objectWithFieldAPINames.put(field.AOB_Parent__r.AOB_Parent__r.Name, new List<AOB_Field__c>{field});
        }
    }

/**
     * @description Processes lookup field
     */
    private static void processLookupField(AOB_Field__c field, Set<String> objectList) {
        if (field.Default_Value__c != null || field.AOB_Type__c != 'Lookup' || field.AOB_SFField__c == null) {
            return;
        }

        updateLookupFields(field);
        objectList.add(field.AOB_SFField__c.split(';')[1]);
    }

    /**
     * @description Updates lookup fields
     */
    private static void updateLookupFields(AOB_Field__c field) {
        if (lookupFields.containsKey(field.AOB_SFObject__c)) {
            if (!lookupFields.get(field.AOB_SFObject__c).contains(field.AOB_SFField__c)) {
                lookupFields.get(field.AOB_SFObject__c).add(field.AOB_SFField__c);
            }
        } else {
            lookupFields.put(field.AOB_SFObject__c, new List<String>{field.AOB_SFField__c});
        }
    }

    /**
     * @description Inserts data for a specific wealth key
     */
    public static void insertData(String parentId, String wealthKey, List<Object> values,
                                List<AOB_Field__c> screenFieldList, Set<String> objectFieldList, String sectionName) {
       
        wealthKey = wealthKey.endsWith('V') || wealthKey.endsWith('W') ? wealthKey.substring(0, wealthKey.length() - 1) : wealthKey;
		string nameExtension= wealthKey.endsWith('V')  ? ' SOF' : ' SOW';
                                   
            Map<String,Decimal> conversionMap = new Map<String,Decimal>();
            for (CurrencyType ct : currencyTypes) {
                conversionMap.put(ct.IsoCode, ct.ConversionRate);
            }    
            for(Object sectionFieldDataObj : values){
                 wealthDetailsAmount = '';
                Map<String, Object> sectionFieldData = (Map<String, Object>) sectionFieldDataObj;              
                    string objectName='Party_Assets_Funds__c';
                    SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
    
                    processFields(screenFieldList, sectionFieldData, objectName, sObj, wealthKey, conversionMap);
    
                    if(sectionFieldData.keySet().contains(objectName) || sectionFieldData.containsKey('Id')){
                        handleExistingRecord(sectionFieldData, objectName, sObj);
                    } else if (objectName != ICS_Constants.ASSESSMENTTEXT){
                        sObj.put('OwnerId',accountInfo.ownerId);
                        if(wealthKey != 'Investment/Stock'){
                        	sObj.put('Name',wealthKey+ ' ' +nameExtension);
                        }
                        sObj.put('Number_of_Assets__c', sectionFieldData.get('orderValue'));

                        insertSObjList.add(sObj);
                    }
                
                
            }
        
		
        handleInsertAndUpdate(parentId);
      
                                    
    }

    /**
     * @description Processes fields for a specific object
     */
    private static void processFields(List<AOB_Field__c> screenFieldList, Map<String, Object> sectionFieldData,
                                    String objectName, SObject sObj, String wealthKey, Map<String,Decimal> conversionMap) {
        for(AOB_Field__c fieldData : screenFieldList) {
            String fieldName = fieldData.AOB_SFField__c;
            if (fieldData.AOB_Type__c == ICS_Constants.MasterDetail) {
                masterDetailMap.put(objectName, fieldName);
            }

            if (isProcessableField(fieldData)) {
                processRegularField(fieldData, sectionFieldData, objectName, fieldName, sObj, wealthKey, conversionMap);
            } else if (isLookupWithDefaultValue(fieldData)) {
                processLookupWithDefault(fieldData, sObj, fieldName);
            } else if (isLookupWithoutDefaultValue(fieldData)) {
                processLookupWithoutDefault(fieldData, sObj);
            }
        }
    }

    /**
     * @description Checks if a field is processable
     */
    private static boolean isProcessableField(AOB_Field__c fieldData) {
        return (fieldData.AOB_Type__c != 'Lookup' && fieldData.AOB_Type__c != ICS_Constants.MasterDetail)
            || (fieldData.AOB_Type__c == 'Lookup' && fieldData.AOB_SFObject__c == ICS_Constants.ASSESSMENTTEXT);
    }

    /**
     * @description Processes a regular field
     */
    private static void processRegularField(AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                          String objectName, String fieldName, SObject sObj,
                                          String wealthKey, Map<String,Decimal> conversionMap) {
        if((sectionFieldData.containsKey(fieldData.Name) && fieldData.AOB_SFObject__c != null
            && fieldData.AOB_SFField__c != null) || fieldData.AOB_SFObject__c == ICS_Constants.ASSESSMENTTEXT) {
                processField(fieldData, sectionFieldData, objectName, fieldName, sObj, wealthKey, conversionMap);
            }
    }

    /**
     * @description Checks if a field is a lookup with default value
     */
    private static boolean isLookupWithDefaultValue(AOB_Field__c fieldData) {
        return fieldData.AOB_Type__c == 'Lookup' && fieldData.Default_Value__c != null;
    }

    /**
     * @description Processes a lookup field with default value
     */
    private static void processLookupWithDefault(AOB_Field__c fieldData, SObject sObj, String fieldName) {
        if(fieldName == 'RecordTypeId'){
            String recId = Schema.getGlobalDescribe().get(fieldData.AOB_SFObject__c).getDescribe()
                .getRecordTypeInfosByName().get(fieldData.Default_Value__c).getRecordTypeId();
            sObj.put(fieldName, recId);
        } else {
            sObj.put(fieldName, fieldData.Default_Value__c);
        }
    }

    /**
     * @description Checks if a field is a lookup without default value
     */
    private static boolean isLookupWithoutDefaultValue(AOB_Field__c fieldData) {
        return fieldData.AOB_Type__c == 'Lookup' && fieldData.Default_Value__c == null;
    }

    /**
     * @description Processes a lookup field without default value
     */
    private static void processLookupWithoutDefault(AOB_Field__c fieldData, SObject sObj) {
        String[] fieldParts = fieldData.AOB_SFField__c.split(';');
        if(fieldParts.size() > 1 && linkedMap.containsKey(fieldParts[1])){
            sObj.put(fieldParts[0], linkedMap.get(fieldParts[1]));
        }
    }

    /**
     * @description Processes a single field
     */
    private static void processField(AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                   String objectName, String fieldName, SObject sObj,
                                   String wealthKey, Map<String,Decimal> conversionMap) {
        if(objectName == ICS_Constants.ASSESSMENTTEXT || fieldName == null) {
            return;
        }

        setupBasicFields(sObj, wealthKey);
                                       if(objectName != null && fieldName !=null){
        String fieldType = getFieldType(fieldData);
        processBasedOnFieldType(fieldData, sectionFieldData, fieldName, fieldType, sObj, conversionMap);
                                       }
    }

    /**
     * @description Sets up basic fields
     */
    private static void setupBasicFields(SObject sObj, String wealthKey) {
        String normalizedWealthKey = (wealthKey == 'Other' ? 'Other' : wealthKey);
         sObj.put('CurrencyIsoCode', 'GBP');
        String objectName = sObj.getSObjectType().getDescribe().getName();

        if(objectName != 'PartyProfile'){
            sObj.put('Type__c', normalizedWealthKey);
            sObj.put('Party_Profile__c', linkedMap.get('PartyProfile'));
        }
    }

    /**
     * @description Gets field type
     */
    private static String getFieldType(AOB_Field__c fieldData) {
        
        SObjectType r = ((SObject)(Type.forName('Schema.'+fieldData.AOB_SFObject__c).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        return d.fields.getMap().get(fieldData.AOB_SFField__c).getDescribe().getType().name().toLowerCase();
    }

    /**
     * @description Processes field based on type
     */
    private static void processBasedOnFieldType(AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                              String fieldName, String fieldType, SObject sObj,
                                              Map<String,Decimal> conversionMap) {
        if(isNumericField(fieldType)) {
            processCurrencyField(fieldData, sectionFieldData, fieldName, sObj, conversionMap);
        } else if(fieldType == 'boolean') {
            sObj.put(fieldName, Boolean.valueOf(sectionFieldData.get(fieldData.Name)));
        } else if(fieldType == 'date') {
            processDateField(fieldData, sectionFieldData, sObj);
        } else {
            processOtherField(fieldData, sectionFieldData, sObj);
        }
    }

    /**
     * @description Checks if field is numeric
     */
    private static boolean isNumericField(String fieldType) {
        return fieldType == 'currency' ||
            fieldType == 'double' ||
            fieldType == 'percent' ||
            fieldType == 'decimal';
    }

    /**
     * @description Processes currency field
     */
    @testvisible
    private static void processCurrencyField(AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                           String fieldName, SObject sObj, Map<String,Decimal> conversionMap) {
                                               if(sectionFieldData.get(fieldData.Name) != null){                                         
        if(fieldData.AOB_Type__c == 'Currency' && sectionFieldData.get(fieldData.Name+ 'Currency') != null) {
            String isoCode = '';
            String currencyField = fieldData.Name + 'Currency';

            if(sectionFieldData.containsKey(currencyField)) {
                isoCode = (String)sectionFieldData.get(currencyField);
            }
		string currencyValue= isoCode.contains(':') ? isoCode.split(':')[1] : isoCode;
            Decimal convertedAmount = ICS_CTRL_DML_OnboardingDetails.mapCurrency(fieldData.Name,
                                                                               Decimal.valueOf(String.valueOf(currencyValue)),
                                                                               isoCode, conversionMap);
            sObj.put(fieldName, convertedAmount);

            if(sectionFieldData.containsKey(currencyField)) {
                if(wealthDetailsAmount != '') {
                    wealthDetailsAmount += ';';
                }
                wealthDetailsAmount += currencyField + ',' + (String)sectionFieldData.get(currencyField);
            }
           sObj.put('Wealth_Details_Inclusive_of_Amount__c', wealthDetailsAmount);

        } else {
            sObj.put(fieldData.AOB_SFField__c, Decimal.valueOf(String.valueOf(sectionFieldData.get(fieldData.Name))));
        }
                                               }
    }

    /**
     * @description Processes date field
     */
    private static void processDateField(AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                        SObject sObj) {
        if(sectionFieldData.get(fieldData.Name) != null) {
            String inputDate = (String)sectionFieldData.get(fieldData.Name);
            String[] dateParts = inputDate.split('-');
            if(dateParts.size() == 3) {
                Integer year = Integer.valueOf(dateParts[0]);
                Integer month = Integer.valueOf(dateParts[1]);
                Integer day = Integer.valueOf(dateParts[2]);
                sObj.put(fieldData.AOB_SFField__c, Date.newInstance(year, month, day));
            }
        }
    }

    /**
     * @description Processes other field types
     */
    private static void processOtherField(AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                         SObject sObj) {
        if(sectionFieldData.get(fieldData.Name) == 'TRUE') {
            sObj.put(fieldData.AOB_SFField__c, 'Yes');
        } else if(sectionFieldData.get(fieldData.Name) == 'FALSE') {
            sObj.put(fieldData.AOB_SFField__c, 'No');
        } else {
            if (fieldData.AOB_SFField__c == 'Jurisdictional_Cover_of_Sale__c') {
                Map<String, String> countryCodeMap = ICS_CTRL_PreAppFormCreator.countryCodeMap();
                string countryName= countryCodeMap.get((string)sectionFieldData.get(fieldData.Name));
                sObj.put('Jurisdictional_Cover_of_Sale__c',countryName);
            }else{
            	sObj.put(fieldData.AOB_SFField__c, sectionFieldData.get(fieldData.Name));
            }
        }
    }

    /**
     * @description Handles existing records
     */
    private static void handleExistingRecord(Map<String, Object> sectionFieldData,
                                           String objectName, SObject updateSObj) {
        if(sectionFieldData.containsKey(objectName) && objectName != ICS_Constants.ASSESSMENTTEXT) {
            updateSObj.put('Id', sectionFieldData.get(objectName));
            updateSObjList.add(updateSObj);
        }
        if(sectionFieldData.containsKey('Id') && objectName != ICS_Constants.ASSESSMENTTEXT) {
            updateSObj.put('Id', sectionFieldData.get('Id'));
            updateSObjList.add(updateSObj);
        }
    }

    /**
     * @description Handles insert and update operations
     */
    private static void handleInsertAndUpdate(String parentId) {
        if(!insertSObjList.isEmpty()) {
            processInserts(parentId);
        }
        if(!updateSObjList.isEmpty()) {
            processUpdates();
        }
    }

    /**
     * @description Processes insert operations
     */
    private static void processInserts(String parentId) {
        List<SObject> masterDetailObjects = separateMasterDetailObjects();
        insertNonMasterDetailObjects(parentId);
        insertMasterDetailObjects(masterDetailObjects);
    }

    /**
     * @description Separates master-detail objects
     */
    private static List<SObject> separateMasterDetailObjects() {
        List<SObject> masterDetailObjects = new List<SObject>();
        List<SObject> nonMasterDetailObjects = new List<SObject>();

        for(SObject objData : insertSObjList) {
            String objectName = objData.getSObjectType().getDescribe().getName();
            if(masterDetailMap.containsKey(objectName)) {
                masterDetailObjects.add(objData);
            } else {
                nonMasterDetailObjects.add(objData);
            }
        }

        insertSObjList = nonMasterDetailObjects;
        return masterDetailObjects;
    }

    /**
     * @description Inserts non-master-detail objects
     */
    private static void insertNonMasterDetailObjects(String parentId) {
        if(!Schema.sObjectType.Party_Assets_Funds__c.isCreateable()) {
            return;
        }
		List<id> insertedIds = new List<Id>();
        List<Database.SaveResult> saveResultList = Database.insert(insertSObjList, false);
        for(Database.SaveResult saveResult : saveResultList) {
            if(saveResult.isSuccess()) {
                insertedIds.add(saveResult.getId());
                updateLinkedMap(saveResult.getId(), parentId);
            }
        }
        List<Party_Assets_Funds__c> ownershipList =[select id from Party_Assets_Funds__c where 
                                                    type__c='Ownership/shares in business' and Party_Profile__r.accountid=:parentId and Is_Future_Fund__c=false and recordtype.name='Source of Funds'  order by Createddate asc];
        
        if(ownershipList.size()>0){
            for(integer j=0;j<ownershipList.size();j++){
                if(additionalownersmap.containskey(j)){
                    
                    List<object> owners = additionalownersmap.get(j);
                     string jsonString = json.serialize(owners);
                  
                       
                        upsertPartyProfile(jsonString, ownershipList[j].Id);
                    
                }
            }
        }
        
    }
    @AuraEnabled
    public static void upsertPartyProfile(String ownerJson, String fundId) {
        try {

            if (String.isEmpty(ownerJson) || String.isEmpty(fundId)) {
                throw new CustomException('Owner JSON and Fund ID are required.');
            }
    
            List<PartyProfile> partyProfiles = createPartyProfiles(ownerJson, fundId);
            
            if (!partyProfiles.isEmpty()) {
                Database.UpsertResult[] results = Database.upsert(partyProfiles, false);
                handleUpsertResults(results);
            }
        } catch (JSONException e) {
           
            throw new AuraHandledException( e.getMessage());
        } catch (CustomException e) {
            throw new AuraHandledException( e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException( e.getMessage());
        }
    }
    
    private static List<PartyProfile> createPartyProfiles(String ownerJson, String fundId) {
        List<Object> rawList = (List<Object>)JSON.deserializeUntyped(ownerJson);
        List<PartyProfile> profiles = new List<PartyProfile>();
        String recordTypeId = getAdditionalBusinessOwnerRecordTypeId();
    
        for (Object item : rawList) {
            Map<String, Object> ownerData = (Map<String, Object>)item;
            PartyProfile profile = new PartyProfile();
            
            setBasicInfo(profile, ownerData, fundId, recordTypeId);
            setPersonalInfo(profile, ownerData);
            setLocationInfo(profile, ownerData);
            setNameHistory(profile, ownerData);
            setBusinessInfo(profile, ownerData);
            
            profiles.add(profile);
        }
        
        return profiles;
    }
    
    private static String getAdditionalBusinessOwnerRecordTypeId() {
        return Schema.getGlobalDescribe()
            .get('PartyProfile')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('ICS Additional Business Owner')
            .getRecordTypeId();
    }
    
    private static void setBasicInfo(PartyProfile profile, Map<String, Object> ownerData, String fundId, String recordTypeId) {
        String firstName = (String)ownerData.get('First Name');
        String surname = (String)ownerData.get('Surname');
        
        profile.Name = String.format('{0} {1} Additional Owner', new List<String>{firstName, surname});
        profile.RecordTypeId = recordTypeId;
        profile.Party_Assets_Funds__c = fundId;
        profile.Id = (String)ownerData.get('Id');
    }
    
    private static void setPersonalInfo(PartyProfile profile, Map<String, Object> ownerData) {
        profile.FirstName = (String)ownerData.get('First Name');
        profile.MiddleName = (String)ownerData.get('Middle Name');
        profile.LastName = (String)ownerData.get('Surname');
        profile.Person_Title__c = (String)ownerData.get('Title');
        profile.Gender = (String)ownerData.get('Gender');
        
        String birthDate = (String)ownerData.get('Date of birth');
        if (String.isNotBlank(birthDate)) {
            profile.Birthdate__c = parseDate(birthDate);
        }
    }
    
    private static void setLocationInfo(PartyProfile profile, Map<String, Object> ownerData) {
        profile.Town_City_of_Birth__c = (String)ownerData.get('Town/City of Birth');
        profile.CountryofBirth = (String)ownerData.get('Country of Birth');
        profile.Country_of_Nationality__c = (String)ownerData.get('Primary Country of Nationality');
        profile.Second_Country_of_Nationality__c = (String)ownerData.get('Secondary Country of Nationality');
        
        String maritalStatus = (String)ownerData.get('Marital Status');
        if (String.isNotBlank(maritalStatus)) {
            profile.WI_MaritialStatus__c = ICS_CTRL_FetchTrustDataProcessor.getMaritalStatusMap().get(maritalStatus);
        }
    }
    
    private static void setNameHistory(PartyProfile profile, Map<String, Object> ownerData) {
        String formerOrMaidenName = (String)ownerData.get('Former Name or Maiden NameFFF');
        if (String.isNotBlank(formerOrMaidenName)) {
            profile.Has_Former_Name__c = hasFormerName(formerOrMaidenName) ? 'Yes' : 'No';
            profile.Has_Maiden_Name__c = hasMaidenName(formerOrMaidenName) ? 'Yes' : 'No';
        }
        
        profile.Former_Name__c = (String)ownerData.get('Former Name');
        profile.Maiden_Name__c = (String)ownerData.get('Maiden Name');
        profile.Different_First_Name__c = (String)ownerData.get('Other First Name');
        profile.Different_Middle_Name__c = (String)ownerData.get('Other Middle Name');
        profile.Different_Last_Name__c = (String)ownerData.get('Other Surname');
        String otherNameData = (String)ownerData.get('Other NameFFF');
        profile.Has_different_First_Middle_Family_Name__c = (otherNameData == null || otherNameData == 'None') ? 'No' : 'Yes';
    }
    
    private static void setBusinessInfo(PartyProfile profile, Map<String, Object> ownerData) {
        Object percentageOwned = ownerData.get('Percentage of the business owned');
        if (percentageOwned != null) {
            profile.Percentage_of_Business__c = Decimal.valueOf(String.valueOf(percentageOwned));
        }
    }
    
    private static Date parseDate(String dateStr) {
        List<String> parts = dateStr.split('-');
        if (parts.size() == 3) {
            return Date.newInstance(
                Integer.valueOf(parts[0]),
                Integer.valueOf(parts[1]),
                Integer.valueOf(parts[2])
            );
        }
        return null;
    }
    
    private static Boolean hasFormerName(String nameType) {
        return nameType == 'FormerName' || nameType == 'FormerAndMaiden';
    }
    
    private static Boolean hasMaidenName(String nameType) {
        return nameType == 'MaidenName' || nameType == 'FormerAndMaiden';
    }
    
    private static void handleUpsertResults(Database.UpsertResult[] results) {
        List<String> errors = new List<String>();
        
        for (Database.UpsertResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    errors.add(err.getMessage());
                }
            }
        }
        
        if (!errors.isEmpty()) {
            throw new CustomException('Failed to upsert party profiles: ' + String.join(errors, '; '));
        }
    }
    

  /**
     * @description Inserts master-detail objects
     */
    private static void insertMasterDetailObjects(List<SObject> masterDetailObjects) {
        for(SObject masterObj : masterDetailObjects) {
            setMasterDetailLookup(masterObj);
        }

        List<Database.SaveResult> mSaveResultList = Database.insert(masterDetailObjects, false);
        for(Database.SaveResult saveResult : mSaveResultList) {
            if(saveResult.isSuccess()) {
                mapLookupData(saveResult.getId());
            }
        }
    }

    /**
     * @description Sets master-detail lookup field
     */
    private static void setMasterDetailLookup(SObject masterObj) {
        String objectName = masterObj.getSObjectType().getDescribe().getName();
        String lookupFieldName = masterDetailMap.get(objectName);
        String[] lookupParts = lookupFieldName.split(ICS_Constants.SemiColon);
        if(lookupParts.size() > 1 && linkedMap.containsKey(lookupParts[1])) {
            masterObj.put(lookupParts[0], linkedMap.get(lookupParts[1]));
        }
    }

    /**
     * @description Processes update operations
     */
    private static void processUpdates() {
        if(!updateSObjList.isEmpty()) {
            Database.update(updateSObjList, false);
        }
    }

    /**
     * @description Updates linkedMap after insertion
     */
    @TestVisible
    private static void updateLinkedMap(Id insertedRecordId, String parentId) {
        String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
        if(linkedMap.containsKey(objectName)) {
            String existingId = linkedMap.get(objectName);
            linkedMap.put(objectName, existingId + ':' + insertedRecordId);
        } else {
            linkedMap.put(objectName, insertedRecordId);
            linkedMap.put('Account', parentId);
        }
    }

    /**
     * @description Maps lookup data after insertion
     */
    private static void mapLookupData(Id insertedRecordId) {
        LOGGER.info('Mapping lookup data for record: {0}', new Object[]{insertedRecordId});
        String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
        if(linkedMap.containsKey(objectName)) {
            String existingIds = linkedMap.get(objectName);
            linkedMap.put(objectName, existingIds + ':' + insertedRecordId);
        } else {
            linkedMap.put(objectName, insertedRecordId);
        }
        updateLookup();
    }

    /**
     * @description Updates lookup fields
     */
    public static void updateLookup() {
        LOGGER.info('Updating lookup fields');
        List<SObject> sObjectListUpdate = new List<SObject>();

        for(String fieldKey : lookupFields.keySet()) {
            processlookupField(fieldKey, sObjectListUpdate);
        }

        if(!sObjectListUpdate.isEmpty()) {
            update sObjectListUpdate;
        }
    }

    /**
     * @description Processes a lookup field
     */
    private static void processlookupField(String fieldKey, List<SObject> sObjectListUpdate) {
        if(linkedMap.get(fieldKey).contains(':')) {
            processMultipleIds(fieldKey, sObjectListUpdate);
        } else {
            processSingleId(fieldKey, sObjectListUpdate);
        }
    }

    /**
     * @description Processes multiple IDs in lookup field
     */
    private static void processMultipleIds(String fieldKey, List<SObject> sObjectListUpdate) {
        for(String singleId : linkedMap.get(fieldKey).split(':')) {
            Id recordId = singleId;
            String sObjectName = recordId.getSObjectType().getDescribe().getName();

            SObjectType sObjectType = ((SObject)(Type.forName('Schema.' + sObjectName).newInstance())).getSObjectType();
            SObject sObjectToLookup = sObjectType.newSObject();
            sObjectToLookup.put('Id', recordId);

            updateLookupFields(fieldKey, sObjectToLookup);
            sObjectListUpdate.add(sObjectToLookup);
        }
    }

    /**
     * @description Processes single ID in lookup field
     */
    private static void processSingleId(String fieldKey, List<SObject> sObjectListUpdate) {
        Id recordId = linkedMap.get(fieldKey);
        String objectName = recordId.getSObjectType().getDescribe().getName();

        SObjectType objectType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        SObject sObjectToLookup = objectType.newSObject();
        sObjectToLookup.put('Id', recordId);

        updateLookupFields(fieldKey, sObjectToLookup);
        sObjectListUpdate.add(sObjectToLookup);
    }

    /**
     * @description Updates lookup fields on an SObject
     */
    private static void updateLookupFields(String fieldKey, SObject sObj) {
        for(String lookupField : lookupFields.get(fieldKey)) {
            String[] parts = lookupField.split(';');
            if(parts.size() > 1 && linkedMap.containsKey(parts[1])) {
                sObj.put(parts[0], linkedMap.get(parts[1]));
            }
        }
    }

    /**
     * @description Custom exception class for onboarding errors
     */
    public class CustomException extends Exception {}
}