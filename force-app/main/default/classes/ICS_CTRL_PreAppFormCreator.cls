/**
* @description class used as controller for  SBO-UK PreApplication Feature
*
* Story:SFP-36380,SFP-31025
*
* @author Ikyatha Naidu
*
* @date May 2023
* @last modified on  : 07-15-2025
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-36380,SFP-31025 class used as controller for SBO-UK PreApplication
* @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 18-03-2025
* @Modification description : SFP-55521 updated for join account
***************************************************************************************
* @last modified on  : 17-04-2025
* @last modified by  : Sai Pranay Poona
* @Modification Description : SFP-57520 Removed describe calls for account and opportunity
***************************************************************************************
* @last modified on  : 20-04-2025
* @last modified by  : Sai Pranay Poona
* @Modification Description : Published platform event to create ACR - this change is done to remediate guest user access issue.
*/
public without sharing class ICS_CTRL_PreAppFormCreator {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(ICS_Constants.ICS_CTRL_PreAppFormCreator);
	 private static final Id JOINT_ACCOUNT_RT_ID = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('CMN_Joint_Account')
        .getRecordTypeId();
    public static Map<String,List<String>> lookupFields = new Map<String,List<String>>();
    public static Map<string,string> labelInfo = new Map<string,string>();
    public static Map<string,string> linkedMap = new Map<String,String>();
    public static Map<string,string> masterDetailMap = new Map<String,String>();
    public static string opportunityId;
    public static string pCode;
    public static string ownerId;
    Public static string oppOwnerId;
    Public static String cor;
    Public static Map<String, Object> sectionFieldData = new Map<String, Object>();
    private static final String MAIN_COR = 'maincor';
	 /**
* @description Used for fetching the details of screen fields based on screenName
* @param screenName
* @return AOB_DTO_Form
*/
    @AuraEnabled
    public static AOB_DTO_Form fetchScreenFields(String screenName) {
        try{
        AOB_DTO_Form form = new AOB_DTO_Form();
        String language = AOB_BOTS_Utils.getUserLanguage();
        language = language == ICS_Constants.en_US ? ICS_Constants.EN : language;

        Set<Id> sectionIds = new Set<Id>();
        form.sections = fetchSectionsByScreenName(screenName, sectionIds);


        Map<Id, List<AOB_DTO_Field>> sectionFields = fetchSectionFields(sectionIds, language);

        for (AOB_DTO_Section section : form.sections) {
            List<AOB_DTO_Field> sortedFields = sectionFields.get(section.identifier);
            if (sortedFields != null) {
                sortedFields.sort();
            }
            section.fields = sortedFields;
        }

        return form;
        }catch(Exception e){
            LOGGER.error('Error in fetchScreenFields' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<AOB_DTO_Section> fetchSectionsByScreenName(String screenName, Set<Id> sectionIds) {
        List<AOB_DTO_Section> sections = new List<AOB_DTO_Section>();
        for (AOB_ScreenSection__c section : new SEL_AOBSection().selectSectionsByScreenName(screenName)) {
            AOB_DTO_Section jsSection = setSectionInfo(section);
            sections.add(jsSection);
            sectionIds.add(section.id);
        }
        if (sectionIds.isEmpty()) {
            throw new AuraHandledException(ICS_Constants.Unabletofind);
        }
        return sections;
    }

    private static Map<Id, List<AOB_DTO_Field>> fetchSectionFields(Set<Id> sectionIds, String language) {
        Map<Id, List<AOB_DTO_Field>> sectionFields = new Map<Id, List<AOB_DTO_Field>>();
        List<String> mriTables = new List<String>();
        for (AOB_Field__c field : new SEL_AOBField().selectMRITablesByLanguage(sectionIds, language)) {
            mriTables.add(field.AOB_MRITable__c);
        }
        Map<String, List<AOB_DTO_SelectOption>> refData = AOB_BOTS_Utils.getAllPicklistEntriesCodes(mriTables);

        for (AOB_Field__c field : new SEL_AOBField().selectFieldsBySection(sectionIds)) {
            AOB_DTO_Field jsField = new AOB_DTO_Field(field, null);
            jsField.options = refData.get(field.AOB_MRITable__c);
            if (!sectionFields.containsKey(field.AOB_Section__c)) {
                sectionFields.put(field.AOB_Section__c, new List<AOB_DTO_Field>());
            }
            sectionFields.get(field.AOB_Section__c).add(jsField);
        }

        if (sectionFields.isEmpty()) {
            throw new AuraHandledException(ICS_Constants.Unabletofindany);
        }
        return sectionFields;
    }

    @TestVisible
    private static AOB_DTO_Section setSectionInfo(AOB_ScreenSection__c section) {
        AOB_DTO_Section sectionInfo = new AOB_DTO_Section();
        sectionInfo.identifier = section.id;
        sectionInfo.title = section.AOB_Title__c;
        sectionInfo.sectionName = section.Name;
        sectionInfo.smallDeviceColumns = section.AOB_smallDeviceColumns__c;
        sectionInfo.mediumDeviceColumns = section.AOB_mediumDeviceColumns__c;
        sectionInfo.largeDeviceColumns = section.AOB_largeDeviceColumns__c;
        sectionInfo.rank = section.AOB_Rank__c;
        sectionInfo.gridClass = 'aob_form_input slds-col slds-m-top_small slds-small-size_1-of-' + sectionInfo.smallDeviceColumns +
                                ' slds-medium-size_1-of-' + sectionInfo.mediumDeviceColumns +
                                ' slds-large-size_1-of-' + sectionInfo.largeDeviceColumns;
        return sectionInfo;
    }
	 /**
* @description Used for fetching the details of Sanctioned Currencies based on countryofResidence
* @param countryofResidence
* @return List<string>
*/
    @AuraEnabled
    public static List<string> returnSanctionedCurrencies(string countryofResidence) {
        try{
        Map<string,List<String>> currenciesMap = new Map<string,List<String>>();
        Map<string,List<String>> countryCurrencyMap = new Map<string,List<String>>();
        Map<String, ICS_SanctionedCurrencies__mdt> sanctionedCurrenciesMap = ICS_SanctionedCurrencies__mdt.getAll();

        for(string currencyMap : sanctionedCurrenciesMap.keySet()) {
            countryCurrencyMap.put(sanctionedCurrenciesMap.get(currencyMap).Country_Of_Residence__c,
                                   sanctionedCurrenciesMap.get(currencyMap).Sanctioned_Currencies__c.split(','));
        }

        List<string> jointaccountCurrencies = countryofResidence.contains(';') ? countryofResidence.split(';') : new List<string>{countryofResidence};

        for(string country : jointaccountCurrencies) {
            if(countryCurrencyMap.containskey(country)) {
                currenciesMap.put(country, countryCurrencyMap.get(country));
            } else if(countryCurrencyMap.containskey(ICS_Constants.noneText)) {
                currenciesMap.put(country, countryCurrencyMap.get(ICS_Constants.noneText));
            }
        }

        Set<String> commonElements = checkCommonElements(currenciesMap);
        List<string> finalCurrencies = new List<string>(commonElements);

        if(finalCurrencies.isEmpty()){
            throw new AuraHandledException(ICS_Constants.UnabletofindanyCurrencyList);
        }
        return finalCurrencies;
        }catch(Exception e){
            LOGGER.error('Error in returnSanctionedCurrencies' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static set<string> checkCommonElements(Map<string,List<string>> inputMap) {
        set<String> commonElements = new set<String>();
        if (inputMap.isEmpty()) {
            return commonElements;
        }
        Boolean isFirstIteration = true;
        for (String key : inputMap.keySet()) {
            if (isFirstIteration) {
                commonElements.addAll(inputMap.get(key));
                isFirstIteration = false;
            } else {
                set<String> currentSet = new set<String>(inputMap.get(key));
                commonElements.retainAll(currentSet);
            }
            if (commonElements.isEmpty()) {
                break;
            }
        }
        return commonElements;
    }
		 /**
* @description Used for validate the Manager Code based on country and salescode
* @param country
* @param salesCode
* @return boolean
*/
   @AuraEnabled
    public static boolean validateSBManagerCode(string country, string salesCode) {
		ics_customlabel__mdt labelData = getLandingPageJSON('Preapplication');
        labelInfo = (Map<string,string>)json.deserialize(labelData.Description__c, map<string,string>.class);
        try{
             sel_Sales_Code selectorCodeData = new sel_Sales_Code();
            Set<String> africanCountries = new Set<String>(
            		labelInfo.get('ics_africanexcludesbmanagercode').split(',')
       		 );
             List<Sales_Codes__c> codeInfo = new List<Sales_Codes__c>();
            if(africanCountries.contains(salesCode)){
                codeInfo = selectorCodeData.selectByName(salesCode);  
            }else{
               codeInfo = selectorCodeData.selectByNameAndSalesCodeCountry(salesCode, country);
            }
       
           
       
        return !codeInfo.isEmpty();
        }catch(Exception e){
             LOGGER.error('Error in validateSBManagerCode' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
         /**
    * @description Used to fetch the product details based on product code
    * @param produtCode
    * @return string
    */
    @AuraEnabled
    public static string fetchProdutDetails(string produtCode) {
        try{
        SEL_Product2 selectorProdData = new SEL_Product2();
        List<Product2> productData = selectorProdData.selectByProductCode(produtCode);
        for(Product2 prodData: productData) {
            if(prodData.productCode == produtCode) {
                return prodData.Name;
            }
        }
        return ICS_Constants.Product_ErrorMessage;
        }catch(Exception e){
         LOGGER.error('Error in fetchProdutDetails' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
	  /**
    * @description Used to checking the existing user or not based on JsonData
    * @param jsonData
    * @return string
    */
    @AuraEnabled 
    public static string checkExitingData(string jsonData) {
        Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

        try {
            SEL_Product2 selectorProductData = new SEL_Product2();
            List<Product2> prodList = selectorProductData.selectByProductCode((String)parsedJson.get(ICS_Constants.productCode));
            
            if (!isActiveProduct(prodList)) {
                return ICS_Constants.noProduct;
            }

            SEL_Account selectorAccountData = new SEL_Account();
            List<Account> accList = selectorAccountData.selectByFirstLastNameBirthday(jsonData);
            
            if (accList.isEmpty()) {
                return ICS_Constants.NewData;
            }

            Account accData = accList[0];
            if (accData.ExternalCIFId__c != null) {
                return ICS_Constants.Duplicate;
            }

            return resolveOpportunityStatus(accData);

        } catch (Exception e) {
            LOGGER.error(ICS_Constants.ErrorcheckExitingData + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean isActiveProduct(List<Product2> prodList) {
        return !prodList.isEmpty() && prodList[0].isActive;
    }

    private static String resolveOpportunityStatus(Account accData) {
        SEL_Opportunity selectOpportunityData = new SEL_Opportunity();
        List<Opportunity> oppList = selectOpportunityData.selectByAccountId(accData.Id);

        if (oppList.isEmpty()) {
            return ICS_Constants.Duplicate;
        }
        return oppList[0].isWon ? ICS_Constants.Duplicate : ICS_Constants.Multiple;
    }
	  /**
    * @description Used to get the productId based on product code
    * @param productCode
    * @return string
    */
    public static string fetchProductId(string productCode) {
        try {
            SEL_Product2 selectorProdData = new SEL_Product2();
            List<Product2> productData = selectorProdData.selectByProductCode(productCode);
            for(Product2 prodData: productData) {
                if(prodData.productCode == productCode) {
                    return prodData.id;
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error in fetchProductId' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return '';
    }
	  /**
    * @description Used to get the countryCode Map based on countryCode
    * @param countryCode
    * @return string
    */
    @AuraEnabled
    public static string countryCodeMap(string countryCode) {
        try{
        map<string,string> countrycodeMap = new map<string,string>();
        Schema.DescribeFieldResult fieldResult = partyprofile.Country_of_Residence__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            countrycodeMap.put(f.getValue(), f.getLabel());
        }
        return countrycodeMap.containsKey(countryCode) ? countrycodeMap.get(countryCode) : '';
        }Catch(Exception e){
            LOGGER.error('Error in countryCodeMap: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
	  /**
    * @description Used to insert the data for the different objects based on Json Data
    * @param data
    * @param opportunityRec
    * @param productCode
    * @return string
    */
    @AuraEnabled
    public static string insertData(String data, string opportunityRec, string productCode) {
        try{
            ics_customlabel__mdt labelData = getLandingPageJSON('Preapplication');
            labelInfo = (Map<string,string>)json.deserialize(labelData.Description__c, map<string,string>.class);

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(data);
            Map<String, Object> personalInputData = (Map<String, Object>)json.deserializeUntyped((string)jsonMap.get('personalInputData'));
            Map<String, Object> contactInputData = (Map<String, Object>)json.deserializeUntyped((string)jsonMap.get('contactInputData'));
            Map<String, Object> residentialInputData = (Map<String, Object>)json.deserializeUntyped((string)jsonMap.get('residentialInputData'));
            Map<String, Object> accountInputData = (Map<String, Object>)json.deserializeUntyped((string)jsonMap.get('accountInputData'));
            Boolean isJoint = (boolean)jsonMap.get('isJoint');
            masterDetailMap = new Map<String,String>();
            pCode = productCode;

            if(String.isNotBlank(opportunityRec)) {
                linkedmap.put(ICS_Constants.opportunityObj, opportunityRec);
            }

            if (personalInputData != null) {
                processScreenData(ICS_Constants.prePersonalScreen, ICS_Constants.prePersonalSection, opportunityRec, personalInputData, isJoint);
                processScreenData(ICS_Constants.preContactScreen, ICS_Constants.preContactSection, opportunityRec, contactInputData, isJoint);
                processScreenData(ICS_Constants.PREADDRESSSCREEN, ICS_Constants.preAddresssSection, opportunityRec, residentialInputData, isJoint);
                processScreenData(ICS_Constants.preAccountScreen, ICS_Constants.PREACCOUNTSECTION, opportunityRec, accountInputData, isJoint);
                updateLookup();

            }

            opportunityId = linkedMap.containsKey(ICS_Constants.Opportunity) ? linkedMap.get(ICS_Constants.Opportunity) : null;
            return opportunityId;
        }Catch(Exception e){
            LOGGER.error('Error in countryCodeMap: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
   @TestVisible
    private static void processScreenData(String screenName, String sectionName, String opportunityRec, Map<String, Object> inputData, Boolean isJointAcc) {
        if (inputData == null) {
            return;
        }
        if(screenName == ICS_Constants.prePersonalScreen){
             String salesCode = getSalesCode(inputData);
                 if(checkIsIFA() ==true){
                 ownerId =getTheOwnerIdForIFA();
             }else{

                  ownerId =getOwnerId(salesCode);
             }
        }
        Map<String, Object> jsonDataMap = new Map<String, Object>{
            'screenName' => screenName,
            'sectionName' => sectionName,
            'opportunityRec' => opportunityRec,
            'insertDML' => ICS_Constants.insertDML,
            'isJointAcc' => isJointAcc
        };
        String jsonString = JSON.serialize(jsonDataMap);
        performOnboardingDMLInfo(jsonString, inputData);
    }

    public static void updateLookup() {
        try {
            List<SObject> sobjectListUpdate = new List<SObject>();
            for (String fieldKey : lookupFields.keySet()) {
                if (!linkedmap.containsKey(fieldKey)) {
                    continue;
                }
                Id recordId = (Id) linkedmap.get(fieldKey);
                SObject sObjectToLookup = createSObjectForLookup(recordId);

                for (String lookupField : lookupFields.get(fieldKey)) {
                    processLookupField(lookupField, sObjectToLookup);
                }

                sobjectListUpdate.add(sObjectToLookup);
            }

            if (!sobjectListUpdate.isEmpty()) {
                update sobjectListUpdate;
            }
        } catch (Exception e) {
            LOGGER.error('Error in updateLookup: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static SObject createSObjectForLookup(Id recordId) {
        SObjectType objectType = recordId.getSObjectType();
        return objectType.newSObject(recordId);
    }
    @TestVisible

    private static void processLookupField(String lookupField, SObject sObjectToLookup) {
        if (!lookupField.contains(';')) {
            return;
        }
        List<sObject> sobjectListUpdate = new List<sObject>();
        String[] lookupFieldParts = lookupField.split(';');
        String fieldName = lookupFieldParts[0];
        String linkedFieldKey = lookupFieldParts[1];

        if (!linkedmap.containsKey(linkedFieldKey)) {
            return;
        }

        String linkedFieldValue = linkedmap.get(linkedFieldKey);

        if (linkedFieldValue.contains(':')) {
            for (String singleId : linkedFieldValue.split(':')) {
                Id recId = (Id) singleId;
                SObject ssObjectToLookup = createSObjectForLookup(recId);
                ssObjectToLookup.put(fieldName, linkedFieldValue);
                sobjectListUpdate.add(ssObjectToLookup);
            }
        } else {
            sObjectToLookup.put(fieldName, linkedFieldValue);
        }
    }
	/**
    * @description this method used to return GBG Pattern Validations based on Country Name
    * @param countryName
    * @return string
    */
    @AuraEnabled
    public static string returnGBGPatternValidations(string countryName) {
        try {
            Map<String, ICS_GBGManadatoryFields__mdt> mandatoryInfo = ICS_GBGManadatoryFields__mdt.getAll();
            Map<String, List<ICS_GBGManadatoryFields__mdt>> dataMap = new Map<String, List<ICS_GBGManadatoryFields__mdt>>();

            for(String mandatoryKey : mandatoryInfo.keySet()) {
                ICS_GBGManadatoryFields__mdt field = mandatoryInfo.get(mandatoryKey);
                if(String.isNotBlank(field.Country_Based__c)) {
                    String lowerCountry = field.Country_Based__c.toLowerCase();
                    if(!dataMap.containsKey(lowerCountry)) {
                        dataMap.put(lowerCountry, new List<ICS_GBGManadatoryFields__mdt>());
                    }
                    dataMap.get(lowerCountry).add(field);
                }
            }

            if(!dataMap.containsKey(countryName.toLowerCase())) {
                return '';
            }

            return generateJsonResponse(dataMap.get(countryName.toLowerCase()));
        } catch (Exception e) {
            LOGGER.error('Error in returnGBGPatternValidations: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String generateJsonResponse(List<ICS_GBGManadatoryFields__mdt> fields) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for(ICS_GBGManadatoryFields__mdt field: fields) {
            gen.writeStartObject();
            gen.writeStringField(ICS_Constants.UI_FIELd, field.UIField__c);
            gen.writeStringField(ICS_Constants.COUNTRY_BASED_GBG, field.Country_Based__c);
            gen.writeStringField(ICS_Constants.ValidationPattern, field.Validation_Pattern__c);
            gen.writeStringField(ICS_Constants.validationMessage, field.Validation_Message__c);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString();
    }
/**
    * @description insert the data for the different objects based on Json Data
    * @param jsonString
    * @param jsonData
    */
    @AuraEnabled
public static void performOnboardingDMLInfo(String jsonString, Map<String, Object> jsonData) {
    try{
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        String screenName = (String)jsonMap.get('screenName');
        String sectionName = (String)jsonMap.get('sectionName');
        String dmlType = (String)jsonMap.get('insertDML');
		boolean isJointAcc = (boolean)jsonMap.get('isJointAcc');

        if (jsonData == null) {
            return;
        }
        if (screenName == ICS_Constants.preAccountScreen) {
            insertAccountDetails(JSON.serialize(jsonData));
            return;
        }

        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames(screenName, sectionName);
       getIdentityDocumentInputs(objectWithFieldAPINames);

        List<sObject> sObjList = new List<sObject>();
        List<sObject> sObjListUpdate = new List<sObject>();

        processObjects(objectWithFieldAPINames, jsonData, sObjList, sObjListUpdate);

        performDMLOperations(sObjListUpdate, sObjList, dmlType);

        handlePostProcessing(screenName, jsonData,sectionName, isJointAcc);
    }Catch(Exception e){
            LOGGER.error('Error in countryCodeMap: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

}

private static Map<String, List<AOB_Field__c>> getObjectWithFieldAPINames(String screenName, String sectionName) {
    Set<Id> sectionIds = new Set<Id>();
    for (AOB_ScreenSection__c section : new SEL_AOBSection().selectSectionsByScreenName(screenName)) {
        if (section.name == sectionName) {
            sectionIds.add(section.id);
        }
    }

    Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
    for (AOB_Field__c field : new SEL_AOBField().selectFieldsBySection(sectionIds)) {
        if (field.AOB_SFObject__c == null || field.AOB_SFField__c == null) {
            continue;
        }
        if (objectWithFieldAPINames.containsKey(field.AOB_SFObject__c)) {
            objectWithFieldAPINames.get(field.AOB_SFObject__c).add(field);
        } else {
            objectWithFieldAPINames.put(field.AOB_SFObject__c, new List<AOB_Field__c>{field});
        }
    }

    return objectWithFieldAPINames;
}

private static List<String> getIdentityDocumentInputs(Map<String, List<AOB_Field__c>> objectWithFieldAPINames) {
    List<String> idDataInput = new List<String>();
    for (String objectName : objectWithFieldAPINames.keySet()) {
        for (AOB_Field__c field : objectWithFieldAPINames.get(objectName)) {
            if (field.AOB_SFObject__c == null || field.AOB_SFField__c == null) {
                idDataInput.add(field.AOB_SFObject__c == ICS_Constants.IdentityDocument ? field.Name : null);
            }
        }
    }
    return idDataInput;
}
@TestVisible
private static void processObjects(Map<String, List<AOB_Field__c>> objectWithFieldAPINames, Map<String, Object> jsonData,
                                   List<sObject> sObjList, List<sObject> sObjListUpdate) {
    for (String objectName : objectWithFieldAPINames.keySet()) {
        if (String.isBlank(objectName) || objectName == ICS_Constants.documentObj) {
            continue;
        }
        sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();

        for (AOB_Field__c fieldData : objectWithFieldAPINames.get(objectName)) {
            processField(sObj, fieldData, jsonData, objectName);
        }
        if (linkedmap.containsKey(objectName)) {
            sObj.put(ICS_Constants.Id, linkedmap.get(objectName));

            sObjListUpdate.add(sObj);
        } else {
            sObjList.add(sObj);
        }
    }
}
@TestVisible
private static void performDMLOperations(List<sObject> sObjListUpdate, List<sObject> sObjList, String dmlType) {
    if (!sObjListUpdate.isEmpty()) {
        update sObjListUpdate;
    }
    if (dmlType == ICS_Constants.insertDML && !sObjList.isEmpty()) {
        insertObjects(sObjList);
    }
}
@TestVisible
private static void handlePostProcessing(String screenName, Map<String, Object> jsonData,string sectionName, boolean isJointAcc) {
    if (screenName == ICS_Constants.prePersonalScreen) {
        insertIdentityDocuments(jsonData, screenName);
            if (linkedmap.containsKey(ICS_Constants.OPPORTUNITY)) {

                Opportunity opp =[select id,ownerId from opportunity where id=:linkedmap.get(ICS_Constants.OPPORTUNITY) ];
                oppOwnerId = opp.ownerId;
            }else{
            insertOpportunity(JSON.serialize(jsonData),sectionName,isJointAcc);
        }
    }
}

   @TestVisible
    private static void processField(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String objectName) {
    String fieldName = fieldData.AOB_SFField__c;

    handleMasterDetailField(objectName, fieldName, fieldData);

    if (shouldProcessField(fieldData)) {
        handlePrimaryApplicant(sObj, jsonData, objectName);
        processFieldValue(sObj, fieldData, jsonData, objectName, fieldName);
    } else if (isLookupWithoutDefaultValue(fieldData)) {
        addToLookupFields(fieldData);
    }
}

private static void handleMasterDetailField(String objectName, String fieldName, AOB_Field__c fieldData) {
    if (fieldData.AOB_Type__c == ICS_Constants.MasterDetail) {
        masterDetailMap.put(objectName, fieldName);
    }
}

private static boolean shouldProcessField(AOB_Field__c fieldData) {
    return fieldData.AOB_Type__c != ICS_Constants.Lookup && fieldData.AOB_Type__c != ICS_Constants.MasterDetail
        || (fieldData.AOB_Type__c == ICS_Constants.Lookup && fieldData.Default_Value__c != null);
}
@TestVisible
private static void handlePrimaryApplicant(SObject sObj, Map<String, Object> jsonData, String objectName) {
    if (jsonData.containsKey(ICS_Constants.isPrimaryIndex) && objectName == ICS_Constants.Applicant) {
        sObj.put(ICS_Constants.role, (Boolean)jsonData.get(ICS_Constants.isPrimaryIndex) ? ICS_Constants.PrimaryApplicant : ICS_Constants.COAPPLICANT);
      
    }
    
   
}
@TestVisible
private static void processFieldValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String objectName, String fieldName) {
  
    if (fieldName != null) {
        String fieldType = getFieldType(objectName, fieldName);
        setFieldValue(sObj, fieldData, jsonData, fieldName, fieldType);
    }
}

@TestVisible
private static String getFieldType(String objectName, String fieldName) {
    SObjectType r = ((SObject)(Type.forName(ICS_Constants.Schema + objectName).newInstance())).getSObjectType();
    DescribeSObjectResult d = r.getDescribe();
    return d.fields.getMap().get(fieldName).getDescribe().getType().name().toLowerCase();
}

private static boolean isLookupWithoutDefaultValue(AOB_Field__c fieldData) {
    return fieldData.Default_Value__c == null && fieldData.AOB_Type__c == ICS_Constants.Lookup;
}
@TestVisible
private static void addToLookupFields(AOB_Field__c fieldData) {
    List<String> fieldList = lookupFields.containsKey(fieldData.AOB_SFObject__c)
        ? lookupFields.get(fieldData.AOB_SFObject__c)
        : new List<String>();
    if (!fieldList.contains(fieldData.AOB_SFField__c)) {
        fieldList.add(fieldData.AOB_SFField__c);
        lookupFields.put(fieldData.AOB_SFObject__c, fieldList);
    }
}

    private static void setFieldValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName, String fieldType) {
        if (fieldType == ICS_Constants.currencyData || fieldType == ICS_Constants.doubleData
            || fieldType == ICS_Constants.percentData || fieldType == ICS_Constants.decimalData) {
            setNumericFieldValue(sObj, fieldData, jsonData, fieldName);
        } else if (fieldType == ICS_Constants.booleanData) {
            setBooleanFieldValue(sObj, fieldData, jsonData, fieldName);
        } else if (fieldType == ICS_Constants.dateData) {
            setDateFieldValue(sObj, jsonData, fieldName, fieldData.Name);
        } else {
            setStringFieldValue(sObj, fieldData, jsonData, fieldName);
        }
    }
@TestVisible
    private static void setNumericFieldValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName) {
        if (fieldData.Default_Value__c == null) {
             sObj.put(fieldName, Decimal.valueOf(String.valueOf(jsonData.get(fieldData.Name))));
        } else if( fieldData.Default_Value__c != null&& fieldData.Default_Value__c != ICS_Constants.merges) {
			sObj.put(fieldName, Decimal.valueOf(fieldData.Default_Value__c));
        }

    }
@TestVisible
    private static void setBooleanFieldValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName) {
       if (fieldData.Default_Value__c == null) {
             sObj.put(fieldName, Boolean.valueOf(jsonData.get(fieldData.Name)));
        } else if(fieldData.Default_Value__c != null && fieldData.Default_Value__c != ICS_Constants.merges){
		sObj.put(fieldName, Boolean.valueOf(fieldData.Default_Value__c));

        }
    }
@TestVisible
    private static void setDateFieldValue(SObject sObj, Map<String, Object> jsonData, String fieldName, String dataName) {
        if (jsonData.get(dataName) != null) {
            String inputDate = (String)(jsonData.get(dataName));
            List<String> dateParts = inputDate.split('-');
            if (dateParts.size() == 3) {
                Integer inpYear = Integer.valueOf(dateParts[0]);
                Integer inpMonth = Integer.valueOf(dateParts[1]);
                Integer inpDay = Integer.valueOf(dateParts[2]);
                Date formattedDate = Date.newInstance(inpYear, inpMonth, inpDay);
                sObj.put(fieldName, formattedDate);
            }
        }
    }


    private static void setStringFieldValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName) {
        if (fieldData.Default_Value__c == null) {
            setValueFromJsonData(sObj, fieldData, jsonData, fieldName);
        } else {
            setValueFromDefaultValue(sObj, fieldData, jsonData, fieldName);
        }
    }
    @TestVisible
    private static void setValueFromJsonData(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName) {
        if (isBooleanField(fieldData, jsonData)) {
            setBooleanValue(sObj, fieldData, jsonData, fieldName);
        } else if (jsonData.containsKey(fieldData.Name)) {
            sObj.put(fieldName, jsonData.get(fieldData.Name));
            if(fieldData.AOB_SFObject__c != 'Applicant'){
                if(oppownerId == null){
            		sObj.put('ownerId',ownerId);
                }else{
                    if (linkedmap.containsKey(ICS_Constants.OPPORTUNITY)) {
                        SEL_Opportunity oppSelector=new SEL_Opportunity();
                        Opportunity opp =oppSelector.selectById(linkedmap.get(ICS_Constants.OPPORTUNITY));
                        oppOwnerId = opp.ownerId;
                    }
                    sObj.put('ownerId',oppownerId);
                }

            }
        }
    }

    private static boolean isBooleanField(AOB_Field__c fieldData, Map<String, Object> jsonData) {
        return jsonData.get(fieldData.Name) == ICS_Constants.trueText || jsonData.get(fieldData.Name) == ICS_Constants.falseText;
    }

    private static void setBooleanValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName) {
        String value = (jsonData.get(fieldData.Name) == ICS_Constants.trueText) ? ICS_Constants.yesText : ICS_Constants.noText;
        sObj.put(fieldName, value);
    }

    private static void setValueFromDefaultValue(SObject sObj, AOB_Field__c fieldData, Map<String, Object> jsonData, String fieldName) {
        if (fieldName == 'RecordtypeId') {
            setRecordTypeId(sObj, fieldData, fieldName);
        } else if (fieldData.Default_Value__c == ICS_Constants.merges) {
            sObj.put(fieldName, String.valueOf(jsonData.get(fieldData.Name)));
        } else {
            sObj.put(fieldName, fieldData.Default_Value__c);
        }
    }

    private static void setRecordTypeId(SObject sObj, AOB_Field__c fieldData, String fieldName) {
        String recID = Schema.getGlobalDescribe().get(fieldData.AOB_SFObject__c).getDescribe()
            .getRecordTypeInfosByName().get(fieldData.Default_Value__c).getRecordTypeId();
        sObj.put(fieldName, recID);
    }
@TestVisible
    private static void insertObjects(List<SObject> sObjList) {
        List<SObject> masterDetailObjects = new List<SObject>();
        List<Integer> removeIndex = new List<Integer>();

        for(Integer i = 0; i < sObjList.size(); i++) {
            SObject objData = sObjList[i];
            SObjectType objectType = objData.getSObjectType();
            String objectName = objectType.getDescribe().getName();
            if(masterDetailMap.containsKey(objectName)) {
                removeIndex.add(i);
                masterDetailObjects.add(objData);
            }
        }

        for(Integer i = removeIndex.size() - 1; i >= 0; i--) {
            sObjList.remove(removeIndex[i]);
        }

        List<Database.SaveResult> saveResultList = Database.insert(sObjList, false);
        for (Database.SaveResult saveResult : saveResultList) {
            if (saveResult.isSuccess()) {
                mapLookupData(saveResult.getId());
            } else {
                LOGGER.error('Error in insertObjects: ' + saveResult.getErrors()[0].getMessage());
            }
        }

        for(SObject masterObj : masterDetailObjects) {
            SObjectType objectType = masterObj.getSObjectType();
            String objectName = objectType.getDescribe().getName();
            String lookupFieldName = masterDetailMap.get(objectName);
            String[] lookupFieldParts = lookupFieldName.split(ICS_Constants.SemiColon);
            masterObj.put(lookupFieldParts[0], linkedMap.get(lookupFieldParts[1]));
        }

        List<Database.SaveResult> mSaveResultList = Database.insert(masterDetailObjects, false);
        for (Database.SaveResult saveResult : mSaveResultList) {
            if (saveResult.isSuccess()) {
                mapLookupData(saveResult.getId());
            }
            else {
                LOGGER.error('Error in insertObjects (masterDetail): ' + saveResult.getErrors()[0].getMessage());
            }
        }
    }
	@TestVisible
    private static void mapLookupData(Id insertedRecordId) {
        String objectName = insertedRecordId.getSObjectType().getDescribe().getName();
        if (linkedMap.containsKey(objectName)) {
            String existingIds = linkedMap.get(objectName);
            linkedMap.put(objectName, existingIds + ':' + insertedRecordId);
        } else {
          linkedMap.put(objectName, insertedRecordId);
        }
    }

@TestVisible
    private static void insertIdentityDocuments(Map<String, Object> sectionFieldData, String screenName) {
        if(!linkedMap.containsKey(ICS_Constants.Account) || screenName != ICS_Constants.prePersonalScreen) {
            return;
        }
        Map<String, String> mandatoryFields = new Map<String, String>();
        List<IdentityDocument> documentList = new List<IdentityDocument>();

        for(ICS_GBGManadatoryFields__mdt gbgData : ICS_GBGManadatoryFields__mdt.getAll().values()) {
            mandatoryFields.put(gbgData.UIField__c, gbgData.ICS_Salesforce_Type__c);
        }

        for (String iData : mandatoryFields.keySet()) {
            if (!sectionFieldData.containsKey(iData)) {
                continue;
            }
            String fieldValue = (String)sectionFieldData.get(iData);
            if (String.isBlank(fieldValue)) {
                continue;
            }
            IdentityDocument idData = new IdentityDocument(
                Name = iData + ':' + fieldValue,
                PartyProfileId = linkedMap.get(ICS_Constants.PartyProfile),
                RelatedLegalEntityId = linkedMap.get(ICS_Constants.accountText),
                IdDocumentType = mandatoryFields.get(iData),
                ownerID= ownerId
            );
            documentList.add(idData);
        }

        if(!documentList.isEmpty()  || Schema.sObjectType.IdentityDocument.isCreateable()) {
            insert documentList;
        }
    }

    /**
* @description Used to insert Opportunity based on input data
* @param inputData
* @return String
*/
    public static String insertOpportunity(String inputData,String sectionName, Boolean isJointAcc) {
        sectionFieldData = (Map<String, Object>) JSON.deserializeUntyped(inputData);
        if (!linkedMap.containsKey(ICS_Constants.accountText)) {
            return null;
        }

        Account accData = getAccountData();
        Opportunity opp = createOpportunity(accData, sectionFieldData, isJointAcc);

        insert opp;

        Account acc = new Account(
            Id = accData.Id,
            OwnerId = opp.OwnerId
        );
        update acc;


        insertOpportunityLineItems(opp);



        opportunityId = opp.Id;
        linkedMap.put(ICS_Constants.Opportunity, opp.Id);
        return opportunityId;
    }
    /**
     * @description AC1: Creates a Group Joint Account named after all participants + "Joint"
     *              AC2: Links each Person Account's Contact to the Joint Account
     *              AC3: Populates the Roles field from the Applicant record
     **/
   @AuraEnabled
    public static void createGroupJointAccount(String oppId) {
        try {
            SEL_ApplicationForm applicationFormSelector = new SEL_ApplicationForm();
            List<ApplicationForm> formList = applicationFormSelector.selectByOpportunityId(oppId);
            String jointAccountName = constructFullName(formList).substring(0, Math.min(constructFullName(formList).length(), 120));

            if(formList.size()>0) {
                    Account jointAccount = new Account(
                        Name         = jointAccountName,
                        ExternalSystemId__c=formList[0].Account.ExternalSystemId__c,
                        ExternalCIFCountry__c=formList[0].Account.ExternalCIFCountry__c,
                        RecordTypeId = JOINT_ACCOUNT_RT_ID,
                        Type         = 'Joint',
                        OwnerId      = formList[0].OwnerId
                    );
                    insert jointAccount;
    
                Opportunity opp = new Opportunity();
                opp.Id        = oppId;
                opp.AccountId = jointAccount.Id;
                opp.Name      = jointAccountName;
                update opp;
    
                Set<Id> accountIds = new Set<Id>();
                for (ApplicationForm form : formList) {
                    accountIds.add(form.accountId);
                }
    
                SEL_Applicant applicantSelector = new SEL_Applicant();
                List<Applicant> applicants = applicantSelector.selectByAccountIds(accountIds);
    
                Map<Id, String> accountRoleMap = new Map<Id, String>();
                for (Applicant app : applicants) {
                    accountRoleMap.put(app.AccountId, app.Role);
                }
    
                SEL_Account accountSelector = new SEL_Account();
                List<Account> personAccounts = accountSelector.selectByIds(accountIds);
    
                List<ACREventWrapper> acrEventList = new List<ACREventWrapper>();
                ACREventWrapper objWpr;
                for (Account personAcc : personAccounts) {
                    String applicantRole = accountRoleMap.get(personAcc.Id);
                    String acrRole = (applicantRole == 'Primary Applicant') ? 'Primary Applicant' : 'Co-Applicant';
    				objWpr = new ACREventWrapper();
                    	objWpr.strAccountId = jointAccount.Id;
                        objWpr.strContactId = personAcc.PersonContactId;
                        objWpr.strRoles = acrRole;
                        objWpr.strRoleUps = 'All';
                    acrEventList.add(objWpr);
                    
    
                }
                
                     if (acrEventList.isEmpty()) {
                         LOGGER.warn('No AccountContactRelations created for Joint Account: ' + jointAccount.Id);
                     } else {
                         publishACREvents(acrEventList);
                         LOGGER.info('Successfully linked ' + acrEventList.size() + ' participants to Joint Account');
                     }
            }
          

        } catch (Exception e) {
            LOGGER.error('Error in createGroupJointAccount: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*
     * @Description : used to publish platform event to create ACR
     * @param : acrDataList - list of ACREventWrapper
     */
    public static void publishACREvents(List<ACREventWrapper> acrDataList) {
        
        List<ICS_Handle_ACR_Event__e> objAcrEvents = new List<ICS_Handle_ACR_Event__e>();
        
        for(ACREventWrapper data : acrDataList) {
            ICS_Handle_ACR_Event__e event = new ICS_Handle_ACR_Event__e();
            event.AccountId__c = data.strAccountId;
            event.ContactId__c = data.strContactId;
            event.Roles__c     = data.strRoles;
            event.RollUps__c   = data.strRoleUps;
            objAcrEvents.add(event);
        }
        
        if(!objAcrEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(objAcrEvents);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    LOGGER.info('ACR Event Publish Failed: ' + sr.getErrors());
                }
            }
        }
    }
    private class ACREventWrapper{
        string strAccountId;
        string strContactId;
        string strRoles;
        string strRoleUps;        
    }
    
    
    
	 private static String constructFullName(List<ApplicationForm> appforms) {
       
        List<String> namesList = new List<String>();
        for(ApplicationForm appf :appforms){
           namesList.add(
            appf.Account.PersonTitle.replace('.', '') + ' ' +
            appf.Account.FirstName.substring(0, 1) + ' ' +
            appf.Account.LastName
        );
        }
        return String.join(namesList, ', ');
    }
	 /**
* @description Used to checking whether the logged in user is IFA
* @return boolean
*/
    @AuraEnabled
    public static boolean checkIsIFA() {
        try{
            if (!Schema.sObjectType.User.isAccessible()) {
        throw new SecurityException('Insufficient permissions to access User');
    }
        User u = [SELECT Id, Contact.Account.RecordType.Name FROM User WHERE Id = :UserInfo.getUserId()];
        return u.Contact.Account.RecordType.Name == 'IFA';
        }catch(Exception e){
             LOGGER.error('Error in checkIsIFA: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
* @description Used to checking whether the logged in user is IFA based on contactId
* @param conId
* @return boolean
*/
    @AuraEnabled
    public static String checkIsIFAWithContactId(String conId) {
        try{
            Contact c = [SELECT Id, Account.RecordType.Name FROM Contact WHERE Id = :conId];
            Set<String> validRecordTypes = new Set<String>{'IFA', 'BCB Isle of Man', 'BCB Jersey', 'IWI', 'IPB'};
            Map<String, Object> returnData = new Map<String, Object>();
            returnData.put('isTrue', validRecordTypes.contains(c.Account.RecordType.Name));
            returnData.put('recordType', c.Account.RecordType.Name);
            return JSON.serialize(returnData);
            //return validRecordTypes.contains(c.Account.RecordType.Name);
        }catch(Exception e){
            LOGGER.error('Error in checkIsIFAWithContactId: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }




@TestVisible
    private static Account getAccountData() {
        SEL_Account selectorAccountInfo = new SEL_Account();
        return selectorAccountInfo.selectById(linkedMap.get(ICS_Constants.accountText));
    }

    @TestVisible
    private static Opportunity createOpportunity(Account accData, Map<String, Object> sectionFieldData, boolean isJointAcc) {
        Opportunity opp = new Opportunity(
            AccountId = accData.Id,
            Name = accData.FirstName + ' ' + accData.LastName,
            StageName = 'ID & Address Verification',
            CurrencyIsoCode = ICS_Constants.DEFAULT_CURRENCY,
            CloseDate = Date.today().addDays(365),
            RecordTypeId = Schema.getGlobalDescribe().get(ICS_Constants.Opportunity).getDescribe().getRecordTypeInfosByName().get(ICS_Constants.ICSApplicant).getRecordTypeId(),
            LeadSource = checkIsIFA() ? 'IFA' : 'Direct',
            ICS_Opportunity_Type__c = isJointAcc ? 'Joint' : null
        );
        SEL_Product2 selectorProdData = new SEL_Product2();
        if(selectorProdData.selectByProductCodes(new List<String>{pCode})[0].Name =='Seafarer'){
            opp.Required_Approval_Processes__c	='Need Captain letter Approval;';
        }
        if (checkIsIFA()) {
        opp.OwnerId = getTheOwnerIdForIFA();
        } else {
            String salesCode = getSalesCode(sectionFieldData);
            opp.OwnerId = ownerId;
             oppOwnerId= ownerId;
            	opp.Sales_Code__c = getSalesCodeId(salesCode);
                if(sectionFieldData.containskey(ICS_Constants.SBManagerCode)){
                opp.LeadSource='Staff';
            	}
        }

        return opp;
    }
   private static Id getTheOwnerIdForIFA(){
        return [
            SELECT Contact.Account.OwnerId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ].Contact.Account.OwnerId;
    }
@TestVisible
   private static String getSalesCode(Map<String, Object> sectionFieldData) {
    cor = determineCor(sectionFieldData);
    String salesCode = '';

    SEL_Product2 selectorProdData = new SEL_Product2();
    String productCodeSales = selectorProdData.selectByProductCodes(new List<String>{pCode})[0].Name;
    
    sel_Sales_Code selectorCodeData = new sel_Sales_Code();
    List<Sales_Codes__c> codeInfo = selectSalesCodeInfo(sectionFieldData, cor, productCodeSales, selectorCodeData);
    
    if (codeInfo.isEmpty()) {
        String defaultOwner = labelInfo.get(ICS_Constants.ics_relationship_manager);
        codeInfo = selectorCodeData.selectByName(defaultOwner);
        salesCode = codeInfo[0].Id;
    } else {
        for (Sales_Codes__c code : codeInfo) {
            if (code.Sales_Code_Province__c == '1') {
                salesCode = code.Id;
            } else {
                salesCode = codeInfo[0].Id;  
            }
        }
    }
       
    return salesCode;
}

private static String determineCor(Map<String, Object> sectionFieldData) {
    if (cor != null) {
        return cor;
    }
    
    return (sectionFieldData.get(MAIN_COR) == null) 
        ? (String) sectionFieldData.get(ICS_Constants.CORTEXT)
        : (String) sectionFieldData.get(MAIN_COR);
}

private static List<Sales_Codes__c> selectSalesCodeInfo(
    Map<String, Object> sectionFieldData, 
    String cor, 
    String productCodeSales, 
    sel_Sales_Code selectorCodeData
) {
    // Check Sales Manager Code
    if (sectionFieldData.containsKey(ICS_Constants.SBManagerCode)) {
        String salesCode = (String) sectionFieldData.get(ICS_Constants.SBManagerCode);
        	Set<String> africanCountries = new Set<String>(
            		labelInfo.get('ics_africanexcludesbmanagercode').split(',')
       		 );
            if(africanCountries.contains(salesCode)){
                return selectorCodeData.selectByName(salesCode);  
            }else{
               return selectorCodeData.selectByNameAndSalesCodeCountry(salesCode, cor);
            }
       
    }
    
    // Check Seafarer Product
    if (productCodeSales == 'Seafarer') {
        String leadOwner = labelInfo.get(ICS_Constants.ics_seafarer_lead);
        return selectorCodeData.selectByName(leadOwner);
    }
    
    // Handle specific country and region cases
    return selectSalesCodeByRegion(sectionFieldData, cor, selectorCodeData);
}

    private static List<Sales_Codes__c> selectSalesCodeByRegion(
        Map<String, Object> sectionFieldData, 
        String cor, 
        sel_Sales_Code selectorCodeData
    ) {
        	
           Set<String> countrySet = new Set<String>();
        if(labelInfo.containskey('ics_iom_countries')){
            countrySet.addall(labelInfo.get('ics_iom_countries').split(','));
        }
          
          String salesCode = (String) sectionFieldData.get(ICS_Constants.SBManagerCode);
        
        // IOM Country specific logic
          if (countrySet.contains(cor) && (salesCode == null || String.isBlank(salesCode))) {
            return handleIOMCountryLogic(sectionFieldData, cor, selectorCodeData);
        }
        // SA Country specific logic
        if (cor == ICS_Constants.SACountryCode) {
            return handleSACountryLogic(sectionFieldData, cor, selectorCodeData);
        }
        
        // African countries logic
        if (labelInfo.containsKey(ICS_Constants.ics_african_countries)) {
            return handleAfricanCountriesLogic(cor, selectorCodeData);
        }
        
        // Default relationship manager
        String defaultOwner = labelInfo.get(ICS_Constants.ics_relationship_manager);
        return selectorCodeData.selectByName(defaultOwner);
    }
    private static List<Sales_Codes__c> handleIOMCountryLogic(
    Map<String, Object> sectionFieldData, 
    String cor, 
    sel_Sales_Code selectorCodeData
    ) {
      String defaultOwner = labelInfo.get('ics_relationship_manager_direct');
         
    LOGGER.info('handleIOMCountryLogic: fetching IOM sales code for cor=' + cor + 
                ' | defaultOwner=' + defaultOwner + 
                ' | sectionFieldData=' + JSON.serialize(sectionFieldData));
    
          List<Sales_Codes__c> codeInfo=[select CurrencyIsoCode, Id, Name, Sales_Code_Country__c,Sales_Code_Province__c,Sales_Code_Sub_Region__c
                                           FROM Sales_Codes__c WHERE Name =:defaultOwner
                                           ORDER BY Name ASC NULLS FIRST ];
        if (codeInfo.isEmpty()) {
            LOGGER.warn('handleIOMCountryLogic: No Sales Code found for owner=' + defaultOwner + ' cor=' + cor+'selectorCodeData'+selectorCodeData);
        }
            return codeInfo;

    }
    
    private static List<Sales_Codes__c> handleSACountryLogic(
        Map<String, Object> sectionFieldData, 
        String cor, 
        sel_Sales_Code selectorCodeData
    ) {
        String province = sectionFieldData.get(MAIN_COR) == null 
            ? (String) sectionFieldData.get('Province')
            : (String) sectionFieldData.get('mainProvince');
        
        String subRegion = sectionFieldData.get(MAIN_COR) == null 
            ? (String) sectionFieldData.get('Sub Region')
            : (String) sectionFieldData.get('mainSubRegion');
        
        return selectorCodeData.selectByCountryRegion(cor, province, subRegion);
    }
    
    private static List<Sales_Codes__c> handleAfricanCountriesLogic(
        String cor, 
        sel_Sales_Code selectorCodeData
    ) {
        Set<String> africanCountries = new Set<String>(
            labelInfo.get(ICS_Constants.ics_african_countries).split(',')
        );
        
        return africanCountries.contains(cor)
            ? selectorCodeData.selectByCountryRegion(cor, '', '')
            : selectorCodeData.selectByName(
                labelInfo.get(ICS_Constants.ics_relationship_manager)
            );
    }

    @TestVisible
    private static Id getOwnerId(String salesCode) {
        if (String.isBlank(salesCode)) {
            String defaultOwner = labelInfo.get(ICS_Constants.ics_relationship_manager);

            List<Sales_Codes__c> codeInfo=[select CurrencyIsoCode, Id, Name, Sales_Code_Country__c
                                           FROM Sales_Codes__c WHERE Name =:defaultOwner
                                           ORDER BY Name ASC NULLS FIRST ];
            salesCode=codeInfo[0].id;
        }
        List<Sales_Code_Allocation__c> allocation =[select id,User__c, Sales_Codes__r.id,Sales_Codes__r.Name
                                                    FROM Sales_Code_Allocation__c WHERE Sales_Codes__c =:salesCode
                                                    ];
        if (allocation.isEmpty()) {

            throw new AuraHandledException('Sales_Code_Allocation__c object records return null');
        }else{

            return allocation[0].User__c;
        }

    }
@TestVisible
    private static Id getSalesCodeId(String salesCode) {
        if (String.isBlank(salesCode)) {
            return null;
        }
        List<Sales_Code_Allocation__c> allocation =[select id,Sales_Codes__r.Id from Sales_Code_Allocation__c
                                                    where  Sales_Codes__r.Id =: salesCode ];
        return allocation.isEmpty() ? null : allocation[0].Sales_Codes__r.Id;
    }
@TestVisible
    private static void insertOpportunityLineItems(Opportunity opp) {
        SEL_PriceBookEntry selectPB = new SEL_PriceBookEntry();
        SEL_Product2 selectorProdData = new SEL_Product2();
        List<PricebookEntry> pbList = selectPB.selectByProductcodeAndName(new List<String>{pCode}, ICS_Constants.ICSPricebook, ICS_Constants.DEFAULT_CURRENCY);
        List<OpportunityLineItem> itemList = new List<OpportunityLineItem>();
        if (!pbList.isEmpty()) {
            for (PricebookEntry pBData : pbList) {
                OpportunityLineItem prodLineData = new OpportunityLineItem(
                    Product2Id = selectorProdData.selectByProductCodes(new List<String>{pCode})[0].Id,
                    PricebookEntryId = pBData.Id,
                    OpportunityId = opp.Id
                );
                itemList.add(prodLineData);
            }

            if (!itemList.isEmpty() || Schema.sObjectType.OpportunityLineItem.isCreateable()) {
                insert itemList;
            }
			

        }
        
        
       
    }
	 /**
    * @description Used to insert Account Data based on inputData
    * @param inputData
    */
    public static void insertAccountDetails(String inputData) {

            Map<String, Object> accountSectionFieldData = (Map<String, Object>) JSON.deserializeUntyped(inputData);
            String accCurrencies = (String) accountSectionFieldData.get(ICS_Constants.Pleaseselectthecurrencies);
            String selaccCurrencies = (String) accountSectionFieldData.get(ICS_Constants.Selectthecurrencies);
            Boolean isVisaCard = (String.valueOf(accountSectionFieldData.get(ICS_Constants.Wouldyoulike))).equals(ICS_Constants.trueText);

            Set<String> accProductCurrencies = new Set<String>();
            if (String.isNotBlank(accCurrencies)) {
                accProductCurrencies.addAll(accCurrencies.split(ICS_Constants.SemiColon));
                if (isVisaCard && String.isNotBlank(selaccCurrencies)) {
                    accProductCurrencies.add(ICS_Constants.Visa);
                    for (String selCurre : selaccCurrencies.split(ICS_Constants.SemiColon)) {
                        accProductCurrencies.add(selCurre + ' ' + ICS_Constants.Card);
                    }
                }
            }

            List<ApplicationFormProduct> lineItemList = insertProductsForAccount(accProductCurrencies);

            if (!lineItemList.isEmpty()  || Schema.sObjectType.ApplicationFormProduct.isCreateable()) {
                insert lineItemList;
            }

    }
@TestVisible
    private static List<ApplicationFormProduct> insertProductsForAccount(Set<String> accProductCurrencies) {
        SEL_Product2 selectorProdData = new SEL_Product2();
        Map<String, Id> codeMap = new Map<String, Id>();
        for (Product2 prod : selectorProdData.selectByProductCodes(new List<String>(accProductCurrencies))) {
            codeMap.put(prod.ProductCode, prod.Id);
        }

        List<ApplicationFormProduct> lineItemList = new List<ApplicationFormProduct>();
        for (String prodCode : codeMap.keySet()) {
            ApplicationFormProduct prodData = new ApplicationFormProduct(
                ProductId = codeMap.get(prodCode),
                ownerId= oppOwnerId,
                ApplicationFormId = linkedMap.get(ICS_Constants.ApplicationForm)
            );
            lineItemList.add(prodData);
        }
		ApplicationForm formInfo = new ApplicationForm();
        formInfo.id= linkedMap.get(ICS_Constants.ApplicationForm);
        formInfo.OwnerId = oppOwnerId;
        update formInfo;

        return lineItemList;
    }
	 /**
    * @description Used to get the data of country of residence based on accountId
    * @param accId
    * @return string
    */
    @AuraEnabled
    public static String fetchCountryofResidence(String accId) {
        try{
        SEL_PartyProfile selectorProfileData = new SEL_PartyProfile();
        PartyProfile profileData = selectorProfileData.selectByAccountAndRecordType(accId, ICS_Constants.SBO_RECNAME);

        if(profileData != null && String.isNotBlank(profileData.Country_of_Residence__c)) {
            Map<String, String> countryCodeMap = countryCodeMap();
            return countryCodeMap.get(profileData.Country_of_Residence__c);
        }else {
            return null;
        }
        }catch(Exception e){
            LOGGER.error('Error in insertAccountDetails: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
	/**
    * @description Used to get the data of countryCodeMap
    * @return Map<String, String>
    */
    public static Map<String, String> countryCodeMap() {
        Map<String, String> countryCodeMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = PartyProfile.Country_of_Residence__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            countryCodeMap.put(f.getValue(), f.getLabel());
        }
        return countryCodeMap;
    }

    /**
    * @description Used to get the data of ics_customlabel__mdt based on developer name
    * @param developerName
    * @return ics_customlabel__mdt
    */
    @TestVisible
    @AuraEnabled(cacheable=true)
    public static ics_customlabel__mdt getLandingPageJSON(String developerName) {
        try{
        return [SELECT DeveloperName, Description__c FROM ics_customlabel__mdt WHERE DeveloperName = :developerName LIMIT 1];
        }catch(Exception e){
            LOGGER.error('Error in getLandingPageJSON: ' + e.getMessage());
          throw new AuraHandledException(e.getMessage());
        }
    }
    

}