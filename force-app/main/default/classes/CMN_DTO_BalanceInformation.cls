/**
* @description Wrapper Class for Balance Information Object
*
* @author Eduardo Salia
*
* @date July 2021
*/
public with sharing class CMN_DTO_BalanceInformation {
    @AuraEnabled public String balanceAmount {get;set;} //Amount remaining in the account
    @AuraEnabled public String balanceType {get;set;} //Type of balance
    @AuraEnabled public String balanceDate {get;set;} //ISO 8601 compliant date {yyyy-mm-dd}
    @AuraEnabled public String currencyCode {get;set;} //Currency type of the balance
    @AuraEnabled public String accountNo {get;set;}
}