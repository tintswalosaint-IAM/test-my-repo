/***************************************************************************************

@name of the Class : ICS_CTRL_DML_OnboardingDetials.cls
@description : class used as controller for  SBO-UK onBoardingApplication Feature
@author : Ikyatha Naidu
@created Date :  01/01/2024
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 20-04-2025
@modification description: updated to latest version
***************************************************************************************/

public without sharing class ICS_CTRL_DML_OnboardingDetails {

    Public static   Map<String,List<String>>lookupFields = new Map<String,List<String>>();
    Public static Map<string,string>linkedMap = new Map<String,String>();
    Public static Map<string,AssessmentQuestionResponse> responseDataMap = new Map<string,AssessmentQuestionResponse>();
    Public static Map<string,string>quetsionsResponseMap = new Map<string,string>();
    Public static Map<string,List<AOB_Field__c>>  objectWithFieldAPINames =new Map<string,List<AOB_Field__c>>();
    Public static Map<string,List<AOB_Field__c>>tableFieldMap = new Map<string,List<AOB_Field__c>>();
    Public static Map<String, Object> sectionFieldData = new Map<String, Object>();
    Public static Map<string,string> identityDocuData = new Map<string,string>();
    Public static Map<string,string>assesmentQuestionResponse = new Map<string,string>();
    Public static Map<string,string> countryCodeMap = new map<string,string>();
    Public static List<sObject> insertsObjList = new List<sObject>();
    Public static List<assessmentquestion> assessmentQuestionsList = new List<assessmentquestion>();
    Public static List<sObject> updatesObjList = new List<sObject>();
    Public static  Map<string,string> masterDetailMap = new Map<String,String>();
    Public static  Map<string,string> primaryContactPointPhone = new Map<String,String>();
    Public static boolean invokeDML=false;
    Public static boolean  invokeCrossObjects = false;
    Public static Set<Id> existingIds = new Set<Id>();
    Public static Set<String> objectList = new Set<String>();
    Public static Map<string,Object> existingDataMap= ICS_CTRL_FecthOnboardingDetails.existingDataMap;
    Public static List<CurrencyType> currencyTypes = new List<CurrencyType>();
    Public static List<SObject> sobjectListUpdate = new List<SObject>();

    Public static List<AssessmentQuestionResponse> responseList = new List<AssessmentQuestionResponse>();
    Public static List<AssessmentQuestionResponse> updtaeResponseList = new List<AssessmentQuestionResponse>();
    private ICS_CTRL_DML_OnboardingDetails(){

    }
    public static void processData(String jsonString, String screenName, String sectionName, String parentId) {

            if (String.isBlank(jsonString)) {
        	return;
            }

    initializeData(jsonString);
    List<AOB_Field__c> screenFieldList = fetchScreenFields(screenName, sectionName);

    processScreenFields(screenFieldList,sectionName);
    fetchLinkedData(parentId, sectionName);
    handleSectionSpecificProcessing(jsonString, screenName, sectionName, parentId, screenFieldList);


}

private static void initializeData(String jsonString) {

    countryCodeMap = ICS_CTRL_OnboardingFormCreator.countryCodeMap();
    currencyTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType LIMIT 1000];
    sectionFieldData = new Map<String, Object>((Map<String, Object>) JSON.deserializeUntyped(jsonString));
}

private static List<AOB_Field__c> fetchScreenFields(String screenName, String sectionName) {
    return ICS_CTRL_FecthOnboardingDetails.fetchAobFields(screenName, sectionName);
}

public static void processScreenFields(List<AOB_Field__c> screenFieldList,string sectionName) {

    for (AOB_Field__c field : screenFieldList) {

        processField(field,sectionName);
    }

}

private static void processField(AOB_Field__c field,string sectionName) {

    if (isTableField(field)) {
        processTableField(field);
    } else if(sectionFieldData.containskey('type')==false
    || sectionName == 'Previous Residential Address'
    || sectionName == 'Other Business Interests'
    || sectionName == 'Previous Employment Details' ) {
        processRegularField(field);
    }
    processLookupField(field);
}

