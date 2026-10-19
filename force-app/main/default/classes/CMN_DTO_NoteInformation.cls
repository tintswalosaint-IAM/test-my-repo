/**
* @description Wrapper Class for Note Information Object for History Notes
*
* @author Eduardo Salia
*
* @date September 2021
*/
public with sharing class CMN_DTO_NoteInformation {
    
    @AuraEnabled public String noteDatedOn {get;set;}
    @AuraEnabled public String type {get;set;}
    @AuraEnabled public String noteDetails {get;set;}
    @AuraEnabled public String noteCreatedBy {get;set;}

}