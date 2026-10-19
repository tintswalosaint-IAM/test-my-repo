/***************************************************************************************
* @name of the Class : Used to Insert Tax Detail object which was filled in applicationform ICS_CTRL_DML_TaxDetails.cls
* @description class used for Tax declaration
* @Story:SFP-30236
* @author Ikyatha Naidu
* @date 11-06-2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_DML_TaxDetails {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_DML_TaxDetails');
    public static string AccountID;
    Public static string otherCountry;
    Public static partyprofile pData;
    private static final String TIN_FIELD = 'TIN';
    private static final String TIN_NUMBER_M_FIELD = 'TIN NumberM';
    private static final String TIN_REASON_FIELD = 'Please select reason for not having a TIN number';
    private static final String TIN_REASON_M_FIELD = 'Please select reason for not having a TIN numberM';
    private static final String MAIN_TAX_RESIDENCY_FIELD = 'Please select your main tax residency country';
    private static final String EXPLANATION_FIELD_S = 'Please explain the reason for not obtaining TIN or equivalent numberM';//Please select your main tax residency country
    private static final String EXPLANATION_FIELD = 'Please explain the reason for not obtaining TIN or equivalent numberG';//is you south
    private static final String EXPLANATION_FIELD_A = 'Please explain the reason for not obtaining TIN or equivalent number'; //accordian
	@TestVisible
	private ICS_CTRL_DML_TaxDetails() {
        //Private Constructor for instantiation
    }
    public static String insertTaxDetails(String jsonString, String parentId) {
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
         pData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
        AccountID = parentId;
        Map<String, Object> jsonDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String taxId = (String) jsonDataMap.get('Id');
        if(jsonDataMap.containskey('tax_detail__c')){
            taxId = (string)jsonDataMap.get('tax_detail__c');
        }
        if(pData.Country_of_Residence__c == 'US'){
            taxId = (string)jsonDataMap.get('usId');
        }
         processMainTaxDetail(jsonDataMap, parentId, taxId);
         processCountrySpecificTaxDetails(jsonDataMap, parentId);

        List<AssessmentQuestionResponse> responseData = processAssessmentQuestions(jsonDataMap, parentId);

        processUSTaxDetail(jsonDataMap, parentId);
        try{
            if (!responseData.isEmpty()) {
                upsert responseData;
            }
         }catch(exception ex){
            LOGGER.error('Error in DML of Tax Detail');
        }


        return '';
    }

    public static TaxDetails__c processMainTaxDetail(Map<String, Object> jsonDataMap, String parentId, String taxId) {
        TaxDetails__c taxDetail = initializeTaxDetail(taxId);
        if (jsonDataMap == null || parentId == null) {
            return taxDetail;
        }

        populateTaxDetail(taxDetail, jsonDataMap, parentId);
        saveTaxDetail(taxDetail);

        return taxDetail;
    }

    private static TaxDetails__c initializeTaxDetail(String taxId) {
        if (String.isBlank(taxId)) {
            return new TaxDetails__c();
        }

        return [SELECT Id, TIN_IN_Number__c, TaxExemptReason__c, ExternalIdentifier__c,Reason_for_No_TIN__c, Account__c
                FROM TaxDetails__c
                WHERE Id = :taxId
                LIMIT 1];
    }

    private static void populateTaxDetail(TaxDetails__c taxDetail, Map<String, Object> jsonDataMap, String parentId) {
        setTinNumber(taxDetail, jsonDataMap);
        setExternalIdentifier(taxDetail, jsonDataMap, parentId);
        setTaxExemptReason(taxDetail, jsonDataMap);
        setCountry(taxDetail, jsonDataMap, parentId);
        setExplanation(taxDetail, jsonDataMap);
        taxDetail.Account__c = parentId;
        taxDetail.Name = 'Main Tax Details';
    }

    private static void setTinNumber(TaxDetails__c taxDetail, Map<String, Object> jsonDataMap) {
        if (jsonDataMap.containsKey(TIN_FIELD)) {
            taxDetail.TIN_IN_Number__c = (String)jsonDataMap.get(TIN_FIELD);
        } else if (jsonDataMap.containsKey(TIN_NUMBER_M_FIELD)) {
            taxDetail.TIN_IN_Number__c = (String)jsonDataMap.get(TIN_NUMBER_M_FIELD);
        }
        
    }
    
    private static void setExplanation(TaxDetails__c taxDetail, Map<String, Object> jsonDataMap) {
        String tinReasonExplanation = taxDetail.Reason_for_No_TIN__c;

        if (jsonDataMap.containsKey(EXPLANATION_FIELD) && jsonDataMap.get(EXPLANATION_FIELD) != null) {
            tinReasonExplanation = (String)jsonDataMap.get(EXPLANATION_FIELD);
        } else if (jsonDataMap.containsKey(EXPLANATION_FIELD_S)) {
            tinReasonExplanation = (String)jsonDataMap.get(EXPLANATION_FIELD_S);
        }

        taxDetail.Reason_for_No_TIN__c = tinReasonExplanation;
        
    }

    private static void setExternalIdentifier(TaxDetails__c taxDetail, Map<String, Object> jsonDataMap, String parentId) {
        if (jsonDataMap.containsKey(TIN_FIELD)) {
            String countryOfResidence = pData?.Country_of_Residence__c;
             SEL_Account accSelector = new SEL_Account();
         	Account accountInfo = accSelector.selectById(parentId);
             taxDetail.OwnerId = accountInfo.OwnerId;
            taxDetail.ExternalIdentifier__c = String.join(
                new List<String>{
                    countryOfResidence,
                    String.valueOf(System.now()),
                    parentId,
                    (String)jsonDataMap.get(TIN_FIELD)
                },
                ''
            );
        }
    }

    private static void setTaxExemptReason(TaxDetails__c taxDetail, Map<String, Object> jsonDataMap) {
        String tinReason = taxDetail.TaxExemptReason__c;

        if (jsonDataMap.containsKey(TIN_REASON_FIELD) && jsonDataMap.get(TIN_REASON_FIELD) != null) {
            tinReason = (String)jsonDataMap.get(TIN_REASON_FIELD);
        } else if (jsonDataMap.containsKey(TIN_REASON_M_FIELD)) {
            tinReason = (String)jsonDataMap.get(TIN_REASON_M_FIELD);
        }

        taxDetail.TaxExemptReason__c = tinReason;
    }

    private static void setCountry(TaxDetails__c taxDetail, Map<String, Object> jsonDataMap, String parentId) {
        if (jsonDataMap.containsKey(MAIN_TAX_RESIDENCY_FIELD)) {
            taxDetail.Country__c = (String)jsonDataMap.get(MAIN_TAX_RESIDENCY_FIELD);
        } else {
            String otherCountry = getOtherMainCountry(parentId);
            taxDetail.Country__c = String.isNotBlank(otherCountry) ?
                otherCountry :
                pData?.Country_of_Residence__c;
        }
    }

    private static void saveTaxDetail(TaxDetails__c taxDetail) {
        try {
            upsert taxDetail;
        } catch (Exception ex) {
            LOGGER.error('Error in DML of Tax Detail: ' + ex.getMessage());
        }
    }

    private static List<AssessmentQuestionResponse> processAssessmentQuestions(Map<String, Object> jsonDataMap, String parentId) {
        sel_assesment selectorAssInfo = new sel_assesment();
        List<Assessment> assDataList = selectorAssInfo.SelectByAccountId(parentId);
        Map<String, String> questionMap = getAssessmentQuestionMap();

        List<AssessmentQuestionResponse> responseData = new List<AssessmentQuestionResponse>();
        for (String key : questionMap.keySet()) {
            processAssessmentQuestion(jsonDataMap, key, questionMap.get(key), assDataList[0].Id, responseData);
        }
        return responseData;
    }

    private static Map<String, String> getAssessmentQuestionMap() {
        Set<String> assQuestions = new Set<String>();
        Map<String, String> questionMap = new Map<String, String>();
              List<Opportunity> opportunityList =new SEL_Opportunity().selectByAccountId(AccountID);
                Boolean isIFa = false;

                if (!opportunityList.isEmpty()) {
                    Opportunity opportunityData = opportunityList[0]; // Get the first record if it exists
                    if (opportunityData.LeadSource == 'IFA') {
                        isIFa = true;
                    }
                }
        String screenName =  isIFa ? 'ICS UK IFA Account Details' : 'ICS UK Account Details';
        for (AOB_Field__c fieldMapping : [SELECT AOB_SFObject__c, Name, AOB_SFField__c, AOB_Label__c
                                          FROM AOB_Field__c
                                          WHERE AOB_SFObject__c = 'Assessment'
                                          AND AOB_Section__r.Name =: ICS_Constants.TaxCertificates
                                          AND AOB_Section__r.AOB_Screen__r.Name =: screenName]) {
            assQuestions.add(fieldMapping.AOB_Label__c);
        }
        List<AssessmentQuestion> assementQuestionList = new SEL_AssessmentQuestion().selectByNames(assQuestions);
        for (AssessmentQuestion assQuestion : assementQuestionList) {
            questionMap.put(assQuestion.QuestionText, assQuestion.ActiveVersionId);
        }

        return questionMap;
    }

    private static void processAssessmentQuestion(Map<String, Object> jsonDataMap, String key, String questionId,
                                                  Id assessmentId, List<AssessmentQuestionResponse> responseData) {
        if (jsonDataMap.containsKey(key + ':Id')) {
            AssessmentQuestionResponse assResponse = new AssessmentQuestionResponse(
                Id = (String) jsonDataMap.get(key + ':Id'),
                ResponseText = (String) jsonDataMap.get(key)
            );
            if (assResponse.ResponseText != null) {
                responseData.add(assResponse);
            }
        } else if (jsonDataMap.containsKey(key)) {
            responseData.add(new AssessmentQuestionResponse(
                ResponseText = (String) jsonDataMap.get(key),
                AssessmentId = assessmentId,
                AssessmentQuestionId = questionId,
                Name = ICS_Constants.taxCertificate
            ));
        }
    }

    private static void processCountrySpecificTaxDetails(Map<String, Object> jsonDataMap, String parentId) {
        List<String> countries = getCountries(jsonDataMap, parentId);
        List<TaxDetails__c> taxDetailsInfo = new List<TaxDetails__c>();

        for (String country : countries) {
            if (jsonDataMap.containsKey(country)) {
                List<Object> countryDetails = (List<Object>) jsonDataMap.get(country);
                for (Object countryDetailObj : countryDetails) {
                     if (Schema.sObjectType.TaxDetails__c.isAccessible()) {
                    TaxDetails__c countryTaxDetail = createCountryTaxDetail((Map<String, Object>) countryDetailObj, country, parentId);
                    taxDetailsInfo.add(countryTaxDetail);
                     }else{
                        LOGGER.error('Insufficient permissions to access TaxDetails__c');
                     }
                }
            }
        }
        if (taxDetailsInfo.isEmpty()) {
            taxDetailsInfo = new List<TaxDetails__c>();

        }else{
            try{
             upsert taxDetailsInfo;
             }catch(exception ex){
                LOGGER.error('Error in DML of Tax Detail :'+ex.getmessage());
            }

        }
    }
	 private static string getOtherMainCountry(string parentID) {
        List<AssessmentQuestionResponse> responseInfo = [SELECT Id, ResponseText
                                                         FROM AssessmentQuestionResponse
                                                         WHERE Assessment.AccountId = :parentId
                                                         AND AssessmentQuestion.QuestionText = 'Please select your main tax residency country'];


       if (responseInfo.size()>0) {
            return responseInfo[0].ResponseText;
        }
        return '';
    }
    private static List<String> getCountries(Map<String, Object> jsonDataMap, String parentId) {
        List<AssessmentQuestionResponse> responseInfo = [SELECT Id, ResponseText
                                                         FROM AssessmentQuestionResponse
                                                         WHERE Assessment.AccountId = :parentId
                                                         AND AssessmentQuestion.QuestionText = 'Please select one or more countries'];
		 if (jsonDataMap.containsKey('Please select one or more countries')) {
            return ((String) jsonDataMap.get('Please select one or more countries')).split(';');
        }
        else if (responseInfo.size()>0) {
            return responseInfo[0].ResponseText.split(';');
        }
        return new List<String>();
    }

    private static TaxDetails__c createCountryTaxDetail(Map<String, Object> countryDetailMap, String country, String parentId) {
        if (Schema.sObjectType.TaxDetails__c.isAccessible()) {
        TaxDetails__c countryTaxDetail = new TaxDetails__c(
            Account__c = parentId,
            Country__c = country
        );

        if (countryDetailMap.containsKey('Id')) {
            countryTaxDetail.Id = (String) countryDetailMap.get('Id');
        }
        countryTaxDetail.Name = 'Country Tax Details';
        String taxIdNumber =  ICS_Constants.TAX_ID_NUMBER;
        if (countryDetailMap.get(taxIdNumber) == 'TRUE') {
            countryTaxDetail.ExternalIdentifier__c = country + System.now() + parentId + (String) countryDetailMap.get('TIN NumberS');
              if(countryDetailMap.containskey('TIN NumberS')){
            countryTaxDetail.TIN_IN_Number__c = (String) countryDetailMap.get('TIN NumberS');
              }
            countryTaxDetail.TaxExemptReason__c = '';
        } else if (countryDetailMap.containsKey('Please select a reason for not having a TIN NumberS')) {
            countryTaxDetail.TaxExemptReason__c = (String) countryDetailMap.get('Please select a reason for not having a TIN NumberS');
            countryTaxDetail.ExternalIdentifier__c = country + System.now() + parentId;
            countryTaxDetail.TIN_IN_Number__c = '';
            if (countryDetailMap.containsKey('Please explain the reason for not obtaining TIN or equivalent number')) {
                countryTaxDetail.Reason_for_No_TIN__c = (String) countryDetailMap.get('Please explain the reason for not obtaining TIN or equivalent number');
            }
        } 
             return countryTaxDetail;
        }else{
            LOGGER.error('Insufficient permissions to access TaxDetails__c');
            return null;
        }

    }

    private static void processUSTaxDetail(Map<String, Object> jsonDataMap, String parentId) {
        string usId ='';
        if(jsonDataMap.containskey('usId')){
            usId =(string) jsonDataMap.get('usId');
        }
        if (jsonDataMap.containsKey('US specific Tax Identification Number (TIN)')) {
            TaxDetails__c usTaxDetail = new TaxDetails__c(
                Account__c = parentId,
                ExternalIdentifier__c = System.now() + 'US' + parentId + (String) jsonDataMap.get('US specific Tax Identification Number (TIN)'),
                TIN_IN_Number__c = (String) jsonDataMap.get('US specific Tax Identification Number (TIN)'),
                Country__c = 'US'
            );
            if(usId != ''){
                usTaxDetail.id= usId;
            }
            usTaxDetail.Name = 'US Tax Detail';
            try{
            upsert usTaxDetail;
            }catch(exception e){
                LOGGER.error('Error in processUSTaxDetail'+e.getmessage());
            }
        }
    }
}