/**
* @description BeanClass for dealing with account creation api and sending the result to the main container and storing the values in the wrapper
* @author Amarnath Reddy(amarnath.reddy@stanndardbank.co.za)
* @date june 2022
*/

public class AOB_ODAccountCreationBean {

    /** @description ODAccountAddRq */
    public ODAccountAddRqInfo ODAccountAddRq{get;set;}
    /** @description ODaccountAddCustomData */
    public ODaccountAddCustomDataInfo ODaccountAddCustomData{get;set;}
     /** @description ODAccountAddRqInfo is using for ODAccountCreation API request body **/
    public class ODAccountAddRqInfo {
        /** @description customerNumber */
        public String customerNumber{get;set;}
        /** @description accountType */
        public AccountTypeInfo accountType{get;set;}
        /** @description accountCurrency */
        public String accountCurrency{get;set;}
        /** @description bankInfo */
        public BankInformation bankInfo{get;set;}
        /** @description ODAcctGeneralInfo */
        public ODAcctGeneralInformation ODAcctGeneralInfo{get;set;}
        /** @description accountLimits */
        public AccountLimitsInfo accountLimits{get;set;}
        /** @description localCalculationFlag */
        public String localCalculationFlag{get;set;}
    }
    /** @description AccountTypeInfo is using for ODAccountCreation API request body **/
    public class AccountTypeInfo {
        /** @description schemaCode */
        public String schemaCode{get;set;}
    }
    /** @description BankInformation is using for ODAccountCreation API request body **/
    public class BankInformation {
        /** @description bankId */
        public String bankId{get;set;}
        /** @description branchId */
        public String branchId{get;set;}
    }
    /** @description ODAcctGeneralInformation is using for ODAccountCreation API request body **/
    public class ODAcctGeneralInformation {
        /** @description despatchMode */
        public String despatchMode{get;set;}
    }
    /** @description AccountLimitsInfo is using for ODAccountCreation API request body **/
    public class AccountLimitsInfo {
        /** @description expiryDate */
        public String expiryDate{get;set;}
        /** @description documentDate */
        public String documentDate{get;set;}
        /** @description drawingPowerIndicator */
        public String drawingPowerIndicator{get;set;}
    }
    /** @description ODaccountAddCustomDataInfo is using for ODAccountCreation API request body **/
    public class ODaccountAddCustomDataInfo {
        /** @description localCalculationFlag */
        public String localCalculationFlag{get;set;}
        /** @description missEntered */
        public String missEntered{get;set;}
        /** @description pricingCode */
        public String pricingCode{get;set;}
        /** @description PHCode */
        public String PHCode{get;set;}
        /** @description EFTFlag */
        public String EFTFlag{get;set;}
        /** @description WPBFlag */
        public String WPBFlag{get;set;}
        /** @description INTCRAccountFlag */
        public String INTCRAccountFlag{get;set;}
        /** @description INTDRAccountFlag */
        public String INTDRAccountFlag{get;set;}
        /** @description saleBackendBO */
        public SaleBackendBOInfo saleBackendBO{get;set;}
        /** @description selfPrintChequeBook */
        public String selfPrintChequeBook{get;set;}
        /** @description channelID */
        public String channelID{get;set;}
        /** @description PFNum */
        public String PFNum{get;set;}
        /** @description applicationHealthCode */
        public String applicationHealthCode{get;set;}
        /** @description alternativeInstitutionName */
        public String alternativeInstitutionName{get;set;}
        /** @description alternativeAccountName */
        public String alternativeAccountName{get;set;}
        /** @description alternativeAccountNumber */
        public String alternativeAccountNumber{get;set;}
         /** @description DepositAmountLimitValue */
        public String DepositAmountLimitValue{get;set;}
         /** @description DepositCurrency */
        public String DepositCurrency{get;set;}
         /** @description TransferAmountLimitValue */
        public String TransferAmountLimitValue{get;set;}
         /** @description TransferAmountCurrency */
        public String TransferAmountCurrency{get;set;}
    }
    /** @description SaleBackendBOInfo is using for ODAccountCreation API request body **/
    public class SaleBackendBOInfo {
        /** @description applicationHealthCode */
        public String applicationHealthCode{get;set;}
    }
}