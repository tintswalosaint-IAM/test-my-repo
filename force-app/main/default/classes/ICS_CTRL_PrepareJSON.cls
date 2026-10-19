/**
* @description Controller class for SBO-UK onBoardingApplication Feature
* Story: SFP-30128
* @author Ikyatha Naidu
* @date May 2023
* @last modified on : 09-11-2025
* @last modified by : Ramya Gurram  
 * @Modification description : SFP-52215 added Industry related changes
* ******************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 28/01/2025
* Last Modified Description:  SFP-54701 Updated processOtherFieldTypes to compare Norway country code 
*/
public without sharing class ICS_CTRL_PrepareJSON {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_PrepareJSON');
    Public static Map<String, String> industryMap = new Map<String, String>();
    public static Map<String, Object> existingDataMap = new Map<String, Object>();
    Public static string cor='';
    private static final String OBJECT_ASSESSMENT = 'Assessment';
    private static final String FIELD_STATE = 'state';
    private static final String SECTION_BUSINESS_OWNERSHIP = 'Business Ownership';
    private static final String SECTION_ASSETS_INCOME = 'Assets and Income';
    private static final String SECTION_FUTURE_DEPOSITS = 'Future Deposits';
    private static final String SECTION_OTHER_BUSINESS = 'Other Business Interests';
    private static final String SECTION_PERSONAL_DETAILS = 'Personal Details';
    private static final String SECTION_CURRENT_RESIDENTIAL = 'Current Residential Address';
    private static final String SECTION_APPLICANT_RESIDENTIAL = 'Applicant\'s Current Residential Address';
    private static final String SECTION_ADDITIONAL_BANK = 'Additional Bank Accounts';
    Public static Map<string,List<AssessmentQuestionResponse>> responseMap = new Map<string,List<AssessmentQuestionResponse>>();
         
      private static Map<String,List<AssessmentQuestionResponse>> getResponses(String parentId){
        if (!Schema.sObjectType.AssessmentQuestionResponse.isAccessible()) {
            return responseMap;
        }
        List<AssessmentQuestionResponse> allResponses = [
            SELECT Id, ResponseText, Name, AssessmentQuestion.Name
            FROM AssessmentQuestionResponse
            WHERE Assessment.AccountId = :parentId
            WITH SECURITY_ENFORCED
        ];
        for(AssessmentQuestionResponse responseObj : allResponses){
            if(!responseMap.containsKey(responseObj.Name)){
                responseMap.put(responseObj.Name, new List<AssessmentQuestionResponse>());
            }
            responseMap.get(responseObj.Name).add(responseObj);
        }
        return responseMap;
    }
    
    private ICS_CTRL_PrepareJSON(){
        //Private Constructor for instantiation
    }
    /**
* @description Fetches industry data from AOB_ReferencedData__c
*/
   public static void fetchIndustryData() {
        try {
            if (!Schema.sObjectType.AOB_ReferencedData__c.isAccessible()) {
                return;
            }
            for (AOB_ReferencedData__c data : [SELECT Id, AOB_Code__c, Name FROM AOB_ReferencedData__c WHERE AOB_SAPField__c = 'ICS_Industry' WITH SECURITY_ENFORCED]) {
                industryMap.put(data.Name, data.AOB_Code__c);
            }
        } catch (Exception e) {
            LOGGER.error('Error fetching industry data', e);
        }
    }

    /**
* @description Prepares JSON from various inputs
* @param objectInfoMap List of SObjects to process
* @param objectWithFieldAPINames Map of object names to their fields
* @param quetionWithScreenNameSet Map of questions to screen names
* @param parentId Parent record Id
* @param sectionName Name of the current section
* @param tableScreenFields Set of table screen fields
* @return List<String> List of JSON strings
*/
    public static List<String> prepareJSON(List<SObject> objectInfoMap,
                                           Map<String, List<AOB_Field__c>> objectWithFieldAPINames,
                                           Map<String, String> quetionWithScreenNameSet,
                                           String parentId,
                                           String sectionName,
                                           Set<String> tableScreenFields) {
                                               List<String> jsonListString = new List<String>();
												getResponses(parentId);
                                               try {
                                                   if (needsIndustryData(sectionName)) {
                                                       fetchIndustryData();
                                                   }

                                                   Map<String, Object> jsonMap = new Map<String, Object>();
                                                   String searchKey = '';
                                                   Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap = getResponseCurrencyMap(parentId);
                                                   Map<String, List<String>> mandatoryFields = getMandatoryFields();

                                                   if (objectInfoMap == null || objectInfoMap.isEmpty()) {
                                                       objectInfoMap = new List<SObject>{Schema.getGlobalDescribe().get(OBJECT_ASSESSMENT).newSObject()};
                                                           }
                                                   for (SObject objectData : objectInfoMap) {
                                                       processObject(objectData, objectWithFieldAPINames, sectionName, searchKey, responseCurrencyMap, mandatoryFields, jsonMap, parentId, quetionWithScreenNameSet);


                                                       if (!jsonMap.isEmpty()) {
                                                           jsonListString.add(JSON.serialize(jsonMap));
                                                       }
                                                   }

                                                   existingDataMap = jsonMap;

                                               } catch (Exception e) {

                                                   LOGGER.error('Error preparing JSON', e);
                                               }

                                               return jsonListString;
                                           }

    /**
    * @description Processes a single SObject
    */
     private static void processObject(SObject objectData,
                                    Map<String, List<AOB_Field__c>> objectWithFieldAPINames,
                                    String sectionName,
                                    String searchKey,
                                    Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap,
                                    Map<String, List<String>> mandatoryFields,
                                    Map<String, Object> jsonMap,
                                    String parentId,
                                    Map<String, String> questionWithScreenNameSet) {
        if (objectData == null) {
            return;
        }
        jsonMap.clear();
        String objectName = objectData.getSObjectType().getDescribe().getName();
    
        if (objectWithFieldAPINames.containsKey(objectName)) {
            setJsonMapIdentifiers(objectData, objectName, jsonMap);
            searchKey = sectionName + ':' + (String)objectData.get('Id');
        } else if (sectionName != SECTION_ADDITIONAL_BANK) {
            jsonMap.put('objectName', OBJECT_ASSESSMENT);
        }
    
        if (objectName == 'IdentityDocument') {
            processIdentityDocument(objectData, mandatoryFields, jsonMap);
        } else if (objectWithFieldAPINames.containsKey(objectName)) {
            processFields(objectData, objectWithFieldAPINames.get(objectName), sectionName, searchKey, responseCurrencyMap, jsonMap);
        }
    
        if (questionWithScreenNameSet != null && !questionWithScreenNameSet.isEmpty()) {
            processQuestions(searchKey, sectionName, jsonMap, parentId, questionWithScreenNameSet);
        }
    }
    private static void setJsonMapIdentifiers(SObject objectData, 
                                          String objectName,
                                          Map<String, Object> jsonMap) {
        Boolean isContactPhone = objectName == 'ContactPointPhone';
        Boolean isPrimary = isContactPhone && (Boolean)objectData.get('IsPrimary');
        Boolean shouldShowId = !isContactPhone || !isPrimary;
        
        if (shouldShowId) {
            jsonMap.put('Id', (String)objectData.get('Id'));
            jsonMap.put('objectName', objectName == OBJECT_ASSESSMENT ?OBJECT_ASSESSMENT: objectName);
        }
    }
    /**
*
* @description Processes fields of an SObject
*/
    private static void processFields(SObject objectData,
                                      List<AOB_Field__c> fields,
                                      String sectionName,
                                      String searchKey,
                                      Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap,
                                      Map<String, Object> jsonMap
                                      ) {

                                          for (AOB_Field__c fieldData : fields) {
                                              String fieldAPIName = fieldData.AOB_SFField__c.contains('table:') ? fieldData.AOB_SFField__c.split(':')[1] : fieldData.AOB_SFField__c;

                                              if (objectData.get(fieldAPIName) != null) {
                                                  processField(objectData, fieldData, fieldAPIName, sectionName, searchKey, responseCurrencyMap, jsonMap);
                                              }
                                          }
                                      }

    /**
* @description Processes a single field
*/
    private static void processField(SObject objectData,
                                     AOB_Field__c fieldData,
                                     String fieldAPIName,
                                     String sectionName,
                                     String searchKey,
                                     Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap,
                                     Map<String, Object> jsonMap) {
                                         String objectName = objectData.getSObjectType().getDescribe().getName();

                                         processObjectSpecificLogic(objectData, objectName, sectionName, jsonMap);
                                         processSectionSpecificLogic(objectData, objectName, sectionName, jsonMap);

                                         SObjectType r = ((SObject)(Type.forName('Schema.' + objectName).newInstance())).getSObjectType();
                                         DescribeSObjectResult d = r.getDescribe();
                                         String fieldType = d.fields.getMap().get(fieldAPIName).getDescribe().getType().name().toLowerCase();

                                         processFieldByType(objectData, fieldData, fieldAPIName, fieldType, searchKey, responseCurrencyMap, jsonMap);
                                     }

    private static void processObjectSpecificLogic(SObject objectData, String objectName, String sectionName, Map<String, Object> jsonMap) {

        if (objectName == 'PartyProfileAddress') {

            processPartyProfileAddress(objectData, sectionName, jsonMap);
        } else if (objectName == 'PartyProfile') {
            cor = (String)objectData.get('Country_of_Residence__c');

            if (sectionName == SECTION_BUSINESS_OWNERSHIP) {
                processBusinessOwnershipFields(objectData, jsonMap);
            }
        } else if (objectName == 'ContactPointPhone') {
            processContactPointPhone(objectData, jsonMap);
        }
    }

    private static void processSectionSpecificLogic(SObject objectData, String objectName, String sectionName, Map<String, Object> jsonMap) {
        if (sectionName == SECTION_BUSINESS_OWNERSHIP) {
            processBusinessOwnership(objectData, objectName, jsonMap);
        }else if (sectionName == SECTION_ASSETS_INCOME || sectionName == SECTION_FUTURE_DEPOSITS) {
            processAssetsAndIncome(objectData, jsonMap,sectionName);
        } else if (sectionName == SECTION_OTHER_BUSINESS) {
            processOtherBusinessInterests(objectData, jsonMap);
        }
    }

    private static void processFieldByType(SObject objectData, AOB_Field__c fieldData, String fieldAPIName, String fieldType,
                                           String searchKey, Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap,
                                           Map<String, Object> jsonMap) {
                                               switch on fieldType {
                                                   when 'currency' {
                                                       processCurrencyField(fieldData, searchKey, responseCurrencyMap, jsonMap);
                                                   }
                                                   when 'double', 'percent', 'decimal' {
                                                       jsonMap.put(fieldData.Name, String.valueOf(objectData.get(fieldAPIName)));
                                                   }
                                                   when 'boolean' {
                                                       jsonMap.put(fieldData.Name, (Boolean)objectData.get(fieldAPIName) ? 'TRUE' : 'FALSE');
                                                   }
                                                   when 'date' {
                                                       processDateField(objectData, fieldData, fieldAPIName, jsonMap);
                                                   }
                                                   when else {
                                                       processOtherFieldTypes(objectData, fieldData, fieldAPIName,  jsonMap);
                                                   }
                                               }
                                           }
    private static void processPartyProfileAddress(SObject objectData, String sectionName, Map<String, Object> jsonMap) {
       
        if (sectionName == SECTION_CURRENT_RESIDENTIAL || sectionName == SECTION_PERSONAL_DETAILS || sectionName == SECTION_APPLICANT_RESIDENTIAL) {
            string state = (String)objectData.get(FIELD_STATE);
            if(sectionName == SECTION_PERSONAL_DETAILS) {
                if (state.contains(';')) {
                    jsonMap.put('Province', objectData.get(FIELD_STATE));
                } else {
                    jsonMap.put('ProvinceName', objectData.get(FIELD_STATE));
                }
            }
            if(sectionName == SECTION_CURRENT_RESIDENTIAL) {
                jsonMap.put('Province', objectData.get(FIELD_STATE));
            }
            if(sectionName == SECTION_APPLICANT_RESIDENTIAL) {

                jsonMap.put('ProvinceF', objectData.get(FIELD_STATE));
            }
            
        }
        
        jsonMap.put('Length of time at address', ICS_CTRL_FecthOnboardingDetails.checkDateDifference(
            Date.valueOf(objectData.get('Date_Move_In__c')),
            Date.valueOf(objectData.get('Date_Move_Out__c'))
        ));
    }

    private static void processBusinessOwnership(SObject objectData, String objectName, Map<String, Object> jsonMap) {
        if (objectName == 'PartyProfile') {
            jsonMap.put('% of Business Owned', (Decimal)objectData.get('Percentage_of_Business__c'));
        }
    }



    private static void processAssetsAndIncome(SObject objectData, Map<String, Object> jsonMap, String sectionName) {
         jsonMap.put('isListed', objectData.get('Is_listed_in_assets__c'));
       
             if(objectData.get('Percentage_of_Company_Ownership__c') != null && objectData.get('Percentage_of_Company_Ownership__c') == 100){
                 jsonMap.put('Are you the sole owner of the business?', 'TRUE');
             }else{
                 jsonMap.put('Are you the sole owner of the business?', 'FALSE');
             }
         
        if (objectData.get('Wealth_Details_Inclusive_of_Amount__c') != null) {
            processWealthDetails(objectData, jsonMap);
        }
        if(objectData.get('Full_details_inclusive_of_amount__c') != null){
            processCurrencyFieldData(objectData, jsonMap);
        }
     
          if(objectData.get('Value_of_the_business__c') != null && sectionName==SECTION_FUTURE_DEPOSITS ){
            
               jsonMap.put('Value of the business', objectData.get('Value_of_the_business__c'));
        }
    }

    private static void processOtherBusinessInterests(SObject objectData, Map<String, Object> jsonMap) {
        jsonMap.put('Relationship with Interest', objectData.get('Relationship__c'));
        jsonMap.put('Receive Income from this', (Boolean)objectData.get('Is_any_income_from_this_interest__c') ? 'Yes' : 'No');
    }


    private static void processWealthDetails(SObject objectData, Map<String, Object> jsonMap) {
        String wealthDetails = (String)objectData.get('Wealth_Details_Inclusive_of_Amount__c');
        List<String> detailsList = wealthDetails.split(';');
        for (String detail : detailsList) {
            List<String> parts = detail.split(',');
            if (parts.size() == 2) {
                jsonMap.put(parts[0], parts[1]);
            }
        }
    }
    private static void processCurrencyFieldData(SObject objectData, Map<String, Object> jsonMap) {
        String wealthDetails = (String)objectData.get('Full_details_inclusive_of_amount__c');
        List<String> detailsList = wealthDetails.split(';');
        for (String detail : detailsList) {
            List<String> parts = detail.split(',');
            if (parts.size() == 2) {
                jsonMap.put(parts[0], parts[1]);
            }
        }
    }
    private static void processCurrencyField(AOB_Field__c fieldData,
                                             String searchKey,
                                             Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap,
                                             Map<String, Object> jsonMap) {
                                                 if (responseCurrencyMap.containsKey(searchKey)) {
                                                     for (AssessmentQuestionResponse responseData : responseCurrencyMap.get(searchKey)) {
                                                         if (responseData.AssessmentQuestion.Name == fieldData.Name + 'Currency') {
                                                             String responseInfo = responseData.ResponseText;
                                                             String[] splitResponse = responseInfo.split(':');
                                                             if (splitResponse.size() > 1) {
                                                                 jsonMap.put(fieldData.Name, splitResponse[1]);
                                                                 jsonMap.put(fieldData.Name + 'Currency', responseInfo);
                                                             }
                                                         }
                                                     }
                                                 }
                                             }

    private static void processDateField(SObject objectData,
                                         AOB_Field__c fieldData,
                                         String fieldAPIName,
                                         Map<String, Object> jsonMap) {
                                             if (objectData.get(fieldAPIName) != null) {
                                                 Date inputDate = Date.valueOf(String.valueOf(objectData.get(fieldAPIName)));
                                                 Integer inpYear = inputDate.year();
                                                 Integer inpMonth = inputDate.month();
                                                 Integer inpDay = inputDate.day();
                                                 Date formattedDate = Date.newInstance(inpYear, inpMonth, inpDay);
                                                 jsonMap.put(fieldData.Name, formattedDate);
                                             }
                                         }

    private static void processOtherFieldTypes(SObject objectData,
                                               AOB_Field__c fieldData,
                                               String fieldAPIName,

                                               Map<String, Object> jsonMap) {
                                                String fieldValue = (String)objectData.get(fieldAPIName);
                                                if ('Yes'.equals(fieldValue)) {
                                                jsonMap.put(fieldData.Name, 'TRUE');
                                                } else if ('No'.equals(fieldValue)) {
                                                    jsonMap.put(fieldData.Name, 'FALSE');
                                                } else if (!jsonMap.containsKey(fieldData.Name) && fieldData.Name != 'Alternative Contact Number' && fieldData.Name != 'Contact Number') {
                                                    // If value is not null, escape double quotes
                                                    if (fieldValue != null) {
                                                        fieldValue = fieldValue.replaceall('"', '\'');
                                                    }    
                                                     if(fieldData.Name == 'Jurisdiction coverage of sales'){
                                                        string country = '""';
                                                            country= countryCodeMap((string)fieldValue);
                                                        jsonMap.put(fieldData.Name, country);
                                                     }  else{
                                                         jsonMap.put(fieldData.Name,fieldValue);
                                                     }
                                               		
                                                       
                                                   }
                                               }
	
    public static string countryCodeMap(string countryCode) {
      
        map<string,string> countrycodeMap = new map<string,string>();
        Schema.DescribeFieldResult fieldResult = partyprofile.Country_of_Residence__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            countrycodeMap.put(f.getLabel(), f.getValue());
        }
        return countrycodeMap.containsKey(countryCode) ? countrycodeMap.get(countryCode) : '""';
      
    }
    private static void processBusinessOwnershipFields(SObject objectData, Map<String, Object> jsonMap) {
        processFormerOrMaidenName(objectData, jsonMap);
        processMaritalStatus(objectData, jsonMap);
        processOtherNames(objectData, jsonMap);
    }

    private static void processFormerOrMaidenName(SObject objectData, Map<String, Object> jsonMap) {
        String hasFormerName = (String)objectData.get('Has_Former_Name__c');
        String hasMaidenName = (String)objectData.get('Has_Maiden_Name__c');

        Map<String, String> nameTypeMap = new Map<String, String>{
            'Yes,Yes' => 'FormerAndMaiden',
                'Yes,No' => 'FormerName',
                'No,Yes' => 'MaidenName',
                'No,No'=>'None'
                };

                    String key = hasFormerName + ',' + hasMaidenName;
        if (nameTypeMap.containsKey(key)) {
            jsonMap.put('Former Name or Maiden Name', nameTypeMap.get(key));
        }
    }
    private static void processMaritalStatus(SObject objectData, Map<String, Object> jsonMap) {
        String maritalStatus = (String)objectData.get('WI_MaritialStatus__c');

        if (String.isNotBlank(maritalStatus)) {
            Map<String, String> maritalStatusMap = ICS_CTRL_FetchTrustDataProcessor.getMaritalStatusMap();
            String upperCaseStatus = maritalStatus.toUpperCase();
            if (maritalStatusMap.containsKey(upperCaseStatus)) {
                jsonMap.put('Marital Status', maritalStatusMap.get(upperCaseStatus));
            }
        }
    }
    private static void processOtherNames(SObject objectData, Map<String, Object> jsonMap) {
        if ((String)objectData.get('Has_different_First_Middle_Family_Name__c') == 'Yes') {
            List<String> otherNamesList = new List<String>();
            Map<String, String> nameFieldMap = new Map<String, String>{
                'Different_First_Name__c' => 'OtherFirstName',
                    'Different_Middle_Name__c' => 'OtherMiddleName',
                    'Different_Last_Name__c' => 'OtherSurname'
                    };

                        for (String field : nameFieldMap.keySet()) {
                            if (String.isNotBlank((String)objectData.get(field))) {
                                otherNamesList.add(nameFieldMap.get(field));
                            }
                        }

            jsonMap.put('Other Names', otherNamesList.isEmpty() ? 'None' : String.join(otherNamesList, '; '));
        }
    }
    private static Map<String, Object>  processContactPointPhone(SObject objectData, Map<String, Object> jsonMap) {
        if ((Boolean)objectData.get('IsPrimary')) {
            jsonMap.put('Contact Number', objectData.get('TelephoneNumber'));

        }else{
             jsonMap.put('Alternative Contact Number',objectData.get('TelephoneNumber'));
        }
        return jsonMap;
    }

    /**
* @description Processes an IdentityDocument object
*/
    private static void processIdentityDocument(SObject objectData,
                                                Map<String, List<String>> mandatoryFields,
                                                Map<String, Object> jsonMap
                                                ) {
                                                    String docData = (String)objectData.get('IdDocumentType');
                                                    String docName = (String)objectData.get('Name');

                                                    if (mandatoryFields.containsKey(docData + ':' + cor)) {
                                                        for (String uiData : mandatoryFields.get(docData + ':' + cor)) {
                                                            if (docName.contains(':')) {
                                                                uiData = docName.split(':')[0];
                                                                jsonMap.put(uiData, docName.split(':')[1]);
                                                            } else {
                                                                jsonMap.put(uiData, docName);
                                                            }
                                                        }
                                                    }
                                                    if (mandatoryFields.containsKey(docData + ':null')) {
                                                        for (String uiData : mandatoryFields.get(docData + ':null')) {
                                                            jsonMap.put(uiData, docName);
                                                        }
                                                    }
                                                }


