/**
* @description Wrapper Class for Routing Information Object
*
* @author Eduardo Salia
*
* @date July 2021
*/
public with sharing class CMN_DTO_RoutingInformation {
    @AuraEnabled public String systemIdentificationNumber {get;set;} //System identification number
    @AuraEnabled public String applicationIdentificationNumber {get;set;} //Application identification number
}