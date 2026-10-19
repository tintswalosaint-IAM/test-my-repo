/**
 * @description Wrapper Class for COAP POAP Components Information 
 * 
 * @userStory SFP-11931 Epic 3 MVP2 : Customer on a page (Profile)
 *
 * @author Alexei Vyrskii
 *
 * @date January 2023
*/
public with sharing class COAP_DTO_CoapPoapComponent {
    
    @AuraEnabled public String message {get;set;}
    @AuraEnabled public String componentName {get;set;}
    @AuraEnabled public String values {get;set;}

}