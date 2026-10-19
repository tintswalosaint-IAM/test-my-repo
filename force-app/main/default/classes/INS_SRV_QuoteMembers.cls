/**
 * @description Service class for managing quote members via LWC direct Apex calls.
 *              Handles adding and editing members on an existing quote by calling
 *              the Quick Quote Members and Edit Members services.
 * @author      Irshad
 * @group       Insurance
 * @last modified on  : 03-29-2026
 * @last modified by  : Irshad
 **/
public with sharing class INS_SRV_QuoteMembers {

    /**
     * @description Adds a new member to an existing quote.
     *              Builds the member payload, calls the Add Members service,
     *              and returns the API response mapped into a result object.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and members list or error message.
     */
    @AuraEnabled
    public static String addMember(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildMemberPayload(quoteId, input);
            System.debug('Add Member payload: ' + payloadJson);

            INS_SRV_QuickQuote_Members service = new INS_SRV_QuickQuote_Members(payloadJson, quoteId);
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
                INS_SRV_QuickQuote_Members.SERVICE_NAME
            );
            service.process(obj);
            insert obj;

            Integer statusCode = service.getResponseStatusCode();
            String responseBody = service.getResponseBody();
            System.debug('Add Member status: ' + statusCode);
            System.debug('Add Member response: ' + responseBody);

            return processResponse(statusCode, responseBody);

        } catch (Exception ex) {
            throw new AuraHandledException('Add member failed: ' + ex.getMessage());
        }
    }

    /**
     * @description Edits an existing member on a quote.
     *              Builds the member payload, calls the Edit Members service,
     *              and returns the API response mapped into a result object.
     * @param quoteId The external quote reference number.
     * @param input   Map containing updated member details and benefit configuration from LWC.
     * @return        Serialised JSON string containing hasError flag and members list or error message.
     */
    @AuraEnabled
    public static String editMember(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildMemberPayload(quoteId, input);
            System.debug('Edit Member payload: ' + payloadJson);

            INS_SRV_QuickQuote_EditMembers service = new INS_SRV_QuickQuote_EditMembers(payloadJson, quoteId);
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
                INS_SRV_QuickQuote_EditMembers.SERVICE_NAME
            );
            service.process(obj);
            insert obj;

            Integer statusCode = service.getResponseStatusCode();
            String responseBody = service.getResponseBody();
            System.debug('Edit Member status: ' + statusCode);
            System.debug('Edit Member response: ' + responseBody);

            return processResponse(statusCode, responseBody);

        } catch (Exception ex) {
            throw new AuraHandledException('Edit member failed: ' + ex.getMessage());
        }
    }

    /**
     * @description Builds the serialised JSON request payload for the Add/Edit Members API.
     *              Maps LWC input fields into the INS_Quick_Quote_Wrapper structures.
     * @param quoteId The external quote reference number.
     * @param input   Map containing member and benefit details from LWC.
     * @return        Serialised JSON string of the member payload.
     */
    private static String buildMemberPayload(String quoteId, Map<String, Object> input) {
        INS_Quick_Quote_Wrapper.MemberPayload request = new INS_Quick_Quote_Wrapper.MemberPayload();
        request.referenceNumber = quoteId;
        request.thirdPartyPolicy = false; // false for myself and true for someoneelse

        INS_Quick_Quote_Wrapper.AddMember member = new INS_Quick_Quote_Wrapper.AddMember();
        member.firstName             = (String) input.get('firstName');
        member.surname               = (String) input.get('surname');
        member.relationship          = (String) input.get('relationship');
        member.memberType            = (String) input.get('memberType');
        member.memberId              = (String) input.get('memberId');
        member.idNumber              = (String) input.get('idNumber');
        member.identityDocumentType  = (String) input.get('identityDocumentType');
        member.gender                = (String) input.get('gender');
        member.dateOfBirth           = (String) input.get('dateOfBirth');
        member.bpid                  = (String) input.get('bpid');
       

        // Map benefits from LWC input
        List<Object> incomingBenefits = (List<Object>) input.get('benefits');
        member.benefits = new List<INS_Quick_Quote_Wrapper.MemberBenefit>();

        if (incomingBenefits != null) {
            for (Object obj : incomingBenefits) {
                Map<String, Object> b = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

                Object amountObj = b.get('benefitAmountValue') != null
                    ? b.get('benefitAmountValue')
                    : b.get('amount');
                Decimal amount = amountObj != null ? Decimal.valueOf(String.valueOf(amountObj)) : 0;

                // Skip zero amount benefits
                if (amount == 0) {
                    continue;
                }

                INS_Quick_Quote_Wrapper.MemberBenefit benefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
                benefit.benefitId             = b.get('benefitId') != null ? String.valueOf(b.get('benefitId')) : null;
                benefit.benefitKey            = b.get('benefitKey') != null ? String.valueOf(b.get('benefitKey')) : null;
                benefit.benefitType           = b.get('benefitType') != null ? String.valueOf(b.get('benefitType')) : null;
                benefit.benefitAmountValue    = amount;
                benefit.benefitFrequencyValue = b.get('benefitFrequencyValue') != null
                    ? String.valueOf(b.get('benefitFrequencyValue'))
                    : 'MONTHLY';
                benefit.premiumType           = 'NORMALPREMIUM';
                benefit.prefix                = b.get('prefix') != null ? String.valueOf(b.get('prefix')) : 'R';

                member.benefits.add(benefit);
            }
        }

        request.members = new List<INS_Quick_Quote_Wrapper.AddMember>{ member };
        system.debug('Request payload =='+JSON.serialize(request));
		return JSON.serialize(request);
    }

    /**
     * @description Processes the API HTTP response and returns a standardised JSON result string.
     *              Checks the ValidationResult block to determine success or failure.
     * @param statusCode   HTTP status code from the service callout.
     * @param responseBody Raw JSON response body string from the service callout.
     * @return             Serialised JSON string with hasError, members, or error fields.
     */
    private static String processResponse(Integer statusCode, String responseBody) {
        if (statusCode == 200 || statusCode == 201) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> validation  = (Map<String, Object>) responseMap.get('ValidationResult');

            if (validation != null) {
                String resultStatus = (String) validation.get('ResultStatus');

                if ('Success'.equalsIgnoreCase(resultStatus)) {
                    return JSON.serialize(new Map<String, Object>{
                        'hasError' => false,
                        'members'  => responseMap.get('members')
                    });
                } else {
                    return JSON.serialize(new Map<String, Object>{
                        'hasError' => true,
                        'error'    => validation.get('Message')
                    });
                }
            }

            return JSON.serialize(new Map<String, Object>{
                'hasError' => true,
                'error'    => 'Unexpected response format'
            });

        } else {
            return JSON.serialize(new Map<String, Object>{
                'hasError' => true,
                'error'    => 'Service error: ' + statusCode + ' - ' + responseBody
            });
        }
    }


    /**
    * @description Calculates benefit premiums for given members and benefits without saving.
    *              Builds the calculation payload, calls the Benefit Calculation service,
    *              and returns the calculated premiums in the response.
    * @param quoteId The external quote reference number.
    * @param input   Map containing member details and benefit configuration from LWC.
    * @return        Serialised JSON string containing hasError flag and calculated premiums or error message.
    */
    @AuraEnabled
    public static String calculateBenefits(String quoteId, Map<String, Object> input) {
        try {
            String payloadJson = buildBenefitCalculationPayload(quoteId, input);
            System.debug('Benefit Calculation payload: ' + payloadJson);

            INS_SRV_Get_BenefitPremiums service = new INS_SRV_Get_BenefitPremiums(payloadJson, quoteId);
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
                INS_SRV_Get_BenefitPremiums.SERVICE_NAME
            );
            service.process(obj);
            insert obj;

            Integer statusCode = service.getResponseStatusCode();
            String responseBody = service.getResponseBody();
            System.debug('Benefit Calculation status: ' + statusCode);
            System.debug('Benefit Calculation response: ' + responseBody);
            calculatePremiumWrapper wrClass =
                (calculatePremiumWrapper) JSON.deserialize(responseBody, calculatePremiumWrapper.class);
            
            return processCalculateResponse(statusCode, responseBody);

        } catch (Exception ex) {
            throw new AuraHandledException('Benefit calculation failed: ' + ex.getMessage());
        }
    }

    /**
    * @description Builds the serialised JSON request payload for the Benefit Calculation API.
    *              Maps only the minimum fields required for premium calculation
    *              (gender, dateOfBirth, benefits) without full member details.
    * @param quoteId The external quote reference number.
    * @param input   Map containing member and benefit details from LWC.
    * @return        Serialised JSON string of the calculation payload.
    */
    private static String buildBenefitCalculationPayload(String quoteId, Map<String, Object> input) {
       
        calculatePremiumWrapper request = new calculatePremiumWrapper();
        request.referenceNumber = quoteId;
        request.thirdPartyPolicy = false;// false for myself and true for others
        // Build minimal member data — only what's needed for calculation
        INS_Quick_Quote_Wrapper.AddMember member = new INS_Quick_Quote_Wrapper.AddMember();
        member.gender      = (String) input.get('gender');
        member.dateOfBirth = (String) input.get('dateOfBirth');

        // Map benefits from LWC input
        List<Object> incomingBenefits = (List<Object>) input.get('benefits');
        List<INS_Quick_Quote_Wrapper.MemberBenefit> benefitList = new List<INS_Quick_Quote_Wrapper.MemberBenefit>();
        //member.benefits = new List<INS_Quick_Quote_Wrapper.MemberBenefit>();

        if (incomingBenefits != null) {
            for (Object obj : incomingBenefits) {
                Map<String, Object> b = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

                Object amountObj = b.get('benefitAmountValue') != null
                    ? b.get('benefitAmountValue')
                    : b.get('amount');
                Decimal amount = amountObj != null ? Decimal.valueOf(String.valueOf(amountObj)) : 0;

                // Skip zero amount benefits
                if (amount == 0) {
                    continue;
                }

                INS_Quick_Quote_Wrapper.MemberBenefit benefit = new INS_Quick_Quote_Wrapper.MemberBenefit();
                benefit.benefitKey            = b.get('benefitKey') != null ? String.valueOf(b.get('benefitKey')) : null;
                benefit.benefitType           = b.get('benefitType') != null ? String.valueOf(b.get('benefitType')) : null;
                benefit.benefitAmountValue    = amount;
                benefit.benefitFrequencyValue = b.get('benefitFrequencyValue') != null
                    ? String.valueOf(b.get('benefitFrequencyValue'))
                    : 'MONTHLY';

                //member.benefits.add(benefit);
                benefitList.add(benefit);
            }
        }

        request.members = new List<INS_Quick_Quote_Wrapper.AddMember>{ member };
        //request1.members = new List<INS_Quick_Quote_Wrapper.AddMember>{ member };
        request.benefits = benefitList;
        System.debug('Benefit Calculation request payload == ' + JSON.serialize(request, true));
        return JSON.serialize(request, true);
    }

    private static String processCalculateResponse(Integer statusCode, String responseBody) {
        if (statusCode == 200 || statusCode == 201) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                return JSON.serialize(new Map<String, Object>{
                    'hasError' => false,
                    'benefits'  => responseMap.get('benefits'),
                    'members'  => responseMap.get('members')
                });           
                
            
            
        }else{
            return JSON.serialize(new Map<String, Object>{
                    'hasError' => true,
                    'error'    => 'Error in the API'
                });
        }
          

       
    }

    private class calculatePremiumWrapper {
        private String referenceNumber;
        private Boolean thirdPartyPolicy;
        private List<INS_Quick_Quote_Wrapper.AddMember> members;
        private List<INS_Quick_Quote_Wrapper.MemberBenefit> benefits;
    }

    
}