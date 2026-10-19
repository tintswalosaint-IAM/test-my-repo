/**
* @description Wrapper Class used to Display Response Object for Get Product Portfolio
*
* @author Eduardo Salia
*
* @date October 2021
*/
public with sharing class CMN_DTO_ProductPortfolioResponse {
    
    @AuraEnabled public List<CMN_DTO_ProductPortfolio> accountProductDetails {get;set;}

}