/**
* @description Class used to Display Request Object for Latest Financial Transactions on LWC
*
* @author Eduardo Salia
*
* @date July 2021
*/
public with sharing class CMN_DTO_FinancialTransactionsRequest {
    @AuraEnabled public requestObject request {get;set;}
    
    /**
* @description Inner Class for Request Object
*/
    public class RequestObject {
        @AuraEnabled public String uniqueTransactionIdentificationNumber {get;set;} //Unique transaction identification number
        @AuraEnabled public String cifCountry {get;set;} //CIF Country
        @AuraEnabled public String cifSystemIdentificationNumber {get;set;} //CIF system identification number
        @AuraEnabled public String customerUUID {get;set;} //Unique UUID to identify a customer
        @AuraEnabled public String customerIdNumber {get;set;} //Customer identification document number. Example - passport number (or) ID document number
        @AuraEnabled public String customerRegNumber {get;set;} //Customer business registration number
        @AuraEnabled public String accountNo {get;set;} //Customer account number
        @AuraEnabled public String transactionsStartDt {get;set;} //Start date of the transactions
        @AuraEnabled public String transactionsEndDt {get;set;} //End date of the transactions
        @AuraEnabled public String numberOfTransactions {get;set;} //Number of transactions
        @AuraEnabled public List<CMN_DTO_RoutingInformation> routingInformation {get;set;} //Array for routingInformationObject
    }
}