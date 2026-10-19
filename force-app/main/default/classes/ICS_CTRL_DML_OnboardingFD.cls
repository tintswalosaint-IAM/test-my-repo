/***************************************************************************************
* @name of the Class : ICS_CTRL_DML_OnboardingFD.cls
* @description class used as controller for Future Deposits 
* @Story: SFP-30244
* @author Ikyatha Naidu
* @date 10/03/2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_DML_OnboardingFD {
    
    private static final String FUTURE_DEPOSITS = 'Future Deposits';
    private static final String HOW_DO_YOU_INTEND = 'How do you intend to fund the future deposits?';
    
    public static Map<String, List<String>> lookupFields = new Map<String, List<String>>();
    public static Map<String, String> linkedMap = new Map<String, String>();
    public static Map<String, AssessmentQuestionResponse> responseDataMap = new Map<String, AssessmentQuestionResponse>();
    public static Map<String, String> questionsResponseMap = new Map<String, String>();
    public static Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
    public static Map<String, Map<String, List<AOB_Field__c>>> objectWithFieldAPIWealthNames = new Map<String, Map<String, List<AOB_Field__c>>>();
    public static Map<String, List<AOB_Field__c>> tableFieldMap = new Map<String, List<AOB_Field__c>>();
    public static Map<String, Object> sectionFieldData = new Map<String, Object>();
    public static Map<String, String> identityDocuData = new Map<String, String>();
    public static Map<String, String> assessmentQuestionResponse = new Map<String, String>();
    public static Map<String, String> countryCodeMap = new Map<String, String>();
    public static List<SObject> insertsObjList = new List<SObject>();
    public static List<AOB_Field__c> assessObjList = new List<AOB_Field__c>();
    public static List<SObject> updateSObjectList = new List<SObject>();
    public static Map<String, String> masterDetailMap = new Map<String, String>();
  Public static Map<String, Decimal> conversionMap = new Map<String, Decimal>(); 
    public static Map<String, Object> existingDataMap = ICS_CTRL_FecthOnboardingDetails.existingDataMap;
    Public static map<integer,List<Object>> additionalOwnersMap = new map<integer,List<Object>>();
   private ICS_CTRL_DML_OnboardingFD(){
        //Private Constructor for instantiation
    }
    public static void processData(String jsonString, String screenName, String sectionName, String parentId, List<AOB_Field__c> assessmentScreenData) {
        if (String.isNotBlank(jsonString)) {
            conversionMap = getConversionRates();
            parseJSON(jsonString, sectionName, parentId, assessmentScreenData);
        }
    }

    public static void parseJSON(String jsonData, String sectionName, String parentId, List<AOB_Field__c> assessmentScreenData) {
        Map<String, Object> jsonDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        sectionFieldData = jsonDataMap;
        checkRecords(jsonDataMap,parentId);
        List<String> wealthList = new List<String>();
        Set<String> objectList = new Set<String>();
        Set<String> objectFieldList = new Set<String>();
        Map<String, List<Object>> wealthJSONMap = new Map<String, List<Object>>();
        
        processAssessmentQuestions(jsonDataMap, parentId, wealthList, assessmentScreenData);
        
        if (!wealthList.isEmpty()) {
            processWealthList(wealthList, sectionName, parentId, objectList, objectFieldList);
        }
        
        populateWealthJSONMap(jsonDataMap, wealthList, wealthJSONMap);
        for (String wealthKey : wealthList) {
            if (objectWithFieldAPINames.get(wealthKey) != null && wealthJSONMap.containsKey(wealthKey)) {
                insertData(parentId, wealthKey, wealthJSONMap.get(wealthKey), objectWithFieldAPINames.get(wealthKey), objectFieldList, sectionName);
            }
        }
        if (!insertsObjList.isEmpty()) {
            handleBulkInsert(parentId);
        }
        if (!updateSObjectList.isEmpty()) {
            update updateSObjectList;
        }
    }

        /**
     * @description delete records
     */

     private static void checkRecords(Map<String, Object> jsonDataMap, String parentId) {
        processAssets(jsonDataMap, parentId, HOW_DO_YOU_INTEND, HOW_DO_YOU_INTEND, 'Source of Funds');
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
          return 
        assResponseMap.get(assessmentName) != null ?  assResponseMap.get(assessmentName).ResponseText : '';
    }
    @testVisible
    private static void deletePartyAssets(String parentId, List<String> missingAssets, String assetType) {
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        SEL_PartyAssetFunds selectorPartyAssetFunds = new SEL_PartyAssetFunds();
        List<Party_Assets_Funds__c> assetsToDelete = selectorPartyAssetFunds.selectByPartyProfileBulkTypewithRecordAssests(profileData.Id, missingAssets, assetType, true);

        if (!assetsToDelete.isEmpty()) {
            delete assetsToDelete;
        } 
    }

    private static void processAssessmentQuestions(Map<String, Object> jsonDataMap, String parentId, List<String> wealthList, List<AOB_Field__c> assessmentScreenData) {
        Map<String, AssessmentQuestionResponse> assResponseMap = new Map<String, AssessmentQuestionResponse>();
        SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responseList = selectorAssessmentqueResponse.selectByParentIdAndSectionName(parentId, FUTURE_DEPOSITS);
        
        for (AssessmentQuestionResponse responseInfo : responseList) {
            assResponseMap.put(responseInfo.AssessmentQuestion.Name, responseInfo);
        }
        
        List<String> allAssessmentQuestion = new List<String>();
        for (AOB_Field__c data : assessmentScreenData) {
           
            allAssessmentQuestion.add(data.Name);
        }
    
        SEL_Assesment selectorAssInfo = new SEL_Assesment();
        List<Assessment> assDataList = selectorAssInfo.SelectByAccountId(parentId);
        Map<String, String> questionMap = new Map<String, String>();
        
        for (AssessmentQuestion assQuestion : [SELECT Id, Name, ActiveVersionId, QuestionText FROM AssessmentQuestion WHERE Name IN :allAssessmentQuestion]) {
            questionMap.put(assQuestion.Name, assQuestion.ActiveVersionId);
          
        }
    
        List<AssessmentQuestionResponse> responseData = new List<AssessmentQuestionResponse>();
        
        for (String key : questionMap.keySet()) {
            
            processIndividualQuestion(key, jsonDataMap, assResponseMap, assDataList, responseData, questionMap);
            
            if (key == HOW_DO_YOU_INTEND) {
                processWealthTypes(key, jsonDataMap, assResponseMap, wealthList);
            }
        }

        if (!responseData.isEmpty() && !Test.isRunningTest()) {
            upsert responseData;
        }
    }

    private static void processIndividualQuestion(String key, Map<String, Object> jsonDataMap, Map<String, AssessmentQuestionResponse> assResponseMap, 
                                                  List<Assessment> assDataList, List<AssessmentQuestionResponse> responseData, Map<String, String> questionMap) {
        AssessmentQuestionResponse response = assResponseMap.containsKey(key) ? assResponseMap.get(key) : new AssessmentQuestionResponse();
       
        if (jsonDataMap.containsKey(key)) {
            if(key == 'Expected annual/yearly turnover for the account'){
                
                
                String isoCode = '';
              
                
                if (jsonDataMap.containsKey(key + 'Currency')) {
                    isoCode = (String) jsonDataMap.get(key + 'Currency');
                }
                
                Decimal convertedAmount = ICS_CTRL_DML_OnboardingDetails.mapCurrency(
                    key,
                    Decimal.valueOf(String.valueOf( (String) jsonDataMap.get(key))),
                    isoCode,
                    conversionMap
                );
                response.ResponseText = string.valueof(convertedAmount);
            }else{
              response.ResponseText = (String) jsonDataMap.get(key);
            }
            if (!assResponseMap.containsKey(key)) {
                response.AssessmentId = assDataList[0].Id;
                response.AssessmentQuestionId = questionMap.get(key);
                response.Name = FUTURE_DEPOSITS;
            }
            responseData.add(response);
        }
    }

    private static void processWealthTypes(String key, Map<String, Object> jsonDataMap, Map<String, AssessmentQuestionResponse> assResponseMap, List<String> wealthList) {
        List<String> typeList = new List<String>();
        
        if (jsonDataMap.containsKey(key)) {
            String questionData = (String)jsonDataMap.get(key);
            if (questionData != null) {
                typeList.addAll(questionData.split(';'));
            }
        } else if (assResponseMap.containsKey(key)) {

               if (assResponseMap.get(key) != null && assResponseMap.get(key).ResponseText != null) {
                    typeList.addAll(assResponseMap.get(key).ResponseText.split(';'));
                }
            // typeList.addAll(assResponseMap.get(key).ResponseText.split(';'));
        }
        
        for (String asset : typeList) {
            wealthList.add(asset + 'Vvv');
        }
    }

    private static void processWealthList(List<String> wealthList, String sectionName, String parentId, Set<String> objectList, Set<String> objectFieldList) {
        List<AOB_Field__c> screenFieldList = new SEL_AOBField().selectMRITablesByParentNames(wealthList, sectionName);
       
        Map<Id,AOB_Field__c> screenFieldMap = new Map<Id,AOB_Field__c>(screenFieldList);

        List<AOB_Field__c> childFields = new SEL_AOBField().selectFieldsByParentIds(screenFieldMap.keySet());
                                          
        if(!childFields.isEmpty()) {
            screenFieldList.addAll(childFields);
        }
        assessObjList = screenFieldList;
        for (AOB_Field__c field : screenFieldList) {

            if (field.AOB_SFObject__c != null && field.AOB_SFField__c != null) {
                addToObjectWithFieldAPINames(field);
                objectFieldList.add(field.AOB_SFObject__c);
            }
            
            if (field.Default_Value__c == null && field.AOB_Type__c == 'Lookup') {
                addToLookupFields(field);
                objectList.add(field.AOB_SFField__c.split(';')[1]);
            }
        }
        
        linkedMap = ICS_CTRL_FecthOnboardingDetails.queryDataWithObject(parentId, objectList, sectionName);
    }
   @TestVisible
    private static void addToObjectWithFieldAPINames(AOB_Field__c field) {
        if (objectWithFieldAPINames.containsKey(field.AOB_Parent__r.Name)) {
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
  @TestVisible
    private static void addToLookupFields(AOB_Field__c field) {
        if (lookupFields.containsKey(field.AOB_SFObject__c)) {
            List<String> fields = lookupFields.get(field.AOB_SFObject__c);
            if (!fields.contains(field.AOB_SFField__c)) {
                fields.add(field.AOB_SFField__c);
            }
        } else {
            lookupFields.put(field.AOB_SFObject__c, new List<String>{field.AOB_SFField__c});
        }
    }

    private static void populateWealthJSONMap(Map<String, Object> jsonDataMap, List<String> wealthList, Map<String, List<Object>> wealthJSONMap) {
        for (String key : wealthList) {
            if (jsonDataMap.containsKey(key) && jsonDataMap.get(key) instanceof List<Object>) {
                 List<Object> objList = (List<Object>)jsonDataMap.get(key);
                wealthJSONMap.put(key,objList);
                integer i=0;
                    for(Object obj : objList) {
                        
                        if(obj instanceof Map<String, Object>) {
                            Map<String, Object> objMap = (Map<String, Object>)obj;                            
                            String ownersKey = 'Addtional Business Owners';
                            if(objMap.containsKey(ownersKey) && objMap.get(ownersKey) instanceof List<Object>) {
                                List<Object> ownersList = (List<Object>)objMap.get(ownersKey);
                                if(!ownersList.isEmpty()) {
                                    // Now this will work because the Map is properly typed
                                    additionalOwnersMap.put(i, ownersList);
                                }
                                i++;
                            }
                        }
                    }
            }
        }
    }

    public static void insertData(String parentId, String wealthKey, List<Object> values, List<AOB_Field__c> screenFieldList, Set<String> objectFieldList, String sectionName) {
        SEL_Account accSelector = new SEL_Account();
         Account accountInfo = accSelector.selectById(parentId);       
        for (Object sectionFieldDataObj : values) {
            Map<String, Object> sectionFieldData = (Map<String, Object>) sectionFieldDataObj;
            
            for (String objectName : objectFieldList) {
                SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                SObject updateSObj = Schema.getGlobalDescribe().get(objectName).newSObject();
                String wealthDetails = '';
                String street = '';
                
                processFields(sObj, updateSObj, screenFieldList, sectionFieldData, objectName, wealthKey, wealthDetails); 
                
                if (objectName == 'PartyProfileAddress') {
                    sObj.put('Street', street);
                }
                sObj.put('OwnerId',accountInfo.ownerId);
                String textWithoutVvv = wealthKey;
                if (String.isNotBlank(wealthKey)) {
                textWithoutVvv = wealthKey?.replaceAll('Vvv', '');
                }
                if(textWithoutVvv != 'Investment/Stock'){
                    sObj.put('Name',textWithoutVvv+ ' SOF');
                }
                sObj.put('Number_of_Assets__c', sectionFieldData.get('orderValue'));
                handleRecordInsertion(sObj, updateSObj, sectionFieldData, objectName);
            }
        }
        
        
        
        
    }

    private static Map<String, Decimal> getConversionRates() {
        Map<String, Decimal> conversionMap = new Map<String, Decimal>();
        for (CurrencyType ct : [SELECT IsoCode, ConversionRate FROM CurrencyType LIMIT 1000]) {
            conversionMap.put(ct.IsoCode, ct.ConversionRate);
        }
        return conversionMap;
    }

    private static void processFields(SObject sObj, SObject updateSObj, List<AOB_Field__c> screenFieldList, Map<String, Object> sectionFieldData, 
                                      String objectName, String wealthKey, String wealthDetails) {
        for (AOB_Field__c fieldData : screenFieldList) {
            String fieldName = fieldData.AOB_SFField__c;
            if (String.isBlank(fieldName)) {
                continue;
            }
            if (fieldData.AOB_Type__c == ICS_Constants.MasterDetail) {
                masterDetailMap.put(objectName, fieldName);
            }
            
            if (fieldData.AOB_Type__c == 'Lookup') {
                processLookupField(sObj, fieldData, fieldName);
            }
            else if (fieldData.AOB_Type__c != 'Lookup' && fieldData.AOB_Type__c != ICS_Constants.MasterDetail) {
                processNonLookupField(sObj, updateSObj, fieldData, sectionFieldData, objectName, fieldName, wealthKey, wealthDetails);
            } 
        }
    }

    private static void processNonLookupField(SObject sObj, SObject updateSObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData, 
                                              String objectName, String fieldName, String wealthKey, String wealthDetails
                                               ) {
        if ((sectionFieldData.containsKey(fieldData.Name) && fieldData.AOB_SFObject__c != null && fieldData.AOB_SFField__c != null) 
            || fieldData.AOB_SFObject__c == ICS_Constants.ASSESSMENTTEXT) {
            if (objectName == 'IdentityDocument') {
                handleIdentityDocument(updateSObj, fieldData, sectionFieldData, fieldName);
            } else if (objectName != ICS_Constants.ASSESSMENTTEXT && fieldName != null) {
                setFieldValue(sObj, fieldData, sectionFieldData, objectName, fieldName, wealthKey, wealthDetails, conversionMap);
            }
        }
    }
	@TestVisible
    private static void handleIdentityDocument(SObject updateSObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData, String fieldName) {
        if (sectionFieldData.containsKey(fieldData.Name + ' Id')) {
            updateSObj.put('Id', (String)sectionFieldData.get(fieldData.Name + ' Id'));
            updateSObj.put('Name', (String)sectionFieldData.get(fieldData.Name));
            updateSObjectList.add(updateSObj);
        } else {
            identityDocuData.put(fieldName, (String)sectionFieldData.get(fieldName));
        }
    }

// Split into smaller, focused methods
private static void setFieldValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData, 
                                String objectName, String fieldName, String wealthKey, 
                                String wealthDetails, Map<String, Decimal> conversionMap) {
    // Get field type
    String fieldType = getFieldType(objectName, fieldName);
    
    // Process wealth-related fields
    processWealthFields(sObj, wealthKey, objectName,sectionFieldData);
    
    // Set party profile if exists
    setPartyProfile(sObj);
    
    // Set default currency
    sObj.put('currencyisocode', 'GBP');
    
    // Handle field based on type
    FieldHandler handler = getFieldHandler(fieldType);
    handler.handleField(sObj, fieldData, sectionFieldData, fieldName, wealthDetails, conversionMap);
}

private static String getFieldType(String objectName, String fieldName) {
    SObjectType r = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
    DescribeSObjectResult d = r.getDescribe();
    return d.fields.getMap().get(fieldName).getDescribe().getType().name().toLowerCase();
}

private static void processWealthFields(SObject sObj, String wealthKey, String objectName,Map<String, Object> sectionFieldData) {
    if (objectName == 'Party_Assets_Funds__c') {
        String processedWealthKey = wealthKey.replaceAll('Vvv', '');
        processedWealthKey = (processedWealthKey == 'Other') ? 'Other' : processedWealthKey;
        sObj.put('type__c', processedWealthKey);
		if(sectionFieldData.containskey('isListed')){
            if(sectionFieldData.get('isListed') == true){
            	sObj.put('Is_listed_in_assets__c', true);
            }  
            }
    }
}

private static void setPartyProfile(SObject sObj) {
    if (linkedMap != null && linkedMap.containsKey('PartyProfile')) {
        sObj.put('Party_Profile__c', linkedMap.get('PartyProfile'));
    }
}

// Field Handler Interface
public interface FieldHandler {
    void handleField(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData, 
                    String fieldName, String wealthDetails, Map<String, Decimal> conversionMap);
}

// Concrete Handlers
public class CurrencyFieldHandler implements FieldHandler {
    public void handleField(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                          String fieldName, String wealthDetails, Map<String, Decimal> conversionMap) {
        if (fieldData.AOB_Type__c == 'Currency') {
            handleCurrencyType(sObj, fieldData, sectionFieldData, fieldName, wealthDetails, conversionMap);
        } else {
            sObj.put(fieldName, Decimal.valueOf(String.valueOf(sectionFieldData.get(fieldData.Name))));
        }
    }
    
    private void handleCurrencyType(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                                  String fieldName, String wealthDetails, Map<String, Decimal> conversionMap) {
        String isoCode = '';
        String currencyField = fieldData.Name + 'Currency';
        
        if (sectionFieldData.containsKey(fieldData.Name + 'Currency')) {
            isoCode = (String) sectionFieldData.get(fieldData.Name + 'Currency');
        }
        
        Decimal convertedAmount = ICS_CTRL_DML_OnboardingDetails.mapCurrency(
            fieldData.Name,
            Decimal.valueOf(String.valueOf(sectionFieldData.get(fieldData.Name))),
            isoCode,
            conversionMap
        );
        
        sObj.put(fieldName, convertedAmount);
        setWealthDetails(sObj, sectionFieldData, currencyField, wealthDetails);
    }
    
    private void setWealthDetails(SObject sObj, Map<String, Object> sectionFieldData, 
                                String currencyField, String wealthDetails) {
    
        if (sectionFieldData.containsKey(currencyField)) {
            String updatedDetails = currencyField + ',' + (String)sectionFieldData.get(currencyField);
            
            String fieldName = sObj.get('Wealth_Details_Inclusive_of_Amount__c') == null ?
                'Wealth_Details_Inclusive_of_Amount__c' : 'Full_details_inclusive_of_amount__c';
            
            String existingValue = (String) sObj.get(fieldName);
            if (existingValue != null && existingValue != '') {
                updatedDetails = existingValue + ';' + updatedDetails;
            } else if (wealthDetails != '') {
                updatedDetails = wealthDetails + ';' + updatedDetails;
            }
            
            sObj.put(fieldName, updatedDetails);
        }
        sObj.put('Is_Future_Fund__c', true);
        }
    }

// Similar handlers for other field types
public class BooleanFieldHandler implements FieldHandler {
    public void handleField(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                          String fieldName, String wealthDetails, Map<String, Decimal> conversionMap) {
        sObj.put(fieldName, Boolean.valueOf(sectionFieldData.get(fieldData.Name)));
    }
}

public class DateFieldHandler implements FieldHandler {
    public void handleField(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                          String fieldName, String wealthDetails, Map<String, Decimal> conversionMap) {
        if (sectionFieldData.get(fieldData.Name) != null) {
            String inputDate = (String)(sectionFieldData.get(fieldData.Name));
            List<String> dateParts = inputDate.split('-');
            Date formattedDate = Date.newInstance(
                Integer.valueOf(dateParts[0]),
                Integer.valueOf(dateParts[1]),
                Integer.valueOf(dateParts[2])
            );
            sObj.put(fieldName, formattedDate);
        }
    }
}

public class DefaultFieldHandler implements FieldHandler {
    public void handleField(SObject sObj, AOB_Field__c fieldData, Map<String, Object> sectionFieldData,
                          String fieldName, String wealthDetails, Map<String, Decimal> conversionMap) {
        Object value = sectionFieldData.get(fieldData.Name);
        if (value == 'TRUE') {
            sObj.put(fieldName, 'Yes');
        } else if (value == 'FALSE') {
            sObj.put(fieldName, 'No');
        } else {
		if (fieldData.AOB_SFField__c == 'Jurisdictional_Cover_of_Sale__c' && fieldData.Name == 'Jurisdiction coverage of sales') {
                Map<String, String> countryCodeMap = ICS_CTRL_PreAppFormCreator.countryCodeMap();
                string countryName= countryCodeMap.get((string)value);
                sObj.put('Jurisdictional_Cover_of_Sale__c',countryName);
            }else{
                sObj.put(fieldName, (String)value);
            }
        }
    }
}

// Factory method to get appropriate handler
private static FieldHandler getFieldHandler(String fieldType) {
    switch on fieldType {
        when 'currency', 'double', 'percent', 'decimal' {
            return new CurrencyFieldHandler();
        }
        when 'boolean' {
            return new BooleanFieldHandler();
        }
        when 'date' {
            return new DateFieldHandler();
        }
        when else {
            return new DefaultFieldHandler();
        }
    }
}

  
    @testVisible
    private static void processLookupField(SObject sObj, AOB_Field__c fieldData, String fieldName) {
        if (fieldData.Default_Value__c == null && fieldData.AOB_Type__c == 'Lookup') {
          List<String> fieldParts = fieldData.AOB_SFField__c.split(';');
            
            if (linkedMap.containsKey(fieldParts[1])) {
                sObj.put(fieldParts[0], linkedMap.get(fieldParts[1]));
            }
            
        }
        else  {
            if (fieldName == 'RecordtypeId') {
                String recID = Schema.getGlobalDescribe().get(fieldData.AOB_SFObject__c).getDescribe()
                    .getRecordTypeInfosByName().get(fieldData.Default_Value__c).getRecordTypeId();
                sObj.put(fieldName, recID);
                
            } else {
                
                sObj.put('Is_future_fund__c', true);
            }
        } 
    }

    private static void handleRecordInsertion(SObject sObj, SObject updateSObj, Map<String, Object> sectionFieldData, String objectName) {
        if (sectionFieldData.containsKey(objectName) || sectionFieldData.containsKey('Id')) {
            updateSObj = sObj;
            if (sectionFieldData.containsKey(objectName) && objectName != ICS_Constants.ASSESSMENTTEXT) {
                updateSObj.put('Id', sectionFieldData.get(objectName));
                updateSObjectList.add(updateSObj);
            }
            if (sectionFieldData.containsKey('Id') && objectName != ICS_Constants.ASSESSMENTTEXT) {
                updateSObj.put('Id', sectionFieldData.get('Id'));
                updateSObjectList.add(updateSObj);
            }
        } else if (objectName != 'IdentityDocument' && objectName != ICS_Constants.ASSESSMENTTEXT) {
            insertsObjList.add(sObj);
           
        }
    }

    private static void handleBulkInsert(String parentId) {
        List<SObject> masterDetailObject = new List<SObject>();
        List<Integer> removeIndex = new List<Integer>();
        
        for (Integer i = 0; i < insertsObjList.size(); i++) {
            SObject objData = insertsObjList[i];
            String objectName = objData.getSObjectType().getDescribe().getName();
            if (masterDetailMap.containsKey(objectName)) {
                removeIndex.add(i);
                masterDetailObject.add(objData);
            }
        }
        
        for (Integer i = removeIndex.size() - 1; i >= 0; i--) {
            insertsObjList.remove(removeIndex[i]);
        }
       
        List<Database.SaveResult> saveResultList = Database.insert(insertsObjList, false);
        processInsertResults(saveResultList, parentId);
        
        for (SObject masterObj : masterDetailObject) {
            String objectName = masterObj.getSObjectType().getDescribe().getName();
            String lookupFieldName = masterDetailMap.get(objectName);
            List<String> fieldParts = lookupFieldName.split(ICS_Constants.SemiColon);
            masterObj.put(fieldParts[0], linkedMap.get(fieldParts[1]));
        }
        
        List<Database.SaveResult> mSaveResultList = Database.insert(masterDetailObject, false);
        processMasterDetailResults(mSaveResultList);
    }
	@TestVisible
    private static void processInsertResults(List<Database.SaveResult> saveResultList, String parentId) {
        List<id> insertedIds = new List<Id>();
        for (Database.SaveResult saveResult : saveResultList) {
            if (saveResult.isSuccess()) {
                Id insertedRecordId = saveResult.getId();
                insertedIds.add(insertedRecordId);
                String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
                if (linkedMap.containsKey(objectName)) {
                    
                    String existingId = linkedMap.get(objectName);
                    linkedMap.put(objectName, existingId + ':' + insertedRecordId);
                } else {
                    linkedMap.put(objectName, insertedRecordId);
                    linkedMap.put('Account', parentId);
                }
            }
        }
         List<Party_Assets_Funds__c> ownershipList =[select id from Party_Assets_Funds__c where 
                                                    type__c='Ownership/shares in business' and Party_Profile__r.accountid=:parentId and Is_Future_Fund__c=true and recordtype.name='Source of Funds'  order by Createddate asc];
        
        if(ownershipList.size()>0){
            for(integer j=0;j<ownershipList.size();j++){
                if(additionalownersmap.containskey(j)){
                    
                    List<object> owners = additionalownersmap.get(j);
                     string jsonString = json.serialize(owners);
                  
                       
                        ICS_CTRL_DML_OnboardingAI.upsertPartyProfile(jsonString, ownershipList[j].Id);
                    
                }
            }
        }
    }

    private static void processMasterDetailResults(List<Database.SaveResult> mSaveResultList) {
        List<SObject> sObjectListUpdate = new List<Sobject>();
        for (Database.SaveResult saveResult : mSaveResultList) {
            sObjectListUpdate = new List<Sobject>();
            if (saveResult.isSuccess()) {
                Id insertedRecordId = saveResult.getId();
                sObjectListUpdate = mapLookupData(insertedRecordId);
            }
        }

        if (!sObjectListUpdate.isEmpty()) {
            update sObjectListUpdate;
        }
    }

    @TestVisible
    private static List<SObject> mapLookupData(Id insertedRecordId) {
        String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
        if (linkedMap.containsKey(objectName)) {
            
            String existingIds = linkedMap.get(objectName);
            linkedMap.put(objectName, existingIds + ':' + insertedRecordId);
        } else {
            linkedMap.put(objectName, insertedRecordId);
        }
        List<SObject> sObjectListUpdate = new List<Sobject>();
        sObjectListUpdate =  updateLookup();
        return sObjectListUpdate;
    }

    public static List<SObject> updateLookup() {
        List<SObject> sObjectListUpdate = new List<SObject>();
        for (String fieldKey : lookupFields.keySet()) {
            if (linkedMap.get(fieldKey).contains(':')) {
               processMultipleLookups(fieldKey, sObjectListUpdate);
            } else {
                 processSingleLookup(fieldKey, sObjectListUpdate);
            }
        }
        return sObjectListUpdate;
       
    }
  @TestVisible
    private static void processSingleLookup(String fieldKey, List<SObject> sObjectListUpdate) {
        Id recordId = linkedMap.get(fieldKey);
        String objectName = recordId.getSObjectType().getDescribe().getName();
        SObjectType objectType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        SObject sObjectToLookup = objectType.newSObject();
        sObjectToLookup.put('Id', recordId);
        
        for (String lookupField : lookupFields.get(fieldKey)) {
            List<String> fieldParts = lookupField.split(';');
            if (linkedMap.containsKey(fieldParts[1])) {
                sObjectToLookup.put(fieldParts[0], linkedMap.get(fieldParts[1]));
            }
        }
        
        sObjectListUpdate.add(sObjectToLookup);
    }
    
    @testVisible
    private static void processMultipleLookups(String fieldKey, List<SObject> sObjectListUpdate) {
        for (String singleId : linkedMap.get(fieldKey).split(':')) {
            Id recordId = singleId;
            String objectName = recordId.getSObjectType().getDescribe().getName();
            SObjectType objectType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
            SObject sObjectToLookup = objectType.newSObject();
            sObjectToLookup.put('Id', recordId);
            
            for (String lookupField : lookupFields.get(fieldKey)) {
                List<String> fieldParts = lookupField.split(';');
                if (linkedMap.containsKey(fieldParts[1])) {
                    sObjectToLookup.put(fieldParts[0], linkedMap.get(fieldParts[1]));
                }
            }
            
            sObjectListUpdate.add(sObjectToLookup);
        }
    }
}