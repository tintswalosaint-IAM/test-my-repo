/**
 * @description       : Handles quote recalculation by making a callout to the Quick Quote Benefits service.
 * @author            : Irshad
 * @Created on        : 03-25-2026
 * @last modified by  : Irshad
 * 
 * =====================================================TO BE DELETED=================================================
 **/
public with sharing class INS_SRV_CreateQuoteAction {

    
    @AuraEnabled
    public static String recalculateQuote(String quoteId, Map<String, Object> input) {
        // Generate payload internally — no separate LWC call needed
        String payloadJson = generateQuickQuoteBenefitsRequest(quoteId, input);
        System.debug('payloadJson==' + payloadJson);

        INS_SRV_QuickQuote_benefits quickQuoteBenefitsService = new INS_SRV_QuickQuote_benefits(payloadJson, quoteId);
        CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            INS_SRV_QuickQuote_benefits.SERVICE_NAME
        );
        quickQuoteBenefitsService.process(obj);
        insert obj;

        Integer statusCode = quickQuoteBenefitsService.getResponseStatusCode();
        String responseBody = quickQuoteBenefitsService.getResponseBody();
        System.debug('statusCode==' + statusCode);
        System.debug('responseBody==' + responseBody);

        if (statusCode == 200 || statusCode == 201) {
            Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> validation = (Map<String, Object>) jsonResponseMap.get('ValidationResult');

            if (validation != null && 'Success'.equalsIgnoreCase((String) validation.get('ResultStatus'))) {
                List<Object> benefits = (List<Object>) jsonResponseMap.get('benefits');
                return JSON.serialize(new Map<String, Object>{
                    'hasError' => false,
                    'ReCalculateBenefits' => benefits
                });
            } else {
                return JSON.serialize(new Map<String, Object>{
                    'hasError' => true,
                    'ReCalculateBenefitsError' => validation?.get('Message')
                });
            }
        } else {
            return JSON.serialize(new Map<String, Object>{
                'hasError' => true,
                'ReCalculateBenefitsError' => 'Error: ' + statusCode + ' - ' + responseBody
            });
        }
    }

    /**
     * @description Generates the Quick Quote Benefits request payload.
     *              Handles both single BenefitAmount (fpi_chooseYourCover)
     *              and multiple benefits list (cmn_MemberQuoteTable).
     */
    @AuraEnabled
    public static String generateQuickQuoteBenefitsRequest(String quoteId, Map<String, Object> input) {
        Map<String, Object> createQuoteResponse = (Map<String, Object>) JSON.deserializeUntyped(
            JSON.serialize(input.get('CreateQuoteResponse'))
        );
        String memberId = (String) createQuoteResponse.get('memberId');

        // Use wrapper classes
        INS_Quick_Quote_Wrapper.QuoteBenefitRequest request = new INS_Quick_Quote_Wrapper.QuoteBenefitRequest();
        request.referenceNumber = quoteId;
        request.benefits = new List<INS_Quick_Quote_Wrapper.QuoteBenefit>();

        List<Object> incomingBenefits = (List<Object>) input.get('benefits');

        if (incomingBenefits != null && !incomingBenefits.isEmpty()) {
            // Generic path — multiple benefits from cmn_MemberQuoteTable
            for (Object obj : incomingBenefits) {
                Map<String, Object> b = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

                // Resolve amount from either 'amount' or 'benefitAmountValue'
                Object amountObj = b.get('amount') != null ? b.get('amount') : b.get('benefitAmountValue');
                Decimal amount = amountObj != null ? Decimal.valueOf(String.valueOf(amountObj)) : 0;

                // Skip zero amount benefits with no existing id
                if (amount == 0 && b.get('id') == null) {
                    continue;
                }

                INS_Quick_Quote_Wrapper.QuoteBenefit benefit = new INS_Quick_Quote_Wrapper.QuoteBenefit();
                benefit.benefitId             = b.get('id') != null ? (String) b.get('id') : (String) b.get('benefitId');
                benefit.benefitKey            = b.get('key') != null ? (String) b.get('key') : (String) b.get('benefitKey');
                benefit.benefitType           = b.get('type') != null ? (String) b.get('type') : (String) b.get('benefitType');
                benefit.benefitAmountValue    = amount;
                benefit.benefitFrequencyValue = b.get('frequency') != null ? (String) b.get('frequency') : 'MONTHLY';
                benefit.memberId              = memberId;

                request.benefits.add(benefit);
            }

        } else {
            // Single benefit path — MAINFUNERAL from fpi_chooseYourCover
            Decimal totalBenefitAmount = Decimal.valueOf(String.valueOf(input.get('BenefitAmount')));
            System.debug('TotalBenefitAmount==' + totalBenefitAmount);

            INS_Quick_Quote_Wrapper.QuoteBenefit benefit = new INS_Quick_Quote_Wrapper.QuoteBenefit();
            benefit.benefitId             = '1-MAINFUNERAL';
            benefit.benefitKey            = '1.MAINFUNERAL';
            benefit.benefitType           = 'MAINFUNERAL';
            benefit.benefitAmountValue    = totalBenefitAmount;
            benefit.benefitFrequencyValue = 'MONTHLY';
            benefit.memberId              = memberId;

            request.benefits.add(benefit);
        }

        System.debug('Request payload==' + JSON.serialize(request));
        return JSON.serialize(request);
    }
}