private static boolean isTableField(AOB_Field__c field) {
    return  field.AOB_SFObject__c.contains('table:');
}

private static void processTableField(AOB_Field__c field) {
    if (sectionFieldData.get('type') == 'modalData') {
        String[] parts = field.AOB_SFField__c.split(':');
        field.AOB_SFField__c = parts.size() > 1 ? parts[1] : field.AOB_SFField__c.substringAfter('table:');
        field.AOB_SFObject__c = field.AOB_SFObject__c.split(':')[1];
        addToObjectWithFieldAPINames(field);
    }
}

private static void processRegularField(AOB_Field__c field) {
    if (field.AOB_SFObject__c != null ) {
        addToObjectWithFieldAPINames(field);
    }
}

private static void addToObjectWithFieldAPINames(AOB_Field__c field) {

    if (objectWithFieldAPINames.containsKey(field.AOB_SFObject__c)) {
        objectWithFieldAPINames.get(field.AOB_SFObject__c).add(field);
    } else {
        objectWithFieldAPINames.put(field.AOB_SFObject__c, new List<AOB_Field__c>{field});
    }

}

private static void processLookupField(AOB_Field__c field) {
    if (field.Default_Value__c == null && field.AOB_Type__c == 'Lookup') {
        addToLookupFields(field);
        addToObjectList(field);
    }
}

private static void addToLookupFields(AOB_Field__c field) {
    List<String> fields = lookupFields.get(field.AOB_SFObject__c);

    if (fields == null) {
        fields = new List<String>();
        lookupFields.put(field.AOB_SFObject__c, fields);
    }

    if (!fields.contains(field.AOB_SFField__c)) {
        fields.add(field.AOB_SFField__c);
    }
    lookupFields.remove('table:');
}

private static void addToObjectList(AOB_Field__c field) {
    if (field.AOB_SFField__c != null && !field.AOB_SFField__c.contains('table:')) {
        String objName = field.AOB_SFField__c.contains(';') ? field.AOB_SFField__c.split(';')[1] : field.AOB_SFField__c;
        objectList.add(objName);
    }
}

public static void fetchLinkedData(String parentId, String sectionName) {
    linkedMap = ICS_CTRL_FecthOnboardingDetails.queryDataWithObject(parentId, objectList, sectionName);
    for(ContactPointPhone phoneData: [select id,Name from ContactPointPhone where isprimary=true and parentId =:parentId ]){
    	primaryContactPointPhone.put(phoneData.id,phoneData.Name);
        }
}

private static void handleSectionSpecificProcessing(String jsonString, String screenName, String sectionName, String parentId, List<AOB_Field__c> screenFieldList) {

    switch on sectionName {
        when 'Assets and Income' {

            ICS_CTRL_DML_OnboardingAI.processData(jsonString, screenName, sectionName, parentId, getAssessmentScreenData(screenFieldList));
        }
        when 'Future Deposits' {
           ICS_CTRL_DML_OnboardingFD.processData(jsonString, screenName, sectionName, parentId, getAssessmentScreenData(screenFieldList));
        }
        when 'Trusts' {
            ICS_CTRL_TrustDataProcessor.processTrustData(jsonString, parentId);
        }
        when 'Tax Certificates' {
            ICS_CTRL_DML_TaxDetails.insertTaxDetails(jsonString, parentId);
        }
        when else {
            insertData(parentId, screenFieldList, sectionName);
        }
    }
}
 @TestVisible
private static List<AOB_Field__c> getAssessmentScreenData(List<AOB_Field__c> screenFieldList) {
    List<AOB_Field__c> assessmentScreenData = new List<AOB_Field__c>();
    for (AOB_Field__c field : screenFieldList) {
        if (field.AOB_SFObject__c == 'Assessment') {
            assessmentScreenData.add(field);
        }
    }
    return assessmentScreenData;
}

