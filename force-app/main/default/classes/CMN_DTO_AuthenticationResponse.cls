/**
* @description Wrapper Class used to Map Authentication Response from ESB
*
* @author Eduardo Salia
*
* @date July 2021
*/
@SuppressWarnings('PMD')
//Suppress Warnings Tag used to avoid Regex Error for Instance Property names: token_type, access_token and expires_in
public with sharing class CMN_DTO_AuthenticationResponse {
    public String token_type {get;set;}
    public String access_token {get;set;}
    public String scope {get;set;}
    public Integer expires_in {get;set;}
}