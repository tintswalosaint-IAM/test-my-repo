/***************************************************************************************

@name of the Class : ICS_CTRL_FetchTrustDataProcessor.cls
@description : class used as controller for  SBO-UK onBoardingApplication Feature
@author : Ikyatha Naidu
@created Date : May 05 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On :  06-06-2024
@modification description: SFP-30128
***************************************************************************************/

public without sharing class ICS_CTRL_FetchTrustDataProcessor {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GBG');

    @AuraEnabled(cacheable=true)
    public static String prepareJsonForUI(String parentId) {
        try{
        Map<String, Map<String, String>> fieldMappings = getFieldMappings(parentId);
        Map<String, Object> data = new Map<String, Object>();
       
         List<Opportunity> opportunityList = [SELECT Id, LeadSource FROM Opportunity WHERE AccountId = :parentId];
            Boolean isIFa = false;

            if (!opportunityList.isEmpty()) {
                Opportunity opportunityData = opportunityList[0]; // Get the first record if it exists
                if (opportunityData.LeadSource == 'IFA') {
                    isIFa = true;
                }
            }
        if(isIFa){
             data.put('Is the applicant associated to a Trust Structure? If yes, how many?', checkTrustStructure(parentId));
        }else{
            data.put('Are you related to a Trust structure?', checkTrustStructure(parentId).responsetext);
            data.put('Are you related to a Trust structure?:Id',checkTrustStructure(parentId).Id);
        }

        List<Map<String, Object>> trustsData = prepareTrustsData(parentId, fieldMappings);
        data.put('accordian', trustsData);

        AssessmentQuestionResponse relatedTrust = getRelatedTrustResponse(parentId);
            if(isIFa){
                return '[{"objectName":"Party_asset_Funds__c","Is the applicant associated to a Trust Structure? If yes, how many?": "' + relatedTrust + '","accordian":' + JSON.serialize(trustsData) + '}]';
            } else{
                return '[{"objectName":"Party_asset_Funds__c","Are you related to a Trust structure?": "' + relatedTrust.responsetext + '","Are you related to a Trust structure?:Id": "' + relatedTrust.Id + '","accordian":' + JSON.serialize(trustsData) + '}]';
            }
    	}catch(exception exc){
           LOGGER.error(exc.getmessage());
           throw new AuraHandledException(exc.getmessage());
       }
    }

    private static List<Map<String, Object>> prepareTrustsData(String parentId, Map<String, Map<String, String>> fieldMappings) {
        List<Map<String, Object>> trustsData = new List<Map<String, Object>>();
        PartyProfile profileData = new sel_partyProfile().selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        List<Party_Assets_Funds__c> trustRecords = getTrustRecords(profileData.id);
        Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap = getResponseCurrencyMap(parentId);

        for (Integer i = 0; i < trustRecords.size(); i++) {
            Party_Assets_Funds__c trustRecord = trustRecords[i];
            Map<String, Object> trustData = prepareTrustData(trustRecord, i + 1, fieldMappings,parentId);
            trustData.put('Add Another Person', prepareProfilesData(profileData.id, trustRecord.id, fieldMappings));
            trustData.put('ADD Benefit', prepareBenefitsData(trustRecord.Id, fieldMappings, responseCurrencyMap));
            trustsData.add(trustData);
        }

        return trustsData;
    }

    private static Map<String, Object> prepareTrustData(Party_Assets_Funds__c trustRecord, Integer counter, Map<String, Map<String, String>> fieldMappings,String parentId) {
        Map<String, Object> trustData = new Map<String, Object>();
        trustData.put('label', 'Trust ' + counter);
        trustData.put('index', counter);
        trustData.put('Id', trustRecord.id);
        
         List<Opportunity> opportunityList = [SELECT Id, LeadSource FROM Opportunity WHERE AccountId = :parentId];
            Boolean isIFa = false;

            if (!opportunityList.isEmpty()) {
                Opportunity opportunityData = opportunityList[0]; // Get the first record if it exists
                if (opportunityData.LeadSource == 'IFA') {
                    isIFa = true;
                }
            }
        string trustRelatedText = isIFa ? 'Does the applicant receive any disbursement or benefit from this Trust?': 'Do you receive any disbursement or benefit from a Trust?';
        trustData.put(trustRelatedText, trustRecord.Is_Trust_Beneficiary__c ? 'TRUE' : 'FALSE');
        populateMapWithFieldMappings(trustData, trustRecord, 'Party_Assets_Funds__c', fieldMappings);
        return trustData;
    }

    private static List<Map<String, Object>> prepareProfilesData(Id profileDataId, Id trustRecordId, Map<String, Map<String, String>> fieldMappings) {
        List<Map<String, Object>> profilesData = new List<Map<String, Object>>();
        for (PartyProfile profileRecord : getProfileRecords(profileDataId, trustRecordId)) {
            Map<String, Object> profileDataMap = new Map<String, Object>();
            profileDataMap.put('Id', profileRecord.id);
            populateMapWithFieldMappings(profileDataMap, profileRecord, 'PartyProfile', fieldMappings);
            populateAdditionalProfileData(profileDataMap, profileRecord);
            profilesData.add(profileDataMap);
        }
        return profilesData;
    }

    private static void populateAdditionalProfileData(Map<String, Object> profileDataMap, PartyProfile profileRecord) {
        profileDataMap.put('Former name or maiden name', getFormerOrMaidenNameValue(profileRecord));
        profileDataMap.put('Marital status', getMaritalStatus(profileRecord.WI_MaritialStatus__c));
        profileDataMap.put('Other name', getOtherNames(profileRecord));
    }

    private static List<Map<String, Object>> prepareBenefitsData(Id trustRecordId, Map<String, Map<String, String>> fieldMappings, Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap) {
        List<Map<String, Object>> benefitsData = new List<Map<String, Object>>();
        for (Party_Assets_Funds__c benefitRecord : getBenefitRecords(trustRecordId)) {
            Map<String, Object> benefitData = new Map<String, Object>();
            benefitData.put('Id', benefitRecord.id);
            populateMapWithFieldMappings(benefitData, benefitRecord, 'Party_Assets_Funds__c', fieldMappings);
            populateCurrencyData(benefitData, benefitRecord, responseCurrencyMap);
            benefitsData.add(benefitData);
        }
        return benefitsData;
    }

    @TestVisible
    private static Map<String, Map<String, String>> getFieldMappings(string parentId) {
        Map<String, Map<String, String>> fieldMappings = new Map<String, Map<String, String>>();
        
         List<Opportunity> opportunityList = [SELECT Id, LeadSource FROM Opportunity WHERE AccountId = :parentId];
            Boolean isIFa = false;

            if (!opportunityList.isEmpty()) {
                Opportunity opportunityData = opportunityList[0]; // Get the first record if it exists
                if (opportunityData.LeadSource == 'IFA') {
                    isIFa = true;
                }
            }
        string isRelatesTrustScreen = isIFa ? 'ICS UK IFA Financial Details':'ICS UK Financial Details';
        for (AOB_Field__c fieldMapping : [
            SELECT AOB_SFObject__c, Name, AOB_SFField__c
            FROM AOB_Field__c
            WHERE AOB_Section__r.Name = 'Trusts' AND AOB_Section__r.AOB_Screen__r.Name = :isRelatesTrustScreen
        ]) {
            if (!fieldMappings.containsKey(fieldMapping.AOB_SFObject__c)) {
                fieldMappings.put(fieldMapping.AOB_SFObject__c, new Map<String, String>());
            }
            fieldMappings.get(fieldMapping.AOB_SFObject__c).put(fieldMapping.Name, fieldMapping.AOB_SFField__c);
        }

        return fieldMappings;
    }

    @TestVisible
    private static void populateMapWithFieldMappings(Map<String, Object> dataMap, SObject sObj, String sObjectName, Map<String, Map<String, String>> fieldMappings) {
        if (fieldMappings.containsKey(sObjectName)) {
            Map<String, String> objectFieldMappings = fieldMappings.get(sObjectName);
            for (String sourceFieldName : objectFieldMappings.keySet()) {
                String targetFieldAPIName = objectFieldMappings.get(sourceFieldName);
                Object fieldValue = sObj.get(targetFieldAPIName);
                if (fieldValue instanceof Boolean) {
                    dataMap.put(sourceFieldName, (Boolean)fieldValue ? 'TRUE' : 'FALSE');
                } else {
                    if(sourceFieldName == 'Location where Trust is registered' && sObjectName == 'Party_Assets_Funds__c'){
                        string country = countryCodeMap((string)fieldValue);
                        dataMap.put(sourceFieldName, country);
                    }else{
                    dataMap.put(sourceFieldName, fieldValue);
                }

                }
            }
        }
    }
	public static string countryCodeMap(string countryCode) {
        try{
        map<string,string> countrycodeMap = new map<string,string>();
        Schema.DescribeFieldResult fieldResult = partyprofile.Country_of_Residence__c.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            countrycodeMap.put(f.getLabel(), f.getValue());
        }
        return countrycodeMap.containsKey(countryCode) ? countrycodeMap.get(countryCode) : '';
        }Catch(Exception e){
            LOGGER.error('Error in countryCodeMap: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @TestVisible
    private static AssessmentQuestionResponse checkTrustStructure(String parentId) {
        Assessment assessment = [
            SELECT Id, accountId
            FROM Assessment
            WHERE accountId = :parentId
            LIMIT 1
        ];

        if (assessment == null) {
            return null;
        }

        SEL_AssesmentQuestionResponse selectorResponse = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responses = selectorResponse.selectByParentId(parentId);

        for (AssessmentQuestionResponse response : responses) {
            if (response.Name.startsWith('Trusts')) {
                return response;
            }
        }return null;
    }

    @AuraEnabled(cacheable=true)@testvisible
    public static Map<String, String> getMaritalStatusMap() {
        try{
        Map<String, String> maritalStatusMap = new Map<String, String>{
            '1' => 'SINGLE',
            '2' => 'MARRIED',
            '3' => 'SEPARATED',
            '4' => 'DIVORCED',
            '5' => 'WIDOWED',
            '6' => 'UNCLASSIFIED',
            'SINGLE' => '1',
            'MARRIED' => '2',
            'SEPARATED' => '3',
            'DIVORCED' => '4',
            'WIDOWED' => '5',
            'UNCLASSIFIED' => '6'
        };
              return maritalStatusMap;
            }catch(exception exc){LOGGER.error(exc.getmessage()); throw new AuraHandledException(exc.getmessage());}

    }

    private static List<Party_Assets_Funds__c> getTrustRecords(Id profileId) {
        return [SELECT Id, Name, Deed_Number__c, Related_To_PEP_Through_Trust__c, Is_Trust_Beneficiary__c, Beneficiary_Of_Trust__c, Annual_Monetary_Value__c, Type__c, Type_of_Benefit__c, Rationale_for_Trust__c,
                Trust_Name__c, Frequency_of_Trust_Benefit__c, TrustDeed_or_Letter_of_wishes__c, Description__c, Locations__c,
                Settlor_Name__c, Wealth_Source_and_Timeline__c, Wealth_Details_Inclusive_of_Amount__c, Date_Funds_Received__c
                FROM Party_Assets_Funds__c
                WHERE Type__c='Trust' AND Party_Profile__c = :profileId with security_enforced  order by createddate asc];
    }

    private static List<PartyProfile> getProfileRecords(Id profileDataId, Id trustRecordId) {
        return [SELECT Id, Name, Person_Title__c, FirstName, LastName, MiddleName, Gender, DateOfBirth, WI_MaritialStatus__c,
                CountryofBirth, Town_City_of_Birth__c, Country_of_Residence__c, Country_of_Nationality__c,
                Second_Country_of_Nationality__c, Different_First_Name__c, Different_Middle_Name__c, Different_Last_Name__c,
                Maiden_Name__c, Former_Name__c, PrimaryIdentifierType, PrimaryIdentifier, Has_Former_Name__c,
                Has_Maiden_Name__c, Has_different_First_Middle_Family_Name__c
                FROM PartyProfile
                WHERE RelatedPartyProfileId = :profileDataId AND name='PEP' AND Party_Assets_Funds__c = :trustRecordId  order by createddate asc];
    }

    private static List<Party_Assets_Funds__c> getBenefitRecords(Id trustRecordId) {
        return [SELECT Id, Name, type__c, Deed_Number__c,Is_Trust_Beneficiary__c, Related_To_PEP_Through_Trust__c, Beneficiary_Of_Trust__c, Annual_Monetary_Value__c, Type_of_Benefit__c, Rationale_for_Trust__c,
                Trust_Name__c, Frequency_of_Trust_Benefit__c, TrustDeed_or_Letter_of_wishes__c, Description__c, Locations__c,
                Settlor_Name__c, Wealth_Source_and_Timeline__c, Wealth_Details_Inclusive_of_Amount__c, Date_Funds_Received__c
                FROM Party_Assets_Funds__c
                WHERE Trust__c = :trustRecordId AND Type__c = 'Benefit from a trust'  order by createddate asc];
    }

    private static AssessmentQuestionResponse getRelatedTrustResponse(String parentId) {
        SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responseList = selectorAssessmentqueResponse.selectByParentIdAndSectionName(parentId, 'Trusts');
        return responseList.isEmpty() ? null : responseList[0];
    }

    private static String getFormerOrMaidenNameValue(PartyProfile profileRecord) {
        if (profileRecord.Has_Former_Name__c == 'Yes' && profileRecord.Has_Maiden_Name__c == 'Yes') {
            return 'FormerAndMaiden';
        } else if (profileRecord.Has_Former_Name__c == 'Yes') {
            return 'FormerName';
        } else if (profileRecord.Has_Maiden_Name__c == 'Yes') {
            return 'MaidenName';
        }
        return 'None';
    }

    private static String getMaritalStatus(String status) {
        if (status != null) {
            Map<String, String> maritalStatusMap = getMaritalStatusMap();
            return maritalStatusMap.get(status.toUpperCase());
        }
        return null;
    }
	@TestVisible
    private static String getOtherNames(PartyProfile profileRecord) {
        if (profileRecord.Has_different_First_Middle_Family_Name__c == 'Yes') {
            List<String> otherNamesList = new List<String>();
            if (profileRecord.Different_First_Name__c != null) {
                otherNamesList.add('OtherFirstName');
            }
            if (profileRecord.Different_Middle_Name__c != null) {
                otherNamesList.add('OtherMiddleName');
            }
            if (profileRecord.Different_Last_Name__c != null) {
                otherNamesList.add('OtherSurname');
            }
            return otherNamesList.isEmpty() ? 'None' : String.join(otherNamesList, '; ');
        }
        return 'None';
    }

    private static void populateCurrencyData(Map<String, Object> benefitData, Party_Assets_Funds__c benefitRecord, Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap) {
        String searchKey = 'Trusts:' + benefitRecord.id;
        if (responseCurrencyMap.containsKey(searchKey)) {
            for (AssessmentQuestionResponse responseData : responseCurrencyMap.get(searchKey)) {
                if (responseData.AssessmentQuestion.Name == 'Annual Monetary ValueCurrency') {
                    String[] splitResponse = responseData.ResponseText.split(':');
                    if (splitResponse.size() > 1) {
                        benefitData.put('Annual Monetary Value', splitResponse[1]);
                        benefitData.put('Annual Monetary ValueCurrency', responseData.ResponseText);
                        benefitData.put('Annual Monetary ValueCurrency:Id', responseData.id);
                    }
                    break;
                }
            }
        }
    }

    private static Map<String, List<AssessmentQuestionResponse>> getResponseCurrencyMap(String parentId) {
        Map<String, List<AssessmentQuestionResponse>> responseCurrencyMap = new Map<String, List<AssessmentQuestionResponse>>();
        for (AssessmentQuestionResponse responseData : [
            SELECT Id, Name, ResponseText, AssessmentQuestion.Name
            FROM AssessmentQuestionResponse
            WHERE AssessmentQuestion.QuestionText LIKE '%Currency%'
            AND Assessment.AccountId = :parentId
        ]) {
            if (responseCurrencyMap.containsKey(responseData.Name)) {
                 responseCurrencyMap.get(responseData.Name).add(responseData);
            } else {
               responseCurrencyMap.put(responseData.Name, new List<AssessmentQuestionResponse>{responseData});
            }
        }
        return responseCurrencyMap;
    }
}