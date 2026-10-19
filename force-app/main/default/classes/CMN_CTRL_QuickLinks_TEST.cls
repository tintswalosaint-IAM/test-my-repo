/**
* @description Test Class for CMN_CTRL_QuickLinks class
*
* @author Gnitsevich Anton
*
* @date October 2021
*/
@IsTest
public with sharing class CMN_CTRL_QuickLinks_TEST {
    private static final Id ACCOUNT_RECORDTYPE_PERSON =
        Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

    @IsTest
    private static void testNoQuickLinksReturned() {
        // cannot insert metadata records in tests, so verify there's no quick links for invalid context
        Test.startTest();
        List<QuickLink__mdt> links;
        links = CMN_CTRL_QuickLinks.getQuickLinks('testcontext');
        Test.stopTest();
        //
        System.assertEquals(links.size(), 0, 'No links should be returned');
    }
}