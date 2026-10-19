/**
* @description Bean Class for dealing with BCB_CreateAccountLockProfile api and sending the result to the main container and storing the values in the wrapper
* @author Lokesh Bothsa(lokesh.bothsa@standardbank.co.za)
* @date june 2023
* Story Number : SFP-27033
*/
public class BCB_CreateAccountLockProfileBean {
    /** @description Attribute */
    public String lockIndicator {get;set;}
    /** @description Attribute */
    public String accountNumber {get;set;}
    /** @description Attribute */
    public String lockCode {get;set;}
    /** @description Attribute */
    public String lockReason {get;set;}
    /** @description Attribute */
    public String modLockIndicator {get;set;}
    /** @description Attribute */
    public String lockRemarks {get;set;}
}