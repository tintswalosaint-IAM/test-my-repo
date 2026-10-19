/***************************************************************************************
@name of the Class : ICS_CTRL_DMLAdditionalBankAccounts.cls
@description :	SBO-UK onBoardingApplication Feature for AdditionalBankAccountSection
@author : Ikyatha Naidu
@created Date : 2024-06-04
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024 
@modification description: SFP-30233
*
***************************************************************************************/
public without sharing class ICS_CTRL_DMLAdditionalBankAccounts {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_DMLAdditionalBankAccounts');
    
    // Hard-coded values
    private static final String PARTY_ASSETS_FUNDS_OBJECT = 'Party_Assets_Funds__c';
    private static final String ADDITIONAL_ACCOUNTS_RECORD_TYPE = 'Additional Accounts';
    private static final String BANK_ACCOUNT_TYPE = 'Bank Account';
    private static final String DEFAULT_CURRENCY = 'GBP';
    private static final String SECTION_NAME = 'Additional Bank Accounts';
    private static final String SCREEN_NAME = 'ICS UK Financial Details';
    private static final String CURRENT_ACCOUNT_BALANCE_FIELD = 'Current Account Balance';
    private static final String CURRENT_ACCOUNT_BALANCE_CURRENCY_FIELD = 'Current Account BalanceCurrency';
    private static List<AssessmentQuestionResponse> responseList = new List<AssessmentQuestionResponse>();
    private static List<AssessmentQuestionResponse> updateResponseList = new List<AssessmentQuestionResponse>();
     private ICS_CTRL_DMLAdditionalBankAccounts(){
        //Private Constructor for instantiation
    }
    /**
* This method processes the JSON string to create or update Party Asset Funds records.
*
* @param jsonString - The JSON string containing Party Asset Funds data.
* @param parentId - The ID of the parent Party Profile.
*/
    public static void createPartyAssetFunds(String jsonString, String parentId) {
        LOGGER.info('Starting createPartyAssetFunds with parentId: {0}', new Object[]{parentId});
        Map<String, Object> parsedJson = parseJson(jsonString);
        String partyAssetFundId = (String) parsedJson.get(PARTY_ASSETS_FUNDS_OBJECT);
        List<Object> subAccordianList = (List<Object>) parsedJson.get('Sub Accordian');
        List<Map<String, Object>> subAccordian = new List<Map<String, Object>>();
        List<CurrencyType> currencyTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType LIMIT 1000];
        Map<String, Decimal> conversionMap = new Map<String, Decimal>();
        for (CurrencyType ct : currencyTypes) { 
            conversionMap.put(ct.IsoCode, ct.ConversionRate);
        }
        // Convert the list of Object to list of Map<String, Object>
        for (Object item : subAccordianList) {
            subAccordian.add((Map<String, Object>) item);
        }
        
        Map<String, List<AOB_Field__c>> fieldMappings = getFieldMappings();
        Map<String, Schema.SObjectField> sObjectFields = getSObjectFields(PARTY_ASSETS_FUNDS_OBJECT);
        
        List<Party_Assets_Funds__c> partyAssetFunds = new List<Party_Assets_Funds__c>();
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId,ICS_Constants.SBO_RECNAME);
        
        String recId = Schema.getGlobalDescribe().get(PARTY_ASSETS_FUNDS_OBJECT).getDescribe().getRecordTypeInfosByName().get(ADDITIONAL_ACCOUNTS_RECORD_TYPE).getRecordTypeId();
        sel_assesment selectorAssInfo = new sel_assesment();
        List<Assessment> assDataList = selectorAssInfo.SelectByAccountId(profileData.AccountId);
        
        for (Map<String, Object> subRecord : subAccordian) {
            Party_Assets_Funds__c partyAssetFund = mapFieldsToPartyAssetFund(subRecord, partyAssetFundId, fieldMappings, sObjectFields);
            partyAssetFund.Party_Profile__c = profileData.Id;
            partyAssetFund.RecordTypeId = recId;
            if(subRecord.containsKey(CURRENT_ACCOUNT_BALANCE_CURRENCY_FIELD)) {
                Decimal convertedAmount = ICS_CTRL_DML_OnboardingDetails.mapCurrency(CURRENT_ACCOUNT_BALANCE_FIELD,
                                                                                    Decimal.valueOf(String.valueOf(subRecord.get(CURRENT_ACCOUNT_BALANCE_FIELD))),
                                                                                    (String)subRecord.get(CURRENT_ACCOUNT_BALANCE_CURRENCY_FIELD), conversionMap);
                partyAssetFund.Current_Account_Balance__c = convertedAmount; 
            }
            SEL_Account accSelector = new SEL_Account();
            Account accountInfo = accSelector.selectById(parentId); 
            partyAssetFund.Type__c = BANK_ACCOUNT_TYPE;
            partyAssetFund.Name = 'Additional Bank Account';
            partyAssetFund.CurrencyIsoCode = DEFAULT_CURRENCY;
            partyAssetFund.OwnerId = accountInfo.ownerId;
            partyAssetFunds.add(partyAssetFund); 
        }
        processPartyAssetFunds(partyAssetFunds, subAccordian, assDataList, SECTION_NAME, CURRENT_ACCOUNT_BALANCE_CURRENCY_FIELD);
        LOGGER.info('Finished createPartyAssetFunds');
    }
    
    public static void processPartyAssetFunds(List<SObject> partyAssetFunds, 
                                              List<Map<String,Object>> subAccordian, 
                                              List<SObject> assDataList, String sectionName,
                                              String assessmentQuestionName) {
                                                  LOGGER.info('Starting processPartyAssetFunds');
                                                  
                                                  if (partyAssetFunds.isEmpty()) {
                                                      LOGGER.info('Finished processPartyAssetFunds - No party asset funds to process');
                                                      return;
                                                  }
                                                  
                                                  Map<String,  List<AssessmentQuestionResponse>> responseDataMap = createResponseDataMap(partyAssetFunds, subAccordian, assDataList, sectionName, assessmentQuestionName);
                                                  
                                                  String assQuestionId = getAssessmentQuestionId(assessmentQuestionName);
                                                  
                                                  
                                                  
                                                  populateResponseLists(responseDataMap, assQuestionId, responseList, updateResponseList);
                                                  
                                                  saveResponses(responseList, updateResponseList);
                                                  
                                                  LOGGER.info('Finished processPartyAssetFunds');
                                              }
    
    private static Map<String, List<AssessmentQuestionResponse>> createResponseDataMap(List<SObject> partyAssetFunds, 
                                                                                 List<Map<String,Object>> subAccordian, 
                                                                                 List<SObject> assDataList, String sectionName,
                                                                                 String assessmentQuestionName) {
                                                                                     Map<String, List<AssessmentQuestionResponse>> responseDataMap = new Map<String, List<AssessmentQuestionResponse>>();
                                                                                     List<Database.UpsertResult> saveResultList = Database.upsert(partyAssetFunds, false);
                                                                                     
                                                                                     for (Integer i = 0; i < saveResultList.size(); i++) {
                                                                                         Database.UpsertResult saveResult = saveResultList[i];
                                                                                         if (saveResult.isSuccess()) {
                                                                                             AssessmentQuestionResponse responseInfo = createResponseInfo(saveResult, subAccordian[i], assDataList, sectionName, assessmentQuestionName);
                                                                                             if(responseDataMap.containskey(responseInfo.Id) == false){
                                                                                                 responseDataMap.put(responseInfo.Id, new List<AssessmentQuestionResponse>{responseInfo});
                                                                                             }else{
                                                                                             	 responseDataMap.get(responseInfo.Id).add(responseInfo);
                                                                                             }
                                                                                             
                                                                                         }
                                                                                     }
                                                                                     
                                                                                     return responseDataMap;
                                                                                 }
    
    private static AssessmentQuestionResponse createResponseInfo(Database.UpsertResult saveResult, 
                                                                 Map<String, Object> sectionFieldData, 
                                                                 List<SObject> assDataList, String sectionName,
                                                                 String assessmentQuestionName) {
                                                                     AssessmentQuestionResponse responseInfo = new AssessmentQuestionResponse();
                                                                     responseInfo.ResponseText = (String) sectionFieldData.get(assessmentQuestionName);
                                                                     if (!assDataList.isEmpty()) {
                                                                         responseInfo.AssessmentId = assDataList[0].Id;
                                                                     }
                                                                     if (sectionFieldData.containsKey(assessmentQuestionName+':Id')) {
                                                                         responseInfo.Id = (String) sectionFieldData.get(assessmentQuestionName+':Id');
                                                                     } 
                                                                     responseInfo.Name = sectionName + ':' + saveResult.getId();
                                                                     return responseInfo;
                                                                 }
    
    private static String getAssessmentQuestionId(String assessmentQuestionName) {
        AssessmentQuestion aq = [SELECT ActiveVersionId FROM AssessmentQuestion WHERE Name = :assessmentQuestionName LIMIT 1];
        return aq.ActiveVersionId;
    }
    
    private static void populateResponseLists(Map<String, List<AssessmentQuestionResponse>> responseDataMap, 
                                              String assQuestionId,
                                              List<AssessmentQuestionResponse> responseList,
                                              List<AssessmentQuestionResponse> updateResponseList) {
                                                  for(string key:responseDataMap.keyset() ) {
                                                      for (AssessmentQuestionResponse responseData : responseDataMap.get(key)) {
                                                          responseData.AssessmentQuestionId = assQuestionId;
                                                          if (responseData.Id == null) {
                                                               responseList.add(responseData);
                                                          } else {
                                                              updateResponseList.add(responseData);
                                                             
                                                          }
                                                      }
                                                  }
                                              }
    
    private static void saveResponses(List<AssessmentQuestionResponse> responseList, 
                                      List<AssessmentQuestionResponse> updateResponseList) {
                                          if (!responseList.isEmpty() && !Test.isRunningTest()) {
                                              insert responseList;
                                          }
                                          if (!updateResponseList.isEmpty()) {
                                              update updateResponseList;
                                          }
                                      }
    
    /**
* Parses the JSON string into a Map.
*
* @param jsonString - The JSON string to parse.
* @return A Map representation of the JSON string.
*/
    private static Map<String, Object> parseJson(String jsonString) {
        LOGGER.info('Parsing JSON string');
        return (Map<String, Object>) JSON.deserializeUntyped(jsonString);
    }
    
    /**
* Retrieves the field mappings from the AOB_Field__c object.
*
* @return A map of field mappings.
*/
    public static Map<String, List<AOB_Field__c>> getFieldMappings() {
        LOGGER.info('Getting field mappings');
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
        for (AOB_Field__c fieldMapping : [SELECT AOB_SFObject__c, Name, AOB_SFField__c FROM AOB_Field__c WHERE AOB_Section__r.Name = :SECTION_NAME AND AOB_Section__r.AOB_Screen__r.Name = :SCREEN_NAME]) {
            if (objectWithFieldAPINames.containsKey(fieldMapping.AOB_SFObject__c)) {
               
                objectWithFieldAPINames.get(fieldMapping.AOB_SFObject__c).add(fieldMapping);
            } else {
                 objectWithFieldAPINames.put(fieldMapping.AOB_SFObject__c, new List<AOB_Field__c>{fieldMapping});
            }
        }
        return objectWithFieldAPINames;
    }
    
    /**
* Retrieves the SObject fields for the specified SObject.
*
* @param sObjectName - The API name of the SObject.
* @return A map of SObject fields.
*/
    private static Map<String, Schema.SObjectField> getSObjectFields(String sObjectName) {
        LOGGER.info('Getting SObject fields for: {0}', new Object[]{sObjectName});
        return Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
    }
    
    /**
* Maps the JSON fields to the Party_Assets_Funds__c SObject fields.
*
* @param subRecord - The sub-record from the JSON.
* @param partyAssetFundId - The ID of the Party Asset Fund.
* @param fieldMappings - The field mappings.
* @param sObjectFields - The SObject fields.
* @return A Party_Assets_Funds__c instance with mapped fields.
*/
    public static Party_Assets_Funds__c mapFieldsToPartyAssetFund(Map<String, Object> subRecord, String partyAssetFundId,
                                                                  Map<String, List<AOB_Field__c>> fieldMappings,
                                                                  Map<String, Schema.SObjectField> sObjectFields) {
                                                                      LOGGER.info('Mapping fields to Party_Assets_Funds__c');
                                                                      Party_Assets_Funds__c partyAssetFund = new Party_Assets_Funds__c();
                                                                      partyAssetFund.Id = (String) subRecord.get('Id');
                                                                      
                                                                      for (AOB_Field__c fieldData : fieldMappings.get(PARTY_ASSETS_FUNDS_OBJECT)) {
                                                                          String sourceFieldName = fieldData.Name;
                                                                          String targetFieldAPIName = fieldData.AOB_SFField__c;
                                                                          if (sObjectFields.containsKey(targetFieldAPIName)) {
                                                                              Schema.DisplayType fieldType = sObjectFields.get(targetFieldAPIName).getDescribe().getType();
                                                                              Object value = subRecord.get(sourceFieldName);
                                                                              if (value != null) {
                                                                                  partyAssetFund.put(targetFieldAPIName, castValueToFieldType(value, fieldType));
                                                                              }
                                                                          }
                                                                      }
                                                                      return partyAssetFund;
                                                                  }
    
    /**
* Casts the value to the appropriate type based on the field type.
*
* @param value - The value to cast.
* @param fieldType - The field type.
* @return The cast value.
*/
    @TestVisible
    private static Object castValueToFieldType(Object value, Schema.DisplayType fieldType) {
        LOGGER.info('Casting value to field type: {0}', new Object[]{fieldType});
        if (fieldType == Schema.DisplayType.STRING) {
            return (String) value;
        } else if (fieldType == Schema.DisplayType.INTEGER) {
            return Integer.valueOf(value.toString());
        } else if (fieldType == Schema.DisplayType.DOUBLE || fieldType == Schema.DisplayType.CURRENCY) {
            return Decimal.valueOf(value.toString());
        } else if (fieldType == Schema.DisplayType.BOOLEAN) {
            return Boolean.valueOf(value.toString());
        } else if (fieldType == Schema.DisplayType.DATE) {
            return Date.valueOf(value.toString());
        } else if (fieldType == Schema.DisplayType.DATETIME) {
            return DateTime.valueOf(value.toString());
        } else {
            return value;
        }
    }
}