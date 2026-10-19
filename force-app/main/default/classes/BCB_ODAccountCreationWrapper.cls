/**
* @description BeanClass for dealing with account creation api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@stanndardbank.co.za)
* @date june 2023
* Story Number : SFP-25770
*/
public without sharing class BCB_ODAccountCreationWrapper {
    /** @description ODAccountAddRq */
    public class ODAccountAddRq {
        /** @description Attribute */
        public ODAcctGeneralInfo ODAcctGeneralInfo {get;set;}
        /** @description Attribute */
        public String localCalculationFlag {get;set;}
        /** @description Attribute */
        public String customerNumber {get;set;}
        /** @description Attribute */
        public BankInfo bankInfo {get;set;}
        /** @description Attribute */
        public AccountType accountType {get;set;}
        /** @description Attribute */
        public AccountLimits accountLimits {get;set;}
        /** @description Attribute */
        public String accountCurrency {get;set;}
    }
     /** @description AccountLimits */
    public class AccountLimits {
        /** @description Attribute */
        public String expiryDate {get;set;}
        /** @description Attribute */
        public String drawingPowerIndicator {get;set;}
        /** @description Attribute */
        public String documentDate {get;set;}
    }
    /** @description Attribute ODAccountAddRq */
    public ODAccountAddRq ODAccountAddRq {get;set;}
        /** @description Attribute ODaccountAddCustomData */
    public ODaccountAddCustomData ODaccountAddCustomData {get;set;}
    /** @description customer details */
    public class ODaccountAddCustomData {
        /** @description Attribute */
        public String WPBFlag {get;set;}
        /** @description Attribute */
        public String selfPrintChequeBook {get;set;}
        /** @description Attribute */
        public Object saleBackendBO {get;set;}
        /** @description Attribute */
        public String pricingCode {get;set;}
        /** @description Attribute */
        public String PHCode {get;set;}
        /** @description Attribute */
        public String PFNum {get;set;}
        /** @description Attribute */
        public String missEntered {get;set;}
        /** @description Attribute */
        public String localCalculationFlag {get;set;}
        /** @description Attribute */
        public String EFTFlag {get;set;}
        /** @description Attribute */
        public String INTCRAccountFlag {get;set;}
        /** @description Attribute */
        public String INTDRAccountFlag {get;set;}
        /** @description Attribute */
        public String channelID {get;set;}
        /** @description Attribute */
        public String applicationHealthCode {get;set;}
        /** @description Attribute */
        public String alternativeInstitutionName {get;set;}
        /** @description Attribute */
        public String alternativeAccountNumber {get;set;}
        /** @description Attribute */
        public String alternativeAccountName {get;set;}
    }
    /** @description general details */
    public class ODAcctGeneralInfo {
        /** @description Attribute */
        public String despatchMode {get;set;}
    }
    /** @description Accounttype */
    public class AccountType {
        /** @description Attribute */
        public String schemaCode {get;set;}
    }
     /** @description bank account details */
    public class BankInfo {
        /** @description Attribute */
        public String branchId {get;set;}
        /** @description Attribute */
        public String bankId {get;set;}
    }
    
}