public static void insertData(String parentId, List<AOB_Field__c> screenFieldList, String sectionName) {
    Map<String, Decimal> conversionMap = buildConversionMap();
    Map<String, SObject> objectMap = initializeObjects();


    processFields(objectMap, sectionName, conversionMap, masterDetailMap,parentId);

    sortObjects(objectMap,  existingIds);

    handleInserts( parentId, sectionName, masterDetailMap);
    handleUpdates( parentId, sectionName);

    handleCrossObjectInserts(parentId, sectionName);
}

private static Map<String, Decimal> buildConversionMap() {
    Map<String, Decimal> conversionMap = new Map<String, Decimal>();
    for (CurrencyType ct : currencyTypes) {
        conversionMap.put(ct.IsoCode, ct.ConversionRate);
    }
    return conversionMap;
}

public static Map<String, SObject> initializeObjects() {
    Map<String, SObject> objectMap = new Map<String, SObject>();

    for (String objectName : objectWithFieldAPINames.keySet()) {
        objectMap.put(objectName, Schema.getGlobalDescribe().get(objectName).newSObject());
    }
    return objectMap;
}

private static void processFields(Map<String, SObject> objectMap,
                                  String sectionName, Map<String, Decimal> conversionMap,
                                  Map<String, String> masterDetailMap,string parentId

                                 ) {
                                    SEL_Account accSelector = new SEL_Account();
                                    Account accountInfo = accSelector.selectById(parentId);       
                                    for (String objectName : objectWithFieldAPINames.keySet()) {
                                        for (AOB_Field__c fieldData : objectWithFieldAPINames.get(objectName)) {
                                            SObject sObj = objectMap.get(objectName);
                                            if(objectName == 'Party_Assets_Funds__c'){
                                                sObj.put('OwnerId',accountInfo.ownerId);
                                                sObj.put('Name',sectionName);
                                            }
                                            processField(sObj, fieldData, sectionName, conversionMap, masterDetailMap, objectName);
                                        }
                                    }
    assessmentQuestionsList =[select id,name,ActiveVersionId,QuestionText from AssessmentQuestion
    where name in: responseDatamap.keyset()];
}

private static void processField(SObject sObj, AOB_Field__c fieldData, String sectionName,
                                 Map<String, Decimal> conversionMap, Map<String, String> masterDetailMap,

                                  String objectName) {
    String fieldName = fieldData.AOB_SFField__c;

    if (fieldData.AOB_Type__c == ICS_Constants.MasterDetail) {
        masterDetailMap.put(objectName, fieldName);
    }
    if (isProcessableField(fieldData)) {
        if (sectionFieldData.containsKey(fieldData.Name) && fieldData.AOB_SFObject__c != null ) {
            processRegularField(sObj, fieldData, sectionName, conversionMap, objectName);
        }
    } else if (fieldData.AOB_Type__c == 'Lookup' && fieldData.AOB_SFObject__c != 'Assessment') {
        processLookupField(sObj, fieldData);
    }
}

private static boolean isProcessableField(AOB_Field__c fieldData) {

    return (fieldData.AOB_Type__c != 'Lookup' && fieldData.AOB_Type__c != ICS_Constants.MasterDetail)
        || (fieldData.AOB_Type__c == 'Lookup' && fieldData.AOB_SFObject__c == ICS_Constants.ASSESSMENTTEXT)||fieldData.AOB_SFObject__c == ICS_Constants.ASSESSMENTTEXT;
}

private static void processRegularField(SObject sObj, AOB_Field__c fieldData, String sectionName,
                                        Map<String, Decimal> conversionMap,

                                         String objectName) {
    if (objectName == ICS_Constants.ASSESSMENTTEXT) {
         processAssessmentField(fieldData,conversionMap);

    } else {
       processNonAssessmentField(sObj, fieldData, sectionName, conversionMap,  objectName);
    }
}

