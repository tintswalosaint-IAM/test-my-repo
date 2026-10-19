/***************************************************************************************
@name of the Class : ICS_CTRL_Fetch_TaxDetails.cls
@description :class used as controller for  SBO-UK ApplicationForm Feature to fetch tax details
@author : Ikyatha Naidu
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: Updated to latest version
***************************************************************************************/
public without sharing class ICS_CTRL_Fetch_TaxDetails {
    public static string AccountID;
	private ICS_CTRL_Fetch_TaxDetails(){
        //Private Constructor for instantiation
    }
    public static String fetchTaxDetails(String parentId) {
        AccountID = parentId;
        Map<String, Object> result = new Map<String, Object>();
		string cor='';

        sel_partyprofile selectorProfile = new sel_partyProfile();
        partyprofile pData  = selectorProfile.selectByAccountAndRecordType(parentId,ICS_Constants.SBO_RECNAME);
        cor = pData.Country_of_Residence__c;

        List<AssessmentQuestionResponse> responses = new SEL_AssesmentQuestionResponse().selectByAccountIdAndName(parentId, 'Tax Certificates');
        for (AssessmentQuestionResponse response : responses) {

                result.put(response.AssessmentQuestion.Name, response.ResponseText);
                result.put(response.AssessmentQuestion.Name + ':Id', response.Id);
            if(response.AssessmentQuestion.Name =='Please select your main tax residency country'){
                cor = response.ResponseText;
            }
        }
        List<TaxDetails__c> mainTaxDetail = [SELECT Id, TIN_IN_Number__c,Country__c,Reason_for_No_TIN__c,TaxExemptReason__c, ExternalIdentifier__c, Account__c
                                               FROM TaxDetails__c
                                               WHERE Account__c = :parentId and (country__c=: cor or country__c = 'US')
                                       		];
		if (mainTaxDetail.size()>0) {
            for(TaxDetails__c taxInfo : mainTaxDetail){
                if(taxInfo.country__c == 'US' && cor != 'US'){

                    result.put('US specific Tax Identification Number (TIN)',taxInfo.TIN_IN_Number__c);
                    result.put('usId', taxInfo.Id);
                    result.put('objectName', 'tax_detail__c');
                }else{
                    result.put('TIN', taxInfo.TIN_IN_Number__c);
                     result.put('TIN NumberM', taxInfo.TIN_IN_Number__c);
                    result.put('Id', taxInfo.Id);
                    result.put('objectName', 'tax_detail__c');
                     result.put('Please select your main tax residency country', cor);
                    result.put('Please select reason for not having a TIN number', taxInfo.TaxExemptReason__c);
                    result.put('Please select reason for not having a TIN numberM', taxInfo.TaxExemptReason__c);
                    result.put('Please explain the reason for not obtaining TIN or equivalent numberG', taxInfo.Reason_for_No_TIN__c);
                    result.put('Please explain the reason for not obtaining TIN or equivalent numberM', taxInfo.Reason_for_No_TIN__c);
                }

            }

        }

        // Fetch country-specific TaxDetails__c records
        if(result.containskey('Please select one or more countries')){
            List<string> countryList = ((string)result.get('Please select one or more countries')).split(';');
            Map<String, List<Map<String, Object>>> countryDetailsMap = fetchCountryTaxDetails(parentId,countryList);
            result.putAll(countryDetailsMap);
        }
         List<String> jsonListString = new List<String>();
         if (result.keySet().size() != 0) {
              jsonListString.add(JSON.serialize(result));
         }
         String jsonString = '';
          jsonString = '[' + String.join(jsonListString, ',') + ']';
        // Convert the result to JSON and return
        return jsonString;
    }



    // Fetch country-specific TaxDetails__c records and organize them into a map
    @TestVisible
    private static Map<String, List<Map<String, Object>>> fetchCountryTaxDetails(String parentId,List<string> countryList) {
        Map<String, List<Map<String, Object>>> countryDetailsMap = new Map<String, List<Map<String, Object>>>();
        List<TaxDetails__c> countryTaxDetails = [SELECT Id, TIN_IN_Number__c,Country__c,TaxExemptReason__c, Reason_for_No_TIN__c,ExternalIdentifier__c, Account__c
                                                 FROM TaxDetails__c
                                                 WHERE Account__c = :parentId and country__c in:countryList
                                               ];



        String screenName =  'Do you have a Tax Identification Number?S';
        for (TaxDetails__c countryDetail : countryTaxDetails) {
            Map<String, Object> countryMap = new Map<String, Object>();
            countryMap.put('TIN NumberS', countryDetail.TIN_IN_Number__c);
            countryMap.put('objectName', 'tax_detail__c');
             countryMap.put('Id', countryDetail.Id);
            if(countryDetail.TIN_IN_Number__c == null){
                 countryMap.put(screenName,'FALSE');
                 countryMap.put('Please select a reason for not having a TIN NumberS', countryDetail.TaxExemptReason__c);
                 countryMap.put('Please explain the reason for not obtaining TIN or equivalent number', countryDetail.Reason_for_No_TIN__c);
            }else{
               countryMap.put(screenName,'TRUE');
            }

            // Add any other relevant fields

            if (!countryDetailsMap.containsKey(countryDetail.Country__c)) {
                countryDetailsMap.put(countryDetail.Country__c, new List<Map<String, Object>>());
            }
            countryDetailsMap.get(countryDetail.Country__c).add(countryMap);
        }
        return countryDetailsMap;
    }


        /**
* @description To fetch the current application ID associated with the user for clow.
* @return The ID of the current application or an empty string if not found.
*/
    @InvocableMethod(label=
'Get ApplicationForm Stage'
)
    Public static List<String> getApplicationFormStageName() {
        List<String> stageName= new List<String>();
        map<string,string> userMap = new Map<string,string>();
        for(user userData : [SELECT id, contact.accountid from user where id =: userinfo.getuserid()]) {
            userMap.put(userData.id,userData.contact.accountid);
        }
        if(userMap.containskey(userinfo.getuserId())) {
             List<ApplicationForm> formDataList = new List<ApplicationForm>();
            formDataList =[select id,Section_Name__c,opportunityId,accountid from applicationform
                                                 where accountid=:userMap.get(userinfo.getuserId())
                                                 and opportunity.iswon =false and opportunity.isclosed=false];
            if(formDataList.size()>0) {
                if(formDataList[0].Section_Name__c == null){
                  stageName.add('ICS UK Personal Info');
                }else{

                    string sectionName =formDataList[0].Section_Name__c.split(';')[0];
                	stageName.add(sectionName);
                }
            }
        }
        return stageName;
    }
}