/***************************************************************************************
@Name of the Class :SEL_ContentDocumentLink_Test
@Description : Test Class for SEL_ContentDocumentLink	
@Author :Dayakar
@Created Date :sept 13th 2024
***************************************************************************************/
@IsTest
public class SEL_ContentDocumentLink_Test {

    static final String MY_DOC = 'My Document';
    static final String MY_DOC_TITLE = 'Title should match as excpected';

    @testSetup
    static void setup() {
        Application__c app= AOB_BOTS_DAL_TestFactory.createApplication();
        Application_Participant__c aps= AOB_BOTS_DAL_TestFactory.createAppParticipant(app.id);
        AOB_BOTS_DAL_TestFactory.createApplicationParticipantDocument(aps.id); 
    } 
    
    
    /**
     * @description test method SEL_ContentDocumentLink.getDocumentLinkByLinkedEntity
     */
    @Istest
    public static void getDocumentLinkByLinkedEntityTest(){
        Application_Document__c doc = [select Id from Application_Document__c Limit 1];
        List<Id> idlist= new List<Id>();
        idlist.add(doc.id);
        Test.startTest();
        List<ContentDocumentLink> cdlist= new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntity(idlist);
        new SEL_ContentDocumentLink().selectByLinkedEntity(new set<id>{doc.id});
        Test.stopTest();
        ContentVersion cv=  [SELECT Id, ContentDocumentId, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdlist[0].ContentDocumentId];
        Assert.areEqual(cv.Title,MY_DOC,MY_DOC_TITLE);
    }
    
    
    /**
     * @description test method SEL_ContentDocumentLink.getDocumentLinkByLinkedEntityId
     */
    @Istest
    public static void getDocumentLinkByLinkedEntityIdTest(){
        Application_Document__c doc = [select Id from Application_Document__c Limit 1];
        Test.startTest();
        List<ContentDocumentLink> cdlist= new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(doc.id);
        Test.stopTest();
        ContentVersion cv=  [SELECT Id, ContentDocumentId, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdlist[0].ContentDocumentId];
        Assert.areEqual(cv.Title,MY_DOC,MY_DOC_TITLE);
    }
    
    /**
     * @description test method SEL_ContentDocumentLink.getDocumentLinkByLinkedEntityIdWithLimit
     */
    @Istest
    public static void getDocumentLinkByLinkedEntityIdWithLimitTest(){
        Application_Document__c doc = [select Id from Application_Document__c Limit 1];
        Test.startTest();
        List<ContentDocumentLink> cdlist= new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityIdWithLimit(doc.id);
        Test.stopTest();
        ContentVersion cv=  [SELECT Id, ContentDocumentId, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cdlist[0].ContentDocumentId];
        Assert.areEqual(cv.Title,MY_DOC,MY_DOC_TITLE);
    }
    
    /**
     * @description test method SEL_ContentDocumentLink.getDocumentLinkByLinkedEntityIdWithLimitOne
     */
    @Istest
    public static void getDocumentLinkByLinkedEntityIdWithLimitOneTest(){
        Application_Document__c doc = [select Id from Application_Document__c Limit 1];
        Test.startTest();
        ContentDocumentLink cd= new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityIdWithLimitOne(doc.id);
        Test.stopTest();
        ContentVersion cv=  [SELECT Id, ContentDocumentId, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :cd.ContentDocumentId];
        Assert.areEqual(cv.Title,MY_DOC,MY_DOC_TITLE);
    }
}