/**
* @description Wrapper Class used to Display Response Object for Latest Financial Transactions on LWC
*
* @author Eduardo Salia
*
* @date July 2021
*/
public with sharing class CMN_DTO_FinancialTransactionsResponse {
    @AuraEnabled public ResponseObject response {get;set;}
    
    /**
* @description Inner Class for Response Object
*/
    public class ResponseObject {
        @AuraEnabled public String uniqueTransactionIdentificationNumber {get;set;} //Unique transaction identification number
        @AuraEnabled public String cifCountry {get;set;} //CIF Country
        @AuraEnabled public String cifSystemIdentificationNumber {get;set;} //CIF system identification number
        @AuraEnabled public List<CMN_DTO_RoutingInformation> routingInformation {get;set;} //Array for routingInformationObject
        @AuraEnabled public List<CMN_DTO_TransactionInformation> transactions {get;set;} //Array for transactionObject
    }    
}