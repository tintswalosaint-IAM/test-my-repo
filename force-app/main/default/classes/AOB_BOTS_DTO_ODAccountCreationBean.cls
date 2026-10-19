/**
 * @description       : Wrapper class for account creation 
 * @author            : Dayakar
 * @last modified on  : 09-04-2023
 * @last modified by  : Dayakar 
**/
public class AOB_BOTS_DTO_ODAccountCreationBean {
    
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

    /** @description ODaccountAddCustomDataInfo is using for ODAccountCreation API request body **/
    public class ODaccountAddCustomDataInfo {
       /** @description PFNum */
        public String PFNum{get;set;}
        
    }
    /** @description SaleBackendBOInfo is using for ODAccountCreation API request body **/
    public class SaleBackendBOInfo {
        /** @description applicationHealthCode */
        public String applicationHealthCode{get;set;}
    }

}