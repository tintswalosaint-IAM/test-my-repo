public with sharing class INS_SRV_CallQuickQuote_benefits {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_SRV_CallQuickQuote_benefits');
    public INS_SRV_CallQuickQuote_benefits() {

    }

    public static void generatePayloadAndCallService(Id quoteId) {
        try {
            String jsonRequestBody = generateQuickQuoteBenefitsRequest(quoteId);
            INS_SRV_QuickQuote_benefits quickQuoteBenefitsService = new INS_SRV_QuickQuote_benefits(jsonRequestBody, quoteId);    
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(INS_SRV_QuickQuote_benefits.SERVICE_NAME);
            quickQuoteBenefitsService.process(obj);
            insert obj;
        } catch(Exception ex) {
            LOGGER.error('Error in calling Quick Quote Benefits service for Quote Id: ' + quoteId, ex);
        }
    }

    public static String generateQuickQuoteBenefitsRequest(String quoteId){
        // Implement the logic to generate the JSON request body for Quick Quote Benefits
        return '';
    }

    public class benefitWrapper {
        public String benefitId {get; set;}
        public String benefitKey {get; set;}
        public String benefitType {get; set;}
        public String benefitAmountValue {get; set;}
        public String benefitFrequencyValue {get; set;}
        public Integer commission =0;
        public Integer premiumDue =0;
        public Integer proratPremium =0;
        public String premiumType ='NORMALPREMIUM';
        public Integer vat =0;
        public Integer prorata =0;
        public Integer commissionAmount =0;
        public String memberId {get; set;}
    }

    
}