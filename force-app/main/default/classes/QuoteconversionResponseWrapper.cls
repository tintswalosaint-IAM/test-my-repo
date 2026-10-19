/**
 * @description wrapper class  QuoteconversionResponseWrapper for INS_Quote_Conversion.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param .
 * @return .
 * @date Nov 07th 2023
 */
public class QuoteconversionResponseWrapper {
    /**
 	  * @description quoteHeader		
 	*/
    public quoteHeader quoteHeader{get;set;}
    /**
 	  * @description validationResult		
 	*/
    public validationResult validationResult{get;set;}
    /**
 		* @description otpNumber		
 	*/
    public Integer otpNumber{get;set;}
    /**
 		* @description referenceNumber		
 	*/
    public String referenceNumber{get;set;}
    /**
 		* @description otpDate		
 	*/
    public String otpDate{get;set;}
    /**
 		* @description PolicyNumber		
 	*/
    public String PolicyNumber{get;set;}
    
    /**
 * @description wrapper class  validationResult.
 *
 * @param .
 * @return .
 */
    public class validationResult{
        public list<String> validationMessages{get;set;}
        public String fullValidationMessage{get;set;}
        public Boolean isValid{get;set;}
    }
    /**
 * @description wrapper class  quoteHeader.
 *
 * @param .
 * @return .
 */
    public class quoteHeader{
        /**
         * @description cashBackPremium.         
        */
        public String cashBackPremium{get;set;}
        /**
         * @description debitOrderDate.         
        */
        public String debitOrderDate{get;set;}
        /**
         * @description cashBackOption.         
        */
        public String cashBackOption{get;set;}
        /**
         * @description coverEffectiveDate.         
        */
        public String coverEffectiveDate{get;set;}
        /**
         * @description ppol.         
        */
        public String ppol{get;set;}
        /**
         * @description faAgreementNumber.         
        */
        public String faAgreementNumber{get;set;}
        /**
         * @description leadId.         
        */
        public String leadId{get;set;}
        /**
         * @description costCenterNumber.         
        */
        public String costCenterNumber{get;set;}
        /**
         * @description requestId.         
        */
        public String requestId{get;set;}
        /**
         * @description branchCode.         
        */
        public String branchCode{get;set;}
        /**
         * @description status.         
        */
        public String status{get;set;}
        /**
         * @description consultantCode.         
        */
        public String consultantCode{get;set;}
        /**
         * @description totalPremium.         
        */
        public Decimal totalPremium{get;set;}
        /**
         * @description campaignCode.         
        */
        public String campaignCode{get;set;}
        /**
         * @description totalVatAmount.         
        */
        public Decimal totalVatAmount{get;set;}
        /**
         * @description promoCode.         
        */
        public String promoCode{get;set;}
        /**
         * @description prorataPremium.         
        */
        public Decimal prorataPremium{get;set;}
        /**
         * @description waiveWaitingPeriod.         
        */
        public Boolean waiveWaitingPeriod{get;set;}
        /**
         * @description brokerCommission.         
        */
        public Decimal brokerCommission{get;set;}
        /**
         * @description annualBenefitIncrease.         
        */
        public Integer annualBenefitIncrease{get;set;}
        /**
         * @description externalReference.         
        */
        public String externalReference{get;set;}
        /**
         * @description referenceNumber.         
        */
        public String referenceNumber{get;set;}
        /**
         * @description cashbackBenefit.         
        */
        public Boolean cashbackBenefit{get;set;}
        /**
         * @description productId.         
        */
        public String productId{get;set;}
        /**
         * @description otpNumber.         
        */
        public Integer otpNumber{get;set;}
        /**
         * @description channel.         
        */
        public String channel{get;set;}
        /**
         * @description otpDate.         
        */
        public String otpDate{get;set;}
        /**
         * @description quoteNumber.         
        */
        public String quoteNumber{get;set;}
        /**
         * @description saleReferenceId.         
        */
        public String saleReferenceId{get;set;}
        /**
         * @description quoteKey.         
        */
        public String quoteKey{get;set;}
        /**
         * @description quoteId.         
        */
        public String quoteId{get;set;}
        /**
         * @description headerId.         
        */
        public String headerId{get;set;}
    }
}