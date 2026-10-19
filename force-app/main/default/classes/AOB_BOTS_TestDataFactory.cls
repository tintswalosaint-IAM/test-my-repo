/**
* @description Class for dealing with data for run the  test classes
* @author Nagendraprasad Mylavarapu
* @date 15-02-2023
*/
@isTest
public inherited sharing class AOB_BOTS_TestDataFactory {

    /**
    * @description Method for the list of application
    * @return application
    */
    public static Application__c createApplication() {
        Application__c application = new Application__c();
        application.AOB_FirstName__c = 'Johnson Tipiyai';
        application.AOB_City__c = 'ABIM';
        application.AOB_Country__c = 'IN';
        application.AOB_State__c = 'NRT';
        application.AOB_Street__c = '1st';    
        application.AOB_Email__c = 'testUser@standardbank.com';
        application.AOB_Phone__c = '256987654321';
        application.AOB_DOB__c = Date.valueOf('1993-01-01 00:00:00');
        application.AOB_NIN__c = 'CM930121003EGE';
        application.AOB_UTM_Source__c = 'SFMC';
        application.AOB_UTM_Medium__c = 'email';
        application.AOB_Fund_Amount__c = '12000';
        application.AOB_Account_Number__c = '9030020820380';
        application.AOB_Mobile_Money_Number__c = '997755660';
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
        
        return application;
    }
    /**
    * @description Method for the list of Banking product details
    * @return cv 
    */
    public static ContentVersion createContentVersion(){
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Everyday Banking ';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        return cv;
    }
    /**
    * @description Method for the lead data
    * @return id 
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
    * @return pr 
    */
    public static Product2 createProduct (){
        Product2 pr = new Product2();
        pr.Name = 'testName';
        pr.isActive = true;
        pr.AOB_Account_Type__c = 'Everyday Banking account';
        pr.AOB_Memo_Code__c = '123';
        pr.AOB_Pricing_Option__c = 'PAYAS';
        pr.AOB_ProductCategory__c = 'Savings';
        pr.AOB_Product_Details__c = 'Test Product Details';
        pr.AOB_Scheme_Type__c = 'ODA';
        pr.Description = 'Test Description';
        pr.Country__c = 'UG';
        return pr;
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
    * @description Method for the flow screen object values
    * @param flowScreenName
    * @param sequence
    * @return flowscreen instance
    */
    public static AOB_FlowScreen__c createFlowScreen(String flowScreenName, Integer sequence) {
        AOB_FlowScreen__c fs = new AOB_FlowScreen__c();
        fs.name = flowScreenName;
        fs.AO_ExternalId__c ='1234444';
        fs.AOB_TitleApplicationField__c = 'AOB_title__c';
        fs.AOB_Screen_Sequence__c = sequence;
        return fs;
    }
    /**
    * @description Method for the screen field object values
    * @param section
    * @param type
    * @return fi
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
    * @description Method for Application Participant
    * @param applicationId
    * @param inflightData
    * @return fi
    */
    public static Application_Participant__c createApplicationParticipant(Id applicationId, String inflightData) {
        Application_Participant__c participant = new Application_Participant__c(
            Application__c = applicationId,
            Inflight__c = inflightData
        );

        return participant;
    }    
}