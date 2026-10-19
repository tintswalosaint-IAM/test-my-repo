/**
  * @description      : SFP-50219: Sends a POST request to the Quote API endpoint with the provided applicant details To get quick Quote Estimates.
  * @author           : Shams Ul Arifeen
  * @date             : October 2023, 
                      :  07/07/2025 - (Irshad)Added PR comments to add SFP-50219
  */
  public class INS_Create_Quick_Quote{

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_Create_Quick_Quote');

    /**
     * @description       : Invocable method to create a quick quote for the provided applicants.
     * @author            : Shams Ul Arifeen
     * @param requests : List of List<RequestWrapper> objects containing applicant details and Product Id.
     * @return            : List of INS_Quick_Quote_Wrapper.Response objects containing API response.
     **/
    @InvocableMethod(Label = 'Create Quick Quote' Description = 'Create quote for the applicant')
    public static List<INS_Quick_Quote_Wrapper.Response> createQuote(List<RequestWrapper> requests){
        List<INS_Quick_Quote_Wrapper.Response> responses = new List<INS_Quick_Quote_Wrapper.Response> ();

        // Build the payload for the API request
        INS_Quick_Quote_Wrapper.QuotePayload payload = buildQuotePayload(requests[0].mainMember, requests);
        String payloadJson = JSON.serialize(payload);
        String accessToken = INS_Quote_Helper.getAccessToken(INS_Quote_Helper.accessTokenTypeQuote);
        System.debug('payloadJson=='+JSON.serializePretty(payloadJson));
        // Create HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:INS_Quote_Named_Credentials'+'/life-quoting/quotes');
        request.setMethod(INS_Quote_Helper.HTTP_METHOD_POST);
        request.setTimeout(120000);
        request.setHeader(INS_Quote_Helper.HEADER_CONTENT_TYPE, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_ACCEPT, INS_Quote_Helper.CONTENT_TYPE_APPLICATION_JSON);
        request.setHeader(INS_Quote_Helper.HEADER_AUTHORIZATION, INS_Quote_Helper.AUTHORIZATION_TYPE_BEARER + accessToken);
        request.setHeader(INS_Quote_Helper.HEADER_CLIENT_COUNTRY, INS_Quote_Helper.CLIENT_COUNTRY_SA);
        request.setBody(payloadJson);
        Http http = new Http();
       
        
        try{
            // Send HTTP request
            HttpResponse response = http.send(request);
            System.debug('Response=='+JSON.serializePretty(response.getBody()));
            // Handle response based on status code
            if (response.getStatusCode() == 200){
                // Handle successful response
                responses = handleSuccessfulResponse(response, accessToken);
            } else{
                throw new INS_CustomException('Error: ' + response.getBody());
            }
        } catch (Exception ex){
            LOGGER.error('INS_Create_Quick_Quote.createQuote', ex);
            throw new INS_CustomException(ex.getMessage());
        }
        return responses;
    }

    /**
     * @description       : Builds the payload for the API request based on applicant details.
     * 
     * @param applicant
     * @return            : INS_Quick_Quote_Wrapper.QuotePayload
     **/
    private static INS_Quick_Quote_Wrapper.QuotePayload buildQuotePayload(InsurancePolicyParticipant applicant, List<RequestWrapper> requests){
        INS_Quick_Quote_Wrapper.QuotePayload payload = new INS_Quick_Quote_Wrapper.QuotePayload();
        payload.members = new List<INS_Quick_Quote_Wrapper.Member> ();

            INS_Quick_Quote_Wrapper.Member member = new INS_Quick_Quote_Wrapper.Member();
            Datetime dateOfBirth = applicant.BirthDate__c;
            member.firstName = applicant.FirstName__c;
            member.lastName = applicant.LastName__c;
            string MobilePhoneNumber = (applicant.MobilePhone__c != null) ? String.valueOf(applicant.MobilePhone__c) : '';
            
            // Remove '+' sign, any spaces, and starting zero from the mobile phone number
            String cleanedMobile = MobilePhoneNumber.replace('+', '').replace(' ', '');
            while (cleanedMobile.startsWith('0')) {
                cleanedMobile = cleanedMobile.substring(1);
            }
            member.contactNumber = cleanedMobile;
            member.email = String.isNotBlank(applicant.Email__c) ? applicant.Email__c : '';
            member.gender = applicant.Gender__c;
            member.memberType = (applicant.RelationshipToInsured != 'Main Member') ? 'MAININSURED' : applicant.RelationshipToInsured;
            member.dateOfBirth = dateOfBirth.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
            member.identityNumber = applicant.IdentityNumber__c;
       		if(applicant.IdType__c == 'NATIONAL ID')
            {
            member.identityDocumentType = 'SAIDENTITYDOCUMENT';
            }
        	else
            {
                member.identityDocumentType = 'PASSPORT';
            }
            
            member.idCountryOfIssue = requests[0].country;
            member.customerExternalId = requests[0].customerExternalId;
            INS_Quick_Quote_Wrapper.Beneficiaries beneficiaries = new INS_Quick_Quote_Wrapper.Beneficiaries();
            beneficiaries.allocationAmount = Integer.valueOf(requests[0].allocationAmount);
            beneficiaries.allocationType = 'PERCENTAGE';

            INS_Quick_Quote_Wrapper.Benefit benefit = new INS_Quick_Quote_Wrapper.Benefit();
            benefit.benefitType = 'MAINFUNERAL';
            benefit.benefitKey = '1.MAINFUNERAL';
            benefit.coverAmount = requests[0].coverAmount;
            benefit.duration = 'Monthly';
            benefit.beneficiaries = new List<INS_Quick_Quote_Wrapper.Beneficiaries>{
                beneficiaries
            };

            member.benefits = new List<INS_Quick_Quote_Wrapper.Benefit>{
                benefit
            };
            payload.members.add(member);

        payload.quoteId = '';
        payload.channel = 'Salesforce';
        payload.consultantCode = [Select id,EmployeeNumber from User where id=:userInfo.getUserID()].EmployeeNumber;
        payload.annualBenefitIncrease = 0;
        payload.requestId = '';
        payload.cashBackOption = false;

        INS_Quick_Quote_Wrapper.ProductRules productRules = new INS_Quick_Quote_Wrapper.ProductRules();
        productRules.productId = requests[0].productId;
        productRules.annualBenefitIncrease = 0;
        productRules.waiveWaitingPeriod = false;
        payload.productRules = productRules;

        return payload;
    }

    /**
     * @description       : Handles successful API response.
     * @param   response
     * @param   accessToken
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

        INS_Quick_Quote_Wrapper.Response responseObj = new INS_Quick_Quote_Wrapper.Response();
        responseObj.totalPremium = totalPremium;
        responseObj.totalBenefitAmount = totalBenefitAmount;
        responseObj.quoteNumber = quoteNumber;
        responseObj.quoteId = quoteId;
        responseObj.memberId = memberId;
        responseObj.mainFuneralId = funeralBenefitId;
        responseObj.accessToken = accessToken;

        return new List<INS_Quick_Quote_Wrapper.Response>{
            responseObj
        };
    }
    
    /**
     * @description       : Wrapper Class to pass in the RequestWrapper.
     * @author            : Shams Ul Arifeen
     **/
    public class RequestWrapper{
        @InvocableVariable(label = 'Product Id')
        public String productId;
        @InvocableVariable(label = 'Main Member')
        public InsurancePolicyParticipant mainMember;
        @InvocableVariable(label = 'Allocation AMount')
        public Decimal allocationAmount;
        @InvocableVariable(label = 'Cover Amount')
        public Decimal coverAmount;
        @InvocableVariable(label = 'Customer External Id')
        public String customerExternalId;
        @InvocableVariable(label = 'Client Country')
        public String country;
        //@InvocableVariable(label = 'Identification Type')
       // public String identificationType;
    }
}