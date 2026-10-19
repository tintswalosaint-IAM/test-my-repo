/**
 * @description       :Test Class for ContentVersion Entity
 * @author            : VenkataRamadevi Ravuri
 * @last modified on  : April 4th 2023
 * @last modified by  : VenkataRamadevi Ravuri
**/
@IsTest
public class AOB_BOTS_SEL_ContentVersion_Test {

    @TestSetup
    public static void testSetUp(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
    }

    /**
    * Test method for BOTS SEL.ContentVersion.getSObjectFieldList
    * Check that fields are returned correctly
    */
    @IsTest
    private static void getSObjectFieldListTest(){
        Test.startTest();
        AOB_BOTS_SEL_ContentVersion app = new AOB_BOTS_SEL_ContentVersion();
        List<Schema.SObjectField> lst = app.getSObjectFieldList();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-fields returned');
    }

    /**
    * Test method for BOTS SEL.ContentVersion.getSObjectType
    * Check that an sObjectType is returned
    */
    @IsTest
    private static void getSObjectTypeTest(){      
        Test.startTest();
        AOB_BOTS_SEL_ContentVersion app = new AOB_BOTS_SEL_ContentVersion();
        Schema.SObjectType typ = app.getSObjectType();
        Test.stopTest();
        Assert.areEqual(ContentVersion.sObjectType,typ);
    }

    /**
    * Test method for BOTS ContentVersion selectWithoutCondition
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectWithoutConditionTest(){
        ContentVersion contentVersion = [Select Id,Title, ContentDocumentId from ContentVersion Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ContentVersion app = new AOB_BOTS_SEL_ContentVersion();
        List<ContentVersion> lst = app.selectWithoutCondition();
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }

    /**
    * Test method for BOTS ContentVersion selectWithoutCondition
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectApplicationByIdTest(){
        ContentVersion contentVersion = [Select Id,Title, ContentDocumentId from ContentVersion Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ContentVersion app = new AOB_BOTS_SEL_ContentVersion();
        List<ContentVersion> lst = app.selectApplicationById(contentVersion.ContentDocumentId);
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }
    /**
    * Test method for BOTS ContentVersion selectWithoutCondition
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectContentVersionByIdTest(){
        ContentVersion contentVersion = [Select Id,Title, ContentDocumentId from ContentVersion Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ContentVersion app = new AOB_BOTS_SEL_ContentVersion();
        ContentVersion lst = app.selectContentVersionById(contentVersion.Id);
        Test.stopTest();
        Assert.areNotEqual(null,lst.Id,'successful-application/s returned');
    }
    /**
    * Test method for BOTS ContentVersion selectWithoutCondition
    * Check that at least one application is returned
    */
    @IsTest
    private static void selectContentVersionByIdsTest(){
        ContentVersion contentVersion = [Select Id,Title, ContentDocumentId from ContentVersion Limit 1 ];
        Test.startTest();
        AOB_BOTS_SEL_ContentVersion app = new AOB_BOTS_SEL_ContentVersion();
        List<ContentVersion> lst = app.selectContentVersionByIds(New List<Id>{contentVersion.ContentDocumentId});
        Test.stopTest();
        Assert.areNotEqual(0,lst.size(),'successful-application/s returned');
    }

}