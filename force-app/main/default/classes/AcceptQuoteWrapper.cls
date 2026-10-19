/**
 * @description wrapper class  AcceptQuoteWrapper for INS_Accept_Quote.
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @date Nov 07th 2023
 */
public class AcceptQuoteWrapper {
    	
    	/**
         * @description coverEffectiveDate.         
        */
		public String coverEffectiveDate{get;set;}//coverEffectiveDate
    	/**
         * @description bankingDetails.         
        */
		public BankingDetails bankingDetails{get;set;}//bankingDetails
    	/**
         * @description underwriterNotes.         
        */
		public String underwriterNotes{get;set;}//underwriterNotes
   		/**
         * @description premiumTypes.         
        */
		public Integer premiumTypes{get;set;}//premiumTypes
    	/**
         * @description referralOverrideIndicator.         
        */
		public Boolean referralOverrideIndicator{get;set;}//referralOverrideIndicator
    	/**
         * @description debitOrderDate.         
        */
		public String debitOrderDate{get;set;}//debitOrderDate
    	/**
         * @description policyNumber.         
        */
		public String policyNumber{get;set;}//policyNumber
    	/**
         * @description policyId.         
        */
		public String policyId{get;set;}//policyId
    	/**
         * @description quoteNumber.         
        */
		public String quoteNumber{get;set;}//quoteNumber
    	/**
         * @description prorataPremium.         
        */
		public Integer prorataPremium{get;set;}//prorataPremium
            
/** @description wrapper class  BankingDetails
  */
    
	public class BankingDetails{
        
        /**
         * @description idCountryOfIssue.         
        */
		public String idCountryOfIssue{get;set;}//idCountryOfIssue
        /**
         * @description title.         
        */
		public String title{get;set;}//title
        /**
         * @description gender.         
        */
		public String gender{get;set;}//gender
        /**
         * @description identityDocumentType.         
        */
		public String identityDocumentType{get;set;}//identityDocumentType
        /**
         * @description dateOfBirth.         
        */
		public String dateOfBirth{get;set;}//dateOfBirth
        /**
         * @description idNumber.         
        */
		public String idNumber{get;set;}//idNumber
        /**
         * @description branchCode.         
        */
		public String branchCode{get;set;}//branchCode
        /**
         * @description branchName.         
        */
        public String branchName{get;set;}//branchName
        /**
         * @description contactNumber.         
        */
		public String contactNumber{get;set;}//contactNumber
        /**
         * @description bankName.         
        */
		public String bankName{get;set;}//bankName
        /**
         * @description initials.         
        */
		public String initials{get;set;}//initials
        /**
         * @description accountType.         
        */
		public Integer accountType{get;set;}//accountType
        /**
         * @description surname.         
        */
		public String surname{get;set;}//surname
        /**
         * @description debitOrderMandateCheck.         
        */
		public Boolean debitOrderMandateCheck{get;set;}//debitOrderMandateCheck
        /**
         * @description name.         
        */
		public String name{get;set;}//name
        /**
         * @description validationResponse.         
        */
		public String validationResponse{get;set;}//validationResponse
        /**
         * @description accountNumber.         
        */
		public String accountNumber{get;set;}//accountNumber
        /**
         * @description isValidated.         
        */
		public Boolean isValidated{get;set;}//isValidated
        /**
         * @description validationOverridden.         
        */
		
		public Boolean validationOverridden{get;set;}//validationOverridden
        /**
         * @description bankAccountKey.         
        */
		public String bankAccountKey{get;set;}//bankAccountKey
	}
}