private static void processNonAssessmentField(SObject sObj, AOB_Field__c fieldData, String sectionName,
                                              Map<String, Decimal> conversionMap,
                                               String objectName) {
    invokeCrossObjects = true;
    invokeDML = true;
    String fieldName = fieldData.AOB_SFField__c;
    String aobScreenfieldName = fieldData.name;
    String fieldType = getFieldType(sObj, fieldName);

    if (objectName != 'ContactPointPhone') {
        sObj.put('CurrencyISOCode', 'GBP');
    }

    handleSpecialCases(sObj, fieldData, sectionName, fieldName);
    setFieldValue(sObj, fieldName, sectionFieldData.get(fieldData.Name), fieldType, conversionMap,aobScreenfieldName);
}

private static void processAssessmentField(AOB_Field__c fieldData,Map<String, Decimal> conversionMap) {
    AssessmentQuestionResponse responseInfo = new AssessmentQuestionResponse();
     if(fieldData.Name == 'Amount of your initial deposit'){
         
         String isoCode = '';
       
         
         if (sectionFieldData.containsKey(fieldData.Name + 'Currency')) {
             isoCode = (String) sectionFieldData.get(fieldData.Name + 'Currency');
         }
         
         Decimal convertedAmount = ICS_CTRL_DML_OnboardingDetails.mapCurrency(
             fieldData.Name,
             Decimal.valueOf(String.valueOf( (String) sectionFieldData.get(fieldData.Name))),
             isoCode,
             conversionMap
         );
         responseInfo.ResponseText = string.valueof(convertedAmount);
     }else{
    	responseInfo.ResponseText = (String)sectionFieldData.get(fieldData.Name);
     }
    responseInfo.Id = (String)sectionFieldData.get(fieldData.Name+':Id');
   String key;
    if (fieldData.AOB_Label__c == null ) {
        key = fieldData.Name;
    } else {
        key = fieldData.AOB_Label__c;
    }
    responseDataMap.put(key, responseInfo);
}

private static void processLookupField(SObject sObj, AOB_Field__c fieldData) {
    String fieldName = fieldData.AOB_SFField__c;
    if (fieldData.Default_Value__c == null) {
        setLinkedLookupValue(sObj, fieldName);
    } else  {

        setDefaultLookupValue(sObj, fieldName, fieldData);
    }
}

private static void setDefaultLookupValue(SObject sObj, String fieldName, AOB_Field__c fieldData) {
    if (fieldName == 'RecordTypeId') {
        String recId = Schema.getGlobalDescribe().get(fieldData.AOB_SFObject__c).getDescribe()
            .getRecordTypeInfosByName().get(fieldData.Default_Value__c).getRecordTypeId();
        sObj.put(fieldName, recId);
    } else if (fieldName == 'Main_Account__c') {
        sObj.put(fieldName, Boolean.valueOf(fieldData.Default_Value__c));
    } else {
        sObj.put(fieldName, fieldData.Default_Value__c);
    }
}

private static void setLinkedLookupValue(SObject sObj, String fieldName) {
    if(fieldName.contains(';')){
    String[] parts = fieldName.split(';');
    if (linkedmap.containsKey(parts[1])) {
        sObj.put(parts[0], linkedmap.get(parts[1]));
    }
}
}

private static void handleSpecialCases(SObject sObj, AOB_Field__c fieldData, String sectionName, String fieldName) {
    if (sectionName == 'Current Residential Address') {
        handleResidentialAddressCase(sObj, fieldName);
    }

    if (fieldData.AOB_SFObject__c == 'PartyProfile') {
        handlePartyProfileSpecialCases(sObj);
    }
}
 @TestVisible
private static void handleResidentialAddressCase(SObject sObj, String fieldName) {
    if (fieldName == 'ProvinceName' && sectionFieldData.get('ProvinceName') != null) {
        sObj.put(fieldName, String.valueOf(sectionFieldData.get('ProvinceName')));
    } else if (fieldName == 'Province' && sectionFieldData.get('Province') != null) {
        sObj.put(fieldName, String.valueOf(sectionFieldData.get('Province')));
    }
}

