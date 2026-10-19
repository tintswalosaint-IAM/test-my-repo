/***************************************************************************************
@ Author            :Jagadish
@ Date              :Feb 2024
@ Name of the Class :SEL_ContentVersion_Test
@ Description       :test class to cover the content version selector class.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20/02/2024.
@ Modification Description : SFP-31036
***************************************************************************************/
 /**
    * @description test class to cover the content version selector class.
 */
@isTest
private class SEL_ContentVersion_Test {

    private static Id contentDocumentId;
    @testSetup
    static void setupTestData() {
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        ContentVersion cv = AOB_TestDataFactory.createContentVersion();
        List<ContentVersion> documentList = new List<ContentVersion>{cv};
        insert documentList;
        ContentVersion contentVersion2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :documentList[0].Id LIMIT 1];
        List<Product2> productList = AOB_TestDataFactory.createProduct();
        insert productList;

        lstApp[0].AOB_Product__c = productList[0].Id;
        update lstApp;

        ContentDocumentLink cDoc = AOB_TestDataFactory.createContentDocumentLink(productList[0].Id, contentVersion2.ContentDocumentId);
        insert cDoc;
        contentDocumentId = contentVersion2.ContentDocumentId;
        Lead ld = AOB_TestDataFactory.createLead();
        List<Lead> ldList = new List<Lead>();
        ldList.add(ld);
        insert ldList;
    }
    
   /**
    * @description Tests the method selectWithoutCondition() 
    *              to ensure it retrieves ContentVersion records without any conditions.
    */

    @isTest
    static void testSelectWithoutCondition() {
        SEL_ContentVersion selector = new SEL_ContentVersion();
        List<ContentVersion> result = selector.selectWithoutCondition();
       Assert.AreNotEqual(null, result,'test message');
    }
    /**
    * @description Tests the method selectApplicationById() to fetch ContentVersion 
    *              records using a specific ContentDocumentId.
    */
    @isTest
    static void testSelectApplicationById() {
        SEL_ContentVersion selector = new SEL_ContentVersion();
        List<ContentVersion> result = selector.selectApplicationById(contentDocumentId);
        selector.selectContentVersionByList(new list<ContentVersion>());
        selector.selectApplicationByIdandTitleAndlastModifiedDate(new set<id>(),new list<string>());
        selector.selectContentVersionByIds(new List<Id>(), '');
        selector.getDocumentLinkByLinkedEntityIdWithLimit(contentDocumentId);
        Assert.AreNotEqual(null, result,'test message');    
    }
     /**
    * @description Tests the method selectContentVersionByIds() to retrieve ContentVersion 
    *              records by a given list of ContentDocumentIds.
    */
    @isTest
    static void testSelectContentVersionByIds() {
        SEL_ContentVersion selector = new SEL_ContentVersion();
        List<Id> contentDocList = new List<Id>{contentDocumentId};
        List<ContentVersion> result = selector.selectContentVersionByIds(contentDocList);
        Assert.AreNotEqual(null, result,'test message');   
    }
    /**
    * @description Tests the method selectContentVersionByContentDocLatest() 
    *              to ensure it retrieves the latest ContentVersion record for a given ContentDocumentId.
    */
    @isTest
    static void testSelectContentVersionByContentDocLatest() {
        SEL_ContentVersion selector = new SEL_ContentVersion();
        List<ContentVersion> result = selector.selectContentVersionByContentDocLatest(contentDocumentId);
        Assert.AreNotEqual(null, result,'test message');   
    }
     /**
    * @description Tests the method selectContentVersionByContentDocListLatest() 
    *              to verify retrieval of the latest ContentVersion records for multiple ContentDocumentIds.
    */
    @isTest
    static void testSelectContentVersionByContentDocListLatest() {
        SEL_ContentVersion selector = new SEL_ContentVersion();
        Set<Id> contentDocumentIds = new Set<Id>{contentDocumentId};
        List<ContentVersion> result = selector.selectContentVersionByContentDocListLatest(contentDocumentIds);
        Assert.AreNotEqual(null, result,'test message');    
    }
    /**
    * @description Tests the method selectApplicationByIdandTitle() to ensure ContentVersion 
    *              records are fetched based on ContentDocumentId and document title.
    */
    @isTest
    static void testSelectApplicationByIdandTitle() {
        SEL_ContentVersion selector = new SEL_ContentVersion();
        List<Id> contentDocumentIdList = new List<Id>{contentDocumentId};
        List<String> documentTitleList = new List<String>{'Test Content Document'};
        List<ContentVersion> result = selector.selectApplicationByIdandTitle(contentDocumentIdList, documentTitleList);
        Assert.AreNotEqual(null, result,'test message');   
    }
     /**
    * @description Tests the method selectByIds() to verify that ContentVersion 
    *              records can be retrieved by their IDs.
    */
    @isTest
    static void selectByIdsTest() {
        List<ContentVersion> result = new SEL_ContentVersion().selectWithoutCondition();
        new SEL_ContentVersion().selectByIds(new set<id>{result[0].id});
        Assert.AreNotEqual(null, result,'test message');
    }
    
}