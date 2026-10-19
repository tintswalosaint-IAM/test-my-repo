/**
* @description Wrapper Class used to Display Response Object for History Notes on LWC
*
* @author Eduardo Salia
*
* @date September 2021
*/
public with sharing class CMN_DTO_NoteInformationResponse {
    
    @AuraEnabled public List<CMN_DTO_NoteInformation> notes {get;set;} //Array for CMN_DTO_NoteInformation Object
    
}