private static void handlePartyProfileSpecialCases(SObject sObj) {
    handleFormerOrMaidenName(sObj);
    handleOtherNames(sObj);
    handleMaritalStatus(sObj);
}

private static void handleFormerOrMaidenName(SObject sObj) {
    if (sectionFieldData.containsKey('Former Name or Maiden Name')) {
        String formerOrMaidenName = (String)sectionFieldData.get('Former Name or Maiden Name');
        Boolean hasFormerName = formerOrMaidenName == 'FormerName' || formerOrMaidenName == 'FormerAndMaiden';
        Boolean hasMaidenName = formerOrMaidenName == 'MaidenName' || formerOrMaidenName == 'FormerAndMaiden';
        sObj.put('Has_Former_Name__c', hasFormerName ? 'Yes' : 'No');
        sObj.put('Has_Maiden_Name__c', hasMaidenName ? 'Yes' : 'No');
    }
}

private static void handleOtherNames(SObject sObj) {
    if (sectionFieldData.containsKey('Other Names')) {
        String otherNames = (String)sectionFieldData.get('Other Names');
        if(otherNames == 'None'){
            sObj.put('Has_different_First_Middle_Family_Name__c','No');
                     }else{
                         sObj.put('Has_different_First_Middle_Family_Name__c','Yes');
                     }
    }
}

private static void handleMaritalStatus(SObject sObj) {
    if (sectionFieldData.containsKey('Marital Status')) {
        Map<String, String> maritalStatusMap = ICS_CTRL_FetchTrustDataProcessor.getMaritalStatusMap();
        String maritalStatus = (String)sectionFieldData.get('Marital Status');
        sObj.put('WI_MaritialStatus__c', maritalStatusMap.get(maritalStatus));
    }
}

private static void setFieldValue(SObject sObj, String fieldName, Object fieldValue, String fieldType,
                                  Map<String, Decimal> conversionMap,string aobScreenfieldName) {
    switch on fieldType.toLowerCase() {
        when 'currency', 'double', 'percent', 'decimal' {
            setNumericValue(sObj, fieldName, fieldValue, fieldType, conversionMap,aobScreenfieldName);
        }
        when 'boolean' {
            sObj.put(fieldName, Boolean.valueOf(fieldValue));
        }
        when 'date' {
            setDateValue(sObj, fieldName, (String)fieldValue);
        }
        when else {

            setStringValue(sObj, fieldName, fieldValue);
        }
    }
}

private static void setNumericValue(SObject sObj, String fieldName, Object fieldValue, String fieldType,
                                    Map<String, Decimal> conversionMap,string aobScreenfieldName) {
    if (fieldType == 'currency') {
        String isoCode = (String)sectionFieldData.get(aobScreenfieldName + 'Currency');
        if(isoCode != null){
            Decimal convertedAmount = mapCurrency(fieldName, Decimal.valueOf((String)fieldValue), isoCode, conversionMap);
            sObj.put(fieldName, convertedAmount);
        }
    } else {
        sObj.put(fieldName, Decimal.valueOf((String)fieldValue));
    }
}

private static void setDateValue(SObject sObj, String fieldName, String dateString) {
    if (dateString == null) {
        Schema.DescribeFieldResult fieldDescribe = sObj.getSObjectType()
        .getDescribe().fields.getMap().get(fieldName).getDescribe();
    
    if (fieldDescribe.getType() == Schema.DisplayType.String) {
        sObj.put(fieldName, '');
    } else {
        sObj.put(fieldName, null);
    }
    }else{
        String[] dateParts = dateString.split('-');
        Date formattedDate = Date.newInstance(Integer.valueOf(dateParts[0]),
                                              Integer.valueOf(dateParts[1]),
                                              Integer.valueOf(dateParts[2]));
        sObj.put(fieldName, formattedDate);
    }
}

