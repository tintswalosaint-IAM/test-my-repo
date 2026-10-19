/**
 * @description       :
 * @author            :
 * @group             :
 * @last modified on  : 03-25-2026
 * @last modified by  : 
 **/
global with sharing class INS_SRV_CallBenefits_RemoteAction implements Callable {
    global Object call(String actionType, Map<String, Object> args) {
        if (actionType == 'reCalculateBenefits') {
            Map<String, Object> input = (Map<String, Object>) args.get('input');
            // Get the JSon request payload data from the iput and send it to CreateQuote API
            Map<String, Object> output = (Map<String, Object>) args.get('output');
            return callReCalculateBenefitsAPI(input, output, null);
        }

        throw new AuraHandledException('Unsupported action: ' + actionType);
    }

    @AuraEnabled(cacheable=false)
    public static Object callReCalculateBenefitsAPI(
        Map<String, Object> input,
        Map<String, Object> output,
        String payloadReq
    ) {
        // Get the JSon request payload data from the input and send it to ReCalculateBenefits API
        String payloadJson;
        String quoteId;
        if (input != null && !input.isEmpty()) {
            Map<String, Object> CreateQuoteResponse = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(input.get('CreateQuoteResponse')));
            quoteId = (String) CreateQuoteResponse.get('quoteId');
            payloadJson = generateQuickQuoteBenefitsRequest(quoteId, input);
            
        } else {
            requestWrapperBenefits request = (requestWrapperBenefits) JSON.deserialize(payloadReq, requestWrapperBenefits.class);
            quoteId = request.referenceNumber;
            payloadJson = JSON.serialize(request);
        }
        System.debug('payloadJson==' + payloadJson);

        INS_SRV_QuickQuote_benefits quickQuoteBenefitsService = new INS_SRV_QuickQuote_benefits(payloadJson, quoteId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_benefits.SERVICE_NAME
        );
        quickQuoteBenefitsService.process(obj);
        insert obj;

        // Map<String, Object> jsonResponseMap = new Map<String, Object>();
        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            quickQuoteBenefitsService.getResponseBody()
        );
        System.debug('jsonResponse==' + JSON.serialize(jsonResponseMap));

        Integer statusCode = quickQuoteBenefitsService.getResponseStatusCode();

        if (statusCode == 201 || statusCode == 200) {
            processSuccessResponse(jsonResponseMap, output);
        } else {
            output.put('hasError', 'true');
            Map<String, Object> errorResponse = (Map<String, Object>) jsonResponseMap.get('error');
            String errorDescription = (String) errorResponse.get('errorDescription');
            output.put('ReCalculateBenefitsError', errorDescription);
        }

        return output;
    }

    @AuraEnabled(cacheable=false)
    public static String generateRequestPayload(List<benefitWrapper> benefitsRequestList, String quoteId) {
        // Implement the logic to generate the JSON request body for Create Quote API
        requestWrapperBenefits request = new requestWrapperBenefits();
        request.referenceNumber = quoteId;
        request.benefits = benefitsRequestList;

        return JSON.serialize(request);
    }
    @AuraEnabled
    public static Map<String, Object> prepareQuoteMemberBenefits(String quoteId, membersWrapper member) {
        Map<String, Object> output = new Map<String, Object>();
        requestWrapperAddMembers request = new requestWrapperAddMembers();
        request.referenceNumber = quoteId;
        request.members = new List<membersWrapper>{ member };
        // for (benefitWrapper benefit : member.benefits) {
        //     benefit.benefitAmountValue = '10000';
        // }

        requestWrapperBenefits requestBenefits = new requestWrapperBenefits();
        requestBenefits.referenceNumber = quoteId;
        requestBenefits.benefits = new List<benefitWrapper>{ member.benefits[0] };

        String payloadJson = JSON.serialize(requestBenefits);
        // String payloadJson = JSON.serialize(request);
        System.debug('payloadJson==' + payloadJson);
        INS_SRV_QuickQuote_benefits quickQuoteBenefitsService = new INS_SRV_QuickQuote_benefits(payloadJson, quoteId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_benefits.SERVICE_NAME
        );
        quickQuoteBenefitsService.process(obj);
        insert obj;

        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            quickQuoteBenefitsService.getResponseBody()
        );
        System.debug('jsonResponse==' + JSON.serialize(jsonResponseMap));

        Integer statusCode = quickQuoteBenefitsService.getResponseStatusCode();

        if (statusCode == 201 || statusCode == 200) {
            processSuccessResponse(jsonResponseMap, output);
            output.put('result', jsonResponseMap);
        } else {
            output.put('hasError', 'true');
            String errorDescription = (String) jsonResponseMap.get('errorDescription');
            output.put('ReCalculateBenefitsError', errorDescription);
            output.put('result', jsonResponseMap);
        }

        return output;
    }

    public static String generateQuickQuoteBenefitsRequest(String quoteId, Map<String, Object> input) {
        // Implement the logic to generate the JSON request body for Quick Quote Benefits
        Map<String, Object> CreateQuoteResponse = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(input.get('CreateQuoteResponse')));
        List<benefitWrapper> benefitsList = new List<benefitWrapper>();
        Decimal TotalBenefitAmount = (Decimal) input.get('BenefitAmount');
        System.debug('TotalBenefitAmount==' + TotalBenefitAmount);
        // main Member
        benefitWrapper benefit = new benefitWrapper();
        benefit.benefitId = '1-MAINFUNERAL';
        benefit.benefitKey = '1.MAINFUNERAL';
        benefit.benefitType = 'MAINFUNERAL';
        benefit.benefitAmountValue = String.ValueOf(TotalBenefitAmount); //'65000'; //(String) input.get('benefitAmountValue');
        benefit.benefitFrequencyValue = 'MONTHLY'; //(String) input.get('benefitFrequencyValue');
        benefit.memberId = (String) CreateQuoteResponse.get('memberId');

        benefitsList.add(benefit);

        requestWrapperBenefits request = new requestWrapperBenefits();
        request.referenceNumber = quoteId;
        request.benefits = benefitsList;
        return JSON.serialize(request);
    }

     @AuraEnabled
     public static string recalculateQuote(string quoteId, Map<String, Object> input) {
        String payloadJson = generateQuickQuoteBenefitsRequest(quoteId, input);
        System.debug('payloadJson==' + payloadJson);
        INS_SRV_QuickQuote_benefits quickQuoteBenefitsService = new INS_SRV_QuickQuote_benefits(payloadJson, quoteId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_benefits.SERVICE_NAME
        );
        quickQuoteBenefitsService.process(obj);
        insert obj;

        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            quickQuoteBenefitsService.getResponseBody()
        );
        System.debug('jsonResponse==' + JSON.serialize(jsonResponseMap));

        Integer statusCode = quickQuoteBenefitsService.getResponseStatusCode();

        if (statusCode == 201 || statusCode == 200) {
            return 'success';
        } else {
            return 'error';
        }   


     }


    /**
     * method to generate the JSON request body for Add Members API
     * @param quoteId - the quote Id for which the members are being added
     * @param input - the input map containing the member details and benefits details
     * @return String - the JSON serialized request body
     **/

    public static String generateAddMemberPayload(String quoteId, Map<String, Object> input) {
        requestWrapperAddMembers request = new requestWrapperAddMembers();
        request.referenceNumber = quoteId;

        // Extract member details from the input map
        membersWrapper member = new membersWrapper();
        member.surname = (String) input.get('surname');
        member.firstName = (String) input.get('firstName');
        member.staff = (String) input.get('staff');
        member.relationship = (String) input.get('relationship');
        member.memberType = (String) input.get('memberType');
        member.memberId = (String) input.get('memberId');
        // member.isStaff = (Boolean) input.get('isStaff');
        member.isStaff = false;
        member.idNumber = (String) input.get('idNumber');
        member.identityDocumentType = (String) input.get('identityDocumentType');
        member.gender = (String) input.get('gender');
        member.dateOfBirth = (String) input.get('dateOfBirth');
        // member.benefits = (List<benefitWrapper>)input.get('benefits');
        benefitWrapper benefitWraper = new benefitWrapper();
        benefitWraper.benefitType = 'EXTENDEDFAMILYBENEFIT';
        benefitWraper.benefitKey = '11.EXTENDEDFAMILYBENEFIT';
        benefitWraper.benefitId = '';
        benefitWraper.benefitFrequencyValue = 'MONTHLY';
        benefitWraper.benefitAmountValue = '50000.0';

        member.benefits = new List<benefitWrapper>{ benefitWraper };

        // Add the member to the request
        request.members = new List<membersWrapper>();
        request.members.add(member);

        return JSON.serialize(request);
    }

    public static String generateEditMemberPayload(String quoteId, Map<String, Object> input) {
        requestWrapperAddMembers request = new requestWrapperAddMembers();
        request.referenceNumber = quoteId;
        membersWrapper member = (membersWrapper) JSON.deserialize(JSON.serialize(input), membersWrapper.class);
        // Add the member to the request
        request.members = new List<membersWrapper>();
        request.members.add(member);

        return JSON.serialize(request);
    }

    public static void processSuccessResponse(Map<String, Object> jsonResponseMap, Map<String, Object> output) {
        Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');
        try {
            if (validation != null) {
                String resultStatus = (String) validation.get('ResultStatus');
                System.debug('Validation Message==' + validation.get('Message'));
                if ('Failed'.equalsIgnoreCase(resultStatus)) {
                    output.put('hasError', true);
                    output.put('ReCalculateBenefits', validation.get('Message'));
                } else if ('Success'.equalsIgnoreCase(resultStatus)) {
                    List<Object> benefits = (List<Object>) jsonResponseMap.get('benefits');
                    output.put('hasError', false);
                    output.put('ReCalculateBenefits', benefits);
                }
            } else {
                output.put('hasError', true);
                String errorDescription = (String) jsonResponseMap.get('errorDescription');
                output.put('ReCalculateBenefitsError', errorDescription);
            }
        } catch (Exception ex) {
        }
    }
    public static void processMembersSuccessResponse(Map<String, Object> jsonResponseMap, Map<String, Object> output) {
        Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');
        try {
            if (validation != null) {
                String resultStatus = (String) validation.get('ResultStatus');
                System.debug('Validation Message==' + validation.get('Message'));
                if ('Failed'.equalsIgnoreCase(resultStatus)) {
                    output.put('hasError', true);
                    output.put('members', null);
                    output.put('error', validation.get('Message'));
                } else if ('Success'.equalsIgnoreCase(resultStatus)) {
                    List<Object> benefits = (List<Object>) jsonResponseMap.get('members');
                    output.put('hasError', false);
                    output.put('members', benefits);
                }
            } else {
                output.put('hasError', true);
                String errorDescription = (String) jsonResponseMap.get('errorDescription');
                output.put('members', null);
                output.put('error', errorDescription);
            }
        } catch (Exception ex) {
        }
    }

    /**
     * Call Add members API to add members to an existing quote.
     * This method will be called from the client side when the user adds a new member to the quote.
     * It will generate the JSON request body using the input map and call the INS_SRV_QuickQuote_Members service
     * to add the member to the quote.
     *
     */
    @AuraEnabled
    public static Object callAddMembersAPI(Map<String, Object> input, Map<String, Object> output) {
        String payloadJson = generateEditMemberPayload((String) input.get('quoteId'), input);
        System.debug('Add Members Payload JSON: ' + payloadJson); 
        INS_SRV_QuickQuote_Members quickQuoteAddMemberService = new INS_SRV_QuickQuote_Members(
            payloadJson,
            (String) input.get('quoteId')
        );
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_Members.SERVICE_NAME
        );
        quickQuoteAddMemberService.process(obj);
        insert obj;

        // Handle the response as needed and populate the output map
        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            quickQuoteAddMemberService.getResponseBody()
        );
        System.debug('jsonResponse==' + JSON.serialize(jsonResponseMap));

        Integer statusCode = quickQuoteAddMemberService.getResponseStatusCode();
        if (statusCode == 201 || statusCode == 200) {
            processMembersSuccessResponse(jsonResponseMap, output);
        } else {
            output.put('hasError', 'true');
            output.put('AddMembersError', JSON.deserializeUntyped(quickQuoteAddMemberService.getResponseBody()));
        }

        return output;
    }

    @AuraEnabled
    public static Object callEditMembersAPI(Map<String, Object> input, Map<String, Object> output) {
        String payloadJson = generateEditMemberPayload((String) input.get('quoteId'), input);
        System.debug('Edit Members Payload JSON: ' + payloadJson);

        INS_SRV_QuickQuote_EditMembers quickQuoteEditMemberService = new INS_SRV_QuickQuote_EditMembers(
            payloadJson,
            (String) input.get('quoteId')
        );
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_EditMembers.SERVICE_NAME
        );
        quickQuoteEditMemberService.process(obj);
        insert obj;

        // Handle the response as needed and populate the output map
        Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(
            quickQuoteEditMemberService.getResponseBody()
        );
        System.debug('jsonResponse==' + JSON.serialize(jsonResponseMap));

        Integer statusCode = quickQuoteEditMemberService.getResponseStatusCode();
        if (statusCode == 201 || statusCode == 200) {
            processMembersSuccessResponse(jsonResponseMap, output);
        } else {
            output.put('hasError', 'true');
            output.put('EditMembersError', JSON.deserializeUntyped(quickQuoteEditMemberService.getResponseBody()));
        }

        return output;
    }

    /**
     * @description       : Handles successful API response.
     * @author            : Shams Ul Arifeen
     * @param  response
     * @param  member
     * @return            : InsurancePolicyParticipant
     **/
    private static InsurancePolicyParticipant handleSuccessfulResponse(
        HttpResponse response,
        InsurancePolicyParticipant member
    ) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> membersList = (List<Object>) responseMap.get('members');
        for (Object memberObj : membersList) {
            Decimal premiumAmount = 0.00;
            Map<String, Object> memberMap = (Map<String, Object>) memberObj;
            String memberId = (String) memberMap.get('memberId');
            String idNumber = (String) memberMap.get('idNumber');
            if (member.IdentityNumber__c == idNumber) {
                member.Member_Id__c = memberId;
                List<Object> benefits = (List<Object>) memberMap.get('benefits');
                for (Object benefitObj : benefits) {
                    Map<String, Object> benefitMap = (Map<String, Object>) benefitObj;
                    String benefitType = (String) benefitMap.get('benefitType');
                    // Map premium data based on benefit type
                    if (benefitType.contains('CATERING')) {
                        member.Catering_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('TOMBSTONE') || benefitType.contains('ADVERTISEMENT')) {
                        member.Tombstone_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('FUNERAL') || benefitType == 'EXTENDEDFAMILYBENEFIT') {
                        member.Funeral_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('REPATRIATION')) {
                        member.Transport_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('AIRTIME') || benefitType.contains('RADIOANNOUNCEMENT')) {
                        member.Radio_Announcement_benefit_Id__c = (String) benefitMap.get('benefitId');
                    } else if (benefitType.contains('GROCERYBENEFIT')) {
                        member.Shopping_Benefit_Id__c = (String) benefitMap.get('benefitId');
                    }
                    premiumAmount += (Decimal) benefitMap.get('premium');
                }

                member.Monthly_Premium__c = premiumAmount;
                System.debug('premiumAmount==' + premiumAmount);
            }
        }
        return member;
    }

    public class requestWrapperBenefits {
        public String referenceNumber; // external quote Id
        public List<benefitWrapper> benefits;
    }

    public class requestWrapperAddMembers {
        public String referenceNumber; // external quote Id
        public List<membersWrapper> members;
    }

    public class benefitWrapper {
        @AuraEnabled
        public String benefitId { get; set; } // 1-MAINFUNERAL
        @AuraEnabled
        public String benefitKey { get; set; } // 1.MAINFUNERAL
        @AuraEnabled
        public String benefitType { get; set; } // MAINFUNERAL
        @AuraEnabled
        public String benefitAmountValue { get; set; }
        @AuraEnabled
        public String duration { get; set; }
        @AuraEnabled
        public Decimal coverAmount { get; set; }
        @AuraEnabled
        public String benefitFrequencyValue { get; set; }
        @AuraEnabled
        public String prefix { get; set; }
        public Integer commission = 0;
        public Integer premiumDue = 0;
        public Integer proratPremium = 0;
        public String premiumType = 'NORMALPREMIUM';
        public Integer vat = 0;
        public Integer prorata = 0;
        public Integer commissionAmount = 0;
        @AuraEnabled
        public String memberId { get; set; }
        // @AuraEnabled
        // public List<BeneficiaryWrapper> beneficiaries { get; set; }
    }
    public class BeneficiaryWrapper {
        @AuraEnabled
        public String allocationType { get; set; }
        @AuraEnabled
        public Decimal allocationAmount { get; set;}
    }
    

    public class membersWrapper {
        @AuraEnabled
        public String surname { get; set; }
        @AuraEnabled
        public String firstName { get; set; }
        @AuraEnabled
        public String staff { get; set; }
        @AuraEnabled
        public String relationship { get; set; }
        @AuraEnabled
        public String memberType { get; set; }
        @AuraEnabled
        public String memberId { get; set; }
        @AuraEnabled
        public boolean isStaff { get; set; }
        @AuraEnabled
        public String idNumber { get; set; }
        @AuraEnabled
        public String identityDocumentType { get; set; }
        @AuraEnabled
        public String gender { get; set; }
        @AuraEnabled
        public String dateOfBirth { get; set; }
        public String bpid;
        // benefits details
        @AuraEnabled
        public String benefitsTotalAmount { get; set; }
        @AuraEnabled
        public String benefitsTotalMonthlyAmount { get; set; }
        @AuraEnabled
        public List<benefitWrapper> benefits { get; set; }
    }
    public class MemberWrapper {
        @AuraEnabled
        public String surname;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String staff;
        @AuraEnabled
        public String relationship;
        @AuraEnabled
        public String memberType;
        @AuraEnabled
        public String memberId;
        @AuraEnabled
        public boolean isStaff;
        @AuraEnabled
        public String idNumber;
        @AuraEnabled
        public String identityDocumentType;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String dateOfBirth;
        public String bpid;
        // benefits details
        @AuraEnabled
        public String benefitsTotalAmount { get; set; }
        @AuraEnabled
        public String benefitsTotalMonthlyAmount { get; set; }
        @AuraEnabled
        public List<benefitWrapper> benefits;
    }
}