/**
 * @description Process questions and add responses to JSON map
 */
    private static void processQuestions(String searchKey,
                                         String sectionName,
                                         Map<String, Object> jsonMap,
                                         String parentId,
                                         Map<String, String> questionWithScreenNameSet) {
        if (questionWithScreenNameSet == null || questionWithScreenNameSet.isEmpty()) {
            return;
        }
        try {
            String finalKey = String.isBlank(searchKey) ? sectionName : searchKey;
    
            List<AssessmentQuestionResponse> relevantResponses = new List<AssessmentQuestionResponse>();
            if (responseMap.containsKey(finalKey)) {
                relevantResponses.addAll(responseMap.get(finalKey));
            }
            if (responseMap.containsKey(sectionName)) {
                relevantResponses.addAll(responseMap.get(sectionName));
            }
    
            processRelevantResponses(relevantResponses, jsonMap);
            processQuestionResponseMap(
                ICS_CTRL_FecthOnboardingDetails.fetchQuetsionReposneData(parentId, finalKey),
                questionWithScreenNameSet,
                jsonMap
            );
        } catch(Exception e) {
            LOGGER.error('Error in processQuestions: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
        private static void processRelevantResponses(List<AssessmentQuestionResponse> relevantResponses,
                                                 Map<String, Object> jsonMap) {
        for (AssessmentQuestionResponse response : relevantResponses) {
            jsonMap.put(response.AssessmentQuestion.Name + ':Id', response.Id);
            jsonMap.put(response.AssessmentQuestion.Name, response.ResponseText);
        }
    }
    
    private static void processQuestionResponseMap(Map<String, AssessmentQuestionResponse> questionResponseDataMap,
                                                   Map<String, String> questionWithScreenNameSet,
                                                   Map<String, Object> jsonMap) {
        for (String question : questionResponseDataMap.keySet()) {
            if (questionWithScreenNameSet.containsKey(question)) {
                AssessmentQuestionResponse qResponse = questionResponseDataMap.get(question);
                String screenName = questionWithScreenNameSet.get(question);
                jsonMap.put(screenName, qResponse.ResponseText);
                jsonMap.put(screenName + ':Id', qResponse.Id);
            }
        }
    }

    /**
* @description Checks if industry data is needed for the given section
*/
    private static Boolean needsIndustryData(String sectionName) {
        Set<String> sectionsNeedingIndustryData = new Set<String>{
            SECTION_BUSINESS_OWNERSHIP, SECTION_ASSETS_INCOME,
                'Dual Employment Details', 'Previous Employment Details', SECTION_OTHER_BUSINESS,SECTION_FUTURE_DEPOSITS
                };
                    return sectionsNeedingIndustryData.contains(sectionName);
    }

    /**
* @description Retrieves response currency map
*/
    private static Map<String, List<AssessmentQuestionResponse>> getResponseCurrencyMap(String parentId) {
        Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap = new Map<String, List<AssessmentQuestionResponse>>();
        try {
            if (!Schema.sObjectType.AssessmentQuestionResponse.isAccessible()) {
                return responseCurrencyMap;
            }
            List<AssessmentQuestionResponse> responses = [
                SELECT Id, Name, ResponseText, AssessmentQuestion.Name
                FROM AssessmentQuestionResponse
                WHERE AssessmentQuestion.QuestionText LIKE '%Currency%'
                AND Assessment.AccountId = :parentId
                WITH SECURITY_ENFORCED
            ];
            for (AssessmentQuestionResponse response : responses) {
                if (!responseCurrencyMap.containsKey(response.Name)) {
                    responseCurrencyMap.put(response.Name, new List<AssessmentQuestionResponse>());
                }
                responseCurrencyMap.get(response.Name).add(response);
            }
        } catch (Exception e) {
            LOGGER.error('Error retrieving response currency map', e);
        }
        return responseCurrencyMap;
    }

    /**
* @description Retrieves mandatory fields from custom metadata
*/
    private static Map<String, List<String>> getMandatoryFields() {
        Map<String, List<String>> mandatoryFields = new Map<String, List<String>>();
        try {
            for (ICS_GBGManadatoryFields__mdt gbgData : ICS_GBGManadatoryFields__mdt.getAll().values()) {
                String key = gbgData.ICS_Salesforce_Type__c + ':' + gbgData.Country_Based__c;
                if (mandatoryFields.containsKey(key)) {
                     mandatoryFields.get(key).add(gbgData.UIField__c);
                } else {
                   mandatoryFields.put(key, new List<String>{gbgData.UIField__c});
                }
            }
        } catch (Exception e) {
            LOGGER.error('Error retrieving mandatory fields', e);
        }
        return mandatoryFields;
    }
}