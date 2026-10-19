/***************************************************************************************
@Name of the Class : BCB_DAL_TestFactory
@description       : Used to create Data, mostly for unit tests.
@Author            : Sai Sharanyya 
@Date              : June 23rd 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 29-02-2024
@Modification Description : SFP-36156
***************************************************************************************/
public with sharing class BCB_DAL_TestFactory {
      /**
    * @description Method for the list of application
    * @param numApplications
    * @return List<Application__c>
    */
    public static List<Application__c> createApplication(Integer numApplications) {
        List<Application__c> applicationList = new List<Application__c>();
        for(Integer i=0;i<numApplications;i++) {
            Application__c application = new Application__c();
            application.AOB_FirstName__c = 'Johnson Tipiyai';
            application.AOB_City__c = 'ABIM';
            application.AOB_DateofRegistration__c=Date.valueOf('1993-01-01 00:00:00');
            application.AOB_Mode_Of_Payment__c = 'Mobile Money';
            application.AOB_Country__c = 'UG';
            application.AOB_Operator_Name__c = 'MTN';
            application.AOB_MNO_Customer_Name__c = 'IGA KAGWAA';
            application.AOB_State__c = 'NRT';
            application.AOB_Street__c = '1st';    
            application.AOB_Email__c = 'testUser'+i+'@standardbank.com';
            application.AOB_Phone__c = '256987654321';
            application.AOB_DOB__c = Date.valueOf('1993-01-01 00:00:00');
            application.AOB_NIN__c = 'CM930121003EGE';
            application.AOB_UTM_Source__c = 'SFMC';
            application.AOB_UTM_Medium__c = 'email';
            application.AOB_Fund_Amount__c = '12000';
            application.AOB_Account_Number__c = '9030020820380';
            application.AOB_Mobile_Money_Number__c = '997755660'+i;
            application.AOB_Nationality__c = 'IN';
            application.AOB_UTM_Campaign__c = '101_Consumer_UG__05102022_credit-card_gold_POC-Campaign-for-onboarding-dropped_SFMC_push';
            application.AOB_Accommodation_Type__c= 'X';
            application.AOB_County__c= 'Abim';
            application.AOB_Course_Name__c= 'MBA';
            application.AOB_Accommodation_Type__c = 'X';
            application.AOB_Current_Address_City__c = 'ABIM';
            application.AOB_Current_Address_From_Date__c = system.today();
            application.AOB_Current_Address_PostalCode__c = '256';
            application.AOB_Current_Address_State__c = 'NRT';
            application.AOB_Current_Address_Street__c = 'Street';
            application.AOB_Customer_Id__c = '10302230085';
            application.AOB_Device_Details__c = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36';
            application.AOB_Email_Type__c = 'COMMEML';
            application.AOB_Employer_Address__c = 'Kampala';
            application.AOB_Employer_Name__c = 'Test';
            application.AOB_Employment_Type__c = '001';
            application.AOB_IP_Address__c = '255.255.255.255';
            application.AOB_Institution__c = 'SRM';
            application.AOB_LastName__c = 'User';
            application.AOB_Marital_Status__c = '002';
            application.AOB_Occupation__c = '003';
            application.AOB_Phone_Type__c = 'CELLPH';
            application.AOB_PostalCode__c = '256';
            application.AOB_Preferred_Branch__c = '031066';
            application.AOB_Sector__c = '001';
            application.AOB_Sectorcode__c = 'A';
            application.AOB_Selected_Currency__c = 'UGX';
            application.AOB_Subsector__c = '101';
            application.AOB_BusinessLegalName__c='uganda inc';
            application.AOB_GroupName__c='test';
            application.AOB_RegistrationNumber__c='124234';
            application.AOB_inflightData__c = '{"sourceOfFunds":null,"registrationDate":"2023-05-29","noOfEmployees":"3","newAccountReason":"","grossIncomeEntity":"TRUE","grossAssetsEntity":"TRUE","businessPlotDetails":"Corndog Street UG","businessDistrict":"Abim","businessCity":"ABIM","anticipatedAnnualTO":"123","undefined":"","UPLOAD TRADE LICENSE":true,"UPLOAD COMPANY REGISTRATION CERTIFICATE":true,"UPLOAD STATEMENT OF PARTICULARS FOR SOLE PROPS":true,"ConsentBox":true}';
            application.Inflight__c = '{"sourceOfFunds":null,"registrationDate":"2023-05-29","noOfEmployees":"3","newAccountReason":"","grossIncomeEntity":"TRUE","grossAssetsEntity":"TRUE","businessPlotDetails":"Corndog Street UG","businessDistrict":"Abim","businessCity":"ABIM","anticipatedAnnualTO":"123","undefined":"","UPLOAD TRADE LICENSE":true,"UPLOAD COMPANY REGISTRATION CERTIFICATE":true,"UPLOAD STATEMENT OF PARTICULARS FOR SOLE PROPS":true,"ConsentBox":true}';

            
            applicationList.add(application);
        }
        return applicationList;
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
* @description Method for the list of Banking product details
* @return ContentVersion 
*/
    public static ContentVersion createContentVersion(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Everyday Banking account_UGX';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        return cv;
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
    * @description Method for the lead data
    * @return Lead 
    */
    public static Lead createLead (){
        String recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Uganda_Onboarding').getRecordTypeId();
        Lead ld = new Lead();
        ld.FirstName = 'testName';
        ld.LastName = 'testLead';
        ld.Email = 'test@gmail.com';
        ld.Status = 'New';
        ld.Company = 'testLead';
        ld.Phone = '1234567';
        ld.recordTypeId = recordTypeId;
        ld.AOB_Date_of_Birth__c = system.today();
        return ld;
    }
    /**
    * @description Method for the lead data
    * @return id 
    */
    public static Individual createIndividual (){
        String recordTypeId = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get('Uganda_Onboarding').getRecordTypeId();
        Individual individualRecord = new Individual();
        individualRecord.FirstName = 'testName';
        individualRecord.LastName = 'testIndividual';
        individualRecord.recordTypeId = recordTypeId;
        return individualRecord;
    }
     /**
    * @description Method for the product details
    * @return List<Product2> 
    */
    public static List<Product2> createProduct (){
        Product2 pr = new Product2();
        pr.Name = 'testName';
        pr.isActive = true;
        pr.AOB_Account_Type__c = 'Everyday Banking account';
        pr.AOB_Memo_Code__c = 'OD005';
        pr.AOB_Pricing_Option__c = 'PAYAS';
        pr.AOB_ProductCategory__c = 'Savings';
        pr.AOB_Product_Details__c = 'Test Product Details';
        pr.AOB_Scheme_Type__c = 'ODA';
        pr.Description = 'Test Description';
        pr.Country__c = 'UG';
        List<Product2> prList = new List<Product2>();
        prList.add(pr);
        return prList;
    }
    /**
    * @description Method for the document details
    * @param linkedEdId 
    * @param contentdocId
    * @return contentlink
    */
    public static ContentDocumentLink createContentDocumentLink (String linkedEdId, String contentdocId){
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = linkedEdId;
        contentlink.contentdocumentid = contentdocId;
        contentlink.ShareType = 'V';
        return contentlink; 
    }
    /**
    * @description Method for createapplicationdocument
    * @param appId
    * @return appDoc
    */
    public static Application_Document__c createApplicationDocument(String appId){
        Application_Document__c appDoc = new Application_Document__c(Application__c = appId,
        Document_Type__c='Upload Proof of Identity');      
        return appDoc;
      
    }
    
    
    public static Application_Document__c createApplicationDocumentforImage(String appId){
        Application_Document__c appDoc = new Application_Document__c(Application_Participant__c = appId,
        Document_Type__c='FaceImage');      
        return appDoc;
      
    }
    
    public static Application_Document__c createApplicationDocumentforSignature(String appId){
        Application_Document__c appDoc = new Application_Document__c(Application_Participant__c = appId,
        Document_Type__c='upload signature');      
        return appDoc;
      
    }

    /**
    * @description Method for the flow screen object values
    * @param numOfScreenRecord
    * @return flowScreenList
    */
    public static List<AOB_FlowScreen__c> createFlowScreen(Integer numOfScreenRecord) {
        List<AOB_FlowScreen__c> flowScreenList = new List<AOB_FlowScreen__c>();
        for(Integer i = 0;i < numOfScreenRecord;i++) {
            AOB_FlowScreen__c fs = new AOB_FlowScreen__c();
            fs.name='Great Choice!'+i;
            fs.AO_ExternalId__c='1234444'+i;
            fs.AOB_TitleApplicationField__c = 'AOB_title__c';
            fs.AOB_Screen_Sequence__c=19-i;
            flowScreenList.add(fs);
        }

        return flowScreenList;
    }
     /**
    * @description Method for the screen field object values
    * @param section
    * @param type
    * @return AOB_Field__c
    */
    public static AOB_Field__c createAOBField(String section, String type) {
        AOB_Field__c fi = new AOB_Field__c();
        fi.Name = 'Test';
        fi.AOB_Section__c = section;
        fi.AOB_Label__c = 'Test';
        fi.AOB_sequence__c = '1';
        fi.AOB_Type__c = type;
        return fi;
    }
  
    /**
    * @description Method for the list of application
    * @param numApplications
    * @return List<Application_Participant__c>
    */
    public static List<Application_Participant__c> createApplicationParticipant(Integer numApplications) {
        List<Application_Participant__c> applicationParticipantList = new List<Application_Participant__c>();
        list<Application__c> appList= BCB_DAL_TestFactory.createApplication(1);
        insert appList;
        for(Integer i=0;i<numApplications;i++) {
            Application_Participant__c application = new Application_Participant__c();
            application.Application__c = appList[0].Id;
            application.CNGCU_First_Name__c = 'Johnson';
            application.CNGCU_Last_Name__c='Tipiyai';
            application.AOB_City__c = 'ABIM';
            application.AOB_State__c = 'Jwaneng Town';
            application.AOB_Street__c = '1st';    
            application.CNGCU_Email__c = 'testUser'+i+'@standardbank.com';
            application.CNGCU_Phone__c = '256987654321';
            application.AOB_DateofBirth__c = Date.valueOf('1993-01-01 00:00:00');
            application.AOB_IDNumber__c = 'CM930121003EGE';
            application.AOB_Preferred_Name__c='test';
            application.AOB_CIFID__c='02626616726';
            application.AOB_PrimaryNationality__c = 'UG';
            application.AOB_KeyContactPerson__c=true;
            application.CNGCU_Email__c='jt@gmail.com';
            application.AOB_Signatory__c=true;
            application.AOB_Card_Number__c='000092637';
            application.AOB_AddressValidFrom__c = system.today();
            applicationParticipantList.add(application); 
        }
        return applicationParticipantList;
    }
    /**
    * @description Method for create docuemnt based participant 
    * @return Application_Document__c
    */
    public static Application_Document__c createDocumentBasedOnParticipant(){
     List<Application_Participant__c> applicationParticipantList =   BCB_DAL_TestFactory.createApplicationParticipant(1);
          Application_Document__c document = new Application_Document__c();
                document.Document_Type__c = 'Upload Proof of Identity';
                document.Application_Participant__c = applicationParticipantList[0].Id;
                document.External_Id__c='test';
        return document;
    }
     /**
    * @description  creates Lead, Application, Application Participant
     * @param productId
    */
   public static void createAppRecords(Id productId){
        Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Uganda_BCB_Account_Onboarding').getRecordTypeId();
        Lead lobj = new Lead();
        lobj.FirstName = 'Test';
        lobj.LastName = 'Test LastName';
        lobj.MobilePhone = '0987878787';
        lobj.Email = 'sample@gmail.com';
        lobj.RecordTypeId = leadRecordTypeId;
        insert lobj;

        Id applicationRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('Uganda_BCB_Account_Onboarding').getRecordTypeId();
        Application__c application = new Application__c();
        application.RecordTypeId=applicationRecordTypeId;
        application.Status__c = 'In Progress';
        application.AOB_Lead__c = lobj.Id;  
        application.AOB_Product__c =productId;
        application.AOB_UG_BCB_Stage__c = 'Pre-Application';
        application.AOB_BCCEntityType__c = 'Sole Proprietor';
        application.AOB_Selected_Currency__c = 'USD';
        insert application; 

        Application_Participant__c appParticipant= new Application_Participant__c();
        appParticipant.AOB_Title__c = '139';
        appParticipant.AOB_Gender__c = 'Female';
        appParticipant.CNGCU_First_Name__c = 'FirstName';
        appParticipant.CNGCU_Last_Name__c = 'LastName';
        appParticipant.AOB_Preferred_Name__c = 'Preferred Name';
        appParticipant.AOB_IDNumber__c = '12345678';
        appParticipant.AOB_DateofBirth__c = Date.today();
        appParticipant.AOB_National_ID_expiry_date__c = Date.today();
        appParticipant.CNGCU_Phone__c = '098767676';
        appParticipant.CNGCU_Email__c = 'sample@gmail.com';
        appParticipant.AOB_Occupation__c = 'Income from Own Business';
        appParticipant.Application__c = application.Id;
        appParticipant.AOB_Stage__c = 'Pre application-Step1';

        insert appParticipant;
        
        Application_Document__c appDoc = new Application_Document__c();
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
    * @description  creates product data info 
    * @return prd.Id
    */
    public static Id createProducts(){
        Product2 prd=new Product2();
        prd.ProductCode='OD005';
        prd.AOB_Memo_Code__c='OD005';
        prd.Name='test test';
        insert prd;
        return prd.Id;
    }

    
}