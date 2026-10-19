/***************************************************************************************

@name of the Class : ICS_CTRL_TrustDataProcessor.cls
@description : class used as controller for  SBO-UK onBoardingApplication Feature
@author : Ikyatha Naidu
@created Date : May 2023
/***************************************************************************************
@last Modified By : Ramya Gurram
@last Modified On : 08-07-2025
@modification description: SFP-30128
***************************************************************************************/
public without sharing class ICS_CTRL_TrustDataProcessor {
    private static final Map<String, String> MARITAL_STATUS_MAP = initializeMaritalStatusMap();
    public static string AccountID;

    private ICS_CTRL_TrustDataProcessor() {
        // Private Constructor for instantiation
    }

    private static Map<String, String> initializeMaritalStatusMap() {
        Map<String, String> maritalMap = new Map<String, String>{
            '1' => 'SINGLE', '2' => 'MARRIED', '3' => 'SEPARATED',
            '4' => 'DIVORCED', '5' => 'WIDOWED', '6' => 'UNCLASSIFIED'
        };
        for (String key : maritalMap.keySet()) {
            maritalMap.put(maritalMap.get(key), key);
        }
        return maritalMap;
    }

    public static Map<String, String> getMaritalStatusMap() {
        return MARITAL_STATUS_MAP;
    }

    public static void addNewBenefit(String jsonString, String parentId) {
        Map<String, Object> benefitData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        Party_Assets_Funds__c benefitRecord = new Party_Assets_Funds__c();
        populateBenefitRecord(benefitRecord, benefitData);
        benefitRecord.Name = 'Benefit Trust';
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        benefitRecord.OwnerId = profileData.OwnerId;            
        upsert benefitRecord;
        sel_assesment selectorAssInfo = new sel_assesment();
        List<Assessment> assDataList = selectorAssInfo.SelectByAccountId(parentId);

        ICS_CTRL_DMLAdditionalBankAccounts.processPartyAssetFunds(
            new List<SObject>{benefitRecord},
            new List<Map<String, Object>>{benefitData},
            assDataList,
            'Trusts',
            'Annual Monetary ValueCurrency'
        );
    }

    private static void populateBenefitRecord(Party_Assets_Funds__c benefitRecord, Map<String, Object> benefitData) {
        benefitRecord.Type__c = 'Benefit from a trust';
        if(benefitData.containskey('Id')) {
            benefitRecord.id = (string)benefitData.get('Id');
        }else{

            benefitRecord.Trust__c = (String) benefitData.get('accordianId');
        }
        
        benefitRecord.CurrencyIsoCode = 'GBP';
        populateSObjectFields(benefitRecord, benefitData, 'ADD Benefit');
        if (benefitData.containsKey('Annual Monetary ValueCurrency')) {
            List<CurrencyType> currencyTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType LIMIT 1000];
            Map<String, Decimal> conversionMap = new Map<String, Decimal>();
            for (CurrencyType ct : currencyTypes) {
                conversionMap.put(ct.IsoCode, ct.ConversionRate);
            }
           benefitRecord.Annual_Monetary_Value__c = ICS_CTRL_DML_OnboardingDetails.mapCurrency(
               'Annual Monetary Value',
               Decimal.valueOf(String.valueOf(benefitData.get('Annual Monetary Value'))),
               (String) benefitData.get('Annual Monetary ValueCurrency'),
               conversionMap
            );
        }
    }

    public static void addNewPerson(String jsonString, String accId) {
        Map<String, Object> personData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        PartyProfile personProfile = new PartyProfile();
        populatePersonProfile(personProfile, personData, accId);
        upsert personProfile;
    }

    private static void populatePersonProfile(PartyProfile profile, Map<String, Object> personData, String accId) {
        profile.Name = 'PEP';
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile mainProfile = selectorPartyProfile.selectByAccountAndRecordType(accId, ICS_Constants.SBO_RECNAME);
        profile.RelatedPartyProfileId = mainProfile.Id;
		profile.OwnerId = mainProfile.OwnerId;
        if(personData.containskey('Id')) {
            profile.id = (string)personData.get('Id');
        }else{
            profile.Party_Assets_Funds__c = (String) personData.get('accordianId');
        }
        populateSObjectFields(profile, personData, 'Add Another Person');
        setFormerOrMaidenName(profile, personData);
        setMaritalStatus(profile, personData);
        setOtherName(profile, personData);

    }

    private static void setFormerOrMaidenName(PartyProfile profile, Map<String, Object> personData) {
        String formerOrMaidenName = (String) personData.get('Former name or maiden name');
        if (formerOrMaidenName != null) {
            profile.Has_Former_Name__c = (formerOrMaidenName == 'FormerName' || formerOrMaidenName == 'FormerAndMaiden') ? 'Yes' : 'No';
            profile.Has_Maiden_Name__c = (formerOrMaidenName == 'MaidenName' || formerOrMaidenName == 'FormerAndMaiden') ? 'Yes' : 'No';
        }
    }

    private static void setOtherName(PartyProfile profile, Map<String, Object> personData) {
        String otherName = (String) personData.get('Other name');
        profile.Has_different_First_Middle_Family_Name__c = (otherName == null || otherName == 'None') ? 'No' : 'Yes';
    }

    private static void setMaritalStatus(PartyProfile profile, Map<String, Object> personData) {
        String maritalStatus = (String) personData.get('Marital status');
        if (maritalStatus != null) {
            profile.WI_MaritialStatus__c = MARITAL_STATUS_MAP.get(maritalStatus);
        }
    }

    public static void processTrustData(String jsonString, String parentId) {
        AccountID = parentId;
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        if (isBenefitData(data)) {
            addNewBenefit(jsonString, parentId);
        } else if (isPersonData(data)) {
            addNewPerson(jsonString, parentId);
        } else {
            processFullTrustData(data, parentId);
        }
    }

    private static boolean isBenefitData(Map<String, Object> data) {
        return (data.containsKey('label') && ((String)data.get('label')).contains('Benefit'))
            || (data.containsKey('Id') && (String)data.get('objectName') == 'Party_Assets_Funds__c');
    }

    private static boolean isPersonData(Map<String, Object> data) {
        return (data.containsKey('label') && ((String)data.get('label')).contains('Person'))
            || (data.containsKey('Id') && (String)data.get('objectName') == 'PartyProfile');
    }

    private static void processFullTrustData(Map<String, Object> data, String parentId) {
        SEL_PartyProfile selPartyProfile = new SEL_PartyProfile();
        PartyProfile profileII = selPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        SEL_PartyAssetFunds partyAssetsFunds = new SEL_PartyAssetFunds();
        List<Party_Assets_Funds__c> partyAssetsFundsList = partyAssetsFunds.selectByPartyProfileTypeList(profileII.Id,new List<string>{'Trust'});
        if(partyAssetsFundsList.size()> 0 && data.get('Are you related to a Trust structure?') == 'FALSE'){
               delete partyAssetsFundsList;
        }
        List<AssessmentQuestionResponse> responsesToUpsert = processAssessmentQuestions(data, parentId);
        List<Party_Assets_Funds__c> trustsToUpsert = new List<Party_Assets_Funds__c>();
        List<PartyProfile> profilesToUpsert = new List<PartyProfile>();
        List<Party_Assets_Funds__c> benefitsToUpsert = new List<Party_Assets_Funds__c>();
        Map<Integer, Party_Assets_Funds__c> accordianIndexToTrustMap = new Map<Integer, Party_Assets_Funds__c>();
        Map<Id, Integer> profileToAccordianIndexMap = new Map<Id, Integer>();
        Map<Id, Integer> benefitToAccordianIndexMap = new Map<Id, Integer>();
        List<Object> trusts = (List<Object>) data.get('accordian');
        if (trusts != null) {
            for (Integer i = 0; i < trusts.size(); i++) {
                processSingleTrust((Map<String, Object>) trusts[i], parentId, trustsToUpsert, profilesToUpsert, benefitsToUpsert, i, accordianIndexToTrustMap, profileToAccordianIndexMap, benefitToAccordianIndexMap);
            }
        }


        // Perform DML operations outside of loops

         if (!responsesToUpsert.isEmpty()) {
            upsert responsesToUpsert;
        }
        if (!trustsToUpsert.isEmpty()) {
            upsert trustsToUpsert;
        }


        // Update profiles and benefits with correct Trust__c after trusts are upserted
        for (PartyProfile profile : profilesToUpsert) {
            Integer accordianIndex = profileToAccordianIndexMap.get(profile.Id);
            profile.Party_Assets_Funds__c = accordianIndexToTrustMap.get(accordianIndex).Id;
        }

        for (Party_Assets_Funds__c benefit : benefitsToUpsert) {
            Integer accordianIndex = benefitToAccordianIndexMap.get(benefit.Id);
            benefit.Trust__c = accordianIndexToTrustMap.get(accordianIndex).Id;
        }

        if (!profilesToUpsert.isEmpty()) {
            upsert profilesToUpsert;
        }
        if (!benefitsToUpsert.isEmpty()) {
            upsert benefitsToUpsert;
        }
    }

    private static List<AssessmentQuestionResponse> processAssessmentQuestions(Map<String, Object> data, String parentId) {
        List<AssessmentQuestionResponse> responseData = new List<AssessmentQuestionResponse>();
        Map<String, String> questionMap = getQuestionMap(parentId);

        sel_assesment selectorAssInfo = new sel_assesment();
        List<Assessment> assDataList = selectorAssInfo.SelectByAccountId(parentId);

        for (String key : questionMap.keySet()) {
            if (data.containsKey(key)) {
                AssessmentQuestionResponse response = createResponse(data, key, questionMap.get(key), assDataList[0].Id);
                responseData.add(response);
            }
        }
        return responseData;
    }

    private static Map<String, String> getQuestionMap(string parentId) {
      
          List<Opportunity> opportunityList = [SELECT Id, LeadSource FROM Opportunity WHERE AccountId = :parentId];
            Boolean isIFa = false;

            if (!opportunityList.isEmpty()) {
                Opportunity opportunityData = opportunityList[0]; // Get the first record if it exists
                if (opportunityData.LeadSource == 'IFA') {
                    isIFa = true;
                }
            }
        String compareTrustText= isIFa ? 'Is the applicant associated to a Trust Structure? If yes, how many?' : 'Are you related to a Trust structure?';
        Map<String, String> questionMap = new Map<String, String>();
        for (AssessmentQuestion assQuestion : [SELECT Id, Name, ActiveVersionId, QuestionText
                                               FROM AssessmentQuestion
                                               WHERE Name =: compareTrustText]) {
            questionMap.put(assQuestion.QuestionText, assQuestion.ActiveVersionId);
        }
        return questionMap;
    }
	@testvisible
    private static AssessmentQuestionResponse createResponse(Map<String, Object> data, String key, String questionId, Id assessmentId) {
        AssessmentQuestionResponse response = new AssessmentQuestionResponse();
        
        response.ResponseText = (String) data.get(key);
        if( data.containskey(key + ':Id')){
            response.Id = (String) data.get(key + ':Id');
            
        }else{
            response.AssessmentId = assessmentId;
        }
        response.AssessmentQuestionId = questionId;
        response.Name = 'Trusts';
        return response;
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
    private static void processSingleTrust(Map<String, Object> trustMap, String parentId,
                                           List<Party_Assets_Funds__c> trustsToUpsert,
                                           List<PartyProfile> profilesToUpsert,
                                           List<Party_Assets_Funds__c> benefitsToUpsert,
                                           Integer accordianIndex,
                                           Map<Integer, Party_Assets_Funds__c> accordianIndexToTrustMap,
                                           Map<Id, Integer> profileToAccordianIndexMap,
                                           Map<Id, Integer> benefitToAccordianIndexMap) {
        Party_Assets_Funds__c trustRecord = new Party_Assets_Funds__c();
        populateTrustRecord(trustRecord, trustMap, parentId);
        trustsToUpsert.add(trustRecord);
        accordianIndexToTrustMap.put(accordianIndex, trustRecord);

        processRelatedPeople(trustMap, accordianIndex, parentId, profilesToUpsert, profileToAccordianIndexMap);
        processRelatedBenefits(trustMap, accordianIndex, benefitsToUpsert, benefitToAccordianIndexMap,parentId);
    }

    private static void populateTrustRecord(Party_Assets_Funds__c trustRecord, Map<String, Object> trustMap, String parentId) {
        trustRecord.Type__c = 'Trust';
        if(trustMap.containskey('Id')) {
            trustRecord.id = (Id)trustMap.get('Id');
        }
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        trustRecord.Party_Profile__c = profileData.Id;
        trustRecord.OwnerId = profileData.OwnerId; 
        trustRecord.Name = 'Trust';
        populateSObjectFields(trustRecord, trustMap, 'accordian');
    }

    private static void processRelatedPeople(Map<String, Object> trustMap, Integer accordianIndex,
        String parentId, List<PartyProfile> profilesToUpsert,
        Map<Id, Integer> profileToAccordianIndexMap) {
        List<Object> people = (List<Object>) trustMap.get('Add Another Person');
        if (people != null) {
            if(trustMap.get('Are you related to Politically Exposed Person through a Trust relationship?')== 'TRUE'){
                for (Object personObj : people) {
                    processRelatedPerson((Map<String, Object>) personObj, accordianIndex, parentId, profilesToUpsert, profileToAccordianIndexMap);
                }
            }else {
             SEL_PartyProfile selPartyProfile = new SEL_PartyProfile();
        PartyProfile profileII = selPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        Object idValue = trustMap.get('Id');
        Id profilePartyAssetsFundsId = idValue != null ? Id.valueOf(String.valueOf(idValue)) : null;
        List<PartyProfile> deleteRecords = getProfileRecords(profileII.id,profilePartyAssetsFundsId);
                delete deleteRecords;
           
                
            }
        }
    }


    private static void processRelatedPerson(Map<String, Object> personMap, Integer accordianIndex,
                                             String parentId, List<PartyProfile> profilesToUpsert,
                                             Map<Id, Integer> profileToAccordianIndexMap) {
        PartyProfile personProfile = new PartyProfile();
        if(personMap.containskey('Id')) {
            personProfile.id = (Id)personMap.get('Id');
        }
        populatePersonProfile(personProfile, personMap, parentId);

        profilesToUpsert.add(personProfile);
        profileToAccordianIndexMap.put(personProfile.Id, accordianIndex);
    }

    private static void processRelatedBenefits(Map<String, Object> trustMap, Integer accordianIndex,
                                               List<Party_Assets_Funds__c> benefitsToUpsert,
                                               Map<Id, Integer> benefitToAccordianIndexMap,string parentId) {
        List<Object> benefits = (List<Object>) trustMap.get('ADD Benefit');
        if (benefits != null) {
             if(trustMap.get('Do you receive any disbursement or benefit from a Trust?')== 'TRUE'){
                 for (Object benefitObj : benefits) {
                    processRelatedBenefit((Map<String, Object>) benefitObj, accordianIndex, benefitsToUpsert, benefitToAccordianIndexMap,parentId);
                }
            }else {
                 SEL_PartyProfile selPartyProfile = new SEL_PartyProfile();
        PartyProfile profileII = selPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        Object idValue = trustMap.get('Id');
        Id profilePartyAssetsFundsId = idValue != null ? Id.valueOf(String.valueOf(idValue)) : null;
        List<Party_Assets_Funds__c> deleteRecords = getBenefitRecords(profilePartyAssetsFundsId);
                delete deleteRecords;
            }
             
           
        }
    }
    
    private static List<Party_Assets_Funds__c> getBenefitRecords(Id trustRecordId) {
        return [SELECT Id, Name, type__c, Deed_Number__c,Is_Trust_Beneficiary__c, Related_To_PEP_Through_Trust__c, Beneficiary_Of_Trust__c, Annual_Monetary_Value__c, Type_of_Benefit__c, Rationale_for_Trust__c,
                Trust_Name__c, Frequency_of_Trust_Benefit__c, TrustDeed_or_Letter_of_wishes__c, Description__c, Locations__c,
                Settlor_Name__c, Wealth_Source_and_Timeline__c, Wealth_Details_Inclusive_of_Amount__c, Date_Funds_Received__c
                FROM Party_Assets_Funds__c
                WHERE Trust__c = :trustRecordId AND Type__c = 'Benefit from a trust'  order by createddate asc];
    }

    private static void processRelatedBenefit(Map<String, Object> benefitMap, Integer accordianIndex,
                                              List<Party_Assets_Funds__c> benefitsToUpsert,
                                              Map<Id, Integer> benefitToAccordianIndexMap,string parentId) {
        Party_Assets_Funds__c benefitRecord = new Party_Assets_Funds__c();
        if(benefitMap.containskey('Id')) {
            benefitRecord.id = (Id)benefitMap.get('Id');
        }
          benefitRecord.Name = 'Benefit Trust';
          SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
          PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
          benefitRecord.OwnerId = profileData.OwnerId;                                         
        populateBenefitRecord(benefitRecord, benefitMap);
        benefitsToUpsert.add(benefitRecord);
        benefitToAccordianIndexMap.put(benefitRecord.Id, accordianIndex);
    }

    public static void populateSObjectFields(SObject sObj, Map<String, Object> sectionField, String parentName) {
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames(parentName);
        String sObjectName = sObj.getSObjectType().getDescribe().getName();
        if (!objectWithFieldAPINames.containsKey(sObjectName)){
            return;
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
        Set<Id> fieldIds = new Set<Id>();
        for (AOB_Field__c fieldData : objectWithFieldAPINames.get(sObjectName)) {
            fieldIds.add(fieldData.Id);
        }
        List<AOB_Field__c> childFields = new SEL_AOBField().selectFieldsByParentIds(fieldIds);
         if (!childFields.isEmpty()) {
            if (objectWithFieldAPINames.containsKey(sObjectName)) {
                objectWithFieldAPINames.get(sObjectName).addAll(childFields);
            } else {
                objectWithFieldAPINames.put(sObjectName, childFields);
            }
        }
        for (AOB_Field__c fieldData : objectWithFieldAPINames.get(sObjectName)) {
            populateField(sObj, sectionField, fieldData, fieldMap);
        }
    }

    private static Map<String, List<AOB_Field__c>> getObjectWithFieldAPINames(String parentName) {
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = new Map<String, List<AOB_Field__c>>();
       
          List<Opportunity> opportunityList = [SELECT Id, LeadSource FROM Opportunity WHERE AccountId = :AccountID];
            Boolean isIFa = false;

            if (!opportunityList.isEmpty()) {
                Opportunity opportunityData = opportunityList[0]; // Get the first record if it exists
                if (opportunityData.LeadSource == 'IFA') {
                    isIFa = true;
                }
            }
        string isRelatesTrustScreen = isIFa ? 'ICS UK IFA Financial Details':'ICS UK Financial Details';
        for (AOB_Field__c fieldMapping : [SELECT AOB_SFObject__c, Name, AOB_SFField__c
                                          FROM AOB_Field__c
                                          WHERE AOB_Parent__r.Name = :parentName
                                          AND AOB_Section__r.Name = 'Trusts'
                                          AND AOB_Section__r.AOB_Screen__r.Name =: isRelatesTrustScreen]) {
                                            if (!objectWithFieldAPINames.containsKey(fieldMapping.AOB_SFObject__c)) {
                                                objectWithFieldAPINames.put(fieldMapping.AOB_SFObject__c, new List<AOB_Field__c>());
                                            }
                                            objectWithFieldAPINames.get(fieldMapping.AOB_SFObject__c).add(fieldMapping);
                                        }
                                        return objectWithFieldAPINames;
                                    }

                                    private static void populateField(SObject sObj, Map<String, Object> sectionField, AOB_Field__c fieldData, Map<String, Schema.SObjectField> fieldMap) {
                                        String sourceFieldName = fieldData.Name;
                                        String targetFieldAPIName = fieldData.AOB_SFField__c;
                                        if (fieldMap.containsKey(targetFieldAPIName) && sectionField.containsKey(sourceFieldName)) {
                                            Schema.DisplayType fieldType = fieldMap.get(targetFieldAPIName).getDescribe().getType();
                                            Object value = sectionField.get(sourceFieldName);
                                            if (value != null) {
                                                setFieldValue(sObj, targetFieldAPIName, fieldType, value);
                                            }
                                        }
                                    }

                                    private static void setFieldValue(SObject sObj, String fieldName, Schema.DisplayType fieldType, Object value) {
                                        switch on fieldType {
                                            when STRING, PICKLIST, ID,TEXTAREA {
                                                sObj.put(fieldName, (String) value);
                                            }
                                            when BOOLEAN {
                                                sObj.put(fieldName, Boolean.valueOf((String) value));
                                            }
                                            when INTEGER {
                                                sObj.put(fieldName, Integer.valueOf((String) value));
                                            }
                                            when DOUBLE, CURRENCY {
                                                sObj.put(fieldName, Decimal.valueOf(String.valueOf(value)));
                                            }
                                            when DATE {
                                                sObj.put(fieldName, Date.valueOf((String) value));
                                            }
                                            when DATETIME {
                                                sObj.put(fieldName, DateTime.valueOf((String) value));
                                            }
                                        }
                                        
                                        if (fieldName == 'Locations__c') {
                                             Map<String, String> countryCodeMap = ICS_CTRL_PreAppFormCreator.countryCodeMap();
            								string countryName= countryCodeMap.get((string)value);
                                            sObj.put('Locations__c',countryName);
                                        }
                                       
                                    }
                                }