/**
 * @description Controller Class for handling Quick Links
 *
 * @author Gnitsevich Anton
 *
 * @date October 2021
 */
public with sharing class CMN_CTRL_QuickLinks {

    /**
     * @description This method returns quick links for current user's context
     *
     * @param context context (Home, Account etc)
     *
     * @return List<QuickLink__mdt> List of quick links sorted by Order__c
     */
    @AuraEnabled
    public static List<QuickLink__mdt> getQuickLinks(String context) {
        User usr = [SELECT Id, SVC_UserTeam__c FROM User WHERE Id =: UserInfo.getUserId()];
        context = '%' + context + '%';
        List<QuickLink__mdt> quickLinks = [
            SELECT Id, DeveloperName, Label, Column__c, ColumnTitle__c, Order__c, URL__c, Icon__c, Team__c, Contexts__c
            FROM QuickLink__mdt
            WHERE Team__c =: usr.SVC_UserTeam__c AND Contexts__c LIKE: context
            ORDER BY Order__c ASC
        ];
        //
        return quickLinks;
    }
}