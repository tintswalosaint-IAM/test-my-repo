/*************************************************************
* @description SFP-32986 Class used to send TIN Data
*
* @autor Ramya Gurram
*
* @date OCT 13 2024
***************************************************************
* Last Modified By  Ramya Gurram
* Last Modified Date 13/10/2024
* Last Modified Description: updated to latest Version
 ****************************************************************************************
 * @Last Modified By 		: Ramya Gurram
 * @Last Modified On 		: 19-06-2025
 * @Modification description :SFP-50469
*/
public without sharing class ICS_API_UpdateTINRequestData {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_UpdateTINRequestData');

    /**
* @description To prepare the TIN JSON
* @param accId accountId
* @return  this returns the JSON String
*/

    public string prepareTINJson(String accId) {
        String jsonResult = null;

        if (String.isNotBlank(accId)) {
            ICS_DTO_UpdateTinData tinData = new ICS_DTO_UpdateTinData();

            try {
                tinData.bpId = fetchBpId(accId);
                tinData.contactId = fetchContactId(accId);
                tinData.taxInfo = queryTaxData(accId);

                jsonResult = JSON.serialize(tinData);
            } catch (QueryException qe) {
                LOGGER.error('Database query error in prepareTINJson: ' + qe.getMessage());
            } catch (JSONException je) {
                LOGGER.error('JSON serialization error in prepareTINJson: ' + je.getMessage());
            }
        } else {
            LOGGER.error('Invalid account ID provided in prepareTINJson');
        }

        return jsonResult;
    }
    /**
* @description To fetch contact id
* @param accId accountId
* @return  this returns contact id
*/
    private String fetchContactId(Id accId) {
        String contactId = null;
        SEL_Account selectorAccount = new SEL_Account();
        Account accData = selectorAccount.selectById(accId);


            contactId = accData.PersonContactId;


        return contactId;
    }
    /**
* @description To fetch Bp id
* @param accId accountId
* @return  this returns contact id
*/
    private String fetchBpId(Id accId) {
        String bpId = null;
        SEL_Account selectorAccount = new SEL_Account();
        Account accData = selectorAccount.selectById(accId);
        bpId = accData.ExternalCIFId__c;
        return bpId;
    }

    /**
* @description To query tax data
* @param accId accountId
* @return  this returns  taxData
*/
    private List < ICS_DTO_UpdateTinData.TaxInfo > queryTaxData(String accId) {
        List < TaxDetails__c > mainTaxDetail = [SELECT Id, TIN_IN_Number__c, Country__c, TaxExemptReason__c, Reason_for_No_TIN__c,ExternalIdentifier__c, Account__c
                                                FROM TaxDetails__c
                                                WHERE Account__c =: accId
                                               ];

        String mainCountryResidence = fetchCountryOfResidence(accId);
        String isSelectedMainTaxResidence = fetchAssementOfMainTax(accId);
        List < ICS_DTO_UpdateTinData.TaxInfo > taxModifiedData = new List < ICS_DTO_UpdateTinData.TaxInfo > ();
        if (!mainTaxDetail.isEmpty()) {
            Map < String, TaxDetails__c > taxDetailMap = new Map < String, TaxDetails__c > ();
            for (TaxDetails__c taxData: mainTaxDetail) {
              
                taxDetailMap.put(taxData.Country__c, taxData);
            }

            for (String taxCountry: taxDetailMap.keySet()) {
                ICS_DTO_UpdateTinData.TaxInfo setData = new ICS_DTO_UpdateTinData.TaxInfo();
                String mainTaxResidencyValue;
                if(taxCountry == mainCountryResidence){
                    if(isSelectedMainTaxResidence == 'TRUE'){
                        mainTaxResidencyValue = 'Y';
                    } else {
                         mainTaxResidencyValue = '';
                    }
                } else {
                    mainTaxResidencyValue = '';
                }
                setData.mainTaxResidency = mainTaxResidencyValue;
                setData.country = taxDetailMap.get(taxCountry).Country__c;
                setData.tinNumber = String.isNotBlank(taxDetailMap.get(taxCountry).TIN_IN_Number__c) ?
                    taxDetailMap.get(taxCountry).TIN_IN_Number__c : '';
                if(String.isNotBlank(taxDetailMap.get(taxCountry).TaxExemptReason__c)){
                    if(taxDetailMap.get(taxCountry).TaxExemptReason__c.equals('Reason B')){
                          setData.taxExemptReason =taxDetailMap.get(taxCountry).Reason_for_No_TIN__c; 
                    }else{
                        setData.taxExemptReason = taxDetailMap.get(taxCountry).TaxExemptReason__c; 
                    }
                } else {
                    setData.taxExemptReason = '';
                }
                taxModifiedData.add(setData);
            }
        }
        return taxModifiedData;
    }
    private string fetchAssementOfMainTax(String accId){
        String questionText;
        List<AssessmentQuestionResponse> responses = [SELECT Id,Name, ResponseText, AssessmentId, AssessmentQuestionId,
                                                      AssessmentQuestion.Name
                                                      FROM AssessmentQuestionResponse
                                                      WHERE Name='Tax Certificates' and Assessment.accountId=:accId ];
        
        for (AssessmentQuestionResponse response : responses) {
            if(response.AssessmentQuestion.Name == 'Is your Country of Residence your main tax residency?'){
                questionText = response.ResponseText;
            }
        }
        if(questionText == null){
            questionText = 'FALSE';
        }
        return questionText;

    }
    /**
* @description To fetch country of residence
* @param accId accountId
* @return  this returns country of residence
*/
    private String fetchCountryOfResidence(Id accId) {
        String countryOfResidence = null;
        SEL_PartyProfile pProfile = new SEL_PartyProfile();
        PartyProfile partyProfileList = pProfile.selectByAccountAndRecordType(accId, ICS_Constants.SBO_RECNAME);
        if (partyProfileList != null) {
            countryOfResidence = partyProfileList.Country_of_Residence__c;
        }
        return countryOfResidence;
    }
}