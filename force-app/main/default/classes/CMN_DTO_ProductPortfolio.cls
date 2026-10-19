/**
* @description Wrapper Class used to Display Response Object for Get Product Portfolio
*
* @author Eduardo Salia
*
* @date October 2021
*/
public with sharing class CMN_DTO_ProductPortfolio {
    
    @AuraEnabled public String accountNumber {get;set;}
    @AuraEnabled public String accountName {get;set;}
    @AuraEnabled public String accountType {get;set;}
    @AuraEnabled public String productNumber {get;set;}
    @AuraEnabled public String productName {get;set;}
    @AuraEnabled public String accountStatus {get;set;}
}