private static void setStringValue(SObject sObj, String fieldName, Object fieldValue) {
    if (fieldValue == 'TRUE') {
        sObj.put(fieldName, 'Yes');
    } else if (fieldValue == 'FALSE') {
        sObj.put(fieldName, 'No');
    } else {
        sObj.put(fieldName, (String)fieldValue);
    }
}

private static void sortObjects(Map<String, SObject> objectMap, Set<Id> existingIds) {
    for (String objectName : objectMap.keySet()) {
        SObject sObj = objectMap.get(objectName);
        processObject(sObj, objectName, existingIds);
    }
}

private static void processObject(SObject sObj, String objectName, Set<Id> existingIds) {
    if (shouldUpdate(objectName)) {
        addToUpdatesList(sObj, updatesObjList, existingIds, objectName);
    } else if (shouldInsert(objectName)) {
        handleInsert(sObj, objectName);
    }
}

private static boolean shouldUpdate(String objectName) {
    return invokeDML && (sectionFieldData.containsKey('Id') || sectionFieldData.containsKey(objectName));
}

private static boolean shouldInsert(String objectName) {
    return invokeDML &&
           objectName != 'IdentityDocument' &&
           objectName != ICS_Constants.ASSESSMENTTEXT &&
           !sectionFieldData.isEmpty();
}

private static void handleInsert(SObject sObj, String objectName) {
    if (!isSpecialContactPointPhone(objectName)) {
        insertsObjList.add(sObj);
    }
}

private static boolean isSpecialContactPointPhone(String objectName) {
    return objectName == 'ContactPointPhone' &&
           primaryContactPointPhone.containsKey((String)sectionFieldData.get(objectName));
}



private static void addToUpdatesList(SObject sObj, List<SObject> updatesList, Set<Id> existingIds, String objectName) {
    if (sectionFieldData.containsKey(objectName) && objectName != ICS_Constants.ASSESSMENTTEXT) {
        sObj.put('Id', sectionFieldData.get(objectName));
        updatesList.add(sObj);
    } else if (sectionFieldData.containsKey('Id') && objectName != ICS_Constants.ASSESSMENTTEXT) {
        String id = (String)sectionFieldData.get('Id');
        if (!existingIds.contains(id)) {
            sObj.put('Id', id);
            updatesList.add(sObj);
            existingIds.add(id);
        }
    }

}



private static void handleInserts( String parentId,
                                  String sectionName, Map<String, String> masterDetailMap) {
                                      if (insertsObjList.isEmpty()){
                                           return;
                                      }

    List<SObject> masterDetailObjects = new List<SObject>();
    List<Integer> removeIndexes = new List<Integer>();



    for (Integer i = 0; i < insertsObjList.size(); i++) {
        SObject obj = insertsObjList[i];

        String objectName = obj.getSObjectType().getDescribe().getName();
        if (masterDetailMap.containsKey(objectName)) {
            removeIndexes.add(i);
            masterDetailObjects.add(obj);

        }
    }

    for (Integer i = removeIndexes.size() - 1; i >= 0; i--) {
        insertsObjList.remove(removeIndexes[i]);
    }

    insertRegularObjects( parentId, sectionName);
    insertMasterDetailObjects(masterDetailObjects, masterDetailMap);
}

