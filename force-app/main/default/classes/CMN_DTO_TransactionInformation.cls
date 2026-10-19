/**
* @description Wrapper Class for Transaction Information Object
*
* @author Eduardo Salia
*
* @date July 2021
*/
public with sharing class CMN_DTO_TransactionInformation {
    @AuraEnabled public String transactionDt {get;set;} //Date on which the transaction took place
    @AuraEnabled public String transactionType {get;set;} //Type of transaction. Example. atm withdrawal, ib payment etc
    @AuraEnabled public String description {get;set;} //The narrative or description of the transaction
    @AuraEnabled public String creditDebit {get;set;} //A fixed code of for Credits {c} or Debits {d}
    @AuraEnabled public String amount {get;set;} //This is a positive number representing the amount
    @AuraEnabled public String currencyCode {get;set;} //ISO 4217 Currency code
}