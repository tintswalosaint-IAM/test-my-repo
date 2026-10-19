/**
* @description  : INS_Get_Quick_Quote.cls to get the latest quote data fro Mobi
* @SFP-50909    : The class has been created to connect to Mobi to get the quote data by passing quoteId
* @author       : Irshad Alam (irshad.alam@standardbank.co.za)
* @date         : October 2025
* @last Modified: SFP-54233: Removed debug logs.
*
* @lastModified : Jaco de Lange
* @date         : 2026-03-21
* @userStory    : SFP-57183 - Add the beneficiary list response to insurance policy participant list
*/

public with sharing class INS_Get_Quick_Quote {
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Get_Quick_Quote');

	/**
     * @description       : Invocable method to get a quick quote for the provided applicants.
     * @author            : Irshad Alam
     * @param requests    : List of List<RequestWrapper> objects containing applicant details and Product Id.
     * @return            : List of INS_Quick_Quote_Wrapper.Response objects containing API response.
     **/
    @InvocableMethod(Label = 'Get Quick Quote' Description = 'Get quote for the applicant')
    public static List<INS_Quick_Quote_Wrapper.Response> GetQuote(List<RequestWrapper> requests){
        List<INS_Quick_Quote_Wrapper.Response> responses = new List<INS_Quick_Quote_Wrapper.Response> ();

        // Build the payload for the API request
        String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
        String quoteId = requests[0].quoteId;
        // Create HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes/'+quoteId);
        request.setMethod(INS_Quote_Helper.HTTP_METHOD_GET);
        request.setTimeout(120000);
        request.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_AUTHORIZATION, INS_Quote_Helper.AUTHORIZATION_TYPE_BEARER + accessToken);
        request.setHeader(INS_Quote_Helper.HEADER_CLIENT_COUNTRY, INS_Quote_Helper.CLIENT_COUNTRY_SA);
        Http http = new Http();
        try{
            // Send HTTP request
            HttpResponse response = http.send(request);
            // Handle response based on status code
            if (response.getStatusCode() == 200){
                // Handle successful response                
                responses = handleSuccessfulResponse(response, accessToken);                
            } else{
                LOGGER.error('INS_Create_Quick_Quote.GetQuote', 'Error:-'+response.getBody());
                throw new INS_CustomException('Error: ' + response.getBody());
            }
        } catch (Exception ex){
            LOGGER.error('INS_Create_Quick_Quote.GetQuote', ex);
            throw new INS_CustomException(ex.getMessage());
        }
        return responses;
    }

	 /**
     * @description       : Wrapper Class to pass in the RequestWrapper.
     * @author            : Shams Ul Arifeen
     **/
    public class RequestWrapper{
        @InvocableVariable(label = 'Quote Id')
        public String quoteId;
        
    }

    /**
     * @description       : Handles successful API response.
     * @param             : response
     * @param             : accessToken
     * @return            : List<INS_Quick_Quote_Wrapper.Response >
     **/
    private static List<INS_Quick_Quote_Wrapper.Response> handleSuccessfulResponse( HttpResponse response, String accessToken ){
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> quoteHeaderMap = (Map<String, Object>) responseMap.get('quoteHeader');
        Decimal totalPremium = (Decimal) quoteHeaderMap.get('totalPremium');
        String quoteId = (String) quoteHeaderMap.get('quoteId');
        String quoteNumber = (String) quoteHeaderMap.get(INS_Quote_Helper.quoteNumber);
        Decimal totalBenefitAmount = 0;
        String funeralBenefitId = '';
        List<Object> persons = (List<Object>) responseMap.get('persons');
        for (Object personObj: persons){
            Map<String, Object> personMap = (Map<String, Object>) personObj;
            List<Object> benefits = (List<Object>) personMap.get('benefits');
            for (Object benefitObj: benefits){
                Map<String, Object> benefitMap = (Map<String, Object>) benefitObj;
                totalBenefitAmount += (Decimal) benefitMap.get('benefitAmountValue');
                String benefitType = (String) benefitMap.get('benefitType');
                if (benefitType == 'MAINFUNERAL'){
                    funeralBenefitId = (String) benefitMap.get('benefitId');
                }
            }
        }
        
        String memberId = '';
        List<Object> responseMembers = (List<Object>) responseMap.get('members');
        if (responseMembers != null && !responseMembers.isEmpty()){
            Map<String, Object> personMap = (Map<String, Object>) responseMembers[0];
            memberId = (String) personMap.get('memberId');
        }

        List<InsurancePolicyParticipant> participantRecords = new List<InsurancePolicyParticipant>();
        
        List<Object> responseBeneficiaries = (List<Object>) responseMap.get('beneficiaries');
        List<INS_Quick_Quote_Wrapper.Beneficiary> beneficiaryList = new List<INS_Quick_Quote_Wrapper.Beneficiary>();
        if (responseBeneficiaries != null && !responseBeneficiaries.isEmpty()) {
            for (Object benObj : responseBeneficiaries) {
                Map<String, Object> beneficiaryMap = (Map<String, Object>) benObj;
                INS_Quick_Quote_Wrapper.Beneficiary benWrObj = new INS_Quick_Quote_Wrapper.Beneficiary();

                InsurancePolicyParticipant participant = new InsurancePolicyParticipant();

                if (beneficiaryMap.containsKey('beneficiaryId')) {
                    benWrObj.beneficiaryId = (String) beneficiaryMap.get('beneficiaryId');
                }
                if (beneficiaryMap.containsKey('firstName')) {
                    benWrObj.beneficiaryFirstName = (String) beneficiaryMap.get('firstName');
                    participant.FirstName__c = (String) beneficiaryMap.get('firstName');
                }
                if (beneficiaryMap.containsKey('surname')) {
                    benWrObj.beneficiarySurname = (String) beneficiaryMap.get('surname');
                    participant.LastName__c = (String) beneficiaryMap.get('surname');
                }
                if (beneficiaryMap.containsKey('gender')) {
                    benWrObj.gender = (String) beneficiaryMap.get('gender');
                    participant.Gender__c = (String) beneficiaryMap.get('gender');
                }
                if (beneficiaryMap.containsKey('relationship')) {
                    benWrObj.beneficiaryRelationship = (String) beneficiaryMap.get('relationship');
                    participant.RelationshipToInsured = (String) beneficiaryMap.get('relationship');
                }
                if (beneficiaryMap.containsKey('allocationAmount')) {
                    benWrObj.allocationAmount = (Integer) beneficiaryMap.get('allocationAmount');
                    participant.Allocation__c = Decimal.valueOf(String.valueOf(beneficiaryMap.get('allocationAmount')));
                }
               if (beneficiaryMap.containsKey('dateOfBirth')) {
                    String dateStr = (String) beneficiaryMap.get('dateOfBirth');
                
                    benWrObj.dateOfBirth = dateStr;

                    if (String.isNotBlank(dateStr)) {
                        participant.BirthDate__c = DateTime.valueOf(dateStr.replace('T', ' ')).date();
                    }
                }
                beneficiaryList.add(benWrObj);
                participantRecords.add(participant);
            }
        }

        INS_Quick_Quote_Wrapper.Response responseObj = new INS_Quick_Quote_Wrapper.Response();
        responseObj.totalPremium = totalPremium;
        responseObj.totalBenefitAmount = totalBenefitAmount;
        responseObj.quoteNumber = quoteNumber;
        responseObj.quoteId = quoteId;
        responseObj.memberId = memberId;
        responseObj.mainFuneralId = funeralBenefitId;
        responseObj.accessToken = accessToken;
        // Convert the strongly-typed list into an untyped structure first
        List<Object> untypedBeneficiaryList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(beneficiaryList));
        // Then serialize untyped list (this avoids double escaping)
        responseObj.beneficiariesJson = JSON.serialize(untypedBeneficiaryList);
        responseObj.participants = participantRecords;
        return new List<INS_Quick_Quote_Wrapper.Response>{
            responseObj
        };
    }	
}