private static void insertRegularObjects( String parentId, String sectionName) {
    List<Database.SaveResult> saveResultList = Database.insert(insertsObjList, false);
    string assId = checkAssessment(parentId);
    for (Database.SaveResult saveResult : saveResultList) {
        if (saveResult.isSuccess()) {
            Id insertedRecordId = saveResult.getId();
            insertAssessmentResponseData(parentId, sectionName, insertedRecordId,assId);
            updateLinkedMap(insertedRecordId, parentId);
        }
    }
    if(responseList.size()>0){

        Insert responseList;
    }
    if(updtaeResponseList.size()>0){
        update updtaeResponseList;
    }
}
private static string  checkAssessment(string parentId){
    SEL_Account selectorAccountInfo = new SEL_Account();
    Account acc= selectorAccountInfo.selectById(parentId);
    sel_assesment selectorAssInfo = new sel_assesment();
        List<Assessment> assDataList = new List<Assessment>();
        Assessment assData = new Assessment();
        assDataList= selectorAssInfo.SelectByAccountId(parentId);
        if(assDataList.size()==0){
            assData.Name=acc.Name+' Assessment';
            assData.AssessmentStatus = 'In Progress';
            assData.AccountId = parentId;
            insert assData;
        }else{
            assData =  assDataList[0];

        }

        return assData.id;
}
private static void updateLinkedMap(Id insertedRecordId, Id parentId) {
    String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
    if (linkedMap.containsKey(objectName)) {
        String existingId = linkedMap.get(objectName);
        linkedMap.put(objectName, existingId + ':' + insertedRecordId);
    } else {
         linkedMap.put(objectName, insertedRecordId);
        linkedMap.put('Account', parentId);
    }
}

private static void insertMasterDetailObjects(List<SObject> masterDetailObjects, Map<String, String> masterDetailMap) {
    for (SObject masterObj : masterDetailObjects) {
        String objectName = masterObj.getSObjectType().getDescribe().getName();
        String lookupFieldName = masterDetailMap.get(objectName);
        String[] lookupParts = lookupFieldName.split(ICS_Constants.SemiColon);
        masterObj.put(lookupParts[0], linkedMap.get(lookupParts[1]));
    }

    List<Database.SaveResult> mSaveResultList = Database.insert(masterDetailObjects, false);
    for (Database.SaveResult saveResult : mSaveResultList) {
        if (saveResult.isSuccess()) {
            mapLookupData(saveResult.getId());
        }
    }
    if (!sobjectListUpdate.isEmpty()) {
        update sobjectListUpdate;
    }
}

private static void handleUpdates( String parentId, String sectionName) {
    if (updatesObjList.isEmpty()) {return;}
    string assId = checkAssessment(parentId);
    List<Database.SaveResult> saveResultList = Database.update(updatesObjList, false);
    for (Database.SaveResult saveResult : saveResultList) {
        if (saveResult.isSuccess()) {
            String updatedRecordId = saveResult.getId();
            insertAssessmentResponseData(parentId, sectionName, updatedRecordId,assId);
        }
    }

    if(responseList.size()>0){
        Insert responseList;
    }
    if(updtaeResponseList.size()>0){
        update updtaeResponseList;
    }
}

private static void handleCrossObjectInserts(String parentId, String sectionName) {

    if (invokeCrossObjects == false && !responseDataMap.isEmpty()) {
        string assId = checkAssessment(parentId);
        insertAssessmentResponseData(parentId, sectionName, null,assId);
        if(responseList.size()>0){
            Insert responseList;
        }
        if(updtaeResponseList.size()>0){
            update updtaeResponseList;
        }
    }

}




