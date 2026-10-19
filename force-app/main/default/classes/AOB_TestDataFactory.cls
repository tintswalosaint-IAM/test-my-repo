/**
 * @description       : Test data factory class for creating mock data used in test classes
 * @author            : Amarnath Reddy
 * @group             : 
 * @last modified on  : 10-21-2025
 * @last modified by  : jagadish Thummala
**/
@isTest
public class AOB_TestDataFactory {
    /**
     * @description Method to create a list of Application__c records
     * @author Amarnath Reddy | 06/2022 
     * @param numApplications The number of applications to create
     * @return List<Application__c> The list of created Application__c records
     */
    public static List<Application__c> createApplication(Integer numApplications) {
        List<Application__c> applicationList = new List<Application__c>();
        for(Integer i = 0; i < numApplications; i++) {
            Application__c application = new Application__c();
            application.AOB_FirstName__c = 'Johnson Tipiyai';
            application.AOB_City__c = 'ABIM';
            application.AOB_Country__c = 'IN';
            application.AOB_State__c = 'WST';
            application.AOB_Street__c = '1st';    
            application.AOB_Email__c = 'testUser' + i + '@standardbank.com';
            application.AOB_Phone__c = '256987654321';
            application.AOB_DOB__c = Date.valueOf('1993-01-01 00:00:00');
            application.AOB_NIN__c = 'CM930121003EGE';
            application.AOB_UTM_Source__c = 'SFMC';
            application.AOB_UTM_Medium__c = 'email';
            application.AOB_Fund_Amount__c = '12000';
            application.AOB_Account_Number__c = '9030020820380';
            application.AOB_Mobile_Money_Number__c = '997755660' + i;
            application.AOB_Nationality__c = 'IN';
            application.AOB_UTM_Campaign__c = '101_Consumer_UG__05102022_credit-card_gold_POC-Campaign-for-onboarding-dropped_SFMC_push';
            application.AOB_Accommodation_Type__c = 'X';
            application.AOB_County__c = 'Abim';
            application.AOB_Course_Name__c = 'MBA';
            application.AOB_Current_Address_City__c = 'ABIM';
            application.AOB_Current_Address_From_Date__c = system.today();
            application.AOB_Current_Address_PostalCode__c = '256';
            application.AOB_Current_Address_State__c = 'WST';
            application.AOB_Current_Address_Street__c = 'Street';
            application.AOB_Customer_Id__c = '10302230085';
            application.AOB_Device_Details__c = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36';
            application.AOB_Email_Type__c = 'COMMEML';
            application.AOB_Employer_Address__c = 'Kampala';
            application.AOB_Employer_Name__c = 'AFRICAN MEDICAL RESEARCH FOUNDATION (AMREF)';
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
            application.Employment_Details_Notes__c = 'A12345';
            applicationList.add(application);
        }
        return applicationList;
    }

    /**
     * @description Method to create a ContentVersion record
     * @author Amarnath Reddy | 06/2022 
     * @return ContentVersion The created ContentVersion record
     */
    public static ContentVersion createContentVersion() {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Everyday Banking account_UGX';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        return cv;
    }

    /**
     * @description Method to create a Lead record
     * @author Amarnath Reddy | 06/2022 
     * @return Lead The created Lead record
     */
    public static Lead createLead() {
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
     * @description Method to create an Individual record
     * @author Amarnath Reddy | 06/2022 
     * @return Individual The created Individual record
     */
    public static Individual createIndividual() {
        String recordTypeId = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get('Uganda_Onboarding').getRecordTypeId();
        Individual individualRecord = new Individual();
        individualRecord.FirstName = 'testName';
        individualRecord.LastName = 'testIndividual';
        individualRecord.recordTypeId = recordTypeId;
        return individualRecord;
    }

    /**
     * @description Method to create a list of Product2 records
     * @author Amarnath Reddy | 06/2022 
     * @return List<Product2> The list of created Product2 records
     */
    public static List<Product2> createProduct() {
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
        List<Product2> prList = new List<Product2>();
        prList.add(pr);
        return prList;
    }

    /**
     * @description Method to create multiple Product2 records with varying configurations
     * @author Amarnath Reddy | 06/2022 
     * @param numOfProducts The number of products to create
     * @return List<Product2> The list of created Product2 records
     */
    public static List<Product2> createMultipleProducts(Integer numOfProducts) {
        List<Product2> prList = new List<Product2>();
        
        for (Integer i = 0; i < numOfProducts; i++) {
            Product2 pr = new Product2();
            pr.AOB_Memo_Code__c = 'VALID' + (i + 1);
            pr.isActive = true;
            pr.AOB_Account_Type__c = 'Everyday Banking account';
            pr.AOB_Pricing_Option__c = 'PAYAS';
            pr.AOB_ProductCategory__c = 'Savings';
            pr.AOB_Product_Details__c = 'Test Product Details';
            pr.AOB_Scheme_Type__c = 'ODA';
            pr.Description = 'Test Description';
            pr.Country__c = 'UG';
            
            // Ensure ONLY the first 2 products have "Uganda Product" names
            if (i == 0) {
                pr.Name = 'Uganda Product 1';
            } else if (i == 1) {
                pr.Name = 'Uganda Product 2';
            } else if (i == 2) {
                pr.Name = 'Excluded Product';
                pr.AOB_Memo_Code__c = 'OD005'; // Different memo code
                pr.Country__c = 'KE'; // Different country
            } else if (i == 3) {
                pr.Name = 'Inactive Product';
                pr.isActive = false; // Make inactive
            } else if (i == 4) {
                pr.Name = 'Non Uganda Product';
                pr.Country__c = 'KE'; // Different country
            } else {
                // For any additional products beyond 5
                pr.Name = 'Test Product ' + i;
            }
            
            prList.add(pr);
        }
        
        return prList;
    }

    /**
     * @description Method to create a ContentDocumentLink record
     * @author Amarnath Reddy | 06/2022 
     * @param linkedEdId The LinkedEntityId for the link
     * @param contentdocId The ContentDocumentId for the link
     * @return ContentDocumentLink The created ContentDocumentLink record
     */
    public static ContentDocumentLink createContentDocumentLink(String linkedEdId, String contentdocId) {
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = linkedEdId;
        contentlink.contentdocumentid = contentdocId;
        contentlink.ShareType = 'V';
        return contentlink; 
    }

    /**
     * @description Method to create a list of AOB_FlowScreen__c records
     * @author Amarnath Reddy | 06/2022 
     * @param numOfScreenRecord The number of flow screen records to create
     * @return List<AOB_FlowScreen__c> The list of created AOB_FlowScreen__c records
     */
    public static List<AOB_FlowScreen__c> createFlowScreen(Integer numOfScreenRecord) {
        List<AOB_FlowScreen__c> flowScreenList = new List<AOB_FlowScreen__c>();
        for(Integer i = 0; i < numOfScreenRecord; i++) {
            AOB_FlowScreen__c fs = new AOB_FlowScreen__c();
            fs.name = 'Great Choice!' + i;
            fs.AO_ExternalId__c = '1234444' + i;
            fs.AOB_TitleApplicationField__c = 'AOB_title__c';
            fs.AOB_Screen_Sequence__c = 19 - i;
            flowScreenList.add(fs);
        }

        return flowScreenList;
    }

    /**
     * @description Method to create an AOB_Field__c record
     * @author Amarnath Reddy | 06/2022 
     * @param section The section for the field
     * @param type The type for the field
     * @return AOB_Field__c The created AOB_Field__c record
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
}