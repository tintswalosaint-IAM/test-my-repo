/**
* @description Used to create Data, mostly for unit tests
* @author Narendra Teja
* @date April 4th 2023
* @ Last Modified By : Dayakar
* @ Last Modified On : 08-08-2023
* @ Modification Description : added new test data methods
*/

public with sharing class AOB_BOTS_DAL_TestFactory {
    
    /**
* @description  create flowscreens
* @return   list<AOB_FlowScreen__c>
*/
    public static list<AOB_FlowScreen__c> createScreen(){
        list<AOB_FlowScreen__c> listScreen = new list<AOB_FlowScreen__c>();
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(Name = 'Company Information',
                                                         AOB_title__c = 'Company Information', 
                                                         AOB_subtitle__c='Enter the following information', 
                                                         AO_ExternalId__c='1234',AOB_Screen_Sequence__c =1, AOB_Language__c='EN');
        listScreen.add(screen);
        insert listScreen;
        return listScreen;    
    }
    
    /**
* @description  create screen sections
* @param screenId
* @return   list<AOB_ScreenSection__c>
*/
    public static list<AOB_ScreenSection__c> createSection(Id screenId){
        list<AOB_ScreenSection__c> listSection = new list<AOB_ScreenSection__c>();
        
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(AOB_Screen__c=screenId, 
                                                                Name='Company details', 
                                                                AOB_ExternalId__c='Q1',     
                                                                AOB_Title__c='Company details');
        
        listSection.add(section);
        insert listSection;
        return listSection;    
    }
    
    
    /**
* @description  create screen fields
* @param sectionId
* @return   list<AOB_Field__c>
*/
    public static list<AOB_Field__c> createFields(id sectionId){
        list<AOB_Field__c> listField = new list<AOB_Field__c>{
            new AOB_Field__c(AOB_Section__c=sectionId, 
                             Name='Cellphone Number', 
                             AOB_Type__c='Text', 
                             AOB_sequence__c='1', 
                             AOB_Label__c='Cellphone Number?'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='cellphone', 
                                 AOB_Type__c='Radio', 
                                 AOB_sequence__c='2', 
                                 AOB_Label__c='Do you have a cellphone?',   
                                 AOB_ShowAtScreenLoad__c=true,
                                 AOB_MRITable__c='PER_CLASSIF'),    
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='Email', 
                                 AOB_Type__c='Email', 
                                 AOB_sequence__c='3', 
                                 AOB_Label__c='Email Address'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='Check Box', 
                                 AOB_Type__c='Checkbox', 
                                 AOB_sequence__c='4', 
                                 AOB_Label__c='CheckBox'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='Currency', 
                                 AOB_Type__c='Currency', 
                                 AOB_sequence__c='5', 
                                 AOB_Label__c='Currency'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='ConsentBoxt', 
                                 AOB_Type__c='ConsentBox', 
                                 AOB_sequence__c='6', 
                                 AOB_Label__c='ConsentBox'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='TextReadOnly', 
                                 AOB_Type__c='TextReadOnly', 
                                 AOB_sequence__c='7', 
                                 AOB_Label__c='TextReadOnly'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='Combobox', 
                                 AOB_Type__c='Combobox', 
                                 AOB_sequence__c='8', 
                                 AOB_Label__c='Combobox'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='Tax', 
                                 AOB_Type__c='Tax', 
                                 AOB_sequence__c='9', 
                                 AOB_Label__c='Tax'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='MultiSelectSearch', 
                                 AOB_Type__c='MultiSelectSearch', 
                                 AOB_sequence__c='10', 
                                 AOB_Label__c='MultiSelectSearch'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='memberdetails', 
                                 AOB_Type__c='memberdetails', 
                                 AOB_sequence__c='11', 
                                 AOB_Label__c='memberdetails'),
                new AOB_Field__c(AOB_Section__c=sectionId, 
                                 Name='directordetails', 
                                 AOB_Type__c='directordetails', 
                                 AOB_sequence__c='12', 
                                 AOB_Label__c='directordetails')};
                                     
                                     insert listField;
        
        AOB_Field__c parent = [select id from AOB_Field__c where AOB_sequence__c = '11' limit 1 ];
        AOB_Field__c child = [select id from AOB_Field__c where AOB_sequence__c = '12' limit 1 ];
        child.AOB_Parent__c = parent.id;
        update child;
        
        return listField;    
    } 
    
    
    /**
* @description  creates refrencedData info 
* @return   list<AOB_ReferencedData__c>
*/
    public static list<AOB_ReferencedData__c> createRefData(){
        list<AOB_ReferencedData__c> listRefData = new list<AOB_ReferencedData__c>();
        
        AOB_ReferencedData__c refData = new AOB_ReferencedData__c(Name='Yes', 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c='PER_CLASSIF', 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c='Yes', 
                                                                  AOB_Language__c = 'en_US');
        
        AOB_ReferencedData__c refData2 = new AOB_ReferencedData__c(name='No', 
                                                                   AOB_Default__c=true, 
                                                                   AOB_SAPField__c='PER_CLASSIF', 
                                                                   AOB_isActive__c=true, 
                                                                   AOB_Code__c='false', 
                                                                   AOB_Language__c = 'en_US');                                                          
        
        listRefData.add(refData);
        listRefData.add(refData2);
        insert listRefData;
        return listRefData;    
    }
    
    /**
* @description  creates lead info
* @return   Lead
*/
    public static Lead createlead(){
        Id recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();       
        Lead ld=new Lead();
        ld.LastName = 'Test Lead';
        ld.AOB_Status__c='New';
        ld.RecordTypeId = recordTypeIdLead;
        insert ld;
        return ld;
    }
    /**
* @description  creates application info
* @return   Application__c
*/
    public static Application__c createApplication(){
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        app.AOB_BusinessLegalName__c='test';
        app.AOB_BCCEntityType__c = 'Sole Proprietor';
        app.Inflight__c ='{"How would like receive the message":"SMS","DATE OF RESOLUTION MEETING":"2023-04-12","Intended use of account":"DP"}';
        insert app; 
        return app;  
    }
    
    /**
* @description  creates Application_Participant info
* @param appId
* @return   Application_Participant__c
*/
    public static Application_Participant__c createAppParticipant(String appId){
        Application_Participant__c participant = new Application_Participant__c(
            CNGCU_Phone__c = '+27123456789',
            CNGCU_Email__c = 'test@example.com',
            Application__c = appId,
            AOB_PostalCode__c='473653',
            AOB_TransactOnTheBusiness__c=true,
            AOB_PreviousScreens__c = 'Summary',
            AOB_FullName__c='test one',
            AOB_TECH_OTPATTEMS__c = 3,
            AOB_Retry_Count__c = 3,
            AOB_IDNumber__c = '123456789',
            Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test two","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}',
            AOB_KeyContactPerson__c = true);
        
        Application_Participant__c participanttwo = new Application_Participant__c(
            CNGCU_Phone__c = '+27123456788',
            CNGCU_Email__c = 'test@example.com',
            Application__c = appId, 
            AOB_PostalCode__c='473653',
            AOB_TransactOnTheBusiness__c=true,
            AOB_PreviousScreens__c = 'Summary',
            AOB_FullName__c='test two',
            AOB_IDNumber__c = '123456799',
            Inflight__c = '{"Directors":{"PHONE_NUMBER":"+26676767676","OMANG_ID_NUMBER":"567867676","FULLNAME":"test one","EMAIL_ADDRESS":"trew@gmail.com","ARE_YOU_THE_KEY_CONTACT_PERSON":false,"ARE_YOU_A_SIGNATORY":false,"ARE_YOU_A_DIRECTOR_ON_THE_ENTITY":false}}',
            AOB_KeyContactPerson__c = false);
        insert participant;
        insert participanttwo;
        return participant; 
        
    }
    
    /**
* @description  creates Application_Participant info
* @param    participantId
*/
    public static void createApplicationParticipantDocument(String participantId){
        Application_Document__c appDoc = new Application_Document__c(Application_Participant__c = participantId);
        insert appDoc;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'My Document';
        cv.PathOnClient = 'path/to/my/document.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT Id,ContentDocumentId,VersionData  FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = appDoc.Id;
        insert cdl;
    }
    
    /**
* @description  creates product info
*/
    public static void creatProduct(){
        Product2 prd=new Product2();
        prd.ProductCode='SOCTY';
        prd.AOB_Memo_Code__c='SOCTY';
        prd.Name='test test';
        prd.CurrencyIsoCode = 'BWP';
        insert prd;
        
    }
    /**
* @description  creates product info
*/
    public static void creatProduct1(){
        Product2 prd=new Product2();
        prd.ProductCode='OD001';
        prd.AOB_Memo_Code__c='OD001';
        prd.Name='test test';
        prd.CurrencyIsoCode = 'BWP';
        insert prd;
        
    }
    
    /**
* @description  creates participantApplication info
*/
    public static void participantApplication(){
        Application__c app = new Application__c(AOB_RegistrationNumber__c = 'Test Registration Number');
        Application_Participant__c participant = new Application_Participant__c(
            AOB_FullName__c = 'Test Participant', 
            AOB_IDNumber__c = '123456789', 
            Application__c = app.Id, 
            CNGCU_Email__c = 'test@test.com', 
            AOB_KeyContactPerson__c = true, 
            AOB_Signatory__c = false
        );
        insert app;
        insert participant;
    }
    
    /**
* @description  creates application info
*/
    public static void application(){
        Application__c app = new Application__c();
        insert app;
        Application_Participant__c appParticipant = new Application_Participant__c(Application__c = app.Id);
        insert appParticipant;
        Application_Line_Item__c appLineItem = new Application_Line_Item__c(Application__c = app.Id, Name = 'Test Product', AOB_Status__c = 'Accepted', AOB_ProductCode__c = 'TEST');
        insert appLineItem;
    }
    
    /**
    * @description  creates application info
    * @param appId
    */
    public static void insertLineItem(Id appId) {
        Application_Line_Item__c ali = new Application_Line_Item__c(
            Application__c = appId,
            Name = 'Test Line Item',
            AOB_Status__c = 'Accepted',
            AOB_Main__c = true,
            AOB_ProductCode__c = 'Test Product'
        );
        insert ali;
    }
    /**
    * @description  creates application info
    * @return Application__c
    */
    public static Application__c createTestRecords() {
        Application__c app = new Application__c();
        insert app;
        
        return app;
    }
    
    /**
* @description  creates application info
* @return Application__c
*/
    public static Application__c createTest() {
        Id recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();       
        Lead ld=new Lead();
        ld.LastName = 'Test Lead';
        ld.AOB_Status__c='New';
        ld.RecordTypeId = recordTypeIdLead;
        insert ld;
        Application__c app = new Application__c();
        app.AOB_RegistrationNumber__c = 'BW00001881348';
        app.AOB_Lead__c=ld.Id;
        insert app;
        Application_Participant__c appParticipant = new Application_Participant__c(AOB_FullName__c = 'test test',Application__c = app.id, AOB_TECH_OTPATTEMS__c = 3,CNGCU_Phone__c = '+27965142523',AOB_Signatory__c = true,AOB_KeyContactPerson__c = true,CNGCU_Email__c = 'test@email.com',AOB_Stage__c='');
        insert appParticipant;
        Application_Line_Item__c appLineItem = new Application_Line_Item__c(Application__c = app.Id, AOB_Main__c = false, Details__c = 'Test details');
        insert appLineItem;
        
        return app;
    }
    /**
* @description  creates application info
* @return Application__c
*/
    public static Application__c createAppParticipant() {
        Application__c app = new Application__c();
        insert app;
        Application_Participant__c appParticipant = new Application_Participant__c(Application__c = app.Id);
        insert appParticipant;
        return app;
    }
    
    /**
* @description  creates application info
* @param lineItems
*/
    public  void createLineItems(List<Application_Line_Item__c> lineItems) {
        insert lineItems;
    }
    
    /**
* @description  creates application info
* @return Application__c
*/
    public static Application__c createAccountForTest(){
        Application__c app = new Application__c();
        app.AOB_BusinessLegalName__c = 'Nit Legal Associates';
        app.Inflight__c = '{"RelyStatusList":[{"complete":"true","customerId":"20243156","Status":"AcceptableRisk"},{"complete":"true","customerId":"20243154","Status":"AcceptableRisk"}],"createAssementRely":["1271359","1271360"],"createCustomerRely":{"upsertCustomers":{"customers":[{"created":true,"customer":{"id":"20243156","identifier":"145746af-bcc2-ff7e-2dae-05ec0636b2b3"}}]}},"SigningHUBDocumnetFaxEmail":{"documentid":13191},"SigningHUBDocumnet":{"documentid":13189},"null":{"cardOption":"Debit card","BWP":0,"PrefferedBranch":"062096"},"SigningHUBPackages":{"package_id":13617,"workflow_mode":"ONLY_OTHERS","workflow_type":"SERIAL"},"SigningHUBDocumnetonline":{"documentid":13190},"createBusinessRely":{"createCustomer":{"customer":{"id":"20243154","created":"2023-04-05T10:06:03.654254+00:00","identifier":"233876e6-16fa-b0dc-f190-cd17668f3986","businessName":"test"}}}}';
        app.AOB_RegistrationNumber__c = 'BW12345678779';
        app.AOB_GUID__c = 'BW12345678779';
        insert app;
        return app;
    }
}