private static String getFieldType(SObject sObj, String fieldName) {
    SObjectType objectType = sObj.getSObjectType();
    DescribeSObjectResult describeResult = objectType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
    Schema.DescribeFieldResult fieldDescribe = fieldMap.get(fieldName).getDescribe();
    return fieldDescribe.getType().name().toLowerCase();
}



    public static decimal mapCurrency(string fieldName,decimal jsonAmount,string isocode,map<string,decimal>conversionMap){
        decimal convertedAmount=0;

        string[] responseInfo;

        if (isValidIsoCode(isoCode)) {
            isoCode = extractBaseIsoCode(isoCode);
            convertedAmount = ICS_CTRL_CurrencyConverter.convertToDefaultCurrency(jsonAmount, isoCode, conversionmap);
        } else {
            convertedAmount = jsonAmount;
        }
        return convertedAmount;
    }
    private static boolean isValidIsoCode(String code) {
        return code != null ;
    }

    private static String extractBaseIsoCode(String code) {
        return code.contains(':') ? code.split(':')[0] : code;
    }

    @testVisible
    private static void mapLookupData(id insertedRecordId){
        String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
        if (linkedMap.containsKey(objectName)) {

            String existingIds = linkedMap.get(objectName);
            linkedMap.put(objectName, existingIds + ':' + insertedRecordId);

        } else {
             linkedMap.put(objectName, insertedRecordId);
        }
        updateLookup();
    }

    Public static void insertAssessmentResponseData(string parentId,string sectionName,string recordId,string assId){

        responseList = new List<AssessmentQuestionResponse>();
       updtaeResponseList = new List<AssessmentQuestionResponse>();

        for(AssessmentQuestion assQuestion: assessmentQuestionsList){
                                                 if(responseDataMap.containskey(assQuestion.Name)){

                                                     AssessmentQuestionResponse responseData = responseDataMap.get(assQuestion.Name);

                                                    AssessmentQuestionResponse responseInfo = new AssessmentQuestionResponse();
                                                     responseInfo = responseData;
                                                     if(recordId == null){
                                                         responseInfo.Name= sectionName;

                                                     }else{
                                                          responseInfo.Name= sectionName+':'+recordId;
                                                     }
                                                     responseData.AssessmentQuestionId = assQuestion.ActiveVersionId;
                                                     if(sectionFieldData.keyset().contains(assQuestion.QuestionText+':Id')){
                                                         	responseInfo.id= (string)sectionFieldData.get(assQuestion.QuestionText+':Id');
                                                         	updtaeResponseList.add(responseInfo);
                                                     }else{

                                                         if(responseInfo.id ==null) {
                                                             responseInfo.AssessmentId =assId;
                                                             responseList.add(responseInfo);
                                                         }

                                                     }
                                                 }
                                             }

    }
    public static void updateLookup() {
        sobjectListUpdate= new List<sobject>();
        for (String fieldKey : lookupFields.keySet()) {
            List<SObject> objectsToUpdate = processFieldKey(fieldKey);
            sobjectListUpdate.addAll(objectsToUpdate);
        }


    }

    private static List<SObject> processFieldKey(String fieldKey) {
        List<SObject> objectsToUpdate = new List<SObject>();

        if (!linkedmap.containsKey(fieldKey)) {
            return objectsToUpdate;
        }

        String fieldValue = linkedmap.get(fieldKey);

        if (fieldValue.contains(':')) {
            objectsToUpdate.addAll(processMultipleIds(fieldKey, fieldValue));
        } else {
            SObject singleObject = processSingleId(fieldKey, fieldValue);
            if (singleObject != null) {
                objectsToUpdate.add(singleObject);
            }
        }

        return objectsToUpdate;
    }

    private static List<SObject> processMultipleIds(String fieldKey, String fieldValue) {
        List<SObject> objectsToUpdate = new List<SObject>();

        for (String singleId : fieldValue.split(':')) {
            SObject obj = createSObjectWithId(singleId);
            updateLookupFields(obj, fieldKey);
            objectsToUpdate.add(obj);
        }

        return objectsToUpdate;
    }

    private static SObject processSingleId(String fieldKey, String fieldValue) {
        SObject obj = createSObjectWithId(fieldValue);
        updateLookupFields(obj, fieldKey);
        return obj;
    }

    private static SObject createSObjectWithId(String recordId) {
        Id id = recordId;
        String objectName = id.getSObjectType().getDescribe().getName();
        SObjectType objectType = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
        SObject sObj = objectType.newSObject();
        sObj.put('Id', id);
        return sObj;
    }

    private static void updateLookupFields(SObject obj, String fieldKey) {
        for (String lookupField : lookupFields.get(fieldKey)) {
            String[] parts = lookupField.split(';');
            String fieldApiName = parts[0];
            String linkedFieldKey = parts[1];

            if (linkedmap.containsKey(linkedFieldKey)) {
                obj.put(fieldApiName, linkedmap.get(linkedFieldKey));
            }
        }
    }
}